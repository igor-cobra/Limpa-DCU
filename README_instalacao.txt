Bem-vindo ao instalador do Limpa DCU.

Este assistente irá preparar a instalação do aplicativo em seu computador, copiando os arquivos principais do sistema, criando os atalhos configurados para a instalação e deixando o ambiente pronto para uso.

O Limpa DCU é uma ferramenta criada para facilitar a limpeza de arquivos DCU em projetos Delphi, principalmente em cenários maiores, onde esse processo manual pode ser repetitivo, demorado e sujeito a falhas.

Durante a instalação, este assistente poderá:

- copiar os arquivos do programa para a pasta escolhida;
- registrar atalhos, se esta opção tiver sido habilitada;
- preparar a estrutura inicial necessária para execução do aplicativo;
- disponibilizar o sistema para uso imediato ao final da instalação.

IMPORTANTE SOBRE TEMAS VISUAIS

Este projeto prioriza primeiro o comportamento do próprio Delphi e do mecanismo nativo de temas da aplicação. Ainda assim, por segurança e por previsibilidade na distribuição, o sistema também suporta arquivos de estilo externos no formato .vsf.

Isso significa que, mesmo que o ambiente de desenvolvimento ou a máquina do usuário tenham diferenças de configuração, o aplicativo pode utilizar explicitamente os estilos esperados quando eles estiverem presentes na pasta apropriada.

Se desejar utilizar os estilos visuais externos, os arquivos podem ser colocados ao lado do executável, dentro da estrutura:

styles\
  Aqua Light Slate.vsf
  Glow.vsf

Essa pasta pode ser usada como uma camada extra de segurança para distribuição, testes, homologação e uso em produção. O mesmo mecanismo também permite que o projeto seja adaptado futuramente para temas customizados, desde que compatíveis com a aplicação.

Caso os arquivos .vsf não estejam presentes, o sistema continuará funcional utilizando o fallback visual definido internamente.

SOBRE O PROJETO

O Limpa DCU é um projeto open-source licenciado sob a MIT License. Isso significa que o código pode ser estudado, utilizado, adaptado e distribuído com bastante liberdade, respeitando os termos básicos da licença.

Se você gostou da proposta do projeto, encontrou algo que possa ser melhorado ou deseja evoluir a ferramenta, considere participar também no repositório oficial. Você pode:

- fazer um fork do projeto;
- sugerir melhorias;
- reportar problemas;
- abrir uma issue;
- enviar um pull request;
- propor novas funcionalidades;
- adaptar o projeto ao seu fluxo de trabalho.

Repositório oficial:
https://github.com/igor-cobra/Limpa-DCU

Este instalador foi preparado para tornar o uso da aplicação mais simples, mas a colaboração da comunidade pode tornar o projeto ainda mais útil e robusto com o tempo.

Antes de prosseguir, confirme se o diretório de instalação está correto e continue com a instalação normalmente.