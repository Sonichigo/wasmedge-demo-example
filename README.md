# WASM + CRUN + ContainerD 
A hands-on demo to run WebAssembly (WASM) workloads in Kubernetes using containerd, crun, and WasmEdge — all in a few commands!

## Using wget

```bash
wget -qO- https://raw.githubusercontent.com/sonichigo/wasmedge-demo-example/main/install.sh | bash
```

<!-- ### Using Curl

```bash
curl -fsSL https://raw.githubusercontent.com/wasmedge-demo-example/main/install.sh && source install.sh | bash
``` -->

## Run WebAssembly container images in Kubernetes

Finally, we can run WebAssembly programs in Kubernetes as containers in pods. In this section, we will start from another terminal window and start using the cluster.

```bash
cd kubernetes && git checkout v1.29.0

export KUBERNETES_PROVIDER=local

sudo cluster/kubectl.sh config set-cluster local --server=https://localhost:6443 --certificate-authority=/var/run/kubernetes/server-ca.crt
sudo cluster/kubectl.sh config set-credentials myself --client-key=/var/run/kubernetes/client-admin.key --client-certificate=/var/run/kubernetes/client-admin.crt
sudo cluster/kubectl.sh config set-context local --cluster=local --user=myself
sudo cluster/kubectl.sh config use-context local
sudo cluster/kubectl.sh
```

Let's check the status to make sure that the cluster is running.

```sh
sudo cluster/kubectl.sh cluster-info
```

### A WebAssembly-based HTTP service

Run the WebAssembly-based image from Docker Hub in the Kubernetes cluster as follows.

```bash
sudo cluster/kubectl.sh run --restart=Never http-server --image=wasmedge/example-wasi-http:latest --annotations="module.wasm.image/variant=compat-smart" --overrides='{"kind":"Pod", "apiVersion":"v1", "spec": {"hostNetwork": true}}'
```

Since we are using `hostNetwork` in the `kubectl` run command, the HTTP server image is running on the local network with IP address `127.0.0.1`. Now, you can use the curl command to access the HTTP service.

```sh
curl -d "name=WasmEdge" -X POST http://127.0.0.1:1234
```
