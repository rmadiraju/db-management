# Version 1.0 - Initial Database Schema

## Overview
This version contains the initial database schema with basic user management functionality.

## Changes
- Created `users` table with basic user information
- Added indexes for performance optimization
- Inserted sample user data

## Files
- `V1.0__Create_users_table.sql` - DDL for users table
- `V1.0__Insert_sample_users.sql` - DML for sample user data

## Dependencies
- None (initial version)

## Rollback
To rollback this version, use:
```bash
./rollback-scripts/rollback.sh 0.0
```

## Validation
Run validation before deployment:
```bash
./validation-scripts/validate.sh
```
