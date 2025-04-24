#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

int main() {
    int server_socket = socket(AF_UNIX, SOCK_STREAM, 0);
    struct sockaddr_un server_addr;
    struct sockaddr_un client_addr;
    server_addr.sun_family = AF_UNIX;
    strcpy(server_addr.sun_path, "unix_socket");
    unlink(server_addr.sun_path);
    int slen = sizeof(server_addr);

    bind(server_socket, (struct sockadr *) &sockaddr_un, slen);

    listen(server_socket, 5);

    int clen = sizeof(client_addr);
    int client_socket = accept(server_socket, (struct sockaddr *) &client_addr, &clen);
    printf("Servidor lee %d del cleinte\n", read(client_socket, &clen, sizeof(clen)));

    close(client_socket);
    
}