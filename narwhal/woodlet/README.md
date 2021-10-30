## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| google-beta | n/a |
| random | n/a |
| time | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable\_binary\_authorization | Binary Authorization is a service on Google Cloud that provides software supply-chain security for container-based applications. Binary Authorization extends Google Kubernetes Engine (GKE) and GKE on-prem with deploy time enforcement of security policies. | `bool` | `false` | no |
| gke\_additional\_labels | Additional custom labels to add | `map(string)` | `{}` | no |
| gke\_authorized\_cidr\_blocks | The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet. See Private Cluster Limitations for more details. This field only applies to private clusters, when enable\_private\_nodes is true. | <pre>list(object({<br>    cidr_block   = string<br>    display_name = string<br>  }))</pre> | <pre>[<br>  {<br>    "cidr_block": "172.17.144.0/20",<br>    "display_name": "level-2-auth"<br>  },<br>  {<br>    "cidr_block": "141.214.0.0/16",<br>    "display_name": "HITS Public IPs"<br>  }<br>]</pre> | no |
| gke\_business\_owner | ServiceNow business owner | `string` | n/a | yes |
| gke\_configuration\_item | ServiceNow configuration item | `string` | n/a | yes |
| gke\_control\_plane\_cidr | The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet. See Private Cluster Limitations for more details. This field only applies to private clusters, when enable\_private\_nodes is true. | `string` | `""` | no |
| gke\_data\_sensitivity | Data sensitivity classification https://safecomputing.umich.edu/protect-the-u/safely-use-sensitive-data/classification-levels | `string` | n/a | yes |
| gke\_enable\_private\_endpoint | When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used. This field only applies to private clusters, when enable\_private\_nodes is true. | `bool` | `false` | no |
| gke\_enable\_private\_nodes | Enables the private cluster feature, creating a private endpoint on the cluster. In a private cluster, nodes only have RFC 1918 private addresses and communicate with the master's private endpoint via private networking. | `bool` | `true` | no |
| gke\_env | Environment tier of cluster to deploy, like test or prod | `string` | n/a | yes |
| gke\_maintenance\_days | A comma separated string of one or many of the following: MO,TU,WE,TH,FR,SA,SU | `string` | `"MO,TU,WE,TH,FR,SA,SU"` | no |
| gke\_maintenance\_end\_hour | 00-23 in UTC for the maintenance window to start | `string` | `"23"` | no |
| gke\_maintenance\_start\_hour | 00-23 in UTC for the maintenance window to start | `string` | `"00"` | no |
| gke\_max\_pods\_per\_node | https://cloud.google.com/kubernetes-engine/docs/how-to/flexible-pod-cidr, in a way defines the maximum cluster size. Currently our pod CIDR is a /21, which allows 2048 addresses. The default value of 32 causes each worker node to be allocated a /26, 64 addresses. 2048/64 = 32 = max cluster size. | `number` | `32` | no |
| gke\_network | the self-link value for the network vpc for the cluster to run in | `string` | n/a | yes |
| gke\_node\_disk\_size\_gb | Default size of each node in the node pool. This will be for container ephemeral storage. | `number` | `50` | no |
| gke\_node\_image\_type | os & ctr runtime: Image types available:\n<br>cos: Optimized for security and performance\n<br>cos\_containerd: cos, using containerd as the main container runtime directly integrated with Kubernetes\n<br>Ubuntu: Supports NFS, GlusterFS, XFS, Sysdig, and Debian packages.\n<br>Ubuntu\_containerd: Ubuntu, using containerd as container runtime\n | `string` | `"COS_CONTAINERD"` | no |
| gke\_node\_machine\_type | size of machine to allocate for node pool | `string` | n/a | yes |
| gke\_node\_pool\_max\_nodes | The maximum number of nodes the node pool can autoscale to | `number` | `1` | no |
| gke\_node\_pool\_min\_nodes | The minimum number of nodes the node pool can autoscale to | `number` | `1` | no |
| gke\_node\_preemptible | True if you want the GKE nodes to be preemptible | `bool` | `true` | no |
| gke\_node\_service\_account\_name | https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#permissions - The service account to be used by the Node VMs. GKE requires, at a minimum, the service account to have the monitoring.viewer, monitoring.metricWriter, and logging.logWriter roles. | `string` | n/a | yes |
| gke\_pod\_cidr\_name | The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses. | `string` | n/a | yes |
| gke\_purpose | Purpose of the cluster, like an app name or other moniker | `string` | n/a | yes |
| gke\_random\_suffix | Set to true to add a random suffix to the end of the cluster name, useful for testing | `bool` | `false` | no |
| gke\_regional | Set to true to make this a regional cluster | `bool` | `true` | no |
| gke\_subnetwork | the self-link value for the subnetwork vpc for the cluster to run in | `string` | n/a | yes |
| gke\_svc\_cidr\_name | The name of the existing secondary range in the cluster's subnetwork to use for service ClusterIPs | `string` | n/a | yes |
| gke\_technical\_owner | ServiceNow technical owner | `string` | n/a | yes |
| notification\_channel\_name | The display name of the alerting channel | `string` | n/a | yes |
| project\_id | project id | `string` | n/a | yes |
| pubsub\_topic\_name | The name of the Pub/Sub topic to send GKE cluster upgrade notifications to | `string` | n/a | yes |
| region | GCP Region | `string` | `"us-central1"` | no |
| zone | GCP zone | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| location | The location of the created GKE cluster |
| name | The name of the created GKE cluster |
| node\_pool\_name | The name of the created GKE node pool |

