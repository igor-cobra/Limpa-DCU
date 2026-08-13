# DECISÕES DE PRODUÇÃO

## Nome do projeto

O repositório, o DPR e o executável permanecem como `LimpaDCU`. A evolução para um “DevJanitor Delphi” acontece pelo escopo das futuras rotinas, sem quebrar identidade/histórico.

## Runtime Packages

Debug usa Runtime Packages para desenvolvimento. Release não usa Runtime Packages e deve funcionar sem Delphi instalado.

## Win32 e Win64

As duas arquiteturas são builds independentes, com artefatos separados. O instalador é único e escolhe qual executável instalar.

## Dados

Executável e dados não ficam misturados. O banco é compartilhado entre Win32/Win64 e migrações preservam dados antes da remoção de instalações antigas.

## Limpeza

O botão principal remove apenas `*.dcu`. Outros artefatos só devem entrar em perfis explícitos quando houver regra segura e necessidade real.

## EditorConfig

O `.editorconfig` pertence ao projeto e aparece no Project Manager, mas o Delphi puro não depende dele para configurar seu editor. No Delphi 13 ele pode ser consumido pelo MSys Delphi Formatter.

## Arquivos administrativos no Project Manager

Documentação, scripts e arquivos de configuração são itens `None` no `.dproj`: pertencem ao projeto sem serem compilados.

## Versão mínima do Delphi

A versão mínima oficialmente suportada é Delphi 13 Florence. A baseline não será artificialmente rebaixada para Delphi 12.x apenas para ampliar compatibilidade sem uma necessidade concreta.

Delphi 13 Community Edition pode ser usado tecnicamente por quem se enquadrar na licença vigente. Lazarus/FPC permanece como possibilidade de port futuro, não como target atual.

## Estratégia de branches

Mudanças arquiteturais grandes não entram diretamente na `main`. A baseline de produção deve ser fechada em `refactor/production-baseline`; a infraestrutura DUnitX deve nascer depois em `test/dunitx`, a partir da `main` já atualizada.
