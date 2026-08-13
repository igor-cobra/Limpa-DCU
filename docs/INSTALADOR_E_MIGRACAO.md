# INSTALADOR E MIGRACAO

O instalador único contém Win32 e Win64.

- Windows 32-bit: instala Win32;
- Windows 64-bit: permite Win64 ou Win32, com Win64 como padrão.

Os dados são compartilhados entre arquiteturas em:

```text
%PROGRAMDATA%\SucoDev\LimpaDCU
```

Antes da limpeza de legado, o setup executa um helper no contexto do usuário original para preservar bancos encontrados em locais antigos.

A migração utiliza arquivo temporário `database.db.migrando` e somente promove a cópia quando o tamanho confere.

A limpeza antiga inclui caminhos conhecidos do LimpaDCU, sem apagar diretórios genéricos da máquina.
