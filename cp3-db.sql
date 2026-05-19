-- Grupo:
-- Fabrício Henrique Pereira rm563237
-- Pedro Henrique de Oliveira rm562312
-- Miguel Henrique Oliveira Dias rm565492
-- Leonardo José Pereira rm563065

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET DEFINE OFF;

-- =====================================================================
-- EXERCICIO 1 - Bloco anonimo de verificacao de estoque
-- =====================================================================
DECLARE
    v_produto_id    cp3_produto.produto_id%TYPE    := 2;
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
      JOIN cp3_estoque e   ON e.produto_id   = p.produto_id
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

-- Teste ex01: produto com estoque ok
DECLARE
    v_produto_id    cp3_produto.produto_id%TYPE    := 1;
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
      JOIN cp3_estoque e   ON e.produto_id   = p.produto_id
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

-- Teste ex01: produto inexistente
DECLARE
    v_produto_id    cp3_produto.produto_id%TYPE    := 999;
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
      JOIN cp3_estoque e   ON e.produto_id   = p.produto_id
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

-- =====================================================================
-- EXERCICIO 2
-- =====================================================================
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
            RAISE_APPLICATION_ERROR(-20001, 'Categoria ' || p_categoria_id || ' nao existe.');
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

-- =====================================================================
-- EXERCICIO 3
-- =====================================================================
CREATE OR REPLACE PROCEDURE cp3_pr_listar_pedidos_periodo(
    p_data_ini IN DATE,
    p_data_fim IN DATE
) IS
    CURSOR c_pedidos IS
        SELECT pe.pedido_id, pe.data_pedido, pe.status, cl.nome AS nome_cliente
          FROM cp3_pedido pe
          JOIN cp3_cliente cl ON cl.cliente_id = pe.cliente_id
         WHERE pe.data_pedido BETWEEN p_data_ini AND p_data_fim
         ORDER BY pe.data_pedido;

    r_pedido c_pedidos%ROWTYPE;
BEGIN
    IF p_data_fim < p_data_ini THEN
        RAISE_APPLICATION_ERROR(-20002, 'Data final nao pode ser anterior a data inicial.');
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

-- =====================================================================
-- EXERCICIO 4
-- =====================================================================
CREATE OR REPLACE PROCEDURE cp3_pr_detalhar_pedidos_periodo(
    p_data_ini IN DATE,
    p_data_fim IN DATE
) IS
    CURSOR c_pedidos IS
        SELECT pe.pedido_id, pe.data_pedido, pe.status, cl.nome AS nome_cliente
          FROM cp3_pedido pe
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
          JOIN cp3_produto pr ON pr.produto_id = it.produto_id
         WHERE it.pedido_id = p_pedido_id;

    r_pedido c_pedidos%ROWTYPE;
    r_item   c_itens%ROWTYPE;
BEGIN
    IF p_data_fim < p_data_ini THEN
        RAISE_APPLICATION_ERROR(-20002, 'Data final nao pode ser anterior a data inicial.');
    END IF;

    OPEN c_pedidos;
    LOOP
        FETCH c_pedidos INTO r_pedido;
        EXIT WHEN c_pedidos%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            '-- Pedido ' || r_pedido.pedido_id ||
            ' | ' || TO_CHAR(r_pedido.data_pedido, 'DD/MM/YYYY') ||
            ' | ' || r_pedido.nome_cliente ||
            ' | ' || r_pedido.status
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

-- =====================================================================
-- EXERCICIO 5
-- =====================================================================
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
        RAISE_APPLICATION_ERROR(-20003, 'Pedido ' || p_pedido_id || ' nao encontrado.');
    END IF;

    SELECT NVL(SUM((quantidade * preco_unitario) - desconto), 0)
      INTO v_total
      FROM cp3_pedido_item
     WHERE pedido_id = p_pedido_id;

    RETURN v_total;
END cp3_fn_total_pedido;
/

