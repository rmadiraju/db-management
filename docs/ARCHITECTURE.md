# Architecture Documentation

This document describes the architecture of the database management reference application.

## System Overview

The application consists of three main components:

1. **Flyway Database Management** - SQL-based database migrations
2. **Liquibase Database Management** - XML-based database changes
3. **Spring Boot Application** - REST API with JPA entities

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Database Management Layer                     │
├─────────────────────────────────────────────────────────────────┤
│  Flyway Management          │  Liquibase Management              │
│  ┌─────────────────────┐   │  ┌─────────────────────┐            │
│  │   DDL Scripts       │   │  │   Changelog Files   │            │
│  │   DML Scripts       │   │  │   Changesets        │            │
│  │   Version Control   │   │  │   Rollback Procs    │            │
│  └─────────────────────┘   │  └─────────────────────┘            │
├─────────────────────────────────────────────────────────────────┤
│                    Validation & Execution Layer                  │
├─────────────────────────────────────────────────────────────────┤
│  Validation Scripts        │  Execution Scripts                 │
│  ┌─────────────────────┐   │  ┌─────────────────────┐            │
│  │   Syntax Check      │   │  │   Deployment        │            │
│  │   Naming Conventions│   │  │   Rollback          │            │
│  │   Best Practices    │   │  │   Backup            │            │
│  └─────────────────────┘   │  └─────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Spring Boot Application                       │
├─────────────────────────────────────────────────────────────────┤
│  REST API Layer                                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  UserController  │  ProductController  │  OrderController  ││
│  └─────────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────────┤
│  Service Layer                                                  │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  UserService     │  ProductService     │  OrderService     ││
│  └─────────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────────┤
│  Repository Layer                                               │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  UserRepository  │  ProductRepository  │  OrderRepository  ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Data Layer                                   │
├─────────────────────────────────────────────────────────────────┤
│  JPA Entities                                                   │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  User           │  Product         │  Order                ││
│  │  OrderItem      │  Relationships   │  Constraints          ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Infrastructure Layer                         │
├─────────────────────────────────────────────────────────────────┤
│  PostgreSQL Database    │  LocalStack (AWS Simulation)          │
│  ┌─────────────────┐    │  ┌─────────────────┐                  │
│  │   Aurora        │    │  │   RDS Service    │                  │
│  │   Postgres      │    │  │   STS Service    │                  │
│  │   Database      │    │  │   Endpoints      │                  │
│  └─────────────────┘    │  └─────────────────┘                  │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Database Management Layer

#### Flyway Management
- **Purpose**: SQL-based database migrations
- **Features**: Version control, rollback, validation
- **Structure**: DDL/DML scripts with versioning
- **Execution**: Automated deployment scripts

#### Liquibase Management
- **Purpose**: XML-based database changes
- **Features**: Changesets, rollback procedures, validation
- **Structure**: Changelog files with changesets
- **Execution**: Automated deployment scripts

### 2. Validation & Execution Layer

#### Validation Scripts
- **Syntax Validation**: SQL and XML syntax checks
- **Naming Conventions**: Tool-specific naming rules
- **Best Practices**: Primary keys, timestamps, comments
- **Security Checks**: Password and permission validation

#### Execution Scripts
- **Deployment**: Automated database deployment
- **Rollback**: Safe rollback mechanisms
- **Backup**: Automatic backup creation
- **Verification**: Post-deployment verification

### 3. Spring Boot Application

#### REST API Layer
- **Controllers**: RESTful endpoints for CRUD operations
- **Validation**: Request validation and error handling
- **Documentation**: API documentation and examples

#### Service Layer
- **Business Logic**: Application-specific business rules
- **Transaction Management**: Database transaction handling
- **Error Handling**: Exception handling and logging

#### Repository Layer
- **Data Access**: Spring Data JPA repositories
- **Custom Queries**: Complex query implementations
- **Performance**: Optimized database queries

### 4. Data Layer

#### JPA Entities
- **User**: User account management
- **Product**: Product catalog management
- **Order**: Order management
- **OrderItem**: Order line items

