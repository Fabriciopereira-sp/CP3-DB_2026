-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 9 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PROCEDURE cp3_pr_classificar_clientes IS

    CURSOR c_clientes IS
        SELECT cliente_id, nome, email
          FROM cp3_cliente
         WHERE ativo = 'S';


    CURSOR c_pedidos_finalizados(p_cliente_id NUMBER) IS
        SELECT pedido_id
          FROM cp3_pedido
         WHERE cliente_id = p_cliente_id
           AND status     = 'FINALIZADO';

    r_cliente c_clientes%ROWTYPE;
    r_pedido  c_pedidos_finalizados%ROWTYPE;
    v_total   NUMBER;
    v_classif VARCHAR2(20);
BEGIN
    OPEN c_clientes;
    LOOP
        FETCH c_clientes INTO r_cliente;
        EXIT WHEN c_clientes%NOTFOUND;


        v_total := 0;


        OPEN c_pedidos_finalizados(r_cliente.cliente_id);
        LOOP
            FETCH c_pedidos_finalizados INTO r_pedido;
            EXIT WHEN c_pedidos_finalizados%NOTFOUND;


            v_total := v_total + cp3_fn_total_pedido(r_pedido.pedido_id);
        END LOOP;
        CLOSE c_pedidos_finalizados;

        IF v_total >= 5000 THEN
            v_classif := 'VIP';
        ELSIF v_total >= 1000 THEN
            v_classif := 'REGULAR';
        ELSIF v_total > 0 THEN
            v_classif := 'NOVO';
        ELSE
            v_classif := 'INATIVO';
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'Cliente: '     || r_cliente.nome  ||
            ' | Email: '    || r_cliente.email ||
            ' | Total: R$ ' || TO_CHAR(v_total, 'FM999G990D00') ||
            ' | Class: '    || v_classif
        );
    END LOOP;
    CLOSE c_clientes;
END cp3_pr_classificar_clientes;
/
