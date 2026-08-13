# LimpaDCU

Utilitário VCL para manutenção segura de artefatos de compilação em projetos Delphi.

**Baseline:** 2.2.0.0  
**RAD Studio:** Delphi 13 Florence  
**Plataformas:** Win32 e Win64

O projeto continua se chamando **LimpaDCU** para preservar a identidade e o histórico do repositório, mas a estrutura foi preparada para crescer de forma controlada na direção de um pequeno **DevJanitor para Delphi**.

## Estrutura

```text
LimpaDCU\
├─ src\
│  ├─ Class\
│  ├─ DataModule\
│  └─ Forms\
├─ docs\
├─ scripts\
├─ installer\
├─ assets\
├─ bin\                    # gerado
├─ build\                  # gerado
├─ .editorconfig
├─ .gitattributes
├─ .gitignore
├─ LimpaDCU.dpr
├─ LimpaDCU.dproj
└─ LimpaDCU.res
```

## Compatibilidade

A versão mínima **oficialmente suportada** é **Delphi 13 Florence**. O projeto também pode ser desenvolvido com o **Delphi 13 Community Edition**, desde que o usuário se enquadre nos termos de licenciamento da CE.

Lazarus/Free Pascal não é suportado atualmente. A lógica pode ser portada no futuro, mas a aplicação usa VCL, FireDAC e APIs específicas do Delphi/Windows, portanto não se trata de recompilar o mesmo projeto.

Veja [docs/COMPATIBILIDADE.md](docs/COMPATIBILIDADE.md).

## Fluxo Git

Mudanças arquiteturais e infraestrutura de testes devem ser desenvolvidas em branches separadas. Para esta baseline, use `refactor/production-baseline`; depois do merge na `main`, crie `test/dunitx` para a suíte DUnitX.

Veja [docs/FLUXO_GIT.md](docs/FLUXO_GIT.md).

## Project Manager do Delphi

Os arquivos de configuração, documentação, scripts e instalador são referenciados no `.dproj` como itens `<None Include="...">`.

Isso faz com que eles apareçam no **Project Manager** do Delphi sem serem enviados ao `dcc32`/`dcc64`.

Entre eles:

- `.editorconfig`;
- `.gitattributes`;
- `.gitignore`;
- `README.md`;
- `CHANGELOG.md`;
- documentação de `docs\`;
- scripts PowerShell;
- `installer\LimpaDCU.iss`.

## EditorConfig e Delphi 13

O RAD Studio não depende do `.editorconfig` para suas opções normais de editor. Neste projeto o arquivo tem dois objetivos:

1. definir regras estáveis para ferramentas/editoras que suportam EditorConfig;
2. servir como configuração por projeto para o **MSys Delphi Formatter** no RAD Studio 13.

O formatter mantém o fluxo `Ctrl+D` e lê regras do `.editorconfig` mais próximo do fonte.

Veja [docs/EDITORCONFIG_E_FORMATTER.md](docs/EDITORCONFIG_E_FORMATTER.md).

## Recurso do projeto

O `LimpaDCU.res` é versionado de propósito. Ele contém o recurso de aplicação necessário para que uma build por MSBuild funcione também em checkout limpo, sem depender de a IDE ter recriado o recurso antes.

## Build

O projeto abre por padrão em:

```text
Debug + Win32
```

As saídas são segregadas:

```text
bin\Win32\Debug\
bin\Win32\Release\
bin\Win64\Debug\
bin\Win64\Release\

build\dcu\Win32\Debug\
build\dcu\Win32\Release\
build\dcu\Win64\Debug\
build\dcu\Win64\Release\
```

Debug utiliza Runtime Packages. Release não utiliza Runtime Packages e é a configuração destinada à distribuição em máquinas sem Delphi instalado.

Para compilar as duas arquiteturas Release:

```powershell
pwsh .\scripts\Build.ps1 -Configuration Release -Platform All -Target Rebuild
```

Para gerar a release completa:

```powershell
pwsh .\scripts\Release.ps1
```

## Dados

A instalação utiliza o mesmo banco para Win32 e Win64:

```text
%PROGRAMDATA%\SucoDev\LimpaDCU\data\database.db
```

Quando o diretório compartilhado não está disponível em execução de desenvolvimento, existe fallback para `%LOCALAPPDATA%\SucoDev\LimpaDCU`.

## Segurança da limpeza

A rotina continua removendo apenas `*.dcu`.

Ela não atravessa roots de unidade nem junctions/reparse points, e falhas de acesso em subpastas são registradas sem interromper toda a execução.

## Licença

MIT. Consulte [LICENSE](LICENSE).
