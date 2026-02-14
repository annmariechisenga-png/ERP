from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "<h1>Welcome to the HR Automation Platform</h1><p>Employee data, payroll, and more coming soon.</p>"

if __name__ == "__main__":
    app.run(debug=True)
