# Setting up Raspberry Pi

This is a simple start guide to setting up Raspberry Pi for use with inkblot

## Flashing

See the [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) for details on downloading images and flashing them to cards.

## Wifi setup

Run `bin/pi/wpa_config` to enter wifi credentials. This will save a `wpa_supplicant.conf` file. You can also create one manually if you'd like.

![wpa_config](https://justinp-io-production.s3.amazonaws.com/store/36c56b2414c134c7b0425b4b9307542f.png)

## Boot Config

Ensure that the boot volume is mounted. Run `bin/pi/boot_config`, which will set SSH and SPI settings, and copy your `wpa_supplicant.conf` file.

![boot_config](https://justinp-io-production.s3.amazonaws.com/store/587730ee4e834e015d87e197713c71eb.png)

## Handshaking

Insert the card into the Raspberry Pi and power it on. Run `bin/pi/ssh`, which will connect to the Raspberry pi for the first time and save a configuration file. If a password is requested, it is "`raspberry`". You'll want to also run `ssh-copy-id pi@raspberrypi.local` to set up keys.

## Login setup

Run `bin/pi/changelogin`. This will allow you to change your pi's hostname on the network, and change the password. After rebooting, run `bin/pi/ssh` again to confirm it worked.

![change_login](https://justinp-io-production.s3.amazonaws.com/store/3247b228c980d4bac903c56305312bd7.png)

## Installing Dependencies

Run `bin/pi/install_deps`. You can install various needed dependencies remotely with this script, including Ruby, NodeJS/NPM, ImageMagick, and the gem itself.

![install_deps](https://justinp-io-production.s3.amazonaws.com/store/290cda5a1739a0ee3a0be994878f1bf4.png)
