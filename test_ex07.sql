-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Testes — Exercicio 7
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === TESTE 1: Entrada de 10 unidades no produto 1 ===
BEGIN
    cp3_pr_movimentar_estoque(1, 'E', 10, 'Reposicao de estoque');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Entrada realizada com sucesso.');
END;
/

PROMPT === TESTE 2: Saida de 5 unidades do produto 3 ===
BEGIN
    cp3_pr_movimentar_estoque(3, 'S', 5, 'Venda avulsa');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Saida realizada com sucesso.');
END;
/

PROMPT === TESTE 3: Saldo insuficiente — deve lancar excecao ===
BEGIN
    cp3_pr_movimentar_estoque(2, 'S', 100, 'Teste saldo negativo');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/

PROMPT === TESTE 4: Tipo invalido — deve lancar excecao ===
BEGIN
    cp3_pr_movimentar_estoque(1, 'X', 5, 'Tipo errado');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/

PROMPT === TESTE 5: Produto inexistente — deve lancar excecao ===
BEGIN
    cp3_pr_movimentar_estoque(999, 'E', 5, 'Produto que nao existe');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/
