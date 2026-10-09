-- Diagnóstico inicial: volume e identificação dos cidadãos.
-- TRIM desconsidera espaços nas extremidades do CPF.

SELECT
    'PREFEITURA' AS origem,
    COUNT(*) AS total_registros,
    COUNT(DISTINCT TRIM(CPF_PREFEITURA)) AS cpfs_distintos,
    COUNT(*) - COUNT(TRIM(CPF_PREFEITURA)) AS cpfs_vazios,
    COUNT(TRIM(CPF_PREFEITURA))
        - COUNT(DISTINCT TRIM(CPF_PREFEITURA))
        AS repeticoes_cpf
FROM T_SRC_PREFEITURA_CIDADAO

UNION ALL

SELECT
    'RECEITA FEDERAL' AS origem,
    COUNT(*) AS total_registros,
    COUNT(DISTINCT TRIM(CPF_RECEITA)) AS cpfs_distintos,
    COUNT(*) - COUNT(TRIM(CPF_RECEITA)) AS cpfs_vazios,
    COUNT(TRIM(CPF_RECEITA))
        - COUNT(DISTINCT TRIM(CPF_RECEITA))
        AS repeticoes_cpf
FROM T_SRC_RECEITA_FEDERAL;


-- Verifica a correspondência de CPF entre as origens.

SELECT
    CASE
        WHEN p.CPF_PREFEITURA IS NULL
            THEN 'SOMENTE NA RECEITA'
        WHEN r.CPF_RECEITA IS NULL
            THEN 'SOMENTE NA PREFEITURA'
        ELSE 'NAS DUAS ORIGENS'
    END AS situacao_cpf,
    COUNT(*) AS quantidade
FROM T_SRC_PREFEITURA_CIDADAO p
FULL OUTER JOIN T_SRC_RECEITA_FEDERAL r
    ON TRIM(p.CPF_PREFEITURA) = TRIM(r.CPF_RECEITA)
GROUP BY
    CASE
        WHEN p.CPF_PREFEITURA IS NULL
            THEN 'SOMENTE NA RECEITA'
        WHEN r.CPF_RECEITA IS NULL
            THEN 'SOMENTE NA PREFEITURA'
        ELSE 'NAS DUAS ORIGENS'
    END
ORDER BY situacao_cpf;


-- Mostra os valores recebidos, antes da padronização.

SELECT
    'PREFEITURA' AS origem,
    NVL(TRIM(SEXO_PREF), '(VAZIO)') AS sexo_origem,
    COUNT(*) AS quantidade
FROM T_SRC_PREFEITURA_CIDADAO
GROUP BY TRIM(SEXO_PREF)

UNION ALL

SELECT
    'RECEITA FEDERAL' AS origem,
    NVL(TRIM(SEXO), '(VAZIO)') AS sexo_origem,
    COUNT(*) AS quantidade
FROM T_SRC_RECEITA_FEDERAL
GROUP BY TRIM(SEXO)

ORDER BY origem, sexo_origem;


-- Prefeitura: MM/DD/YYYY
-- Receita Federal: DD/MM/YYYY
-- Consulta de diagnóstico: não modifica os dados.

WITH diagnostico_datas AS (
    SELECT
        'PREFEITURA' AS origem,
        CASE
            WHEN TRIM(DT_NASC_PREF) IS NULL
                THEN 'AUSENTE'
            WHEN VALIDATE_CONVERSION(
                TRIM(DT_NASC_PREF) AS DATE, 'FXMM/DD/YYYY'
            ) = 0
                THEN 'INVALIDA'
            ELSE 'CONVERSIVEL'
        END AS situacao
    FROM T_SRC_PREFEITURA_CIDADAO

    UNION ALL

    SELECT
        'RECEITA FEDERAL' AS origem,
        CASE
            WHEN TRIM(DT_NASCIMENTO) IS NULL
                THEN 'AUSENTE'
            WHEN VALIDATE_CONVERSION(
                TRIM(DT_NASCIMENTO) AS DATE, 'FXDD/MM/YYYY'
            ) = 0
                THEN 'INVALIDA'
            ELSE 'CONVERSIVEL'
        END AS situacao
    FROM T_SRC_RECEITA_FEDERAL
)
SELECT
    origem,
    situacao,
    COUNT(*) AS quantidade
FROM diagnostico_datas
GROUP BY origem, situacao
ORDER BY origem, situacao;



-- Identifica os padrões de escolaridade recebidos da Receita.

SELECT
    NVL(TRIM(ESCOLARIDADE), '(VAZIO)') AS escolaridade_origem,
    COUNT(*) AS quantidade
FROM T_SRC_RECEITA_FEDERAL
GROUP BY TRIM(ESCOLARIDADE)
ORDER BY quantidade DESC, escolaridade_origem;


