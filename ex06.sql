-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 6 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE FUNCTION cp3_fn_calcular_frete(
    p_pedido_id IN NUMBER
) RETURN NUMBER IS
    v_uf         cp3_cep.uf%TYPE;
    v_peso_total NUMBER := 0;
    v_frete      NUMBER := 0;
    v_existe     NUMBER;
BEGIN

    SELECT COUNT(*) INTO v_existe
      FROM cp3_pedido
     WHERE pedido_id = p_pedido_id;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20004,
            'Pedido ' || p_pedido_id || ' nao encontrado para calculo de frete.');
    END IF;


    SELECT cep.uf
      INTO v_uf
      FROM cp3_pedido   pe
      JOIN cp3_endereco en  ON en.endereco_id = pe.endereco_entrega_id
      JOIN cp3_cep      cep ON cep.cep        = en.cep
     WHERE pe.pedido_id = p_pedido_id;


    SELECT NVL(SUM(pr.peso_kg * it.quantidade), 0)
      INTO v_peso_total
      FROM cp3_pedido_item it
      JOIN cp3_produto     pr ON pr.produto_id = it.produto_id
     WHERE it.pedido_id = p_pedido_id;


    IF v_uf IN ('SP', 'RJ') THEN
        v_frete := 15 + (2 * v_peso_total);
    ELSIF v_uf IN ('MG', 'ES') THEN
        v_frete := 20 + (3 * v_peso_total);
    ELSE
        v_frete := 30 + (5 * v_peso_total);
    END IF;

    RETURN ROUND(v_frete, 2);
END cp3_fn_calcular_frete;
/
