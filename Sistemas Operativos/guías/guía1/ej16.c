#include <stdio.h>    // printf()
#include <stdlib.h>   // exit()
#include <unistd.h>   // fork() pipe() execlp() dup2() close()
#include <sys/wait.h> // wait()

// Constants 0 and 1 for READ and WRITE
enum { READ, WRITE };

// para distinguir los pipes de escritura de cada uno
enum {PADRE, HIJO_1, HIJO_2};
int pipes_fd[3][2];

void ejecutar_hijo_1() {
  int value = 0;
  close(pipes_fd[PADRE][WRITE]);
  close(pipes_fd[HIJO_1][READ]);
  close(pipes_fd[HIJO_2][READ]);
  close(pipes_fd[HIJO_2][WRITE]);


    

  while (value != 50) {
    read(pipes_fd[PADRE][READ], &value, sizeof(int));
    if (value != 50) value += 1;
    printf("Hijo 1 recibión %d y escribe %d\n", value - 1, value);
    write(pipes_fd[HIJO_1][WRITE], &value, sizeof(int));
  }
  exit(EXIT_SUCCESS);
}

void ejecutar_hijo_2() {
  int value = 0;
  close(pipes_fd[PADRE][WRITE]);
  close(pipes_fd[PADRE][READ]);
  close(pipes_fd[HIJO_1][WRITE]);
  close(pipes_fd[HIJO_2][READ]);

  while (value != 50) {
    read(pipes_fd[HIJO_1][READ], &value, sizeof(int));
    if (value == 50) {
      write(pipes_fd[HIJO_2][WRITE], &value, sizeof(int));
    } else {
      printf("Hijo 2 recibión %d y escribe %d\n", value, value + 1);
      value += 1;
      write(pipes_fd[HIJO_2][WRITE], &value, sizeof(int));
    }
    
    
  }
  exit(EXIT_SUCCESS);
}
int main(int argc, char const* argv[]) {
  // Completar...
  printf("arranco\n");
  for (int i =0; i < 3; i++) {
    pipe(pipes_fd[i]);
  }
  if (!fork()) ejecutar_hijo_1();
  if (!fork()) ejecutar_hijo_2();
  int value = 1;
  write(pipes_fd[PADRE][WRITE], &value, sizeof(int));
  while (value != 50) {
    read(pipes_fd[HIJO_2][READ], &value, sizeof(int));
    if (value != 50) value+=1;
    printf("Padre recibió %d y escribe %d\n", value - 1, value);
    
    write(pipes_fd[PADRE][WRITE], &value, sizeof(int));
  }

  wait(NULL);
  wait(NULL);


  return 0;
}
