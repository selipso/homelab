# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Deploy the Swarm Infrastructure
```bash
ansible-playbook -i ./inventory.yaml swarm.yml --ask-pass --ask-become-pass
```
Note: Run `ssh-add` if using SSH keys with passphrases.

### Deploy Service Stacks
```bash
# Deploy Database Stack (PostgreSQL, PGBouncer, pgAdmin)
ansible-playbook -i ./inventory.yaml database.yml --ask-pass --ask-become-pass

# Deploy Immich (photo management)
ansible-playbook -i ./inventory.yaml immich.yml --ask-pass --ask-become-pass

# Deploy Meilisearch
ansible-playbook -i ./inventory.yaml meilisearch.yml --ask-pass --ask-become-pass

# Deploy other services
ansible-playbook -i ./inventory.yaml <service-name>.yml --ask-pass --ask-become-pass
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
1. Each service has a dedicated Ansible playbook (e.g., `immich.yml`, `meilisearch.yml`)
2. Playbooks use Jinja2 templates from `templates/` to render Docker Compose files
3. Secrets are stored in encrypted `group_vars/secrets.yml` (use `ansible-vault` to edit)
4. Services use overlay networks (`proxy`, service-specific networks) for inter-service communication
5. Deployments target the first manager node using `community.docker.docker_stack`

### Key Files Structure
- `inventory.yaml` - Defines cluster nodes and groups
- `swarm.yml` - Main playbook for Docker/Swarm setup
- `services/` - Docker Compose source files
- `templates/` - Jinja2 templates for stack deployments
- `group_vars/secrets.yml` - Encrypted variables (ANSIBLE_VAULT)

### Network Architecture
- `proxy` network: Shared overlay network for services behind reverse proxy
- Service-specific networks: Isolated overlay networks per service stack
- All networks are created as attachable overlay networks before stack deployment

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
