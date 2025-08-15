up:
	docker compose up -d

up_build:
	docker compose up -d --build

bash:
	docker compose exec php bash

down:
	docker compose down

db:
	docker compose exec mysql bash

# só usa uma vez, pra configurar um novo projeto
setup:
	# copiar o .env se ainda não existir
	cp --update=none backend/.env.example backend/.env

	# instalar as dependencias/pacotes
	docker compose exec php bash -c "composer install"

	# Gerar a chave de autenticação do laravel
	docker compose exec php bash -c "php artisan key:generate"

	# Atualizar o esquema do banco (criar tabelas, etc)
	docker compose exec php bash -c "php artisan migrate"

# rodar o seeder
seed:
	docker compose exec php bash -c "php artisan db:seed"

# === COMANDOS DE MIGRAÇÃO ===
# Executar migrações
migrate:
	docker compose exec php bash -c "php artisan migrate"

# Desfazer última migração
migrate_rollback:
	docker compose exec php bash -c "php artisan migrate:rollback"

# Desfazer todas as migrações
migrate_reset:
	docker compose exec php bash -c "php artisan migrate:reset"

# Resetar e executar todas as migrações novamente
migrate_refresh:
	docker compose exec php bash -c "php artisan migrate:refresh"

# Resetar migrações e executar seeders
migrate_fresh:
	docker compose exec php bash -c "php artisan migrate:fresh --seed"

# Ver status das migrações
migrate_status:
	docker compose exec php bash -c "php artisan migrate:status"

# === COMANDOS DE BANCO DE DADOS ===
# Acessar CLI do banco
db_cli:
	docker compose exec php bash -c "php artisan db"

# Mostrar informações do banco
db_show:
	docker compose exec php bash -c "php artisan db:show"

# Limpar todas as tabelas
db_wipe:
	docker compose exec php bash -c "php artisan db:wipe"

# === COMANDOS DE CACHE ===
# Limpar cache da aplicação
cache_clear:
	docker compose exec php bash -c "php artisan cache:clear"

# Limpar cache de configuração
config_clear:
	docker compose exec php bash -c "php artisan config:clear"

# Limpar cache de rotas
route_clear:
	docker compose exec php bash -c "php artisan route:clear"

# Limpar cache de views
view_clear:
	docker compose exec php bash -c "php artisan view:clear"

# Limpar todos os caches
clear_all:
	docker compose exec php bash -c "php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear"

# === COMANDOS DE OTIMIZAÇÃO ===
# Otimizar aplicação para produção
optimize:
	docker compose exec php bash -c "php artisan optimize"

# Limpar otimizações
optimize_clear:
	docker compose exec php bash -c "php artisan optimize:clear"

# Cache de configuração
config_cache:
	docker compose exec php bash -c "php artisan config:cache"

# Cache de rotas
route_cache:
	docker compose exec php bash -c "php artisan route:cache"

# === COMANDOS DE QUEUE ===
# Processar jobs na fila
queue_work:
	docker compose exec php bash -c "php artisan queue:work"

# Reiniciar workers da fila
queue_restart:
	docker compose exec php bash -c "php artisan queue:restart"

# Limpar jobs falhados
queue_flush:
	docker compose exec php bash -c "php artisan queue:flush"

# === COMANDOS DE DESENVOLVIMENTO ===
# Gerar nova chave da aplicação
key_generate:
	docker compose exec php bash -c "php artisan key:generate"

# Listar todas as rotas
route_list:
	docker compose exec php bash -c "php artisan route:list"

# Executar tinker
tinker:
	docker compose exec php bash -c "php artisan tinker"

# === COMANDOS DE STORAGE ===
# Criar link simbólico para storage
storage_link:
	docker compose exec php bash -c "php artisan storage:link"

# === COMANDOS DE TESTES ===
# Executar todos os testes
test:
	docker compose exec php bash -c "php artisan test"

# Executar testes com coverage
test_coverage:
	docker compose exec php bash -c "php artisan test --coverage"

# === COMANDOS DE CRIAÇÃO (MAKE) ===
# Criar nova migração
make_migration:
	@read -p "Nome da migração: " name; \
	docker compose exec php bash -c "php artisan make:migration $$name"

# Criar novo modelo
make_model:
	@read -p "Nome do modelo: " name; \
	docker compose exec php bash -c "php artisan make:model $$name"

# Criar modelo com migração e factory
make_model_full:
	@read -p "Nome do modelo: " name; \
	docker compose exec php bash -c "php artisan make:model $$name -mf"

# Criar controller
make_controller:
	@read -p "Nome do controller: " name; \
	docker compose exec php bash -c "php artisan make:controller $$name"

# Criar controller com recursos
make_controller_resource:
	@read -p "Nome do controller: " name; \
	docker compose exec php bash -c "php artisan make:controller $$name --resource"

# Criar seeder
make_seeder:
	@read -p "Nome do seeder: " name; \
	docker compose exec php bash -c "php artisan make:seeder $$name"

# Criar factory
make_factory:
	@read -p "Nome da factory: " name; \
	docker compose exec php bash -c "php artisan make:factory $$name"

# Criar middleware
make_middleware:
	@read -p "Nome do middleware: " name; \
	docker compose exec php bash -c "php artisan make:middleware $$name"

# Criar request
make_request:
	@read -p "Nome do request: " name; \
	docker compose exec php bash -c "php artisan make:request $$name"

# Criar job
make_job:
	@read -p "Nome do job: " name; \
	docker compose exec php bash -c "php artisan make:job $$name"

# Criar event
make_event:
	@read -p "Nome do event: " name; \
	docker compose exec php bash -c "php artisan make:event $$name"

# Criar listener
make_listener:
	@read -p "Nome do listener: " name; \
	docker compose exec php bash -c "php artisan make:listener $$name"

