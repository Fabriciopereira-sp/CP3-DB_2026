-- =====================================================================
-- ShopFast — Schema de apoio à prova de PL/SQL
-- =====================================================================
-- Este script cria todo o schema (DDL) e popula dados de teste (DML).
-- Modelo em 3ª Forma Normal (3NF). Todas as tabelas, sequências e
-- índices têm o prefixo cp3_.
-- Para reexecução, o bloco a seguir remove objetos pré-existentes.
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET DEFINE OFF;

-- ---------------------------------------------------------------------
-- 0. Limpeza para reexecução segura
-- ---------------------------------------------------------------------
DECLARE
    PROCEDURE drop_obj(p_type IN VARCHAR2, p_name IN VARCHAR2) IS
        v_sql VARCHAR2(200);
    BEGIN
        v_sql := 'DROP ' || p_type || ' ' || p_name;
        IF p_type = 'TABLE' THEN
            v_sql := v_sql || ' CASCADE CONSTRAINTS';
        END IF;
        EXECUTE IMMEDIATE v_sql;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE NOT IN (-942, -2289, -4043) THEN
                RAISE;
            END IF;
    END drop_obj;
BEGIN
    -- Tabelas (ordem inversa às dependências)
    drop_obj('TABLE', 'cp3_pagamento');
    drop_obj('TABLE', 'cp3_pedido_item');
    drop_obj('TABLE', 'cp3_pedido');
    drop_obj('TABLE', 'cp3_movimento_estoque');
    drop_obj('TABLE', 'cp3_estoque');
    drop_obj('TABLE', 'cp3_produto_fornecedor');
    drop_obj('TABLE', 'cp3_produto');
    drop_obj('TABLE', 'cp3_fornecedor');
    drop_obj('TABLE', 'cp3_endereco');
    drop_obj('TABLE', 'cp3_cep');
    drop_obj('TABLE', 'cp3_cliente');
    drop_obj('TABLE', 'cp3_categoria');
    -- Sequências
    drop_obj('SEQUENCE', 'cp3_seq_categoria');
    drop_obj('SEQUENCE', 'cp3_seq_cliente');
    drop_obj('SEQUENCE', 'cp3_seq_endereco');
    drop_obj('SEQUENCE', 'cp3_seq_fornecedor');
    drop_obj('SEQUENCE', 'cp3_seq_produto');
    drop_obj('SEQUENCE', 'cp3_seq_movimento');
    drop_obj('SEQUENCE', 'cp3_seq_pedido');
    drop_obj('SEQUENCE', 'cp3_seq_item');
    drop_obj('SEQUENCE', 'cp3_seq_pagamento');
END;
/

-- ---------------------------------------------------------------------
-- 1. Sequências
-- ---------------------------------------------------------------------
CREATE SEQUENCE cp3_seq_categoria   START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cp3_seq_cliente     START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cp3_seq_endereco    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cp3_seq_fornecedor  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cp3_seq_produto     START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cp3_seq_movimento   START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cp3_seq_pedido      START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cp3_seq_item        START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE cp3_seq_pagamento   START WITH 1 INCREMENT BY 1 NOCACHE;

-- ---------------------------------------------------------------------
-- 2. Tabelas (em ordem de dependência)
-- ---------------------------------------------------------------------

-- 2.1 Categorias do catálogo
CREATE TABLE cp3_categoria (
    categoria_id  NUMBER         CONSTRAINT pk_cp3_categoria PRIMARY KEY,
    nome          VARCHAR2(60)   NOT NULL,
    descricao     VARCHAR2(200)
);

-- 2.2 Clientes
CREATE TABLE cp3_cliente (
    cliente_id     NUMBER         CONSTRAINT pk_cp3_cliente PRIMARY KEY,
    nome           VARCHAR2(120)  NOT NULL,
    email          VARCHAR2(120)  NOT NULL CONSTRAINT uk_cp3_cli_email UNIQUE,
    cpf            VARCHAR2(14)   NOT NULL CONSTRAINT uk_cp3_cli_cpf UNIQUE,
    telefone       VARCHAR2(20),
    data_cadastro  DATE           DEFAULT SYSDATE NOT NULL,
    ativo          CHAR(1)        DEFAULT 'S' NOT NULL,
    CONSTRAINT ck_cp3_cli_ativo CHECK (ativo IN ('S','N'))
);

