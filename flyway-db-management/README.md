# Flyway Database Management

This directory contains Flyway-based database management scripts for Aurora Postgres using LocalStack simulation.

## Structure

```
flyway-db-management/
├── scripts/
│   ├── ddl/                    # Data Definition Language scripts
│   └── dml/                    # Data Manipulation Language scripts
├── versions/                   # Version-specific documentation
│   ├── v1.0/                   # Initial schema
│   ├── v1.1/                   # Product catalog
│   └── v2.0/                   # Order management
├── execution-scripts/          # Deployment scripts
├── validation-scripts/         # Validation scripts
├── rollback-scripts/           # Rollback scripts
├── flyway.conf                 # Flyway configuration
└── flyway.properties           # Environment properties
```

## Prerequisites

1. **Flyway CLI**: Install Flyway command-line tool
2. **PostgreSQL**: Running PostgreSQL instance (simulating Aurora)
3. **LocalStack**: For AWS-like environment simulation

## Quick Start

### 1. Setup Database
```bash
# Start PostgreSQL (LocalStack simulation)
docker run -d --name postgres-localstack \
  -e POSTGRES_DB=aurora_postgres_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 postgres:13
```

### 2. Validate Scripts
```bash
./validation-scripts/validate.sh
```

### 3. Deploy Database
```bash
./execution-scripts/deploy.sh
```

### 4. Rollback (if needed)
```bash
./rollback-scripts/rollback.sh 1.1
```

## Script Naming Convention

Flyway scripts follow the pattern: `V{version}__{description}.sql`

Examples:
- `V1.0__Create_users_table.sql`
- `V1.1__Create_products_table.sql`
- `V2.0__Create_orders_table.sql`

## Validation Features

The validation script checks for:
- SQL syntax errors
- Flyway naming conventions
- Best practices (primary keys, timestamps, comments)
- Security issues (hardcoded passwords, DROP statements)
- Reserved keyword usage

## Version Management

Each version includes:
- DDL scripts for schema changes
- DML scripts for data changes
- Documentation in `versions/v{x.x}/README.md`
- Dependency information
- Rollback instructions

## AWS Aurora Simulation

This setup simulates AWS Aurora Postgres using:
- LocalStack for AWS service simulation
- PostgreSQL with Aurora-compatible settings
- Connection retry logic
- Schema management best practices

## Troubleshooting

### Common Issues

1. **Connection Failed**: Ensure PostgreSQL is running on localhost:5432
2. **Syntax Errors**: Run validation script to identify issues
3. **Migration Conflicts**: Check Flyway info for current state
4. **Rollback Issues**: Ensure backup exists before rollback

### Logs

- Deployment logs: `deployment.log`
- Rollback logs: `rollback.log`
- Validation logs: `validation.log`
