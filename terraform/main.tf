provider "google" {
  project = "PROJECT-ID"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "SERVICE"
  location = "REGION"
  client   = "terraform"

  template {
    containers {
      image = "IMAGE"
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}