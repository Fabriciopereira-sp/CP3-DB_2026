-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 1 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET DEFINE ON;

DECLARE
    v_produto_id    cp3_produto.produto_id%TYPE    := &produto_id;
    v_nome_produto  cp3_produto.nome%TYPE;
    v_nome_cat      cp3_categoria.nome%TYPE;
    v_qtd_atual     cp3_estoque.quantidade%TYPE;
    v_qtd_minima    cp3_estoque.qtd_minima%TYPE;
    v_situacao      VARCHAR2(30);
BEGIN
    SELECT p.nome, c.nome, e.quantidade, e.qtd_minima
      INTO v_nome_produto, v_nome_cat, v_qtd_atual, v_qtd_minima
      FROM cp3_produto p
      JOIN cp3_categoria c ON c.categoria_id = p.categoria_id
      JOIN cp3_estoque   e ON e.produto_id   = p.produto_id
     WHERE p.produto_id = v_produto_id;

    IF v_qtd_atual < v_qtd_minima THEN
        v_situacao := 'ALERTA: REPOR ESTOQUE';
    ELSE
        v_situacao := 'ESTOQUE OK';
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'Produto: '       || v_nome_produto ||
        ' | Categoria: '  || v_nome_cat     ||
        ' | Qtd atual: '  || v_qtd_atual    ||
        ' | Qtd minima: ' || v_qtd_minima   ||
        ' | '             || v_situacao
    );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Produto com ID ' || v_produto_id || ' nao encontrado.');
END;
/
