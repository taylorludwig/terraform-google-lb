# Regional TCP Load Balancer Terraform Module
Modular Regional TCP Load Balancer for GCE using target pool and forwarding rule.

## Compatibility
This module is meant for use with Terraform 0.12. If you haven't [upgraded](https://www.terraform.io/upgrade-guides/0-12.html) and need a Terraform 0.11.x-compatible version of this module, the last released version intended for Terraform 0.11.x is [1.0.3](https://github.com/terraform-google-modules/terraform-google-lb/releases/tag/1.0.3)

## Usage
Basic usage is as follows:
```hcl
module "load_balancer" {
  source       = "terraform-google-modules/lb/google"
  version      = "~> 2.0.0"
  region       = var.region
  name         = "load-balancer"
  service_port = 80
  target_tags  = ["allow-lb-service"]
  network      = var.network
}

module "managed_instance_group" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "~> 1.0.0"
  region            = var.region
  target_size       = 2
  hostname          = "mig-simple"
  instance_template = module.instance_template.self_link
  target_pools      = [module.load_balancer.target_pool]
  named_ports = [{
    name = "http"
    port = 80
  }]
}
```
Full functional examples are located in the [examples](./examples/) directory.

## Resources Created
**Figure 1.** Diagram of Terraform resources created by module (in green).
![Terraform Resources Diagram](./docs/tf-resources-diagram.png "Terraform Resources Diagram")

- [`google_compute_forwarding_rule.default`](https://www.terraform.io/docs/providers/google/r/compute_forwarding_rule.html): TCP Forwarding rule to the service port on the instances.
- [`google_compute_target_pool.default`](https://www.terraform.io/docs/providers/google/r/compute_target_pool.html): The target pool created for the instance group.
- [`google_compute_http_health_check.default`](https://www.terraform.io/docs/providers/google/r/compute_http_health_check.html): The health check for the instance group targeted at the service port.
- [`google_compute_firewall.default-lb-fw`](https://www.terraform.io/docs/providers/google/r/compute_firewall.html): Firewall that allows traffic from anywhere to instances service port.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| firewall\_project | Name of the project to create the firewall rule in. Useful for shared VPC. Default is var.project. | string | `""` | no |
| name | Name for the forwarding rule and prefix for supporting resources. | string | n/a | yes |
| network | Name of the network to create resources in. | string | `"default"` | no |
| project | The project to deploy to, if not set the default provider project is used. | string | `""` | no |
| region | Region used for GCP resources. | string | n/a | yes |
| service\_port | TCP port your service is listening on. | number | n/a | yes |
| session\_affinity | How to distribute load. Options are `NONE`, `CLIENT_IP` and `CLIENT_IP_PROTO` | string | `"NONE"` | no |
| target\_tags | List of target tags to allow traffic using firewall rule. | list(string) | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| external\_ip | The external ip address of the forwarding rule. |
| target\_pool | The `self_link` to the target pool resource created. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
