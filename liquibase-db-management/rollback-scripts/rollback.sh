#!/bin/bash

# Liquibase Database Rollback Script
# This script rolls back database changes to a specific changeset
# Simulates AWS Aurora Postgres rollback using LocalStack

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIQUIBASE_CONFIG="$PROJECT_ROOT/liquibase.properties"
LOG_FILE="$PROJECT_ROOT/rollback.log"

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

# Show usage
usage() {
    echo "Usage: $0 <changeset_id>"
    echo "Example: $0 1.1-001"
    echo "Available changesets:"
    liquibase --defaults-file="$LIQUIBASE_CONFIG" status | grep "|" | tail -n +3 | awk '{print "  " $2}'
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Liquibase is installed
    if ! command -v liquibase &> /dev/null; then
        error "Liquibase is not installed. Please install Liquibase first."
    fi
    
    # Check if PostgreSQL is running
    if ! pg_isready -h localhost -p 5432 &> /dev/null; then
        error "PostgreSQL is not running on localhost:5432. Please start LocalStack PostgreSQL."
    fi
    
    log "Prerequisites check passed."
}

# Backup database before rollback
backup_database() {
    log "Creating database backup before rollback..."
    BACKUP_FILE="$PROJECT_ROOT/rollback_backup_$(date +%Y%m%d_%H%M%S).sql"
    
    if pg_dump -h localhost -p 5432 -U postgres aurora_postgres_db > "$BACKUP_FILE"; then
        log "Database backup created: $BACKUP_FILE"
    else
        error "Failed to create database backup"
    fi
}

# Rollback to specific changeset
rollback_to_changeset() {
    local changeset_id="$1"
    
    log "Rolling back to changeset: $changeset_id"
    
    cd "$PROJECT_ROOT"
    
    # Show current status
    log "Current Liquibase status:"
    liquibase --defaults-file="$LIQUIBASE_CONFIG" status
    
    # Confirm rollback
    read -p "Are you sure you want to rollback to changeset $changeset_id? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Rollback cancelled by user."
        exit 0
    fi
    
    # Perform rollback
    log "Performing rollback to changeset: $changeset_id"
    if liquibase --defaults-file="$LIQUIBASE_CONFIG" rollback "$changeset_id"; then
        log "Rollback completed successfully."
    else
        error "Rollback failed."
    fi
}

# Verify rollback
verify_rollback() {
    local changeset_id="$1"
    
    log "Verifying rollback to changeset: $changeset_id"
    
    # Check Liquibase status
    log "Current Liquibase status:"
    liquibase --defaults-file="$LIQUIBASE_CONFIG" status
    
    # Verify tables based on changeset
    case "$changeset_id" in
        "1.0-001"|"1.0-002"|"1.0-003")
            if psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1 FROM users LIMIT 1;" &> /dev/null; then
                log "Version 1.0 verification: users table exists."
            else
                error "Version 1.0 verification failed: users table missing."
            fi
            ;;
        "1.1-001"|"1.1-002"|"1.1-003"|"1.1-004")
            if psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1 FROM products LIMIT 1;" &> /dev/null; then
                log "Version 1.1 verification: products table exists."
            else
                error "Version 1.1 verification failed: products table missing."
            fi
            ;;
        "2.0-001"|"2.0-002"|"2.0-003"|"2.0-004"|"2.0-005"|"2.0-006")
            if psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1 FROM orders LIMIT 1;" &> /dev/null; then
                log "Version 2.0 verification: orders table exists."
            else
                error "Version 2.0 verification failed: orders table missing."
            fi
            ;;
    esac
    
    log "Rollback verification completed."
}

# Main execution
main() {
    if [ $# -eq 0 ]; then
        usage
    fi
    
    local changeset_id="$1"
    
    log "Starting Liquibase database rollback to changeset: $changeset_id"
    
    check_prerequisites
    backup_database
    rollback_to_changeset "$changeset_id"
    verify_rollback "$changeset_id"
    
    log "Database rollback completed successfully!"
}

# Run main function
main "$@"