-- 2.3 CEP — extraída do endereço para garantir 3NF
-- (cep determina cidade e uf; bairro permanece em endereço pois pode
--  variar por logradouro dentro de um mesmo cep em áreas urbanas).
CREATE TABLE cp3_cep (
    cep      VARCHAR2(10)  CONSTRAINT pk_cp3_cep PRIMARY KEY,
    cidade   VARCHAR2(60)  NOT NULL,
    uf       CHAR(2)       NOT NULL,
    CONSTRAINT ck_cp3_cep_uf CHECK (REGEXP_LIKE(uf, '^[A-Z]{2}$'))
);

-- 2.4 Endereços (1:N com cliente; N:1 com cep)
CREATE TABLE cp3_endereco (
    endereco_id   NUMBER         CONSTRAINT pk_cp3_endereco PRIMARY KEY,
    cliente_id    NUMBER         NOT NULL,
    cep           VARCHAR2(10)   NOT NULL,
    logradouro    VARCHAR2(120)  NOT NULL,
    numero        VARCHAR2(10),
    complemento   VARCHAR2(60),
    bairro        VARCHAR2(60),
    principal     CHAR(1)        DEFAULT 'N' NOT NULL,
    CONSTRAINT ck_cp3_end_principal CHECK (principal IN ('S','N')),
    CONSTRAINT fk_cp3_end_cliente FOREIGN KEY (cliente_id)
        REFERENCES cp3_cliente(cliente_id),
    CONSTRAINT fk_cp3_end_cep FOREIGN KEY (cep)
        REFERENCES cp3_cep(cep)
);

-- 2.5 Fornecedores
CREATE TABLE cp3_fornecedor (
    fornecedor_id  NUMBER         CONSTRAINT pk_cp3_fornecedor PRIMARY KEY,
    razao_social   VARCHAR2(150)  NOT NULL,
    cnpj           VARCHAR2(18)   NOT NULL CONSTRAINT uk_cp3_forn_cnpj UNIQUE,
    telefone       VARCHAR2(20)
);

-- 2.6 Produtos
CREATE TABLE cp3_produto (
    produto_id      NUMBER         CONSTRAINT pk_cp3_produto PRIMARY KEY,
    categoria_id    NUMBER         NOT NULL,
    nome            VARCHAR2(150)  NOT NULL,
    descricao       VARCHAR2(500),
    preco_unitario  NUMBER(10,2)   NOT NULL,
    peso_kg         NUMBER(8,3)    DEFAULT 0 NOT NULL,
    ativo           CHAR(1)        DEFAULT 'S' NOT NULL,
    CONSTRAINT ck_cp3_prod_preco CHECK (preco_unitario >= 0),
    CONSTRAINT ck_cp3_prod_peso  CHECK (peso_kg >= 0),
    CONSTRAINT ck_cp3_prod_ativo CHECK (ativo IN ('S','N')),
    CONSTRAINT fk_cp3_prod_cat FOREIGN KEY (categoria_id)
        REFERENCES cp3_categoria(categoria_id)
);

-- 2.7 Produto x Fornecedor (relação N:N com atributos)
CREATE TABLE cp3_produto_fornecedor (
    produto_id          NUMBER        NOT NULL,
    fornecedor_id       NUMBER        NOT NULL,
    preco_compra        NUMBER(10,2)  NOT NULL,
    prazo_entrega_dias  NUMBER(3)     NOT NULL,
    CONSTRAINT pk_cp3_prod_forn PRIMARY KEY (produto_id, fornecedor_id),
    CONSTRAINT ck_cp3_pf_preco CHECK (preco_compra >= 0),
    CONSTRAINT ck_cp3_pf_prazo CHECK (prazo_entrega_dias > 0),
    CONSTRAINT fk_cp3_pf_prod  FOREIGN KEY (produto_id)
        REFERENCES cp3_produto(produto_id),
    CONSTRAINT fk_cp3_pf_forn  FOREIGN KEY (fornecedor_id)
        REFERENCES cp3_fornecedor(fornecedor_id)
);

-- 2.8 Estoque (1:1 com produto)
CREATE TABLE cp3_estoque (
    produto_id          NUMBER         CONSTRAINT pk_cp3_estoque PRIMARY KEY,
    quantidade          NUMBER(10)     DEFAULT 0 NOT NULL,
    qtd_minima          NUMBER(10)     DEFAULT 0 NOT NULL,
    data_atualizacao    DATE           DEFAULT SYSDATE NOT NULL,
    CONSTRAINT ck_cp3_est_qtd CHECK (quantidade >= 0),
    CONSTRAINT ck_cp3_est_min CHECK (qtd_minima >= 0),
    CONSTRAINT fk_cp3_est_prod FOREIGN KEY (produto_id)
        REFERENCES cp3_produto(produto_id)
);

