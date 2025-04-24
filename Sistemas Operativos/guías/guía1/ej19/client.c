#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>

int main() {
    int server_socket;
    struct sockaddr_un server_addr;
    int connection_result;

    server_socket = socket(AF_UNIX, SOCK_STREAM, 0);

    server_addr.sun_family = AF_UNIX;
    strcpy(server_addr.sun_path, "unix_socket");

    connection_result = connect(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr));

    if (connection_result == -1) {
        perror("Error:");
        exit(1);
    }

    int c = 0;
    while (c != 3)
    {
        /* code */
        read(server_socket, &c, sizeof(c));
        printf("cliente lee %d del servidor\n", c);
        c++;
        printf("Cliente escribe %d al servidor \n", c);
        write(server_socket, &c, sizeof(c));
    }
    close(server_socket);
    exit(0);
}