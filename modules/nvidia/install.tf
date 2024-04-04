locals {
  users = []
  apt = {
    packages = [
      "nvidia-driver",
      "nvidia-container-toolkit",
      "nvidia-smi"
    ]
    repositories = [
      "nvidia-container-toolkit",
    ]
  }
  systemd_units = []
}