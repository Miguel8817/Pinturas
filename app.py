from flask import Flask, render_template, request, url_for, redirect, flash, session
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
import MySQLdb.cursors
import os
from datetime import datetime



app = Flask(__name__)
app.secret_key = os.urandom(24)
#Establecer el entorno de ejecución:
app.config["ENV"] = os.getenv("FLASK_ENV", "production")
#Habilitar/deshabilitar el modo debug:
app.config["DEBUG"] = app.config["ENV"] == "development"


# En la sección de configuración MySQL (reemplaza tu configuración actual)
app.config['MYSQL_HOST'] = os.getenv('MYSQLHOST', 'trolley.proxy.rlwy.net')
# os.getenv Gestionar configuraciones sensibles.
app.config['MYSQL_USER'] = os.getenv('MYSQLUSER', 'root')
app.config['MYSQL_PASSWORD'] = os.getenv('MYSQLPASSWORD', 'VQKNeMDpSsHWUWuLDUJiIwhqpRrEhAgi')
app.config['MYSQL_DB'] = os.getenv('MYSQLDATABASE', 'railway')
app.config['MYSQL_PORT'] = int(os.getenv('MYSQLPORT', 33367))  # ¡Asegúrate de convertir a entero!
app.config['MYSQL_CONNECT_TIMEOUT'] = 10  # Previene timeouts
mysql = MySQL(app)



# Filtro para formatear fechas en Jinja
def format_datetime(value):
    if isinstance(value, datetime):
        return value.strftime('%Y-%m-%d %H:%M:%S')
    return value
app.jinja_env.filters['datetime'] = format_datetime

@app.route('/inicios')
def inicio():
    return render_template('inicio.html')

# Página de inicio
@app.route('/')
def index():
    return render_template('index.html')

# Redirección al login
@app.route('/seccion')
def login_redirect():
    return render_template('login.html')

# Formulario de registro
@app.route('/registro')
def registro_form():
    return render_template('registro.html')

# Registro de usuario
@app.route('/record', methods=['GET', 'POST'])
def registrar_usuario():
    if request.method == 'POST':
        name = request.form['name']
        apellido = request.form['apellido']
        email = request.form['email']
        password = request.form['password']

        if not name or not apellido or not email or not password:
            flash('Todos los campos son obligatorios.', 'error')
            return render_template('registro.html')

        cur = mysql.connection.cursor()
        try:
            cur.execute('SELECT * FROM user WHERE email = %s', (email,))
            existing_user = cur.fetchone()
            if existing_user:
                flash('El correo electrónico ya está registrado. Por favor, inicie sesión.', 'error')
                return redirect(url_for('registro_form'))

            hashed_password = generate_password_hash(password)
            cur.execute('INSERT INTO user (name, apellido, email, password) VALUES (%s, %s, %s, %s)',
                        (name, apellido, email, hashed_password))
            mysql.connection.commit()

            # Aquí enviamos un mensaje de éxito para mostrar en la misma página
            

        except Exception as e:
            flash(f'Error al registrar usuario: {e}', 'error')
            mysql.connection.rollback()
        finally:
            cur.close()

    flash('Usuario ingresado correctamente.', 'error')
    return redirect(url_for('inicio'))




# Inicio de sesión
@app.route('/login', methods=['GET', 'POST'])
def iniciar_sesion():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        if not email or not password:
            flash('Todos los campos son obligatorios.', 'error')
            return render_template('login.html')

        cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        try:
            cur.execute('SELECT * FROM user WHERE email = %s', (email,))
            user = cur.fetchone()

            if not user:
                flash('El correo electrónico no está registrado.', 'error')
                return render_template('login.html')

            if check_password_hash(user['password'], password):
                session['email'] = user['email']
                flash('Inicio de sesión exitoso', 'success')
                return redirect(url_for('inicio'))

            else:
                flash('Contraseña incorrecta', 'error')
                return render_template('login.html')

        except Exception as e:
            flash(f'Error al iniciar sesión: {e}', 'error')
            return render_template('login.html')
        finally:
            cur.close()

    return render_template('login.html')

# Cierre de sesión
@app.route('/logout')
def logout():
    session.clear()
    flash('Sesión cerrada', 'info')
    return redirect(url_for('index'))

@app.route('/promo')
def promos():
    return render_template('promo.html')



@app.route('/Materiales')
def materiales():
    return render_template ('Materiales.html')



@app.route('/Nosotros')
def nosotro():
    return render_template ('Nosotros.html')

@app.route('/Electricidad')
def electrico():
    return render_template ('Electricidad.html')

@app.route('/Plomeria')
def fontaneria():
    return render_template('Plomeria.html')

@app.route('/Herramientas')
def herramienta():
    return render_template('herramientas.html')

if __name__ == '__main__':
    try:
        port = int(os.environ.get('PORT', 33367))
        print(f"* Running on port: {port}")  # Para verificar en logs
        app.run(host='0.0.0.0', port=port)
    except Exception as e:
        print(f"Error starting server: {e}")
        raise
