# 🚀 Laravel Docker Mono

Ambiente de desenvolvimento Laravel completo com Docker, incluindo múltiplos bancos de dados (MySQL, PostgreSQL, MongoDB) e Redis, com mais de 400 comandos Make organizados em módulos.

![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=flat-square&logo=laravel)
![PHP](https://img.shields.io/badge/PHP-8.x-777BB4?style=flat-square&logo=php)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-336791?style=flat-square&logo=postgresql)
![MongoDB](https://img.shields.io/badge/MongoDB-8.0-47A248?style=flat-square&logo=mongodb)
![Redis](https://img.shields.io/badge/Redis-Alpine-DC382D?style=flat-square&logo=redis)

## 📋 Índice

- [Características](#-características)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação Rápida](#-instalação-rápida)
- [Serviços Disponíveis](#-serviços-disponíveis)
- [Comandos Principais](#-comandos-principais)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Módulos Make](#-módulos-make)
- [Uso Diário](#-uso-diário)
- [Bancos de Dados](#-bancos-de-dados)
- [Qualidade de Código](#-qualidade-de-código)
- [Troubleshooting](#-troubleshooting)

## ✨ Características

- 🐳 **Docker Compose** - Ambiente totalmente containerizado
- 🎯 **426+ Comandos Make** - Organizados em 14 módulos especializados
- 🗄️ **Múltiplos Bancos de Dados** - MySQL, PostgreSQL e MongoDB
- ⚡ **Redis** - Cache e sessões
- 📧 **Mailpit** - Teste de emails em desenvolvimento
- 🔍 **Qualidade de Código** - PHPStan, Pint, PHP CS Fixer, PHPMD
- 🧪 **Testes** - PHPUnit e Pest
- 🔀 **Git Integrado** - 54 comandos git via Make
- 🏗️ **Padrões Arquiteturais** - Repository, Service, Action, DTO
- 📦 **Pacotes Laravel** - Telescope, Horizon, Sanctum, Passport, Scout, Livewire

## 📦 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Docker](https://docs.docker.com/get-docker/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (2.0+)
- [Make](https://www.gnu.org/software/make/) (geralmente já vem instalado no Linux/Mac)

### Verificar Instalação

```bash
docker --version
docker compose version
make --version
```

## 🚀 Instalação Rápida

### 1. Clone o Repositório

```bash
git clone <seu-repositorio>
cd laravel-docker-mono
```

### 2. Inicialize o Projeto

```bash
make init-project
```

Este comando irá:
- ✅ Criar estrutura de pastas necessárias
- ✅ Construir e iniciar todos os containers
- ✅ Configurar arquivo `.env` automaticamente
- ✅ Instalar dependências do Composer
- ✅ Gerar chave da aplicação Laravel
- ✅ Executar migrations do banco de dados
- ✅ Configurar storage link

### 3. Acesse a Aplicação

- **Aplicação Laravel**: http://localhost:8080
- **Mailpit (emails)**: http://localhost:32770

## 🐳 Serviços Disponíveis

| Serviço | Container | Porta | Descrição |
|---------|-----------|-------|-----------|
| **PHP** | `setup-laravel-php` | - | PHP 8.x + FPM + Composer |
| **Nginx** | `setup-laravel-nginx` | 8080, 443 | Servidor web |
| **MySQL** | `setup-laravel-mysql` | 3306 | Banco de dados MySQL 8.0 |
| **PostgreSQL** | `setup-laravel-postgres` | 5432 | Banco de dados PostgreSQL 18 |
| **MongoDB** | `setup-laravel-mongodb` | 27017 | Banco de dados MongoDB 8.0 |
| **Redis** | `setup-laravel-redis` | 6379 | Cache e sessões |
| **Mailpit** | `setup-laravel-mailer` | 32770 | Servidor de email para testes |

### Credenciais dos Bancos de Dados

#### MySQL
```
Host: localhost (ou mysql dentro dos containers)
Port: 3306
Database: db_laravel
User: developer
Password: 123456
Root Password: root
```

#### PostgreSQL
```
Host: localhost (ou postgres dentro dos containers)
Port: 5432
Database: db_laravel
User: developer
Password: 123456
```

#### MongoDB
```
Host: localhost (ou mongodb dentro dos containers)
Port: 27017
Database: db_laravel
User: developer
Password: 123456
Auth Database: admin
```

#### Redis
```
Host: localhost (ou redis dentro dos containers)
Port: 6379
```

## 🎯 Comandos Principais

### 📚 Ajuda e Informações

```bash
make help              # Lista todos os comandos disponíveis (426+)
make info              # Mostra informações do ambiente
make status            # Status completo do ambiente
make health            # Health check de todos os serviços
```

### 🐳 Docker - Gerenciamento Básico

```bash
# Iniciar e Parar
make up                # Inicia containers em background
make down              # Para e remove containers
make restart           # Reinicia todos os containers

# Logs e Status
make logs              # Logs de todos containers
make logs-php          # Logs apenas do PHP
make ps                # Status dos containers

# Rebuild
make up-build          # Rebuild e inicia containers
make docker-rebuild    # Rebuild completo sem cache
```

### 💻 Acesso aos Containers

```bash
make bash              # Acessa bash do container PHP
make bash-nginx        # Acessa bash do Nginx
make bash-mysql        # Acessa bash do MySQL
make bash-redis        # Acessa bash do Redis
```

### 🗄️ Banco de Dados

```bash
# Conexões Diretas
make db                # Conecta ao MySQL (root)
make db-dev            # Conecta ao MySQL (developer)
make psql              # Conecta ao PostgreSQL
make mongo             # Conecta ao MongoDB
make redis-cli         # Acessa Redis CLI

# Migrations
make migrate           # Executa migrations pendentes
make migrate-fresh     # Dropa tudo e recria (⚠️ apaga dados)
make migrate-status    # Status das migrations
make migrate-rollback  # Desfaz última migration

# Seeders
make seed              # Executa todos seeders
make seed-class        # Executa seeder específico

# Backup e Restore
make backup-db         # Backup do MySQL
make restore-db        # Restaura backup do MySQL
```

### 🎬 Setup e Instalação

```bash
# Setup Inicial
make setup             # Setup básico do Laravel
make setup-full        # Setup completo com seeders

# Instalação de Dependências
make install           # Instala dependências Composer
make composer-install  # Alias para install
make npm-install       # Instala dependências NPM

# Workflows Rápidos
make quick-start       # Start rápido (up + setup)
make fresh             # Fresh start com seed
make rebuild-all       # Rebuild completo
```

### 🛠️ Desenvolvimento Laravel

```bash
# Criação de Arquivos
make make-controller           # Cria controller
make make-model               # Cria model
make make-model-full          # Model completo (migration, factory, seeder, controller)
make make-migration           # Cria migration
make make-api-resource-full   # API completa (model + controller + resources + requests)

# Ferramentas de Desenvolvimento
make tinker                   # Laravel Tinker (REPL)
make route-list              # Lista todas as rotas
make about                   # Informações da aplicação
make debug                   # Informações de debug
```

### 🏗️ Padrões Arquiteturais

```bash
make make-repository         # Cria repository pattern
make make-service           # Cria service class
make make-action            # Cria action class
make make-dto               # Cria DTO (Data Transfer Object)
make make-module            # Cria estrutura de módulo completa
```

### 🧪 Testes

```bash
make test                  # Executa todos os testes
make test-coverage         # Testes com coverage
make test-parallel         # Testes em paralelo
make test-filter           # Executa teste específico
```

### 🔍 Qualidade de Código

```bash
# Verificação Completa
make quality-check         # Executa todas verificações
make quality-fix           # Corrige problemas automaticamente

# Ferramentas Individuais
make phpstan-analyze       # Análise estática com PHPStan
make pint-fix             # Formata código com Laravel Pint
make phpcs-fix            # Corrige estilo com PHP CS Fixer
make phpmd-analyze        # Detecta problemas com PHPMD

# Instalação de Ferramentas
make quality-install-all  # Instala todas ferramentas de qualidade
```

### 🔀 Git

```bash
# Status e Informações
make git-status           # Status do repositório
make git-log              # Histórico de commits
make git-branch           # Lista branches

# Commit e Push
make git-add              # Adiciona todos arquivos
make git-commit           # Faz commit
make git-quick-push       # Add + commit + push rápido

# Branches
make git-branch-create    # Cria nova branch
make git-branch-switch    # Muda para outra branch

# Mais 50+ comandos git disponíveis!
```

### 🧹 Cache e Otimização

```bash
# Limpeza de Cache
make cache-clear          # Limpa cache da aplicação
make config-clear         # Limpa cache de configuração
make route-clear          # Limpa cache de rotas
make clear-all            # Limpa TODOS os caches

# Otimização
make optimize             # Otimiza aplicação
make production-ready     # Prepara app para produção
```

### 📦 Pacotes Laravel

```bash
# Laravel Telescope (Debug)
make telescope-install    # Instala Telescope
make telescope-clear      # Limpa registros

# Laravel Horizon (Queue Dashboard)
make horizon-install      # Instala Horizon
make horizon              # Inicia Horizon

# Laravel Sanctum (API Auth)
make sanctum-install      # Instala Sanctum

# Laravel Passport (OAuth2)
make passport-install     # Instala Passport

# Laravel Scout (Search)
make scout-install        # Instala Scout

# Laravel Livewire
make livewire-install     # Instala Livewire
make livewire-make        # Cria componente Livewire
```

### 🔄 Queue e Schedule

```bash
# Queue
make queue-work           # Processa filas
make queue-failed         # Lista jobs falhados
make queue-retry          # Reprocessa jobs falhados

# Schedule
make schedule-run         # Executa schedule uma vez
make schedule-list        # Lista comandos agendados
```

## 📁 Estrutura do Projeto

```
laravel-docker-mono/
├── backend/                    # Aplicação Laravel
│   ├── app/                   # Código da aplicação
│   ├── config/                # Configurações
│   ├── database/              # Migrations, seeders, factories
│   ├── routes/                # Rotas da aplicação
│   ├── storage/               # Storage e logs
│   └── tests/                 # Testes automatizados
├── docker/                     # Configurações Docker
│   ├── mysql/                 # Configurações MySQL
│   ├── nginx/                 # Configurações Nginx
│   ├── php/                   # Dockerfile e configurações PHP
│   └── postgres/              # Configurações PostgreSQL
├── makefiles/                  # Módulos Make organizados
│   ├── Makefile.docker        # Comandos Docker básicos
│   ├── Makefile.laravel       # Comandos Laravel
│   ├── Makefile.database      # Comandos de banco de dados
│   ├── Makefile.git           # Comandos Git
│   ├── Makefile.quality       # Qualidade de código
│   └── ... (14 módulos total)
├── backups/                    # Backups dos bancos de dados
├── docker-compose.yml          # Configuração dos serviços
├── Makefile                    # Makefile principal
└── README.md                   # Este arquivo
```

## 📚 Módulos Make

O projeto possui **14 módulos Make** com **426+ comandos** organizados:

| Módulo | Comandos | Descrição |
|--------|----------|-----------|
| `Makefile.docker` | 22 | Docker Compose básico (up, down, restart) |
| `Makefile.docker-advanced` | 53 | Gerenciamento avançado (volumes, networks, images) |
| `Makefile.laravel` | 11 | Desenvolvimento Laravel (tinker, routes, about) |
| `Makefile.laravel-make` | 36 | Criação de arquivos Laravel |
| `Makefile.architecture` | 13 | Padrões arquiteturais (Repository, Service, DTO) |
| `Makefile.database` | 19 | Banco de dados, migrations, backups |
| `Makefile.git` | 54 | Controle de versão Git |
| `Makefile.packages` | 38 | Pacotes Laravel (Telescope, Horizon, etc) |
| `Makefile.queue` | 23 | Filas e agendamentos |
| `Makefile.tests` | 6 | Testes automatizados |
| `Makefile.maintenance` | 37 | Cache, logs, manutenção |
| `Makefile.setup` | 29 | Setup e workflows |
| `Makefile.utils` | 49 | Composer, NPM, debug, análise |
| `Makefile.quality` | 35 | Qualidade de código (PHPStan, Pint, etc) |

Execute `make help` para ver todos os comandos disponíveis!

## 🎯 Uso Diário

### Rotina Diária de Início

```bash
make daily-start
```

Este comando:
1. Inicia todos os containers
2. Verifica saúde dos serviços
3. Mostra status das migrations
4. Prepara ambiente para trabalhar

### Antes de Fazer Commit

```bash
make before-commit
```

Este comando executa:
1. Todos os testes
2. Validação de código (PHPStan, PHP CS Fixer)
3. Verificação de migrations

### Deploy para Produção

```bash
make deploy-production
```

Workflow completo:
1. Executa testes
2. Faz backup do banco
3. Atualiza dependências
4. Executa migrations
5. Otimiza aplicação
6. Reinicia serviços

## 🗄️ Bancos de Dados

### Escolhendo o Banco de Dados

Configure no arquivo `.env`:

#### Para MySQL (padrão):
```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=db_laravel
DB_USERNAME=developer
DB_PASSWORD=123456
```

#### Para PostgreSQL:
```env
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=db_laravel
DB_USERNAME=developer
DB_PASSWORD=123456
```

#### Para MongoDB:
```env
# Requer pacote adicional: mongodb/laravel-mongodb
DB_CONNECTION=mongodb
DB_HOST=mongodb
DB_PORT=27017
DB_DATABASE=db_laravel
DB_USERNAME=developer
DB_PASSWORD=123456
DB_AUTHENTICATION_DATABASE=admin
```

### Comandos Específicos por Banco

#### PostgreSQL
```bash
make psql                    # Conecta ao PostgreSQL
make psql-list-databases    # Lista todos bancos
make psql-list-tables       # Lista todas tabelas
make backup-postgres        # Backup do PostgreSQL
make restore-postgres       # Restaura backup do PostgreSQL
```

#### MongoDB
```bash
make mongo                  # Conecta ao MongoDB
make mongo-shell           # MongoDB shell interativo
```

## 🔍 Qualidade de Código

### Instalando Ferramentas de Qualidade

```bash
make quality-install-all
```

Instala:
- ✅ PHP Insights
- ✅ PHPStan
- ✅ PHP CS Fixer
- ✅ Laravel Pint
- ✅ PHPMD
- ✅ phploc

### Verificação Completa

```bash
make quality-check
```

Executa:
1. Todos os testes
2. Verificação de estilo
3. Análise estática (PHPStan)
4. Verificação de vulnerabilidades
5. Métricas de código

### Correção Automática

```bash
make quality-fix
```

Corrige automaticamente:
- Estilo de código (PHP CS Fixer)
- Formatação (Laravel Pint)
- Problemas detectáveis (PHP Insights)

## 🐛 Troubleshooting

### Container não inicia

```bash
# Ver logs do container
make logs-php
make logs-nginx
make logs-mysql

# Verificar status
make ps

# Rebuild completo
make docker-rebuild
```

### Problemas de Permissão

```bash
# Corrigir permissões
make permissions
make fix-permissions-auto
```

### Limpar Tudo e Começar do Zero

```bash
# Reset completo (⚠️ APAGA DADOS!)
make reset-hard

# Ou mais controlado
make down-volumes    # Para e remove volumes
make up-build        # Rebuild e inicia
make setup-full      # Setup completo
```

### Verificar Ambiente

```bash
make verify-environment    # Verifica Docker, Compose, arquivos
make validate-containers   # Valida configuração dos containers
make container-health-check  # Health check individual
```

### Problemas com Banco de Dados

```bash
# MySQL
make db-show              # Mostra informações do banco
make db-monitor           # Monitora conexões

# Ver logs
make logs-mysql
make logs-mysql-error
```

### Cache Preso

```bash
make clear-all           # Limpa todos os caches
make optimize-clear      # Remove otimizações
make clean               # Limpa arquivos temporários
```

## 📊 Informações Adicionais

### Volumes Docker

Os seguintes volumes são criados automaticamente:

- `mysql_data` - Dados do MySQL
- `postgres_data` - Dados do PostgreSQL
- `mongodb_data` - Dados do MongoDB
- `mongodb_config` - Configurações do MongoDB
- `redis_data` - Dados do Redis

### Backups

Backups são salvos automaticamente na pasta `backups/`:

```bash
make backup-db           # Cria backup com timestamp
make restore-db          # Lista e restaura backups
```

### Monitoramento

```bash
make docker-stats        # Uso de recursos dos containers
make docker-stats-live   # Monitoramento em tempo real
make docker-disk         # Uso de disco do Docker
```

### Limpeza Docker

```bash
make docker-clean        # Limpeza geral
make docker-clean-all    # Limpeza completa (⚠️ cuidado!)
make prune               # Remove recursos não utilizados
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:

1. Fazer fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abrir um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT.

## 🙏 Agradecimentos

- [Laravel](https://laravel.com/)
- [Docker](https://www.docker.com/)
- [Mailpit](https://github.com/axllent/mailpit)

---

<div align="center">

**[⬆ Voltar ao topo](#-laravel-docker-mono)**

Feito com ❤️ para a comunidade Laravel

</div>

