# EDITORCONFIG E FORMATTER

## O que o `.editorconfig` faz neste projeto

O `.editorconfig` define convenções de arquivo que podem ser consumidas por ferramentas compatíveis:

- encoding;
- quebra de linha;
- indentação;
- newline final;
- remoção de espaços no fim da linha.

No RAD Studio 13 Florence, o arquivo também pode ser usado pelo **MSys Delphi Formatter**, que suporta configuração por projeto via `.editorconfig`.

## O que ele não faz

O `.editorconfig` não substitui as opções gerais do editor do RAD Studio. Sem uma ferramenta que o interprete, o Delphi não passa a aplicar automaticamente essas regras só porque o arquivo existe no repositório.

## Regras do LimpaDCU

Pascal:

```text
UTF-8 com BOM
CRLF
3 espaços
```

DFM:

```text
UTF-8 com BOM
CRLF
2 espaços
```

PowerShell/Inno/TXT:

```text
UTF-8 com BOM
CRLF
```

Markdown/YAML/JSON e arquivos Git:

```text
UTF-8
LF
```

## MSys Delphi Formatter

A configuração Pascal também contém:

```ini
delphi_keep_user_linebreaks = true
```

A intenção é impedir que a formatação transforme desnecessariamente a estrutura de linhas já escrita pelo desenvolvedor.

Não foram adicionadas propriedades específicas do MSys sem documentação/verificação. O restante das preferências pode ser ajustado em `Tools > Options > MSys > Delphi Formatter` e exportado posteriormente para o `.editorconfig` se a equipe decidir padronizá-las.

## Project Manager

O `.editorconfig` e os demais arquivos administrativos são incluídos no `.dproj` como:

```xml
<None Include=".editorconfig" />
```

Isso os deixa visíveis no Project Manager, mas não os compila.
