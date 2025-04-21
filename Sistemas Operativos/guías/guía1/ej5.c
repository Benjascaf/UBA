#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>


int main() {
    int status;
    __pid_t pid = fork();
    if (pid) {
        // Soy Abraham
        printf("Soy Abraham\n");
        wait(&status);
        printf("Y Homero ya terminó\n");
    } else {
        // Soy Homero
        pid = fork();
        if (pid) {
            // Sigo siendo Homero
            waitpid(pid, &status, 0);
            printf("Soy, Homero, Y Maggie ya terminó\n");
            pid = fork();
            if(pid) {
                waitpid(pid, &status, 0);
                printf("Soy Homero, y Bart ya terminó\n");
            } else {
                printf("Soy Bart\n");
            }
        } else {
            printf("Soy Maggie\n");
        }
    }


    return 0;
}
