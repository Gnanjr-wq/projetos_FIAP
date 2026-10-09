-- Projeto: Cidade Alfa - PBL Fase 6
-- Objetivo: apresentar a quantidade de cidadãos por estado civil.

CREATE OR REPLACE VIEW VW_MDM_ESTADO_CIVIL AS
SELECT
    NM_ESTADO_CIVIL,
    COUNT(*) AS QTDE_CIDADAOS
FROM T_MDM_CIDADAO
GROUP BY NM_ESTADO_CIVIL;

-- Consulta da view, ordenada da maior para a menor quantidade.
SELECT
    NM_ESTADO_CIVIL,
    QTDE_CIDADAOS
FROM VW_MDM_ESTADO_CIVIL
ORDER BY QTDE_CIDADAOS DESC, NM_ESTADO_CIVIL;