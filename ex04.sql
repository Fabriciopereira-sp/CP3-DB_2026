-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 4 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PROCEDURE cp3_pr_detalhar_pedidos_periodo(
    p_data_ini IN DATE,
    p_data_fim IN DATE
) IS

    CURSOR c_pedidos IS
        SELECT pe.pedido_id,
               pe.data_pedido,
               pe.status,
               cl.nome AS nome_cliente
          FROM cp3_pedido  pe
          JOIN cp3_cliente cl ON cl.cliente_id = pe.cliente_id
         WHERE pe.data_pedido BETWEEN p_data_ini AND p_data_fim
         ORDER BY pe.data_pedido;


    CURSOR c_itens(p_pedido_id NUMBER) IS
        SELECT pr.nome AS nome_produto,
               it.quantidade,
               it.preco_unitario,
               it.desconto,
               (it.quantidade * it.preco_unitario) - it.desconto AS subtotal
          FROM cp3_pedido_item it
          JOIN cp3_produto     pr ON pr.produto_id = it.produto_id
         WHERE it.pedido_id = p_pedido_id;

    r_pedido c_pedidos%ROWTYPE;
    r_item   c_itens%ROWTYPE;
BEGIN

    IF p_data_fim < p_data_ini THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Data final nao pode ser anterior a data inicial.');
    END IF;


    OPEN c_pedidos;
    LOOP
        FETCH c_pedidos INTO r_pedido;
        EXIT WHEN c_pedidos%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            '-- Pedido ' || r_pedido.pedido_id ||
            ' | '        || TO_CHAR(r_pedido.data_pedido, 'DD/MM/YYYY') ||
            ' | '        || r_pedido.nome_cliente ||
            ' | '        || r_pedido.status
        );


        OPEN c_itens(r_pedido.pedido_id);
        LOOP
            FETCH c_itens INTO r_item;
            EXIT WHEN c_itens%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE(
                '   Produto: '    || r_item.nome_produto   ||
                ' | Qtd: '        || r_item.quantidade     ||
                ' | Preco: R$'    || r_item.preco_unitario ||
                ' | Desconto: R$' || r_item.desconto       ||
                ' | Subtotal: R$' || r_item.subtotal
            );
        END LOOP;
        CLOSE c_itens;

    END LOOP;
    CLOSE c_pedidos;
END cp3_pr_detalhar_pedidos_periodo;
/
