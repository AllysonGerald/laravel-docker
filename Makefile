.PHONY: help

# Cores para output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

##@ 🎯 Ajuda

help: ## Mostra esta mensagem de ajuda
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)  🚀 Laravel Docker - Comandos Disponíveis$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(YELLOW)%-25s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

##@ 🐳 Docker Compose

up: ## Inicia os containers em background
	@echo "$(GREEN)🚀 Iniciando containers...$(NC)"
	docker compose up -d

up-build: ## Rebuild e inicia os containers
	@echo "$(GREEN)🔨 Rebuilding e iniciando containers...$(NC)"
	docker compose up -d --build

down: ## Para e remove os containers
	@echo "$(RED)🛑 Parando containers...$(NC)"
	docker compose down

down-volumes: ## Para containers e remove volumes (⚠️ APAGA DADOS!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso vai apagar todos os dados!$(NC)"
	@read -p "Tem certeza? [s/N]: " confirm; \
	if [ "$$confirm" = "s" ] || [ "$$confirm" = "S" ]; then \
		docker compose down -v; \
	else \
		echo "Cancelado."; \
	fi

restart: ## Reinicia todos os containers
	@echo "$(YELLOW)🔄 Reiniciando containers...$(NC)"
	docker compose restart

restart-php: ## Reinicia apenas o container PHP
	@echo "$(YELLOW)🔄 Reiniciando PHP...$(NC)"
	docker compose restart php

restart-nginx: ## Reinicia apenas o container Nginx
	@echo "$(YELLOW)🔄 Reiniciando Nginx...$(NC)"
	docker compose restart nginx

restart-mysql: ## Reinicia apenas o container MySQL
	@echo "$(YELLOW)🔄 Reiniciando MySQL...$(NC)"
	docker compose restart mysql

restart-redis: ## Reinicia apenas o container Redis
	@echo "$(YELLOW)🔄 Reiniciando Redis...$(NC)"
	docker compose restart redis

ps: ## Lista status dos containers
	docker compose ps

logs: ## Mostra logs de todos os containers
	docker compose logs -f

logs-php: ## Mostra logs do container PHP
	docker compose logs -f php

logs-nginx: ## Mostra logs do container Nginx
	docker compose logs -f nginx

logs-mysql: ## Mostra logs do container MySQL
	docker compose logs -f mysql

logs-redis: ## Mostra logs do container Redis
	docker compose logs -f redis

##@ 💻 Acesso aos Containers

bash: ## Acessa bash do container PHP
	docker compose exec php bash

bash-nginx: ## Acessa bash do container Nginx
	docker compose exec nginx sh

bash-mysql: ## Acessa bash do container MySQL
	docker compose exec mysql bash

bash-redis: ## Acessa bash do container Redis
	docker compose exec redis sh

db: ## Conecta ao MySQL (root)
	docker compose exec mysql mysql -u root -proot

db-dev: ## Conecta ao MySQL (developer)
	docker compose exec mysql mysql -u developer -p123456 db_laravel

redis-cli: ## Acessa Redis CLI
	docker compose exec redis redis-cli

##@ 🎬 Setup & Instalação

setup: ## Setup inicial completo do projeto
	@echo "$(GREEN)🎬 Configurando projeto Laravel...$(NC)"
	@echo "$(YELLOW)📋 1/5 Copiando .env...$(NC)"
	cp --update=none backend/.env.example backend/.env
	@echo "$(YELLOW)📦 2/5 Instalando dependências Composer...$(NC)"
	docker compose exec php composer install
	@echo "$(YELLOW)🔑 3/5 Gerando chave da aplicação...$(NC)"
	docker compose exec php php artisan key:generate
	@echo "$(YELLOW)🗄️  4/5 Executando migrations...$(NC)"
	docker compose exec php php artisan migrate
	@echo "$(YELLOW)🔗 5/5 Criando link de storage...$(NC)"
	docker compose exec php php artisan storage:link
	@echo "$(GREEN)✅ Setup concluído!$(NC)"

