from flask import Flask
import json

app = Flask(__name__)

# Load configuration
with open('/app/config.json', 'r') as f:
    config = json.load(f)

@app.route('/')
def hello():
    return f"Hello from {config['app_name']}! Running on port {config['port']}\n"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config['port'])
