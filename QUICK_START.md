# ⚡ Guia de Início Rápido

## 🚀 Instalação em 3 Passos

```bash
# 1. Clone o repositório
git clone <seu-repositorio>
cd laravel-docker-mono

# 2. Inicie o projeto
make init-project

# 3. Acesse
# Aplicação: http://localhost:8080
# Mailpit: http://localhost:32770
```

## 📋 Comandos Mais Usados

### Docker
```bash
make up              # Iniciar containers
make down            # Parar containers
make restart         # Reiniciar containers
make logs            # Ver logs
make ps              # Status containers
```

### Laravel
```bash
make bash            # Acessar container PHP
make tinker          # Laravel Tinker
make route-list      # Listar rotas
make migrate         # Executar migrations
make test            # Executar testes
```

### Banco de Dados
```bash
make db              # MySQL (root)
make psql            # PostgreSQL
make mongo           # MongoDB
make redis-cli       # Redis CLI
make backup-db       # Backup
```

### Desenvolvimento
```bash
make make-model-full         # Criar model completo
make make-controller-api     # Criar API controller
make make-migration          # Criar migration
```

### Git
```bash
make git-status              # Status
make git-quick-push          # Add + commit + push
make git-branch              # Listar branches
```

### Qualidade
```bash
make quality-check           # Verificação completa
make quality-fix             # Corrigir automaticamente
make phpstan-analyze         # Análise estática
make pint-fix                # Formatar código
```

## 🗄️ Credenciais

### MySQL
- Host: `localhost` ou `mysql`
- Port: `3306`
- User: `developer` / Password: `123456`
- Root: `root` / Password: `root`

### PostgreSQL
- Host: `localhost` ou `postgres`
- Port: `5432`
- User: `developer` / Password: `123456`

### MongoDB
- Host: `localhost` ou `mongodb`
- Port: `27017`
- User: `developer` / Password: `123456`

### Redis
- Host: `localhost` ou `redis`
- Port: `6379`

## 🔧 Troubleshooting Rápido

```bash
make health                  # Health check
make verify-environment      # Verificar ambiente
make docker-rebuild          # Rebuild completo
make clear-all              # Limpar caches
make reset-hard             # Reset completo (⚠️)
```

## 📚 Mais Informações

```bash
make help           # Ver todos os 426+ comandos
```

📖 Ver [README.md](README.md) para documentação completa.

