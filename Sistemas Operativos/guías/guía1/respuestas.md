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
set_current_process(pcb_1.PID)
ret()

```

## 3
Una llamada a función puede (y de hecho probablemente vaya) a involucrar una syscall, pero en general nos referimos a simples instrucciones que va a deber ejecutar la CPU, y que involucran uso del stack para poder volver al callee. Una syscall en cambio, siempre involucra una interrupción al sistema, por lo que la misma es más costosa debido al overhead y el cambio de contexto necesario para ejecutarla (Esto está bien así?)

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