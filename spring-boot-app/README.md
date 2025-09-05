# Database Management Spring Boot Application

This Spring Boot application demonstrates database management with Aurora Postgres using LocalStack for AWS service simulation.

## Features

- **JPA Entities**: User, Product, Order, OrderItem entities with proper relationships
- **Repository Layer**: Spring Data JPA repositories with custom queries
- **Service Layer**: Business logic with transaction management
- **REST API**: RESTful endpoints for CRUD operations
- **LocalStack Integration**: AWS services simulation for development
- **Aurora Postgres**: PostgreSQL database with Aurora-compatible configuration
- **Validation**: Bean validation for data integrity
- **Testing**: Unit and integration tests with TestContainers

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   REST API      │    │   Service       │    │   Repository    │
│   Controllers   │───▶│   Layer         │───▶│   Layer         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
                                               ┌─────────────────┐
                                               │   PostgreSQL    │
                                               │   Database      │
                                               └─────────────────┘
```

## Technology Stack

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **PostgreSQL**
- **LocalStack**
- **AWS SDK v2**
- **Maven**
- **Docker & Docker Compose**

## Quick Start

### Prerequisites

- Java 17+
- Maven 3.6+
- Docker & Docker Compose

### 1. Start Infrastructure

```bash
# Start PostgreSQL and LocalStack
docker-compose up -d postgres localstack

# Wait for services to be ready
docker-compose logs -f postgres localstack
```

### 2. Run Application

```bash
# Build and run with Maven
mvn clean package
mvn spring-boot:run

# Or run with Docker
docker-compose up app
```

### 3. Access Application

- **Application**: http://localhost:8080/api
- **Health Check**: http://localhost:8080/api/actuator/health
- **Metrics**: http://localhost:8080/api/actuator/metrics

## API Endpoints

### Users

- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID
- `GET /api/users/username/{username}` - Get user by username
- `GET /api/users/active` - Get active users
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `PUT /api/users/{id}/activate` - Activate user
- `PUT /api/users/{id}/deactivate` - Deactivate user
- `DELETE /api/users/{id}` - Delete user

### Products

- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `GET /api/products/sku/{sku}` - Get product by SKU
- `GET /api/products/active` - Get active products
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### Orders

- `GET /api/orders` - Get all orders
- `GET /api/orders/{id}` - Get order by ID
- `GET /api/orders/user/{userId}` - Get orders by user
- `GET /api/orders/status/{status}` - Get orders by status
- `POST /api/orders` - Create new order
- `PUT /api/orders/{id}` - Update order
- `PUT /api/orders/{id}/status` - Update order status
- `DELETE /api/orders/{id}` - Delete order

## Database Schema

### Users Table
- `id` (Primary Key)
- `username` (Unique)
- `email` (Unique)
- `first_name`
- `last_name`
- `password_hash`
- `is_active`
- `created_at`
- `updated_at`

### Products Table
- `id` (Primary Key)
- `name`
- `description`
- `sku` (Unique)
- `price`
- `category_id`
- `stock_quantity`
- `is_active`
- `created_at`
- `updated_at`

### Orders Table
- `id` (Primary Key)
- `user_id` (Foreign Key)
- `order_number` (Unique)
- `status`
- `total_amount`
- `shipping_address`
- `billing_address`
- `created_at`
- `updated_at`

### Order Items Table
- `id` (Primary Key)
- `order_id` (Foreign Key)
- `product_id` (Foreign Key)
- `quantity`
- `unit_price`
- `total_price`
- `created_at`

## LocalStack Integration

The application uses LocalStack to simulate AWS services:

- **RDS**: Database service simulation
- **STS**: Security Token Service simulation
- **Endpoint**: http://localhost:4566

### AWS Configuration

```yaml
aws:
  region: us-east-1
  endpoint: http://localhost:4566
  access-key: test
  secret-key: test
```

## Development

### Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=UserServiceTest

# Run with coverage
mvn test jacoco:report
```

### Database Migrations

The application uses JPA for schema management. For production, consider using Flyway or Liquibase (see parent directories).

### Adding New Features

1. Create entity class
2. Create repository interface
3. Create service class
4. Create controller class
5. Add tests
6. Update documentation

## Production Considerations

- Use proper database migration tools (Flyway/Liquibase)
- Implement proper security (JWT, OAuth2)
- Add API documentation (OpenAPI/Swagger)
- Implement caching (Redis)
- Add monitoring and logging
- Use proper configuration management
- Implement CI/CD pipeline

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Ensure PostgreSQL is running
   - Check connection parameters
   - Verify database exists

2. **LocalStack Connection Failed**
   - Ensure LocalStack is running on port 4566
   - Check AWS configuration
   - Verify service endpoints

3. **Application Won't Start**
   - Check Java version (17+)
   - Verify Maven dependencies
   - Check application logs

### Logs

```bash
# Application logs
docker-compose logs -f app

# Database logs
docker-compose logs -f postgres

# LocalStack logs
docker-compose logs -f localstack
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Add tests
5. Submit pull request

## License

This project is licensed under the MIT License.
