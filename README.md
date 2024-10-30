# Monzo User Activity Analysis Project

## Overview
This dbt project transforms raw user activity data into analytics-ready models for tracking user engagement, account status, and cohort performance metrics.

## Table of Contents
- [Installation](#installation)
- [Project Setup](#project-setup)
- [Models Architecture](#models-architecture)
- [Key Metrics](#key-metrics)
- [Testing](#testing)
- [Development](#development)
- [Documentation](#documentation)

## Installation

### Prerequisites
- Python 3.8 or higher
- Google Cloud SDK
- BigQuery access

### 1. Install dbt

#### Option A: Using pip (recommended)
```bash
# Create virtual environment
python -m venv dbt-env

# Activate environment
# Windows:
dbt-env\Scripts\activate
# macOS/Linux:
source dbt-env/bin/activate

# Install dbt
pip install dbt-bigquery
```

### 2. Verify Installation
```bash
dbt --version
```

### 3. Configure BigQuery Authentication

1. Install Google Cloud SDK:
   - Download from: https://cloud.google.com/sdk/docs/install

2. Setup Authentication:
```bash
# Initialize Google Cloud
gcloud init

# Setup application credentials
gcloud auth application-default login
```

3. Configure `~/.dbt/profiles.yml`:
```yaml
monzo:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: analytics-take-home-test
      dataset: Monzo_datawarehouse
      threads: 4
      timeout_seconds: 300
```

## Project Setup

1. Clone Repository:
```bash
git clone [repository-url]
cd monzo
```

2. Install Dependencies:
```bash
dbt deps
```

3. Verify Connection:
```bash
dbt debug
```

4. Build Project:
```bash
dbt build
```

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

### Account Status Categories
- Not Activated
- Closed
- Very Active (< 30 days)
- Active (31-90 days)
- Inactive (91-180 days)
- Dormant (> 180 days)

## Project Structure
```
monzo/
├── analyses/        # Ad-hoc analyses
├── macros/         # Custom SQL macros
│   └── custom_tests/   # Custom test definitions
├── models/         # Data transformation models
│   ├── staging/        # Raw data cleaning
│   ├── intermediate/   # Business logic layer
│   └── dimensions/     # Final presentation layer
├── seeds/          # Static data files
├── snapshots/      # Slowly changing dimension configs
└── tests/          # Custom data tests
```

## Testing

### Test Types
- Unique key constraints
- Referential integrity
- Accepted values
- Custom data quality tests

### Key Test Files
- `models/intermediate/intermediate_models.yml`
- `models/marts/mart_models.yml`
- `tests/assert_closed_after_created.sql`


### Key Documentation Files
- Model documentation in YAML files
- Technical documentation via dbt docs
- README.md for project overview