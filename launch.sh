#!/bin/bash

WORKDIR=/home/coldnew/Yocto/yocto-bsp/deploy/images/qemux86-64

    #-drive file=${WORKDIR}/core-image-weston-qemux86-64.wic.vmdk,if=virtio \
    #-drive file=${WORKDIR}/core-image-weston-qemux86-64.ext4,if=virtio,format=raw \
qemu-system-x86_64 \
    -name qemu-wayland \
    -smp 1 \
    -m 1024 \
    -drive file=${WORKDIR}/core-image-weston-qemux86-64.wic.vmdk,if=virtio \
    -enable-kvm \
    -display sdl,gl=on \
    -show-cursor \
    -usb -usbdevice tablet \
    -device virtio-vga,virgl \
    -soundhw hda -net nic -net user,hostfwd=tcp::6622-:22,hostfwd=tcp::9998-:9998 \
    -serial stdio


#    -kernel ${WORKDIR}/bzImage-qemux86-64.bin \
#    -serial stdio -append 'root=/dev/vda2 rw console=ttyS0  net.ifnames=0 biosdevname=1 vga=0 uvesafb.mode_option=640x480-32 '

#    Running qemu-system-x86_64 -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:02 -netdev tap,id=net0,ifname=tap0,script=no,downscript=no -drive file=/yocto/yocto-bsp/deploy//images/qemux86-64/core-image-weston-qemux86-64-20190625094227.rootfs.ext4,if=virtio,format=raw -vga vmware -show-cursor -usb -device usb-tablet -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0   -cpu core2duo -m 256 -serial mon:vc -serial null -kernel /yocto/yocto-bsp/deploy//images/qemux86-64/bzImage--5.0.19+git0+31de88e51d_00638cdd8f-r0-qemux86-64-20190625014351.bin -append 'root=/dev/vda2 rw highres=off  mem=256M ip=192.168.7.2::192.168.7.1:255.255.255.0 vga=0 uvesafb.mode_option=640x480-32 oprofile.timer=1 uvesafb.task_timeout=-1 '

#QB_DRIVE_TYPE = "/dev/vd"