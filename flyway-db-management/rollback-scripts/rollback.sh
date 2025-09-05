#!/bin/bash

# Flyway Database Rollback Script
# This script rolls back database changes to a specific version
# Simulates AWS Aurora Postgres rollback using LocalStack

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FLYWAY_CONFIG="$PROJECT_ROOT/flyway.conf"
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
    echo "Usage: $0 <target_version>"
    echo "Example: $0 1.1"
    echo "Available versions:"
    flyway -configFiles="$FLYWAY_CONFIG" info | grep "|" | tail -n +3 | awk '{print "  " $2}'
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Flyway is installed
    if ! command -v flyway &> /dev/null; then
        error "Flyway is not installed. Please install Flyway first."
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

# Rollback to target version
rollback_to_version() {
    local target_version="$1"
    
    log "Rolling back to version: $target_version"
    
    cd "$PROJECT_ROOT"
    
    # Show current migration status
    log "Current migration status:"
    flyway -configFiles="$FLYWAY_CONFIG" info
    
    # Confirm rollback
    read -p "Are you sure you want to rollback to version $target_version? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Rollback cancelled by user."
        exit 0
    fi
    
    # Perform rollback using Flyway clean and migrate
    log "Cleaning database..."
    flyway -configFiles="$FLYWAY_CONFIG" clean
    
    log "Migrating to target version..."
    flyway -configFiles="$FLYWAY_CONFIG" migrate -target="$target_version"
    
    log "Rollback completed successfully."
}

# Verify rollback
verify_rollback() {
    local target_version="$1"
    
    log "Verifying rollback to version: $target_version"
    
    # Check migration history
    log "Current migration status:"
    flyway -configFiles="$FLYWAY_CONFIG" info
    
    # Verify tables based on version
    case "$target_version" in
        "1.0")
            if psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1 FROM users LIMIT 1;" &> /dev/null; then
                log "Version 1.0 verification: users table exists."
            else
                error "Version 1.0 verification failed: users table missing."
            fi
            ;;
        "1.1")
            if psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1 FROM products LIMIT 1;" &> /dev/null; then
                log "Version 1.1 verification: products table exists."
            else
                error "Version 1.1 verification failed: products table missing."
            fi
            ;;
        "2.0")
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
    
    local target_version="$1"
    
    log "Starting Flyway database rollback to version: $target_version"
    
    check_prerequisites
    backup_database
    rollback_to_version "$target_version"
    verify_rollback "$target_version"
    
    log "Database rollback completed successfully!"
}

# Run main function
main "$@"
