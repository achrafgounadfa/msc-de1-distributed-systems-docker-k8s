# 1. Image de base légère et officielle
FROM python:3.11-slim

# 2. Variables d'environnement
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_RUN_HOST=0.0.0.0 \
    PORT=5000

# 3. SÉCURITÉ : appliquer les correctifs de sécurité de l'OS
#    Réduit les CVE CRITICAL/HIGH héritées de l'image de base Debian
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 4. Dossier de travail
WORKDIR /app

# 5. SÉCURITÉ : utilisateur non-root
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -s /bin/sh -m appuser

# 6. Dépendances d'abord (cache Docker)
COPY requirements.txt .

# 7. Installation des dépendances Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 8. Copie du code applicatif
COPY . .

# 9. SÉCURITÉ : droits pour l'utilisateur non-root
RUN chown -R appuser:appuser /app

# 10. Bascule sur l'utilisateur non-root
USER appuser

# 11. Port exposé
EXPOSE 5000

# 12. HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/')" || exit 1

# 13. Commande de lancement
CMD ["python", "run.py"]