
# DISTRIBUTED SYSTEMS TECHNICAL REPORT
**Containerize, Secure, Publish and Orchestrate an Existing Application**

- **Author:** Achraf Gounadfa
- **Cohort:** Master of Science - Data Engineering (MSc DE1)
- **Module:** Distributed Systems
- **Date:** September 2026
- **GitHub Repository:** https://github.com/achrafgounadfa/msc-de1-distributed-systems-docker-k8s
- **Docker Hub Repository:** https://hub.docker.com/r/achraf2026/msc-de1-flask-app

---

## 1. Baseline Application Verification

Before any containerization work, the original Python Flask REST API from the UBC starter repository was inspected, configured, and tested locally to establish a functional baseline.

### Local Setup & Testing
1. A Python virtual environment (`venv`) was isolated and activated.
2. Dependencies were installed from `requirements.txt`.
3. All 4 unit tests were executed and passed successfully (`Ran 4 tests ... OK`).
4. The application entry point `run.py` was executed locally.

### Verified REST Routes:
- `GET /` -> Returns `Hello, Flask!` (HTTP 200)
- `GET /items` -> Returns initial JSON array `{"items": []}` (HTTP 200)
- `POST /items` -> Adds a new item `{"message": "Item added successfully"}` (HTTP 200)
- `GET /items/0` -> Retrieves the newly created item (HTTP 200)

*Evidence:* Screenshots stored in `evidence/01_baseline_tests.png` and unit test outputs.

---

## 2. Dockerization & Image Optimization

### Dockerfile Design Decisions
To ensure a secure and lightweight image, `python:3.11-slim` (Debian-based) was chosen as the base image instead of full Python images, resulting in a final content size of only **50.7 MB** (207 MB uncompressed layer footprint).

Key choices in `Dockerfile`:
- **Layer Caching Optimization:** `requirements.txt` is copied and installed prior to copying the application source code.
- **Non-Root Security:** A dedicated system group and user (`appuser`, UID/GID 1000) are explicitly created and activated via `USER appuser`.
- **Runtime Host Binding:** `run.py` was improved to listen on `0.0.0.0` (configurable via `FLASK_RUN_HOST` environment variable) so that Flask accepts external container connections.
- **Healthcheck:** Embedded `HEALTHCHECK` running `urllib.request` every 30 seconds.

*Evidence:* Image layer history (`docker history`) and container identity inspect (`docker exec <c> id`) stored in `evidence/docker-history.png` and `evidence/non-root-id.png`.

---

## 3. Container Security, Vulnerability Scan & SBOM

Security was evaluated independently and systematically improved following DevSecOps principles.

### Vulnerability Scan & Risk Reduction (Docker Scout)
An initial scan of image `1.0.0` revealed **5 Critical** and **12 High** vulnerabilities inherited from unpatched Debian base packages.

**Mitigation Applied:**
`apt-get update && apt-get upgrade -y` was added to the `Dockerfile` to fetch upstream OS security patches. The resulting image `1.0.1` achieved:
- **CRITICAL:** Reduced from **5 to 0** (-100%)
- **HIGH:** Reduced from **12 to 6** (-50%)
- **MEDIUM:** Reduced from **12 to 3** (-75%)

### Software Bill of Materials (SBOM)
An SPDX 2.3 JSON SBOM was generated using `docker scout sbom` and saved to `security/sbom.spdx.json`.

### Security Summary Table

| Requirement | Implementation | Status |
|---|---|---|
| Non-root Execution | `USER appuser` (UID 1000) | Enforced |
| Read-Only Root FS | `read_only: true` with `/tmp` `tmpfs` | Enforced |
| Privilege Reduction | `cap_drop: [ALL]`, `no-new-privileges: true` | Enforced |
| Vulnerability Scan | Docker Scout CVE report in `security/` | 0 Critical |
| SBOM | SPDX format in `security/sbom.spdx.json` | Generated |

---

## 4. Docker Hub Publication & Local Compose Verification

### Docker Hub Repository
The sanitized image was tagged and pushed to Docker Hub under public visibility:
- Repository: `achraf2026/msc-de1-flask-app`
- Tags: `1.0.1` (deployment version), `1.0.0` (initial version), `latest`

