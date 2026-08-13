# MODO DE MANUTENÇÃO

O próprio executável possui modos internos usados pelo instalador. Eles não fazem parte da interface normal.

## `/migrar-legado`

Prepara os diretórios atuais e tenta preservar um `database.db` de versões antigas. A cópia é feita primeiro para `database.db.migrando`, validada por tamanho e somente então promovida para o nome definitivo.

Exit code `0` indica sucesso; `1`, falha.

## `/limpar-legado-usuario`

Remove resíduos conhecidos localizados no perfil do usuário original, como diretórios históricos e atalhos antigos. A rotina é de melhor esforço e não apaga diretórios genéricos.

Esses modos existem para que o setup elevado não dependa do perfil da conta usada no UAC para tratar dados do usuário original.
