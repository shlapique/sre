#!/bin/bash 

## some varibles ##
mount_dir="/home/admini/packages/iso"
mounted=1
packages=("net-tools" "bird" "lldp" "openssh-server")

mount_iso() {
    if [ -d "$mount_dir" ];
    then
        sudo mount /dev/sr0 /media
        $mounted=1
    else
        echo "$mount_dir doesn't exist!"
        echo "creating $mount_dir... and mounting..."
        sudo mkdir /media
        sudo mount /dev/sr0 /media
        $mounted=1
    fi 
}

check_for_packages() {
    for pkg in ${packages[@]};
    do
        if [ "$(dpkg-query -W --showformat='${Status}\n' ${pkg} | grep "install ok installed")" == "install ok installed" ];
        then
            echo "${pkg} ok"
        else
            echo "${pkg} not installed!"
        fi
    done
}

# install packages from 'iso-package.iso'
installpackages() {
    if [ $mounted -eq "1" ];
    then
        sudo dpkg -i $mount_dir/*.deb
    else
        echo "error: in $mount_dir there's no mounted disk!"
        exit 1
    fi
}

addusers_and_pass() {

}

# start point of the script
# mount_iso()
installpackages
check_for_packages
