-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Testes — Exercicio 5
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === TESTE 1: Total do pedido 1 (caminho feliz) ===
DECLARE
    v_total NUMBER;
BEGIN
    v_total := cp3_fn_total_pedido(1);
    DBMS_OUTPUT.PUT_LINE('Total pedido 1: R$ ' || v_total);
END;
/

PROMPT === TESTE 2: Total do pedido 3 (tem desconto) ===
DECLARE
    v_total NUMBER;
BEGIN
    v_total := cp3_fn_total_pedido(3);
    DBMS_OUTPUT.PUT_LINE('Total pedido 3 (com desconto): R$ ' || v_total);
END;
/

PROMPT === TESTE 3: Pedido inexistente (ID 999) — deve lancar excecao ===
BEGIN
    DBMS_OUTPUT.PUT_LINE(cp3_fn_total_pedido(999));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/
