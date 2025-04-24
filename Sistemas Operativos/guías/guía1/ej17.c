#include <stdio.h>    // printf()
#include <stdlib.h>   // exit()
#include <unistd.h>   // fork() pipe() execlp() dup2() close()
#include <sys/wait.h> // wait()
#include <signal.h>


enum {READ, WRITE};
char termino = 0;

int dameNumero(__pid_t pid) {
    return pid;
}

int calcularNumero(int numero){
    // Para simular cómputo costoso, noc si stá bien
    sleep(2);
    return numero * 2;
}

void informarResultado(int numero, int resultado, __pid_t pid) {
    printf("El número %d calculado por proceso %d dio como resultado %d\n", numero, pid, resultado);
}

void sigchld_handler(int signal) {
    termino = 1;

}

void ejecutarHijo (int i, int pipes[][2], int N) {
    // ...
    // Mis pipes de lectura y escritura son i y N + i, respectivamente
    int pipe_nieto[2];
    pipe(pipe_nieto); 
    signal(SIGCHLD, sigchld_handler);
    int numero = 0;
    read(pipes[i][READ], &numero, sizeof(numero));
    // printf("nieto lee %d", numero);

    if (fork() == 0) {
        int resultado = calcularNumero(numero);
        write(pipe_nieto[WRITE], &resultado, sizeof(resultado));
        printf("Termina el nieto\n");
        exit(EXIT_SUCCESS);
    } else {
        // Mientras que el nieto no haya terminado simlpemente escribo el valor que me pasa padre
        int no_termino = 0;
        while (!termino) {
            read(pipes[i][READ], &no_termino, sizeof(termino));
            write(pipes[N + i][WRITE], &no_termino, sizeof(termino));
        }
        // Nieto termino
        read(pipes[i][READ], &no_termino, sizeof(termino));
        write(pipes[N + i][WRITE], &termino, sizeof(termino));
        int resultado = 0;
        // Leo valor calculado
        read(pipe_nieto[READ], &resultado, sizeof(resultado));
        printf("Hijo lee valor %d calculado por nieto con numero %d\n", resultado, numero);
        // Escribo y salgo
        write(pipes[N+i][WRITE], &numero, sizeof(numero));
        write(pipes[N+i][WRITE], &resultado, sizeof(resultado));
        exit(EXIT_SUCCESS);

    }

}

int main(int argc, char* argv[]){
    if (argc< 2) {
        printf ("Debe ejecutar con la cantidad de hijos como parametro\n");
        return 0; 
    }
    int N = atoi(argv[1]);
    int pipes[N*2][2];
    __pid_t pids[N];
    for (int i=0; i< N*2; i++){
        pipe(pipes[i]); }
        for (int i=0; i< N; i++) {
        int pid = fork () ;
        if (pid==0) {
            ejecutarHijo(i,pipes, N);
            return 0;
        } else {
            pids[i] = pid;
            int numero = dameNumero(pid) ;
            printf("Escribiendo numero %d\n", numero);
            write(pipes[i][1], &numero, sizeof(numero)); 
    } 

    }
    int cantidadTerminados = 0;
    char hijoTermino[N];
    for (size_t i  = 0; i < N; i++) {
        hijoTermino[i] = 0;
    }
    while (cantidadTerminados < N) {
        for ( int i=0; i< N; i++) {
            if (hijoTermino[i]) {
                continue; 
            }
            char termino = 0;
            write(pipes[i][1], &termino, sizeof(termino));
            read(pipes[N+i][0], &termino, sizeof(termino));
            if (termino) {
                int numero = 0;
                int resultado = 0;
                read(pipes[N+i][0], &numero, sizeof(numero));
                printf("%d dio como numero %d", pids[i], numero);
                read(pipes[N+i][0], &resultado, sizeof(resultado));
                informarResultado(numero, resultado, pids[i]);
                hijoTermino[i] = 1;
                cantidadTerminados++; 
            } 
        } 
    }
    wait(NULL);
    return 0;   
}