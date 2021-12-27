# Real Time Clock
It is practical to have a real time clock (RTC) built into your system. With this you are more flexible and have less problems with connections and scanning of devices.

# automatic sync ntp
To automatic sync with an ntp server use
```bash
sudo timedatectl set-time "2020-04-23 8:38"
# or
timedatectl set-ntp True
```

# DS1307 RTC
- 5V DC supply
- Automatic Power-Fail detect and switch circuitry
- Consumes less than 500nA in Battery-Backup Mode with Oscillator Running
- 56-Byte, Battery-Backed, Nonvolatile (NV)RAM for data storage
- I2C ADDRESS 0x68

Pinout
| PIN | Description         | Comment                                          |
| --- | ------------------- | ------------------------------------------------ |
| BAT | Battery voltage     | To monitor the battery voltage, or not connected |
| GND | Ground              | Ground                                           |
| VCC | 5V supply           | Power the module and charge the battery          |
| SDA | I2C data            | I2C data for the RTC                             |
| SCL | I2C clock           | I2C clock for the RTC                            |
| DS  | Temp. Sensor output | One wire inteface                                |
| SQ  | Square wave output  | Normally not used                                |

## Setting up 
```bash
nano /boot/config.txt
# add: dtoverlay=i2c-rtc,ds1307
reboot
i2cdetect -y 1
# You should see a wall of text appear, if UU appears instead of 68 then we have successfully loaded i2c in the Kernel driver

# Remove fake system clock
sudo apt -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove
sudo nano /lib/udev/hwclock-set
# Find and Comment out
>    if [ -e /run/systemd/system ] ; then
>        exit 0
>    fi
# read the time directly
sudo hwclock -D -r
# read the system time
date
```

If the time displayed by the date command is correct, you can go ahead and run the following command on your RPi. This command will write the time from the RPi to the RTC Module.
```bash
sudo hwclock -w
# and verify
sudo hwclock -r
```
