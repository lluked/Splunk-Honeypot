# Splunk-Honeypot

This is a project for deploying and monitoring an ssh honeypot. This project consists of the following:

- Terraform for provisioning Infrastructure on AWS or Azure
- Vagrant for local testing and development
- Ansible for provisioning the deployment
- Docker / docker-compose to run the services
- The [Splunk in Docker](https://hub.docker.com/r/splunk/splunk/)
- [Traefik](https://github.com/traefik/traefik) reverse proxy for Splunk access
- [Cowrie](https://github.com/cowrie/cowrie) SSH Honeypot

## Requirements

- Ansible
- Terraform (Cloud Deployment)
- AWS or Azure account with cli installed (Cloud Deployment)
- Vagrant (Development and Testing)

## Terraform Deployment (Cloud Deployment)

- Install Ansible
- Install Terraform
- Install AWS Cli / Azure Cli
- Setup credentials
- Clone the repo
- Open a terminal in the `./terraform/aws` or `./terraform/azure` directory and run `terraform init`
- Update passwords in the terraform.tfvars file
```
    traefik_splunk_proxy_password = "changeme"
    splunk_password = "changeme"
```
traefik_splunk_proxy_password is for the proxy exposing Splunk to the web (this service id however limited to access from your IP only by default)
- run `terraform apply`
    - SSH private and public keys are automatically created and outputted to "./keys/" in the relative terraform folder
    - Terraform deploys all infrastructure
    - Ansible provisions the deployed instance
    - The real SSH port is changed from `22` to a non default value
    - The instance is signalled to restart
    - docker-compose is started to build the services after restart
    - Access for SSH, and Kibana is provided in the output
- Have a coffee (Wait around 10 mins for the deployment to complete)
- Access Splunk at the outputted url
    - The first login screen is for the Traefik proxy with the user being `splunk` and password being the value defined for `traefik_splunk_proxy_password` (This hides the Splunk service if the firewall rules are opened up)
    - The second login is for Splunk itself, the user is `admin` and the password is the value defined for `splunk_password`
- View the Cowrie Dashboard and watch the attacks come in

## Vagrant Deployment (Development and Testing)

Vagrant deployment is largely the same as with Terraform but only creates the deployment for access on your local machine.

- Install Ansible
- Install Vagrant
- Install providers
- Clone the repo
- Open a terminal in the root directory and run `vagrant init`
- Update the password variables in ./ansible/main.yml
- Build the box with `vagrant up`
    -   `vagrant up --provider=virtualbox` for virtualbox only
    -   `vagrant up --provider=vmware_desktop` for vmware only
- Have a coffee (Wait around 10 mins for the deployment to complete)
- SSH remains on the default port 22
- Cowrie is bound to ports 2222 (SSH) and 2223 (Telnet) on the box, Vagrant maps these services to localhost at ports 5222 (SSH) and 5223 (Telnet)
- Traefik is bound to https port 443 on the box, Vagrant maps this service to localhost at port 8443
- Once everything is up and running create some honeypot activity with attempts to localhost port 5222 (SSH) and 5223 (Telnet)
- Access Splunk at `http://localhost:8080/xyz`

## Troubleshooting

  - Check progress by sshing into the instance
    - Run 'sudo systemctl status manuka' to check the service status
    - Run 'docker ps' to check docker status
    - Once 'docker ps' shows the Traefik container as running wait a couple of minutes.
