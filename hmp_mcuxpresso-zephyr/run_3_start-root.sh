modprobe rpmsg_ns || true
modprobe rpmsg_ctrl || true
modprobe rpmsg_char || true
modprobe rpmsg-client-sample || true

mkdir -p /root/firmware
echo /root/firmware > /sys/module/firmware_class/parameters/path
cp ./build/zephyr/rpmsg_lite_sample.elf /root/firmware
echo stop > /sys/class/remoteproc/remoteproc0/state
echo rpmsg_lite_sample.elf > /sys/class/remoteproc/remoteproc0/firmware
echo start > /sys/class/remoteproc/remoteproc0/state
