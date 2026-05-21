-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 5 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE FUNCTION cp3_fn_total_pedido(
    p_pedido_id IN NUMBER
) RETURN NUMBER IS
    v_total  NUMBER := 0;
    v_existe NUMBER;
BEGIN

    SELECT COUNT(*) INTO v_existe
      FROM cp3_pedido
     WHERE pedido_id = p_pedido_id;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Pedido ' || p_pedido_id || ' nao encontrado.');
    END IF;


    SELECT NVL(SUM((quantidade * preco_unitario) - desconto), 0)
      INTO v_total
      FROM cp3_pedido_item
     WHERE pedido_id = p_pedido_id;

    RETURN v_total;
END cp3_fn_total_pedido;
/
