-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 10 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PROCEDURE cp3_pr_processar_compra(
    p_cliente_id  IN NUMBER,
    p_produto_id  IN NUMBER,
    p_qtd         IN NUMBER,
    p_endereco_id IN NUMBER
) IS
    v_cliente_ativo cp3_cliente.ativo%TYPE;
    v_produto_ativo cp3_produto.ativo%TYPE;
    v_preco         cp3_produto.preco_unitario%TYPE;
    v_end_cliente   NUMBER;
    v_novo_pedido   NUMBER;
    v_novo_item     NUMBER;
    v_total         NUMBER;
    v_frete         NUMBER;
BEGIN

    BEGIN
        SELECT ativo INTO v_cliente_ativo
          FROM cp3_cliente
         WHERE cliente_id = p_cliente_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20030,
                'Cliente ' || p_cliente_id || ' nao encontrado.');
    END;

    IF v_cliente_ativo = 'N' THEN
        RAISE_APPLICATION_ERROR(-20031,
            'Cliente ' || p_cliente_id || ' esta inativo.');
    END IF;

    BEGIN
        SELECT ativo, preco_unitario
          INTO v_produto_ativo, v_preco
          FROM cp3_produto
         WHERE produto_id = p_produto_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20032,
                'Produto ' || p_produto_id || ' nao encontrado.');
    END;

    IF v_produto_ativo = 'N' THEN
        RAISE_APPLICATION_ERROR(-20033,
            'Produto ' || p_produto_id || ' esta inativo.');
    END IF;

    SELECT COUNT(*) INTO v_end_cliente
      FROM cp3_endereco
     WHERE endereco_id = p_endereco_id
       AND cliente_id  = p_cliente_id;

    IF v_end_cliente = 0 THEN
        RAISE_APPLICATION_ERROR(-20034,
            'Endereco ' || p_endereco_id ||
            ' nao pertence ao cliente ' || p_cliente_id || '.');
    END IF;

    IF p_qtd <= 0 THEN
        RAISE_APPLICATION_ERROR(-20035,
            'Quantidade deve ser maior que zero.');
    END IF;

    SELECT cp3_seq_pedido.NEXTVAL INTO v_novo_pedido FROM DUAL;

    INSERT INTO cp3_pedido
        (pedido_id, cliente_id, endereco_entrega_id, data_pedido, status, valor_total, valor_frete)
    VALUES
        (v_novo_pedido, p_cliente_id, p_endereco_id, SYSDATE, 'PENDENTE', 0, 0);

    SELECT cp3_seq_item.NEXTVAL INTO v_novo_item FROM DUAL;

    INSERT INTO cp3_pedido_item
        (item_id, pedido_id, produto_id, quantidade, preco_unitario, desconto)
    VALUES
        (v_novo_item, v_novo_pedido, p_produto_id, p_qtd, v_preco, 0);

    cp3_pr_finalizar_pedido(v_novo_pedido);


    v_total := cp3_fn_total_pedido(v_novo_pedido);
    v_frete := cp3_fn_calcular_frete(v_novo_pedido);

    DBMS_OUTPUT.PUT_LINE('=== Compra processada com sucesso ===');
    DBMS_OUTPUT.PUT_LINE('Pedido:        ' || v_novo_pedido);
    DBMS_OUTPUT.PUT_LINE('Valor total:   R$ ' || v_total);
    DBMS_OUTPUT.PUT_LINE('Frete:         R$ ' || v_frete);
    DBMS_OUTPUT.PUT_LINE('Total a pagar: R$ ' || (v_total + v_frete));

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20039,
            'Falha ao processar compra: ' || SQLERRM);
END cp3_pr_processar_compra;
/