-- 2.9 Movimentações de estoque
CREATE TABLE cp3_movimento_estoque (
    movimento_id     NUMBER       CONSTRAINT pk_cp3_movimento PRIMARY KEY,
    produto_id       NUMBER       NOT NULL,
    tipo             CHAR(1)      NOT NULL,
    quantidade       NUMBER(10)   NOT NULL,
    data_movimento   DATE         DEFAULT SYSDATE NOT NULL,
    observacao       VARCHAR2(200),
    CONSTRAINT ck_cp3_mov_tipo CHECK (tipo IN ('E','S')),
    CONSTRAINT ck_cp3_mov_qtd  CHECK (quantidade > 0),
    CONSTRAINT fk_cp3_mov_prod FOREIGN KEY (produto_id)
        REFERENCES cp3_produto(produto_id)
);

-- 2.10 Pedidos
-- valor_total e valor_frete sao snapshots (congelados na finalizacao).
-- Nao constituem dependencia transitiva intra-tabela e, portanto, nao
-- violam 3NF. Permanecem aqui para suportar auditoria e os exercicios.
CREATE TABLE cp3_pedido (
    pedido_id            NUMBER         CONSTRAINT pk_cp3_pedido PRIMARY KEY,
    cliente_id           NUMBER         NOT NULL,
    endereco_entrega_id  NUMBER         NOT NULL,
    data_pedido          DATE           DEFAULT SYSDATE NOT NULL,
    status               VARCHAR2(20)   DEFAULT 'PENDENTE' NOT NULL,
    valor_total          NUMBER(12,2)   DEFAULT 0 NOT NULL,
    valor_frete          NUMBER(10,2)   DEFAULT 0 NOT NULL,
    CONSTRAINT ck_cp3_ped_status
        CHECK (status IN ('PENDENTE','FINALIZADO','CANCELADO')),
    CONSTRAINT ck_cp3_ped_total CHECK (valor_total >= 0),
    CONSTRAINT ck_cp3_ped_frete CHECK (valor_frete >= 0),
    CONSTRAINT fk_cp3_ped_cli FOREIGN KEY (cliente_id)
        REFERENCES cp3_cliente(cliente_id),
    CONSTRAINT fk_cp3_ped_end FOREIGN KEY (endereco_entrega_id)
        REFERENCES cp3_endereco(endereco_id)
);

-- 2.11 Itens do pedido
-- preco_unitario aqui e o preco congelado no momento da venda.
-- Depende de item_id (nao de produto_id), portanto nao viola 3NF.
CREATE TABLE cp3_pedido_item (
    item_id         NUMBER         CONSTRAINT pk_cp3_pedido_item PRIMARY KEY,
    pedido_id       NUMBER         NOT NULL,
    produto_id      NUMBER         NOT NULL,
    quantidade      NUMBER(8)      NOT NULL,
    preco_unitario  NUMBER(10,2)   NOT NULL,
    desconto        NUMBER(10,2)   DEFAULT 0 NOT NULL,
    CONSTRAINT ck_cp3_item_qtd      CHECK (quantidade > 0),
    CONSTRAINT ck_cp3_item_preco    CHECK (preco_unitario >= 0),
    CONSTRAINT ck_cp3_item_desconto CHECK (desconto >= 0),
    CONSTRAINT fk_cp3_it_ped  FOREIGN KEY (pedido_id)
        REFERENCES cp3_pedido(pedido_id),
    CONSTRAINT fk_cp3_it_prod FOREIGN KEY (produto_id)
        REFERENCES cp3_produto(produto_id)
);

