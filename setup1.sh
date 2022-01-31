# enable needed cgroups
# mangle command line. Should probably match the defaults. Definitely doesn't match if you're not using raspbian lite
echo "console=serial0,115200 console=tty1 root=PARTUUID=$(ls /dev/disk/by-partuuid|sort|tail -n 1) rootfstype=ext4 fsck.repair=yes rootwait cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1"|sudo tee /boot/cmdline.txt
# just append. The params must be on one line, so the previous line might be more reliable
#echo ' cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1' |sudo tee -a /boot/cmdline.txt

#preconfigure docker
sudo mkdir /etc/docker
echo '
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
' | sudo tee /etc/docker/daemon.json

# turn off swap
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove

# add docker keyring for packages
curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

#add docker package source
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/raspbian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#add k8s keyring
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

#add k8s package source
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#remove swap support entirely
sudo apt-get purge dphys-swapfile 

sudo apt-get update && sudo apt-get dist-upgrade

# Install docker & k8s. we are installing 1.22.4 because 1.23 has a bug on arm7. You can use latest if you're using an arm64 distro (i.e. ubuntu) 
sudo apt-get install kubelet=1.22.4-00 kubeadm=1.22.4-00 kubectl=1.22.4-00 docker-ce docker-ce-cli containerd.io 
# don't upgrade k8s packages automatically
sudo apt-mark hold kubelet kubeadm kubectl 

#setup autocompletion for kubectl for next login
mkdir -p ~/.kube/
kubectl completion bash > ~/.kube/completion.bash.inc
printf "
# Kubectl shell completion
source '$HOME/.kube/completion.bash.inc'
" >> $HOME/.bash_profile
source $HOME/.bash_profile

# add the pi user to the docker group so we don't need to sudo all the docker stuff
sudo adduser pi docker

# restart the pi so kernel and dns changes take effect before we bootstrap the cluster
sudo reboot
