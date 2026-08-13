# FLUXO GIT

## Objetivo

Manter a `main` sempre representando uma baseline coerente e permitir que mudanças arquiteturais, testes e novas funcionalidades sejam revisadas separadamente.

## Situação da reforma 2.2.0

A reforma de produção altera estrutura, build, instalador, paths, documentação e diversas units. Por esse motivo ela **não deve ser commitada diretamente na `main`**.

Com a working tree atual, crie uma branch antes do primeiro commit:

```powershell
git switch -c refactor/production-baseline
```

O Git mantém as alterações não commitadas ao trocar para a nova branch. Depois:

```powershell
git status
git add .
git commit -m "Reestrutura projeto para baseline de produção"
```

Execute as validações e builds necessárias nessa branch. Quando estiver estável:

```powershell
git switch main
git merge --no-ff refactor/production-baseline
```

Se o repositório estiver sendo trabalhado por mais pessoas, prefira Pull Request em vez de fazer o merge localmente.

## Branch do DUnitX

O projeto de testes deve nascer **depois que a baseline de produção estiver integrada à `main`**.

```powershell
git switch main
git pull
git switch -c test/dunitx
```

A branch `test/dunitx` deve conter somente o que for necessário para introduzir a infraestrutura e a suíte inicial de testes. Isso deixa a revisão muito mais simples do que misturar reorganização arquitetural e criação de testes no mesmo commit/PR.

## Evolução sugerida da branch de testes

O primeiro conjunto de DUnitX deve priorizar regras que possam ser verificadas sem depender de interação visual:

1. validação de caminhos seguros para limpeza;
2. bloqueio de raiz de unidade;
3. comportamento com junction/reparse point;
4. seleção das extensões que podem ser removidas;
5. migração e descoberta de banco legado;
6. criação/atualização da estrutura SQLite;
7. persistência de configurações;
8. regras de seleção/cadastro que possam ser extraídas da UI sem artificializar a arquitetura.

Notificações, VCL Styles e comportamento visual devem ficar para testes de integração ou manuais quando DUnitX puro não trouxer benefício real.

## Convenção simples de branches

Não é necessário adotar Git Flow completo. Para o tamanho atual do projeto, uma convenção curta é suficiente:

```text
main
  versão estável / integrável

refactor/*
  reorganizações e mudanças arquiteturais

feature/*
  funcionalidade nova

test/*
  infraestrutura e suítes de teste

fix/*
  correção objetiva

release/*
  opcional, apenas quando houver necessidade real de estabilização de uma release
```

## Commits

Prefira commits que contem uma mudança coerente. Exemplos:

```text
Reestrutura projeto para baseline de produção
Adiciona infraestrutura de testes com DUnitX
Adiciona testes das regras de segurança de caminhos
Adiciona testes de migração do banco legado
```

Evite transformar toda a suíte DUnitX em um único commit se ela crescer além da infraestrutura inicial.

## Branches antigas

Branches históricas como `Notifications` e `Tema-escuro` não devem ser reutilizadas para trabalho novo. Depois de confirmar que todo o conteúdo necessário já está integrado à `main`, elas podem ser mantidas apenas como histórico ou removidas do remoto conforme a política do repositório.
