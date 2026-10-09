
-- ============================================================
-- DDL: T_MDM_CIDADAO
-- Projeto: Cidade Alfa � Master Data Management
-- Descricao: Gold Record unificado da populacao
-- ============================================================

-- DROP SEQUENCE SQ_MDM_CIDADAO;
-- DROP TABLE T_MDM_CIDADAO;


CREATE TABLE T_MDM_CIDADAO (
    -- -- Identificacao ----------------------------------------
    ID_GOLD_CIDADAO     NUMBER                          NOT NULL,
    NR_CPF_CIDADAO      NUMBER                          NOT NULL,
    -- -- Dados pessoais ---------------------------------------
	NR_CPF_CIDADAO_MASCARA VARCHAR2(18)                 NOT NULL,
    NM_CIDADAO          VARCHAR2(200)                   NOT NULL,
    DT_NASCIMENTO       DATE                            	NULL,
    NR_IDADE            NUMBER(3)                       	NULL,
    NM_FAIXA_ETARIA     VARCHAR2(20)                    	NULL,
    NM_SEXO             VARCHAR2(20)                    	 NULL,
    NM_ESTADO_CIVIL     VARCHAR2(20)                    	NULL,
    NM_ESCOLARIDADE     VARCHAR2(30)                        NULL,
    -- -- Controle de qualidade --------------------------------
	DT_CARGA			DATE							NOT NULL,
    FL_DIVERGENCIA      VARCHAR2(3)                     NOT NULL,
	DS_DIVERGENCIA		VARCHAR2(4000)						NULL,
    -- -- Constraints ------------------------------------------
    CONSTRAINT PK_MDM_CIDADAO
        PRIMARY KEY (ID_GOLD_CIDADAO),

    CONSTRAINT UK_MDM_CIDADAO_CPF
        UNIQUE (NR_CPF_CIDADAO),

    CONSTRAINT UK_MDM_CIDADAO_CPF_MASCARA
        UNIQUE (NR_CPF_CIDADAO_MASCARA),
		
    -- Ajuste em relação ao DDL original:
    -- inclui BEBE para atender à faixa de 0 a 2 anos da planilha.
    CONSTRAINT CK_MDM_FAIXA_ETARIA
        CHECK (
            NM_FAIXA_ETARIA IN (
                'BEBE',
                'CRIANCA',
                'ADOLESCENTE',
                'ADULTO',
                'IDOSO',
                'NAO_INFORMADO'
            )
        ),

    CONSTRAINT CK_MDM_SEXO
        CHECK (NM_SEXO IN ('MASCULINO','FEMININO','NAO_INFORMADO')),

    CONSTRAINT CK_MDM_ESTADO_CIVIL
        CHECK (NM_ESTADO_CIVIL IN ('SOLTEIRO','CASADO','DIVORCIADO','VIUVO','UNIAO_ESTAVEL','NAO_INFORMADO')),

    CONSTRAINT CK_MDM_FL_DIVERGENCIA
        CHECK (FL_DIVERGENCIA IN ('SIM','NAO')),

    CONSTRAINT CK_MDM_IDADE
        CHECK (NR_IDADE IS NULL OR NR_IDADE BETWEEN 0 AND 130)

);

-- ============================================================
-- SEQUENCE para gera��o do ID_GOLD
-- ============================================================
CREATE SEQUENCE SQ_MDM_CIDADAO
    START WITH     1
    INCREMENT BY   1
    NOCACHE
    NOCYCLE;

-- ============================================================
-- COMENTARIOS DA TABELA
-- ============================================================
COMMENT ON TABLE  T_MDM_CIDADAO                  IS 'Gold Record unificado da populacao � Data Hub MDM Cidade Alfa';
COMMENT ON COLUMN T_MDM_CIDADAO.ID_GOLD_CIDADAO  IS 'PK gerada pela sequence SQ_MDM_CIDADAO';
COMMENT ON COLUMN T_MDM_CIDADAO.NR_CPF_CIDADAO   IS 'CPF do cidadao em formato numerico, sendo chave unica do MDM';
COMMENT ON COLUMN T_MDM_CIDADAO.NR_CPF_CIDADAO_MASCARA   IS 'CPF do cidadao em formato caractere, sendo chave unica no MDM e utilizado para exibi��o de relat�rios e dados completo com mascara';
COMMENT ON COLUMN T_MDM_CIDADAO.NM_CIDADAO       IS 'Nome completo padronizado em UPPER TRIM, com prioridade utilizado pela Receita Federal';
COMMENT ON COLUMN T_MDM_CIDADAO.DT_NASCIMENTO    IS 'Data de nascimento convertida e validada, sendo origem da Receita Federal';
COMMENT ON COLUMN T_MDM_CIDADAO.NR_IDADE         IS 'Conte�do derivado: TRUNC(MONTHS_BETWEEN(SYSTIMESTAMP, DT_NASCIMENTO) / 12)';
COMMENT ON COLUMN T_MDM_CIDADAO.NM_FAIXA_ETARIA  IS 'Conte�do derivado: via IF/ELSIF: CRIANCA/ADOLESCENTE/ADULTO/IDOSO';
COMMENT ON COLUMN T_MDM_CIDADAO.NM_SEXO          IS 'Mapeado dos 3 dominios de origem para padrao unico via CASE WHEN';
COMMENT ON COLUMN T_MDM_CIDADAO.NM_ESTADO_CIVIL  IS 'Origem exclusiva gerada pela Receita Federal';
COMMENT ON COLUMN T_MDM_CIDADAO.NM_ESCOLARIDADE  IS 'Escolaridade do cidad�o disponibilizada pela Receita Federal';
COMMENT ON COLUMN T_MDM_CIDADAO.DT_CARGA		 IS 'Ir� receber o conte�do de SYSTIMESTAMP e que deve armazenar o momento no tempo em que foi gerado esse registro na tabela T_MDM_CIDADAO';
COMMENT ON COLUMN T_MDM_CIDADAO.FL_DIVERGENCIA   IS 'SIM quando nome ou data diverge entre as origens de dados';
COMMENT ON COLUMN T_MDM_CIDADAO.DS_DIVERGENCIA   IS 'Informa��es sobre qualquer diverg�ncia encontrada nos dados do cidad�o e que ir� servir para apoiar a qualidade do dado para que se torne um gold record.';
