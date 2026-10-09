-- 1. Quantidade, unicidade e preenchimento dos novos campos
SELECT
    COUNT(*) AS total_cidadaos,
    COUNT(DISTINCT nr_cpf_cidadao) AS cpfs_distintos,
    COUNT(nr_idade) AS com_idade,
    COUNT(nm_faixa_etaria) AS com_faixa_etaria,
    COUNT(nm_sexo) AS com_sexo,
    COUNT(nm_escolaridade) AS com_escolaridade
FROM t_mdm_cidadao;

-- 2. Distribuicao por faixa etaria
SELECT
    nm_faixa_etaria,
    COUNT(*) AS quantidade
FROM t_mdm_cidadao
GROUP BY nm_faixa_etaria
ORDER BY nm_faixa_etaria;

-- 3. Distribuicao por sexo
SELECT
    nm_sexo,
    COUNT(*) AS quantidade
FROM t_mdm_cidadao
GROUP BY nm_sexo
ORDER BY nm_sexo;

-- 4. Escolaridade apos a padronizacao
SELECT
    nm_escolaridade,
    COUNT(*) AS quantidade
FROM t_mdm_cidadao
GROUP BY nm_escolaridade
ORDER BY nm_escolaridade;

-- 5. Registros com e sem divergencias
SELECT
    fl_divergencia,
    COUNT(*) AS quantidade
FROM t_mdm_cidadao
GROUP BY fl_divergencia
ORDER BY fl_divergencia;



-- Conferir os motivos da ausencia de idade e faixa etaria
SELECT
    m.id_gold_cidadao,
    r.dt_nascimento AS nascimento_receita,
    p.dt_nasc_pref AS nascimento_prefeitura,
    m.dt_nascimento AS nascimento_mdm,
    m.nr_idade,
    m.nm_faixa_etaria,
    m.fl_divergencia,
    m.ds_divergencia
FROM t_mdm_cidadao m
JOIN t_src_receita_federal r
    ON r.cpf_receita = m.nr_cpf_cidadao_mascara
JOIN t_src_prefeitura_cidadao p
    ON p.cpf_prefeitura = m.nr_cpf_cidadao_mascara
WHERE m.nr_idade IS NULL
   OR m.nm_faixa_etaria IS NULL
ORDER BY m.id_gold_cidadao;

-- Validacao apos reexecutar a carga
SELECT
    COUNT(*) AS total_cidadaos,
    COUNT(DISTINCT nr_cpf_cidadao) AS cpfs_distintos,
    COUNT(DISTINCT id_gold_cidadao) AS ids_distintos
FROM t_mdm_cidadao;