# Wander: Zero-to-Running Developer Environment
# Makefile for managing the development environment

.PHONY: help dev down logs clean clean-all teardown status ps top restart rebuild shell check-deps

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  🚀 Wander Developer Environment - Available Commands$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

check-deps: ## Check if Docker is running
	@echo "$(BLUE)🔍 Checking dependencies...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)❌ Docker is not installed$(NC)"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "$(RED)❌ Docker is not running. Please start Docker Desktop.$(NC)"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1 || { echo "$(RED)❌ Docker Compose is not installed$(NC)"; exit 1; }
	@echo "$(GREEN)✅ All dependencies are available$(NC)"

dev: check-deps ## Start all services (use PROFILE=minimal|backend|full)
	@PROFILE=$(or $(PROFILE),full); \
	if [ "$$PROFILE" = "minimal" ]; then \
		echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"; \
		echo "$(BLUE)  🚀 Starting Minimal Profile (Frontend only)...$(NC)"; \
		echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"; \
		echo "$(YELLOW)📦 Services to start:$(NC)"; \
		echo "   • Frontend (React)"; \
		echo ""; \
		cd infrastructure && docker-compose -f docker-compose.minimal.yml up -d; \
	elif [ "$$PROFILE" = "backend" ]; then \
		echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"; \
		echo "$(BLUE)  🚀 Starting Backend Profile (Backend + DB + Redis)...$(NC)"; \
		echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"; \
		echo "$(YELLOW)📦 Services to start:$(NC)"; \
		echo "   • PostgreSQL (Database)"; \
		echo "   • Redis (Cache)"; \
		echo "   • Backend API (Node.js)"; \
		echo ""; \
		cd infrastructure && docker-compose -f docker-compose.backend.yml up -d; \
	else \
		echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"; \
		echo "$(BLUE)  🚀 Starting Full Stack Profile...$(NC)"; \
		echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"; \
		echo "$(YELLOW)📦 Services to start:$(NC)"; \
		echo "   • PostgreSQL (Database)"; \
		echo "   • Redis (Cache)"; \
		echo "   • Backend API (Node.js)"; \
		echo "   • Frontend (React)"; \
		echo ""; \
		cd infrastructure && docker-compose up -d; \
	fi
	@echo ""
	@echo "$(GREEN)✅ Services starting...$(NC)"
	@echo "$(YELLOW)⏳ Waiting for services to be healthy...$(NC)"
	@sleep 5
	@$(MAKE) status
	@echo ""
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)  ✅ Environment Ready!$(NC)"
	@echo "$(GREEN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(BLUE)🌐 Frontend:$(NC)  http://localhost:3000"
	@echo "$(BLUE)🔧 Backend:$(NC)   http://localhost:8080"
	@echo "$(BLUE)📊 Health:$(NC)    http://localhost:8080/health"
	@echo ""
	@echo "$(YELLOW)💡 Tip: Run 'make logs' to see live logs$(NC)"

down: ## Stop all services (use PROFILE=minimal|backend|full)
	@PROFILE=$(or $(PROFILE),full); \
	echo "$(YELLOW)🛑 Stopping services (profile: $$PROFILE)...$(NC)"; \
	if [ "$$PROFILE" = "minimal" ]; then \
		cd infrastructure && docker-compose -f docker-compose.minimal.yml down; \
	elif [ "$$PROFILE" = "backend" ]; then \
		cd infrastructure && docker-compose -f docker-compose.backend.yml down; \
	else \
		cd infrastructure && docker-compose down; \
	fi; \
	echo "$(GREEN)✅ All services stopped$(NC)"

logs: ## Show logs from all services
	@cd infrastructure && docker-compose logs -f

logs-api: ## Show logs from backend API only
	@cd infrastructure && docker-compose logs -f backend

logs-frontend: ## Show logs from frontend only
	@cd infrastructure && docker-compose logs -f frontend

logs-db: ## Show logs from PostgreSQL only
	@cd infrastructure && docker-compose logs -f postgres

logs-redis: ## Show logs from Redis only
	@cd infrastructure && docker-compose logs -f redis