-- 2.12 Pagamentos
CREATE TABLE cp3_pagamento (
    pagamento_id    NUMBER         CONSTRAINT pk_cp3_pagamento PRIMARY KEY,
    pedido_id       NUMBER         NOT NULL,
    metodo          VARCHAR2(20)   NOT NULL,
    valor           NUMBER(12,2)   NOT NULL,
    status          VARCHAR2(20)   DEFAULT 'AGUARDANDO' NOT NULL,
    data_pagamento  DATE,
    parcelas        NUMBER(2)      DEFAULT 1 NOT NULL,
    CONSTRAINT ck_cp3_pag_metodo CHECK (metodo IN ('PIX','BOLETO','CARTAO')),
    CONSTRAINT ck_cp3_pag_status CHECK (status IN ('AGUARDANDO','PAGO','CANCELADO','ESTORNADO')),
    CONSTRAINT ck_cp3_pag_valor  CHECK (valor >= 0),
    CONSTRAINT ck_cp3_pag_parc   CHECK (parcelas BETWEEN 1 AND 24),
    CONSTRAINT fk_cp3_pag_ped FOREIGN KEY (pedido_id)
        REFERENCES cp3_pedido(pedido_id)
);

-- ---------------------------------------------------------------------
-- 3. Índices auxiliares (FKs e colunas de busca frequente)
-- ---------------------------------------------------------------------
CREATE INDEX ix_cp3_end_cliente   ON cp3_endereco(cliente_id);
CREATE INDEX ix_cp3_end_cep       ON cp3_endereco(cep);
CREATE INDEX ix_cp3_prod_cat      ON cp3_produto(categoria_id);
CREATE INDEX ix_cp3_pf_forn       ON cp3_produto_fornecedor(fornecedor_id);
CREATE INDEX ix_cp3_mov_prod      ON cp3_movimento_estoque(produto_id);
CREATE INDEX ix_cp3_ped_cliente   ON cp3_pedido(cliente_id);
CREATE INDEX ix_cp3_ped_endereco  ON cp3_pedido(endereco_entrega_id);
CREATE INDEX ix_cp3_ped_status    ON cp3_pedido(status);
CREATE INDEX ix_cp3_item_pedido   ON cp3_pedido_item(pedido_id);
CREATE INDEX ix_cp3_item_produto  ON cp3_pedido_item(produto_id);
CREATE INDEX ix_cp3_pag_pedido    ON cp3_pagamento(pedido_id);

-- =====================================================================
-- 4. Carga de dados de teste (DML)
-- =====================================================================

-- 4.1 Categorias
INSERT INTO cp3_categoria VALUES (cp3_seq_categoria.NEXTVAL, 'Eletronicos', 'TVs, celulares e acessorios');
INSERT INTO cp3_categoria VALUES (cp3_seq_categoria.NEXTVAL, 'Livros',      'Livros fisicos e didaticos');
INSERT INTO cp3_categoria VALUES (cp3_seq_categoria.NEXTVAL, 'Alimentos',   'Alimentos nao pereciveis');
INSERT INTO cp3_categoria VALUES (cp3_seq_categoria.NEXTVAL, 'Vestuario',   'Roupas e acessorios');

-- 4.2 Clientes
INSERT INTO cp3_cliente VALUES (cp3_seq_cliente.NEXTVAL, 'Ana Souza',   'ana@mail.com',   '111.111.111-11', '11999990001', SYSDATE-400, 'S');
INSERT INTO cp3_cliente VALUES (cp3_seq_cliente.NEXTVAL, 'Bruno Lima',  'bruno@mail.com', '222.222.222-22', '11999990002', SYSDATE-300, 'S');
INSERT INTO cp3_cliente VALUES (cp3_seq_cliente.NEXTVAL, 'Carla Reis',  'carla@mail.com', '333.333.333-33', '11999990003', SYSDATE-200, 'S');
INSERT INTO cp3_cliente VALUES (cp3_seq_cliente.NEXTVAL, 'Diego Alves', 'diego@mail.com', '444.444.444-44', '21999990004', SYSDATE-100, 'S');
INSERT INTO cp3_cliente VALUES (cp3_seq_cliente.NEXTVAL, 'Eva Martins', 'eva@mail.com',   '555.555.555-55', '41999990005', SYSDATE-50,  'S');

-- 4.3 CEPs
INSERT INTO cp3_cep VALUES ('01000-000', 'Sao Paulo',      'SP');
INSERT INTO cp3_cep VALUES ('01310-000', 'Sao Paulo',      'SP');
INSERT INTO cp3_cep VALUES ('22000-000', 'Rio de Janeiro', 'RJ');
INSERT INTO cp3_cep VALUES ('30000-000', 'Belo Horizonte', 'MG');
INSERT INTO cp3_cep VALUES ('80000-000', 'Curitiba',       'PR');

