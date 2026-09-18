# run.py

#from app import app

#if __name__ == '__main__':
   # app.run()

# run.py
import os
from app import app

if __name__ == '__main__':
    # Permet d'écouter sur 0.0.0.0 (obligatoire pour Docker) et d'utiliser les variables d'environnement
    host = os.environ.get("FLASK_RUN_HOST", "0.0.0.0")
    port = int(os.environ.get("PORT", 5000))
    app.run(host=host, port=port)