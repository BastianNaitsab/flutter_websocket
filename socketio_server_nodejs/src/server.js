const { Server } = require("socket.io");  // Importa Socket.IO

// io representa la instancia de Socket.IO que maneja las conexiones del servidor
// socket representa la conexión individual entre el servidor y un cliente. Cada cliente que se conecta tiene su propio objeto socket

// Para escuchar se usa socket.on
// Para madar se usa socket.emit

// Crea una instancia de Socket.IO sin un servidor HTTP explícito en el puerto 3000
const io = new Server(3000, {
    cors: {
        origin: ["http://localhost:3000", "http://mi-cliente.com"], // Permite solo conexiones desde estos origenes
        methods: ["GET", "POST"],
    },
});

// Maneja la conexión en el servidor
io.on("connection", (socket) => {
    console.log(`Un cliente se ha conectado con id: ${socket.id}`);

    // Enviar mensaje al cliente conectado
    socket.emit("mensaje", "¡Hola, bienvenido al servidor!");

    // Enviar mensaje a todos los clientes conectados
    io.emit("mensaje", "¡Hola a todos los clientes conectados");

    // Enviar mensaje a todos los clientes excepto el emisor
    socket.broadcast.emit("mensaje", "¡Hola a todos los clientes conectados");

    // Manejo de la desconexión del cliente
    socket.on("disconnect", () => {
        console.log(`El cliente ${socket.id} se ha desconectado`);
    });

    // Manejo de error en el socket
    socket.on("error", (err) => {
        console.log("Error en el socket:", err);
    });

    // Escuchar evento 'mensaje' del cliente, (este es un evento personalizado)
    socket.on("mensaje", (data) => {
        console.log("Mensaje recibido:", data);

        // Enviar el mensaje a todos los demás clientes, excepto al emisor
        socket.emit("mensaje", `${data}`);
    });

    // Unirse a una sala, (este es un evento personalizado)
    socket.on("unirseSala", (sala) => {
        socket.join(sala);  // El cliente se une a la sala especificada
        console.log(`El cliente ${socket.id} se ha unido a la sala: ${sala}`);
    });

    // Para salir de una sala
    // socket.leave('sala1');

    // Enviar mensaje a todos los miembros de una sala, (este es un evento personalizado)
    socket.on("mensajeSala", (sala, mensaje) => {
        io.to(sala).emit("mensaje", `Mensaje en la sala ${sala}: ${mensaje}`);
    });

});

// Manejo de error en el server
io.on("error", (err) => {
    console.error("Error en el servidor Socket.IO:", err);
});

// Crear namespace '/chat'
const chatNamespace = io.of("/chat");

chatNamespace.on("connection", (socket) => {
    console.log("Un cliente se ha conectado al namespace /chat");

    // Enviar un mensaje a todos los clientes en el namespace '/chat'
    socket.emit("mensaje", "¡Bienvenido al chat!");

    socket.on("mensaje", (data) => {
        console.log("Mensaje recibido en /chat:", data);
        socket.emit("mensaje", `Mensaje en /chat: ${data}`);
    });
});

console.log("Servidor Socket.IO escuchando en el puerto 3000...");
