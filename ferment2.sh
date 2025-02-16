#!/bin/bash

fermentpath='/opt/ferment/installed'
fermentbins='/opt/ferment/bin'
fermentdata='/opt/ferment/data'
fermenttmps='/opt/ferment/tmp'
kavitadl='https://raw.githubusercontent.com/Kareadita/Kavita/releases/download/v0.8.4.2/kavita-linux-x64.tar.gz'
jellyfindl='https://repo.jellyfin.org/files/server/linux/latest-stable/amd64/jellyfin_10.10.5-amd64.tar.xz'
smokepingdl='https://oss.oetiker.ch/smokeping/pub/smokeping-2.8.2.tar.gz'
gitrepo='https://raw.githubusercontent.com/thedistromaker/ferment2/main'
gitcfgrepo='https://raw.githubusercontent.com/thedistromaker/ferment2/main/configs'

endclean() {
    rm -rf /opt/ferment/tmp/*
    echo "Finished cleanup. Exiting..."
    exit 0
}
fermentsmkpng() {
    sudo apt install smokeping fping ping wget curl nginx fcgiwrap -y
    sudo systemctl enable smokeping
    sudo systemctl start --now smokeping
    wget -q -O $fermenttmps/smokeping $gitcfgrepo/smokeping
    NEW_IP=$(hostname -I | awk '{print $1}')
    sed -i "s/your-nas-ip/$NEW_IP/g" '/opt/ferment/tmp/smokeping'
    sudo mv /opt/ferment/tmp/smokeping /etc/nginx/sites-available/smokeping
    sudo systemctl restart smokeping
    echo "Finished with installation. Cleaning up..."
    endclean
}

fermentjellyfin() {
    sudo apt install docker -y
    mkdir /opt/ferment/installed/jellyfin
    wget -q -O $fermentpath/jellyfin/Dockerfile $gitcfgrepo/Dockerfile-Jellyfin
    cd $fermentpath/jellyfin
    sudo systemctl enable docker
    docker build -t jellyfin .
    docker run -d --name jellyfin -p 8096:8096 -v /opt/ferment/installed/jellyfin/media:/jellyfin/media -v /opt/ferment/installed/jellyfin/config:/jellyfin/config jellyfin jellyfin
    echo "Finished with installation. To run Jellyfin after reboot, run: 'docker run -d --name jellyfin -p 8096:8096 /opt/ferment/installed/jellyfin/media:/jellyfin/media -v /opt/ferment/installed/jellyfin/config:/jellyfin/config jellyfin'. Cleaning up..."
    endclean
}

fermentkavita() {
    sudo apt install docker -y
    mkdir /opt/ferment/installed/kavita
    sudo systemctl enable docker
    wget -q -O wget -q -O $fermentpath/kavita/Dockerfile $gitcfgrepo/Dockerfile-Kavita
    cd $fermentpath/kavita
    docker build -t kavita .
    docker run -d --name jellyfin -p 5000:5000 /opt/ferment/installed/jellyfin/media:/jellyfin/media jellyfin
    echo "Finished with installation. To run Kavita after reboot, run: 'docker run -d --name kavita -p 5000:5000 /opt/ferment/installed/kavita/data:/kavita/data kavita'. Cleaning up..."
    endclean
}

fermenttransmission() {
    sudo apt install docker -y
    mkdir /opt/ferment/installed/transmission
    sudo systemctl enable docker
    wget -q -O wget -q -O $fermentpath/transmission/Dockerfile $gitcfgrepo/Dockerfile-Transmission
    cd $fermentpath/transmission
    docker build -t transmission .
    docker run -d --name transmission -p 9091:9091 /opt/ferment/installed/transmission/downloads:/transmission/downloads transmission
    echo "Finished with installation. To run Transmission after reboot, run: 'docker run -d --name transmission -p 9091:9091 /opt/ferment/installed/transmission/downloads:/transmission/downloads transmission'. Cleaning up..."
    endclean
}

removetransmission() {
    docker stop transmission
    docker rm transmission
    rm -rf /opt/ferment/installed/transmission
    echo "Finished removal."
    endclean
}

removekavita() {
    docker stop kavita
    docker rm kavita
    rm -rf /opt/ferment/installed/kavita
    echo "Finished removal."
    endclean
}

removejellyfin() {
    docker stop jellyfin
    docker rm jellyfin
    rm -rf /opt/ferment/installed/jellyfin
    echo "Finished removal."
    endclean
}

removesmokeping() {
    sudo systemctl stop smokeping
    sudo apt remove smokeping fping ping wget curl nginx fcgiwrap -y
    sudo rm -rf /opt/ferment/tmp/smokeping /etc/nginx/sites-available/smokeping
    echo "Finished removal."
    endclean
}

case $1 in
    install)
        if [ -z "$2" ]; then
            echo "Error 2243A: no package stated."
        fi
        case $2 in
            kavita)
                fermentkavita
                ;;
            jellyfin)
                fermentjellyfin
                ;;
            smokeping)
                fermentsmkpng
                ;;
            transmission)
                fermenttransmission
                ;;
            *)
                echo "Package not in database. Exiting..."
                exit 1
                ;;
        esac
        ;;
    remove)
        if [ -z "$2" ]; then
            echo "Error 2243B: no package stated."
            echo "Usage: $0 {install|remove <package> [--purge/--keepdata], update, ver}"
            exit 1
        fi
        case $2 in
            jellyfin)
                removejellyfin
                ;;
            kavita)
                removekavita
                ;;
            smokeping)
                removesmokeping
                ;;
            transmission)
                removetransmission
                ;;
        esac
        ;;
    ver)
        echo "Version 1.0"
        exit 0
        ;;
    list)
        echo "Transmission"
        echo "Kavita"
        echo "Jellyfin"
        echo "Smokeping"
        exit 0
        ;;
    *)
        echo "Usage: $0 {install|remove <package> [--purge/--keepdata], update, list, ver}"
        exit 1
        ;;
esac