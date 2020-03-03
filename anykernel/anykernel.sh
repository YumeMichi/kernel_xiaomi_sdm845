# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# Begin properties
properties() { '
kernel.string=Polar Kernel by YumeMichi @ xda-developers
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=dipper
supported.versions=10
supported.patchlevels=
'; } # End properties

# Shell variables
block=boot;
is_slot_device=auto;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# Import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

## AnyKernel install
ui_print " " "Decompressing boot image..."
dump_boot;

# Begin ramdisk changes

# End ramdisk changes

ui_print " " "Installing new boot image..."
write_boot;

## End install
ui_print " " "Done!"
$bb umount /system
