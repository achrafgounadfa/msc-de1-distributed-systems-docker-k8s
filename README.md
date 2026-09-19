# MSc DE1 — Distributed Systems: Docker & Local Kubernetes Project

**Author:** Achraf Gounadfa
**Cohort:** MSc Data Engineering (MSc DE1)
**Module:** Distributed Systems
**GitHub Repository:** https://github.com/achrafgounadfa/msc-de1-distributed-systems-docker-k8s
**Public Docker Hub Repository:** https://hub.docker.com/r/achraf2026/msc-de1-flask-app

---

## 1. Project Objective and Architecture Overview

The objective of this project is to take an existing application that is **not containerized**, make sure it works locally, then design a complete containerization and local orchestration solution.

The workflow demonstrates:

1. Baseline verification of a Python Flask REST API
2. Secure Docker containerization (non-root, healthcheck, minimal image)
3. Publication to a public Docker Hub repository
4. Local multi-node Kubernetes orchestration with `kind`
5. Distributed systems behaviors (replication, self-healing, scaling, rolling update/rollback)

**High-level architecture:**

* Application: Flask REST API (`GET /`, `GET /items`, `GET /items/{id}`, `POST /items`)
* Image: `achraf2026/msc-de1-flask-app:1.0.1` (public on Docker Hub)
* Local cluster: `kind` with 1 control-plane + 2 worker nodes
* Kubernetes objects: Namespace, ConfigMap, Deployment (3 replicas), Service, NetworkPolicy
* Security: non-root user, read-only root filesystem, dropped capabilities, seccomp, resource limits, vulnerability scan + SBOM

---

## 2. Link to the Original Starter Application

Original repository used as the baseline:

https://github.com/ubc/flask-sample-app

At the time this project was prepared, the repository did not provide a Dockerfile in its main project structure.

---

## 3. Prerequisites

* Windows 10/11, Linux or macOS
* Python 3.11+
* Docker Desktop (or Docker Engine) 24+
* Docker Compose
* Git
* `kind` (Kubernetes IN Docker)
* `kubectl`
* PowerShell, Git Bash or a standard terminal

Optional:

* Docker Scout (for vulnerability scan and SBOM)

---

## 4. How to Run the Original Application Locally

```bash
# 1. Clone the repository
git clone https://github.com/achrafgounadfa/msc-de1-distributed-systems-docker-k8s.git
cd msc-de1-distributed-systems-docker-k8s

# 2. Create and activate a Python virtual environment
python -m venv venv

# Windows PowerShell
.\venv\Scripts\activate

# Linux / macOS
# source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run the application without Docker
python run.py
```

The application is available at:

**http://127.0.0.1:5000**

### Verify the routes

```bash
curl.exe http://127.0.0.1:5000/
curl.exe http://127.0.0.1:5000/items
curl.exe -X POST -H "Content-Type: application/json" -d "{\"name\": \"Premier Item\"}" http://127.0.0.1:5000/items
curl.exe http://127.0.0.1:5000/items/0
```

### Run unit tests

```bash
python -m unittest discover tests
```

Expected result:

```text
Ran 4 tests ...
OK
```

---

## 5. How to Build and Run the Docker Image

```bash
# Build the image
docker build -t achraf2026/msc-de1-flask-app:1.0.1 .

# Optional: also tag latest
docker tag achraf2026/msc-de1-flask-app:1.0.1 achraf2026/msc-de1-flask-app:latest

# Run the container
docker run -d -p 5000:5000 --name flask-container achraf2026/msc-de1-flask-app:1.0.1

# Verify status
docker ps

# Prove non-root execution
docker exec flask-container id

# Test the API from the host
curl.exe http://127.0.0.1:5000/
curl.exe http://127.0.0.1:5000/items

# Inspect logs
docker logs flask-container

# Clean stop and removal
docker stop flask-container
docker rm flask-container
```

Expected non-root result:

```text
uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)
```

---

## 6. How to Run the Project with Docker Compose

```bash
# Start the stack
docker compose up -d

# Check health and status
docker compose ps

# Test the API
curl.exe http://127.0.0.1:5000/
curl.exe http://127.0.0.1:5000/items

# Clean teardown
docker compose down
```

The Compose configuration includes:

* application service
* port mapping **`5000:5000`**
* restart policy
* environment variables
* healthcheck
* security options (**`no-new-privileges`**, **`cap_drop: ALL`**)
* read-only root filesystem with a small **`/tmp`** tmpfs

---

## 7. Link to your Public Docker Hub Repository

Public repository:

https://hub.docker.com/r/achraf2026/msc-de1-flask-app

Published tags:

* **`1.0.1`** ← **final tag used by Kubernetes**
* **`1.0.0`**
* **`latest`**

Pull and run from Docker Hub:

```bash
docker pull achraf2026/msc-de1-flask-app:1.0.1
docker run -d -p 5000:5000 --name verify-pulled achraf2026/msc-de1-flask-app:1.0.1
curl.exe http://127.0.0.1:5000/
docker stop verify-pulled && docker rm verify-pulled
```

> ***Traceability: the image and tag used in*** ***`k8s/deployment.yaml`*** ***is exactly*** ***`achraf2026/msc-de1-flask-app:1.0.1`***.

---

## 8. How to Create the Kind Cluster

