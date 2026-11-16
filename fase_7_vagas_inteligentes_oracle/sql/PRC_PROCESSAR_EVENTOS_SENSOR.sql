CREATE OR REPLACE PROCEDURE PRC_PROCESSAR_EVENTOS_SENSOR IS

    -- Classifica as repeticoes considerando todo o historico.
    -- Eventos ja processados com sucesso têm prioridade;
    -- nos demais casos, preserva-se o menor ID.
    CURSOR c_eventos IS
        SELECT e.ID_EVENTO_SENSOR,
               e.CD_SENSOR,
               e.NR_VAGA,
               e.ST_VAGA,
               e.DT_EVENTO,
               e.NR_PLACA_VEICULO,
               e.ORDEM_REPETICAO,
               v.ID_VAGA,
               v.TP_VAGA
        FROM (
            SELECT s.*,
                   ROW_NUMBER() OVER (
                       PARTITION BY CD_SENSOR, NR_VAGA, DT_EVENTO
                       ORDER BY
                           CASE WHEN FL_PROCESSADO = 'S'
                                THEN 0 ELSE 1 END,
                           ID_EVENTO_SENSOR
                   ) AS ORDEM_REPETICAO
            FROM T_STG_EVENTO_SENSOR_VAGA s
        ) e
        LEFT JOIN T_VAGA v
          ON v.CD_SENSOR = e.CD_SENSOR
         AND v.NR_VAGA = e.NR_VAGA
        WHERE e.FL_PROCESSADO = 'N'
        ORDER BY e.CD_SENSOR,
                 e.NR_VAGA,
                 e.DT_EVENTO,
                 e.ID_EVENTO_SENSOR;

    TYPE t_entrada_pendente IS RECORD (
        id_evento NUMBER,
        dt_entrada DATE,
        nr_placa VARCHAR2(10)
    );

    TYPE t_tab_entrada IS TABLE OF t_entrada_pendente
        INDEX BY VARCHAR2(100);

    v_entradas          t_tab_entrada;
    v_chave             VARCHAR2(100);
    v_tempo_min         NUMBER;
    v_id_permanencia    NUMBER;
    v_minutos_livres    NUMBER;
    v_valor_minuto      NUMBER;
    v_minutos_excedentes NUMBER;
    v_valor_cobranca    NUMBER;

    v_total_lidos       NUMBER := 0;
    v_total_erros       NUMBER := 0;
    v_total_permanencias NUMBER := 0;
    v_total_cobrancas   NUMBER := 0;

    -- Atualiza o evento e registra o motivo da rejeicao.
    PROCEDURE rejeitar_evento (
        p_id_evento IN NUMBER,
        p_motivo    IN VARCHAR2
    ) IS
    BEGIN
        UPDATE T_STG_EVENTO_SENSOR_VAGA
        SET FL_PROCESSADO = 'E'
        WHERE ID_EVENTO_SENSOR = p_id_evento
          AND FL_PROCESSADO = 'N';

        PRC_REGISTRAR_ERRO(p_id_evento, p_motivo);

        v_total_erros := v_total_erros + 1;
    END rejeitar_evento;

