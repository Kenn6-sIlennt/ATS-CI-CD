"""Modul aplikasi Flask untuk CI/CD Pipeline ATS."""

from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    """Halaman utama aplikasi."""
    return "Selamat Datang di ATS CI/CD Secure Flask App!"

@app.route("/health")
def health():
    """Endpoint pengecekan kesehatan aplikasi."""
    return {"status": "healthy", "service": "flask-app"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # nosemgrep
