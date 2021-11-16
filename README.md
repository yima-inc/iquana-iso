**iquana-iso** creates unattended installer to deploy [**k3s**](https://github.com/k3s-io/k3s) in air-gapped environments.

# Installation

- Run `make`.
    - Created iso will be found in `_staging/iquana.dev.iso`.
- Use the created iso to create installation media, like a USB stick.
- Install on target computer. It takes **two** phases to complete the installation.
    - Phase 1
        - Boot from USB stick through UEFI.
        - The installation process will start automatically.
        - The computer will be shutdown on completion.
    - Phase 2
        - Remove USB stick.
        - Power on the computer again.
        - Again, the computer will be shutdown on completion.

# Login

After installation, some default settings are used:

| Item     | Value |
| -------- | ----- |
| IP       | `192.168.11.127` |
| Username | `iquana` |
| Password | `iquana` |

You can either login through **ssh**(`ssh iquana@192.168.11.127`) or **cockpit** (`https://192.168.11.127:9090/`).

# Image Preloading

Change `IMAGES` in `custom/firstboot/install-custom-images/Makefile` to images that require preloading.

# Reference

- [Ubuntu Documentation](https://ubuntu.com/server/docs/install/autoinstall)