```bash
# Create the multi-node cluster (1 control-plane + 2 workers)
kind create cluster --config kind/kind-config.yaml --name msc-de1-cluster

# Verify nodes
kubectl get nodes
```

Expected topology:

* **`msc-de1-cluster-control-plane`**
* **`msc-de1-cluster-worker`**
* **`msc-de1-cluster-worker2`**

All nodes must be in **`Ready`** state.

---

## 9. How to Deploy the Kubernetes Manifests

```bash
# Apply manifests in order
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/network-policy.yaml

# Verify resources
kubectl get all -n msc-de1-project
kubectl get pods -n msc-de1-project -o wide
kubectl get svc -n msc-de1-project
kubectl get networkpolicy -n msc-de1-project
```

Deployed objects:

* Namespace: **`msc-de1-project`**
* ConfigMap: **`flask-app-config`**
* Deployment: **`flask-app-deployment`** (3 replicas)
* Service: **`flask-app-service`** (ClusterIP, port 5000)
* NetworkPolicy: **`flask-app-network-policy`**

---

## 10. How to Access and Test the Application

```bash
# Port-forward the Kubernetes Service to the host
kubectl port-forward svc/flask-app-service 8080:5000 -n msc-de1-project
```

In another terminal:

```bash
curl.exe http://127.0.0.1:8080/
curl.exe http://127.0.0.1:8080/items
curl.exe -X POST -H "Content-Type: application/json" -d "{\"name\": \"Item cree dans Kubernetes\"}" http://127.0.0.1:8080/items
curl.exe http://127.0.0.1:8080/items
```

Expected responses:

* **`Hello, Flask!`**
* **`{"items":[]}`** then the newly created item after POST

---

## 11. How to Delete / Clean the Local Cluster

```bash
# Delete the project namespace and all its resources
kubectl delete namespace msc-de1-project

# Delete the entire kind cluster
kind delete cluster --name msc-de1-cluster
```

Optional local Docker cleanup:

```bash
docker compose down
docker system prune -f
```

---

## 12. Security Decisions and Known Limitations

### Security Decisions

1. **Non-root execution**

   * Dedicated user **`appuser`** (UID/GID 1000) in Dockerfile
   * **`USER appuser`**
   * Kubernetes **`runAsNonRoot: true`**, **`runAsUser: 1000`**, **`runAsGroup: 1000`**

2. **Minimal image**

   * Base image: **`python:3.11-slim`**
   * **`.dockerignore`** excludes **`venv/`**, **`.git/`**, evidence, k8s docs, etc.
   * Final content size around 50.7 MB

3. **Dependency hygiene**

   * Reused the original **`requirements.txt`** without unnecessary additions
   * **`pip install --no-cache-dir`**

4. **No secrets in images**

   * No credentials/tokens/keys in Dockerfile, image layers or Git
   * Configuration via environment variables / ConfigMap

5. **Reduced privileges**

   * Compose: **`no-new-privileges:true`**, **`cap_drop: ALL`**
   * Kubernetes: **`allowPrivilegeEscalation: false`**, **`capabilities.drop: [ALL]`**, **`seccompProfile: RuntimeDefault`**

6. **Read-only approach**

   * Compose: **`read_only: true`** + tmpfs on **`/tmp`**
   * Kubernetes: **`readOnlyRootFilesystem: true`** + **`emptyDir`** mounted on **`/tmp`**

7. **Resource awareness**

   * Kubernetes requests/limits:

     * requests: **`cpu: 50m`**, **`memory: 64Mi`**
     * limits: **`cpu: 250m`**, **`memory: 128Mi`**

8. **Vulnerability reduction**

   * Initial scan on **`1.0.0`**: 5 Critical / 12 High
   * After OS patching (**`apt-get upgrade`**) on **`1.0.1`**: **0 Critical / 6 High**
   * Reports stored in:

     * **`security/vulnerability-scan.txt`**
     * **`security/sbom.spdx.json`**
     * **`security/README.md`**

9. **Network isolation**

   * Kubernetes NetworkPolicy restricts ingress/egress for application pods

### Known Limitations

1. **In-memory data store**

   * The Flask app stores items in a Python list in memory.
   * Data is lost when pods restart.
   * Production improvement: external database / StatefulSet.

2. **Residual base-image CVEs**

   * Remaining High/Medium/Low findings come from Debian base OS packages, not from application code.
   * They are mitigated by non-root execution, read-only FS, dropped capabilities and NetworkPolicy.

3. **Development server**

   * Flask built-in server is used for the academic local project.
   * Production improvement: Gunicorn/uWSGI behind an Ingress with TLS.

4. **kind CNI NetworkPolicy enforcement**

   * Depending on the kind networking setup, NetworkPolicy may be best-effort unless a supporting CNI is installed.
   * The policy is still provided and documented as required.

---

## Quick Reference — Final Image Used by Kubernetes

```text
achraf2026/msc-de1-flask-app:1.0.1
```

## Project Structure

```text
msc-de1-distributed-systems-docker-k8s/
├── app/
├── tests/
├── evidence/
├── kind/
│   └── kind-config.yaml
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── network-policy.yaml
├── security/
│   ├── README.md
│   ├── vulnerability-scan.txt
│   └── sbom.spdx.json
├── .dockerignore
├── .gitignore
├── compose.yaml
├── Dockerfile
├── README.md
├── requirements.txt
└── run.py
```
