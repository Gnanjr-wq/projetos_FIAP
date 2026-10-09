-- Confere o volume e o preenchimento das colunas
-- que serão implementadas na versão 2.

SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT NR_CPF_CIDADAO) AS cpfs_distintos,
    COUNT(NR_IDADE) AS com_idade,
    COUNT(NM_FAIXA_ETARIA) AS com_faixa_etaria,
    COUNT(NM_SEXO) AS com_sexo,
    COUNT(NM_ESCOLARIDADE) AS com_escolaridade
FROM T_MDM_CIDADAO;



SELECT
    COUNT(*) AS total_cidadaos,
    COUNT(DISTINCT nr_cpf_cidadao) AS cpfs_distintos,
    COUNT(nr_idade) AS com_idade,
    COUNT(nm_faixa_etaria) AS com_faixa_etaria,
    COUNT(nm_sexo) AS com_sexo,
    COUNT(nm_escolaridade) AS com_escolaridade
FROM t_mdm_cidadao;