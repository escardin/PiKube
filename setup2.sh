#initialize a cluster with non-default network ranges (because the defaults are 192.168.0.0/16 and will mess with home networks)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 

# copy admin config into our home dir so we can apply manifests
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown pi:users ~/.kube/config

# add networking plugin
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# label our node as a pi4 (used in manifest)
kubectl label nodes $HOSTNAME raspberrypi=4
# untaint the node so it can have workloads scheduled to it
kubectl taint node $HOSTNAME node-role.kubernetes.io/master:NoSchedule-
# you should be done and able to create and run pods now
