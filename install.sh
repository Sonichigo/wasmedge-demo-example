echo "WASMEDGE installed"
echo "Installing ContainerD and CRUN"
echo "<==============================>"
#!/bin/bash

export WASMEDGE_VERSION=""
export CRUN_VERSION=""

for opt in "$@"; do
  case $opt in
    -w=*|--wasmedge=*)
      export WASMEDGE_VERSION="${opt#*=}"
      shift
      ;;
    -c=*|--crun=*)
      export CRUN_VERSION="${opt#*=}"
      shift
      ;;
    *)
      ;;
  esac
done

echo -e "Starting installation ..."
sudo apt update
export VERSION="1.5.7"
echo -e "Version: $VERSION"
echo -e "Installing libseccomp2 ..."
sudo apt install -y libseccomp2
echo -e "Installing wget"
sudo apt install -y wget

wget https://github.com/containerd/containerd/releases/download/v${VERSION}/cri-containerd-cni-${VERSION}-linux-amd64.tar.gz
wget https://github.com/containerd/containerd/releases/download/v${VERSION}/cri-containerd-cni-${VERSION}-linux-amd64.tar.gz.sha256sum
sha256sum --check cri-containerd-cni-${VERSION}-linux-amd64.tar.gz.sha256sum

sudo tar --no-overwrite-dir -C / -xzf cri-containerd-cni-${VERSION}-linux-amd64.tar.gz
sudo systemctl daemon-reload

# change containerd conf to use crun as default
sudo mkdir -p /etc/containerd/
sudo bash -c "containerd config default > /etc/containerd/config.toml"
wget https://raw.githubusercontent.com/second-state/wasmedge-containers-examples/main/containerd/containerd_config.diff
sudo patch -d/ -p0 < containerd_config.diff
sudo systemctl start containerd

echo -e "Installing WasmEdge"
if [ -f install.sh ]
then
    rm -rf install.sh
fi
wget -q https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh
sudo chmod a+x install.sh

if [[ "$WASMEDGE_VERSION" = "" ]]; then
    echo -e "Use latest WasmEdge release"
    sudo ./install.sh --path="/usr/local"
else
    echo -e "Use WasmEdge: $WASMEDGE_VERSION"
    sudo ./install.sh --path="/usr/local" --version="$WASMEDGE_VERSION"
fi

rm -rf install.sh
echo -e "Building and installing crun"
sudo apt install -y make git gcc build-essential pkgconf libtool libsystemd-dev libprotobuf-c-dev libcap-dev libseccomp-dev libyajl-dev go-md2man libtool autoconf python3 automake

if [[ "$CRUN_VERSION" = "" ]]; then
    echo -e "Use latest master of Crun"
    git clone https://github.com/containers/crun
else
    echo -e "Use Crun: $CRUN_VERSION"
    echo -e "Downloading crun-${CRUN_VERSION}.tar.gz"
    wget https://github.com/containers/crun/releases/download/"${CRUN_VERSION}"/crun-"${CRUN_VERSION}".tar.gz
    tar --no-overwrite-dir -xzf crun-"${CRUN_VERSION}".tar.gz
    mv crun-"${CRUN_VERSION}" crun
fi

cd crun || exit
./autogen.sh
./configure --with-wasmedge
make
sudo make install
sudo systemctl restart containerd
cd ../
echo "<==============================>"
echo -e "Finished"
echo "ContainerD + CRUN Installed"

echo "<==============================>"

echo "Fetching for k8s"

sudo apt-get update
echo -e "Running Wasm in Kubernetes (k8s) ..."
echo -e "Installing Go"
wget https://golang.org/dl/go1.17.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.17.3.linux-amd64.tar.gz
echo -e "\nexport PATH=$PATH:/usr/local/go/bin" | tee -i -a /home/${USER}/.profile
source /home/${USER}/.profile
echo -e "Defaults secure_path=\"/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\"" | sudo tee -i /etc/sudoers.d/gofile

echo -e "Cloning Kubernetes ..."

git clone https://github.com/kubernetes/kubernetes.git
cd kubernetes/ && git checkout v1.22.4

echo -e "Installing etcd"
sudo apt-get install -y net-tools
sudo CGROUP_DRIVER=systemd CONTAINER_RUNTIME=remote CONTAINER_RUNTIME_ENDPOINT='unix:///var/run/containerd/containerd.sock' ./hack/install-etcd.sh
export PATH="/home/${USER}/kubernetes/third_party/etcd:${PATH}"
sudo cp -rp ./kubernetes/third_party/etcd/etcd* /usr/local/bin/

echo -e "Building and running k8s with containerd"
sudo apt-get install -y build-essential
sudo -b CGROUP_DRIVER=systemd CONTAINER_RUNTIME=remote CONTAINER_RUNTIME_ENDPOINT='unix:///var/run/containerd/containerd.sock' ./hack/local-up-cluster.sh
echo "<==============================>"
