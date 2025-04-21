# WASM + CRUN + ContainerD 
A hands-on demo to run WebAssembly (WASM) workloads in Kubernetes using containerd, crun, and WasmEdge — all in a few commands!

## 📝 Description
This project demonstrates how to run WebAssembly (WASM) applications as Kubernetes Pods using WasmEdge and containerd with the crun runtime. It includes a complete setup script that installs all required components: WasmEdge, containerd, crun, and a local Kubernetes cluster.

A great starting point for developers looking to explore WebAssembly in containerized environments without needing Docker. Based on the evolving standards around runwasi, this demo uses OCI annotations and host networking to show how WASM workloads behave like native containers in Kubernetes.

## 📦 What’s Included

This demo will automatically set up:

- ✅ [WasmEdge](https://github.com/WasmEdge/WasmEdge)
- ✅ [containerd](https://containerd.io/) runtime (v1.5.7)
- ✅ [crun](https://github.com/containers/crun) (with WasmEdge support)
- ✅ [Kubernetes](https://github.com/kubernetes/kubernetes) (v1.22.4) with containerd integration
- ✅ A sample WebAssembly HTTP server (via Docker Hub)

## Installation command

### Using Wget

```bash
wget -qO- https://raw.githubusercontent.com/sonichigo/wasmedge-demo-example/main/install.sh | bash
```

### Using Curl

```bash
curl -fsSL https://raw.githubusercontent.com/wasmedge-demo-example/main/install.sh && source install.sh | bash
```

> ⚠️ **Note:** This script builds crun and Kubernetes from source, so it may take a while depending on your system. Recommended for use on a VM or dev box with at least **4 GB RAM** and **2 vCPUs**.


#### 🛠️ Optional Flags for install.sh

You can specify versions like this:

```bash
bash install.sh --wasmedge=0.13.4 --crun=1.8
```

## 🚀 Run WebAssembly container images in Kubernetes
Start the cluster and configure the local environment:

### 1️⃣ Configure `kubectl`:

```bash
cd kubernetes
export KUBERNETES_PROVIDER=local
sudo cluster/kubectl.sh config set-cluster local --server=https://localhost:6443 --certificate-authority=/var/run/kubernetes/server-ca.crt
sudo cluster/kubectl.sh config set-credentials myself --client-key=/var/run/kubernetes/client-admin.key --client-certificate=/var/run/kubernetes/client-admin.crt
sudo cluster/kubectl.sh config set-context local --cluster=local --user=myself
sudo cluster/kubectl.sh config use-context local
```

## ✅ Verify the cluster
Let's check the status to make sure that the cluster is running.

```sh
sudo cluster/kubectl.sh cluster-info
```

## 🧪 Run a WASM HTTP Service

Run the WebAssembly-based image from Docker Hub in the Kubernetes cluster as follows.

```bash
sudo cluster/kubectl.sh run --restart=Never http-server --image=wasmedge/example-wasi-http:latest --annotations="module.wasm.image/variant=compat-smart" --overrides='{"kind":"Pod", "apiVersion":"v1", "spec": {"hostNetwork": true}}'
```

Since we are using `hostNetwork` in the `kubectl` run command, the HTTP server image is running on the local network with IP address `127.0.0.1`. Now, you can use the curl command to access the HTTP service.

```sh
curl -d "name=WasmEdge" -X POST http://127.0.0.1:1234
```

Expected Output:

```bash
echo: name=WasmEdge
```

## 🙌 Contributing

Feel free to open an issue or PR if you'd like to improve the demo or add features! For questions or feedback, ping [@sonichigo](https://twitter.com/sonichigo) on Twitter.