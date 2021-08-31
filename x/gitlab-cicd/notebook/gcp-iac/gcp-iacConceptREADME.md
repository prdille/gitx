# gcp-iac Concepts

## Product
### About
* The Product is a combination of **terraform apps, terraform modules,** and jinja templated and executed through ansible and jenkins (eventually gitlab).

	* We consider a product as a group of Objects, where each object is the configuration of a particular `terraform_app` at a particular version with some related configuration of that terraform_app versioned inside the properties of a `product`.

* We have two logical constructs, a `customer` and a `product instance`. 
	* A `customer` is a high level organizational concept that allows us to group applications and its tiers back to the business owner.
	* A customer has `product_instance` which is a logical grouping of an application to be deployed, and its various tiers of environments. 
	
* The GCP Product is currently scoped to managing and provisioning resources within a single project.

### Repository and Versioning
* DevOps GCP Products are in the gcp-iac repo: [https://git.umms.med.umich.edu/devops/gcp-iac](https://git.umms.med.umich.edu/devops/gcp-iac)
* All repositories are tagged using semantic major, minor, patch level relase versioning. 
	* Minor fixes or improvements increment the _patch version_.
	* New features or changes that may introduce a higher level of incompatability should be a _minor version_ increment.
	* Breaking changes or large refactors should introduce a new _major version_.

## Customer Product Configuration

* Inside the gcp-iac repository is a folder called customer products. The folder structure can be viewed below that shows a customer, a product instance, and then the config files for each resource based on that product instances product.

![](../img/customer_folder_structure.png)

* What is not pictured here, is the `meta.yml` file that should be found in each product_instance directory. 
* Here is our example CICD `meta.yml`:

```
product_instance_config:
  gcp_product:
    name: "gke-relational"
    version: beta
  gcp_project_vars:
    test:
      project_id: hits-devops-bryanro-6357
      compute:
        gke:
          preemptible: "true"
          machine_type: "e2-small"
    sandbox:
      project_id: family-cancer-history-survey
      compute:
        gke:
          preemptible: "false"
          machine_type: "e2-small"
  gcp_label_metadata:
    project_data_sensitivity: "low"
    project_technical_owner: "devops"
    project_business_owner: "devops"
    project_configuration_item: "bryanro"
  user_inputs:
    compute:
      gke:
        disk_size: 50
        node_pool_min: 1
        node_pool_max: 10
    database:
      psql:
        machine_type: "n2-standard-2"
        psql_version: "POSTGRES_9_6"
        psql_use_public_address: "false"

```

## Terraform Module

### About
* A terrform module is a combination of terraform resources logically constructed to produce required resources.
* It is a `pure` terraform configuration.  There is no ansible, jinja2, or other additional pieces and should/could be used by other groups that are not familiar with the concept of a `GCP Product`.
* Code that consumed modules is typically accompanied by again, further additional terraform resources or data depending on the required inputs or outputs of a module.

### Repository and Versioning
* DevOps Terraform module repositories: [https://git.umms.med.umich.edu/devops/terraform-generic-modules](https://git.umms.med.umich.edu/devops/terraform-generic-modules)
* All repositories are tagged using semantic major, minor, patch level relase versioning. 
	* Minor fixes or improvements increment the _patch version_.
	* New features or changes that may introduce a higher level of incompatability should be a _minor version_ increment.
	* Breaking changes or large refactors should introduce a new _major version_.
## Terraform App

### About

* A terraform app is a combination of terraform modules + Ansible templates that enable efficient and repeatable management of conceptual blocks of google's cloud infrastructure
* Each terraform app should have a specific domain/area of use
* Dependencies betweeen terraform apps are discouraged, but often necessary (eg running a GKE cluster on a particular VPC and subnet)
** Dependencies should be made explicit for clarity and maintenance

### Repository and Versioning
* DevOps Terraform App repositories: [https://git.umms.med.umich.edu/devops/terraform_apps](https://git.umms.med.umich.edu/devops/terraform_apps)
* All repositories are tagged using semantic major, minor, patch level relase versioning. 
	* Minor fixes or improvements increment the _patch version_.
	* New features or changes that may introduce a higher level of incompatability should be a _minor version_ increment.
	* Breaking changes or large refactors should introduce a new _major version_.

### Terraform App - Storing State
* Thet state of each terraform_app is stored separately in a bucket named for the `project_id` of the current project, eg `hits-devops-mjohnw-20cd-tfstate`
** This state is stored in the `hits-devops-backups-03e3` project and is versioned for quick recovery from errors

## gcp_terraform/formidable
* The role [https://git.umms.med.umich.edu/devops/sds-roles/gcp_terraform](gcp_terraform) is designed to create a terraform directory with .tf files that could be executed in any standard `Terraform` way, but by using jinja2, we can do things that are difficult to reason about in a simpler manner than pure HCL.
* Additionally, it creates or ensures the bucket for a particular project/app exists in the `hits-devops-backups-03e3` project
* formidable.yml (a combination of terraFORM and ansIBLE) is a playbook that will run the gcp_terraform role against a particular terraform app

## GCP Product Configuration
* All products are currently stored as a product_name.yml in the `products` directory in the `gcp-iac` repository. Here's a description of important variables:
** `product_components` variable references all the terraform_apps that make up a product and what version of those apps are used at this particular point in time to make up a product_version.
** `project_location` and `project_backup_location` are ways to easily reference a particular project's location information (eg region and zone)
** `product_{{ terraform_app }}_config` has various dictionaries keyed by the expected configuration of each of its terraform apps.  This configuration is versioned as part of a product. Changing this config really means a different product.
*** Example for network:

```
product_network_config:
  network_name: "{{ project_id }}-{{ curr_env }}"
  vpc_module_version: 1.0.2
  use_nat_to_internet: true
  nat_manual_ip_1: "{{ product_external_ips_config['ext_ips_network_binding'][0].name }}"
  nat_manual_ip_2: "{{ product_external_ips_config['ext_ips_network_binding'][1].name }}"
  vpc_env: "{{ curr_env }}"
  network_primary_subnet_name: "{{ project_location['region'] }}-sub"
  network_primary_subnet_cidr: 10.4.0.0/23
  network_primary_subnet_region: "{{ project_location['region'] }}"
  network_backup_subnet_name: "{{ project_backup_location['region'] }}-sub"
  network_backup_subnet_cidr: 10.4.2.0/23
  network_backup_subnet_region: "{{ project_backup_location['region'] }}"
  peering_networks:
    - name: "{{ curr_env }}-{{ project_configuration_item }}-private-psql-range"
      subnet_prefix_length: "20"
  secondary_cidr_ranges: []

```

** Object Bindings
*** `product_{{ terraform_app_A }}_{{ terraform_app_B }}_binding` provides a way to have a dependent terraform_app configure its parent `terraform_app`
*** A good example of this is that our standard gke cluster needs `pod` and `service` cidrs added to the VPC that the cluster resides in.  We therefore create a special object configuration like so (please read and understand the comments, too!):

```
product_network_compute_binding: # <- note that we reference the two terraform_apps, not their constituent terraform-generic-modules
  cluster_one:
    gke_vpc_name: "{{ network_config[curr_env]['network_name'] }}" # <- all references on the right hand side of a dictionary are either the `downstream` configuration or the already-templated configuration.
    gke_vpc_subnet_name: "{{ network_config[curr_env]['network_primary_subnet_name'] }}"
    additional_subnets:
      - name: "{{ product_compute_config['gke_config']['cluster_one']['gke_pod_cidr_name'] }}"
        cidr_range: "{{ product_compute_config['gke_config']['cluster_one']['gke_pod_cidr_range'] }}"
      - name: "{{ product_compute_config['gke_config']['cluster_one']['gke_svc_cidr_name'] }}"
        cidr_range: "{{ product_compute_config['gke_config']['cluster_one']['gke_svc_cidr_range'] }}"
    gke_control_plane_cidr: "{{ product_compute_config['gke_config']['cluster_one']['gke_control_plane_cidr'] }}"
    type: gke
```

*** Then, the logic would be to add this to any default configuration values of the `terraform_app_A` which relate to `terraform_app_B`.  In the example above, the VPC's additional subnets would be populated by any existing additional subnets + the additionalsubnets of the gke object.

## Relase Versioning
* Every GCP Product consists of terraform apps + configuration @ specific versions and terraform modules @ specific versions. 
* As the underlying components are updated we must update the version of the product as well when we apply the new versions into a product, this will release a new version of the product, and should trigger a rollout of the product to all projects that consume the product.

### Versions are located and updated in the following locations

#### Module Versions

* Module version is consumed in a **products config** where the module belongs to a *_config
* When a module version is incremented, update it in the product config


#### Terraform App Versions
* Terraform app versioning has a `terraform_apps/terraform_app_components.yml` and is consumed in a **products config**
	* terraform\_app\_components contain the repo link and supported versions for each terraform_app
	* product configs contain which version of the terraform app they are using

#### Product Versions
* Currently located in gcp-iac, a product version is that at a particular commit or tag.

=======
## Notifications
We use Slack Channels for a variety of GCP notifications
* __devops-cloud-non-prod-alerts__ - Alerts from non-Production GCP projects
* __devops-cloud-prod-alerts__ - Alerts from Production GCP projects
* __devops-gke-logs__ - _coming soon_
* __devops-vuln-scans__ - _coming soon_
* __gcp-outages__- RSS feed from https://status.cloud.google.com/
* __rundeck-notify__- notifications of node pool upgrades
