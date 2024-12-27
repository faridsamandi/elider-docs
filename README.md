# elider-docs


# Build qemu for RISC-V
sudo apt install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev \
                 gawk build-essential bison flex texinfo gperf libtool patchutils bc \
                 zlib1g-dev libexpat-dev git
git clone https://github.com/qemu/qemu
cd qemu
git checkout
./configure --target-list=riscv64-softmmu --enable-slirp
make -j $(nproc)
sudo make install




# Create disk image for vSwarm-u

##Created root fs by buildroot:
ROOTFS = "./"

# install modules from linux kernel compiled above
cd ../linux/
make ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu- INSTALL_MOD_PATH=../RootFS modules_install

# install libraries from the toolchain built above
cd ../RootFS
cp -a /opt/riscv/sysroot/lib  .


## Allow root to login with ssh
echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > $ROOTFS/etc/sudoers.d/ubuntu
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' $ROOTFS/etc/ssh/sshd_config

## Prepare gem5 utility tool
cp m5.${ARCH} $ROOTFS/usr/sbin/m5
chmod +x $ROOTFS/usr/sbin/m5

## Create and enable the gem5 init service
cp gem5init $ROOTFS/sbin/
chmod +x /sbin/gem5init

cat > /lib/systemd/system/gem5.service <<EOF
[Unit]
Description=gem5 init script
Documentation=http://gem5.org
After=getty.target
After=docker.service

[Service]
Type=idle
ExecStart=/sbin/gem5init
StandardOutput=tty
StandardError=tty

[Install]
WantedBy=default.target
EOF

# Install docker-compose (maybe it's not needed)
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-riscv64" -o $ROOTFS/usr/local/bin/docker-compose
chmod +x $ROOTFS/usr/local/bin/docker-compose


# Install golang
wget https://go.dev/dl/go1.21.13.linux-riscv64.tar.gz
sudo tar -C $ROOTFS/usr/local -xzf go1.21.13.linux-riscv64.tar.gz
echo 'export PATH=\$PATH:/usr/local/go/bin' >> $ROOTFS/etc/profile




# Commands to execute on the target
#rm /usr/sbin/iptables
#ln -s /usr/sbin/iptables-legacy /usr/sbin/iptables
#/usr/sbin/ip6tables
#ln -s /usr/sbin/ip6tables-legacy /usr/sbin/ip6tables
systemctl daemon-reload
systemctl enable gem5.service
