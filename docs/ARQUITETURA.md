# ARQUITETURA

## Objetivo

Manter o LimpaDCU pequeno e previsível, com responsabilidades claras e sem criar camadas sem necessidade real.

## Componentes

### `UntClassAplicacao`

Centraliza identidade, arquitetura, versão, diretórios de dados, instância única e migração/limpeza de legado.

### `UntDtmCnx`

Única instância de acesso ao SQLite criada pelo DPR. `TLimpaDcu` recebe essa dependência e não cria outro DataModule.

### `UntClassLimpaDcu`

Coordena cadastro, exclusão, seleção e limpeza de DCUs.

### `UntClassLog`

Grava log técnico sem interferir na operação principal em caso de falha de escrita.

### `UntClassDialogos` / `UntClassNotificacaoWindows`

Centralizam diálogos e notificações, incluindo estado pendente enquanto a instância permanece em execução.

### `UntTemaAplicacao`

Centraliza cores e preferência de tema persistida no SQLite.

## Ownership

```text
DPR
├─ TdtmCnx
└─ TFrmMain
   └─ TLimpaDcu
```

## Regra de expansão

O projeto não cria `factory`, `strategy` ou `repository` só para antecipar necessidades. Um segundo perfil real de limpeza será o gatilho para abstrair estratégias de limpeza.

## Testabilidade

A introdução do DUnitX não deve provocar uma reescrita artificial da arquitetura. Primeiro serão testadas as regras já naturalmente isoláveis. Extrações adicionais devem ocorrer apenas quando uma dependência de UI/infraestrutura impedir um teste útil e a separação também melhorar o desenho do código de produção.
