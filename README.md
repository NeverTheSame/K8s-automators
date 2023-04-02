# K8S Automators
K8S Automators is a collection of utilities and tools for working with various Kubernetes (K8s) clusters, including AKS, CF, EKS, and K8s. The project consists of two main components: `bash-k8s-depl` and `tf-k8s-depl`.

## bash-k8s-depl
`bash-k8s-depl` is a set of Bash scripts that automate common tasks for deploying applications to K8s clusters. The scripts provide utilities for deploying Docker images, managing Kubernetes manifests, and working with SSH keys.
### Usage
To use `bash-k8s-depl`, clone the repository and execute shell scripts as is. This will install the necessary dependencies and configure the environment for the scripts.

The following scripts are available in `bash-k8s-depl`:
-  deploy-docker.sh: Deploys a Docker image to a K8s cluster.
- download-manifest.sh: Downloads a Kubernetes manifest file from a specified endpoint.
- get-ssh-key.sh: Retrieves an SSH key from a specified endpoint.

## tf-k8s-depl
`tf-k8s-depl` is a set of Terraform modules that automate the deployment of AWS resources for a K8s cluster. The modules provide utilities for creating and configuring EC2 instances, load balancers, and security groups.

### Usage
To use `tf-k8s-depl`, clone the repository and run terraform init to initialize the Terraform modules. Then, create a new Terraform configuration file that references the modules and specifies the desired AWS resources.

The following modules are available in `tf-k8s-depl`:
-  ec2: Creates and configures EC2 instances for a K8s cluster.
load-balancer: Creates and configures a load balancer for a K8s cluster.
- security-group: Creates and configures security groups for a K8s cluster.

**Contributing**

Contributions to K8S Automators are welcome! To contribute, please fork the repository and submit a pull request.