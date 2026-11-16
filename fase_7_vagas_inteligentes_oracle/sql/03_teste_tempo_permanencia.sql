-- Conferir a compilacao da funcao
SELECT OBJECT_NAME, STATUS
FROM USER_OBJECTS
WHERE OBJECT_NAME = 'FUN_CALCULAR_TEMPO_PERMANENCIA'
  AND OBJECT_TYPE = 'FUNCTION';

-- Se houver erros de compilacao, esta consulta os exibira
SELECT LINE, POSITION, TEXT
FROM USER_ERRORS
WHERE NAME = 'FUN_CALCULAR_TEMPO_PERMANENCIA'
  AND TYPE = 'FUNCTION'
ORDER BY SEQUENCE;

-- Testar duracoes e passagem pela meia-noite
WITH casos AS (
    SELECT 'Mesmo instante' AS cenario,
           DATE '2026-01-01' AS entrada,
           DATE '2026-01-01' AS saida,
           0 AS esperado
    FROM dual

    UNION ALL
    SELECT 'Limite de 30 minutos',
           DATE '2026-01-01',
           DATE '2026-01-01' + 30 / 1440,
           30
    FROM dual

    UNION ALL
    SELECT 'Permanencia de 45 minutos',
           DATE '2026-01-01',
           DATE '2026-01-01' + 45 / 1440,
           45
    FROM dual

    UNION ALL
    SELECT 'Passagem pela meia-noite',
           TO_DATE('01/01/2026 23:50', 'DD/MM/YYYY HH24:MI'),
           TO_DATE('02/01/2026 00:20', 'DD/MM/YYYY HH24:MI'),
           30
    FROM dual
),
resultados AS (
    SELECT cenario,
           esperado,
           FUN_CALCULAR_TEMPO_PERMANENCIA(
               entrada, saida
           ) AS obtido
    FROM casos
)
SELECT cenario,
       esperado,
       obtido,
       CASE
           WHEN esperado = obtido THEN 'OK'
           ELSE 'REVISAR'
       END AS resultado
FROM resultados;


SET SERVEROUTPUT ON;

DECLARE
    v_resultado NUMBER;

    PROCEDURE testar_rejeicao (
        p_cenario       VARCHAR2,
        p_entrada       DATE,
        p_saida         DATE,
        p_erro_esperado NUMBER
    ) IS
    BEGIN
        v_resultado := FUN_CALCULAR_TEMPO_PERMANENCIA(
            p_entrada, p_saida
        );

        DBMS_OUTPUT.PUT_LINE(
            'FALHOU | ' || p_cenario || ' | Nao rejeitou as datas.'
        );
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = p_erro_esperado THEN
                DBMS_OUTPUT.PUT_LINE(
                    'OK | ' || p_cenario ||
                    ' | Erro esperado: ' || SQLCODE
                );
            ELSE
                RAISE;
            END IF;
    END;
BEGIN
    testar_rejeicao(
        'Entrada nula',
        NULL, DATE '2026-01-01', -20001
    );

    testar_rejeicao(
        'Saida nula',
        DATE '2026-01-01', NULL, -20001
    );

    testar_rejeicao(
        'Saida anterior a entrada',
        DATE '2026-01-02', DATE '2026-01-01', -20002
    );
END;
/