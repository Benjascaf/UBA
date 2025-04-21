#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
void exec(char *path) {
    execl(path, (char *) NULL);
}

int main() {

    exec("./ej5");

    return 0;
}