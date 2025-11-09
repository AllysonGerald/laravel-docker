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

# Incluir todos os módulos
include makefiles/Makefile.docker
include makefiles/Makefile.docker-advanced
include makefiles/Makefile.laravel
include makefiles/Makefile.laravel-make
include makefiles/Makefile.architecture
include makefiles/Makefile.database
include makefiles/Makefile.git
include makefiles/Makefile.packages
include makefiles/Makefile.queue
include makefiles/Makefile.tests
include makefiles/Makefile.maintenance
include makefiles/Makefile.setup
include makefiles/Makefile.utils
include makefiles/Makefile.quality

.DEFAULT_GOAL := help
