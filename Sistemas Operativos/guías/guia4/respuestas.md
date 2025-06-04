## Ej1
- Fragmentación externa:
	- A medida que procesos son cargados y liberados de la memoria, el espacio de memoria libre se va separando en pedacitos
	- Esta fragmentación se presenta cuando hay suficiente memoria para ser asignada a un proceso, pero la misma no se encuentra en un espacio contiguo
- Fragmentación interna:
	- Cuando se usa un esquema de segmentación de memoria que particiona la misma en bloques fijos se puede tener que un proceso requiera memoria de manera tal que le sobre espacio en uno de los bloques asignados al mismo.  Este problema es conocido como fragmentación interna

## Ej2
- a) 
	- Los programas van a ir a los siguientes bloques
		- 500 KB -> 512 KB
		- 6 MB -> 8 MB
		- 3 MB -> 4 MB
		- 20 KB -> 512 KB
		- 4 MB ->  No hay asignación posible
	- La cantidad de memoria desperdiciada es entonces: $$(512 KB - 500KB) + (8 MB - 6 MB) + (4 MB - 3MB) + (512 KB - 20 KB) + 0 + 1 MB + 2 MB = 6648 KB$$
- b) 
	- Ya tenemos **Fiaca seguir**

## Ej3
- Tenemos un sistemas que esta haciendo poco uso de la CPU, de los dispositivos de E / S, y además hace thrashing
- Antes de encarar, recuerdo la definición de thrashing;
	- Decimos que un proceso esta haciendo thrashing si el mimso gasta más tiempo haciendo paging (este es el término que voy a estar usando para referirme a swapping de páginas, más que nada pq es el término que usa el libro)
	- Generalizandolo al sistema, podemos pensarlo como que todos los procesos están haciendo thrashing
- Con esto en cuenta, tenemos
- a) Ya tenemos que el sistema está haciendo poco uso de la CPU, es claro que la misma no es la causa del problema
- b) Nuevamente, incrementar el disco de paginado (calculo hace referencia a parte de la partición de swapping) no va a afectar la situación ya que el cuello de botella se encuentra en la cantidad de frames que los procesos tienen disponibles
- c) Si incrementásemos el grado de multiprogramación, la situación empeoraría, ya tenemos que los procesos tienen menos frames disponibles que lo que requieren, y probablemente se estén peleando por ellos (a no ser que el sistema esté usando un algoritmo de reemplzamiento local, asumo que no), por lo que meter incluso más competencia solo va a empeorar la situación
- d) En este caso, esto sí podría mejorar la situación, ya que podría facilitar una mayor cantidad de memoria a cada proceso
- e) Podría llegar a mejorar al tener más memoria para ser utilizada por los procesos
- f) Es debatible, es bastante probable que la mejora sea marginal debido a que el proceso de acceso a disco siempre va a ser "lento" en comparación a la capacidad de operación del CPU
- g) Probablemente no, a pesar que incrementamos el tamaño de las páginas (y supongo también frames), el tamaño de la memoria se mantuvo, por lo que el efecto es que ahora podemos tener menor cantidad de páginas, por lo que, mientras que un sólo proceso tal vez necesite menos cantidad, la "competencia" podría continuar o incluso emperorar
- h) Diferencia este con el f?
## Ej 4
- Si al traducir una dirección lógica la mmu tiene que apunta a una entrada marcada como inválida tenemos que se activa un trap gate (FURFI VOLVEEEE), en el cual se hace lo siguiente:
	- Se verifica que la dirección lógica no sea inválida (no esté tratando de acceder a memoria no correspondiente al proceso), en cuyo caso se mata al proceso
	- si la dirección era válida, hacemos paging y nos traemos la página a memoria (buscando un frame libre / usando un algortimo de alocamiento)
	- Cuando la página ya está cargada, actualizamos las estructuras a nivel kernel asociadas a las páginas del proceso, así como la page table del proceso
	- Reiniciamos la instrucción que fue interrumpida
