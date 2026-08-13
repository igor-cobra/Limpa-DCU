# CHANGELOG

## 2.2.0.0

### Projeto

- Debug + Win32 como configuração padrão;
- Win32 e Win64 suportados;
- Debug e Release com DCUs e executáveis segregados;
- Runtime Packages somente no Debug;
- Release standalone;
- arquivos de configuração/documentação adicionados ao Project Manager via `<None Include>`;
- `.editorconfig` preparado para EditorConfig e MSys Delphi Formatter.

### Código

- uma única instância de `TdtmCnx`;
- remoção da antiga `UntLib` genérica;
- persistência SQLite em Unicode;
- logs persistentes;
- proteção contra roots e reparse points na limpeza;
- remoção de `Application.ProcessMessages`;
- ciclo de vida explícito de `TLimpaDcu`.

### Notificações

- liberação correta de `TNotification`;
- processamento de diálogo pendente ao clicar no toast;
- fallback ao clicar pela Central de Notificações;
- processamento de diálogo pendente ao aplicativo recuperar foco;
- cancelamento da notificação quando o diálogo é consumido.

### Documentação

- define Delphi 13 Florence como versão mínima oficialmente suportada;
- documenta uso técnico com Delphi 13 Community Edition e ressalva de licenciamento;
- documenta Lazarus/FPC como port futuro, não como target suportado atualmente;
- adiciona estratégia de branches para baseline e DUnitX;
- adiciona `docs/COMPATIBILIDADE.md` e `docs/FLUXO_GIT.md`.
