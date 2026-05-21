-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Testes — Exercicio 6
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === TESTE 1: Pedido 1 — entrega em SP (frete R$15 + R$2/kg) ===
DECLARE
    v_frete NUMBER;
BEGIN
    v_frete := cp3_fn_calcular_frete(1);
    DBMS_OUTPUT.PUT_LINE('Frete pedido 1 (SP): R$ ' || v_frete);
END;
/

PROMPT === TESTE 2: Pedido 5 — entrega em MG (frete R$20 + R$3/kg) ===
DECLARE
    v_frete NUMBER;
BEGIN
    v_frete := cp3_fn_calcular_frete(5);
    DBMS_OUTPUT.PUT_LINE('Frete pedido 5 (MG): R$ ' || v_frete);
END;
/

PROMPT === TESTE 3: Pedido inexistente (ID 999) — deve lancar excecao ===
BEGIN
    DBMS_OUTPUT.PUT_LINE(cp3_fn_calcular_frete(999));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/
