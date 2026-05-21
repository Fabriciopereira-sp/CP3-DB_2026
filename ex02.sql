-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 2 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PROCEDURE cp3_pr_listar_produtos_categoria(
    p_categoria_id IN NUMBER
) IS

    v_nome_cat VARCHAR2(60);

    v_total    NUMBER := 0;


    CURSOR c_produtos IS
        SELECT p.nome, p.preco_unitario, e.quantidade
          FROM cp3_produto p
          JOIN cp3_estoque e ON e.produto_id = p.produto_id
         WHERE p.categoria_id = p_categoria_id
           AND p.ativo = 'S';
BEGIN

    BEGIN
        SELECT nome INTO v_nome_cat
          FROM cp3_categoria
         WHERE categoria_id = p_categoria_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Categoria ' || p_categoria_id || ' nao existe.');
    END;

    DBMS_OUTPUT.PUT_LINE('=== Produtos da categoria: ' || v_nome_cat || ' ===');


    FOR r IN c_produtos LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Produto: '    || r.nome           ||
            ' | Preco: R$' || r.preco_unitario ||
            ' | Estoque: ' || r.quantidade
        );
        v_total := v_total + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total de produtos listados: ' || v_total);
END cp3_pr_listar_produtos_categoria;
/
