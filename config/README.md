# Config

This folder contains user settings and customizations for my desktop environment.

## Installation

To install these user configurations on a new machine

1. Clone this repository

   ```sh
   git clone https://github.com/athackst/workstation_setup.git
   ``

2. Navigate to the repository's root directory

   ```sh
   cd workstation_setup
   ```

3. Run the installation script

    ```sh
    ./config/install.sh
    ```

## Usage

The install sets up user aliases and user preferences contained in the following folders.

1. `.aliases`: Custom bash aliases for frequently used commands
2. `.config`: System configuration files
3. `.gitconfig`: Git configuration settings


Additionally, it adds a bash alias:

- `user_config_diff` -> [user-config-diff.sh](user-config-diff.md)
- `user_config_update` -> [user-config-update.sh](user-config-update.md)
