# ES-PI3-2026-T3-G17

<p align="center">
  <img src="/assets/images/logoMesclaInvest.png" alt="Logo MesclaInvest" width=450>
</p>

## Sobre o Projeto
O **MesclaInvest** é uma plataforma mobile desenvolvida no contexto da disciplina de Projeto Integrador 3 da PUC-Campinas. O objetivo do sistema é simular um ambiente digital de investimentos em startups vinculadas ao ecossistema de inovação Mescla, permitindo que usuários explorem projetos, acompanhem informações institucionais e interajam com os empreendedores. A aplicação busca aproximar a universidade da sociedade, promovendo maior visibilidade às iniciativas empreendedoras desenvolvidas por estudantes.

A plataforma também simula a negociação de participações digitais representadas por tokens. Por meio do aplicativo, os usuários poderão visualizar startups cadastradas, acessar documentos e informações relevantes, enviar perguntas aos fundadores e participar de um ambiente de compra e venda simulada de tokens. O foco do projeto está na construção da arquitetura de software, integração entre backend e aplicativo mobile, e no desenvolvimento de funcionalidades que reproduzam, de forma acadêmica e simulada, a dinâmica de plataformas de investimento.

O desenvolvimento do MesclaInvest utiliza um conjunto de tecnologias modernas voltadas para aplicações móveis e sistemas distribuídos. O frontend do aplicativo é desenvolvido com Flutter, utilizando a linguagem Dart, permitindo a criação de uma interface mobile moderna, responsiva e multiplataforma.

O backend da aplicação é construído com Node.js, utilizando JavaScript/TypeScript para implementação das regras de negócio e disponibilização de APIs responsáveis pela comunicação com o aplicativo mobile. Para armazenamento e gerenciamento dos dados da aplicação, é utilizado o Firebase Firestore, um banco de dados NoSQL em nuvem que permite armazenamento flexível e escalável das informações do sistema.

Além disso, o projeto utiliza Git para controle de versão do código e GitHub como plataforma de hospedagem do repositório, possibilitando o trabalho colaborativo da equipe, gerenciamento de branches e acompanhamento do progresso do desenvolvimento.

## Integrantes do Time 17
* [Beatriz Naomi Ferreira Sasaki](https://github.com/beatrizsasaki1114) : 25016735
* [Bruno Lenitta Machado](https://github.com/BrunoM2422) : 25008041
* [Heloisa Lacerda Marinho](https://github.com/loisaaz) : 25893868
* [Luca Francesco Filippi](https://github.com/LucaFilippi) : 25022556
* [Sofia de Sousa](https://github.com/1SofiaSousa) : 25005435

## Tecnologias Utilizadas
- Flutter
- Linguagem Dart
-  TypeScript
-  Cloud Firestore
  
## Pré-requisitos
Antes de executar o projeto, certifique-se ter instalado:
- **Node.js** 
  [Baixar aqui](https://nodejs.org/)
- **Java JDK**
  [Baixar aqui](https://adoptium.net/pt-BR/temurin/releases?version=21&os=any&arch=any)
- **Flutter SDK**
  [Baixar aqui](https://docs.flutter.dev/install)

## Como executar o projeto
Para executar e testar o ecossistema completo localmente, siga em ordem as intruções abaixo:

No terminal
1. Download de dependências e configurações do projeto.
```bash
flutter pub get
```
2. Verifique se as dependências do Flutter estão ok
```bash
flutter doctor
```
3. Acesse a pasta **ES-PI3-2026-T3-G17**
```bash
cd ES-PI3-2026-T3-G17
```
4. Acesse a diretório das funções
```bash
cd functions
```
5. Instale as dependências do projeto
```bash
npm install
```
6. Compile o código TypeScript para JavaScript:
```bash
npm run build
```
7. Iniciar a depuração da aplicação
```bash
flutter run
```
