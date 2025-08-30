mkbootimg \
    --kernel Image.gz-dtb \
    --ramdisk initramfs.cpio.gz \
    --cmdline "console=tty0 console=ttyGS0,115200 no_console_suspend" \
    --base 0x00000000 \
    --kernel_offset 0x00008000 \
    --ramdisk_offset 0x1000000 \
    --tags_offset 0x00000100 \
    --pagesize 4096 --id -o boot.img