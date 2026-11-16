CREATE OR REPLACE FUNCTION FUN_CALCULAR_TEMPO_PERMANENCIA (
    p_dt_entrada IN DATE,
    p_dt_saida   IN DATE
) RETURN NUMBER
IS
BEGIN
    IF p_dt_entrada IS NULL OR p_dt_saida IS NULL THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Data de entrada e data de saida sao obrigatorias.'
        );
    END IF;

    IF p_dt_saida < p_dt_entrada THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'Data de saida anterior a data de entrada.'
        );
    END IF;

    -- Mantem o arredondamento utilizado no exemplo fornecido.
    -- A diferenca entre datas Oracle e expressa em dias.
    RETURN ROUND(
    ROUND((p_dt_saida - p_dt_entrada) * 86400) / 60
);
END;
/