setup-full: ## Setup completo com seed
	@echo "$(GREEN)🎬 Setup completo com seed...$(NC)"
	$(MAKE) setup
	@echo "$(YELLOW)🌱 Executando seeders...$(NC)"
	docker compose exec php php artisan db:seed
	@echo "$(GREEN)✅ Setup completo concluído!$(NC)"

install: ## Apenas instala dependências Composer
	@echo "$(YELLOW)📦 Instalando dependências...$(NC)"
	docker compose exec php composer install

install-dev: ## Instala dependências de desenvolvimento
	@echo "$(YELLOW)📦 Instalando dependências de dev...$(NC)"
	docker compose exec php composer install --dev

update: ## Atualiza dependências Composer
	@echo "$(YELLOW)⬆️  Atualizando dependências...$(NC)"
	docker compose exec php composer update

##@ 🗄️ Banco de Dados - Migrations

migrate: ## Executa migrations pendentes
	@echo "$(GREEN)🗄️  Executando migrations...$(NC)"
	docker compose exec php php artisan migrate

migrate-fresh: ## Dropa tudo e recria (⚠️ APAGA DADOS!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso vai apagar todos os dados!$(NC)"
	@read -p "Tem certeza? [s/N]: " confirm; \
	if [ "$$confirm" = "s" ] || [ "$$confirm" = "S" ]; then \
		docker compose exec php php artisan migrate:fresh; \
	else \
		echo "Cancelado."; \
	fi

migrate-fresh-seed: ## Dropa, recria e popula o banco
	@echo "$(RED)⚠️  ATENÇÃO: Isso vai apagar todos os dados!$(NC)"
	@read -p "Tem certeza? [s/N]: " confirm; \
	if [ "$$confirm" = "s" ] || [ "$$confirm" = "S" ]; then \
		docker compose exec php php artisan migrate:fresh --seed; \
	else \
		echo "Cancelado."; \
	fi

migrate-refresh: ## Rollback e re-executa todas migrations
	docker compose exec php php artisan migrate:refresh

migrate-refresh-seed: ## Rollback, re-executa e popula
	docker compose exec php php artisan migrate:refresh --seed

migrate-rollback: ## Desfaz última migração
	docker compose exec php php artisan migrate:rollback

migrate-rollback-step: ## Desfaz N migrações
	@read -p "Quantos steps desfazer? " steps; \
	docker compose exec php php artisan migrate:rollback --step=$$steps

migrate-reset: ## Desfaz todas as migrações
	docker compose exec php php artisan migrate:reset

migrate-status: ## Mostra status das migrations
	docker compose exec php php artisan migrate:status

##@ 🗄️ Banco de Dados - Operações

db-show: ## Mostra informações do banco
	docker compose exec php php artisan db:show

db-table: ## Mostra estrutura de uma tabela
	@read -p "Nome da tabela: " table; \
	docker compose exec php php artisan db:table $$table

db-monitor: ## Monitora conexões do banco
	docker compose exec php php artisan db:monitor

db-wipe: ## Limpa todas as tabelas (⚠️ APAGA DADOS!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso vai apagar todos os dados!$(NC)"
	@read -p "Tem certeza? [s/N]: " confirm; \
	if [ "$$confirm" = "s" ] || [ "$$confirm" = "S" ]; then \
		docker compose exec php php artisan db:wipe; \
	else \
		echo "Cancelado."; \
	fi

seed: ## Executa todos os seeders
	@echo "$(GREEN)🌱 Executando seeders...$(NC)"
	docker compose exec php php artisan db:seed

seed-class: ## Executa um seeder específico
	@read -p "Nome do seeder: " seeder; \
	docker compose exec php php artisan db:seed --class=$$seeder

##@ 💾 Backup & Restore

backup-db: ## Faz backup do banco de dados
	@echo "$(GREEN)💾 Criando backup do banco...$(NC)"
	@mkdir -p backups
	@timestamp=$$(date +%Y%m%d_%H%M%S); \
	docker compose exec mysql mysqldump -u root -proot db_laravel > backups/db_backup_$$timestamp.sql && \
	echo "$(GREEN)✅ Backup salvo em: backups/db_backup_$$timestamp.sql$(NC)"