#### Relationships
- **One-to-Many**: User to Orders
- **One-to-Many**: Order to OrderItems
- **Many-to-One**: OrderItem to Product

### 5. Infrastructure Layer

#### PostgreSQL Database
- **Aurora Postgres**: AWS-compatible PostgreSQL
- **LocalStack Simulation**: Local AWS services simulation
- **Connection Management**: Connection pooling and retry logic

#### LocalStack Integration
- **RDS Service**: Database service simulation
- **STS Service**: Security token service simulation
- **AWS SDK**: AWS SDK v2 integration

## Data Flow

### 1. Database Deployment Flow

```
Developer → Validation Scripts → Execution Scripts → Database
    │              │                    │
    │              ▼                    ▼
    │         Syntax Check         Deployment
    │         Naming Check         Backup
    │         Best Practices       Verification
    │         Security Check
    │
    ▼
Rollback Scripts (if needed)
```

### 2. Application Request Flow

```
Client → REST API → Service Layer → Repository Layer → Database
  │         │            │              │
  │         ▼            ▼              ▼
  │    Validation    Business Logic   Data Access
  │    Error Handling Transaction     Custom Queries
  │    Response       Management      Performance
  │
  ▼
Response
```

## Security Architecture

### Database Security
- **Connection Security**: SSL/TLS encryption
- **Authentication**: Username/password authentication
- **Authorization**: Role-based access control
- **Data Encryption**: At-rest and in-transit encryption

### Application Security
- **Input Validation**: Request validation and sanitization
- **SQL Injection Prevention**: Parameterized queries
- **Authentication**: User authentication mechanisms
- **Authorization**: Role-based access control

## Performance Architecture

### Database Performance
- **Indexing**: Strategic index placement
- **Query Optimization**: Efficient query design
- **Connection Pooling**: Database connection management
- **Caching**: Query result caching

### Application Performance
- **Caching**: Application-level caching
- **Connection Pooling**: Database connection pooling
- **Resource Management**: Memory and CPU optimization
- **Load Balancing**: Horizontal scaling support

## Scalability Architecture

### Horizontal Scaling
- **Load Balancers**: Traffic distribution
- **Multiple Instances**: Application instance scaling
- **Database Replicas**: Read replica support
- **Caching Layers**: Distributed caching

### Vertical Scaling
- **Resource Scaling**: CPU and memory scaling
- **Storage Scaling**: Storage capacity scaling
- **Network Scaling**: Network bandwidth scaling

## Monitoring Architecture

### Application Monitoring
- **Health Checks**: Application health monitoring
- **Metrics**: Performance metrics collection
- **Logging**: Centralized logging
- **Alerting**: Automated alerting

### Database Monitoring
- **Connection Monitoring**: Database connection monitoring
- **Query Performance**: Query performance monitoring
- **Resource Usage**: Database resource monitoring
- **Backup Monitoring**: Backup status monitoring

## Deployment Architecture

### Development Environment
- **Local Development**: Local database and services
- **Docker Compose**: Local service orchestration
- **LocalStack**: AWS services simulation
- **Hot Reload**: Development-time hot reloading

### Production Environment
- **Container Orchestration**: Kubernetes or Docker Swarm
- **Load Balancing**: Application load balancing
- **Database Clustering**: Database high availability
- **Monitoring**: Production monitoring and alerting

## Technology Stack

### Database Management
- **Flyway**: Database migration tool
- **Liquibase**: Database change management
- **PostgreSQL**: Database system
- **Aurora Postgres**: AWS database service

### Application Framework
- **Spring Boot**: Application framework
- **Spring Data JPA**: Data access framework
- **Spring Web**: Web framework
- **Spring Validation**: Validation framework

### Infrastructure
- **Docker**: Containerization
- **Docker Compose**: Service orchestration
- **LocalStack**: AWS services simulation
- **AWS SDK**: AWS services integration

### Development Tools
- **Maven**: Build tool
- **Java 17**: Programming language
- **JUnit**: Testing framework
- **TestContainers**: Integration testing
