# BUILD E DISTRIBUICAO

## Ambiente suportado

- Delphi 13 Florence;
- Delphi 13 Community Edition é tecnicamente compatível, respeitando a licença da CE;
- Lazarus/FPC não faz parte da matriz de build;
- Delphi 12.x e anteriores não são versões oficialmente suportadas por esta baseline.

Veja [COMPATIBILIDADE.md](COMPATIBILIDADE.md).

## Matriz

| Configuração | Win32 | Win64 |
|---|---:|---:|
| Debug | suportado | suportado |
| Release | suportado | suportado |

## Debug

- Runtime Packages: ligado;
- otimização: desligada;
- Debug DCUs: ligados;
- símbolos locais: ligados;
- Debug Information: 2;
- Range/Overflow checking: ligados.

## Release

- Runtime Packages: desligado;
- otimização: ligada;
- símbolos/debug DCUs: desligados.

## Saídas

```text
bin\$(Platform)\$(Config)\
build\dcu\$(Platform)\$(Config)\
```

## Compilar

```powershell
pwsh .\scripts\Build.ps1 -Configuration Debug -Platform Win32
pwsh .\scripts\Build.ps1 -Configuration Release -Platform All -Target Rebuild
```

## Release

```powershell
pwsh .\scripts\Release.ps1
```

O release exige os dois executáveis e valida arquitetura/versão antes de gerar o instalador.