# Criar notification
make_notification:
	@read -p "Nome da notification: " name; \
	docker compose exec php bash -c "php artisan make:notification $$name"

# Criar mail
make_mail:
	@read -p "Nome do mail: " name; \
	docker compose exec php bash -c "php artisan make:mail $$name"

# Criar command
make_command:
	@read -p "Nome do command: " name; \
	docker compose exec php bash -c "php artisan make:command $$name"

# Criar test
make_test:
	@read -p "Nome do test: " name; \
	docker compose exec php bash -c "php artisan make:test $$name"

# Criar policy
make_policy:
	@read -p "Nome da policy: " name; \
	docker compose exec php bash -c "php artisan make:policy $$name"

# Criar observer
make_observer:
	@read -p "Nome do observer: " name; \
	docker compose exec php bash -c "php artisan make:observer $$name"

# Criar provider
make_provider:
	@read -p "Nome do provider: " name; \
	docker compose exec php bash -c "php artisan make:provider $$name"

# === COMANDOS DE SCHEDULE ===
# Executar schedule
schedule_run:
	docker compose exec php bash -c "php artisan schedule:run"

# Listar comandos agendados
schedule_list:
	docker compose exec php bash -c "php artisan schedule:list"

# Trabalhar com schedule (daemon)
schedule_work:
	docker compose exec php bash -c "php artisan schedule:work"

# === COMANDOS DE LOGS ===
# Ver logs em tempo real
logs_tail:
	docker compose exec php bash -c "tail -f storage/logs/laravel.log"

# Limpar logs
logs_clear:
	docker compose exec php bash -c "> storage/logs/laravel.log"

# === COMANDOS DE EVENTOS ===
# Listar eventos e listeners
event_list:
	docker compose exec php bash -c "php artisan event:list"

# Gerar eventos em cache
event_cache:
	docker compose exec php bash -c "php artisan event:cache"

# Limpar cache de eventos
event_clear:
	docker compose exec php bash -c "php artisan event:clear"

# === COMANDOS DE SESSÃO ===
# Criar tabela de sessão
session_table:
	docker compose exec php bash -c "php artisan session:table"

# === COMANDOS DE NOTIFICAÇÃO ===
# Criar tabela de notificações
notifications_table:
	docker compose exec php bash -c "php artisan notifications:table"

# === COMANDOS DE QUEUE AVANÇADOS ===
# Criar tabela de failed jobs
queue_failed_table:
	docker compose exec php bash -c "php artisan queue:failed-table"

# Criar tabela de batches
queue_batches_table:
	docker compose exec php bash -c "php artisan queue:batches-table"

# Monitorar queue
queue_monitor:
	docker compose exec php bash -c "php artisan queue:monitor"

# Reprocessar jobs falhados
queue_retry:
	docker compose exec php bash -c "php artisan queue:retry all"

# === COMANDOS DE VENDOR ===
# Publicar assets do vendor
vendor_publish:
	docker compose exec php bash -c "php artisan vendor:publish"

# === COMANDOS DE INSPEÇÃO ===
# Mostrar sobre a aplicação
about:
	docker compose exec php bash -c "php artisan about"

# Listar comandos disponíveis
list_commands:
	docker compose exec php bash -c "php artisan list"

# Inspirational quote
inspire:
	docker compose exec php bash -c "php artisan inspire"

# === COMANDOS DE DESENVOLVIMENTO AVANÇADO ===
# Servir aplicação (se não estiver usando Docker)
serve:
	docker compose exec php bash -c "php artisan serve --host=0.0.0.0 --port=8000"

# Modo de manutenção ON
maintenance_on:
	docker compose exec php bash -c "php artisan down"

# Modo de manutenção OFF
maintenance_off:
	docker compose exec php bash -c "php artisan up"

# === COMANDOS DE BANCO AVANÇADOS ===
# Monitorar conexões do banco
db_monitor:
	docker compose exec php bash -c "php artisan db:monitor"

# Mostrar informações de uma tabela específica
db_table:
	@read -p "Nome da tabela: " table; \
	docker compose exec php bash -c "php artisan db:table $$table"

# === COMANDOS DE PACKAGE DISCOVERY ===
# Descobrir packages
package_discover:
	docker compose exec php bash -c "php artisan package:discover"

# === COMANDOS DE STUB ===
# Publicar stubs
stub_publish:
	docker compose exec php bash -c "php artisan stub:publish"

# === COMANDOS COMBINADOS AVANÇADOS ===
# Reset completo do projeto (migração + seed)
fresh_start:
	docker compose exec php bash -c "php artisan migrate:fresh --seed"

# Preparar aplicação para produção
production_ready:
	docker compose exec php bash -c "php artisan config:cache && php artisan route:cache && php artisan optimize"

# Setup completo para desenvolvimento
dev_setup:
	docker compose exec php bash -c "php artisan key:generate && php artisan migrate:fresh --seed && php artisan storage:link"

# Limpar tudo (cache, config, routes, views, compiled)
clear_everything:
	docker compose exec php bash -c "php artisan optimize:clear && php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear && php artisan event:clear"

# Rebuild completo (limpar tudo + otimizar)
rebuild:
	docker compose exec php bash -c "php artisan optimize:clear && php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear && php artisan config:cache && php artisan route:cache && php artisan optimize"

# Debug: mostrar configuração atual
debug_config:
	docker compose exec php bash -c "php artisan config:show"

# Debug: mostrar rotas com middlewares
debug_routes:
	docker compose exec php bash -c "php artisan route:list --columns=uri,name,action,middleware"

# Verificar saúde da aplicação
health_check:
	docker compose exec php bash -c "php artisan about && php artisan route:list | head -5 && php artisan migrate:status"


