# linux-slack15-setup

# Slackware Kernel Compilation & Backup Utility

This project provides a robust Bash script (`slack_linux_bkp.sh`) designed to automate the process of compiling, installing, backing up, and packaging a custom Linux Kernel on Slackware systems.

## Features.

- **Automated Compilation**:  
  Optionally runs `make bzImage` and `make modules` using all available CPU cores (`-j$(nproc)`).
- **Safe Installation**:  
  - Installs kernel binaries (`vmlinuz`, `System.map`, `.config`) to `/boot`.
  - **Backups**: Automatically backs up existing files in `/boot` to `*.old` before overwriting (e.g., `vmlinuz` -> `vmlinuz.old`).
  - **Symlinks**: Updates symbolic links (`/boot/vmlinuz`, `/boot/System.map`, etc.) to point to the new version.
- **Module & Header Installation**:  
  Installs modules and headers to a temporary directory for packaging, and modules to `/lib/modules` for the system.
- **Initrd Generation**:  
  Automatically detects the correct `mkinitrd` command for your system using `mkinitrd_command_generator.sh`, generates a new initrd, handles backups, and updates symlinks.
- **Packaging**:  
  Creates a `.tar.gz` archive containing the kernel, modules, headers, and initrd for easy distribution or backup.
- **Bootloader Update**:  
  Detects and prompts to update your bootloader (LILO, ELILO, or GRUB) to ensure the new kernel is recognized.

## Prerequisites

- **Root Privileges**: The script must be run as root (or with `sudo`) to write to `/boot`, `/lib/modules`, and update bootloaders.
- **Kernel Source**: You must have the Linux Kernel source code downloaded and extracted (e.g., in `/usr/src/linux`).
- **Build Tools**: Ensure you have the necessary development tools installed (gcc, make, ncurses, etc.).
- **Slackware Tools**: Requires standard Slackware tools like `mkinitrd`.

## Usage

1.  **Navigate to the Kernel Source Directory**:
    The script **must** be run from the root of your Linux kernel source tree.

    ```bash
    cd /usr/src/linux-6.x.x
    ```

2.  **Run the Script**:
    Execute the script from that directory.

    ```bash
    /path/to/tools/slack_linux_bkp.sh
    ```

3.  **Interactive Prompts**:
    The script will guide you through the process:
    - **Project Name**: Enter a suffix for your kernel build (e.g., `custom`).
    - **Compile?**: Choose whether to compile the kernel (`y/N`). If `y`, it will run `make bzImage` and `make modules`.
    - **Bootloader**: At the end, it will ask if you want to update your bootloader (LILO/GRUB).

## 📂 Output

- **System Directories**:
    - `/boot/vmlinuz-generic-X.X.X`
    - `/boot/System.map-X.X.X`
    - `/boot/config-X.X.X`
    - `/boot/initrd-X.X.X.gz`
    - `/lib/modules/X.X.X/`
- **Symlinks**:
    - `/boot/vmlinuz` -> *New Kernel*
    - `/boot/initrd.gz` -> *New Initrd*
- **Backup Archive**:
    - A tarball is created at `/tmp/kernel-dist-<VERSION>-<SUFFIX>.tar.gz` containing all installed files.

## Safety Mechanisms

- **Dependency Check**: Verifies it is running in a valid kernel source tree.
- **Backups**: Never blindly overwrites `/boot/vmlinuz` or `/boot/initrd.gz`. It moves existing files to `.old` first.
