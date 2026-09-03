const API_BASE = "/student-crud";

const estudiantesContainer = document.getElementById("estudiantes-container");

const carrerasContainer = document.getElementById("carreras-container");

const inscripcionesContainer = document.getElementById(
  "inscripciones-container",
);

const mensaje = document.getElementById("mensaje");

// ======================================================
// MENSAJES
// ======================================================

function mostrarMensaje(texto, tipo) {
  mensaje.textContent = texto;
  mensaje.className = `message ${tipo}`;
}

function ocultarMensaje() {
  mensaje.textContent = "";
  mensaje.className = "message";
}

// ======================================================
// ESTUDIANTES
// ======================================================

async function obtenerEstudiantes() {
  const response = await fetch(`${API_BASE}/students`);

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudieron obtener los estudiantes.");
  }

  return data;
}

async function obtenerEstudiantePorId(id) {
  const response = await fetch(
    `${API_BASE}/students?id=${encodeURIComponent(id)}`,
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo obtener el estudiante.");
  }

  return data;
}

async function obtenerEstudiantePorDni(dni) {
  const response = await fetch(
    `${API_BASE}/students?dni=${encodeURIComponent(dni)}`,
  );

  if (response.status === 404) {
    return null;
  }

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo obtener el estudiante.");
  }

  return data;
}

async function obtenerEstudiantePorEmail(email) {
  const response = await fetch(
    `${API_BASE}/students?email=${encodeURIComponent(email)}`,
  );

  if (response.status === 404) {
    return null;
  }

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo consultar el estudiante.");
  }

  return data;
}

