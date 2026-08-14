# IDENTIDADE VISUAL

## Regra

A reforma de arquitetura não deve alterar a identidade visual do LimpaDCU sem uma mudança de UI deliberada e isolada.

## Baseline preservada

- tema claro: `Aqua Light Slate`;
- tema escuro: `Glow`;
- styles declarados em `Custom_Styles` no `LimpaDCU.dproj` e embutidos na aplicação;
- fallback opcional para `styles\AquaLightSlate.vsf` e `styles\Glow.vsf` ao lado do executável;
- ícone oficial: `assets\icons\LimpaDCU.ico`, restaurado a partir do ícone histórico do repositório;
- `UntMain` mantém a pintura manual apenas onde a baseline original já fazia isso. Controles que pertencem ao VCL Style não devem receber uma segunda camada de estilização manual.

## Por que isso importa

Sem os `Custom_Styles`, o estado escuro continua aplicando cores manuais, mas componentes como `TToggleSwitch`, botões, títulos do `TDBGrid` e outros elementos voltam ao style padrão do Windows. O resultado é uma interface híbrida e inconsistente.

Por isso, `UntTemaAplicacao` tenta primeiro ativar o style embutido pelo nome e só utiliza arquivos `.vsf` externos como compatibilidade com instalações antigas.

## Alterações futuras

Mudanças de layout, tema, ícone ou componentes visuais devem ser tratadas como alteração própria e revisadas separadamente de refactors de infraestrutura, build, notificações, instalador ou persistência.
