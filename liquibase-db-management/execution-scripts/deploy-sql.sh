#!/bin/bash

# Liquibase Database Deployment Script using Standalone SQL Files
# This script deploys database changes using Liquibase with standalone SQL files
# Simulates AWS Aurora Postgres deployment using LocalStack

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIQUIBASE_CONFIG="$PROJECT_ROOT/liquibase-complete.properties"
LOG_FILE="$PROJECT_ROOT/deployment-sql.log"

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
    
    # Check if Liquibase is installed
    if ! command -v liquibase &> /dev/null; then
        error "Liquibase is not installed. Please install Liquibase first."
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

# Validate SQL files
validate_sql_files() {
    log "Validating standalone SQL files..."
    
    # Check DDL files
    for sql_file in "$PROJECT_ROOT/scripts/ddl"/*.sql; do
        if [ -f "$sql_file" ]; then
            log "Validating DDL file: $(basename "$sql_file")"
            if ! psql -h localhost -p 5432 -U postgres -d aurora_postgres_db --dry-run -f "$sql_file" &> /dev/null; then
                error "Syntax error in DDL file: $(basename "$sql_file")"
            fi
        fi
    done
    
    # Check DML files
    for sql_file in "$PROJECT_ROOT/scripts/dml"/*.sql; do
        if [ -f "$sql_file" ]; then
            log "Validating DML file: $(basename "$sql_file")"
            if ! psql -h localhost -p 5432 -U postgres -d aurora_postgres_db --dry-run -f "$sql_file" &> /dev/null; then
                error "Syntax error in DML file: $(basename "$sql_file")"
            fi
        fi
    done
    
    log "SQL file validation passed."
}

# Validate changelog files
validate_changelog() {
    log "Validating changelog files..."
    
    # Check main changelog file
    if [ ! -f "$PROJECT_ROOT/scripts/db-changelog-complete.xml" ]; then
        error "Main changelog file not found: scripts/db-changelog-complete.xml"
    fi
    
    # Validate XML syntax
    if ! xmllint --noout "$PROJECT_ROOT/scripts/db-changelog-complete.xml" 2>/dev/null; then
        error "XML syntax error in main changelog file"
    fi
    
    log "Changelog validation passed."
}

# Backup database
backup_database() {
    log "Creating database backup..."
    BACKUP_FILE="$PROJECT_ROOT/backup_sql_$(date +%Y%m%d_%H%M%S).sql"
    
    if pg_dump -h localhost -p 5432 -U postgres aurora_postgres_db > "$BACKUP_FILE"; then
        log "Database backup created: $BACKUP_FILE"
    else
        error "Failed to create database backup"
    fi
}

# Deploy changes
deploy_changes() {
    log "Deploying database changes using standalone SQL files..."
    
    cd "$PROJECT_ROOT"
    
    # Run Liquibase update
    if liquibase --defaults-file="$LIQUIBASE_CONFIG" update; then
        log "Database changes deployed successfully."
    else
        error "Database deployment failed."
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
    
    # Check Liquibase status
    log "Liquibase status:"
    liquibase --defaults-file="$LIQUIBASE_CONFIG" status
    
    log "Deployment verification completed."
}

# Main execution
main() {
    log "Starting Liquibase database deployment with standalone SQL files..."
    
    check_prerequisites
    validate_sql_files
    validate_changelog
    backup_database
    deploy_changes
    verify_deployment
    
    log "Database deployment completed successfully!"
}

# Run main function
main "$@"