restore-db: ## Restaura backup do banco
	@echo "$(YELLOW)Arquivos disponíveis em backups/:$(NC)"
	@ls -lh backups/*.sql 2>/dev/null || echo "Nenhum backup encontrado"
	@read -p "Nome do arquivo (sem o path): " file; \
	if [ -f "backups/$$file" ]; then \
		echo "$(YELLOW)Restaurando backup...$(NC)"; \
		docker compose exec -T mysql mysql -u root -proot db_laravel < backups/$$file && \
		echo "$(GREEN)✅ Backup restaurado!$(NC)"; \
	else \
		echo "$(RED)❌ Arquivo não encontrado!$(NC)"; \
	fi

##@ 🧹 Cache & Otimização

cache-clear: ## Limpa cache da aplicação
	docker compose exec php php artisan cache:clear

config-clear: ## Limpa cache de configuração
	docker compose exec php php artisan config:clear

route-clear: ## Limpa cache de rotas
	docker compose exec php php artisan route:clear

view-clear: ## Limpa cache de views
	docker compose exec php php artisan view:clear

event-clear: ## Limpa cache de eventos
	docker compose exec php php artisan event:clear

clear-all: ## Limpa TODOS os caches
	@echo "$(GREEN)🧹 Limpando todos os caches...$(NC)"
	docker compose exec php php artisan optimize:clear
	docker compose exec php php artisan cache:clear
	docker compose exec php php artisan config:clear
	docker compose exec php php artisan route:clear
	docker compose exec php php artisan view:clear
	docker compose exec php php artisan event:clear
	@echo "$(GREEN)✅ Todos os caches limpos!$(NC)"

optimize: ## Otimiza aplicação (produção)
	@echo "$(GREEN)⚡ Otimizando aplicação...$(NC)"
	docker compose exec php php artisan optimize

optimize-clear: ## Remove todas otimizações
	docker compose exec php php artisan optimize:clear

config-cache: ## Cria cache de configuração
	docker compose exec php php artisan config:cache

route-cache: ## Cria cache de rotas
	docker compose exec php php artisan route:cache

event-cache: ## Cria cache de eventos
	docker compose exec php php artisan event:cache

production-ready: ## Prepara app para produção
	@echo "$(GREEN)🚀 Preparando para produção...$(NC)"
	docker compose exec php php artisan config:cache
	docker compose exec php php artisan route:cache
	docker compose exec php php artisan view:cache
	docker compose exec php php artisan event:cache
	docker compose exec php php artisan optimize
	@echo "$(GREEN)✅ Aplicação otimizada para produção!$(NC)"

##@ 🔑 Chaves & Segurança

key-generate: ## Gera nova chave da aplicação
	docker compose exec php php artisan key:generate

storage-link: ## Cria link simbólico de storage
	docker compose exec php php artisan storage:link

permissions: ## Corrige permissões do Laravel
	@echo "$(YELLOW)🔐 Corrigindo permissões...$(NC)"
	docker compose exec php chmod -R 775 storage bootstrap/cache
	docker compose exec php chown -R www-data:www-data storage bootstrap/cache
	@echo "$(GREEN)✅ Permissões corrigidas!$(NC)"

##@ 📋 Desenvolvimento

tinker: ## Abre Laravel Tinker (REPL)
	docker compose exec php php artisan tinker

route-list: ## Lista todas as rotas
	docker compose exec php php artisan route:list

route-list-full: ## Lista rotas com detalhes completos
	docker compose exec php php artisan route:list --columns=uri,name,action,middleware

about: ## Mostra informações sobre a aplicação
	docker compose exec php php artisan about

inspire: ## Mensagem inspiradora
	docker compose exec php php artisan inspire

serve: ## Servidor de desenvolvimento PHP
	docker compose exec php php artisan serve --host=0.0.0.0 --port=8000

##@ 🧪 Testes

test: ## Executa todos os testes
	@echo "$(GREEN)🧪 Executando testes...$(NC)"
	docker compose exec php php artisan test

test-coverage: ## Executa testes com coverage
	docker compose exec php php artisan test --coverage

test-parallel: ## Executa testes em paralelo
	docker compose exec php php artisan test --parallel

test-filter: ## Executa teste específico
	@read -p "Filtro de teste: " filter; \
	docker compose exec php php artisan test --filter=$$filter

pest: ## Executa Pest tests
	docker compose exec php ./vendor/bin/pest

phpunit: ## Executa PHPUnit
	docker compose exec php ./vendor/bin/phpunit

##@ 📦 Composer

composer-install: ## Instala dependências
	docker compose exec php composer install

composer-update: ## Atualiza dependências
	docker compose exec php composer update

composer-require: ## Adiciona novo pacote
	@read -p "Nome do pacote: " package; \
	docker compose exec php composer require $$package

composer-require-dev: ## Adiciona pacote de dev
	@read -p "Nome do pacote: " package; \
	docker compose exec php composer require --dev $$package

composer-remove: ## Remove pacote
	@read -p "Nome do pacote: " package; \
	docker compose exec php composer remove $$package

composer-dump: ## Regenera autoload
	docker compose exec php composer dump-autoload

composer-validate: ## Valida composer.json
	docker compose exec php composer validate

composer-outdated: ## Mostra pacotes desatualizados
	docker compose exec php composer outdated

composer-show: ## Mostra todos os pacotes instalados
	docker compose exec php composer show

##@ 📦 NPM / Node (se houver frontend)

npm-install: ## Instala dependências NPM
	docker compose exec php npm install

npm-dev: ## Build de desenvolvimento
	docker compose exec php npm run dev

npm-watch: ## Watch de desenvolvimento
	docker compose exec php npm run watch

npm-build: ## Build de produção
	docker compose exec php npm run build

npm-update: ## Atualiza dependências NPM
	docker compose exec php npm update

npm-outdated: ## Mostra pacotes NPM desatualizados
	docker compose exec php npm outdated

##@ 🔄 Queue (Filas)

queue-work: ## Processa filas
	docker compose exec php php artisan queue:work

queue-work-daemon: ## Processa filas em background
	docker compose exec -d php php artisan queue:work

queue-listen: ## Escuta filas
	docker compose exec php php artisan queue:listen

queue-restart: ## Reinicia workers
	docker compose exec php php artisan queue:restart

queue-retry: ## Reprocessa jobs falhados
	docker compose exec php php artisan queue:retry all

queue-retry-id: ## Reprocessa job específico
	@read -p "ID do job: " id; \
	docker compose exec php php artisan queue:retry $$id

queue-flush: ## Limpa jobs falhados
	docker compose exec php php artisan queue:flush

queue-failed: ## Lista jobs falhados
	docker compose exec php php artisan queue:failed

queue-monitor: ## Monitora filas
	docker compose exec php php artisan queue:monitor

queue-table: ## Cria tabela de jobs
	docker compose exec php php artisan queue:table
	docker compose exec php php artisan migrate

queue-failed-table: ## Cria tabela de jobs falhados
	docker compose exec php php artisan queue:failed-table
	docker compose exec php php artisan migrate

queue-batches-table: ## Cria tabela de batches
	docker compose exec php php artisan queue:batches-table
	docker compose exec php php artisan migrate

##@ ⏰ Schedule (Agendamentos)

schedule-run: ## Executa schedule uma vez
	docker compose exec php php artisan schedule:run

schedule-work: ## Executa schedule continuamente
	docker compose exec php php artisan schedule:work

schedule-list: ## Lista comandos agendados
	docker compose exec php php artisan schedule:list

schedule-test: ## Testa schedule
	docker compose exec php php artisan schedule:test

##@ 🛠️ Criação de Arquivos (Make)

make-controller: ## Cria controller
	@read -p "Nome do controller: " name; \
	docker compose exec php php artisan make:controller $$name

make-controller-resource: ## Cria resource controller
	@read -p "Nome do controller: " name; \
	docker compose exec php php artisan make:controller $$name --resource

make-controller-api: ## Cria API controller
	@read -p "Nome do controller: " name; \
	docker compose exec php php artisan make:controller $$name --api

make-model: ## Cria model
	@read -p "Nome do model: " name; \
	docker compose exec php php artisan make:model $$name

make-model-full: ## Cria model completo (migration, factory, seeder, controller)
	@read -p "Nome do model: " name; \
	docker compose exec php php artisan make:model $$name -mfsc

make-model-all: ## Cria model com tudo
	@read -p "Nome do model: " name; \
	docker compose exec php php artisan make:model $$name --all

make-migration: ## Cria migration
	@read -p "Nome da migration: " name; \
	docker compose exec php php artisan make:migration $$name

make-seeder: ## Cria seeder
	@read -p "Nome do seeder: " name; \
	docker compose exec php php artisan make:seeder $$name

make-factory: ## Cria factory
	@read -p "Nome da factory: " name; \
	docker compose exec php php artisan make:factory $$name

make-middleware: ## Cria middleware
	@read -p "Nome do middleware: " name; \
	docker compose exec php php artisan make:middleware $$name

make-request: ## Cria form request
	@read -p "Nome do request: " name; \
	docker compose exec php php artisan make:request $$name

make-resource: ## Cria API resource
	@read -p "Nome do resource: " name; \
	docker compose exec php php artisan make:resource $$name

make-policy: ## Cria policy
	@read -p "Nome da policy: " name; \
	docker compose exec php php artisan make:policy $$name

make-rule: ## Cria validation rule
	@read -p "Nome da rule: " name; \
	docker compose exec php php artisan make:rule $$name

make-job: ## Cria job
	@read -p "Nome do job: " name; \
	docker compose exec php php artisan make:job $$name

make-event: ## Cria event
	@read -p "Nome do event: " name; \
	docker compose exec php php artisan make:event $$name

make-listener: ## Cria listener
	@read -p "Nome do listener: " name; \
	docker compose exec php php artisan make:listener $$name

make-mail: ## Cria mailable
	@read -p "Nome do mail: " name; \
	docker compose exec php php artisan make:mail $$name

make-notification: ## Cria notification
	@read -p "Nome da notification: " name; \
	docker compose exec php php artisan make:notification $$name

make-observer: ## Cria observer
	@read -p "Nome do observer: " name; \
	docker compose exec php php artisan make:observer $$name

make-provider: ## Cria service provider
	@read -p "Nome do provider: " name; \
	docker compose exec php php artisan make:provider $$name

make-command: ## Cria artisan command
	@read -p "Nome do command: " name; \
	docker compose exec php php artisan make:command $$name

make-test: ## Cria test
	@read -p "Nome do test: " name; \
	docker compose exec php php artisan make:test $$name

make-test-unit: ## Cria unit test
	@read -p "Nome do test: " name; \
	docker compose exec php php artisan make:test $$name --unit

make-component: ## Cria Blade component
	@read -p "Nome do component: " name; \
	docker compose exec php php artisan make:component $$name

make-cast: ## Cria custom cast
	@read -p "Nome do cast: " name; \
	docker compose exec php php artisan make:cast $$name

make-channel: ## Cria broadcast channel
	@read -p "Nome do channel: " name; \
	docker compose exec php php artisan make:channel $$name

make-exception: ## Cria exception
	@read -p "Nome da exception: " name; \
	docker compose exec php php artisan make:exception $$name

##@ 📊 Logs & Monitoramento

logs-laravel: ## Tail logs do Laravel
	docker compose exec php tail -f storage/logs/laravel.log

logs-laravel-clear: ## Limpa logs do Laravel
	docker compose exec php sh -c "> storage/logs/laravel.log"
	@echo "$(GREEN)✅ Logs limpos!$(NC)"

logs-mysql-error: ## Mostra error log do MySQL
	docker compose exec mysql tail -f /var/log/mysql/error.log

logs-mysql-general: ## Mostra general log do MySQL
	docker compose exec mysql tail -f /var/lib/mysql/general.log

logs-nginx-access: ## Mostra access log do Nginx
	docker compose exec nginx tail -f /var/log/nginx/access.log

logs-nginx-error: ## Mostra error log do Nginx
	docker compose exec nginx tail -f /var/log/nginx/error.log

##@ 🔧 Manutenção

maintenance-on: ## Ativa modo de manutenção
	@echo "$(YELLOW)🚧 Ativando modo de manutenção...$(NC)"
	docker compose exec php php artisan down
	@echo "$(GREEN)✅ Modo de manutenção ativado!$(NC)"

maintenance-off: ## Desativa modo de manutenção
	@echo "$(GREEN)✅ Desativando modo de manutenção...$(NC)"
	docker compose exec php php artisan up
	@echo "$(GREEN)✅ Aplicação disponível novamente!$(NC)"

maintenance-secret: ## Ativa manutenção com secret
	@read -p "Secret (token para bypass): " secret; \
	docker compose exec php php artisan down --secret=$$secret && \
	echo "$(GREEN)Acesse com: ?secret=$$secret$(NC)"

##@ 📈 Status & Health

status: ## Mostra status completo do ambiente
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)📊 Status do Ambiente Laravel$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(YELLOW)🐳 Containers:$(NC)"
	@docker compose ps
	@echo ""
	@echo "$(YELLOW)📦 Aplicação:$(NC)"
	@docker compose exec php php artisan about
	@echo ""
	@echo "$(YELLOW)🗄️  Migrations:$(NC)"
	@docker compose exec php php artisan migrate:status

health: ## Check de saúde completo
	@echo "$(GREEN)🏥 Health Check...$(NC)"
	@echo ""
	@echo "$(YELLOW)Testando MySQL...$(NC)"
	@docker compose exec mysql mysqladmin -u root -proot ping || echo "$(RED)❌ MySQL com problema$(NC)"
	@echo ""
	@echo "$(YELLOW)Testando Redis...$(NC)"
	@docker compose exec redis redis-cli ping || echo "$(RED)❌ Redis com problema$(NC)"
	@echo ""
	@echo "$(YELLOW)Testando PHP-FPM...$(NC)"
	@docker compose exec php php -v | head -1 || echo "$(RED)❌ PHP com problema$(NC)"
	@echo ""
	@echo "$(GREEN)✅ Health check concluído!$(NC)"

info: ## Mostra informações do ambiente
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)ℹ️  Informações do Ambiente$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(YELLOW)🌐 URLs:$(NC)"
	@echo "  Aplicação: http://localhost:8080"
	@echo "  Mailpit:   http://localhost:32770"
	@echo ""
	@echo "$(YELLOW)🗄️  Banco de Dados:$(NC)"
	@echo "  Host:     localhost"
	@echo "  Port:     3306"
	@echo "  Database: db_laravel"
	@echo "  User:     developer"
	@echo "  Password: 123456"
	@echo ""
	@echo "$(YELLOW)🔴 Redis:$(NC)"
	@echo "  Host: localhost"
	@echo "  Port: 6379"
	@echo ""

##@ 🧼 Limpeza & Reset

clean: ## Limpa arquivos temporários
	@echo "$(GREEN)🧼 Limpando arquivos temporários...$(NC)"
	docker compose exec php rm -rf storage/framework/cache/*
	docker compose exec php rm -rf storage/framework/sessions/*
	docker compose exec php rm -rf storage/framework/views/*
	@echo "$(GREEN)✅ Limpeza concluída!$(NC)"

reset-hard: ## Reset completo do ambiente (⚠️ APAGA TUDO!)
	@echo "$(RED)⚠️⚠️⚠️  ATENÇÃO: Isso vai APAGAR TODOS OS DADOS! ⚠️⚠️⚠️$(NC)"
	@echo "$(RED)Isso inclui: banco de dados, cache, volumes, etc.$(NC)"
	@read -p "Digite 'CONFIRMO' para continuar: " confirm; \
	if [ "$$confirm" = "CONFIRMO" ]; then \
		echo "$(YELLOW)Parando containers...$(NC)"; \
		docker compose down -v; \
		echo "$(YELLOW)Removendo dados...$(NC)"; \
		docker compose exec php rm -rf vendor node_modules storage/logs/*; \
		echo "$(GREEN)✅ Reset completo realizado!$(NC)"; \
		echo "$(YELLOW)Execute 'make up' e 'make setup' para reconfigurar$(NC)"; \
	else \
		echo "Cancelado."; \
	fi

prune: ## Remove containers, volumes e imagens não utilizados
	@echo "$(YELLOW)🧹 Limpando Docker...$(NC)"
	docker system prune -af --volumes
	@echo "$(GREEN)✅ Docker limpo!$(NC)"

##@ 🚀 Workflows Rápidos

dev: up logs ## Inicia e mostra logs

quick-start: up setup ## Start rápido com setup

rebuild-all: down up-build migrate ## Rebuild completo

fresh: migrate-fresh-seed clear-all ## Fresh start com seed

deploy-prep: ## Prepara para deploy
	@echo "$(GREEN)🚀 Preparando para deploy...$(NC)"
	$(MAKE) test
	$(MAKE) production-ready
	@echo "$(GREEN)✅ Pronto para deploy!$(NC)"

##@ 🐛 Debug & Desenvolvimento

debug: ## Mostra informações de debug
	@echo "$(YELLOW)🐛 Debug Info:$(NC)"
	@echo ""
	docker compose exec php php -v
	@echo ""
	docker compose exec php composer --version
	@echo ""
	docker compose exec php php artisan --version

debug-config: ## Mostra configuração atual
	docker compose exec php php artisan config:show

debug-env: ## Mostra variáveis de ambiente
	docker compose exec php php artisan env

debug-routes: ## Debug de rotas
	docker compose exec php php artisan route:list -vvv

tail-all: ## Tail de todos os logs
	docker compose logs -f

watch-logs: ## Watch logs do Laravel (requer inotify-tools)
	docker compose exec php watch -n 1 tail -n 50 storage/logs/laravel.log

##@ 📚 Tabelas Úteis

session-table: ## Cria tabela de sessões
	docker compose exec php php artisan session:table
	docker compose exec php php artisan migrate

notifications-table: ## Cria tabela de notificações
	docker compose exec php php artisan notifications:table
	docker compose exec php php artisan migrate

cache-table: ## Cria tabela de cache
	docker compose exec php php artisan cache:table
	docker compose exec php php artisan migrate

##@ 🎨 Frontend

vite-build: ## Build Vite (produção)
	docker compose exec php npm run build

vite-dev: ## Dev server Vite
	docker compose exec php npm run dev

##@ 📝 Outros

vendor-publish: ## Publica assets de vendors
	docker compose exec php php artisan vendor:publish

list-commands: ## Lista todos comandos Artisan
	docker compose exec php php artisan list

stub-publish: ## Publica stubs para customização
	docker compose exec php php artisan stub:publish

package-discover: ## Descobre packages
	docker compose exec php php artisan package:discover

ide-helper: ## Gera helpers para IDE
	docker compose exec php php artisan ide-helper:generate
	docker compose exec php php artisan ide-helper:models -N
	docker compose exec php php artisan ide-helper:meta

##@ 🎯 Aliases Úteis

dev-mode: clear-all optimize-clear ## Modo desenvolvimento (sem cache)
	@echo "$(GREEN)✅ Modo desenvolvimento ativado!$(NC)"

prod-mode: production-ready ## Modo produção (com cache)
	@echo "$(GREEN)✅ Modo produção ativado!$(NC)"

fresh-install: down up setup-full ## Instalação limpa completa
	@echo "$(GREEN)✅ Instalação limpa concluída!$(NC)"

.DEFAULT_GOAL := help