async function crearEstudiante(datos) {
  const response = await fetch(`${API_BASE}/students`, {
    method: "POST",

    headers: {
      "Content-Type": "application/json",
    },

    body: JSON.stringify(datos),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo crear el estudiante.");
  }

  return data;
}

async function actualizarEstudiante(id, datos) {
  const response = await fetch(
    `${API_BASE}/students?id=${encodeURIComponent(id)}`,
    {
      method: "PUT",

      headers: {
        "Content-Type": "application/json",
      },

      body: JSON.stringify(datos),
    },
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo actualizar el estudiante.");
  }

  return data;
}

async function eliminarEstudiante(id) {
  const response = await fetch(
    `${API_BASE}/students?id=${encodeURIComponent(id)}`,
    {
      method: "DELETE",
    },
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo eliminar el estudiante.");
  }

  return data;
}

// ======================================================
// RENDER ESTUDIANTES
// ======================================================

function renderizarEstudiantes(estudiantes) {
  if (!estudiantes || estudiantes.length === 0) {
    estudiantesContainer.innerHTML = "<p>No hay estudiantes registrados.</p>";

    return;
  }

  let html = `
    <table class="admin-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Apellido</th>
          <th>DNI</th>
          <th>Email</th>
          <th>Teléfono</th>
          <th>Acciones</th>
        </tr>
      </thead>

      <tbody>
  `;

  estudiantes.forEach((estudiante) => {
    html += `
      <tr>
        <td>${estudiante.id}</td>
        <td>${estudiante.nombre}</td>
        <td>${estudiante.apellido}</td>
        <td>${estudiante.dni}</td>
        <td>${estudiante.email}</td>
        <td>${estudiante.telefono || "-"}</td>

        <td>
          <button
            type="button"
            class="btn-editar-estudiante"
            data-id="${estudiante.id}"
          >
            Editar
          </button>

          <button
            type="button"
            class="btn-eliminar-estudiante"
            data-id="${estudiante.id}"
          >
            Eliminar
          </button>
        </td>
      </tr>
    `;
  });

  html += `
      </tbody>
    </table>
  `;

  estudiantesContainer.innerHTML = html;
}

// ======================================================
// CARGAR ESTUDIANTES
// ======================================================

async function cargarEstudiantes() {
  try {
    ocultarMensaje();

    const estudiantes = await obtenerEstudiantes();

    renderizarEstudiantes(estudiantes);
  } catch (error) {
    console.error(error);

    mostrarMensaje(error.message, "error");
  }
}

// ======================================================
// FORMULARIO ESTUDIANTE
// ======================================================

const formEstudiante = document.getElementById("form-estudiante");

const estudianteForm = document.getElementById("estudiante-form");

const btnNuevoEstudiante = document.getElementById("btn-nuevo-estudiante");

const btnCancelarEstudiante = document.getElementById(
  "btn-cancelar-estudiante",
);

let estudianteEditandoId = null;

function mostrarFormularioEstudiante(estudiante = null) {
  formEstudiante.classList.remove("hidden");

  if (!estudiante) {
    estudianteEditandoId = null;

    estudianteForm.reset();

    formEstudiante.querySelector("h3").textContent = "Nuevo estudiante";

    return;
  }

  estudianteEditandoId = estudiante.id;

  formEstudiante.querySelector("h3").textContent = "Editar estudiante";

  document.getElementById("estudiante-nombre").value = estudiante.nombre || "";

  document.getElementById("estudiante-apellido").value =
    estudiante.apellido || "";

  document.getElementById("estudiante-dni").value = estudiante.dni || "";

  document.getElementById("estudiante-email").value = estudiante.email || "";

  document.getElementById("estudiante-telefono").value =
    estudiante.telefono || "";

  document.getElementById("estudiante-nacionalidad").value =
    estudiante.nacionalidad || "";
}

function ocultarFormularioEstudiante() {
  formEstudiante.classList.add("hidden");

  estudianteEditandoId = null;

  estudianteForm.reset();

  formEstudiante.querySelector("h3").textContent = "Nuevo estudiante";
}

btnNuevoEstudiante.addEventListener("click", () => {
  mostrarFormularioEstudiante();
});

btnCancelarEstudiante.addEventListener("click", () => {
  ocultarFormularioEstudiante();
});

estudianteForm.addEventListener("submit", async function (event) {
  event.preventDefault();

  try {
    ocultarMensaje();

    const datos = {
      nombre: document.getElementById("estudiante-nombre").value.trim(),

      apellido: document.getElementById("estudiante-apellido").value.trim(),

      dni: document.getElementById("estudiante-dni").value.trim(),

      email: document.getElementById("estudiante-email").value.trim(),

      telefono: document.getElementById("estudiante-telefono").value.trim(),

      nacionalidad: document
        .getElementById("estudiante-nacionalidad")
        .value.trim(),
    };

    if (estudianteEditandoId) {
      await actualizarEstudiante(estudianteEditandoId, datos);

      mostrarMensaje("Estudiante actualizado correctamente.", "success");
    } else {
      await crearEstudiante(datos);

      mostrarMensaje("Estudiante creado correctamente.", "success");
    }

    ocultarFormularioEstudiante();

    await cargarEstudiantes();

    await refrescarDependencias();
  } catch (error) {
    console.error(error);

    mostrarMensaje(error.message, "error");
  }
});

// ======================================================
// ACCIONES DE LA TABLA DE ESTUDIANTES
// ======================================================

estudiantesContainer.addEventListener("click", async function (event) {
  const btnEditar = event.target.closest(".btn-editar-estudiante");

  const btnEliminar = event.target.closest(".btn-eliminar-estudiante");

  if (btnEditar) {
    const id = btnEditar.dataset.id;

    try {
      const estudiante = await obtenerEstudiantePorId(id);

      mostrarFormularioEstudiante(estudiante);

      window.scrollTo({
        top: 0,
        behavior: "smooth",
      });
    } catch (error) {
      console.error(error);

      mostrarMensaje(error.message, "error");
    }
  }

  if (btnEliminar) {
    const id = btnEliminar.dataset.id;

    const confirmar = confirm("¿Estás seguro de eliminar este estudiante?");

    if (!confirmar) {
      return;
    }

    try {
      await eliminarEstudiante(id);

      mostrarMensaje("Estudiante eliminado correctamente.", "success");

      await cargarEstudiantes();

      await refrescarDependencias();
    } catch (error) {
      console.error(error);

      mostrarMensaje(error.message, "error");
    }
  }
});

// ======================================================
// BÚSQUEDA DE ESTUDIANTES
// ======================================================

const tipoBusquedaEstudiante = document.getElementById(
  "tipo-busqueda-estudiante",
);

const buscarEstudianteInput = document.getElementById("buscar-estudiante");

const btnBuscarEstudiante = document.getElementById("btn-buscar-estudiante");

const btnListarEstudiantes = document.getElementById("btn-listar-estudiantes");

function actualizarPlaceholderBusqueda() {
  const tipoBusqueda = tipoBusquedaEstudiante.value;

  if (tipoBusqueda === "id") {
    buscarEstudianteInput.placeholder = "Buscar por ID...";
  } else if (tipoBusqueda === "dni") {
    buscarEstudianteInput.placeholder = "Buscar por DNI...";
  } else if (tipoBusqueda === "email") {
    buscarEstudianteInput.placeholder = "Buscar por email...";
  }
}

tipoBusquedaEstudiante.addEventListener("change", function () {
  buscarEstudianteInput.value = "";

  actualizarPlaceholderBusqueda();
});

btnBuscarEstudiante.addEventListener("click", async function () {
  const tipoBusqueda = tipoBusquedaEstudiante.value;

  const valor = buscarEstudianteInput.value.trim();

  if (!valor) {
    mostrarMensaje("Ingresá un valor para buscar.", "error");
    return;
  }

  try {
    ocultarMensaje();

    let estudiante = null;

    if (tipoBusqueda === "id") {
      estudiante = await obtenerEstudiantePorId(valor);
    } else if (tipoBusqueda === "dni") {
      estudiante = await obtenerEstudiantePorDni(valor);
    } else if (tipoBusqueda === "email") {
      estudiante = await obtenerEstudiantePorEmail(valor);
    }

    if (!estudiante) {
      mostrarMensaje("No se encontró el estudiante.", "error");

      estudiantesContainer.innerHTML = "";

      return;
    }

    renderizarEstudiantes([estudiante]);
  } catch (error) {
    console.error(error);

    mostrarMensaje(error.message, "error");
  }
});

btnListarEstudiantes.addEventListener("click", async function () {
  buscarEstudianteInput.value = "";

  tipoBusquedaEstudiante.value = "id";

  actualizarPlaceholderBusqueda();

  await cargarEstudiantes();
});

actualizarPlaceholderBusqueda();

// ======================================================
// CARRERAS
// ======================================================

const formCarrera = document.getElementById("form-carrera");

const carreraForm = document.getElementById("carrera-form");

const btnNuevaCarrera = document.getElementById("btn-nueva-carrera");

const btnCancelarCarrera = document.getElementById("btn-cancelar-carrera");

let carreraEditandoId = null;

async function obtenerCarreras() {
  const response = await fetch(`${API_BASE}/carreras`);

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudieron obtener las carreras.");
  }

  return data;
}