-- =====================================================================
-- EXERCICIO 6
-- =====================================================================
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
        RAISE_APPLICATION_ERROR(-20004, 'Pedido ' || p_pedido_id || ' nao encontrado para calculo de frete.');
    END IF;

    SELECT cep.uf
      INTO v_uf
      FROM cp3_pedido pe
      JOIN cp3_endereco en ON en.endereco_id = pe.endereco_entrega_id
      JOIN cp3_cep cep     ON cep.cep        = en.cep
     WHERE pe.pedido_id = p_pedido_id;

    SELECT NVL(SUM(pr.peso_kg * it.quantidade), 0)
      INTO v_peso_total
      FROM cp3_pedido_item it
      JOIN cp3_produto pr ON pr.produto_id = it.produto_id
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

-- =====================================================================
-- EXERCICIO 7
-- =====================================================================
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
        RAISE_APPLICATION_ERROR(-20010, 'Produto ' || p_produto_id || ' nao encontrado.');
    END IF;

    IF p_qtd <= 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Quantidade deve ser maior que zero.');
    END IF;

    IF p_tipo NOT IN ('E', 'S') THEN
        RAISE_APPLICATION_ERROR(-20012, 'Tipo invalido. Use E para entrada ou S para saida.');
    END IF;

    SELECT quantidade INTO v_qtd_atual
      FROM cp3_estoque
     WHERE produto_id = p_produto_id;

    IF p_tipo = 'S' AND (v_qtd_atual - p_qtd) < 0 THEN
        RAISE_APPLICATION_ERROR(-20013,
            'Estoque insuficiente para o produto ' || p_produto_id ||
            '. Disponivel: ' || v_qtd_atual || ', Solicitado: ' || p_qtd);
    END IF;

    IF p_tipo = 'E' THEN
        UPDATE cp3_estoque
           SET quantidade = quantidade + p_qtd,
               data_atualizacao = SYSDATE
         WHERE produto_id = p_produto_id;
    ELSE
        UPDATE cp3_estoque
           SET quantidade = quantidade - p_qtd,
               data_atualizacao = SYSDATE
         WHERE produto_id = p_produto_id;
    END IF;

    INSERT INTO cp3_movimento_estoque
        (movimento_id, produto_id, tipo, quantidade, data_movimento, observacao)
    VALUES
        (cp3_seq_movimento.NEXTVAL, p_produto_id, p_tipo, p_qtd, SYSDATE, p_observacao);

    COMMIT;
END cp3_pr_movimentar_estoque;
/

-- =====================================================================
-- EXERCICIO 8
-- =====================================================================
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
        RAISE_APPLICATION_ERROR(-20020, 'Pedido ' || p_pedido_id || ' nao encontrado.');
    END IF;

    SELECT status INTO v_status
      FROM cp3_pedido
     WHERE pedido_id = p_pedido_id;

    IF v_status != 'PENDENTE' THEN
        RAISE_APPLICATION_ERROR(-20021,
            'Pedido ' || p_pedido_id || ' nao esta pendente. Status atual: ' || v_status);
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
            'Falha ao finalizar pedido ' || p_pedido_id || ': ' || SQLERRM);
END cp3_pr_finalizar_pedido;
/

-- =====================================================================
-- EXERCICIO 9
-- =====================================================================
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

-- =====================================================================
-- EXERCICIO 10
-- =====================================================================
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
            RAISE_APPLICATION_ERROR(-20030, 'Cliente ' || p_cliente_id || ' nao encontrado.');
    END;

    IF v_cliente_ativo = 'N' THEN
        RAISE_APPLICATION_ERROR(-20031, 'Cliente ' || p_cliente_id || ' esta inativo.');
    END IF;

    BEGIN
        SELECT ativo, preco_unitario INTO v_produto_ativo, v_preco
          FROM cp3_produto
         WHERE produto_id = p_produto_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20032, 'Produto ' || p_produto_id || ' nao encontrado.');
    END;

    IF v_produto_ativo = 'N' THEN
        RAISE_APPLICATION_ERROR(-20033, 'Produto ' || p_produto_id || ' esta inativo.');
    END IF;

    SELECT COUNT(*) INTO v_end_cliente
      FROM cp3_endereco
     WHERE endereco_id = p_endereco_id
       AND cliente_id  = p_cliente_id;

    IF v_end_cliente = 0 THEN
        RAISE_APPLICATION_ERROR(-20034,
            'Endereco ' || p_endereco_id || ' nao pertence ao cliente ' || p_cliente_id || '.');
    END IF;

    IF p_qtd <= 0 THEN
        RAISE_APPLICATION_ERROR(-20035, 'Quantidade deve ser maior que zero.');
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

    cp3_pr_movimentar_estoque(
        p_produto_id, 'S', p_qtd,
        'Venda via pedido ' || v_novo_pedido
    );

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
        RAISE_APPLICATION_ERROR(-20039, 'Falha ao processar compra: ' || SQLERRM);
