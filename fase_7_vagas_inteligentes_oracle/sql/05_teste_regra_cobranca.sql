WITH casos AS (
    SELECT 'Comum abaixo do limite' AS cenario,
           'COMUM' AS tipo,
           20 AS minutos,
           30 AS limite,
           'N' AS esperado
    FROM dual

    UNION ALL
    SELECT 'Comum no limite', 'COMUM', 30, 30, 'N'
    FROM dual

    UNION ALL
    SELECT 'Comum acima do limite', 'COMUM', 31, 30, 'S'
    FROM dual

    UNION ALL
    SELECT 'Idoso acima do limite', 'IDOSO', 60, 30, 'N'
    FROM dual

    UNION ALL
    SELECT 'PCD acima do limite', 'PCD', 60, 30, 'N'
    FROM dual

    UNION ALL
    SELECT 'Limite parametrizado em 60', 'COMUM', 45, 60, 'N'
    FROM dual
),
resultados AS (
    SELECT cenario,
           esperado,
           FUN_DEVE_COBRAR(tipo, minutos, limite) AS obtido
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

-- Teste integrado: tempo, elegibilidade e valor da cobranca
WITH casos AS (
    SELECT 'Comum: 30 minutos' AS cenario,
           'COMUM' AS tipo,
           30 AS minutos,
           0 AS valor_esperado
    FROM dual

    UNION ALL
    SELECT 'Comum: 31 minutos', 'COMUM', 31, 0.20
    FROM dual

    UNION ALL
    SELECT 'Comum: 45 minutos', 'COMUM', 45, 3.00
    FROM dual

    UNION ALL
    SELECT 'Idoso: 60 minutos', 'IDOSO', 60, 0
    FROM dual

    UNION ALL
    SELECT 'PCD: 60 minutos', 'PCD', 60, 0
    FROM dual
),
tempos AS (
    SELECT cenario,
           tipo,
           valor_esperado,
           FUN_CALCULAR_TEMPO_PERMANENCIA(
               DATE '2026-01-01',
               DATE '2026-01-01' + minutos / 1440
           ) AS tempo_calculado
    FROM casos
),
valores AS (
    SELECT cenario,
           tempo_calculado,
           valor_esperado,
           CASE
               WHEN FUN_DEVE_COBRAR(
                   tipo, tempo_calculado, 30
               ) = 'S'
               THEN ROUND((tempo_calculado - 30) * 0.20, 2)
               ELSE 0
           END AS valor_obtido
    FROM tempos
)
SELECT cenario,
       tempo_calculado,
       valor_esperado,
       valor_obtido,
       CASE
           WHEN valor_esperado = valor_obtido THEN 'OK'
           ELSE 'REVISAR'
       END AS resultado
FROM valores;