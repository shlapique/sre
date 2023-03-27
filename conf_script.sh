#!/bin/bash 

## some varibles ##
mount_dir="/home/admini/packages/iso"
mounted=1
packages=("net-tools" "bird" "lldp" "openssh-server")
users=("d.alexeev" "s.ivannikov")

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

# adds users with pass and ssh
#
# ssh-keygen (to have .pub key for each user)
# on local machine for each user: 'ssh-copy-key -i /path_to_public_key $user@ip'
addusers_and_pass() {
    for user in ${users[@]};
    do
        sudo useradd -m "$user" 
        echo "pls set pass for $user :"
        sudo passwd $user
        sudo usermod -aG sudo $user
        sudo mkdir /home/$user/.ssh
        sudo chown $user:$user /home/$user/.ssh
    done
}

lv_create() {
    sudo lvcreate -L 30G -n lvVAR vgKVM
    sudo mkfs.ext4 /dev/vgKVM/lvVAR
    # to make mountpoint 
    echo "/dev/vgKVM/lvVAR /var ext4 defaults 0 0" >> /etc/fstab
    sudo mount /dev/vgKVM/lvVAR /var
}

swap_create() {
    sudo fallocate -l 4G /swapfile
    sudo chmod 0600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
}

# start point of the script
mount_iso()
installpackages
check_for_packages
addusers_and_pass
lv_create
