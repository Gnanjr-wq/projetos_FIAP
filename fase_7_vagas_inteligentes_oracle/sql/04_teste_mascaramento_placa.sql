WITH casos AS (
    SELECT 'Placa antiga' AS cenario,
           'ABC1234' AS placa,
           '****234' AS esperado
    FROM dual

    UNION ALL
    SELECT 'Placa Mercosul', 'ABC1D23', '****D23'
    FROM dual

    UNION ALL
    SELECT 'Espacos externos', ' ABC1234 ', '****234'
    FROM dual

    UNION ALL
    SELECT 'Valor curto', 'AB', '**'
    FROM dual

    UNION ALL
    SELECT 'Placa ausente', NULL, NULL
    FROM dual
),
resultados AS (
    SELECT cenario,
           esperado,
           FUN_MASCARAR_PLACA(placa) AS obtido
    FROM casos
)
SELECT cenario,
       esperado,
       obtido,
       CASE
           WHEN esperado = obtido
             OR (esperado IS NULL AND obtido IS NULL)
           THEN 'OK'
           ELSE 'REVISAR'
       END AS resultado
FROM resultados;