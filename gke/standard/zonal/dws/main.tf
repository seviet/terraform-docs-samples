/**
* Copyright 2025 Google LLC
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

# [START gke_standard_zonal_dws_flex_cluster]
# DWS Flex currently require project allowlisting, please follow steps from here
# https://cloud.google.com/kubernetes-engine/docs/concepts/dws
resource "google_container_cluster" "default" {
  name               = "gke-standard-zonal-flex-cluster"
  location           = "us-central1-a"
  initial_node_count = 1
  min_master_version = "1.32.2-gke.1652000"
  release_channel {
    # To use flex-start in GKE, your cluster must use version 1.32.2-gke.1652000 or later.
    channel = "RAPID"
  }
  node_config {
    machine_type = "e2-medium"
  }
}
# [END gke_standard_zonal_dws_flex_cluster]

# [START gke_standard_zonal_dws_non_q_flex]
resource "google_container_node_pool" "default" {
  provider = google-beta
  name     = "gke-standard-zonal-dws-non-q-flex"
  cluster  = google_container_cluster.default.name
  location = google_container_cluster.default.location

  autoscaling {
    total_min_node_count = 0
    total_max_node_count = 1
  }

  queued_provisioning {
    enabled = false
  }

  # More details on usage https://cloud.google.com/kubernetes-engine/docs/how-to/dws-flex-start-training
  node_config {
    machine_type = "a3-highgpu-8g"
    flex_start   = true

    reservation_affinity {
      consume_reservation_type = "NO_RESERVATION"
    }
  }
}
# [END gke_standard_zonal_dws_non_q_flex]
