#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>
#include <signal.h>
#include <string.h>

int ping_count = 0;

void ping() {
    printf("%d\n", getpid());
    ping_count++;
}


int main() {
    
    __pid_t pid = fork();
    // Flag para determinar si ya estamos
    int finished = 0;
    char answer[100] = {0};
    signal(SIGALRM, ping);

    if(pid) {
        // Soy padre
        while (!finished) {
            pause();
            if (ping_count == 2) {
                printf("Desea continuar?");
                scanf("%s", answer);
                if (strcmp(answer, "no") == 0) {
                    kill(pid, SIGKILL);
                    wait(NULL);
                    return 0;
                }
                ping_count = 0;
            }
            kill(pid, SIGALRM);
        }
    } else {
        while (1) {
            kill(getppid(), SIGALRM); 
            pause();
              
        }

    }
}




int main() {
    // Asumo que tiene todas las syscalls usadas en la seción anterior de la guía (?
    __pid_t pid = fork();
    __pid_t parent_pid = get_current_pid();
    if (pid) {
        // En un principio del hijo_2 para que lo reciva
        __pid_t pid2 = fork();
        if (pid) {
            // Información para el juego
            bsend(pid, pid2);
            bsend(pid2, pid);
            // Sincronización
            breceive(pid);
            breceive(pid2);
            // Arranca el juego
            bsend(pid, 0);
            while (1) {
                bsend(pid, breceive(pid) + 1);

            }
        } else {
            __pid_t brother_pid = breceive(parent_pid);
            while(1) {
                bsend(parent_pid, breceive(brother_pid) + 1);
            }
        }
    } else {
        // Hijo 1 recive pid del hermano
        
        __pid_t brother_pid = breceive(parent_pid);

        while(1) {
            bsend(brother_pid, breceive(parent_pid) + 1);
        }
    }

}