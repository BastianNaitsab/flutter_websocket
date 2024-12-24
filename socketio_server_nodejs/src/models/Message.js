class Message {
    constructor(user, message) {
        this.user = user;
        this.message = message;
    }

    // Convertir el objeto Message a un mapa
    toMap() {
        return {
            user: this.user,
            message: this.message
        };
    }

    // Convertir el objeto Message a JSON (cadena de texto)
    toJson() {
        return JSON.stringify(this.toMap()); // Serializar el mapa a JSON
    }

    // Crear un Message a partir de un mapa
    static fromMap(map) {
        return new Message(map.user, map.message);
    }

    // Crear un Message a partir de JSON
    static fromJson(source) {
        return Message.fromMap(JSON.parse(source)); // Deserializar el JSON
    }
}

module.exports = Message;