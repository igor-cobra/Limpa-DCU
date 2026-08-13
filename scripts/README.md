# SCRIPTS

Os scripts desta pasta formam o fluxo suportado de build e release do LimpaDCU.

## Build

```powershell
pwsh .\scripts\Build.ps1 -Configuration Debug -Platform Win32
pwsh .\scripts\Build.ps1 -Configuration Release -Platform All -Target Rebuild
```

## Validação

```powershell
pwsh .\scripts\Validate.ps1
```

Com as duas Releases já compiladas:

```powershell
pwsh .\scripts\Validate.ps1 -ReleaseBinaries
```

## Release completa

```powershell
pwsh .\scripts\Release.ps1
```

O fluxo limpa artefatos, valida a árvore, compila Win32/Win64, verifica arquitetura/versão/dependências BPL e gera o setup com SHA-256.
