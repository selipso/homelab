# PostgreSQL with PGBouncer Setup

Simple PostgreSQL database with PGBouncer connection pooling for Docker Swarm.

## Quick Start

1. **Set up secrets:**
   ```bash
   cp group_vars/secrets.yml.example group_vars/secrets.yml
   ansible-vault edit group_vars/secrets.yml
   ```

2. **Generate MD5 hash for PGBouncer:**
   ```bash
   echo -n "your_passwordyour_username" | md5sum
   ```

3. **Deploy:**
   ```bash
   ansible-playbook -i inventory.yaml pgbouncer.yml --ask-vault-pass
   ```

## Required Secrets

In `group_vars/secrets.yml`:

```yaml
POSTGRES_USER: "postgres"
POSTGRES_PASSWORD: "your_secure_password"
POSTGRES_DB: "postgres"
POSTGRES_PASSWORD_MD5: "md5your_hash_here"
```

## Connection

- **PGBouncer (recommended):** `localhost:6432`
- **Direct PostgreSQL:** `localhost:5432`

## Directory Structure

```
/mnt/nfs/shared/db/
├── data/                    # PostgreSQL data
├── docker-entrypoint-initdb.d/  # Init scripts
└── config/
    ├── pgbouncer.ini       # PGBouncer config
    └── userlist.txt        # PGBouncer users
```

## Usage

```bash
# Connect via PGBouncer
psql -h localhost -p 6432 -U postgres -d postgres

# PGBouncer admin
psql -h localhost -p 6432 -U postgres -d pgbouncer
```

## Troubleshooting

```bash
# Check services
docker service ps pgbouncer_db
docker service ps pgbouncer_pgbouncer

# Check logs
docker service logs pgbouncer_db
docker service logs pgbouncer_pgbouncer
```
