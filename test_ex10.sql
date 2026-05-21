-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Testes — Exercicio 10
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === TESTE 1: Compra bem-sucedida — cliente 1, produto 3, qtd 1, endereco 1 ===
EXEC cp3_pr_processar_compra(1, 3, 1, 1);

PROMPT === TESTE 2: Produto inativo (produto 6) — deve lancar excecao e ROLLBACK ===
BEGIN
    cp3_pr_processar_compra(1, 6, 1, 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado (produto inativo): ' || SQLERRM);
END;
/

PROMPT === TESTE 3: Endereco de outro cliente — deve lancar excecao e ROLLBACK ===
BEGIN
    cp3_pr_processar_compra(1, 3, 1, 3);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado (endereco errado): ' || SQLERRM);
END;
/

PROMPT === TESTE 4: Estoque insuficiente — deve lancar excecao e ROLLBACK ===
BEGIN
    cp3_pr_processar_compra(2, 2, 500, 2);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado (estoque insuficiente): ' || SQLERRM);
END;
/
