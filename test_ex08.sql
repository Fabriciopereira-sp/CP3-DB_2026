-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Testes — Exercicio 8
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === TESTE 1: Finalizar pedido 6 (PENDENTE) — caminho feliz ===
EXEC cp3_pr_finalizar_pedido(6);

PROMPT === TESTE 2: Tentar finalizar pedido 1 (ja FINALIZADO) — deve lancar excecao ===
BEGIN
    cp3_pr_finalizar_pedido(1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/

PROMPT === TESTE 3: Pedido inexistente (ID 999) — deve lancar excecao ===
BEGIN
    cp3_pr_finalizar_pedido(999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/
