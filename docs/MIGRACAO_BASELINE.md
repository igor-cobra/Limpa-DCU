# MIGRAÇÃO PARA ESTA BASELINE

A substituição pode ser feita mantendo a pasta `.git` atual. Como esta baseline altera arquitetura, build, instalador e documentação, faça a integração em branch própria.

1. Na working tree atual, crie `refactor/production-baseline` antes do primeiro commit.
2. Faça backup se necessário e confirme o estado com `git status`.
3. Remova arquivos antigos do projeto, preservando `.git`.
4. Copie o conteúdo desta baseline para a raiz do repositório.
5. Confirme que `LimpaDCU.res` está versionado.
6. Abra `LimpaDCU.dproj` no Delphi 13 Florence.
7. Confirme `Debug + Win32` como seleção inicial.
8. Execute `scripts\Validate.ps1`.
9. Faça `Clean + Rebuild` de Debug/Win32 e valide a depuração.
10. Valide notificações e persistência.
11. Faça a release completa com `scripts\Release.ps1`.
12. Commit/PR da branch de baseline e merge na `main`.
13. Somente depois crie `test/dunitx` a partir da `main` atualizada.

Arquivos `bin`, `build`, `installer\output` e `installer\temp` são gerados e não devem ser copiados/versionados.

Veja [FLUXO_GIT.md](FLUXO_GIT.md) para os comandos e a estratégia sugerida.
