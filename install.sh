curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash
source $HOME/.wasmedge/env
echo "WASMEDGE installed"
echo "Installing ContainerD and CRUN"
curl -sSf https://raw.githubusercontent.com/sonichigo/wasmedge-demo-example/main/containerd.sh && source containerd.sh | bash
echo "ContainerD + CRUN Installed"
cd ../
echo "Fetching for k8s"
wget -qO- https://raw.githubusercontent.com/sonichigo/wasmedge-demo-example/main/k8s.sh && source k8s.sh | bash
