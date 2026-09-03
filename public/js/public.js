// API_BASE dinamico: funciona en docker (raiz "/") y en modo local
// (servido bajo "/student-crud"). Se deriva de la ubicacion de este script.
const API_BASE = (() => {
  const src =
    (document.currentScript && document.currentScript.src) ||
    window.location.href;
  const path = new URL(src, window.location.origin).pathname;
  return path.replace(/\/js\/[^/]+$/, "").replace(/\/$/, "");
})();

const form = document.getElementById("inscripcion-form");
const carreraSelect = document.getElementById("carrera");
const mensaje = document.getElementById("mensaje");
const boton = document.getElementById("btn-inscribir");

async function cargarCarreras() {
  try {
    const response = await fetch(`${API_BASE}/carreras`);

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "No se pudieron cargar las carreras.");
    }

    data.forEach((carrera) => {
      const option = document.createElement("option");

      option.value = carrera.id;
      option.textContent = `${carrera.nombre} (${carrera.codigo})`;

      carreraSelect.appendChild(option);
    });
  } catch (error) {
    console.error(error);
    mostrarMensaje(error.message, "error");
  }
}

async function crearInscripcion(datos) {
  const response = await fetch(`${API_BASE}/inscripciones`, {
    method: "POST",

    headers: {
      "Content-Type": "application/json",
    },

    body: JSON.stringify(datos),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo realizar la inscripción.");
  }

  return data;
}

form.addEventListener("submit", async function (event) {
  event.preventDefault();

  ocultarMensaje();

  boton.disabled = true;
  boton.textContent = "Procesando...";

  try {
    const datos = {
      nombre: document.getElementById("nombre").value.trim(),
      apellido: document.getElementById("apellido").value.trim(),
      dni: document.getElementById("dni").value.trim(),
      email: document.getElementById("email").value.trim(),
      telefono: document.getElementById("telefono").value.trim(),
      nacionalidad: document.getElementById("nacionalidad").value.trim(),
      carrera_id: Number(carreraSelect.value),
    };

    if (!datos.nombre) {
      throw new Error("El nombre es obligatorio.");
    }

    if (!datos.apellido) {
      throw new Error("El apellido es obligatorio.");
    }

    if (!datos.dni) {
      throw new Error("El DNI es obligatorio.");
    }

    if (!datos.email) {
      throw new Error("El email es obligatorio.");
    }

    if (!datos.carrera_id) {
      throw new Error("Seleccioná una carrera.");
    }

    await crearInscripcion(datos);

    mostrarMensaje("¡Inscripción realizada correctamente!", "success");

    form.reset();
  } catch (error) {
    console.error(error);

    mostrarMensaje(error.message, "error");
  } finally {
    boton.disabled = false;
    boton.textContent = "Inscribirme";
  }
});

function mostrarMensaje(texto, tipo) {
  mensaje.textContent = texto;
  mensaje.className = `message ${tipo}`;
}

function ocultarMensaje() {
  mensaje.textContent = "";
  mensaje.className = "message";
}

cargarCarreras();
