# Set swap memory
Swap memory is a file on computer storage dedicated to help RAM when this is not enough according to programs need. It is a common feaure for all unix like systems.

Current swap size and position can be verified in several ways. Before going on, consider that swap size is usually calculated in MByte. Tools reporting this value in bits will consider that, for memory, 1 Kbyte is equal to 1028 MByte.

The very first way where to get current swap size, is using the command `free`. For a more detailed overview you can use `top` to show all running processes, memory and swap.

Changing swap size requires disabling swap, editing size, enabling swap and restarting swap service again. All of these actions are done with following terminal commands:
- Disable swap: `sudo dphys-swapfile swapoff`
- Change swap size in dphys-swapfile. Open this file for editing: `sudo nano /etc/dphys-swapfile`
    - find the `CONF_SWAPSIZE` parameter and change according to your needs. For example `CONF_SWAPSIZE=500`
- Enable swap and restart dphys service:
    ```bash
    sudo dphys-swapfile swapon
    sudo systemctl restart dphys-swapfile.service
    ```
- Check that swap has changed value: `free`

# Set swappiness
Swappiness is a concept complementary to swap memory. It drives when linux kernel should start using swap file instead of RAM.
When linux kernel needs more phisical memory, it can decide to use page cache (also stored on disk) or moving pages to swap memory. Swappiness defines how the kernel will be likely to use swap instead of RAM. 
- show current swappiness: `sysctl vm.swappiness`
- change swappiness temporary (between 0 and 100): `sudo sysctl -w vm.swappiness=50`
- to change permanently open `/etc/sysctl.conf` and append `vm.swappiness=10` with the value you desire


# Sources and more
- [peppe8o.com](https://peppe8o.com/set-raspberry-pi-swap-memory/)