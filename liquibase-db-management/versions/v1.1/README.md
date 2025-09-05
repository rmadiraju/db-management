# Version 1.1 - Product Catalog

## Overview
This version adds product catalog functionality to the database using Liquibase.

## Changes
- Created `products` table for product management
- Added check constraints for data integrity
- Added product-related indexes
- Added table and column comments
- Implemented proper rollback procedures

## Files
- `changelog-v1.1.xml` - Liquibase changelog for version 1.1

## Changesets
- `1.1-001`: Create products table
- `1.1-002`: Add check constraints for products table
- `1.1-003`: Create indexes for products table
- `1.1-004`: Add comments to products table and columns

## Dependencies
- Version 1.0 (users table)

## Rollback
To rollback this version, use:
```bash
./rollback-scripts/rollback.sh 1.1-001
```

## Validation
Run validation before deployment:
```bash
./validation-scripts/validate.sh
```
