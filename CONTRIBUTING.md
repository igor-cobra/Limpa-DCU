# CONTRIBUINDO

## Ambiente

- use **Delphi 13 Florence** ou uma edição compatível da mesma geração;
- Delphi 13 Community Edition é tecnicamente compatível, respeitando os termos da licença da CE;
- preserve Win32 e Win64;
- Lazarus/FPC não faz parte da matriz de build atual.

## Código e repositório

- não versione `bin`, `build` ou arquivos de runtime;
- não compartilhe DCUs entre Debug/Release ou Win32/Win64;
- novas limpezas devem ser explícitas e comprovadamente seguras;
- não coloque regras de filesystem diretamente nos forms;
- mantenha arquivos Pascal em UTF-8 com BOM e CRLF;
- mantenha documentação em UTF-8 e LF;
- execute `scripts\Validate.ps1` antes de uma release;
- execute Clean + Rebuild das duas plataformas antes de empacotar.

## Branches

Não faça mudanças arquiteturais grandes diretamente na `main`. Use branches curtas por objetivo:

```text
refactor/*  arquitetura/reorganização
feature/*   funcionalidade
test/*      testes
fix/*       correções
```

A infraestrutura DUnitX deve ser desenvolvida em `test/dunitx`, criada a partir da `main` depois da integração da baseline de produção.

Veja [docs/FLUXO_GIT.md](docs/FLUXO_GIT.md).

## Testes

Ao introduzir DUnitX, priorize primeiro regras independentes da VCL: segurança de paths, migração, persistência e regras de limpeza. Evite criar abstrações artificiais apenas para aumentar cobertura.
