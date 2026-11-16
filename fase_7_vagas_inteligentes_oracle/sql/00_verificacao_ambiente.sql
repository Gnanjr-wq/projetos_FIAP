-- Fase 7: conexao e identificacao do schema
SELECT
    USER AS usuario_conectado,
    SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS schema_atual,
    TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') AS data_hora_banco
FROM dual;

-- Confere se os objetos da Fase 7 ja existem
SELECT
    object_name,
    object_type,
    status
FROM user_objects
WHERE object_name IN (
    'T_PARAMETROS_ESTACIONAMENTO',
    'T_VAGA',
    'T_STG_EVENTO_SENSOR_VAGA',
    'T_PERMANENCIA_VEICULO',
    'T_COBRANCA_VAGA',
    'T_LOG_ERRO_EVENTO',
    'SEQ_T_VAGA',
    'SEQ_T_STG_EVENTO_SENSOR_VAGA',
    'SEQ_T_PERMANENCIA_VEICULO',
    'SEQ_T_COBRANCA_VAGA',
    'SEQ_T_LOG_ERRO_EVENTO',
    'FUN_CALCULAR_TEMPO_PERMANENCIA',
    'PRC_REGISTRAR_ERRO',
    'PRC_PROCESSAR_EVENTOS_SENSOR'
)
ORDER BY object_type, object_name;
