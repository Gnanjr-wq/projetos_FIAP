CREATE OR REPLACE FUNCTION FUN_DEVE_COBRAR (
    p_tipo_vaga      IN VARCHAR2,
    p_tempo_minutos  IN NUMBER,
    p_minutos_livres IN NUMBER
) RETURN CHAR
IS
    v_tipo VARCHAR2(32767);
BEGIN
    v_tipo := UPPER(TRIM(p_tipo_vaga));

    IF v_tipo IS NULL
       OR v_tipo NOT IN ('COMUM', 'IDOSO', 'PCD') THEN
        RAISE_APPLICATION_ERROR(
            -20003, 'Tipo de vaga invalido ou ausente.'
        );
    END IF;

    IF p_tempo_minutos IS NULL OR p_tempo_minutos < 0
       OR p_minutos_livres IS NULL OR p_minutos_livres < 0 THEN
        RAISE_APPLICATION_ERROR(
            -20004, 'Tempo de permanencia ou limite gratuito invalido.'
        );
    END IF;

    IF v_tipo = 'COMUM'
       AND p_tempo_minutos > p_minutos_livres THEN
        RETURN 'S';
    END IF;

    RETURN 'N';
END;
/