# Distributed Systems — Docker & Local Kubernetes Project

**Author:** Achraf Gounadfa  
**Cohort:** MSc Data Engineering (MSc DE1)  
**GitHub Repository:** [https://github.com/achrafgounadfa/msc-de1-distributed-systems-docker-k8s](https://github.com/achrafgounadfa/msc-de1-distributed-systems-docker-k8s)

---

## 🐳 Docker Hub Image & Traceability

The application image has been containerized, secured, and published to Docker Hub.

* **Public Docker Hub URL:** [https://hub.docker.com/r/achraf2026/msc-de1-flask-app](https://hub.docker.com/r/achraf2026/msc-de1-flask-app)
* **Image Name:** `achraf2026/msc-de1-flask-app`
* **Final Tag for Kubernetes Deployment:** **`1.0.1`** *(0 Critical Vulnerabilities)*
* **Additional Tags:** `1.0.0`, `latest`

> **Traceability Notice:** The Docker Hub image tag used for Kubernetes orchestration in `k8s/deployment.yaml` strictly corresponds to `achraf2026/msc-de1-flask-app:1.0.1`.

---

## 🚀 Quick Start (Local Docker Execution)

### Run using Docker Compose
```bash
docker compose up -d