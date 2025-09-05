# Version 1.1 - Product Catalog

## Overview
This version adds product catalog functionality to the database.

## Changes
- Created `products` table for product management
- Added product-related indexes
- Inserted sample product data

## Files
- `V1.1__Create_products_table.sql` - DDL for products table
- `V1.1__Insert_sample_products.sql` - DML for sample product data

## Dependencies
- Version 1.0 (users table)

## Rollback
To rollback this version, use:
```bash
./rollback-scripts/rollback.sh 1.0
```

## Validation
Run validation before deployment:
```bash
./validation-scripts/validate.sh
```
