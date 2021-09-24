#!/bin/bash

#set date format for vm name
date=$(date '+%Y-%m-%d_%H_%M_%S')

#Memory for VM
memory="8192"

#CPU for VM
cpu="2"

#vm name
vmName="New_VM_$date"

#iso name
iso_name=cylusone_ubuntu_1804_b_iso_process_init_script.iso
iso_loc="$HOME/Downloads/$iso_name"
vboxmanage unregister $vmName --delete
VBoxManage createvm --name $vmName --ostype Ubuntu_64 --register --basefolder `pwd`
VBoxManage modifyvm $vmName --ioapic on
VBoxManage modifyvm $vmName --memory $memory --vram 128 --cpus $cpu
VBoxManage modifyvm $vmName --nic1 nat
VBoxManage createhd --filename `pwd`/$vmName/$vmName_DISK.vdi --size 80000 --format VDI
VBoxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  `pwd`/$vmName/$vmName_DISK.vdi
VBoxManage storagectl $vmName --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $vmName --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $iso_loc
VBoxManage modifyvm $vmName --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage startvm "$vmName"