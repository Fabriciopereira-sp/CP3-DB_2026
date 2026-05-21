-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Exercicio 8 
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PROCEDURE cp3_pr_finalizar_pedido(
    p_pedido_id IN NUMBER
) IS
    v_status cp3_pedido.status%TYPE;
    v_total  NUMBER;
    v_frete  NUMBER;
    v_existe NUMBER;


    CURSOR c_itens IS
        SELECT produto_id, quantidade
          FROM cp3_pedido_item
         WHERE pedido_id = p_pedido_id;

    r_item c_itens%ROWTYPE;
BEGIN

    SELECT COUNT(*) INTO v_existe
      FROM cp3_pedido
     WHERE pedido_id = p_pedido_id;

    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20020,
            'Pedido ' || p_pedido_id || ' nao encontrado.');
    END IF;


    SELECT status INTO v_status
      FROM cp3_pedido
     WHERE pedido_id = p_pedido_id;

    IF v_status != 'PENDENTE' THEN
        RAISE_APPLICATION_ERROR(-20021,
            'Pedido ' || p_pedido_id ||
            ' nao esta pendente. Status atual: ' || v_status);
    END IF;


    OPEN c_itens;
    LOOP
        FETCH c_itens INTO r_item;
        EXIT WHEN c_itens%NOTFOUND;

        cp3_pr_movimentar_estoque(
            r_item.produto_id,
            'S',
            r_item.quantidade,
            'Baixa automatica - pedido ' || p_pedido_id
        );
    END LOOP;
    CLOSE c_itens;


    v_total := cp3_fn_total_pedido(p_pedido_id);


    v_frete := cp3_fn_calcular_frete(p_pedido_id);


    UPDATE cp3_pedido
       SET valor_total = v_total,
           valor_frete = v_frete,
           status      = 'FINALIZADO'
     WHERE pedido_id = p_pedido_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Pedido ' || p_pedido_id ||
        ' finalizado. Total: R$ ' || v_total ||
        ' | Frete: R$ ' || v_frete
    );

EXCEPTION
    WHEN OTHERS THEN

        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20029,
            'Falha ao finalizar pedido ' || p_pedido_id ||
            ': ' || SQLERRM);
END cp3_pr_finalizar_pedido;
/
