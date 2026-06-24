# Arch Linux Minimalist Programming Environment

Repository containing the configuration files (dotfiles) and optimization steps used to revive a legacy 2007 machine into a high-performance environment for software development.

System Specs & Performance

| Metric | Specification / Result |
| :--- | :--- |
| **CPU** |  Intel(R) Pentium(R) Dual E2180 (2) @ 2.00 GHz |
| **RAM** | 2.89 GiB DDR2 (two slots) |
| **OS** | Arch Linux (x86_64) |
| **Window Manager** | bspwm + sxhkd |
| **Boot Time** | ~20 seconds (systemd-analyze) |
| **Idle RAM Usage** | ~505.48 MiB (17%) |

Key Optimizations
- **Window Manager:** Replaced heavy Desktop Environments (like GNOME/KDE) with `bspwm` to maximize CPU/RAM availability for development tools.
- **Display Server:** Minimal Xorg setup without a display manager (booting directly via `startx` / `.xinitrc` to save boot time).
- **Terminal & Editor:** Alacritty + Helix.

Repository Structure
- `.config/bspwm/`: Window manager behavior and workspaces.
- `.config/sxhkd/`: Custom keyboard shortcuts for navigation and efficiency.
- `.config/lemonbar/`: Minimalist status bar configuration.
