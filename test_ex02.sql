-- =====================================================================
-- Grupo:
--   Fabrício Henrique Pereira  RM563237
--   Pedro Henrique de Oliveira RM562312
--   Miguel Henrique Oliveira Dias RM565492
--   Leonardo José Pereira      RM563065
-- Testes — Exercicio 2
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT === TESTE 1: Categoria Eletronicos (ID 1) — caminho feliz ===
EXEC cp3_pr_listar_produtos_categoria(1);

PROMPT === TESTE 2: Categoria Livros (ID 2) — caminho feliz ===
EXEC cp3_pr_listar_produtos_categoria(2);

PROMPT === TESTE 3: Categoria inexistente (ID 999) — deve lancar excecao ===
BEGIN
    cp3_pr_listar_produtos_categoria(999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro esperado: ' || SQLERRM);
END;
/
