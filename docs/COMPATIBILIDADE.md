# COMPATIBILIDADE

## Ambiente oficialmente suportado

A baseline atual do LimpaDCU é mantida e validada para:

- **Delphi 13 Florence**;
- VCL para Windows;
- Win32;
- Win64.

A política do projeto considera **Delphi 13 Florence a versão mínima oficialmente suportada**. Versões anteriores podem eventualmente compilar com ajustes, mas não fazem parte da matriz de validação e não devem ser tratadas como compatibilidade garantida.

## Delphi Community Edition

O projeto pode ser aberto e alterado com o **Delphi 13 Community Edition**, pois a edição atual é baseada no Delphi 13 Florence e disponibiliza VCL, compiladores, debugger e recursos para aplicações nativas.

O LimpaDCU utiliza SQLite local via FireDAC, sem depender de um servidor de banco externo para seu funcionamento normal.

A possibilidade técnica de compilar o projeto com Community Edition não substitui os termos de licenciamento da Embarcadero. Quem utilizar a CE deve confirmar que se enquadra nas condições de uso vigentes, incluindo os limites comerciais e de tamanho de equipe definidos pela licença.

Para o repositório, a regra é simples:

```text
Delphi 13 Florence Professional+  -> suportado
Delphi 13 Florence Community      -> suportado tecnicamente*
Delphi 12.x ou anterior           -> não suportado oficialmente
```

`*` Respeitando integralmente a licença da Community Edition.

## Lazarus / Free Pascal

O LimpaDCU **não possui suporte Lazarus/FPC atualmente**.

Lazarus é compatível com Delphi em muitos conceitos e a LCL foi criada com forte compatibilidade com a VCL, mas a compatibilidade não é total. A aplicação atual também utiliza dependências específicas do ecossistema Delphi/Windows, entre elas:

- VCL;
- FireDAC;
- `System.Notification`;
- `Winapi.ShlObj`;
- VCL Styles;
- arquivos `.dproj` / `.dfm`;
- componentes e comportamento específicos da VCL.

Um port para Lazarus seria viável, mas seria um **port**, não apenas recompilar o mesmo projeto. Entre as substituições esperadas estariam:

```text
Delphi / VCL              Lazarus / FPC
------------------------------------------------
VCL                        LCL
.dproj / .dpr              .lpi / .lpr
.dfm                       .lfm
FireDAC                    SQLDB / SQLite3Connection
TFDQuery                   TSQLQuery
TFDMemTable                TBufDataset ou equivalente
System.Notification        implementação específica
VCL Styles                 solução de tema da LCL
```

## Diretriz arquitetural para um port futuro

Não será criada agora uma camada de abstração só para antecipar Lazarus. O projeto continua VCL/FireDAC enquanto essa for a única implementação real.

Se um port Lazarus for iniciado, o primeiro passo deve ser extrair apenas a lógica que realmente puder ser compartilhada, por exemplo:

```text
src\Core\
  Scanner / regras de path / perfis de limpeza

src\Delphi\
  VCL / FireDAC / notificações Windows

src\Lazarus\
  LCL / SQLDB / integração específica
```

A abstração deve nascer da segunda implementação concreta, não antes dela.