async function obtenerCarreraPorId(id) {
  const response = await fetch(
    `${API_BASE}/carreras?id=${encodeURIComponent(id)}`,
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo obtener la carrera.");
  }

  return data;
}

async function crearCarrera(datos) {
  const response = await fetch(`${API_BASE}/carreras`, {
    method: "POST",

    headers: {
      "Content-Type": "application/json",
    },

    body: JSON.stringify(datos),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo crear la carrera.");
  }

  return data;
}

async function actualizarCarrera(id, datos) {
  const response = await fetch(
    `${API_BASE}/carreras?id=${encodeURIComponent(id)}`,
    {
      method: "PUT",

      headers: {
        "Content-Type": "application/json",
      },

      body: JSON.stringify(datos),
    },
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo actualizar la carrera.");
  }

  return data;
}

async function eliminarCarrera(id) {
  const response = await fetch(
    `${API_BASE}/carreras?id=${encodeURIComponent(id)}`,
    {
      method: "DELETE",
    },
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo eliminar la carrera.");
  }

  return data;
}

function renderizarCarreras(carreras) {
  if (!carreras || carreras.length === 0) {
    carrerasContainer.innerHTML = "<p>No hay carreras registradas.</p>";

    return;
  }

  let html = `
    <table class="admin-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Nombre</th>
          <th>Código</th>
          <th>Acciones</th>
        </tr>
      </thead>

      <tbody>
  `;

  carreras.forEach((carrera) => {
    html += `
      <tr>
        <td>${carrera.id}</td>
        <td>${carrera.nombre}</td>
        <td>${carrera.codigo}</td>

        <td>
          <button
            type="button"
            class="btn-editar-carrera"
            data-id="${carrera.id}"
          >
            Editar
          </button>

          <button
            type="button"
            class="btn-eliminar-carrera"
            data-id="${carrera.id}"
          >
            Eliminar
          </button>
        </td>
      </tr>
    `;
  });

  html += `
      </tbody>
    </table>
  `;

  carrerasContainer.innerHTML = html;
}

async function cargarCarreras() {
  try {
    const carreras = await obtenerCarreras();

    renderizarCarreras(carreras);
  } catch (error) {
    console.error(error);

    mostrarMensaje(error.message, "error");
  }
}

function mostrarFormularioCarrera(carrera = null) {
  formCarrera.classList.remove("hidden");

  if (!carrera) {
    carreraEditandoId = null;

    carreraForm.reset();

    formCarrera.querySelector("h3").textContent = "Nueva carrera";

    return;
  }

  carreraEditandoId = carrera.id;

  formCarrera.querySelector("h3").textContent = "Editar carrera";

  document.getElementById("carrera-nombre").value = carrera.nombre || "";

  document.getElementById("carrera-codigo").value = carrera.codigo || "";
}

function ocultarFormularioCarrera() {
  formCarrera.classList.add("hidden");

  carreraEditandoId = null;

  carreraForm.reset();

  formCarrera.querySelector("h3").textContent = "Nueva carrera";
}

btnNuevaCarrera.addEventListener("click", () => {
  mostrarFormularioCarrera();
});

btnCancelarCarrera.addEventListener("click", () => {
  ocultarFormularioCarrera();
});

carreraForm.addEventListener("submit", async function (event) {
  event.preventDefault();

  try {
    ocultarMensaje();

    const datos = {
      nombre: document.getElementById("carrera-nombre").value.trim(),

      codigo: document.getElementById("carrera-codigo").value.trim(),
    };

    if (!datos.nombre) {
      throw new Error("El nombre de la carrera es obligatorio.");
    }

    if (!datos.codigo) {
      throw new Error("El código de la carrera es obligatorio.");
    }

    if (carreraEditandoId) {
      await actualizarCarrera(carreraEditandoId, datos);

      mostrarMensaje("Carrera actualizada correctamente.", "success");
    } else {
      await crearCarrera(datos);

      mostrarMensaje("Carrera creada correctamente.", "success");
    }

    ocultarFormularioCarrera();

    await cargarCarreras();

    await refrescarDependencias();
  } catch (error) {
    console.error(error);

    mostrarMensaje(error.message, "error");
  }
});

carrerasContainer.addEventListener("click", async function (event) {
  const btnEditar = event.target.closest(".btn-editar-carrera");

  const btnEliminar = event.target.closest(".btn-eliminar-carrera");

  if (btnEditar) {
    const id = btnEditar.dataset.id;

    try {
      const carrera = await obtenerCarreraPorId(id);

      mostrarFormularioCarrera(carrera);

      window.scrollTo({
        top: 0,
        behavior: "smooth",
      });
    } catch (error) {
      console.error(error);

      mostrarMensaje(error.message, "error");
    }

    return;
  }

  if (btnEliminar) {
    const id = btnEliminar.dataset.id;

    const confirmar = confirm("¿Estás seguro de eliminar esta carrera?");

    if (!confirmar) {
      return;
    }

    try {
      await eliminarCarrera(id);

      mostrarMensaje("Carrera eliminada correctamente.", "success");

      await cargarCarreras();

      await refrescarDependencias();
    } catch (error) {
      console.error(error);

      mostrarMensaje(error.message, "error");
    }
  }
});

// ======================================================
// INSCRIPCIONES
// ======================================================

async function obtenerInscripciones() {
  const response = await fetch(`${API_BASE}/inscripciones`);

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudieron obtener las inscripciones.");
  }

  return data;
}

