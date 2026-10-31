# 🌱 Agricultura Urbana Bauru

**Informação agrícola acessível à sociedade.**

## 📌 Sobre o projeto

O projeto **Agricultura Urbana Bauru** tem como objetivo centralizar, organizar e disponibilizar informações públicas relacionadas à agricultura urbana e rural no município de Bauru e região.

A proposta consiste em transformar diferentes conjuntos de dados públicos em uma estrutura organizada de banco de dados, permitindo reunir informações sobre produtores, hortas comunitárias, feiras municipais, iniciativas públicas, serviços de apoio à agricultura e atividades de turismo rural.

Por meio dessa centralização, busca-se facilitar o acesso da população às informações, incentivar a valorização dos produtores locais, divulgar iniciativas sustentáveis e aproximar a sociedade das atividades relacionadas à agricultura no município.

## 🎯 Objetivos

- Centralizar informações públicas relacionadas à agricultura urbana e rural.
- Facilitar a consulta e a localização de produtores, hortas e iniciativas municipais.
- Organizar diferentes conjuntos de dados em uma estrutura relacional padronizada.
- Promover o acesso à informação e a valorização da produção local.
- Aplicar conceitos de modelagem, desenvolvimento e administração de bancos de dados.
- Desenvolver uma estrutura preparada para integração com uma aplicação de consulta e gerenciamento de informações.

## 🌿 Abrangência dos dados

O banco de dados contempla sete categorias principais:

| Categoria | Descrição |
|---|---|
| Agricultores | Informações sobre produtores rurais e suas atividades. |
| Hortas Urbanas | Cadastro de hortas e iniciativas de cultivo urbano. |
| Feiras Municipais | Informações sobre feiras e pontos de comercialização. |
| Atrativos Turísticos | Locais e atividades relacionados ao turismo rural. |
| Serviços para Agricultura | Serviços de apoio e assistência ao setor agrícola. |
| Iniciativas Públicas | Programas, campanhas e ações de incentivo à agricultura. |
| Vivência Rural | Experiências e atividades relacionadas ao ambiente rural. |

Além das informações cadastrais, a estrutura contempla dados complementares, como localizações geográficas, atividades desenvolvidas, certificações, organizações, pontos de venda, qualificações e redes sociais.

## 🗄️ Tecnologias utilizadas

- **Oracle Database 21c XE:** Sistema gerenciador de banco de dados relacional.
- **SQL:** Linguagem utilizada para definição, manipulação e consulta dos dados.
- **PL/SQL:** Desenvolvimento da lógica de negócio, procedimentos armazenados, funções e triggers.
- **JSON:** Formato utilizado na comunicação e transferência de dados entre a aplicação e o banco.
- **Oracle Spatial:** Utilização de estruturas `SDO_GEOMETRY` para armazenamento de informações geográficas.

## ⚙️ Desenvolvimento do banco de dados

O projeto utiliza uma arquitetura baseada em procedimentos armazenados, concentrando as principais operações de cadastro e validação diretamente no banco de dados.

Entre os recursos implementados, destacam-se:

- Modelagem relacional e definição de relacionamentos entre entidades.
- Procedures para inserção e gerenciamento de registros.
- Utilização de JSON para recebimento e processamento de informações.
- Validações de dados realizadas no banco de dados.
- Triggers para automatização de operações e registro de alterações.
- Functions e consultas SQL para recuperação e organização das informações.
- Utilização de sequences para geração de identificadores.
- Armazenamento de coordenadas geográficas por meio de tipos espaciais.

A centralização das regras de negócio em PL/SQL busca manter a consistência das operações e reduzir a dependência de validações realizadas exclusivamente pela aplicação.

## 🔐 Segurança e integridade

A segurança do banco de dados foi planejada considerando a separação de responsabilidades e o princípio do menor privilégio.

Entre as medidas adotadas estão:

- Separação entre o schema proprietário dos objetos e o usuário de conexão da aplicação.
- Criação de roles específicas para administração e utilização da aplicação.
- Concessão controlada de privilégios de acesso e execução de procedures.
- Registro de operações por meio de triggers e tabela de auditoria.

## 💾 Estratégia de backup e recuperação

Para garantir a disponibilidade e a recuperação das informações, foram considerados dois mecanismos complementares de backup:

**RMAN (Recovery Manager)**

Responsável pela realização de backups físicos do banco de dados, permitindo a recuperação de arquivos e estruturas necessárias para restaurar o ambiente Oracle.

**Data Pump (EXPDP)**

Responsável pela exportação lógica dos schemas e seus respectivos objetos e dados, permitindo a recuperação seletiva de informações e facilitando a migração entre ambientes.

A combinação dessas ferramentas proporciona uma estratégia de proteção adequada à dimensão do projeto.

## 🗺️ Abrangência geográfica

O projeto considera Bauru e municípios da região, contemplando os seguintes municípios:

- Agudos
- Arealva
- Avaí
- Bauru
- Pederneiras
- Piratininga
- Reginópolis

As informações geográficas também permitem organizar os registros por zonas de localização do município, facilitando a identificação e a consulta das iniciativas cadastradas.

## 📚 Finalidade acadêmica e social

Além de sua finalidade tecnológica, o projeto busca demonstrar como a organização e a integração de dados públicos podem contribuir para a democratização da informação.

A proposta é utilizar a tecnologia como instrumento de valorização da agricultura local, incentivo à sustentabilidade e aproximação entre produtores, iniciativas públicas e sociedade.

O desenvolvimento também proporciona a aplicação prática de conhecimentos relacionados à modelagem de dados, SQL, PL/SQL, administração de banco de dados, segurança da informação, auditoria e recuperação de dados.

## 👨‍💻 Autor

**João Pedro Faria**

Projeto desenvolvido com foco na aplicação prática de conceitos de Banco de Dados e na transformação de informações públicas em conhecimento acessível à sociedade.