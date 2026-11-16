CREATE OR REPLACE PROCEDURE PRC_REGISTRAR_ERRO (
    p_id_evento_sensor IN NUMBER,
    p_ds_motivo_erro   IN VARCHAR2
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO T_LOG_ERRO_EVENTO (
        ID_LOG,
        ID_EVENTO_SENSOR,
        DS_MOTIVO_ERRO,
        DT_OCORRENCIA
    )
    VALUES (
        SEQ_T_LOG_ERRO_EVENTO.NEXTVAL,
        p_id_evento_sensor,
        SUBSTR(p_ds_motivo_erro, 1, 200),
        SYSDATE
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/