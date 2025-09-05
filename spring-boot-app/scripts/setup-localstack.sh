#!/bin/bash

# LocalStack Setup Script for Database Management
# This script sets up LocalStack with Aurora Postgres simulation

set -e

# Configuration
LOCALSTACK_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"
AWS_ACCESS_KEY="test"
AWS_SECRET_KEY="test"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        error "Docker is not running. Please start Docker first."
    fi
    
    # Check if LocalStack is running
    if ! curl -s "$LOCALSTACK_ENDPOINT/health" &> /dev/null; then
        error "LocalStack is not running. Please start LocalStack first."
    fi
    
    log "Prerequisites check passed."
}

# Configure AWS CLI for LocalStack
configure_aws_cli() {
    log "Configuring AWS CLI for LocalStack..."
    
    # Set AWS configuration
    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"
    export AWS_DEFAULT_REGION="$AWS_REGION"
    export AWS_ENDPOINT_URL="$LOCALSTACK_ENDPOINT"
    
    log "AWS CLI configured for LocalStack."
}

# Create RDS subnet group
create_subnet_group() {
    log "Creating RDS subnet group..."
    
    aws rds create-db-subnet-group \
        --db-subnet-group-name "aurora-postgres-subnet-group" \
        --db-subnet-group-description "Subnet group for Aurora Postgres" \
        --subnet-ids "subnet-12345" "subnet-67890" \
        --endpoint-url "$LOCALSTACK_ENDPOINT" \
        --region "$AWS_REGION" || warn "Subnet group creation failed (may already exist)"
    
    log "RDS subnet group created."
}

# Create RDS parameter group
create_parameter_group() {
    log "Creating RDS parameter group..."
    
    aws rds create-db-parameter-group \
        --db-parameter-group-name "aurora-postgres-params" \
        --db-parameter-group-family "aurora-postgresql13" \
        --description "Parameter group for Aurora Postgres" \
        --endpoint-url "$LOCALSTACK_ENDPOINT" \
        --region "$AWS_REGION" || warn "Parameter group creation failed (may already exist)"
    
    log "RDS parameter group created."
}

# Create Aurora Postgres cluster
create_aurora_cluster() {
    log "Creating Aurora Postgres cluster..."
    
    aws rds create-db-cluster \
        --db-cluster-identifier "aurora-postgres-cluster" \
        --engine "aurora-postgresql" \
        --engine-version "13.7" \
        --master-username "postgres" \
        --master-user-password "postgres" \
        --db-subnet-group-name "aurora-postgres-subnet-group" \
        --vpc-security-group-ids "sg-12345" \
        --endpoint-url "$LOCALSTACK_ENDPOINT" \
        --region "$AWS_REGION" || warn "Aurora cluster creation failed (may already exist)"
    
    log "Aurora Postgres cluster created."
}

# Create Aurora Postgres instance
create_aurora_instance() {
    log "Creating Aurora Postgres instance..."
    
    aws rds create-db-instance \
        --db-instance-identifier "aurora-postgres-instance" \
        --db-cluster-identifier "aurora-postgres-cluster" \
        --db-instance-class "db.r5.large" \
        --engine "aurora-postgresql" \
        --db-parameter-group-name "aurora-postgres-params" \
        --endpoint-url "$LOCALSTACK_ENDPOINT" \
        --region "$AWS_REGION" || warn "Aurora instance creation failed (may already exist)"
    
    log "Aurora Postgres instance created."
}

# Verify setup
verify_setup() {
    log "Verifying LocalStack setup..."
    
    # Check RDS clusters
    log "RDS Clusters:"
    aws rds describe-db-clusters --endpoint-url "$LOCALSTACK_ENDPOINT" --region "$AWS_REGION" || warn "Failed to describe clusters"
    
    # Check RDS instances
    log "RDS Instances:"
    aws rds describe-db-instances --endpoint-url "$LOCALSTACK_ENDPOINT" --region "$AWS_REGION" || warn "Failed to describe instances"
    
    log "LocalStack setup verification completed."
}

# Main execution
main() {
    log "Starting LocalStack setup for Aurora Postgres simulation..."
    
    check_prerequisites
    configure_aws_cli
    create_subnet_group
    create_parameter_group
    create_aurora_cluster
    create_aurora_instance
    verify_setup
    
    log "LocalStack setup completed successfully!"
    log "You can now use Aurora Postgres simulation with LocalStack."
}

# Run main function
main "$@"
