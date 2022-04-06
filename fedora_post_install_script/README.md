# Title: Fedora post install script

Script to install dependencies and applications on a minimal Fedora install.

After installing minimal Fedora, log in to your user account.

```shell
sudo dnf isntall -y wget
wget "https://raw.githubusercontent.com/GPNGR/Scripts/main/fedora_post_install_script/install.sh" -O ./install.sh && chmod =x ./install.sh
./install.sh
```

This script is provided AS IS, the author will not be held liable for damages of any kind. Use at your own risk.
Author: GPNGR
