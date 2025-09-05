#!/bin/bash

# Flyway Database Deployment Script
# This script deploys database changes using Flyway
# Simulates AWS Aurora Postgres deployment using LocalStack

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FLYWAY_CONFIG="$PROJECT_ROOT/flyway.conf"
LOG_FILE="$PROJECT_ROOT/deployment.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Flyway is installed
    if ! command -v flyway &> /dev/null; then
        error "Flyway is not installed. Please install Flyway first."
    fi
    
    # Check if PostgreSQL is running (LocalStack simulation)
    if ! pg_isready -h localhost -p 5432 &> /dev/null; then
        error "PostgreSQL is not running on localhost:5432. Please start LocalStack PostgreSQL."
    fi
    
    # Check if database exists
    if ! psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1;" &> /dev/null; then
        error "Database 'aurora_postgres_db' does not exist. Please create it first."
    fi
    
    log "Prerequisites check passed."
}

# Validate SQL scripts
validate_scripts() {
    log "Validating SQL scripts..."
    
    # Check for syntax errors in DDL scripts
    for script in "$PROJECT_ROOT/scripts/ddl"/*.sql; do
        if [ -f "$script" ]; then
            log "Validating DDL script: $(basename "$script")"
            if ! psql -h localhost -p 5432 -U postgres -d aurora_postgres_db --dry-run -f "$script" &> /dev/null; then
                error "Syntax error in DDL script: $(basename "$script")"
            fi
        fi
    done
    
    # Check for syntax errors in DML scripts
    for script in "$PROJECT_ROOT/scripts/dml"/*.sql; do
        if [ -f "$script" ]; then
            log "Validating DML script: $(basename "$script")"
            if ! psql -h localhost -p 5432 -U postgres -d aurora_postgres_db --dry-run -f "$script" &> /dev/null; then
                error "Syntax error in DML script: $(basename "$script")"
            fi
        fi
    done
    
    log "Script validation passed."
}

# Backup database
backup_database() {
    log "Creating database backup..."
    BACKUP_FILE="$PROJECT_ROOT/backup_$(date +%Y%m%d_%H%M%S).sql"
    
    if pg_dump -h localhost -p 5432 -U postgres aurora_postgres_db > "$BACKUP_FILE"; then
        log "Database backup created: $BACKUP_FILE"
    else
        error "Failed to create database backup"
    fi
}

# Deploy migrations
deploy_migrations() {
    log "Deploying database migrations..."
    
    cd "$PROJECT_ROOT"
    
    # Run Flyway migrate
    if flyway -configFiles="$FLYWAY_CONFIG" migrate; then
        log "Database migrations deployed successfully."
    else
        error "Database migration failed."
    fi
}

# Verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Check if all tables exist
    TABLES=("users" "products" "orders" "order_items")
    for table in "${TABLES[@]}"; do
        if psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1 FROM $table LIMIT 1;" &> /dev/null; then
            log "Table '$table' exists and is accessible."
        else
            error "Table '$table' does not exist or is not accessible."
        fi
    done
    
    # Check migration history
    log "Migration history:"
    flyway -configFiles="$FLYWAY_CONFIG" info
    
    log "Deployment verification completed."
}

# Main execution
main() {
    log "Starting Flyway database deployment..."
    
    check_prerequisites
    validate_scripts
    backup_database
    deploy_migrations
    verify_deployment
    
    log "Database deployment completed successfully!"
}

# Run main function
main "$@"
