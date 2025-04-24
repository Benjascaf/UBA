#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

int main() {

    int bindresult;
    
    struct sockaddr_un server_addr;
    struct sockaddr_un client_addr;
    server_addr.sun_family = AF_UNIX;
    strcpy(server_addr.sun_path, "unix_socket");
    unlink(server_addr.sun_path);
    int slen = sizeof(server_addr);

    printf("Creando socket");

    int server_socket = socket(AF_UNIX, SOCK_STREAM, 0);

    bindresult =  bind(server_socket, (struct sockaddr *) &server_addr, slen);

    if (bindresult != 0) {
        perror("No se bindeo bien");
        exit(EXIT_FAILURE);
    }
    listen(server_socket, 5);


    int clen = sizeof(client_addr);
    int c = 0;
    int client_socket = accept(server_socket, (struct sockaddr *) &client_addr, &clen);
    write(client_socket, &c, sizeof(c));
    while (read(client_socket, &c, sizeof(c)), c != 3) {
        printf("Servidor lee %d del cliente\n", c);
        c++;
        printf("Servidor escribe %d al cliente\n", c);
        write(client_socket, &c, sizeof(c));
    }
    printf("Servidor cierra conexión\n");
    close(client_socket);
    
}