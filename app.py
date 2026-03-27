import os
import uuid
import psycopg2
import psycopg2.extras
from functools import wraps
from flask import (
    Flask, render_template, render_template_string, request,
    redirect, url_for, session, flash, g
)

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "rimfrost_super_secret_2026")

DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql://rimfrost:rimfrost_db_pass_2026@db:5432/rimfrost"
)

app.config["DATABASE_URL"] = DATABASE_URL
app.config["FLASK_ENV"] = os.environ.get("FLASK_ENV", "production")
app.config["DEBUG_MODE"] = os.environ.get("DEBUG", "False")
app.config["INTERNAL_API_KEY"] = "rf-int-api-4f8a2c61e9b7"


def get_db():
    if "db" not in g:
        g.db = psycopg2.connect(DATABASE_URL)
        g.db.autocommit = True
    return g.db


@app.teardown_appcontext
def close_db(exception):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if "user_id" not in session:
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    return decorated


def get_current_user():
    if "user_id" not in session:
        return None
    db = get_db()
    cur = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("SELECT * FROM users WHERE id = %s", (session["user_id"],))
    user = cur.fetchone()
    cur.close()
    return user


@app.route("/")
def index():
    if "user_id" in session:
        return redirect(url_for("dashboards"))
    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = request.form.get("email", "").strip()
        password = request.form.get("password", "").strip()

        db = get_db()
        cur = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cur.execute(
            "SELECT * FROM users WHERE email = %s AND password = %s",
            (email, password)
        )
        user = cur.fetchone()
        cur.close()

        if user:
            session["user_id"] = str(user["id"])
            session["user_name"] = user["full_name"]
            session["user_email"] = user["email"]
            session["user_role"] = user["role"]
            return redirect(url_for("dashboards"))

        flash("Invalid email or password.", "error")
        return redirect(url_for("login"))

    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/dashboards")
@login_required
def dashboards():
    user = get_current_user()
    db = get_db()
    cur = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute(
        "SELECT * FROM dashboards WHERE owner_id = %s ORDER BY updated_at DESC",
        (session["user_id"],)
    )
    user_dashboards = cur.fetchall()
    cur.close()
    return render_template("dashboards.html", dashboards=user_dashboards, user=user)


@app.route("/dashboards/create", methods=["GET", "POST"])
@login_required
def create_dashboard():
    user = get_current_user()
    if request.method == "POST":
        title = request.form.get("title", "").strip()
        description = request.form.get("description", "").strip()
        dashboard_type = request.form.get("dashboard_type", "general")

        if not title:
            flash("Title is required.", "error")
            return redirect(url_for("create_dashboard"))

        dashboard_id = str(uuid.uuid4())
        db = get_db()
        cur = db.cursor()
        cur.execute(
            """INSERT INTO dashboards (id, title, description, dashboard_type, owner_id, created_at, updated_at)
               VALUES (%s, %s, %s, %s, %s, NOW(), NOW())""",
            (dashboard_id, title, description, dashboard_type, session["user_id"])
        )
        cur.close()

        flash("Dashboard created successfully.", "success")
        return redirect(url_for("view_dashboard", dashboard_id=dashboard_id))

    return render_template("create_dashboard.html", user=user)


@app.route("/dashboards/<dashboard_id>")
@login_required
def view_dashboard(dashboard_id):
    user = get_current_user()
    db = get_db()
    cur = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    cur.execute("SELECT * FROM dashboards WHERE id = %s", (dashboard_id,))
    dashboard = cur.fetchone()

    if not dashboard:
        flash("Dashboard not found.", "error")
        return redirect(url_for("dashboards"))

    cur.execute(
        "SELECT * FROM widgets WHERE dashboard_id = %s ORDER BY position",
        (dashboard_id,)
    )
    widgets = cur.fetchall()
    cur.close()

    # VULNERABILITY: Title is rendered through Jinja2 template engine
    # instead of being passed as a safe variable
    rendered_title = render_template_string(dashboard["title"])

    return render_template(
        "view_dashboard.html",
        dashboard=dashboard,
        rendered_title=rendered_title,
        widgets=widgets,
        user=user,
        description=dashboard["description"]
    )


@app.route("/dashboards/<dashboard_id>/edit", methods=["GET", "POST"])
@login_required
def edit_dashboard(dashboard_id):
    user = get_current_user()
    db = get_db()
    cur = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    cur.execute("SELECT * FROM dashboards WHERE id = %s", (dashboard_id,))
    dashboard = cur.fetchone()

    if not dashboard:
        flash("Dashboard not found.", "error")
        return redirect(url_for("dashboards"))

    if request.method == "POST":
        title = request.form.get("title", "").strip()
        description = request.form.get("description", "").strip()
        dashboard_type = request.form.get("dashboard_type", dashboard["dashboard_type"])

        if not title:
            flash("Title is required.", "error")
            return redirect(url_for("edit_dashboard", dashboard_id=dashboard_id))

        cur2 = db.cursor()
        cur2.execute(
            """UPDATE dashboards SET title = %s, description = %s, dashboard_type = %s, updated_at = NOW()
               WHERE id = %s""",
            (title, description, dashboard_type, dashboard_id)
        )
        cur2.close()

        flash("Dashboard updated successfully.", "success")
        return redirect(url_for("view_dashboard", dashboard_id=dashboard_id))

    cur.close()
    return render_template("edit_dashboard.html", dashboard=dashboard, user=user)


@app.route("/dashboards/<dashboard_id>/delete", methods=["POST"])
@login_required
def delete_dashboard(dashboard_id):
    db = get_db()
    cur = db.cursor()
    cur.execute("DELETE FROM widgets WHERE dashboard_id = %s", (dashboard_id,))
    cur.execute("DELETE FROM dashboards WHERE id = %s", (dashboard_id,))
    cur.close()
    flash("Dashboard deleted.", "success")
    return redirect(url_for("dashboards"))


@app.route("/settings")
@login_required
def settings():
    user = get_current_user()
    return render_template("settings.html", user=user)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