async function obtenerInscripcionPorId(id) {
  const response = await fetch(
    `${API_BASE}/inscripciones?id=${encodeURIComponent(id)}`,
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo obtener la inscripción.");
  }

  return data;
}

async function crearInscripcionAdmin(datos) {
  const response = await fetch(`${API_BASE}/inscripciones`, {
    method: "POST",

    headers: {
      "Content-Type": "application/json",
    },

    body: JSON.stringify(datos),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo crear la inscripción.");
  }

  return data;
}

async function eliminarInscripcion(id) {
  const response = await fetch(
    `${API_BASE}/inscripciones?id=${encodeURIComponent(id)}`,
    {
      method: "DELETE",
    },
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || "No se pudo eliminar la inscripción.");
  }

  return data;
}

function renderizarInscripciones(inscripciones) {
  if (!inscripciones || inscripciones.length === 0) {
    inscripcionesContainer.innerHTML =
      '<p class="empty-message">No hay inscripciones registradas.</p>';

    return;
  }

  let html = `
    <table class="admin-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Estudiante</th>
          <th>Carrera</th>
          <th>Código</th>
          <th>Fecha</th>
          <th>Acciones</th>
        </tr>
      </thead>

      <tbody>
  `;

  inscripciones.forEach((inscripcion) => {
    const estudiante = inscripcion.estudiante
      ? `${inscripcion.estudiante.nombre} ${inscripcion.estudiante.apellido}`
      : "-";

    const estudianteId = inscripcion.estudiante
      ? inscripcion.estudiante.id
      : "-";

    const carrera = inscripcion.carrera ? inscripcion.carrera.nombre : "-";

    const codigo = inscripcion.carrera ? inscripcion.carrera.codigo : "-";

    const fecha = inscripcion.fecha_inscripcion
      ? new Date(
          inscripcion.fecha_inscripcion.replace(" ", "T"),
        ).toLocaleString("es-AR")
      : "-";

    html += `
      <tr>
        <td>${inscripcion.id}</td>

        <td>
          ${estudiante}
          <small class="table-secondary">
            ID: ${estudianteId}
          </small>
        </td>

        <td>${carrera}</td>

        <td>${codigo}</td>

        <td>${fecha}</td>

        <td>
          <button
            type="button"
            class="btn-eliminar-inscripcion"
            data-id="${inscripcion.id}"
          >
            Eliminar
          </button>
        </td>
      </tr>
    `;
  });

  html += `
      </tbody>
    </table>
  `;

  inscripcionesContainer.innerHTML = html;
}

