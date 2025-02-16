#!/bin/bash

echo "Setting up Ferment Package Manager!"
echo "You must know your sudo password to install!"
if command -v apt >/dev/null; then
    hostpkg=apt
elif command -v dnf >/dev/null; then
    hostpkg=dnf
elif command -v yum >/dev/null; then
    hostpkg=yum
elif command -v pacman >/dev/null; then
    hostpkg=pacman
elif command -v zypper >/dev/null; then
    hostpkg=zypper
elif command -v opkg >/dev/null; then
    hostpkg=opkg
else
    echo "No known package manager found."
fi
sudo mkdir -p /opt/ferment
sudo mkdir -p /opt/ferment/installed
sudo mkdir -p /opt/ferment/bin
sudo mkdir -p /opt/ferment/data
sudo mkdir -p /opt/ferment/tmp
whoami
read -p "Enter the username that was said above:" user
sudo chown -R $user:$user /opt/ferment
sudo chown -R $user:$user /opt/ferment/*
sudo chown -R 0755 /opt/ferment
sudo chown -R 0755 /opt/ferment*
wget -q -O /opt/ferment/bin/ferment https://raw.githubusercontent.com/thedistromaker/ferment2/main/ferment-$hostpkg.sh
sudo chmod +x /opt/ferment/bin/ferment
read -p "What architecture is your system? (arm, arm64, x64):" FARCH
read -p "Which shell do you use? (b: bash, z: zsh, f: fish)" shell
case $shell in
    b)
        echo "export PATH="/opt/ferment:'$PATH' >> ~/.bashrc
        echo "export farch=$FARCH" >> ~/.bashrc
        source ~/.bashrc
        ;;
    f)
        echo "export PATH="/opt/ferment:'$PATH' >> ~/.fishrc
        echo "export farch=$FARCH" >> ~/.fishrc
        source ~/.fishrc
        ;;
    z)
        echo "export PATH="/opt/ferment:'$PATH' >> ~/.zshrc
        echo "export farch=$FARCH" >> ~/.zshrc
        source ~/.zshrc
        ;;
    *)
        echo "export PATH="/opt/ferment:'$PATH' >> ~/.zshrc
        echo "export PATH="/opt/ferment:'$PATH' >> ~/.fishrc
        echo "export PATH="/opt/ferment:'$PATH' >> ~/.bashrc
        echo "export farch=$FARCH" >> ~/.zshrc
        echo "export farch=$FARCH" >> ~/.bashrc
        echo "export farch=$FARCH" >> ~/.fishrc
        echo "Reboot your system (if headless) or exit your terminal to apply changes after completion."
        ;;
esac
echo "Setup complete! You may delete this file!"
exit 0