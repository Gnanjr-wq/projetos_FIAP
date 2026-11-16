CREATE OR REPLACE FUNCTION FUN_MASCARAR_PLACA (
    p_placa IN VARCHAR2
) RETURN VARCHAR2
IS
    v_placa VARCHAR2(32767);
BEGIN
    v_placa := TRIM(p_placa);

    IF v_placa IS NULL THEN
        RETURN NULL;
    END IF;

    -- Protecao adicional para valores curtos:
    -- mascara integralmente quando houver ate tres caracteres.
    IF LENGTH(v_placa) <= 3 THEN
        RETURN RPAD('*', LENGTH(v_placa), '*');
    END IF;

    RETURN RPAD('*', LENGTH(v_placa) - 3, '*')
           || SUBSTR(v_placa, -3);
END;
/