# Version 2.0 - Order Management

## Overview
This version adds order management functionality to the database.

## Changes
- Created `orders` table for order management
- Created `order_items` table for order line items
- Added foreign key relationships
- Added order-related indexes

## Files
- `V2.0__Create_orders_table.sql` - DDL for orders and order_items tables

## Dependencies
- Version 1.0 (users table)
- Version 1.1 (products table)

## Rollback
To rollback this version, use:
```bash
./rollback-scripts/rollback.sh 1.1
```

## Validation
Run validation before deployment:
```bash
./validation-scripts/validate.sh
```
