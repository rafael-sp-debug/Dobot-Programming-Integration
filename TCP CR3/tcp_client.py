import socket

# Direccion IP del controlador del robot 
ROBOT_IP = "192.168.1.6"

# Puerto en el que se crea el servidor.
# Debe coincidir con el puerto definido en el script Lua.
ROBOT_PORT = 6001

def recv_line(sock: socket.socket) -> str:
    """
    Recibe datos desde el socket hasta encontrar un salto de linea.

    El robot envia respuestas terminadas en '\\n', por ejemplo:
        PONG\\n
        DONE:OPEN\\n
        BYE\\n

    Esta funcion acumula los fragmentos recibidos hasta completar una linea.
    Si el socket se cierra antes de recibir el salto de linea, se devuelve
    lo que se haya recibido hasta ese momento.
    """
    data = b""

    # Continuar leyendo mientras no aparezca el caracter de fin de linea.
    while not data.endswith(b"\n"):
        chunk = sock.recv(1024)

        # Si recv() devuelve bytes vacios, significa que la conexion se cerro.
        if not chunk:
            break

        # Acumular el fragmento recibido.
        data += chunk

    # Convertir los bytes a texto UTF-8.
    # errors="replace" evita que el programa falle si llega algun byte raro.
    return data.decode("utf-8", errors="replace")

def main() -> None:
    """
    Funcion principal del cliente TCP.

    Flujo general:
    1. Crear un socket TCP.
    2. Conectarse al servidor TCP del robot.
    3. Recibir el mensaje inicial del robot.
    4. Mostrar al usuario la lista de comandos disponibles.
    5. Enviar comandos al robot y mostrar la respuesta.
    6. Terminar cuando el usuario mande QUIT o ocurra un timeout.
    """
    print("Conectando al robot...")

    # Crear un socket IPv4 orientado a conexion (TCP).
    # El bloque 'with' garantiza que el socket se cierre automaticamente
    # al salir, incluso si ocurre un error.
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        # Definir un timeout de 10 segundos para operaciones bloqueantes.
        # Esto evita que el programa quede esperando indefinidamente.
        sock.settimeout(30)

        # Establecer la conexion TCP con el robot.
        # Si la IP o el puerto no son correctos, aqui ocurrirá una excepcion.
        sock.connect((ROBOT_IP, ROBOT_PORT))
        print("Conectado")

        # Intentar recibir el mensaje inicial enviado por el robot.
        # Normalmente el robot responde algo como:
        # DOBOT_TCP_SERVER_READY
        try:
            msg = recv_line(sock)
            if msg:
                print("Robot:", msg.strip())
        except socket.timeout:
            # Si no llega mensaje inicial en el tiempo configurado,
            # el programa continua, pero se informa al usuario.
            print("No llego mensaje inicial del robot")

        # Mostrar la lista de comandos que el robot entiende.
        print("Comandos disponibles:")
        print("PING, HOME, SEGURIDAD, ABRIR, CERRAR, SALUDO, DEMO, CAPY, SALIR")

        # ciclo principal de envio de comandos al robot.
        while True:
            # Leer el comando desde teclado.
            # strip() elimina espacios laterales.
            # upper() fuerza el uso de mayusculas para homologar el formato.
            cmd = input("Ingresa comando: ").strip().upper()

            # Si el usuario no escribio nada, pedir nuevamente.
            if not cmd:
                continue

            # Enviar el comando al robot.
            # Se agrega '\\n' al final porque el script del robot espera
            # comandos terminados en salto de linea.
            sock.sendall((cmd + "\n").encode("utf-8"))

            # Esperar la respuesta del robot para el comando enviado.
            try:
                response = recv_line(sock)
                print("Robot:", response.strip())
            except socket.timeout:
                # Si el robot no responde en el tiempo esperado, se asume
                # que hubo un problema de comunicacion o de ejecucion.
                print("Timeout esperando respuesta del robot")
                break

            # Si el comando fue QUIT, salir.
            if cmd == "SALIR":
                break


# Punto de entrada del programa.
if __name__ == "__main__":
    main()
