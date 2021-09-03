job "@daily-esm-core-update" {
  # Specify this job should run in the region named "us". Regions
  # are defined by the Nomad servers' configuration.
  #region = "us"
  # Spread the tasks in this job between us-west-1 and us-east-1.
  datacenters = ["ampathdc1"]
  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  type = "batch"
  periodic {
    cron             = "@daily"
    prohibit_overlap = true
    time_zone = "Africa/Nairobi"
  }

  group "esm-core-group" {
    # Specify the number of these tasks we want.
    count = 1
    
    task "update-esm-core" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "raw_exec"

      # Configuration is specific to each driver.
      config {
        command = "/bin/bash"
        args = ["-c", "/media/data/ci/dev-workflows/scripts/update-mf.sh", "/media/data/spa"]
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
