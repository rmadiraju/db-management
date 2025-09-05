# Deployment Guide

This guide provides step-by-step instructions for deploying the database management reference application.

## Prerequisites

### Required Software
- Java 17+
- Maven 3.6+
- Docker & Docker Compose
- PostgreSQL Client (psql)
- Flyway CLI (for Flyway management)
- Liquibase CLI (for Liquibase management)
- AWS CLI (for LocalStack)

### Required Services
- PostgreSQL Database
- LocalStack (for AWS simulation)

## Deployment Steps

### 1. Infrastructure Setup

#### Start PostgreSQL and LocalStack
```bash
cd spring-boot-app
docker-compose up -d postgres localstack

# Wait for services to be ready
docker-compose logs -f postgres localstack
```

#### Verify Services
```bash
# Check PostgreSQL
psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1;"

# Check LocalStack
curl http://localhost:4566/health
```

### 2. Database Schema Deployment

#### Option A: Using Flyway
```bash
cd flyway-db-management

# Validate scripts
./validation-scripts/validate.sh

# Deploy database
./execution-scripts/deploy.sh

# Verify deployment
flyway -configFiles=flyway.conf info
```

#### Option B: Using Liquibase
```bash
cd liquibase-db-management

# Validate changelogs
./validation-scripts/validate.sh

# Deploy database
./execution-scripts/deploy.sh

# Verify deployment
liquibase --defaults-file=liquibase.properties status
```

### 3. Application Deployment

#### Option A: Maven
```bash
cd spring-boot-app

# Build application
mvn clean package

# Run application
mvn spring-boot:run
```

#### Option B: Docker
```bash
cd spring-boot-app

# Build and run with Docker Compose
docker-compose up app

# Or build and run manually
docker build -t db-management-app .
docker run -p 8080:8080 db-management-app
```

### 4. Verification

#### Check Application Health
```bash
curl http://localhost:8080/api/actuator/health
```

#### Test API Endpoints
```bash
# Get all users
curl http://localhost:8080/api/users

# Get all products
curl http://localhost:8080/api/products

# Get all orders
curl http://localhost:8080/api/orders
```

## Environment Configuration

### Development Environment
- Database: PostgreSQL on localhost:5432
- LocalStack: http://localhost:4566
- Application: http://localhost:8080

### Production Environment
- Database: AWS Aurora Postgres
- AWS Services: Real AWS endpoints
- Application: Load balanced instances

## Rollback Procedures

### Database Rollback

#### Flyway Rollback
```bash
cd flyway-db-management

# Rollback to specific version
./rollback-scripts/rollback.sh 1.1
```

#### Liquibase Rollback
```bash
cd liquibase-db-management

# Rollback to specific changeset
./rollback-scripts/rollback.sh 1.1-001
```

### Application Rollback
```bash
# Stop current application
docker-compose down app

# Deploy previous version
docker-compose up app
```

## Monitoring and Maintenance

### Health Checks
- Application: `/api/actuator/health`
- Database: Connection status
- LocalStack: Service status

### Logs
- Application: `docker-compose logs -f app`
- Database: `docker-compose logs -f postgres`
- LocalStack: `docker-compose logs -f localstack`

### Backup Procedures
- Database backups are created automatically before deployments
- Backup files are stored in the respective management directories
- Manual backups can be created using pg_dump

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Check PostgreSQL status
   - Verify connection parameters
   - Ensure database exists

2. **Migration Failed**
   - Check script syntax
   - Verify naming conventions
   - Review validation logs

3. **Application Won't Start**
   - Check Java version
   - Verify Maven dependencies
   - Check application logs

### Debug Commands

```bash
# Check database connection
psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1;"

# Check LocalStack health
curl http://localhost:4566/health

# Check application health
curl http://localhost:8080/api/actuator/health

# View application logs
docker-compose logs -f app
```

## Security Considerations

### Database Security
- Use strong passwords
- Enable SSL connections
- Restrict network access
- Regular security updates

### Application Security
- Input validation
- SQL injection prevention
- Authentication and authorization
- HTTPS in production

## Performance Optimization

### Database Optimization
- Proper indexing
- Query optimization
- Connection pooling
- Regular maintenance

### Application Optimization
- Caching strategies
- Connection pooling
- Resource monitoring
- Load balancing

## Scaling Considerations

### Horizontal Scaling
- Load balancers
- Multiple application instances
- Database read replicas
- Caching layers

### Vertical Scaling
- Increased memory
- Faster CPUs
- SSD storage
- Network optimization