-- 4.4 Endereços
INSERT INTO cp3_endereco VALUES (cp3_seq_endereco.NEXTVAL, 1, '01000-000', 'Rua A', '100', NULL,      'Centro',      'S');
INSERT INTO cp3_endereco VALUES (cp3_seq_endereco.NEXTVAL, 2, '01310-000', 'Rua B', '200', 'Apto 12', 'Bela Vista',  'S');
INSERT INTO cp3_endereco VALUES (cp3_seq_endereco.NEXTVAL, 3, '22000-000', 'Rua C', '300', NULL,      'Copacabana',  'S');
INSERT INTO cp3_endereco VALUES (cp3_seq_endereco.NEXTVAL, 4, '30000-000', 'Rua D', '400', NULL,      'Savassi',     'S');
INSERT INTO cp3_endereco VALUES (cp3_seq_endereco.NEXTVAL, 5, '80000-000', 'Rua E', '500', NULL,      'Batel',       'S');

-- 4.5 Fornecedores
INSERT INTO cp3_fornecedor VALUES (cp3_seq_fornecedor.NEXTVAL, 'Tech Distribuidora SA', '11.111.111/0001-11', '1133330001');
INSERT INTO cp3_fornecedor VALUES (cp3_seq_fornecedor.NEXTVAL, 'Editora Saber Ltda',    '22.222.222/0001-22', '1133330002');
INSERT INTO cp3_fornecedor VALUES (cp3_seq_fornecedor.NEXTVAL, 'Alimentos Bom Sabor',   '33.333.333/0001-33', '1133330003');

-- 4.6 Produtos
INSERT INTO cp3_produto VALUES (cp3_seq_produto.NEXTVAL, 1, 'Smart TV 50',      'TV 4K 50 polegadas',  2999.00, 12.500, 'S');
INSERT INTO cp3_produto VALUES (cp3_seq_produto.NEXTVAL, 1, 'Fone Bluetooth',   'Fone over-ear',        349.90,  0.400, 'S');
INSERT INTO cp3_produto VALUES (cp3_seq_produto.NEXTVAL, 2, 'Livro Oracle',     'PL/SQL na pratica',     89.90,  0.800, 'S');
INSERT INTO cp3_produto VALUES (cp3_seq_produto.NEXTVAL, 3, 'Cafe Premium',     'Pacote 500g',           28.50,  0.500, 'S');
INSERT INTO cp3_produto VALUES (cp3_seq_produto.NEXTVAL, 4, 'Camiseta Basica',  '100% algodao',          59.90,  0.250, 'S');
-- Mouse sem fio: produto cadastrado mas inativo (ativo='N')
INSERT INTO cp3_produto VALUES (cp3_seq_produto.NEXTVAL, 1, 'Mouse sem fio',    'Mouse wireless',        79.90,  0.200, 'N');

-- 4.7 Produto x Fornecedor
INSERT INTO cp3_produto_fornecedor VALUES (1, 1, 2200.00, 7);
INSERT INTO cp3_produto_fornecedor VALUES (2, 1,  220.00, 5);
INSERT INTO cp3_produto_fornecedor VALUES (3, 2,   55.00, 3);
INSERT INTO cp3_produto_fornecedor VALUES (4, 3,   18.00, 2);
INSERT INTO cp3_produto_fornecedor VALUES (5, 3,   35.00, 4);

-- 4.8 Estoque (note: produto 2 está abaixo do mínimo; produto 6 zerado)
INSERT INTO cp3_estoque VALUES (1,  12,  5, SYSDATE);
INSERT INTO cp3_estoque VALUES (2,   3, 10, SYSDATE);
INSERT INTO cp3_estoque VALUES (3,  80, 20, SYSDATE);
INSERT INTO cp3_estoque VALUES (4, 150, 50, SYSDATE);
INSERT INTO cp3_estoque VALUES (5,  60, 30, SYSDATE);
INSERT INTO cp3_estoque VALUES (6,   0,  5, SYSDATE);

