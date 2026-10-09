SELECT
    *
    
FROM T_SRC_PREFEITURA_CIDADAO;

SELECT
*
FROM T_SRC_RECEITA_FEDERAL;

SELECT
    object_name,
    object_type,
    status
FROM user_objects
WHERE object_name IN (
    'T_MDM_CIDADAO',
    'SQ_MDM_CIDADAO'
)
ORDER BY object_type, object_name;