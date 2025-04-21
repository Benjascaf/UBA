#Soluciones
## 1
Para realizar un cambio de contexto, el sistema debe guardar el contexto del proceso que está ejecutandose en la CPU. Pare ello debemos:
- Guardar los registros
- Guardar el IP
- Guardar el estado
- blabala


## 2
```c
// Primero, nos guardamos los registros
pcb_0.r0 = R0
.
.
.
pcb_0.r15 = R0
// Guardamos el estado, como el enunciado aclara que el cambio de contexto está ocurriendo pq se termino el quantum del proceso, tenemos que necesariamente se encontraba en estado Corriendo, por lo que ahora va a pasar a listo
pcb_0.STAT = KE_READY
// Obtenemos el tiempo que ocupo en el procesador
pcb_0.CPU_TIME = ke_current_user_time()
// Reseteamos, no entiendo porque esto hace falta, o estoy mal o tal vez la implementación para cargar el tiempo simplemente suma al valor del cornómetro?
ke_reset_current_user_time()
// El PID es el mismo, solo queda cargar el nuevo proceso y retornar control al caller. 
// Supongo que está es una función mágica que me hace todo por sí misma , pero debería confirmar

// No, me falta cargar el PCB a mano
set_current_process(pcb_1.PID)
ret()

```

## 3
Una llamada a función puede (y de hecho probablemente vaya) a involucrar una syscall, pero en general nos referimos a simples instrucciones que va a deber ejecutar la CPU, y que involucran uso del stack para poder volver al caller. Una syscall en cambio, siempre involucra una interrupción al sistema, por lo que la misma es más costosa debido al overhead y el cambio de contexto necesario para ejecutarla (Esto está bien así?) (FALTA SALTO DE PRIVILEGIO)

## 4
### a
Falta una flecha desde new a ready, running a ready, running a terminated, ready a running, running a blocked, blocked a ready.
### b
- new a ready: El nuevo proceso terminó de ser creado y esta listo para ser ejecutado
- running a ready: El proceso estaba ejecutando, pero una interrupción causada por el scheduler lo sacó
- running a terminated: El proceso terminó de ejecutar y llamó a exit()
- ready a running: El scheduler le otorgó recursos de CPU al proceso
- running a blocked: El proceso está esperando que alguna operación de E/S o algún otro evente costoso termine
- Blocked a ready: El evento que estaba esperando terminó

## 8
Los resultados parecerían no ser consistentes, pues la variable dato permanece en 0 para el padre, sin embargo, esto se da porque los procesos padre e hijos **no** comparten memoria, y lo que hace fork es una llamada a la syscall clone(), por lo que todo el espacio de memoria asociado al proceso es "clonado" (Esto no es totalmente cierto, ya que usando copy-on-write el SO puede optimizar esta copia y no tener que innecesariamente copiar por completo el heap)

## 11
### a
```c
int main() {
    // Asumo que tiene todas las syscalls usadas en la seción anterior de la guía (?
    __pid_t pid = fork();

    if (pid) {
        bsend(pid, 0);
        while (1) {
            bsend(pid, breceive(pid) + 1);

        }
    } else {
        // Asumo que esto lo puedo hacer por lo que dije en el primer comentrio
        // Si no pudiera, puedo gaurdarme el pid del padre antes del fork aprovechando que la memoria se va a copiar para el hijo

        __pid_t parent_pid = getppid();
        while(1) {
            bsend(parent_pid, breceive(parent_pid) + 1);
        }
    }

}
```

### b 
```c 
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
```

## 12 
### a 
Si no me equivoco, la idea es que nos demos cuenta que no es posible q se realicen ambos a la vez pq las funciones de ipc son bloqueantes entonces nunca van a estar completamente sincronizadas
### b 
Podría ejecutar el proceso derecha hasta que este en estado bloqueado, hacer lo mismo despues con proceso izquierda y despues ejecutarlos en paralelo?