### Verification from Registry
To prove reproducibility, local images were purged (`docker rmi`), pulled fresh from Docker Hub (`docker pull achraf2026/msc-de1-flask-app:1.0.1`), executed, and tested via `curl.exe`.

### Docker Compose
A production-ready `compose.yaml` was authored including healthchecks, environment variables, `no-new-privileges`, `cap_drop: ALL`, and `read_only: true`.

*Evidence:* Screenshots in `evidence/dockerhub-public-page.png` and `evidence/pull-and-verify-from-dockerhub.png`.

---

## 5. Kubernetes Cluster Architecture & Security Hardening

### Local Cluster Topology (`kind`)
A 3-node Kubernetes cluster was created using `kind` (`kind/kind-config.yaml`):
- **1 Control-Plane Node:** `msc-de1-cluster-control-plane`
- **2 Worker Nodes:** `msc-de1-cluster-worker`, `msc-de1-cluster-worker2`

### Deployed Kubernetes Objects (`k8s/`)
1. **Namespace:** Isolated namespace `msc-de1-project`.
2. **ConfigMap:** Non-sensitive environment variables (`PORT`, `FLASK_RUN_HOST`).
3. **Deployment:** 3 replicas running `achraf2026/msc-de1-flask-app:1.0.1`.
4. **Service:** `ClusterIP` service exposing port 5000 with automatic Endpoint discovery across all 3 pods.
5. **NetworkPolicy:** Ingress/egress rules restricting traffic to port 5000 and DNS.

### Pod Security Context & Probes
- `runAsNonRoot: true`, `runAsUser: 1000`, `seccompProfile: RuntimeDefault`
- `readOnlyRootFilesystem: true`, `allowPrivilegeEscalation: false`, `capabilities.drop: [ALL]`
- **Resources:** Requests (64Mi RAM / 50m CPU), Limits (128Mi RAM / 250m CPU)
- **Probes:** `livenessProbe` and `readinessProbe` checking HTTP GET `/` on port 5000.

---

## 6. Distributed Systems Behavior Demonstrations

### A. Replication & Service Discovery
The 3 Pods were automatically scheduled across both worker nodes (`worker` and `worker2`). The `flask-app-service` Endpoints object correctly discovered all 3 pod IP addresses (`10.244.1.2:5000`, `10.244.1.3:5000`, `10.244.2.2:5000`).

### B. Self-Healing
A running Pod was manually deleted using `kubectl delete pod`. The Kubernetes Deployment controller instantly detected the state divergence and reconciled the desired state by spinning up a new replacement Pod within seconds.

### C. Scaling
The Deployment was dynamically scaled from 3 down to 2 replicas (`kubectl scale --replicas=2`), verified, and then scaled back to 3 replicas seamlessly.

### D. Rolling Update & Rollback
- **Rolling Update:** Triggered via `kubectl set image` to update to the `:latest` tag. Zero-downtime transition was observed via `kubectl rollout status`.
- **Rollback:** Executed `kubectl rollout undo` to instantly revert the Deployment to the previous revision.

*Evidence:* Screenshots stored in `evidence/k8s-demo-self-healing.png`, `evidence/k8s-demo-scaling.png`, and `evidence/k8s-demo-rolling-update-rollback.png`.

---

## 7. Conclusion & Future Production Improvements

### Key Learnings
This project demonstrated the complete lifecycle of cloud-native application delivery: moving from an uncontainerized legacy app to a hardened Docker image, publishing to a public registry, and orchestrating a resilient, self-healing multi-node Kubernetes deployment.

### Production Improvements
For a real-world enterprise production environment, the following enhancements would be made:
1. **Ingress Controller & TLS:** Add an NGINX Ingress Controller with `cert-manager` for automatic HTTPS/TLS termination.
2. **Persistent Storage / Database:** Replace the in-memory Python list with a PostgreSQL StatefulSet or managed database.
3. **CI/CD Pipeline:** Automate building, scanning (Trivy/Scout), and deploying via GitHub Actions.
4. **Helm Chart:** Package the `k8s/` manifests into a Helm chart for multi-environment deployments (Dev/Staging/Prod).