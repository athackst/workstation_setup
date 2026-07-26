# Overview

This directory contains various **useful services** that automate common tasks, improve workflow efficiency, and simplify system management.

## Installation & Usage

Each service is **self-contained** and has its own installation and uninstallation scripts.
Navigate to the service directory and run its `install.sh` script. For example:

```bash
cd services/auto-commit
./install.sh
```

## Managing Installed Services

Once installed, services run automatically.  
To check a running service, replace `service_name` with the systemd unit name:

```bash
sudo systemctl status service_name
```

To restart a service:

```bash
sudo systemctl restart service_name
```
