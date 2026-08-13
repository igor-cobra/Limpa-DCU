# NOTIFICACOES

## Fluxo

Quando uma mensagem é marcada para notificar apenas se o aplicativo estiver sem foco:

1. o diálogo é guardado em memória com um identificador único;
2. o toast é publicado;
3. clique imediato no toast consome o diálogo;
4. clique posterior pela Central de Notificações tenta consumir pelo identificador;
5. se o Windows reativar o processo sem preservar o identificador, os diálogos pendentes são processados;
6. `TFrmMain.OnActivate` também processa pendências.

A exibição modal é enfileirada com `TThread.ForceQueue` para não abrir o diálogo dentro do próprio evento de ativação da VCL.

O estado pendente existe somente enquanto a instância está viva. Notificações são canceladas ao serem consumidas e na finalização normal.
