# ServerSetting

This repository is a collection of scripts for simple lab GPU server setup.
All scripts are written with Ubuntu 24.04 as the baseline environment.

## Execution Order

Manually copy and run the following scripts on the target server first:

1. `src/00_make_internet_connection.sh`
2.  `src/10_upgrade_and_install_basics.sh`
3. `src/11_set_basic_security.sh`

Then run the default setup script on the remote server:

```bash
bash default_server_setting.sh
```

`default_server_setting.sh` executes the following scripts in order:

1. `src/20_enable_ubuntu_pro_subscription.sh`
2. `src/21_hostname_change.sh`
3. `src/22_nvidia_driver_enable_pm.sh`
4. `src/23_nvidia_driver_lock.sh`
5. `src/27_change_info_after_login.sh`
6. `src/30_environment_and_module_install.sh`
7. `src/32_conda_env_setting.sh`

## Optional Script

- `src/40_custom_shell_setting.sh` is an optional script and is not included in the default setup flow.
- Run it manually only if needed.
