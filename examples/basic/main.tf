/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "template_file" "instance_startup_script" {
  template = file("${path.module}/templates/gceme.sh.tpl")
  vars = {
    PROXY_PATH = ""
  }
}

resource "google_service_account" "instance-group" {
  account_id = "instance-group"
}

module "instance_template" {
  source               = "terraform-google-modules/vm/google//modules/instance_template"
  version              = "~> 1.0.0"
  subnetwork           = google_compute_subnetwork.subnetwork.self_link
  source_image_family  = var.image_family
  source_image_project = var.image_project
  startup_script       = data.template_file.instance_startup_script.rendered
  tags                 = ["allow-lb-service"]
  service_account = {
    email  = google_service_account.instance-group.email
    scopes = ["cloud-platform"]
  }
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

module "load_balancer" {
  name         = "basic-load-balancer"
  source       = "../../"
  region       = var.region
  service_port = 80
  target_tags  = ["allow-lb-service"]
  network      = google_compute_network.network.name
}
