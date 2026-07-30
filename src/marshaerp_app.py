from flask import Flask, render_template_string, jsonify
from config import Config
import psycopg2
import psycopg2.extras

app = Flask(__name__)

# HTML Template
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>MarshaERP - Leave Management System</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 0; padding: 20px; background: #f0f2f5; }
        h1 { color: #1a73e8; margin-bottom: 10px; }
        h2 { color: #2c3e50; border-bottom: 2px solid #1a73e8; padding-bottom: 10px; }
        .nav { background: #1a73e8; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
        .nav a { color: white; text-decoration: none; margin-right: 20px; padding: 8px 16px; border-radius: 5px; }
        .nav a:hover { background: #1557b0; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background: #1a73e8; color: white; }
        tr:hover { background: #f5f5f5; }
        .badge { background: #28a745; color: white; padding: 4px 8px; border-radius: 4px; font-size: 12px; }
        .stats { display: flex; gap: 20px; margin-bottom: 20px; }
        .stat-card { background: white; padding: 20px; border-radius: 8px; flex: 1; text-align: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stat-number { font-size: 36px; font-weight: bold; color: #1a73e8; }
        .stat-label { color: #666; margin-top: 5px; }
        footer { text-align: center; margin-top: 30px; padding: 20px; color: #666; }
    </style>
</head>
<body>
    <h1>🌍 MarshaERP - Human Resource Management System</h1>
    <div class="nav">
        <a href="/">🏠 Dashboard</a>
        <a href="/leave/types">📋 Leave Types</a>
        <a href="/leave/policies">📈 Leave Policies</a>
        <a href="/leave/employees">👥 Employees</a>
        <a href="/leave/approvals">✅ Approval Chains</a>
    </div>
    
    {% block content %}{% endblock %}
    <footer>
        <p>MarshaERP v1.0 | Powered by PostgreSQL | &copy; 2026</p>
    </footer>
</body>
</html>
"""

def get_db_connection():
    return psycopg2.connect(**Config.get_postgres_params())

def get_count(table):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(f"SELECT COUNT(*) FROM {table};")
        count = cur.fetchone()[0]
        conn.close()
        return count
    except Exception as e:
        return 0

@app.route("/")
def dashboard():
    conn = get_db_connection()
    cur = conn.cursor()
    
    # Get statistics
    cur.execute("SELECT COUNT(*) FROM employees;")
    emp_count = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM leave_types;")
    leave_types = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM leave_policy;")
    policies = cur.fetchone()[0]
    
    cur.execute("SELECT COUNT(*) FROM leave_approval_chain;")
    chains = cur.fetchone()[0]
    
    conn.close()
    
    return render_template_string("""
        {% extends template %}
        {% block content %}
        <div class="stats">
            <div class="stat-card">
                <div class="stat-number">{{ emp_count }}</div>
                <div class="stat-label">Total Employees</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{{ leave_types }}</div>
                <div class="stat-label">Leave Types</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{{ policies }}</div>
                <div class="stat-label">Leave Policies</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">{{ chains }}</div>
                <div class="stat-label">Approval Chains</div>
            </div>
        </div>
        <div class="card">
            <h2>Welcome to MarshaERP</h2>
            <p>Your complete HR and Payroll Management Solution for Local Government Authorities.</p>
            <p>✅ PostgreSQL Database Connected</p>
            <p>✅ Leave Management System Ready</p>
            <p>✅ {{ emp_count }} Employee Records Loaded</p>
            <p>✅ {{ leave_types }} Leave Types Configured</p>
            <p>✅ {{ policies }} Accrual Policies Active</p>
        </div>
        {% endblock %}
    """, template=HTML_TEMPLATE, emp_count=emp_count, leave_types=leave_types, policies=policies, chains=chains)

@app.route("/leave/types")
def leave_types():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute("SELECT * FROM leave_types ORDER BY leave_type_id;")
    types = cur.fetchall()
    conn.close()
    
    return render_template_string("""
        {% extends template %}
        {% block content %}
        <div class="card">
            <h2>📋 Leave Types</h2>
            <table>
                <tr><th>Code</th><th>Name</th><th>Applicable To</th><th>Max/Month</th><th>Max/Year</th><th>Paid</th></tr>
                {% for t in types %}
                <tr>
                    <td>{{ t.leave_type_code }}</td>
                    <td>{{ t.leave_type_name }}</td>
                    <td>{{ t.applicable_to or 'All' }}</td>
                    <td>{{ t.max_days_per_month or '-' }}</td>
                    <td>{{ t.max_days_per_year or '-' }}</td>
                    <td>✅</td>
                </tr>
                {% endfor %}
            </table>
        </div>
        {% endblock %}
    """, template=HTML_TEMPLATE, types=types)

@app.route("/leave/policies")
def leave_policies():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute("SELECT * FROM leave_policy ORDER BY leave_type, division;")
    policies = cur.fetchall()
    conn.close()
    
    return render_template_string("""
        {% extends template %}
        {% block content %}
        <div class="card">
            <h2>📈 Leave Policies (Accrual Rates)</h2>
            <table>
                <tr><th>Leave Type</th><th>Division</th><th>Accrual Rate</th><th>Max Accumulation</th></tr>
                {% for p in policies %}
                <tr>
                    <td>{{ p.leave_type }}</td>
                    <td>{{ p.division or '-' }}</td>
                    <td><strong>{{ p.accrual_rate }}</strong> days/month</td>
                    <td>{{ p.max_accumulation or '-' }} days</td>
                </tr>
                {% endfor %}
            </table>
        </div>
        {% endblock %}
    """, template=HTML_TEMPLATE, policies=policies)

@app.route("/leave/employees")
def employee_balances():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute("""
        SELECT e.employee_id, e.name, e.salary_scale, e.department,
               COALESCE(lb.local_leave_balance, 0) as leave_balance
        FROM employees e
        LEFT JOIN leave_balances lb ON e.employee_id = lb.employee_id
        LIMIT 50;
    """)
    employees = cur.fetchall()
    conn.close()
    
    return render_template_string("""
        {% extends template %}
        {% block content %}
        <div class="card">
            <h2>👥 Employee Leave Balances</h2>
            <table>
                <tr><th>Employee ID</th><th>Name</th><th>Department</th><th>Salary Scale</th><th>Leave Balance</th></tr>
                {% for emp in employees %}
                <tr>
                    <td>{{ emp.employee_id }}</td>
                    <td>{{ emp.name }}</td>
                    <td>{{ emp.department or '-' }}</td>
                    <td>{{ emp.salary_scale or '-' }}</td>
                    <td><span class="badge">{{ emp.leave_balance }} days</span></td>
                </tr>
                {% endfor %}
            </table>
        </div>
        {% endblock %}
    """, template=HTML_TEMPLATE, employees=employees)

@app.route("/leave/approvals")
def approval_chains():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute("SELECT * FROM leave_approval_chain LIMIT 30;")
    chains = cur.fetchall()
    conn.close()
    
    return render_template_string("""
        {% extends template %}
        {% block content %}
        <div class="card">
            <h2>✅ Leave Approval Chains</h2>
            <table>
                <tr><th>Position</th><th>Step</th><th>Approver Role</th><th>Approver Position</th></tr>
                {% for c in chains %}
                <tr>
                    <td>{{ c.position_id }}</td>
                    <td>{{ c.step_number }}</td>
                    <td>{{ c.approver_role }}</td>
                    <td>{{ c.approver_position_id or '-' }}</td>
                </tr>
                {% endfor %}
            </table>
        </div>
        {% endblock %}
    """, template=HTML_TEMPLATE, chains=chains)

if __name__ == "__main__":
    print("=" * 50)
    print("🌍 MarshaERP - Leave Management System")
    print("=" * 50)
    print(f"✅ PostgreSQL: {Config.get_postgres_params()['host']}:{Config.get_postgres_params()['port']}")
    print(f"🌐 Web Interface: http://127.0.0.1:5000")
    print("=" * 50)
    app.run(debug=True, host='127.0.0.1', port=5000)
