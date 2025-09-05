# Database Management Reference Application

A comprehensive reference application demonstrating database management using Flyway and Liquibase with Aurora Postgres, featuring a Spring Boot application with LocalStack integration.

## 🏗️ Project Structure

```
db-management/
├── flyway-db-management/          # Flyway-based database management
│   ├── scripts/
│   │   ├── ddl/                   # Data Definition Language scripts
│   │   └── dml/                   # Data Manipulation Language scripts
│   ├── versions/                  # Version-specific documentation
│   ├── execution-scripts/         # Deployment scripts
│   ├── validation-scripts/       # Validation scripts
│   └── rollback-scripts/         # Rollback scripts
├── liquibase-db-management/       # Liquibase-based database management
│   ├── scripts/
│   │   ├── versions/              # Version-specific changelogs
│   │   └── dml/                   # Data Manipulation Language scripts
│   ├── versions/                  # Version-specific documentation
│   ├── execution-scripts/         # Deployment scripts
│   ├── validation-scripts/       # Validation scripts
│   └── rollback-scripts/         # Rollback scripts
├── spring-boot-app/              # Spring Boot application
│   ├── src/main/java/            # Java source code
│   ├── src/test/java/            # Test source code
│   ├── scripts/                  # Setup and utility scripts
│   └── docker-compose.yml        # Docker Compose configuration
└── docs/                         # Additional documentation
```

## 🚀 Quick Start

### Prerequisites

- **Java 17+**
- **Maven 3.6+**
- **Docker & Docker Compose**
- **PostgreSQL Client** (psql)
- **Flyway CLI** (for Flyway management)
- **Liquibase CLI** (for Liquibase management)

### 1. Start Infrastructure

```bash
# Start PostgreSQL and LocalStack
cd spring-boot-app
docker-compose up -d postgres localstack

# Wait for services to be ready
docker-compose logs -f postgres localstack
```

### 2. Setup LocalStack (Optional)

```bash
# Configure LocalStack for AWS services simulation
cd spring-boot-app
./scripts/setup-localstack.sh
```

### 3. Deploy Database Schema

#### Using Flyway
```bash
cd flyway-db-management

# Validate scripts
./validation-scripts/validate.sh

# Deploy database
./execution-scripts/deploy.sh
```

#### Using Liquibase
```bash
cd liquibase-db-management

# Validate changelogs
./validation-scripts/validate.sh

# Deploy database
./execution-scripts/deploy.sh
```

### 4. Run Spring Boot Application

```bash
cd spring-boot-app

# Build and run
mvn clean package
mvn spring-boot:run

# Or run with Docker
docker-compose up app
```

### 5. Access Application

- **Application**: http://localhost:8080/api
- **Health Check**: http://localhost:8080/api/actuator/health
- **API Documentation**: http://localhost:8080/api/swagger-ui.html

## 📊 Database Schema

The application manages the following entities:

### Users Table
- User accounts with authentication information
- Includes username, email, password hash, and status

### Products Table
- Product catalog with pricing and inventory
- Includes SKU, price, stock quantity, and category

### Orders Table
- Customer orders with status tracking
- Includes order number, total amount, and addresses

### Order Items Table
- Order line items with product details
- Includes quantity, unit price, and total price

## 🔧 Database Management Tools

### Flyway
- **Version Control**: SQL-based migrations with versioning
- **Rollback**: Clean and migrate approach
- **Validation**: Syntax and naming convention checks
- **Execution**: Automated deployment scripts

### Liquibase
- **Version Control**: XML-based changelogs with changesets
- **Rollback**: Built-in rollback procedures
- **Validation**: XML syntax and schema validation
- **Execution**: Automated deployment scripts

## 🛠️ Features

### Database Management
- ✅ **DDL Scripts**: Table creation, indexes, constraints
- ✅ **DML Scripts**: Sample data insertion
- ✅ **Version Management**: Multiple version support
- ✅ **Rollback Procedures**: Safe rollback mechanisms
- ✅ **Validation**: Syntax and best practice checks
- ✅ **Execution Scripts**: Automated deployment
- ✅ **AWS Simulation**: LocalStack integration

### Spring Boot Application
- ✅ **JPA Entities**: Complete entity mapping
- ✅ **Repository Layer**: Spring Data JPA repositories
- ✅ **Service Layer**: Business logic with transactions
- ✅ **REST API**: CRUD operations for all entities
- ✅ **Validation**: Bean validation for data integrity
- ✅ **Testing**: Unit and integration tests
- ✅ **Docker Support**: Containerized deployment

### Validation Features
- ✅ **Syntax Validation**: SQL and XML syntax checks
- ✅ **Naming Conventions**: Tool-specific naming rules
- ✅ **Best Practices**: Primary keys, timestamps, comments
- ✅ **Security Checks**: Password and permission validation
- ✅ **Dependency Checks**: Foreign key relationships

## 📋 API Endpoints

### Users
- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user

### Products
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### Orders
- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `POST /api/orders` - Create new order
- `PUT /api/orders/{id}` - Update order
- `DELETE /api/orders/{id}` - Delete order

## 🔄 Version Management

### Version 1.0 - Initial Schema
- Users table with basic functionality
- Indexes and constraints
- Sample user data

### Version 1.1 - Product Catalog
- Products table with inventory management
- Check constraints for data integrity
- Sample product data

### Version 2.0 - Order Management
- Orders and order items tables
- Foreign key relationships
- Order status management

## 🧪 Testing

### Database Management
```bash
# Test Flyway deployment
cd flyway-db-management
./execution-scripts/deploy.sh

# Test Liquibase deployment
cd liquibase-db-management
./execution-scripts/deploy.sh
```

### Spring Boot Application
```bash
cd spring-boot-app

# Run unit tests
mvn test

# Run integration tests
mvn verify

# Run with TestContainers
mvn test -Dtestcontainers.enabled=true
```

## 🐳 Docker Support

### Infrastructure
```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d postgres localstack

# View logs
docker-compose logs -f
```

### Application
```bash
# Build application image
docker build -t db-management-app .

# Run application
docker run -p 8080:8080 db-management-app
```

## 🔍 Monitoring and Logging

### Health Checks
- **Application Health**: `/api/actuator/health`
- **Database Health**: Connection status
- **LocalStack Health**: AWS services status

### Logs
- **Application Logs**: Spring Boot logging
- **Database Logs**: PostgreSQL logs
- **LocalStack Logs**: AWS service simulation logs

## 🚨 Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Ensure PostgreSQL is running
   - Check connection parameters
   - Verify database exists

2. **Migration Failed**
   - Check script syntax
   - Verify naming conventions
   - Review validation logs

3. **LocalStack Connection Failed**
   - Ensure LocalStack is running on port 4566
   - Check AWS configuration
   - Verify service endpoints

### Debug Commands

```bash
# Check database connection
psql -h localhost -p 5432 -U postgres -d aurora_postgres_db -c "SELECT 1;"

# Check LocalStack health
curl http://localhost:4566/health

# Check application health
curl http://localhost:8080/api/actuator/health
```

## 📚 Documentation

- [Flyway Database Management](flyway-db-management/README.md)
- [Liquibase Database Management](liquibase-db-management/README.md)
- [Spring Boot Application](spring-boot-app/README.md)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Add tests
5. Submit pull request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- **Flyway**: Database migration tool
- **Liquibase**: Database change management
- **Spring Boot**: Application framework
- **LocalStack**: AWS services simulation
- **PostgreSQL**: Database system
- **Docker**: Containerization platform
