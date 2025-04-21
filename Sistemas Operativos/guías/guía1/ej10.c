#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/wait.h>
#include <signal.h>
#include <string.h>

int main() {

    if (fork() == 0) {
        printf("Soy Julieta\n");
        sleep(1);
        if (fork()) {

        } else {
            printf("Soy Jennifer\n");
            sleep(1);
        }
    } else {
        printf("soy Juan\n");
        sleep(1);
        wait(NULL);
        if (fork()) {

        } else {
            printf("Soy Jorge\n");
            sleep(1);
        }
    }

    sleep(1);
    return 0;
}
