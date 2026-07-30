from flask import Flask, render_template_string, request, session, redirect, url_for
from config import Config
import psycopg2
import psycopg2.extras

app = Flask(__name__)
app.secret_key = 'marshaerp-2026-secret-key'

PORTAL_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MarshaERP - Employee Self Service Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: #f0f2f5; font-family: 'Segoe UI', sans-serif; }
        .sidebar { position: fixed; top: 0; left: 0; height: 100vh; width: 280px; background: linear-gradient(135deg, #1a5276 0%, #2e86c1 100%); color: white; padding: 20px 0; }
        .sidebar h3 { padding: 15px 25px; }
        .sidebar .nav-link { color: white; padding: 12px 25px; display: block; text-decoration: none; }
        .sidebar .nav-link:hover { background: rgba(255,255,255,0.2); }
        .sidebar .nav-link i { width: 25px; margin-right: 10px; }
        .content { margin-left: 280px; padding: 20px; }
        .header { background: white; padding: 15px 25px; border-radius: 10px; margin-bottom: 25px; }
        .card { background: white; border-radius: 10px; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .btn-primary { background: #1a5276; border: none; }
        .btn-primary:hover { background: #2e86c1; }
        .form-control, .form-select { margin-bottom: 15px; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h3> MarshaERP</h3>
        <nav>
            <a class="nav-link" href="/"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
            <a class="nav-link" href="/leave/request"><i class="fas fa-calendar-alt"></i> Leave Request</a>
            <a class="nav-link" href="/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </nav>
    </div>
    <div class="content">
        <div class="header">
            <h4>Welcome, {{ session.get('name', 'Employee') }}</h4>
            <p>{{ session.get('department', 'HR') }} | {{ session.get('gender', '') }} | Balance: {{ session.get('balance', 0) }} days</p>
        </div>
        {% block content %}{% endblock %}
    </div>
</body>
</html>
"""

def get_employee_by_id(employee_id):
    conn = psycopg2.connect(**Config.get_postgres_params())
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute("""
        SELECT e.employee_id, e.name, e.gender, e.department,
               COALESCE(lb.local_leave_balance::TEXT, '0') as leave_balance
        FROM employees e
        LEFT JOIN leave_balances lb ON lb.employee_id::TEXT = e.employee_id
        WHERE e.employee_id = %s
        LIMIT 1
    """, (employee_id,))
    employee = cur.fetchone()
    conn.close()
    return dict(employee) if employee else None

def get_leave_types_for_gender(gender):
    conn = psycopg2.connect(**Config.get_postgres_params())
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    if gender == 'Female':
        cur.execute("SELECT leave_type_code, leave_type_name FROM leave_types WHERE applicable_to IN ('All', 'Female Only') ORDER BY leave_type_id;")
    else:
        cur.execute("SELECT leave_type_code, leave_type_name FROM leave_types WHERE applicable_to IN ('All', 'Male Only') ORDER BY leave_type_id;")
    types = cur.fetchall()
    conn.close()
    return types

@app.route("/login", methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        employee_id = request.form.get('employee_id')
        employee = get_employee_by_id(employee_id)
        if employee:
            session['employee_id'] = employee['employee_id']
            session['name'] = employee['name']
            session['gender'] = employee['gender'] or 'Male'
            session['department'] = employee['department'] or 'HR'
            session['balance'] = float(employee.get('leave_balance', 0))
            return redirect(url_for('dashboard'))
        return "Employee not found"
    return '''
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header bg-primary text-white"><h4>MarshaERP Login</h4></div>
                    <div class="card-body">
                        <form method="POST">
                            <input type="text" name="employee_id" class="form-control mb-2" placeholder="Employee ID" required>
                            <input type="password" name="password" class="form-control mb-2" placeholder="PIN">
                            <button type="submit" class="btn btn-primary w-100">Login</button>
                        </form>
                        <small>Try: ZM09-CHL-2024-000001</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
    '''

@app.route("/")
def dashboard():
    if 'employee_id' not in session:
        return redirect(url_for('login'))
    return render_template_string(PORTAL_HTML, content='<div class="card"><h4>Dashboard</h4><a href="/leave/request" class="btn btn-primary">Apply for Leave</a></div>')

@app.route("/leave/request", methods=['GET', 'POST'])
def leave_request():
    if 'employee_id' not in session:
        return redirect(url_for('login'))
    if request.method == 'POST':
        return render_template_string(PORTAL_HTML, content='<div class="card"><div class="alert alert-success">Leave request submitted!</div><a href="/" class="btn btn-primary">Back</a></div>')
    leave_types = get_leave_types_for_gender(session.get('gender', 'Male'))
    options = '<option value="">Select Leave Type</option>'
    for t in leave_types:
        options += f'<option value="{t["leave_type_code"]}">{t["leave_type_name"]}</option>'
    return render_template_string(PORTAL_HTML, content=f'''
        <div class="card">
            <h4>Submit Leave Request</h4>
            <form method="POST">
                <select name="leave_type" class="form-control" required>{options}</select>
                <textarea name="reason" class="form-control" rows="3" placeholder="Reason" required></textarea>
                <input type="date" name="start_date" class="form-control" required>
                <input type="date" name="end_date" class="form-control" required>
                <button type="submit" class="btn btn-primary">Submit</button>
            </form>
        </div>
    ''')

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == "__main__":
    print("MarshaERP Portal running at http://127.0.0.1:5000")
    app.run(debug=True, host='127.0.0.1', port=5000)