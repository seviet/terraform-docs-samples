/**
 * Copyright 2024 Google LLC
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

# [START cloud_sql_mysql_instance_iam_db_auth]
# [START cloud_sql_mysql_instance_iam_db_auth_create_instance]
# [START cloud_sql_mysql_instance_iam_db_auth_add_users]
resource "google_sql_database_instance" "mysql_iam_db_instance_name" {
  name             = "mysql-db-auth-instance-name-test"
  region           = "us-west4"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_iam_db_auth_create_instance]

resource "google_sql_user" "iam_user" {
  name     = "test-user@example.com"
  instance = google_sql_database_instance.mysql_iam_db_instance_name.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_user" "iam_service_account_user" {
  name     = "test-account@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  instance = google_sql_database_instance.mysql_iam_db_instance_name.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
# [END cloud_sql_mysql_instance_iam_db_auth_add_users]

# [START cloud_sql_mysql_instance_iam_db_grant_roles]
data "google_project" "project" {
}

resource "google_project_iam_binding" "cloud_sql_user" {
  project = data.google_project.project.project_id
  role    = "roles/cloudsql.instanceUser"
  members = [
    "user:test-user@example.com",
    "serviceAccount:test-account@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "cloud_sql_client" {
  project = data.google_project.project.project_id
  role    = "roles/cloudsql.client"
  members = [
    "user:test-user@example.com",
    "serviceAccount:test-account@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  ]
}
# [END cloud_sql_mysql_instance_iam_db_grant_roles]
# [END cloud_sql_mysql_instance_iam_db_auth]