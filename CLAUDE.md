# CLAUDE.md
This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Workflow

### Service Deployment Workflow
1. **Create/Modify Service Definition**:
   - Start with a base Docker Compose file in the `services/` directory
   - Ensure proper image, port mappings, volumes, and environment variables

2. **Create Swarm Template**:
   - Convert the service file to a Swarm-compatible template in `templates/<service>-stack.yml.j2`
   - Replace environment variables with Jinja2 variables (e.g., `{{ VARIABLE_NAME }}`)
   - Add Swarm-specific configurations (replicas, placement constraints, etc.)
   - Ensure proper network configuration (`proxy` network and service-specific network)

3. **Create Ansible Playbook**:
   - Create a new playbook named `<service>.yml` in the root directory
   - Include network creation, secret variables, directory creation, and stack deployment
   - Follow the established pattern from existing playbooks

4. **Deploy the Service**:
   - Run the Ansible playbook to deploy the service to the Swarm cluster

## Common Commands

### Deploy the Swarm Infrastructure
```bash
ansible-playbook -i ./inventory.yaml swarm.yml --ask-pass --ask-become-pass
```
Note: Run `ssh-add` if using SSH keys with passphrases.

### Deploy Service Stacks
```bash
# Deploy Database Stack (PostgreSQL, PGBouncer, pgAdmin)
ansible-playbook -i ./inventory.yaml database.yml --ask-vault-pass --ask-become-pass

# Deploy Immich (photo management)
ansible-playbook -i ./inventory.yaml immich.yml --ask-vault-pass --ask-become-pass

# Deploy Meilisearch
ansible-playbook -i ./inventory.yaml meilisearch.yml --ask-vault-pass --ask-become-pass

# Deploy other services
ansible-playbook -i ./inventory.yaml <service-name>.yml --ask-vault-pass --ask-become-pass
```

### Service Development Workflow
```bash
# 1. Edit or create a service definition
nano services/<service-name>.yml

# 2. Create a Swarm template from the service definition
nano templates/<service-name>-stack.yml.j2

# 3. Create or edit the deployment playbook
nano <service-name>.yml

# 4. Deploy the service
ansible-playbook -i ./inventory.yaml <service-name>.yml --ask-vault-pass --ask-become-pass
```

### Check Service Status
```bash
# SSH into first manager node and check stack status
ssh yatit@192.168.1.23 "docker stack ls"
ssh yatit@192.168.1.23 "docker service ls"
```

## Architecture Overview
This homelab uses Infrastructure as Code with Ansible to manage a Docker Swarm cluster:

### Cluster Layout
- **3 Manager Nodes**: High availability control plane (192.168.1.22, 192.168.1.23, 192.168.1.24)
- **2 Worker Nodes**: Running containerized workloads (192.168.1.16, 192.168.1.25)
- **Shared Storage**: NFS volume mounted at `/mnt/nfs/shared/` across all nodes

### Service Deployment Pattern
1. Each service starts with a standard "docker compose" file syntax stored in `services/`. Some of these are just copy and pasted from existing projects.
2. The service is then converted to a swarm mode docker stack in the services directory. The `services/` directory contains .yml files.
3. This stack file is converted to Jinja2 template syntax with all environment variables replaced by the double curly brace (`{{ }}`) . These are then stored in the `templates/` directory.
4. Each service has its own Ansible playbook (named after the service, e.g., `immich.yml`, `affine.yml`) that:
   - Ensures necessary overlay networks exist (`proxy` and service-specific networks)
   - Includes encrypted variables from `group_vars/secrets.yml`
   - Creates required directories on NFS shared storage
   - Renders the Jinja2 template to a temporary directory
   - Deploys the stack to Docker Swarm on the first manager node
   - Cleans up temporary files
5. Secrets are stored in encrypted `group_vars/secrets.yml` (use `ansible-vault` to edit)
6. Services use overlay networks (`proxy`, service-specific networks) for inter-service communication
7. Deployments target the first manager node using `community.docker.docker_stack`

### Key Files Structure
- `inventory.yaml` - Defines cluster nodes and groups
- `swarm.yml` - Main playbook for Docker/Swarm setup
- `services/` - Docker Compose source files (standard compose format)
- `templates/` - Jinja2 templates for stack deployments (Swarm mode with variables)
- `group_vars/secrets.yml` - Encrypted variables (ANSIBLE_VAULT)
- `<service>.yml` - Individual service deployment playbooks in root directory

### Network Architecture
- `proxy` network: Shared overlay network for services behind reverse proxy
- Service-specific networks: Isolated overlay networks per service stack
- All networks are created as attachable overlay networks before stack deployment

## Best Practices for Service Configuration

### Docker Compose to Swarm Template Conversion
1. **Remove `container_name`** - Swarm manages container names automatically
2. **Add deployment configuration**:
   ```yaml
   deploy:
     replicas: 1
   ```
3. **Use external networks** - Define service-specific networks as external
4. **Store persistent data on NFS** - Use `/mnt/nfs/shared/<service-name>/` for volumes
5. **Replace environment variables** with Jinja2 variables (`{{ VARIABLE_NAME }}`)
6. **Include healthchecks** for dependencies where possible

### Template to Playbook Integration
1. Create networks in the playbook before deploying stack
2. Include encrypted variables with `ansible.builtin.include_vars`
3. Create necessary directories on NFS share
4. Use a temporary directory for stack file generation
5. Deploy using `community.docker.docker_stack` module
6. Clean up temporary files after successful deployment

## Database Stack Architecture

The database stack provides a unified PostgreSQL database with connection pooling and management interface:

### Components
- **PostgreSQL 17**: Primary database server (only accessible via PGBouncer)
- **PGBouncer**: Connection pooler with SCRAM-SHA-256 authentication
- **pgAdmin**: Web-based database management interface

### Network Topology
- `db` network: Internal network for PostgreSQL ↔ PGBouncer communication
- `postgres` network: Application connection network (PGBouncer ↔ services)
- `proxy` network: pgAdmin web interface access

### Connecting Applications
When deploying server-side applications that need database access:
1. Add the service to the `postgres` network
2. Connect to hostname `db` on port `6432` (this routes through PGBouncer)
3. Use the credentials from `group_vars/secrets.yml`

Example service configuration:
```yaml
services:
  myapp:
    image: myapp:latest
    environment:
      DATABASE_URL: postgresql://{{ POSTGRES_USER }}:{{ POSTGRES_PASSWORD }}@db:6432/{{ POSTGRES_DB }}
    networks:
      - postgres
      - proxy  # if web-accessible

networks:
  postgres:
    external: true
  proxy:
    external: true
```
