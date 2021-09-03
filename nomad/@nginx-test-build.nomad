job "@nginx-test-build" {
  # Specify this job should run in the region named "us". Regions
  # are defined by the Nomad servers' configuration.
  #region = "us"
  # Spread the tasks in this job between us-west-1 and us-east-1.
  datacenters = ["ampathdc1"]
 
  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
  update {
    stagger      = "10s"
    max_parallel = 1
    auto_revert = false
  }

  type = "service"
  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "test-build-group" {
    # Specify the number of these tasks we want.
    count = 1
    network {
        port "http" {
          static = 7072
          to = 7072
          }
       }

    task "test-build-task" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      
      driver = "docker"
      # Configuration is specific to each driver.
      config {
        image = "nginx:latest"
        ports = ["http"]
        volumes = [
        "/media/data/nginx/conf.d:/etc/nginx/conf.d",
        "/media/data/nginx:/etc/nginx"
        ]
      }
      # Specify the maximum resources required to run the task,
      # include CPU, memory, and bandwidth.
      resources {
        cpu    = 500 # 500 MHZ
        memory = 256 # 256 MB
      }
    }
  }
}
