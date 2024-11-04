-- Nome do Banco de Dados: AGRICULTURA_DB
-- Este script verifica a existência do schema, tabelas e cria-os apenas se não existirem.

-- Verificar se o schema (usuário) PRODUCAO já existe
DECLARE
    schema_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO schema_count
    FROM ALL_USERS
    WHERE USERNAME = 'PRODUCAO';

    IF schema_count = 0 THEN
        -- Criação do schema (usuário) PRODUCAO
        EXECUTE IMMEDIATE 'CREATE USER PRODUCAO IDENTIFIED BY production2024';

        -- Conceder permissões ao schema para que ele possa criar e gerenciar tabelas
        EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO PRODUCAO';

        -- Permitir a criação de tabelas no schema
        EXECUTE IMMEDIATE 'ALTER USER PRODUCAO QUOTA UNLIMITED ON USERS';
    END IF;
END;
/

-- Alterar a sessão para o schema PRODUCAO
ALTER SESSION SET CURRENT_SCHEMA = PRODUCAO;

-- Verificar e criar a tabela T_PRODUTO se não existir
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ALL_TABLES WHERE TABLE_NAME = 'T_PRODUTO' AND OWNER = 'PRODUCAO') THEN
        EXECUTE IMMEDIATE '
            CREATE TABLE PRODUCAO.T_PRODUTO (
                idt_produto NUMBER PRIMARY KEY,
                nm_produto VARCHAR2(50) NOT NULL
            )';
    END IF;
END;
/

-- Verificar e criar a tabela T_LOCALIZACAO se não existir
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ALL_TABLES WHERE TABLE_NAME = 'T_LOCALIZACAO' AND OWNER = 'PRODUCAO') THEN
        EXECUTE IMMEDIATE '
            CREATE TABLE PRODUCAO.T_LOCALIZACAO (
                cd_ibge NUMBER PRIMARY KEY,
                sg_uf CHAR(2) NOT NULL,
                nm_municipio VARCHAR2(50) NOT NULL
            )';
    END IF;
END;
/

-- Verificar e criar a tabela T_PERIODO se não existir
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ALL_TABLES WHERE TABLE_NAME = 'T_PERIODO' AND OWNER = 'PRODUCAO') THEN
        EXECUTE IMMEDIATE '
            CREATE TABLE PRODUCAO.T_PERIODO (
                nr_ano NUMBER(4) NOT NULL,
                nr_mes NUMBER(2) NOT NULL,
                dt_ano_mes CHAR(7) PRIMARY KEY
            )';
    END IF;
END;
/

-- Verificar e criar a tabela T_CUSTO_PRODUCAO se não existir
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ALL_TABLES WHERE TABLE_NAME = 'T_CUSTO_PRODUCAO' AND OWNER = 'PRODUCAO') THEN
        EXECUTE IMMEDIATE '
            CREATE TABLE PRODUCAO.T_CUSTO_PRODUCAO (
                idt_custo NUMBER PRIMARY KEY,
                idt_produto NUMBER NOT NULL,
                cd_ibge NUMBER NOT NULL,
                dt_ano_mes CHAR(7) NOT NULL,
                nm_safra VARCHAR2(10),
                ds_empreendimento VARCHAR2(50),
                un_comercializacao VARCHAR2(10),
                vl_custo_ha NUMBER(10, 2),
                vl_custo_unidade NUMBER(10, 2),
                vl_receita_unidade NUMBER(10, 2),
                vl_margem_lucro NUMBER(10, 2) GENERATED ALWAYS AS (vl_receita_unidade - vl_custo_unidade) VIRTUAL,
                CONSTRAINT fk_produto FOREIGN KEY (idt_produto) REFERENCES PRODUCAO.T_PRODUTO(idt_produto),
                CONSTRAINT fk_localizacao FOREIGN KEY (cd_ibge) REFERENCES PRODUCAO.T_LOCALIZACAO(cd_ibge),
                CONSTRAINT fk_periodo FOREIGN KEY (dt_ano_mes) REFERENCES PRODUCAO.T_PERIODO(dt_ano_mes)
            )';
    END IF;
END;
/

-- Mensagem de confirmação
BEGIN
    DBMS_OUTPUT.PUT_LINE('Script executado com sucesso. Verificações de existência realizadas e schema/tabelas criados conforme necessário.');
END;
/
