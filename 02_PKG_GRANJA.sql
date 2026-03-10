-- ============================================================
--  GRANJA AVÍCOLA - Stored Procedures PL/SQL
-- ============================================================

-- -------------------------------------------------------
-- PACKAGE SPEC
-- -------------------------------------------------------
CREATE OR REPLACE PACKAGE PKG_GRANJA AS

    -- Inserir Pesagem
    PROCEDURE SP_INSERIR_PESAGEM(
        p_id_lote         IN  TAB_PESAGEM.ID_LOTE_FK%TYPE,
        p_data_pesagem    IN  TAB_PESAGEM.DATA_PESAGEM%TYPE,
        p_peso_medio      IN  TAB_PESAGEM.PESO_MEDIO%TYPE,
        p_qtd_pesada      IN  TAB_PESAGEM.QUANTIDADE_PESADA%TYPE,
        p_id_pesagem      OUT TAB_PESAGEM.ID_PESAGEM%TYPE,
        p_erro            OUT VARCHAR2
    );

    -- Inserir Mortalidade
    PROCEDURE SP_INSERIR_MORTALIDADE(
        p_id_lote         IN  TAB_MORTALIDADE.ID_LOTE_FK%TYPE,
        p_data_mort       IN  TAB_MORTALIDADE.DATA_MORTALIDADE%TYPE,
        p_qtd_morta       IN  TAB_MORTALIDADE.QUANTIDADE_MORTA%TYPE,
        p_observacao      IN  TAB_MORTALIDADE.OBSERVACAO%TYPE,
        p_id_mortalidade  OUT TAB_MORTALIDADE.ID_MORTALIDADE%TYPE,
        p_mort_acumulada  OUT NUMBER,   -- percentual 0..100
        p_erro            OUT VARCHAR2
    );

END PKG_GRANJA;
/

