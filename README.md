# Homelab Infrastructure as Code with Ansible and Docker Swarm

This repository contains Ansible playbooks and configuration for managing a homelab Docker Swarm cluster. The infrastructure is defined as code, allowing for consistent, repeatable deployments and easy maintenance.

## Start Command

`ansible-playbook -i ./inventory.yaml swarm.yml --ask-pass --ask-become-pass`

## Overview

Our homelab infrastructure uses:

- **Docker Swarm**: For container orchestration with high availability
- **Ansible**: For automated configuration and deployment
- **GlusterFS**: For distributed shared storage across nodes
- **Infrastructure as Code**: Everything defined in version-controlled configuration files

## Architecture

The Docker Swarm cluster consists of:
- 3 manager nodes for high availability and control plane redundancy
- 2 worker nodes for running containerized workloads
- Shared GlusterFS volume for persistent storage across all nodes

## Getting Started

1. Ensure Ansible is installed on your control node
2. Clone this repository
3. Update the inventory file with your node information
4. Run the main playbook: `ansible-playbook -i inventory.yaml swarm.yml`

## Benefits

- **Reproducible Environment**: Recover from failures or create identical test environments quickly
- **Version Control**: Track and roll back infrastructure changes with Git
- **Automated Management**: Reduce human error and simplify maintenance tasks
- **Scalability**: Easily add new nodes to the cluster as your homelab grows
