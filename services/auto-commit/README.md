# Auto Commit Watcher Service

## Overview

The **Auto Commit Watcher Service** monitors a Git repository for file changes and automatically commits them to its corresponding repository. This ensures that any modifications are consistently saved and pushed.

## Components

1. **`auto_commit.sh`** – The script responsible for detecting changes and committing them.
2. **`install.sh`** – Installs and configures the systemd service.
3. **`uninstall.sh`** – Uninstalls an existing auto-commit service.

## Installation

To install the `auto_commit` service, **run the installation script**:

```bash
./install.sh
```

### Installation Process

- The script will **prompt you for the absolute path** of the Git repository to monitor. (Tab completion is enabled.)
- It will **validate that the directory is a Git repository**.
- The script **creates a systemd service** that automatically runs the watcher.
- A **symbolic link to `auto_commit.sh` is installed in `/usr/local/bin/`**, so any updates to the script will apply automatically.

After running the installation script, the service will be **installed and activated**.

### Checking the Status

To check whether the service is running, use:

```bash
sudo systemctl status auto_commit_<repo_name>
```

## Uninstallation

To remove an installed service, **run the uninstall script**:

```bash
./uninstall.sh
```

- The script will **list installed services** and allow you to **select which one(s) to remove**.
- It will **stop, disable, and remove the systemd service**.
- The **log file will be deleted**, unless changed.

### Manually Removing a Service

If needed, you can manually stop and disable a service:

```bash
sudo systemctl stop auto_commit_<repo_name>
sudo systemctl disable auto_commit_<repo_name>
sudo rm /etc/systemd/system/auto_commit_<repo_name>.service
sudo systemctl daemon-reload
```

## Troubleshooting

- **Logs are stored at**:

  ```bash
  /var/log/auto_commit_<repo_name>.log
  ```

  Replace `<repo_name>` with the name of your repository.

- **To view logs in real-time**:

  ```bash
  sudo tail -f /var/log/auto_commit_<repo_name>.log
  ```

- **To restart a service manually**:

  ```bash
  sudo systemctl restart auto_commit_<repo_name>
  ```

- **If the service is not working**:

  ```bash
  sudo systemctl status auto_commit_<repo_name>
  sudo journalctl -u auto_commit_<repo_name> --no-pager --lines=50
  ```

## Notes

- If multiple services are installed, they **run independently**.
- The symbolic link ensures that **updates to `auto_commit.sh` are reflected in all running services**.
- The service **automatically commits changes after a debounce period and enforces throttling**.