## Ej 5
- Mucha fiaca hacer la tablita acá
## Ej 6
- a) Porque una vez que ya hayamos ocupado todos los frames en memoria, mientras que sigamos en la secuencia el siguiente pedido de página va a ocasionar un page fault, seguido por un swap
- b) Si tuvieramos 500 frames, podríamos usar los primeros k frames (con k siendo algo cerca de 500), para los primeros k paginas y dejar esas páginas fijas, y tener 500 - k frames siendo swappeados para poder usar el resto 

## Ej 7
- $\{ 0,1,2, 2, 1, 0, 3 \}$
- La idea es jugar con el hecho de que Second Chance lo va a marcar como referenciado, pero no va a tener en cuenta el tiempo de la misma manera que lo hace LRU, por lo que al referenciar la secuencia de frames que cargamos en principio en un orden distinto, obtenemos la diferencia en comportamiento
## Ej 8
- a) 
	- FIFO: orden de llegada?
	- LRU: última instancia de tiempo en la que la página fue referenciada
	- Second Chance: Orden de llegada + si fue referenciada en algún momento?
- b) 
	- Si hay frames libres, simplemente cargar la página y actualizar las estructuras de datos necesarias,  (page directory, table, etc)
	- Caso contrario, recorremos los frames e identificamos con el atributo usado por el algoritmo cual desalojar
		- Si la misma fue modificada en algún momento y está con el bit de dirty prendida, la escribimos a memoria
		- Traemos la nueva página
		- Actualizamos todas las estructuras de datos necesarias para representar el cambio 
	- Reseateamos la instrucción que causó el page fault en un principio

## Ej9
- a) La página 3 va a ser reemplazada (su tiempo de carga es elmás viejo)
- b) La página 1 va a ser reemplazada, (Es la que más tiempo tiene desde su última referencia)
- c) La 2, (La 0 y la 3 safan en la primer vuelta por tener los bits de referencia prendidos)
## Ej10
- a) Tenemos que el frame donde se encuentra el código se mantiene, y cada 2 iteraciones sobre i genera un nuevo page fault (pues nos traemos 200 elementos a memoria, desde i A[i] a A[i + 2 - 1], generando 50 page faults por cada iteración sobre j, luego tenemos $100 * 50 = 5000$ page faults 
- b) De manera similar, tenemos un page fault por cada 2 iteraciones sobre i, pero ahora recorremos toda la página que nos trajimos, por lo que tenemos solo 50 page faults
## EJ11

### EJ12
- Para el sistema A tenemos que una vez que termina de procesar un bloque, ya no va a necesitarlo más, por lo que nos gustaría poder minimizar lo máximo posible las estructuras y soporte necesario para determinar qué página desalojar. Tenemos además que el algoritmo de procesamiento que el sistema use es el mismo para todos los bloques. Con esto en mente, propongo utiliza el algoritmo c), ya que el mismo nos habilita a mantener las páginas del algoritmo siempre en memoria, sin el overhead de los otros dos algoritmos (LRU hubiera funcionado también, pero estoy suponiendo es más "caro" de implementar, tal vez esté equivocado)
- Por una razón similar a la anterior, para el proceso B podemos hacer uso de páginas estáticas para el proceso principal, mientras que los programas específicos para las mediciones utilizan second chance
## Ej13
- a) 
	- Para ejecutar un programa cuyo tamaño es mayor que la memoria disponible, se hace una separación del espacio de memoria que un proceso conoce (su memoria virtual), y el espacio de memoria físico asociada a dicha memoria virtual. De esta manera, el proceso siempre va a acceder a memoria usando direcciones virtuales, y es responsabilidad de la mmu traducir las mismas a direcciones físicas. 
	- Una vez que se tiene este modelo, la manera en la que un proceso puede ejecutar incluso si es más grande que la cantidad de memoria disponible, es que, al realizar la traducción a memoria física, si el sistema determina que el frame asociado no se encuentra cargado en memoria, el mismo va o bien simplemente cargarlo en el cayo de que haya un frame disponible, o bien usar algún algoritmo para determinar qué frame desalojar, lo que permite que el proceso siempre tenga acceso a la página que necesita en el el momento, incluso si parte del resto del 