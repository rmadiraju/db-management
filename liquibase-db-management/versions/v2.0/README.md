# Version 2.0 - Order Management

## Overview
This version adds order management functionality to the database using Liquibase.

## Changes
- Created `orders` table for order management
- Created `order_items` table for order line items
- Added foreign key relationships
- Added check constraints for data integrity
- Added order-related indexes
- Added table and column comments
- Implemented proper rollback procedures

## Files
- `changelog-v2.0.xml` - Liquibase changelog for version 2.0

## Changesets
- `2.0-001`: Create orders table
- `2.0-002`: Create order_items table
- `2.0-003`: Add foreign key constraints
- `2.0-004`: Add check constraints for orders and order_items
- `2.0-005`: Create indexes for orders and order_items tables
- `2.0-006`: Add comments to orders and order_items tables

## Dependencies
- Version 1.0 (users table)
- Version 1.1 (products table)

## Rollback
To rollback this version, use:
```bash
./rollback-scripts/rollback.sh 2.0-001
```

## Validation
Run validation before deployment:
```bash
./validation-scripts/validate.sh
```
