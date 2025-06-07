function validarContrasena() {
    const password = document.getElementById("password").value;
    const confirmarPassword = document.getElementById("confirm_password").value;
    const mensajeError = document.getElementById("mensajeError");

    if (password !== confirm_password) {
        mensajeError.textContent = "Las contraseñas no coinciden.";
        return false; // Evita que el formulario se envíe
    } else {
        mensajeError.textContent = ""; // Limpia el mensaje de error
        return true; // Permite que el formulario se envíe
    }
}

// Ejemplo de cómo usar esta función al enviar un formulario:
const formulario = document.getElementById("registroForm"); // Reemplaza "registroForm" con el ID de tu formulario

if (formulario) {
    formulario.addEventListener("submit", function (event) {
        if (!validarContrasena()) {
            event.preventDefault(); // Detiene el envío del formulario si las contraseñas no coinciden
        }
    });
  }