-- 4.9 Pedidos (5 finalizados + 1 pendente, para testar exercício 8)
INSERT INTO cp3_pedido VALUES (cp3_seq_pedido.NEXTVAL, 1, 1, SYSDATE-90, 'FINALIZADO', 3348.90, 41.00);
INSERT INTO cp3_pedido VALUES (cp3_seq_pedido.NEXTVAL, 1, 1, SYSDATE-30, 'FINALIZADO',  118.40, 17.60);
INSERT INTO cp3_pedido VALUES (cp3_seq_pedido.NEXTVAL, 2, 2, SYSDATE-60, 'FINALIZADO',  179.80, 15.80);
INSERT INTO cp3_pedido VALUES (cp3_seq_pedido.NEXTVAL, 3, 3, SYSDATE-15, 'FINALIZADO', 2999.00, 40.00);
INSERT INTO cp3_pedido VALUES (cp3_seq_pedido.NEXTVAL, 4, 4, SYSDATE-5,  'FINALIZADO',   89.90, 22.40);
INSERT INTO cp3_pedido VALUES (cp3_seq_pedido.NEXTVAL, 5, 5, SYSDATE-1,  'PENDENTE',      0.00,  0.00);

-- 4.10 Itens dos pedidos
INSERT INTO cp3_pedido_item VALUES (cp3_seq_item.NEXTVAL, 1, 1, 1, 2999.00,   0);
INSERT INTO cp3_pedido_item VALUES (cp3_seq_item.NEXTVAL, 1, 2, 1,  349.90,   0);
INSERT INTO cp3_pedido_item VALUES (cp3_seq_item.NEXTVAL, 2, 3, 1,   89.90,   0);
INSERT INTO cp3_pedido_item VALUES (cp3_seq_item.NEXTVAL, 2, 4, 1,   28.50,   0);
INSERT INTO cp3_pedido_item VALUES (cp3_seq_item.NEXTVAL, 3, 2, 1,  349.90, 170.10);
INSERT INTO cp3_pedido_item VALUES (cp3_seq_item.NEXTVAL, 4, 1, 1, 2999.00,   0);
INSERT INTO cp3_pedido_item VALUES (cp3_seq_item.NEXTVAL, 5, 3, 1,   89.90,   0);
-- Pedido pendente do cliente 5: comprar 2 camisetas para o exercício 8/10
INSERT INTO cp3_pedido_item VALUES (cp3_seq_item.NEXTVAL, 6, 5, 2,   59.90,   0);

-- 4.11 Pagamentos
INSERT INTO cp3_pagamento VALUES (cp3_seq_pagamento.NEXTVAL, 1, 'PIX',    3389.90, 'PAGO', SYSDATE-90, 1);
INSERT INTO cp3_pagamento VALUES (cp3_seq_pagamento.NEXTVAL, 2, 'BOLETO',  136.00, 'PAGO', SYSDATE-30, 1);
INSERT INTO cp3_pagamento VALUES (cp3_seq_pagamento.NEXTVAL, 3, 'CARTAO',  195.60, 'PAGO', SYSDATE-60, 2);
INSERT INTO cp3_pagamento VALUES (cp3_seq_pagamento.NEXTVAL, 4, 'PIX',    3039.00, 'PAGO', SYSDATE-15, 1);
INSERT INTO cp3_pagamento VALUES (cp3_seq_pagamento.NEXTVAL, 5, 'CARTAO',  112.30, 'PAGO', SYSDATE-5,  3);

COMMIT;

-- ---------------------------------------------------------------------
-- 5. Verificação rápida (opcional)
-- ---------------------------------------------------------------------
PROMPT
PROMPT === Resumo da carga ===
SELECT 'cp3_categoria'           AS tabela, COUNT(*) AS linhas FROM cp3_categoria
UNION ALL SELECT 'cp3_cliente',            COUNT(*) FROM cp3_cliente
UNION ALL SELECT 'cp3_cep',                COUNT(*) FROM cp3_cep
UNION ALL SELECT 'cp3_endereco',           COUNT(*) FROM cp3_endereco
UNION ALL SELECT 'cp3_fornecedor',         COUNT(*) FROM cp3_fornecedor
UNION ALL SELECT 'cp3_produto',            COUNT(*) FROM cp3_produto
UNION ALL SELECT 'cp3_produto_fornecedor', COUNT(*) FROM cp3_produto_fornecedor
UNION ALL SELECT 'cp3_estoque',            COUNT(*) FROM cp3_estoque
UNION ALL SELECT 'cp3_movimento_estoque',  COUNT(*) FROM cp3_movimento_estoque
UNION ALL SELECT 'cp3_pedido',             COUNT(*) FROM cp3_pedido
UNION ALL SELECT 'cp3_pedido_item',        COUNT(*) FROM cp3_pedido_item
UNION ALL SELECT 'cp3_pagamento',          COUNT(*) FROM cp3_pagamento;

PROMPT
PROMPT Schema ShopFast pronto. Pode iniciar os exercicios.