END cp3_pr_processar_compra;
/

-- =====================================================================
-- TESTES EX02
-- =====================================================================
EXEC cp3_pr_listar_produtos_categoria(1);
EXEC cp3_pr_listar_produtos_categoria(2);

BEGIN
    cp3_pr_listar_produtos_categoria(999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex02: ' || SQLERRM);
END;
/

-- =====================================================================
-- TESTES EX03
-- =====================================================================
EXEC cp3_pr_listar_pedidos_periodo(SYSDATE - 120, SYSDATE);

BEGIN
    cp3_pr_listar_pedidos_periodo(SYSDATE, SYSDATE - 10);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex03: ' || SQLERRM);
END;
/

-- =====================================================================
-- TESTES EX04
-- =====================================================================
EXEC cp3_pr_detalhar_pedidos_periodo(SYSDATE - 120, SYSDATE);

BEGIN
    cp3_pr_detalhar_pedidos_periodo(SYSDATE, SYSDATE - 5);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex04: ' || SQLERRM);
END;
/

-- =====================================================================
-- TESTES EX05
-- =====================================================================
DECLARE
    v_total NUMBER;
BEGIN
    v_total := cp3_fn_total_pedido(1);
    DBMS_OUTPUT.PUT_LINE('Total pedido 1: R$ ' || v_total);
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(cp3_fn_total_pedido(999));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex05: ' || SQLERRM);
END;
/

-- =====================================================================
-- TESTES EX06
-- =====================================================================
DECLARE
    v_frete NUMBER;
BEGIN
    v_frete := cp3_fn_calcular_frete(1);
    DBMS_OUTPUT.PUT_LINE('Frete pedido 1 (SP): R$ ' || v_frete);
END;
/

DECLARE
    v_frete NUMBER;
BEGIN
    v_frete := cp3_fn_calcular_frete(5);
    DBMS_OUTPUT.PUT_LINE('Frete pedido 5 (MG): R$ ' || v_frete);
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE(cp3_fn_calcular_frete(999));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex06: ' || SQLERRM);
END;
/

-- =====================================================================
-- TESTES EX07
-- =====================================================================
EXEC cp3_pr_movimentar_estoque(1, 'E', 10, 'Reposicao de estoque');
EXEC cp3_pr_movimentar_estoque(3, 'S', 5, 'Venda avulsa');

BEGIN
    cp3_pr_movimentar_estoque(2, 'S', 100, 'Teste saldo negativo');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex07: ' || SQLERRM);
END;
/

BEGIN
    cp3_pr_movimentar_estoque(1, 'X', 5, 'Tipo errado');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex07: ' || SQLERRM);
END;
/

-- =====================================================================
-- TESTES EX08
-- =====================================================================
EXEC cp3_pr_finalizar_pedido(6);

BEGIN
    cp3_pr_finalizar_pedido(1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex08: ' || SQLERRM);
END;
/

BEGIN
    cp3_pr_finalizar_pedido(999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex08: ' || SQLERRM);
END;
/

-- =====================================================================
-- TESTES EX09
-- =====================================================================
EXEC cp3_pr_classificar_clientes;

-- =====================================================================
-- TESTES EX10
-- =====================================================================
EXEC cp3_pr_processar_compra(1, 3, 1, 1);

BEGIN
    cp3_pr_processar_compra(1, 6, 1, 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex10 produto inativo: ' || SQLERRM);
END;
/

BEGIN
    cp3_pr_processar_compra(1, 3, 1, 3);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex10 endereco errado: ' || SQLERRM);
END;
/

BEGIN
    cp3_pr_processar_compra(2, 2, 500, 2);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado ex10 estoque insuficiente: ' || SQLERRM);
END;
/