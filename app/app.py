from flask import Flask, jsonify
import os, socket

app = Flask(__name__)

@app.get("/")
def home():
    return jsonify(app="NuevaNet API",
                   entorno=os.getenv("APP_ENV", "dev"),
                   host=socket.gethostname())

@app.get("/health")
def health():
    return jsonify(status="ok")
