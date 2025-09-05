# Liquibase Database Management

This directory contains Liquibase-based database management scripts for Aurora Postgres using LocalStack simulation.

## Structure

```
liquibase-db-management/
├── scripts/
│   ├── db-changelog.xml              # Main changelog (XML-based DDL)
│   ├── db-changelog-sql.xml          # SQL file-based DDL changelog
│   ├── db-changelog-complete.xml     # Complete changelog (DDL + DML)
│   ├── ddl/                          # Standalone DDL SQL files
│   │   ├── 01-create-users-table.sql
│   │   ├── 02-create-products-table.sql
│   │   └── 03-create-orders-table.sql
│   ├── dml/                          # Standalone DML SQL files
│   │   ├── 01-insert-sample-users.sql
│   │   ├── 02-insert-sample-products.sql
│   │   └── insert-sample-data.xml    # XML-based DML
│   └── versions/                     # Version-specific changelogs
│       ├── v1.0/
│       │   └── changelog-v1.0.xml
│       ├── v1.1/
│       │   └── changelog-v1.1.xml
│       └── v2.0/
│           └── changelog-v2.0.xml
├── versions/                         # Version-specific documentation
│   ├── v1.0/                         # Initial schema
│   ├── v1.1/                         # Product catalog
│   └── v2.0/                         # Order management
├── execution-scripts/                # Deployment scripts
│   ├── deploy.sh                     # XML-based deployment
│   └── deploy-sql.sh                 # SQL file-based deployment
├── validation-scripts/               # Validation scripts
├── rollback-scripts/                 # Rollback scripts
├── liquibase.conf                    # Liquibase configuration
├── liquibase.properties             # Environment properties
└── liquibase-complete.properties    # Complete configuration
```

## Prerequisites

1. **Liquibase CLI**: Install Liquibase command-line tool
2. **PostgreSQL**: Running PostgreSQL instance (simulating Aurora)
3. **LocalStack**: For AWS-like environment simulation
4. **PostgreSQL JDBC Driver**: Required for Liquibase

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

### 2. Choose Deployment Approach

#### Option A: XML-based DDL (Original Approach)
```bash
# Validate changelogs
./validation-scripts/validate.sh

# Deploy database
./execution-scripts/deploy.sh
```

#### Option B: SQL File-based DDL (New Approach)
```bash
# Validate SQL files and changelogs
./validation-scripts/validate.sh

# Deploy database using standalone SQL files
./execution-scripts/deploy-sql.sh
```

### 3. Rollback (if needed)
```bash
# Rollback to specific changeset
./rollback-scripts/rollback.sh 1.1-001
```

## Deployment Approaches

### Approach 1: XML-based DDL (Embedded)
- **Pros**: All changes in XML, version control friendly
- **Cons**: DDL embedded in XML, harder to read
- **Files**: `db-changelog.xml`, `changelog-v*.xml`
- **Script**: `deploy.sh`

### Approach 2: SQL File-based DDL (Standalone)
- **Pros**: DDL in separate SQL files, easier to read and edit
- **Cons**: More files to manage
- **Files**: `db-changelog-complete.xml`, `scripts/ddl/*.sql`
- **Script**: `deploy-sql.sh`

## Changeset Naming Convention

Liquibase changesets follow the pattern: `{version}-{sequence}`

Examples:
- `1.0-001`: Version 1.0, first changeset
- `1.1-001`: Version 1.1, first changeset
- `2.0-001`: Version 2.0, first changeset

## Validation Features

The validation script checks for:
- XML syntax validation
- Liquibase schema validation
- SQL file syntax validation
- Changeset naming conventions
- Best practices (comments, rollbacks, constraints)
- Security issues (hardcoded passwords, DROP statements)

## Version Management

Each version includes:
- XML changelog files with proper rollback procedures
- Standalone SQL files for DDL and DML
- Documentation in `versions/v{x.x}/README.md`
- Dependency information
- Rollback instructions

## Liquibase Features Used

- **Changesets**: Atomic database changes
- **Rollback**: Automatic rollback procedures
- **SQL Files**: Standalone SQL file execution
- **Constraints**: Check constraints and foreign keys
- **Indexes**: Performance optimization
- **Comments**: Documentation in database
- **Preconditions**: Conditional execution

## AWS Aurora Simulation

This setup simulates AWS Aurora Postgres using:
- LocalStack for AWS service simulation
- PostgreSQL with Aurora-compatible settings
- Connection retry logic
- Schema management best practices

## Troubleshooting

### Common Issues

1. **Connection Failed**: Ensure PostgreSQL is running on localhost:5432
2. **XML Syntax Errors**: Run validation script to identify issues
3. **SQL File Errors**: Check SQL file syntax and paths
4. **Changeset Conflicts**: Check Liquibase status for current state
5. **Rollback Issues**: Ensure backup exists before rollback

### Logs

- Deployment logs: `deployment.log`
- SQL deployment logs: `deployment-sql.log`
- Rollback logs: `rollback.log`
- Validation logs: `validation.log`

## Liquibase Commands

### Basic Commands
```bash
# Update database (XML-based)
liquibase --defaults-file=liquibase.properties update

# Update database (SQL-based)
liquibase --defaults-file=liquibase-complete.properties update

# Check status
liquibase --defaults-file=liquibase.properties status

# Rollback to changeset
liquibase --defaults-file=liquibase.properties rollback <changeset-id>

# Validate changelog
liquibase --defaults-file=liquibase.properties validate
```

### Advanced Commands
```bash
# Generate SQL without executing
liquibase --defaults-file=liquibase.properties updateSQL

# Generate rollback SQL
liquibase --defaults-file=liquibase.properties rollbackSQL <changeset-id>

# Clear checksums
liquibase --defaults-file=liquibase.properties clearCheckSums
```

## File Structure Comparison

### XML-based Approach
```
scripts/
├── db-changelog.xml
├── versions/
│   ├── v1.0/changelog-v1.0.xml
│   ├── v1.1/changelog-v1.1.xml
│   └── v2.0/changelog-v2.0.xml
└── dml/insert-sample-data.xml
```

### SQL File-based Approach
```
scripts/
├── db-changelog-complete.xml
├── ddl/
│   ├── 01-create-users-table.sql
│   ├── 02-create-products-table.sql
│   └── 03-create-orders-table.sql
└── dml/
    ├── 01-insert-sample-users.sql
    └── 02-insert-sample-products.sql
```

Both approaches are valid and can be used depending on your team's preferences and requirements.
