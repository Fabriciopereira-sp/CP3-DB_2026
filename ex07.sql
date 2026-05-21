-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 7 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PROCEDURE cp3_pr_movimentar_estoque(
    p_produto_id IN NUMBER,
    p_tipo       IN CHAR,
    p_qtd        IN NUMBER,
    p_observacao IN VARCHAR2
) IS
    v_qtd_atual cp3_estoque.quantidade%TYPE;
    v_existe    NUMBER;
BEGIN

    SELECT COUNT(*) INTO v_existe
      FROM cp3_produto
     WHERE produto_id = p_produto_id;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Produto ' || p_produto_id || ' nao encontrado.');
    END IF;


    IF p_qtd <= 0 THEN
        RAISE_APPLICATION_ERROR(-20011,
            'Quantidade deve ser maior que zero.');
    END IF;


    IF p_tipo NOT IN ('E', 'S') THEN
        RAISE_APPLICATION_ERROR(-20012,
            'Tipo invalido. Use E para entrada ou S para saida.');
    END IF;

  
    SELECT quantidade INTO v_qtd_atual
      FROM cp3_estoque
     WHERE produto_id = p_produto_id;


    IF p_tipo = 'S' AND (v_qtd_atual - p_qtd) < 0 THEN
        RAISE_APPLICATION_ERROR(-20013,
            'Estoque insuficiente para o produto ' || p_produto_id ||
            '. Disponivel: ' || v_qtd_atual ||
            ', Solicitado: ' || p_qtd);
    END IF;


    IF p_tipo = 'E' THEN
        UPDATE cp3_estoque
           SET quantidade         = quantidade + p_qtd,
               data_atualizacao   = SYSDATE
         WHERE produto_id = p_produto_id;
    ELSE
        UPDATE cp3_estoque
           SET quantidade         = quantidade - p_qtd,
               data_atualizacao   = SYSDATE
         WHERE produto_id = p_produto_id;
    END IF;

    -- Registra a movimentacao no historico
    INSERT INTO cp3_movimento_estoque
        (movimento_id, produto_id, tipo, quantidade, data_movimento, observacao)
    VALUES
        (cp3_seq_movimento.NEXTVAL, p_produto_id, p_tipo, p_qtd, SYSDATE, p_observacao);

    -- COMMIT intencionalmente ausente: o chamador controla a transacao
END cp3_pr_movimentar_estoque;
/
