# GranjaAvicola

Aplicação desktop desenvolvida em Delphi para controle de lotes de aves, com registro de pesagens, mortalidades e indicador visual de saúde por lote.

---

## Tecnologias

- **Delphi** RAD Studio 12 Athens (VCL, Win64)
- **Oracle Database** 21c XE
- **FireDAC** para acesso ao banco via stored procedures
- **PL/SQL** — toda escrita no banco passa pelo package `PKG_GRANJA`

---

## Pré-requisitos

- Delphi RAD Studio 12 (ou 10.3+)
- Oracle Database 21c XE instalado e rodando
- Oracle Instant Client **não necessário** — usa o `oci.dll` do próprio Oracle XE

---

## Configuração do banco de dados

### 1. Criar o usuário (executar como SYSTEM no container XEPDB1)

No SQL Developer, conecte como `system` e execute primeiro:

```sql
ALTER SESSION SET CONTAINER = XEPDB1;
```

Depois:

```sql
CREATE USER granja_user IDENTIFIED BY granja_pass
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP;

GRANT CONNECT, RESOURCE TO granja_user;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE PROCEDURE TO granja_user;
ALTER USER granja_user QUOTA UNLIMITED ON USERS;
```

### 2. Executar os scripts (conectado como granja_user no XEPDB1)

Abrir cada arquivo no SQL Developer e executar com F5, nesta ordem:

```
database/01_DDL_TABLES.sql   -- tabelas, sequências e constraints
database/02_PKG_GRANJA.sql   -- package PL/SQL com stored procedures
database/03_SEED_DATA.sql    -- dados iniciais de teste
```

### 3. Verificar a package

```sql
SELECT OBJECT_NAME, STATUS FROM USER_OBJECTS
WHERE OBJECT_TYPE IN ('PACKAGE', 'PACKAGE BODY');
```

Esperado: `PKG_GRANJA` com `STATUS = VALID`.

---

## Configuração da aplicação

Em `frmMain.pas`, no método `FormCreate`, ajuste a conexão conforme seu ambiente:

```pascal
FDConn.Params.Values['Database']  := 'LOCALHOST:1521/XEPDB1';
FDConn.Params.Values['User_Name'] := 'granja_user';
FDConn.Params.Values['Password']  := 'granja_pass';
```

O componente `TFDPhysOracleDriverLink` no form aponta para:

```
C:\app\<seu_usuario>\product\21c\dbhomeXE\bin\oci.dll
```

Ajuste o caminho conforme onde o Oracle XE foi instalado na sua máquina.

---

## Compilação

1. Abrir `GranjaAvicola.dproj` no Delphi
2. Confirmar plataforma **Windows 64-bit**
3. Verificar que os serviços Oracle estão rodando:
   ```cmd
   net start OracleServiceXE
   net start OracleOraDB21Home1TNSListener
   ```
4. Compilar e executar: **F9**

---

## Funcionalidades

**Tela principal**
- Lista de lotes em grid com percentual de mortalidade acumulada
- Indicador de saúde colorido por lote (verde / amarelo / vermelho)

**Detalhe do lote — aba Pesagens**
- Registro de data, peso médio e quantidade pesada
- Validação: quantidade pesada não pode ultrapassar o total inicial do lote
- Chama `PKG_GRANJA.SP_INSERIR_PESAGEM`, que recalcula o peso médio geral

**Detalhe do lote — aba Mortalidades**
- Registro de data, quantidade morta e observação
- Validação: mortalidade acumulada não pode ultrapassar o total inicial
- Chama `PKG_GRANJA.SP_INSERIR_MORTALIDADE`, que retorna o percentual acumulado para atualizar o indicador em tempo real

**Indicador de saúde (TLoteHealthIndicator)**

 Cor       Condição 

 Verde     Mortalidade < 5% 
 Amarelo   Entre 5% e 10% 
 Vermelho  Acima de 10% 

---

## Arquitetura

O projeto segue uma separação simples em três camadas:

- **Models.pas** — entidades de negócio (`TLote`, `TPesagem`, `TMortalidade`) com validações encapsuladas. `TPesagem` e `TMortalidade` herdam de `TRegistroBase`.
- **DAL.pas** — camada de acesso a dados. Toda escrita usa `TFDStoredProc` apontando para as procedures do Oracle. Leituras usam `TFDQuery`.
- **Forms** — apenas orquestram a interação com o usuário, sem lógica de negócio.

As stored procedures centralizam as regras no banco: validação de limites, cálculo de médias ponderadas e retorno do percentual de mortalidade para o cliente.
