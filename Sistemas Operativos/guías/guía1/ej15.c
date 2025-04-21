#include <stdio.h>    // printf()
#include <stdlib.h>   // exit()
#include <unistd.h>   // fork() pipe() execlp() dup2() close()
#include <sys/wait.h> // wait()

// Constants 0 and 1 for READ and WRITE
enum { READ, WRITE };

// Debe ejecutar "ls -al"
void ejecutar_hijo_1(int pipe_fd[]) {
    close(pipe_fd[READ]); // Para el EOF
    dup2(pipe_fd[WRITE], STDOUT_FILENO);
    execlp("ls", "ls", "-al", NULL);


}

// Debe ejecutar "wc -l"
void ejecutar_hijo_2(int pipe_fd[]) {
    close(pipe_fd[WRITE]);
    dup2(pipe_fd[READ], STDIN_FILENO);
    execlp("wc", "wc", "-l", NULL);
}

int main(int argc, char const* argv[]) {
  int pipe_fd[2];
  pipe(pipe_fd);
  if (!fork()) ejecutar_hijo_1(pipe_fd);
  if (!fork()) ejecutar_hijo_2(pipe_fd);

  close(pipe_fd[READ]);
  close(pipe_fd[WRITE]);

  wait(NULL);
  wait(NULL);


  return 0;
}
