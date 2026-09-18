# 1. Image de base légère et officielle
FROM python:3.11-slim

# 2. Variables d'environnement pour Python et Flask
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_RUN_HOST=0.0.0.0 \
    PORT=5000

# 3. Dossier de travail dans le conteneur
WORKDIR /app

# 4. SÉCURITÉ : Créer un utilisateur non-root (appuser)
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -s /bin/sh -m appuser

# 5. Copier d'abord les dépendances (Optimisation du cache Docker)
COPY requirements.txt .

# 6. Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# 7. Copier le reste du code de l'application
COPY . .

# 8. SÉCURITÉ : Donner les droits du dossier /app à notre utilisateur non-root
RUN chown -R appuser:appuser /app

# 9. Basculer sur l'utilisateur non-root
USER appuser

# 10. Exposer le port de Flask
EXPOSE 5000

# 11. HEALTHCHECK : Permet à Docker de vérifier que l'API répond
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/')" || exit 1

# 12. Commande de lancement de l'application
CMD ["python", "run.py"]