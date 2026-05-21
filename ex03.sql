-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 3 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PROCEDURE cp3_pr_listar_pedidos_periodo(
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


    r_pedido c_pedidos%ROWTYPE;
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
            'Pedido: '     || r_pedido.pedido_id                          ||
            ' | Data: '    || TO_CHAR(r_pedido.data_pedido, 'DD/MM/YYYY') ||
            ' | Cliente: ' || r_pedido.nome_cliente                       ||
            ' | Status: '  || r_pedido.status
        );
    END LOOP;
    CLOSE c_pedidos;
END cp3_pr_listar_pedidos_periodo;
/