BEGIN
    SAVEPOINT inicio_processamento_vagas;

    -- Evita duas execucoes simultaneas sobre os mesmos eventos.
    LOCK TABLE T_STG_EVENTO_SENSOR_VAGA
        IN EXCLUSIVE MODE NOWAIT;

    FOR r_evento IN c_eventos LOOP
        v_total_lidos := v_total_lidos + 1;

        -- Validacoes basicas da RN04.
        IF r_evento.DT_EVENTO IS NULL THEN
            rejeitar_evento(
                r_evento.ID_EVENTO_SENSOR,
                'Data do evento ausente.'
            );
            CONTINUE;
        END IF;

        IF r_evento.ST_VAGA IS NULL
           OR r_evento.ST_VAGA NOT IN ('O', 'S') THEN
            rejeitar_evento(
                r_evento.ID_EVENTO_SENSOR,
                'Status do evento invalido: esperado O ou S.'
            );
            CONTINUE;
        END IF;

        IF r_evento.ID_VAGA IS NULL THEN
            rejeitar_evento(
                r_evento.ID_EVENTO_SENSOR,
                'Sensor/vaga nao localizado no cadastro.'
            );
            CONTINUE;
        END IF;

        -- RN03: repeticao de sensor, vaga e instante.
        IF r_evento.ORDEM_REPETICAO > 1 THEN
            rejeitar_evento(
                r_evento.ID_EVENTO_SENSOR,
                'Evento repetido: mesmo sensor, vaga e data/hora.'
            );
            CONTINUE;
        END IF;

        -- Prefixo com tamanho evita ambiguidades na chave.
        v_chave := LENGTH(r_evento.CD_SENSOR) || ':'
                   || r_evento.CD_SENSOR || ':'
                   || r_evento.NR_VAGA;

        IF r_evento.ST_VAGA = 'O' THEN

            IF v_entradas.EXISTS(v_chave) THEN
                rejeitar_evento(
                    r_evento.ID_EVENTO_SENSOR,
                    'Entrada sem saida da ocupacao anterior.'
                );
            ELSE
                v_entradas(v_chave).id_evento :=
                    r_evento.ID_EVENTO_SENSOR;

                v_entradas(v_chave).dt_entrada :=
                    r_evento.DT_EVENTO;

                v_entradas(v_chave).nr_placa :=
                    r_evento.NR_PLACA_VEICULO;
            END IF;

        ELSIF r_evento.ST_VAGA = 'S' THEN

            IF NOT v_entradas.EXISTS(v_chave) THEN
                rejeitar_evento(
                    r_evento.ID_EVENTO_SENSOR,
                    'Saida sem entrada correspondente.'
                );
                CONTINUE;
            END IF;

            -- RN02: calcular a duracao.
            v_tempo_min := FUN_CALCULAR_TEMPO_PERMANENCIA(
                v_entradas(v_chave).dt_entrada,
                r_evento.DT_EVENTO
            );

            -- Parametros aplicaveis ao instante de entrada.
            -- Termino nulo indica vigencia sem data final.
            BEGIN
                SELECT NR_MINUTOS_TEMPO_LIVRE,
                       VL_MINUTO_VAGA
                INTO v_minutos_livres,
                     v_valor_minuto
                FROM T_PARAMETROS_ESTACIONAMENTO
                WHERE DT_INICIO_VIGENCIA <=
                      v_entradas(v_chave).dt_entrada
                  AND (
                      DT_TERMINO_VIGENCIA IS NULL
                      OR DT_TERMINO_VIGENCIA >=
                         v_entradas(v_chave).dt_entrada
                  );
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    RAISE_APPLICATION_ERROR(
                        -20005,
                        'Sem parametros vigentes para a entrada.'
                    );
                WHEN TOO_MANY_ROWS THEN
                    RAISE_APPLICATION_ERROR(
                        -20006,
                        'Mais de um parametro vigente para a entrada.'
                    );
            END;

            IF v_minutos_livres IS NULL
               OR v_minutos_livres < 0
               OR v_valor_minuto IS NULL
               OR v_valor_minuto <= 0 THEN
                RAISE_APPLICATION_ERROR(
                    -20007,
                    'Parametros de gratuidade ou tarifa invalidos.'
                );
            END IF;

            v_id_permanencia :=
                SEQ_T_PERMANENCIA_VEICULO.NEXTVAL;

            -- RN01 e RN07: gravar permanencia com placa mascarada.
            INSERT INTO T_PERMANENCIA_VEICULO (
                ID_PERMANENCIA,
                CD_SENSOR,
                NR_VAGA,
                DT_ENTRADA,
                DT_SAIDA,
                NR_TEMPO_PERMANENCIA_MIN,
                DT_PROCESSAMENTO,
                NR_PLACA_VEICULO
            )
            VALUES (
                v_id_permanencia,
                r_evento.CD_SENSOR,
                r_evento.NR_VAGA,
                v_entradas(v_chave).dt_entrada,
                r_evento.DT_EVENTO,
                v_tempo_min,
                SYSDATE,
                FUN_MASCARAR_PLACA(
                    v_entradas(v_chave).nr_placa
                )
            );

            -- RN05 e RN06: cobrar apenas quando elegivel.
            IF FUN_DEVE_COBRAR(
                r_evento.TP_VAGA,
                v_tempo_min,
                v_minutos_livres
            ) = 'S' THEN

                v_minutos_excedentes :=
                    v_tempo_min - v_minutos_livres;

                v_valor_cobranca := ROUND(
                    v_minutos_excedentes * v_valor_minuto,
                    2
                );

                INSERT INTO T_COBRANCA_VAGA (
                    ID_COBRANCA,
                    ID_PERMANENCIA,
                    NR_MINUTOS_EXCEDENTES,
                    VL_COBRANCA,
                    ST_COBRANCA,
                    DT_VENCIMENTO,
                    DT_GERACAO
                )
                VALUES (
                    SEQ_T_COBRANCA_VAGA.NEXTVAL,
                    v_id_permanencia,
                    v_minutos_excedentes,
                    v_valor_cobranca,
                    'G',
                    v_entradas(v_chave).dt_entrada + 30,
                    SYSDATE
                );

                v_total_cobrancas := v_total_cobrancas + 1;
            END IF;

            -- Marcar o par somente depois das gravacoes.
            UPDATE T_STG_EVENTO_SENSOR_VAGA
            SET FL_PROCESSADO = 'S'
            WHERE ID_EVENTO_SENSOR IN (
                v_entradas(v_chave).id_evento,
                r_evento.ID_EVENTO_SENSOR
            )
              AND FL_PROCESSADO = 'N';

            v_total_permanencias :=
                v_total_permanencias + 1;

            v_entradas.DELETE(v_chave);
        END IF;
    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Eventos lidos: ' || v_total_lidos
    );
    DBMS_OUTPUT.PUT_LINE(
        'Eventos rejeitados: ' || v_total_erros
    );
    DBMS_OUTPUT.PUT_LINE(
        'Permanencias geradas: ' || v_total_permanencias
    );
    DBMS_OUTPUT.PUT_LINE(
        'Cobrancas geradas: ' || v_total_cobrancas
    );
    DBMS_OUTPUT.PUT_LINE(
        'Entradas aguardando saida: ' || v_entradas.COUNT
    );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO inicio_processamento_vagas;
        RAISE;
END PRC_PROCESSAR_EVENTOS_SENSOR;
/