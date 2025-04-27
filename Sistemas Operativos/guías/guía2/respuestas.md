
Acá hay un [recurso](https://process-scheduling-solver.boonsuen.com) copado para hacer diagramas de Gantt y corroborar que estén bien pensados 
## Ej 1
### a
Las ráfagas de E/S son las q están en puntos y el resto son de CPU
### b

Este punto si no equivoco la idea es llamara la atención al hecho de que, en promedio, parecería ser el caso que las ráfagas de E/S toman más tiempo

## Ej 2

Como tenemos que $P_1$ es frecuentemente bloqueado, mientras que no tenemos información del tiempo de ráfaga de $P_0$ ni de $P_2$, podríamos usar un scheduler con dos colas de prioridad de manera que en la de prioridad más alta siempre vaya $P_1$, que sabemos va a ser frecuentemente bloqueado, y en la otra vayan los otras dos procesos, en la cual utilizamos RR

Un posible problema de este scheduler es que, en el caso de que $P_1$ tenga cortas ráfagas de lectura en la red, podría llegar a causar starvation en los otros dos procesos

Otro posible problema sería que tal vez P_0 tenga ráfagas cortas de E/S, en cuyo caso tal vez podría ser considerado un modelo con tres colas de prioridad

## Ej 3

Tenemos que el proceso una vez que se encuentra en estado *running* no cambia de estado hasta que el mismo sea bloqueado o termine, por lo que se trata de un scheduler cooperativo, el cual solo realiza cambios de contexto cuando un proceso se bloquea para esperar algún evento, o cuando el mismo termina

  

## Ej 4 
### Round-Robin
- En este caso no debería haber problemas ya que tenemos que el uso de cada proceso de la CPU está limitado por el quantum
### Por Prioridad
- Si tenemos que varios procesos frecuentemente son agregados a las colas de mayor prioridad, podemos tener que aquellos en las colas inferiores se encuentran en starvation
### SJF
- En este caso, podría ocurrir que vayan llegando procesos que siempre tengan menor tiempo de ráfaga computado que el resto de procesos
### SRTF
- Parecido al anterior, pero esta vez podemos tener que el proceso que ya estaba siendo ejecutado sea interrumpido
### FIFO
- En este caso tenemos que el primer proceso puede tener mucho más tiempo de ejecución que el resto de procesos en la cola que vienen después, ocasionando Convoy Effect
### Colas de Multinivel
- Igual que por prioridad
### Colas de multinivel con feedback
- Si no me equivoco, en este caso tenemos que starvation es evitada al lograr que un proceso dado no se quede sin acceso a la CPU

## Ej5
### a
- En este caso, dependiendo del proceso, tenemos que damos una especie de "prioridad" al proceso en el sentido de que en una sola ronda el mismo va a tener muchos más quantum para sí a comparación del resto de procesos que sólo están una vez
### b
- La verdad que no tengo idea de este punto, estoy diciendo cualquier cosa

## Ej6
### a 
- FCFS: 
	- |  P1  |  P2  |  P3  |  P4  | P5 | 

	 0     10      11      13      14     19
- SJF:
	- |  P2  |  P4  |  P3  |  P5  | P1 | 

	  0     1          2       4        9     19
- Prioridades:
	- |  P2  |  P5  |  P1  |  P3  | P4 | 

	  0       1       6       16      18     19
- RR:
	- |  P1  |  P2  |  P3  |  P4  | P5 | P1 | P3 | P5 | P1 | P5 | P1 | P5 | P1 

	  0     1          2       3       4      5     6     7      8     9     10   11    12

	  | P5 | P1 | P1 | P1 | P1 | P1 | 

	  13    14   15    16   17   18   19
### b 
- **Waiting time:** Suma de los periodos en estado ready
- **Turnaround time:** Cuánto tiempo tarda en ejecutar (tiempo en ready + tiempo ejecutando + tiempo bloqueado)
-  FCFS: 
	- Waiting time promedio = $\frac{0 + 10 + 11 + 13 + 14}{5} = 9.6$ ($\text{nice}^{t}$)
	- Turnaround promedio = $\frac{10 + 11 + 13 + 14 + 19}{5} = 13.4$
- SJF:
	- Waiting time promedio = $\frac{0 + 1 + 2 + 4 + 9}{5} = 3.2$
	- Turnaround promedio = $\frac{19 + 1 + 4 + 2 + 9}{5} = 7$ 
- Prioridades:
	- Waiting time promedio = $\frac{6 + 0 + 16 + 18 + 1}{5} = 8.2$
	- Turnaround promedio = $\frac{16 + 1 + 18 + 19 + 6}{5} = 12$

- RR:
	- Waiting time promedio = $\frac{(0 + 4 + 2 + 1 + 1 + 1) + 1 + (2 + 3) + 3 + (4 + 2 + 1 + 1 + 1)}{5} = 5.4$
	- Turnaround promedio = **Fiaca** 9.2
### c 
 - SJF es el algoritmo que menor waiting time obtiene (lo cual tiene sentido, pues sabemos que es óptimo en cuanto a minimización del mismo)
 - SJF es el algoritmo que menor turnaround obtiene

## Ej 7 
### a 
- Waiting time promedio = $\frac{0 + (1 + 6) + 0 + 9 + 0}{5} = 3.2$
- Turnaround promedio = $\frac{3 + 13 + 4 + 14 + 2}{5} = 7.2$
### b
El scheduler parecería ser preemptive / no cooperativo, ya que tenemos que P2 por ejemplo no termina toda su ráfaga una vez que tiene acceso a los recursos de la CPU. En particular, parecería tratarse de SRTF, por como se priorizan los procesos y cómo P2 fue interrumpido

## Ej8
-  FCFS: 
	- |  P1  |  P2  |  P3  |  P4  | 

	  5      6      16      17      27    
- RR (quantum = 10):
	- |  P1  |  P2  |  P3  |  P4  | 

	  5      6      16      17      27 
- SJF:
	- |  P1  |  P2  |  P3  |  P4  | 

	  5      6      16      17      27    
- (No, esto no es un typo, son el mismo, tal vez la idea es que pensemos como un algoritmo no necesariamente es mejor que otro?)
- Waiting time promedio: 4.5
- Turnaround promedio: 10

## Ej9 
### a
- |  P1  |  P2  |  P1  |  P2  |  P3 | P4 | P3 | 

  0      5       10     13      16     21    26   27
### b
- |  P1  |  P2  |  P4  |  P3  |  

  0      8       16     21      27  
### c
- Turnaround promedio RR: $\frac{13 + 11 + 13 + 11}{4} = 12$
- Turnaround promedio STRF: $\frac{8 + 11 + 6 + 13}{4} = 9.5$
### d
En el caso que quisieramos simula multiprogramación con procesos interactivos, tener en cuenta sólo el turnaround podría ser contraproductivo al considerar que podemos llegar a situaciones donde procesos de pocas ráfagas de CPU siempre son ejecutadas antes de otras que podrían ser más críticas para un sistema de este estilo. Este no es el caso por ejemplo con los procesos batch, ya que a no ser que se indique lo contrario terminar la ejecución de un proceso lo antes posible sería lo mejor. En el caso de sistemas operativos Real time, la priorización de procesos es crítica, por lo que una adaptación de SRTF debería ser lo mejor

## Ej10
**Fiaca**

## Ej11
La idea del ejercicio parecería ser que nos demos cuenta que SJF es en realidad una aproximación a partir del comportamiento anterior de los procesos en cuestión, pero no me convence que procesos intensivos en CPU no entren en starvation, debería preguntar

## Ej12
- |  P3  |  P2  |  P3  |  P1  |  P4 | P1 |  ... | P5 |

  0      2       3         7      8       10    12   13    16
- Waiting time promedio: $\frac{(7 + 2) + 0 + (0 + 1) + 0 + 0}{5} = 2$
- Turnaround promedio: $\frac{10 + 1 + 7 + 2 + 3}{5} = 4.6$

## Ej13
### a 
- FIFO: En este caso, si tenemos que un trabajo más largo llegó antes que uno corto, el más corto va a tener que esperar que el otro termine, sin importar la diferencia en sus tiempos de ejecución (convoy effect)
## b
- Round-Robin: En este caso, tenemos que el algoritmo es más "justo", en el sentido que cada proceso tiene un límite (quantum) de tiempo durante el cual tiene acceso al CPU, de esta manera evitando que procesos demasiado largos retrasen innecesariamente a los más cortos
## c
- Multilevel feedback queue: En este caso podemos asegurarnos de evitar starvation de procesos con bajas prioridades (qué determina la prioridad de un procesos va a depender del modelo en sí) lo que nos permite asegurarnos que, o bien los procesos más cortos tienen una prioridad más urgente por lo que podemos asegurarnos de que van a ser ejecutados primero, o bien con el paso del tiempo van a volverse más prioritarios, asegurandonos así que nunca se vean "tapados" por otros procesos indeterminadamente

## Ej14
- Throughput: Cantidad de procesos terminados por unidad de tiempo
- Acá no estoy seguro si es uno u otro, o si podemos elegir una combinación de ambos algoritmos. Si se trata del primer caso, entonces necesariamente tenemos que queremos hacer uso de round-robin, pues si no no estaríamos cumpliendo con los requerimientos del enunciado de buen tiempo de respuesta. 
- Dicho eso, también es cierto que sabemos que los trabajos de procesamientos de datos consisten de largar ráfagas de E/S, seguidas de cortas ráfagas de CPU, por lo que FCFS sería perfecto en este caso si tuvieramos que podemos usar un algoritmo distinto para cada uno de los procesos, ya que esto nos permite evitar el overhead causado por cambios de contextos innecesarios (pues es probable que el proceso ya estaba por terminar por sí mismo)
## Ej15
- En este caso, voy a distinguir entre dos tipos de procesos:
	- Aquellos que ocurren en respuesta al usuario apretando botones (brillo y contraste, zoom)
	- Generación de imágenes 
- Propongo entonces un scheduler preemptive con dos colas de prioridad, en la de mayor prioridad se van a encontrar los procesos asociados a los botones, y en la de menor prioridad aquellos asociados a la generación de imágenes. 
- Como la serialización de imágenes probablemente consista de cortas ráfagas de CPU siguiendo ráfagas de E/S, podemos usar un FCFS para la segunda cola. Por otro lado, podemos argumentar usar FCFS o RR en la primera, nos gustaría que el sistema sea lo más rápido posible al procesar estas tareas, por lo que evitar el overhead causado por cambio de contexto podría ser un gran beneficio si tenemos que los procesos no son demasiado y su tiempo de ejecución no difieren tanto (lo primero tiene sentido, ya que si tenemos una gran cantidad de procesos probablemente se deba al usuario abusando de los botones), caso contrario, podemos hacer uso de RR con un quantum adecuado

## Ej16
- Tenemos que tener en cuenta tres tipos de procesos:
	- Módulos de procesamiento de video, que constisten de una ráfaga de E/S, seguida por otra de CPU, y terminados por otra de E/S. Nos destacan que se quiere evitar situaciones poco "justas" de scheduling, y que durante la noche la carga de estos procesos es muy baja, consistiendo además de cortas ráfagas de uso
	- Gestión de alarma, para el cual es crítico que se terminen de ejecutar antes de un deadline estricto
	- Compresión de imágenes, a ser ejecutados durante la noche, y que consisten de dos ráfagas de E/S con una de CPU en el medio
- Con esto en cuenta, (y suponiendo que los deadlines para los procesos asociados a la gestión de alarma son accesibles), propongo el siguiente scheduler:
	- El mismo va a consistir de tres colas de prioridad, de 0 a 2, no cooperativo, de manera que las alarmas vayan a la 0, procesamiento de video a la 1, y compresión de imágenes a la 2
	- En la cola de prioridad 0 vamos a usar EDF, (nuevamente, suponiendo que tenemos acceso a los deadlines), permitiéndonos optimizar este aspecto
	- En la cola 1 vamos a hacer uso de RR, con un quantum adecuado para poder satisfacer los requerimientos de un schedules "justo"
	- En la cola 2 vamos a hacer uso de FCFS, ya que se tratan de procesos no interactivos, y queremos evitar lo más que podamos el overhead causado por cambios de contexto innecesarios para poder facilitar la compresión en su completitud
- La justificación es la siguiente:
	- Tenemos que queremos usar colas de prioridad ya que nos piden por un lado que las alarmas son críticas y deben cumplir con su deadline, la razón por la que además usamos 3 niveles es para asegurarnos de no perdernos información captada desde la cámara, por lo que tenemos una priorización de estos procesos sobre los de compresión
	- Tenemos además que en este modelo starvation debería ser evitado, ya que si tuvieramos demasiadas alarmas tomando recursos, tenemos que el sistema en su totalidad está en estado crítico, por lo que es aceptable una falta temporal de recursos para los demás procesos. Por otro lado, como durante la noche el procesamiento de video se va a ver reducido, tanto en cantidad como en carga, tenemos que darle más prioridad a estos procesos no nos va a impedir terminar la compresión antes de que se pierda el video "crudo"
	- La elección de algoritmos para cada una de las colas debería ser bastante intuitiva.
