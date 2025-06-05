## Services and their Reference Compose Files

This folder contains reference compose files for each service. Although not every service here is deployed, they are starting points for deploying the services. In a multi-node environment, these compose files would generally be converted to a swarm stack or a Kubernetes deployment. In a single-node environment, these compose files can be used as a starting point for deploying the services.

For my personal use, these compose files are converted to Jinja templates for deployment on my home lab with Ansible playbooks. This pattern is inspired by [this article](https://rostislavjadavan.com/posts/deploying-to-docker-swarm-using-ansible). These Jinja templates can be found in the 'templates' directory.
