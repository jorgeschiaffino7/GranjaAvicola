-- ============================================================
--  GRANJA AVÍCOLA - DDL Oracle
--  Criação de Tabelas, Sequências e Constraints
-- ============================================================

-- Sequências
CREATE SEQUENCE SEQ_LOTE_AVES    START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_PESAGEM      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_MORTALIDADE  START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- -------------------------------------------------------
-- TAB_LOTE_AVES
-- -------------------------------------------------------
CREATE TABLE TAB_LOTE_AVES (
    ID_LOTE            NUMBER         CONSTRAINT PK_LOTE_AVES PRIMARY KEY,
    DESCRICAO          VARCHAR2(100)  NOT NULL,
    DATA_ENTRADA       DATE           NOT NULL,
    QUANTIDADE_INICIAL NUMBER         NOT NULL,
    PESO_MEDIO_GERAL   NUMBER(10,2)   DEFAULT 0,
    CONSTRAINT CHK_QTD_INICIAL CHECK (QUANTIDADE_INICIAL > 0)
);

-- -------------------------------------------------------
-- TAB_PESAGEM
-- -------------------------------------------------------
CREATE TABLE TAB_PESAGEM (
    ID_PESAGEM         NUMBER         CONSTRAINT PK_PESAGEM PRIMARY KEY,
    ID_LOTE_FK         NUMBER         NOT NULL,
    DATA_PESAGEM       DATE           NOT NULL,
    PESO_MEDIO         NUMBER(10,2)   NOT NULL,
    QUANTIDADE_PESADA  NUMBER         NOT NULL,
    CONSTRAINT FK_PESAGEM_LOTE  FOREIGN KEY (ID_LOTE_FK) REFERENCES TAB_LOTE_AVES(ID_LOTE),
    CONSTRAINT CHK_PESO_MEDIO   CHECK (PESO_MEDIO > 0),
    CONSTRAINT CHK_QTD_PESADA   CHECK (QUANTIDADE_PESADA > 0)
);

-- -------------------------------------------------------
-- TAB_MORTALIDADE
-- -------------------------------------------------------
CREATE TABLE TAB_MORTALIDADE (
    ID_MORTALIDADE     NUMBER         CONSTRAINT PK_MORTALIDADE PRIMARY KEY,
    ID_LOTE_FK         NUMBER         NOT NULL,
    DATA_MORTALIDADE   DATE           NOT NULL,
    QUANTIDADE_MORTA   NUMBER         NOT NULL,
    OBSERVACAO         VARCHAR2(255),
    CONSTRAINT FK_MORT_LOTE   FOREIGN KEY (ID_LOTE_FK) REFERENCES TAB_LOTE_AVES(ID_LOTE),
    CONSTRAINT CHK_QTD_MORTA  CHECK (QUANTIDADE_MORTA > 0)
);

-- Índices para FKs
CREATE INDEX IDX_PESAGEM_LOTE    ON TAB_PESAGEM(ID_LOTE_FK);
CREATE INDEX IDX_MORT_LOTE       ON TAB_MORTALIDADE(ID_LOTE_FK);

COMMIT;
