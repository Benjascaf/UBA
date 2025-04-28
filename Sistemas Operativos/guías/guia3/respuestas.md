## Ej1
### a 
- No
### b
- Código 1:
	- Proceso A termina todo su código antes de proceso B, imprimiendo 1
	- Proceso B modifica X antes que A imprima el valor de la variable, haciendo que imprima 2
- Código 2:
	- Proceso A ejecuta termina de ejecutar antes que arranque proceso B, se imprime 0123
	- dependiendo De como se vayan ejecutando los procesos, se va a imprimir una variación de (valor de X)a(valor de X | a)
	- También es posible que se imprima una a antes que cualquier dígito, dependiendo del compilador y si decide que al no haber dependencias puede reordenar el código
## Ej2
- Puede ocurrir condiciones de carrera, pues podemos llegar a incrementar x cuando el mismo ya era mayor a 5, o decrementarlo cuando el mismo ya es menor o igual
## Ej3
- Es posible que ocurra inanición (starvation (? ) de procesos si usasemos una pila en vez de una cola ya que tenemos que un mismo proceso podría ponerse a esperar, ser señalado, y después volver a esperar, antes que los procesos debajo de él sean señalados

## Ej4
```
wait(s):
	while (s <= 0) sleep();
	s--;
signal(s):
	s++;
	if (alguien está esperando a s) despertar a alguno;

```
- Si no se cumpliera que ambas instrucciones se realizaran de manera atómica, tendríamos que, por ejemplo, un proceso podría llamar a wait(s) con s = 1, verificar que no es $\leq 0$, continuar a la siguiente linea, y ser interrumpido por otro proceso que también hace wait(s), el mismo también va a ver a s con valor positivo, y seguir su ejecución, causando que tengamos dos procesos ejecutando a la vez (y ademas s con un valor negativo)
- Si signal no fuese implementado de manera atómica, tendríamos que sería posible que tengamos un proceso esperando a ser despertado, y otro proceso que, luego de que incrementamos s y chequeemos si hay alguien esperando, nos interrumpe y ejecuta wait, esto va a causar que decremente s, y cuando volvamos al proceso actual despertemos al proceso que estaba esperando anteriormente

## Ej5
- El código aportado permite inanición ya que hay sólo un signal para barrera, causando que solo uno de los procesos pueda seguir ejecutando, para corregirlo, realizamos n señales 
```
preparado()  
mutex.wait()  
count = count + 1  
mutex.signal()  
if (count == n)  
	for (i=1...n)
		barrera.signal() 
barrera.wait()  
critica()
```

## Ej6

- Herramientas atómicas que menciona el enunciado (creo):
	- Variables atómicas (x int, y bool)
	- x.set()
	- x.get()
	- x.getAndInc()
	- x.getAndAdd()
	- y.getAndSet()
	- y.testAndSet()
	- y.lock()
	- y.unlock()
```
atomic<int> count;
atomic<bool> isover;
isOver.set(false)
count.set(0);


preparado()  
currCount = count.getAndInc()
if (currCount == n)
	isOver.unlock()
isOver.lock()
isOver.unlock()

critica()
```

- NOC, preguntar

## Ej7

- Yo sé que número de proceso soy?
- Spawn de procesos?
```
setup = false;
setup.set(false)
mutexes[N];
setupMutex = sem(1);

wait(setupMutex);
if (!setup) {
	for (j=1...n-1) {
		if (j == i) {
			mutexes[j] = sem(1);
		} else {
			mutexes[j] = sem();
		}
	}
}
signal(setupMutex);
//De nuevo, no estoy seguro si el proceso conoce su índice (k)
mutexes[k].wait()
procesar()
mutexes[k + 1 % N].signal()



```

## Ej8 
### 1
```
semA = sem(1);
semB = sem(0);
semC = sem(0);
A() {
	wait(semA);
	procesar();
	signal(semB);
}

B() {
	wait(semB);
	procesar();
	signal(semC);
}

C() {
	wait(semC);
	procesar();
	signal(semA);
}
```

### 2
```
semA = sem(0);
semB = sem(2);
semC = sem(0);
A() {
	wait(semA);
	procesar();
	signal(semB);
	signal(semB);
}

B() {
	wait(semB);
	procesar();
	signal(semC);
}

C() {
	wait(semC);
	wait(semC);
	procesar();
	signal(semA);
}

```

### 3
- Basándome en un principio en el ejemplo de la teórica
```
mutex = sem(1);
espacios_ocupados = sem(0);
espacios_libres = sem(N);
semA = sem(2);
cant;
//Buffer de capacidad N
buffer;
A() {
	while(true) {
		wait(semA);
		wait(semA);
		item = producir_item();
		// Esperamos dos veces para
		// Asegurar dos espacios
		wait(espacios_libres);
		wait(espacios_lbres);
		wait(mutex);
		agregar(buffer, item);
		agregar(buffer, item);
		cant+= 2;
		signal(mutex);
		signal(espacios_ocupados);
		signal(espacios_ocupados)
	}
}


// Si no me equivoco, el código de B y C es el mismo (supongo que lo que cambiaría es cómo procesan el item? )
B() {
	while(true) {
		wait(espacios_ocupados);
		wait(mutex);
		item = sacar(buffer);
		cant--;
		signal(mutex);
		signal(espacios_libres);
		semA.signal();
		procesar_itemB(item);
		
	}
}

C() {
	idem
}

```

### 4
- La idea es que los consumidores se vayan organizando entre sí, con el productor ignorandolos, como tenemos que ejecuta dos veces, hacemos dos waits en los procesos A y C
```
mutex = sem(1);
espacios_ocupados = sem(0);
espacios_libres = sem(N);
semA = sem(2);
semB = sem(1);
semC = sem(0);
cant;
//Buffer de capacidad N
buffer;
A() {
	while(true) {
		wait(semA);
		wait(semA);
		item = producir_item();
		// Esperamos dos veces para
		// Asegurar dos espacios
		wait(espacios_libres);
		wait(espacios_lbres);
		wait(mutex);
		agregar(buffer, item);
		agregar(buffer, item);
		cant+= 2;
		signal(mutex);
		signal(espacios_ocupados);
		signal(espacios_ocupados)
	}
}


// Si no me equivoco, el código de B y C es el mismo (supongo que lo que cambiaría es cómo procesan el item? )
B() {
	while(true) {
		wait(espacios_ocupados);
		wait(mutex);
		item = sacar(buffer);
		cant--;
		signal(mutex);
		signal(espacios_libres);
		semA.signal();
		semC.signal();
		procesar_itemB(item);
		
	}
}

C() {
	while(true) {
		semC.wait()
		semC.wait()
		wait(espacios_ocupados);
		wait(espacios_ocupados);
		wait(mutex);
		items[0] = sacar(buffer);
		cant--;
		items[1] = sacar(buffer);
		cant--;
		signal(mutex);
		signal(espacios_libres);
		signal(espacios_libres);
		semA.signal();
		semA.signal();
		semB.signal();
	
	}
}

```

## Ej9
- Misma idea que en el ej 5 y el ej de la práctica no? Usamos una señal que actúe como barrera, y mantenemos un contador y un mutex para poder evitar race-conditions al accederlo y modificarlo
- Calculo la idea del ej era generalizar este patrón?

### Ej10
### a 
- Sí, si foo ejecuta su primer línea, decrementa a S, y después es interrumpida y bar ejecuta su primer línea, entramos en un Deadlock
### b
- Mepa que no, más allá de Deadlock completo no veo pq podría ocurrir inanición para sólo un proceso

## Ej11
- Si no me equivoco esto es sólo un renombre del problema del productor-consumidor (en el sentido que es literal un copy-paste)