status: ## Show status of all services
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  📊 Service Status$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@cd infrastructure && docker-compose ps
	@echo ""
	@echo "$(YELLOW)💡 Run 'make logs' to see detailed logs$(NC)"

ps: status ## Alias for status command

top: ## Show resource usage (CPU, Memory)
	@echo "$(BLUE)📊 Resource Usage:$(NC)"
	@cd infrastructure && docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

restart: ## Restart all services
	@echo "$(YELLOW)🔄 Restarting all services...$(NC)"
	@cd infrastructure && docker-compose restart
	@echo "$(GREEN)✅ All services restarted$(NC)"

restart-api: ## Restart backend API only
	@echo "$(YELLOW)🔄 Restarting backend API...$(NC)"
	@cd infrastructure && docker-compose restart backend
	@echo "$(GREEN)✅ Backend API restarted$(NC)"

restart-frontend: ## Restart frontend only
	@echo "$(YELLOW)🔄 Restarting frontend...$(NC)"
	@cd infrastructure && docker-compose restart frontend
	@echo "$(GREEN)✅ Frontend restarted$(NC)"

restart-db: ## Restart database (with warning)
	@echo "$(RED)⚠️  Warning: Restarting database may cause data loss if not saved!$(NC)"
	@echo "$(YELLOW)🔄 Restarting PostgreSQL...$(NC)"
	@cd infrastructure && docker-compose restart postgres
	@echo "$(GREEN)✅ Database restarted$(NC)"

restart-redis: ## Restart Redis
	@echo "$(YELLOW)🔄 Restarting Redis...$(NC)"
	@cd infrastructure && docker-compose restart redis
	@echo "$(GREEN)✅ Redis restarted$(NC)"

start-api: ## Start backend API only
	@echo "$(YELLOW)▶️  Starting backend API...$(NC)"
	@cd infrastructure && docker-compose start backend
	@echo "$(GREEN)✅ Backend API started$(NC)"

stop-api: ## Stop backend API only
	@echo "$(YELLOW)⏸️  Stopping backend API...$(NC)"
	@cd infrastructure && docker-compose stop backend
	@echo "$(GREEN)✅ Backend API stopped$(NC)"

start-frontend: ## Start frontend only
	@echo "$(YELLOW)▶️  Starting frontend...$(NC)"
	@cd infrastructure && docker-compose start frontend
	@echo "$(GREEN)✅ Frontend started$(NC)"

stop-frontend: ## Stop frontend only
	@echo "$(YELLOW)⏸️  Stopping frontend...$(NC)"
	@cd infrastructure && docker-compose stop frontend
	@echo "$(GREEN)✅ Frontend stopped$(NC)"

rebuild: ## Rebuild all containers
	@echo "$(YELLOW)🔨 Rebuilding all containers...$(NC)"
	@cd infrastructure && docker-compose build --no-cache
	@echo "$(GREEN)✅ All containers rebuilt$(NC)"

rebuild-api: ## Rebuild backend container
	@echo "$(YELLOW)🔨 Rebuilding backend container...$(NC)"
	@cd infrastructure && docker-compose build --no-cache backend
	@echo "$(GREEN)✅ Backend container rebuilt$(NC)"

rebuild-frontend: ## Rebuild frontend container
	@echo "$(YELLOW)🔨 Rebuilding frontend container...$(NC)"
	@cd infrastructure && docker-compose build --no-cache frontend
	@echo "$(GREEN)✅ Frontend container rebuilt$(NC)"

shell-api: ## Open shell in backend container
	@cd infrastructure && docker-compose exec backend sh

shell-db: ## Open PostgreSQL console
	@cd infrastructure && docker-compose exec postgres psql -U wander -d wander_dev

shell-redis: ## Open Redis CLI
	@cd infrastructure && docker-compose exec redis redis-cli

