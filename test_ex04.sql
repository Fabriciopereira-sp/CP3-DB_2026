-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Testes — Exercicio 4
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === TESTE 1: Periodo amplo com todos os pedidos e itens ===
EXEC cp3_pr_detalhar_pedidos_periodo(SYSDATE - 120, SYSDATE);

PROMPT === TESTE 2: Data final anterior a inicial — deve lancar excecao ===
BEGIN
    cp3_pr_detalhar_pedidos_periodo(SYSDATE, SYSDATE - 5);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/