async function cargarInscripciones() {
  try {
    const inscripciones = await obtenerInscripciones();

    renderizarInscripciones(inscripciones);
  } catch (error) {
    console.error(error);

    mostrarMensaje(error.message, "error");
  }
}

async function refrescarDependencias() {
  try {
    await cargarInscripciones();

    if (formInscripcion && !formInscripcion.classList.contains("hidden")) {
      await cargarOpcionesInscripcion();
    }
  } catch (error) {
    console.error(error);
  }
}

inscripcionesContainer.addEventListener("click", async function (event) {
  const btnEliminar = event.target.closest(".btn-eliminar-inscripcion");

  if (!btnEliminar) {
    return;
  }

  const id = btnEliminar.dataset.id;

  const confirmar = confirm("¿Estás seguro de eliminar esta inscripción?");

  if (!confirmar) {
    return;
  }

  try {
    await eliminarInscripcion(id);

    mostrarMensaje("Inscripción eliminada correctamente.", "success");

    await cargarInscripciones();
  } catch (error) {
    console.error(error);

    mostrarMensaje(error.message, "error");
  }
});

// ======================================================
// FORMULARIO DE INSCRIPCIÓN
// ======================================================

const formInscripcion = document.getElementById("form-inscripcion");

const inscripcionForm = document.getElementById("inscripcion-form");

