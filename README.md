
# VPN Management Script

This Bash script is designed to manage VPN connections using SSH and `sshuttle`. It supports both IPv4 and IPv6 connections and offers an optional graphical user interface (GUI) for ease of use.

## Features

- **SSH Tunneling**: Connects to VPN servers using SSH tunneling.
- **sshuttle**: Allows VPN connections with `sshuttle` for more advanced routing and DNS handling.
- **GUI Mode**: Provides a graphical interface for selecting connection options.
- **Command-Line Options**: Offers flexible command-line options to control the script's behavior.

## Configuration Setup

Before using the script, you'll need to configure it to match your VPN setup. Here's how:

1. **Edit VPN Configuration**:

   Open the script in a text editor and modify the following variables to fit your VPN server details:

   ```bash
   # VPN config
   user=""           # SSH user for the VPN server
   ipv4=""  # IPv4 address of the VPN server
   ipv6=""  # IPv6 address of the VPN server
   port=""           # Port used for the VPN connection
   local_port=""     # Local port for SSH tunneling
   ```

   - `user`: The SSH username used to connect to the VPN server. Change it if your username is different.
   - `ipv4` and `ipv6`: The IP addresses of your VPN server for IPv4 and IPv6, respectively. Update these with your server's actual addresses.
   - `port`: The port number on which the VPN server listens for connections. Ensure this matches your server's configuration.
   - `local_port`: The local port used for SSH tunneling. Change this if you need a different port.

2. **Install Required Tools**:

   Make sure you have the following tools installed on your system:

   - **SSH**: The SSH client should be installed and configured.
   - **sshuttle**: Install `sshuttle` if you plan to use `sshuttle` mode. On Debian-based systems, you can install it with `sudo apt-get install sshuttle`.
   - **Zenity**: Install `zenity` for GUI mode. On Debian-based systems, you can install it with `sudo apt-get install zenity`.

## Usage

### Command-Line Options

```bash
./vpn_script.sh [-g] [-s] [-v ip_version]
```

- `-g`: Launch GUI mode.
- `-v ip_version`: Specify the VPN server IP version. Must be `4` for IPv4 or `6` for IPv6.
- `-s`: Use `sshuttle` mode (requires `-v`).

### Examples

- **Connect via SSH with IPv4**:
  ```bash
  ./vpn_script.sh -v 4
  ```

- **Connect via SSH with IPv6**:
  ```bash
  ./vpn_script.sh -v 6
  ```

- **Connect via `sshuttle` with IPv4**:
  ```bash
  ./vpn_script.sh -v 4 -s
  ```

- **Connect via `sshuttle` with IPv6**:
  ```bash
  ./vpn_script.sh -v 6 -s
  ```

- **Launch GUI for VPN selection**:
  ```bash
  ./vpn_script.sh -g
  ```

## Functions

- `start_vpn()`: Starts the VPN connection based on the IP version and `sshuttle` mode.
- `launch_gui()`: Launches a GUI for selecting the connection type.

## Notes

- The script continuously attempts to reconnect if the connection is lost (for SSH connections).
- Ensure that `sshuttle` is installed if you plan to use sshuttle mode.
- Make sure `zenity` is installed for GUI mode to work.

## License

This script is released under the MIT License. See `LICENSE` for more details.

## Author

[momoein](https://github.com/momoein)

---

Feel free to adjust any details to better fit your specific setup or preferences.
