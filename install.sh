curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install.sh | bash
source $HOME/.wasmedge/env
echo "WASMEDGE installed"
echo "Installing ContainerD and CRUN"
source container.sh
echo "ContainerD + CRUN Installed"
echo "Fetching for k8s"
source k8s.sh