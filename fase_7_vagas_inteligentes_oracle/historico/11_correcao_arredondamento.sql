SET SERVEROUTPUT ON;

DECLARE
    v_permanencias NUMBER;
    v_cobrancas    NUMBER;
BEGIN
    SAVEPOINT antes_correcao;

    UPDATE T_PERMANENCIA_VEICULO
    SET NR_TEMPO_PERMANENCIA_MIN =
        ROUND(
            ROUND((DT_SAIDA - DT_ENTRADA) * 86400) / 60
        )
    WHERE
        (ID_PERMANENCIA = 3204 AND NR_TEMPO_PERMANENCIA_MIN = 72)
        OR
        (ID_PERMANENCIA = 4193 AND NR_TEMPO_PERMANENCIA_MIN = 75)
        OR
        (ID_PERMANENCIA = 4799 AND NR_TEMPO_PERMANENCIA_MIN = 78)
        OR
        (ID_PERMANENCIA = 5349 AND NR_TEMPO_PERMANENCIA_MIN = 93)
        OR
        (ID_PERMANENCIA = 6500 AND NR_TEMPO_PERMANENCIA_MIN = 99)
        OR
        (ID_PERMANENCIA = 8412 AND NR_TEMPO_PERMANENCIA_MIN = 81);

    v_permanencias := SQL%ROWCOUNT;

    IF v_permanencias <> 6 THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Esperadas 6 permanencias; encontradas '
            || v_permanencias || '. Correcao desfeita.'
        );
    END IF;

    UPDATE T_COBRANCA_VAGA c
    SET (NR_MINUTOS_EXCEDENTES, VL_COBRANCA) = (
        SELECT
            p.NR_TEMPO_PERMANENCIA_MIN - 30,
            ROUND((p.NR_TEMPO_PERMANENCIA_MIN - 30) * 0.20, 2)
        FROM T_PERMANENCIA_VEICULO p
        WHERE p.ID_PERMANENCIA = c.ID_PERMANENCIA
    )
    WHERE c.ST_COBRANCA = 'G'
      AND (
          (c.ID_COBRANCA = 2780 AND c.ID_PERMANENCIA = 3204
           AND c.VL_COBRANCA = 8.40)
          OR
          (c.ID_COBRANCA = 4203 AND c.ID_PERMANENCIA = 4799
           AND c.VL_COBRANCA = 9.60)
          OR
          (c.ID_COBRANCA = 4731 AND c.ID_PERMANENCIA = 5349
           AND c.VL_COBRANCA = 12.60)
          OR
          (c.ID_COBRANCA = 5670 AND c.ID_PERMANENCIA = 6500
           AND c.VL_COBRANCA = 13.80)
      );

    v_cobrancas := SQL%ROWCOUNT;

    IF v_cobrancas <> 4 THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'Esperadas 4 cobrancas; encontradas '
            || v_cobrancas || '. Correcao desfeita.'
        );
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'Permanencias corrigidas: ' || v_permanencias
    );
    DBMS_OUTPUT.PUT_LINE(
        'Cobrancas corrigidas: ' || v_cobrancas
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO antes_correcao;
        RAISE;
END;
/