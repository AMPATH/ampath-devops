job "[[.job_name]]" {
  # Specify this job should run in the region named "us". Regions
  # are defined by the Nomad servers' configuration.
  #region = "us"
  # Spread the tasks in this job between us-west-1 and us-east-1.
  datacenters = ["ampathdc1"]
  # Run this job as a "service" type. Each job type has different
  # properties. See the documentation below for more examples.
  type = "system"
  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
  update {
    stagger      = "30s"
    max_parallel = 1
    auto_revert = true
  }
  
  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "[[.job_name]]" {
      
    # Specify the number of these tasks we want.
    count = 1
    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
     
    task "[[.job_name]]" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      
      driver = "docker"
      # Configuration is specific to each driver.
      config {
        image = "ampathke/etl-services:[[.job_name]]"
        port_map = { http = 8002 }
        volumes = [
        "/media/data/etl/conf:/opt/etl/conf",
        "/media/data/etl/uploads:/opt/etl/uploads",
        ]
      }
      resources {
        cpu    = 10 # MHz
        memory = 190 # Mb
        network {
        port "http" {
            to = 8002
          }
        }
      }
    }
  }
}
