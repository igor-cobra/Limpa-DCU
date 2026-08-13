# CHECKLIST DE RELEASE

- [ ] Release preparada a partir de uma branch integrada/revisada, sem reforma arquitetural não revisada direto na `main`.
- [ ] `git status` sem artefatos gerados.
- [ ] `scripts\Validate.ps1` passou.
- [ ] Rebuild Win32 Release passou.
- [ ] Rebuild Win64 Release passou.
- [ ] Win32 e Win64 possuem a mesma versão.
- [ ] Release não depende de BPLs do Delphi.
- [ ] Teste do Win32 em máquina sem Delphi.
- [ ] Teste do Win64 em máquina sem Delphi.
- [ ] Toast imediato abre o resumo.
- [ ] Toast na Central abre o resumo.
- [ ] Alt+Tab/taskbar processa resumo pendente.
- [ ] Upgrade preserva `database.db`.
- [ ] Troca Win32 ↔ Win64 preserva dados.
- [ ] Desinstalação remove os dados do LimpaDCU quando essa for a intenção da release.
- [ ] Instalador e SHA-256 foram gerados.

> Quando o projeto DUnitX for integrado, adicionar a execução da suíte automatizada como item obrigatório desta checklist.
