# INSTALADOR

O LimpaDCU usa um único instalador Inno Setup contendo as builds Win32 e Win64.

- Windows 32-bit instala Win32.
- Windows 64-bit oferece Win64 (recomendado) ou Win32 (compatibilidade).
- O banco é compartilhado entre arquiteturas em `%PROGRAMDATA%\SucoDev\LimpaDCU`.
- Antes de remover resíduos antigos, o setup executa a migração do banco no contexto do usuário original.
- Se a preservação do banco falhar, a atualização é interrompida antes da limpeza do legado.

O arquivo `LimpaDCU.iss` não deve ser compilado como substituto do fluxo de release sem que as duas builds Release já existam. O caminho suportado é `scripts\Release.ps1`.
