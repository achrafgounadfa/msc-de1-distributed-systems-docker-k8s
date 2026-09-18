# Container Security & Risk Reduction Report

**Project:** MSc DE1 — Distributed Systems (Docker & Local Kubernetes)  
**Author:** Achraf Gounadfa  
**Final Image Scanned:** `achraf2026/msc-de1-flask-app:1.0.1`  
**Docker Hub Repository:** https://hub.docker.com/r/achraf2026/msc-de1-flask-app  
**Date of Scan:** 2026-09-18  
**Tool Used:** Docker Scout  

---

## 1. Image and Runtime Security Measures

| # | Requirement | Implementation | Evidence |
|---|---|---|---|
| 1 | **Non-root execution** | Dedicated user `appuser` (UID/GID 1000) created in Dockerfile. Enforced with `USER appuser` and `user: "1000:1000"` in Compose. | `docker exec <c> id` → `uid=1000(appuser)` |
| 2 | **Minimal image** | Base image `python:3.11-slim`. `.dockerignore` used to exclude `venv/`, `.git/`, docs and k8s files. | Image content size: 50.7 MB |
| 3 | **Dependency hygiene** | Original `requirements.txt` used without unnecessary additions. `pip install --no-cache-dir` prevents cache bloating. | `git diff requirements.txt` |
| 4 | **No secrets in images** | Zero credentials or tokens in Dockerfile or committed code. App config injected via environment variables (`PORT`, `FLASK_RUN_HOST`). | Clean `docker history` |
| 5 | **Reduced privileges** | `security_opt: no-new-privileges:true` and `cap_drop: ALL` configured in Compose. No privileged mode, no host networking. | `compose.yaml` |
| 6 | **Read-only approach** | Enforced `read_only: true` on root filesystem with a `tmpfs` mounted on `/tmp` (`rw,noexec,nosuid,size=32m`). App tested and healthy. | `docker compose ps` → `(healthy)` |
| 7 | **Resource awareness** | Resource requests and limits defined in Kubernetes Deployment to prevent resource exhaustion attacks. | `k8s/deployment.yaml` |

---

## 2. Vulnerability Scan & Risk Reduction (Before vs After)

To comply with the academic security grading principle (*Identify, Reduce, and Explain Risk*), an initial scan was conducted on image `1.0.0`, followed by an OS package upgrade in the Dockerfile (`apt-get upgrade`), resulting in image `1.0.1`.

###  Comparative Reduction Table

| Severity | Initial (`1.0.0`) | Patched (`1.0.1`) | Reduction / Impact |
|---|---:|---:|---|
| **CRITICAL** | **5** | **0** | **-100% (All Critical CVEs eliminated)** |
| **HIGH** | **12** | **6** | **-50% (Reduced by half)** |
| **MEDIUM** | **12** | **3** | **-75% (Reduced by 75%)** |
| **LOW** | **30** | **25** | **-17%** |
| **TOTAL** | **59** | **34** | **Vulnerabilities reduced by 42%** |

### Actions Taken to Reduce Risk
1. **OS Security Patching:** Added `apt-get update && apt-get upgrade -y` in the Dockerfile build process to fetch upstream Debian security patches.
2. **Eliminated Critical CVEs:** Completely fixed `perl` and `libsqlite3` Critical vulnerabilities (`CVE-2026-8376`, `CVE-2026-42496`, etc.).
3. **Runtime Hardening:** Enforced `read_only: true` root filesystem and dropped all Linux capabilities (`cap_drop: ALL`).

### Remaining HIGH Vulnerabilities & Mitigation
The remaining 6 HIGH vulnerabilities are located in deep Debian base OS libraries (`glibc`, `libk5crypto3`) where upstream Debian patches are not yet published for the `python:3.11-slim` base image.

**Risk Mitigation for Remaining Findings:**
* **Attack Surface:** The Flask application does not expose or interact with these OS libraries directly.
* **Containment:** The container runs as non-root (`appuser`), with a read-only root filesystem, no Linux capabilities, and will run under a Kubernetes `NetworkPolicy` and `securityContext`.

---

## 3. Software Bill of Materials (SBOM)

* **Format:** SPDX (JSON 2.3)
* **File:** [`security/sbom.spdx.json`](./sbom.spdx.json)
* **Command:** `docker scout sbom --format spdx achraf2026/msc-de1-flask-app:1.0.1 > security/sbom.spdx.json`