-- -------------------------------------------------------
-- PACKAGE BODY
-- -------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY PKG_GRANJA AS

    -- ===================================================
    -- SP_INSERIR_PESAGEM
    -- Valida quantidade, insere registro e recalcula
    -- o PESO_MEDIO_GERAL do lote (média ponderada).
    -- ===================================================
    PROCEDURE SP_INSERIR_PESAGEM(
        p_id_lote         IN  TAB_PESAGEM.ID_LOTE_FK%TYPE,
        p_data_pesagem    IN  TAB_PESAGEM.DATA_PESAGEM%TYPE,
        p_peso_medio      IN  TAB_PESAGEM.PESO_MEDIO%TYPE,
        p_qtd_pesada      IN  TAB_PESAGEM.QUANTIDADE_PESADA%TYPE,
        p_id_pesagem      OUT TAB_PESAGEM.ID_PESAGEM%TYPE,
        p_erro            OUT VARCHAR2
    ) IS
        v_qtd_inicial   TAB_LOTE_AVES.QUANTIDADE_INICIAL%TYPE;
        v_novo_id       TAB_PESAGEM.ID_PESAGEM%TYPE;
        v_peso_pond     NUMBER;
        v_qtd_total     NUMBER;
    BEGIN
        p_erro := NULL;

        -- Valida se lote existe e obtém quantidade inicial
        BEGIN
            SELECT QUANTIDADE_INICIAL
              INTO v_qtd_inicial
              FROM TAB_LOTE_AVES
             WHERE ID_LOTE = p_id_lote;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_erro := 'Lote não encontrado: ' || p_id_lote;
                RETURN;
        END;

        -- Valida quantidade pesada vs quantidade inicial
        IF p_qtd_pesada > v_qtd_inicial THEN
            p_erro := 'Quantidade pesada (' || p_qtd_pesada ||
                      ') ultrapassa a quantidade inicial do lote (' ||
                      v_qtd_inicial || ').';
            RETURN;
        END IF;

        -- Gera ID e insere
        SELECT SEQ_PESAGEM.NEXTVAL INTO v_novo_id FROM DUAL;

        INSERT INTO TAB_PESAGEM (
            ID_PESAGEM, ID_LOTE_FK, DATA_PESAGEM, PESO_MEDIO, QUANTIDADE_PESADA
        ) VALUES (
            v_novo_id, p_id_lote, p_data_pesagem, p_peso_medio, p_qtd_pesada
        );

        -- Recalcula peso médio geral do lote (média ponderada de todos os registros)
        SELECT SUM(PESO_MEDIO * QUANTIDADE_PESADA),
               SUM(QUANTIDADE_PESADA)
          INTO v_peso_pond, v_qtd_total
          FROM TAB_PESAGEM
         WHERE ID_LOTE_FK = p_id_lote;

        IF v_qtd_total > 0 THEN
            UPDATE TAB_LOTE_AVES
               SET PESO_MEDIO_GERAL = ROUND(v_peso_pond / v_qtd_total, 2)
             WHERE ID_LOTE = p_id_lote;
        END IF;

        COMMIT;
        p_id_pesagem := v_novo_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_erro := 'Erro ao inserir pesagem: ' || SQLERRM;
    END SP_INSERIR_PESAGEM;


    -- ===================================================
    -- SP_INSERIR_MORTALIDADE
    -- Valida acumulado, insere e retorna % mortalidade.
    -- ===================================================
    PROCEDURE SP_INSERIR_MORTALIDADE(
        p_id_lote         IN  TAB_MORTALIDADE.ID_LOTE_FK%TYPE,
        p_data_mort       IN  TAB_MORTALIDADE.DATA_MORTALIDADE%TYPE,
        p_qtd_morta       IN  TAB_MORTALIDADE.QUANTIDADE_MORTA%TYPE,
        p_observacao      IN  TAB_MORTALIDADE.OBSERVACAO%TYPE,
        p_id_mortalidade  OUT TAB_MORTALIDADE.ID_MORTALIDADE%TYPE,
        p_mort_acumulada  OUT NUMBER,
        p_erro            OUT VARCHAR2
    ) IS
        v_qtd_inicial    TAB_LOTE_AVES.QUANTIDADE_INICIAL%TYPE;
        v_acumulado      NUMBER := 0;
        v_novo_id        TAB_MORTALIDADE.ID_MORTALIDADE%TYPE;
    BEGIN
        p_erro           := NULL;
        p_mort_acumulada := 0;

        -- Valida lote
        BEGIN
            SELECT QUANTIDADE_INICIAL
              INTO v_qtd_inicial
              FROM TAB_LOTE_AVES
             WHERE ID_LOTE = p_id_lote;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_erro := 'Lote não encontrado: ' || p_id_lote;
                RETURN;
        END;

        -- Soma mortalidades já registradas
        SELECT NVL(SUM(QUANTIDADE_MORTA), 0)
          INTO v_acumulado
          FROM TAB_MORTALIDADE
         WHERE ID_LOTE_FK = p_id_lote;

        -- Valida se nova mortalidade ultrapassa o limite
        IF (v_acumulado + p_qtd_morta) > v_qtd_inicial THEN
            p_erro := 'Mortalidade acumulada (' || (v_acumulado + p_qtd_morta) ||
                      ') ultrapassa a quantidade inicial do lote (' ||
                      v_qtd_inicial || ').';
            RETURN;
        END IF;

        -- Insere
        SELECT SEQ_MORTALIDADE.NEXTVAL INTO v_novo_id FROM DUAL;

        INSERT INTO TAB_MORTALIDADE (
            ID_MORTALIDADE, ID_LOTE_FK, DATA_MORTALIDADE, QUANTIDADE_MORTA, OBSERVACAO
        ) VALUES (
            v_novo_id, p_id_lote, p_data_mort, p_qtd_morta, p_observacao
        );

        COMMIT;

        -- Calcula percentual acumulado após inserção
        p_mort_acumulada := ROUND(((v_acumulado + p_qtd_morta) / v_qtd_inicial) * 100, 2);
        p_id_mortalidade := v_novo_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_erro := 'Erro ao inserir mortalidade: ' || SQLERRM;
    END SP_INSERIR_MORTALIDADE;

END PKG_GRANJA;
/
