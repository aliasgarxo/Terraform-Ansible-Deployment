

# Scalable 3-Tier Web Application with Terraform and Ansible

This project uses Terraform and Ansible to provision and deploy a scalable 3-tier web application on AWS. It automates the creation of a robust infrastructure and deploys a Java application onto application servers.
The infrastructure consists of 3 layers - Web layer, Application layer, and Database layer. Application and web servers are attached to Load Balancers and Auto Scaling for High availability and Scalability.

<img src="https://github.com/aliasgarxo/Terraform-Ansible-Deployment/assets/134081765/3a08861c-807c-4da8-8f2b-c68c98af6c50" width="500">

## Key Features

### Terraform Infrastructure:

- **3-Tier Architecture**: Deploys load balancers, application servers (EC2 instances), and a database tier (e.g., RDS) in a VPC.
- **Network Configuration**: Provisions subnets, security groups, and routing for secure communication between tiers.
- **Scalability**: Uses Auto Scaling Groups for the application tier to handle dynamic workloads.

### Ansible Deployment:

- **Java Application Packaging**: Builds and packages your Java application into a deployable artifact.
- **Server Configuration**: Installs necessary dependencies (Java runtime, web server) on application instances.
- **Deployment Playbooks**: Deploys the application artifact and configures it on application servers.

## Benefits

- **Automation**: Streamlines the creation and deployment of the entire web application stack.
- **Scalability**: Easily handle fluctuating traffic demands with Auto Scaling.
- **Consistency**: Ensures consistent environments across deployments through the combined power of Terraform and Ansible.
- **Version Control**: Tracks infrastructure and deployment configurations in your Git repository.

## Prerequisites

- AWS account with privileges to create VPCs, EC2 instances, RDS, etc.
- Terraform installed locally.
- Your Java application code ready for deployment.

## Getting Started

1. **Clone the Project**:

    ```bash
    git clone https://github.com/aliasgarxo/Terraform-Ansible-Deployment.git
    ```

2. **Configure Settings**:

    Modify `variables.tf` with your AWS region, instance types, VPC settings, etc. Update Ansible playbooks (e.g., `app.yml`) with your Java application details and configuration.

3. **Initialize Terraform**:

    ```bash
    terraform init
    ```

4. **Plan and Apply Infrastructure**:

    ```bash
    terraform plan
    terraform apply
    ```

5. **Run Ansible Playbook On Bastion Server**:
    This playbook will run on servers which are in Application tier Auto scaling group. For Web servers you can change the host file local to `/opt/web-server/hosts.ini`
    ```bash
    ansible-playbook app.yaml -i /opt/application/hosts.ini
    ```

## Next Steps

- Customize Terraform modules and Ansible playbooks for your specific application requirements.
- Consider using Ansible roles for better organization of configuration tasks.
- Explore integrating continuous deployment pipelines (CI/CD).
