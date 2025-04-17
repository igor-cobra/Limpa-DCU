# Delphi DCU Cleaner

Este projeto foi desenvolvido em Delphi com o objetivo de **agilizar a limpeza de arquivos `.dcu`** (Delphi Compiled Units) gerados em grandes projetos Delphi, principalmente em ambientes com múltiplos módulos e diretórios.

## 🧹 Objetivo

Durante o desenvolvimento em Delphi, especialmente em projetos grandes, é comum a geração excessiva de arquivos `.dcu`, que podem gerar conflitos, erros de compilação. Este utilitário permite remover rapidamente esses arquivos de forma segura e automatizada.

## 🛠️ Tecnologias Utilizadas

- **Delphi** (versão compatível com a sua base de desenvolvimento)
- **VCL** para a interface visual
- **FireDAC** para acesso a dados (caso necessário para log ou controle)

## 📂 Estrutura do Projeto

- `UntMain.pas`: Formulário principal da aplicação, responsável pela interface e interação com o usuário.
- `UntClassLimpaDcu.pas`: Classe principal que implementa a lógica de limpeza de arquivos `.dcu`.
- `UntCdsProj0.pas`: Gerencia os datasets dos projetos e módulos que serão varridos.
- `UntDtmCnx.pas`: Contém a estrutura de conexão com banco de dados usando FireDAC.
- `UntLib.pas`: Funções auxiliares usadas no processo de varredura e exclusão.

## ⚙️ Como Usar

1. Execute o aplicativo.
2. Cadastre novos projetos informando o diretório raiz (caso necessário).
3. Selecione o(s) projetos que deseja fazer a limpeza.
4. Inicie o processo.
4. O sistema irá varrer recursivamente os diretórios em busca de arquivos `.dcu` e listá-los durante o processo de exclusão.
1. Compile o projeto no Delphi.

## 🚀 Funcionalidades

- Varredura recursiva de diretórios.
- Listagem dos arquivos a serem removidos.
- Interface simples e objetiva.

## 📌 Observações

- É **altamente recomendado realizar um backup** antes de qualquer operação de limpeza.
- Este utilitário **não afeta arquivos `.pas`, `.dfm`, `.bpl` ou executáveis**.

## 📜 Licença

Este projeto está licenciado sob os termos da **GNU General Public License v3.0 (GPLv3)**.  
Você pode consultar os detalhes da licença no arquivo [LICENSE](LICENSE) ou no site oficial:  
[https://www.gnu.org/licenses/gpl-3.0.html](https://www.gnu.org/licenses/gpl-3.0.html)

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se livre para abrir issues ou enviar pull requests com melhorias, correções ou sugestões.

---

> Desenvolvido para facilitar o dia a dia de quem lida com grandes projetos Delphi. 🚀