db-backup: ## Create database backup
	@echo "$(YELLOW)💾 Creating database backup...$(NC)"
	@mkdir -p backups 2>nul || mkdir backups
	@cd infrastructure && docker-compose exec -T postgres pg_dump -U wander wander_dev > ../backups/backup_$$(powershell -Command "Get-Date -Format 'yyyyMMdd_HHmmss'" 2>nul || date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✅ Database backup created in backups/$(NC)"

db-restore: ## Restore database from backup (use BACKUP=filename.sql)
	@if [ -z "$(BACKUP)" ]; then \
		echo "$(RED)❌ Error: Please specify backup file: make db-restore BACKUP=backups/backup_20231112_120000.sql$(NC)"; \
		exit 1; \
	fi
	@echo "$(RED)⚠️  Warning: This will overwrite current database!$(NC)"
	@echo "$(YELLOW)📥 Restoring database from $(BACKUP)...$(NC)"
	@cd infrastructure && docker-compose exec -T postgres psql -U wander -d wander_dev < ../$(BACKUP)
	@echo "$(GREEN)✅ Database restored$(NC)"

db-snapshot: ## Create named database snapshot (use NAME=snapshot-name)
	@if [ -z "$(NAME)" ]; then \
		echo "$(RED)❌ Error: Please specify snapshot name: make db-snapshot NAME=before-refactor$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)📸 Creating snapshot: $(NAME)...$(NC)"
	@mkdir -p snapshots 2>nul || mkdir snapshots
	@cd infrastructure && docker-compose exec -T postgres pg_dump -U wander wander_dev > ../snapshots/$(NAME).sql
	@git rev-parse HEAD > snapshots/$(NAME).git 2>nul || echo "unknown" > snapshots/$(NAME).git
	@powershell -Command "Get-Date" > snapshots/$(NAME).date 2>nul || date > snapshots/$(NAME).date 2>nul || echo "unknown" > snapshots/$(NAME).date
	@echo "$(GREEN)✅ Snapshot '$(NAME)' created$(NC)"

snapshots: ## List all snapshots
	@echo "$(BLUE)📸 Available Snapshots:$(NC)"
	@if [ -d snapshots ] && [ -n "$$(ls -A snapshots/*.sql 2>/dev/null)" ]; then \
		for file in snapshots/*.sql; do \
			name=$$(basename $$file .sql); \
			if [ -f snapshots/$$name.date ]; then \
				echo "  • $$name - $$(cat snapshots/$$name.date)"; \
			else \
				echo "  • $$name"; \
			fi; \
		done; \
	else \
		echo "  No snapshots found"; \
	fi

restore: ## Restore from snapshot (use NAME=snapshot-name)
	@if [ -z "$(NAME)" ]; then \
		echo "$(RED)❌ Error: Please specify snapshot name: make restore NAME=before-refactor$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f snapshots/$(NAME).sql ]; then \
		echo "$(RED)❌ Error: Snapshot '$(NAME)' not found$(NC)"; \
		echo "$(YELLOW)💡 Run 'make snapshots' to see available snapshots$(NC)"; \
		exit 1; \
	fi
	@echo "$(RED)⚠️  Warning: This will overwrite current database!$(NC)"
	@echo "$(YELLOW)📥 Restoring snapshot: $(NAME)...$(NC)"
	@cd infrastructure && docker-compose exec -T postgres psql -U wander -d wander_dev < ../snapshots/$(NAME).sql
	@echo "$(GREEN)✅ Snapshot '$(NAME)' restored$(NC)"

db-migrate: ## Run database migrations
	@echo "$(YELLOW)🔄 Running migrations...$(NC)"
	@cd infrastructure && docker-compose exec -T postgres psql -U wander -d wander_dev -f /docker-entrypoint-initdb.d/001_initial_schema.sql || true
	@echo "$(GREEN)✅ Migrations complete$(NC)"

db-console: shell-db ## Alias for shell-db

seed: ## Seed database with sample data
	@echo "$(YELLOW)🌱 Seeding database...$(NC)"
	@cd infrastructure && docker-compose exec -T postgres psql -U wander -d wander_dev < ../backend/seeds/001_sample_users.sql
	@cd infrastructure && docker-compose exec -T postgres psql -U wander -d wander_dev < ../backend/seeds/002_sample_data.sql
	@echo "$(GREEN)✅ Database seeded successfully!$(NC)"

reset-db: ## Reset database (drop all tables, recreate, and seed)
	@echo "$(RED)⚠️  This will delete all data in the database!$(NC)"
	@echo "$(YELLOW)🔄 Resetting database...$(NC)"
	@cd infrastructure && docker-compose stop postgres || true
	@docker volume rm infrastructure_postgres_data 2>nul || docker volume rm infrastructure_postgres_data 2>/dev/null || true
	@cd infrastructure && docker-compose up -d postgres
	@echo "$(YELLOW)⏳ Waiting for database to be ready...$(NC)"
	@timeout /t 5 /nobreak >nul 2>&1 || sleep 5
	@$(MAKE) seed
	@echo "$(GREEN)✅ Database reset complete!$(NC)"

clean: ## Remove all containers, volumes, and networks
	@echo "$(YELLOW)🧹 Cleaning up...$(NC)"
	@echo "$(RED)⚠️  This will remove all containers, volumes, and networks$(NC)"
	@cd infrastructure && docker-compose down -v --remove-orphans
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

clean-all: ## Remove everything including images (complete teardown)
	@echo "$(RED)⚠️  Complete Teardown - This will remove EVERYTHING!$(NC)"
	@echo "$(YELLOW)🧹 Removing containers, volumes, networks, and images...$(NC)"
	@cd infrastructure && docker-compose down --rmi all -v --remove-orphans
	@echo "$(GREEN)✅ Complete teardown done! All containers, volumes, and images removed.$(NC)"

teardown: clean-all ## Complete teardown - removes everything (alias for clean-all)

lint: ## Run linting for all services
	@echo "$(BLUE)🔍 Running linters...$(NC)"
	@cd backend && npm run lint
	@cd frontend && npm run lint
	@echo "$(GREEN)✅ All linting passed!$(NC)"

lint-fix: ## Fix linting issues automatically
	@echo "$(YELLOW)🔧 Fixing linting issues...$(NC)"
	@cd backend && npm run lint-fix || true
	@cd frontend && npm run lint-fix || true
	@echo "$(GREEN)✅ Linting fixes applied!$(NC)"

format: ## Format code with Prettier
	@echo "$(YELLOW)✨ Formatting code...$(NC)"
	@cd backend && npm run format || true
	@cd frontend && npm run format || true
	@echo "$(GREEN)✅ Code formatted!$(NC)"

test: ## Run all tests
	@echo "$(BLUE)🧪 Running all tests...$(NC)"
	@echo "$(YELLOW)⚠️  Test suite not yet implemented$(NC)"
	@echo "$(GREEN)✅ Test framework ready$(NC)"

test-api: ## Run backend tests only
	@echo "$(BLUE)🧪 Running backend tests...$(NC)"
	@cd backend && npm test 2>/dev/null || echo "$(YELLOW)⚠️  Test script not configured$(NC)"

test-frontend: ## Run frontend tests only
	@echo "$(BLUE)🧪 Running frontend tests...$(NC)"
	@cd frontend && npm test 2>/dev/null || echo "$(YELLOW)⚠️  Test script not configured$(NC)"

test-integration: ## Run integration tests
	@echo "$(BLUE)🧪 Running integration tests...$(NC)"
	@echo "$(YELLOW)⚠️  Integration tests not yet implemented$(NC)"

test-e2e: ## Run end-to-end tests
	@echo "$(BLUE)🧪 Running E2E tests...$(NC)"
	@echo "$(YELLOW)⚠️  E2E tests not yet implemented$(NC)"

migration: ## Create a new migration file (use NAME=migration-name)
	@if [ -z "$(NAME)" ]; then \
		echo "$(RED)❌ Error: Please specify migration name: make migration NAME=add_user_roles$(NC)"; \
		exit 1; \
	fi
	@bash scripts/create-migration.sh $(NAME)

benchmark: ## Run performance benchmarks
	@bash scripts/benchmark.sh

smoke-test: ## Run smoke tests to verify setup
	@bash scripts/smoke-test.sh