const btnNuevaInscripcion = document.getElementById("btn-nueva-inscripcion");

const btnCancelarInscripcion = document.getElementById(
  "btn-cancelar-inscripcion",
);

const selectEstudianteInscripcion = document.getElementById(
  "inscripcion-estudiante",
);

const selectCarreraInscripcion = document.getElementById(
  "inscripcion-carrera",
);

async function cargarOpcionesInscripcion() {
  const estudiantes = await obtenerEstudiantes();

  const carreras = await obtenerCarreras();

  selectEstudianteInscripcion.innerHTML = "";
  selectCarreraInscripcion.innerHTML = "";

  const opcionEstudiante = document.createElement("option");
  opcionEstudiante.value = "";
  opcionEstudiante.textContent = "Seleccioná un estudiante...";
  selectEstudianteInscripcion.appendChild(opcionEstudiante);

  const opcionCarrera = document.createElement("option");
  opcionCarrera.value = "";
  opcionCarrera.textContent = "Seleccioná una carrera...";
  selectCarreraInscripcion.appendChild(opcionCarrera);

  estudiantes.forEach((estudiante) => {
    const option = document.createElement("option");
    option.value = estudiante.id;
    option.textContent = `${estudiante.nombre} ${estudiante.apellido} (${estudiante.dni})`;
    selectEstudianteInscripcion.appendChild(option);
  });

  carreras.forEach((carrera) => {
    const option = document.createElement("option");
    option.value = carrera.id;
    option.textContent = `${carrera.nombre} (${carrera.codigo})`;
    selectCarreraInscripcion.appendChild(option);
  });
}

function mostrarFormularioInscripcion() {
  formInscripcion.classList.remove("hidden");
}

function ocultarFormularioInscripcion() {
  formInscripcion.classList.add("hidden");
  inscripcionForm.reset();
}

btnNuevaInscripcion.addEventListener("click", async function () {
  try {
    ocultarMensaje();
    await cargarOpcionesInscripcion();
    mostrarFormularioInscripcion();
  } catch (error) {
    console.error(error);
    mostrarMensaje(error.message, "error");
  }
});

btnCancelarInscripcion.addEventListener("click", function () {
  ocultarFormularioInscripcion();
});

inscripcionForm.addEventListener("submit", async function (event) {
  event.preventDefault();

  try {
    ocultarMensaje();

    const datos = {
      estudiante_id: selectEstudianteInscripcion.value,
      carrera_id: selectCarreraInscripcion.value,
    };

    if (!datos.estudiante_id) {
      throw new Error("Seleccioná un estudiante.");
    }

    if (!datos.carrera_id) {
      throw new Error("Seleccioná una carrera.");
    }

    await crearInscripcionAdmin(datos);

    mostrarMensaje("Inscripción creada correctamente.", "success");

    ocultarFormularioInscripcion();

    await cargarInscripciones();
  } catch (error) {
    console.error(error);
    mostrarMensaje(error.message, "error");
  }
});

// ======================================================
// INICIO
// ======================================================

cargarEstudiantes();

cargarCarreras();

cargarInscripciones();
