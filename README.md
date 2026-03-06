# Delphi DCU Cleaner

Utilitário desktop desenvolvido em Delphi para **agilizar a limpeza de arquivos `.dcu`** (Delphi Compiled Units) em projetos grandes, legados ou com múltiplos módulos e diretórios.

## 🧹 Objetivo

Em projetos Delphi de médio e grande porte, o acúmulo de arquivos `.dcu` pode causar conflitos, comportamentos inesperados e problemas de compilação. Este utilitário foi criado para simplificar esse processo, permitindo a remoção rápida e controlada desses arquivos.

## ✨ Funcionalidades

- Cadastro de projetos e caminhos de varredura.
- Varredura recursiva de diretórios.
- Exclusão automatizada de arquivos `.dcu`.
- Interface simples e objetiva.
- Persistência de preferências do usuário.
- Suporte a tema claro e escuro.

## 🛠️ Tecnologias Utilizadas

- **Delphi / Object Pascal**
- **VCL** para a interface visual
- **FireDAC** para acesso ao banco local de configurações e dados
- **SQLite** para persistência local

## 📂 Estrutura do Projeto

- `UntMain.pas`: formulário principal da aplicação.
- `UntClassLimpaDcu.pas`: regra principal da limpeza dos arquivos `.dcu`.
- `UntCdsProj0.pas`: controle dos datasets de projetos cadastrados.
- `UntDtmCnx.pas`: data module com conexão e estrutura do banco local.
- `UntLib.pas`: funções auxiliares do projeto.
- `UntTemaAplicacao.pas`: centralização de tema, estilos visuais e persistência da preferência do usuário.

## ⚙️ Como Usar

1. Compile o projeto no Delphi.
2. Execute o aplicativo.
3. Cadastre um ou mais projetos informando o diretório raiz.
4. Selecione os projetos desejados.
5. Inicie a limpeza.
6. Acompanhe o log da aplicação durante o processo.

## 🎨 Temas e arquivos `.vsf`

- Os arquivos `.vsf` utilizados por este projeto **não foram incluídos neste repositório**. Como os estilos atualmente adotados podem ser obtidos a partir do ecossistema do Delphi / RAD Studio, optou-se por **não versioná-los publicamente** junto ao código-fonte.
- O projeto foi implementado de forma a **priorizar primeiro os recursos disponíveis no próprio ambiente Delphi**, reaproveitando o comportamento padrão do sistema de estilos da plataforma. Ainda assim, por **medida de segurança e previsibilidade na distribuição**, também é suportado o carregamento dos arquivos `.vsf` externos pela pasta `styles`, localizada ao lado do executável.
- Essa abordagem foi adotada para evitar dependência exclusiva da configuração local de cada máquina de desenvolvimento, garantindo que a aplicação possa encontrar exatamente os estilos esperados em ambiente de teste, homologação e produção.
- Os arquivos podem ser posicionados na seguinte estrutura:

  ```text
  styles\
    AquaLightSlate.vsf
    Glow.vsf
  ```

## 📌 Observações

- É **altamente recomendado realizar backup** antes de executar limpezas em massa.
- O utilitário foi projetado para atuar sobre arquivos `.dcu`.
- Revise cuidadosamente qualquer personalização local antes de executar o processo em diretórios compartilhados.

## 📜 Licença

Este projeto está licenciado sob os termos da **MIT License**.

Consulte o arquivo [`LICENSE_MIT.txt`](LICENSE_MIT.txt) para o texto completo da licença.

## 🤝 Contribuições

Contribuições são bem-vindas. Sinta-se à vontade para abrir issues ou enviar pull requests com melhorias, correções e sugestões.

---

> Desenvolvido para facilitar o dia a dia de quem lida com grandes projetos Delphi.
