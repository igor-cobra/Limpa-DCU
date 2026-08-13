# ROADMAP

## Próximos passos possíveis

- criar perfis explícitos de limpeza somente quando houver um segundo tipo real de artefato a tratar;
- permitir exclusões por projeto para diretórios que não devem ser varridos;
- adicionar modo de simulação (“dry run”) antes de novas categorias destrutivas;
- adicionar projeto DUnitX e suíte automatizada para regras de path, migração, persistência e limpeza;
- assinar digitalmente EXE e instalador quando houver certificado de code signing;
- avaliar MSIX apenas se o modelo de distribuição passar a se beneficiar das restrições e identidade do pacote.

Não é objetivo transformar o LimpaDCU em um framework de limpeza antes de existir necessidade concreta.

## Testes automatizados

A próxima evolução planejada deve ocorrer em `test/dunitx`, a partir da `main` já contendo a baseline de produção.

Prioridade inicial:

- paths válidos e inválidos;
- raiz de unidade;
- reparse points/junctions;
- migração de banco legado;
- estrutura SQLite;
- configurações persistidas;
- regras de limpeza que não dependem diretamente da UI.
