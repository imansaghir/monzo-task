# User Activity Analysis Project

## Overview
This dbt project transforms raw user activity data into analytics-ready models.

## Models Architecture

### Staging Layer (`/models/staging/`)
Raw data cleaning and standardization for:
- Account Creation Events
- Account Closure Events
- Account Reopening Events
- Transaction Events

### Intermediate Layer (`/models/intermediate/`)
- `int_daily_user_status`: Daily snapshot of user activity status
  - Tracks account open/closed status
  - 7-day activity window
  - Incrementally processed
- `int_Accounts`: Consolidated account information

### Mart Layer (`/models/dimensions/`)
- `mart_daily_user_activity`: 
  - Daily and monthly cohort tracking
  - Activity rates
- `mart_accounts`: Account dimension table

## Key Metrics

### Activity Metrics
- **Active Rate**: % of open accounts active in last 7 days
- **Active Users**: Count of users with activity in last 7 days
- **Total Users**: Count of users with open accounts

## Getting Started

### Prerequisites
- dbt version 1.8.8 or higher
- BigQuery access
- Python 3.8 or higher


## Testing
The project includes several types of tests:
- Unique key constraints
- Referential integrity
- Accepted values
- Custom data quality tests

Key test files:
- `models/intermediate/intermediate_models.yml`
- `models/marts/mart_models.yml`
- `tests/assert_closed_after_created.sql`

## Documentation
- Model documentation in YAML files
- dbt docs for technical documentation
