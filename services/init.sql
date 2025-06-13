-- Minimal database initialization optimized for Prisma ORM
-- Creates app_user with proper migration permissions
-- Executed when initializing PostgreSQL in the docker init directory

\set pguser `echo "$POSTGRES_USER"`
\set pgpass `echo "$POSTGRES_PASSWORD"`

-- Create application user with migration capabilities
CREATE USER app_user WITH PASSWORD :'pgpass';

-- Grant database-level permissions
GRANT CONNECT ON DATABASE :"POSTGRES_DB" TO app_user;
GRANT CREATE ON DATABASE :"POSTGRES_DB" TO app_user;

-- Grant schema permissions (Prisma needs to create/modify schemas)
GRANT CREATE ON SCHEMA public TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON SCHEMA public TO app_user;

-- Grant default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO app_user;

-- Make app_user owner of public schema for full migration control
ALTER SCHEMA public OWNER TO app_user;

\echo 'Database ready for Prisma with single app_user for migrations and runtime'
