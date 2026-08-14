### Correção de foco ao clicar na notificação da Central de Notificações

- o clique explícito em uma notificação pendente passa a solicitar foco forte para o formulário principal antes de abrir o diálogo;
- a ativação usa `AttachThreadInput` somente nesse caminho para contornar a restrição de foreground do Windows;
- restauração pela barra de tarefas, Alt+Tab e ativação normal continuam usando o fluxo comum, sem tentativa adicional de roubar foco.

# CHANGELOG

### Correção de diálogo pendente ao restaurar a aplicação

- o resumo de limpeza pendente passa a ser processado também na ativação global da aplicação;
- a restauração da janela pela barra de tarefas dispara o processamento via `WM_SIZE`;
- o processamento é postado para a fila de mensagens da VCL, evitando abrir diálogo modal durante a mensagem de ativação/restauração do Windows;
- o clique na notificação continua funcionando, mas deixou de ser o único caminho confiável para exibir o resumo pendente.

## Próxima versão

### Limpeza de DCUs

- execução da varredura e exclusão fora da thread visual, mantendo a janela responsiva durante o processo;
- enumeração das pastas em uma única passagem, sem montar previamente uma lista global de DCUs;
- gravação do log persistente em lote por projeto, removendo o custo de abrir o arquivo de log a cada DCU excluído;
- comandos que alteram projetos ficam temporariamente indisponíveis durante a limpeza, sem bloquear minimizar, restaurar ou mover a janela;
- restauração do diálogo de conclusão com resumo de projetos, arquivos removidos e falhas;
- quando a aplicação estiver sem foco, o toast continua registrando o diálogo pendente para exibição ao retornar ao LimpaDCU.

### Compilação

- corrigida a ambiguidade entre `Winapi.Windows.FindClose(THandle)` e `System.SysUtils.FindClose(TSearchRec)` no Win64;
- removidas atribuições de retorno sem uso em `GarantirDiretorios` e `ProcessarModoManutencao`, eliminando os hints H2077 relatados pelo compilador.

## 2.2.0.0

### Correção da baseline visual

- restaurados os VCL Styles históricos `Aqua Light Slate` e `Glow`;
- restaurado o ícone histórico do LimpaDCU;
- removida a estilização adicional do painel inferior que criava aparência híbrida com o style padrão do Windows;
- preservadas as mudanças de arquitetura, build, Win32/Win64, notificações, instalador e migração de dados.

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
