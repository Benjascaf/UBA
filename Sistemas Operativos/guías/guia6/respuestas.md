## Ej1
- Para obtener los bloques correspondientes a un archivo, primero voy a tener que determinar cuál es el primer bloque del archivo, que voy a asumir es información incluida en la representaión del archivo, con eso en cuenta tengo que ir a disco y obtener la i-ésima entrada de la FAT (asumiendo que i es el primer bloque), y traerme el iésimo bloque, repitiendo este proceso, tengo n accesos a la tabla de FAT y n accesos más para buscar los bloques en sí, luego, tengo 2n accesos
- \
## E2
### a)
- Recordemos primero la relación de unidades:
	- 1 byte = 8 bits = 2
	- 1 Kib = 1024 bytes = $2^{10}$ bytes
	- 1 Mib = 1024 kb = $2^{20}$ bytes
	- 1 Gib = 1024 Mib = $2^{30}$
- Con esto en cuenta, primero calculamos cúantos bloques entran en memoria, para ello tomamos el cociente entre el tamaño del disco y lo que ocupa cada bloque, es decir $$\frac{128GB}{8KB} = \frac{{128 \times2^{30}}B}{8\times 2^{10}B} = 16 \times 2^{20} = 16777216$$
- Esta es la cantidad de bloques que entran en memoria (Usé kib, etc pq supuse que iba a ser más cómodo pero ahora no estoy tan seguro)
- Con la cantidad de bloques, podemos ahora determinar cuanto ocupa la tabla, para esto, multiplicamos lo que ocupa cada entrada (24 bytes, lo q me parece raro) por la cantidad de bloques, obteniendo: $$16 \times 2 ^{20} \times 24 B = 384 \times 2 ^{20}B = 384 MiB$$
### b)
- Primero determino cuantos bloques de $8 KiB$ necesito por archivo de $10 MiB$, para ello uso el cociente entre estos números: $$\frac{10MiB}{8KiB} = \frac{{10 \times2^{20}B}}{8 \times 2^{10}B} = 1.25 \times 2 ^{10} =_{\text{redondeando para arriba}}  1280$$
- Ahora tenemos que determinar cuantos bloques ocupa la tabla FAT, usando la misma cuenta que recién tenemos: $$\frac{384MiB}{8KiB} = 48 \times 2 ^{10}$$
- Calculamos ahora los bloques que podemos usar para almacenar archivos: $$16 \times 2 ^{20} - 48 \times 2^{10} = 16336 \times 2^{10}$$
- Y ahora veo cuántos archivos de 10 MiB puedo meter acá: $$\frac{{16336 \times 2^{10}}}{1,25\times2^{10}} = 13068.8 =_{redondeo} 13068$$
### c)
- Este no lo entiendo
## Ej3
### a)
- Para determinar el tamaño máximo de archivo que el modelo de enunciado soporta, primero calculo cuántos bloques de datos me permite tener por inodo
- Por un lado, tenemos los primeros 5 correspondientes a las entradas directas
- Después, para calcular cuántos bloques tengo en los bloques indirectos, tengo que calcular cuántas LBAS puedo meter en un bloque, y así determinar cuántas bloques puedo referenciar por bloque indirecto. Para ello calculo el cociente entre el tamaño del bloque de las LBAs: $$\frac{4KiB}{8B} = \frac{{2^{2} \times 2^{10}B}}{2^{3}B} = 2^{9}$$
- Y ahora, para la entrada doblemente indirecta, tengo que puedo referenciar $2^{9}$ bloques, cada uno capaz de referenciar $2^{9}$ bloques, por lo que la cantidad de bloques referenciados por esta entrada es ${2^{9}}^{2}$
- Con entradas directas puedo tener hasta $5 \times 4 KiB = 20KiB$, con un bloque indirecto, $2^{9} \times 4 KiB = 2048 KiB$, y, como tenemos dos de estos, $4096KiB$. Finalmente, para el bloque indirecto tengo $2^{18} \times 4KiB = 2^{20} KiB = 1GiB$.  Juntando todo, tenemos aprox 1028 MiB
### b)
- Tenemos que solo los archivos de $2KiB$ desperdician espacio, ya que los otros son múltiplos del tamaño de los bloque. Como estos archivos están desperdiciando la mitad de su espacio asignado (50% del espacio del disco), tenemos que el desperdicio total es de un 25%
### c) 
- Para procesar un archivo de $5MiB$, primero uso los primeros 5 bloques de referencia directa, y me quedan procesar todavía $5\times 2^{10}KiB - 20KiB = 5100KiB$
- Después uso las dos entradas indirectas (un total de $2^{10} + 2$ bloques, contando los dos que contienen las referencias), y me quedan procesar $5100 KiB - 4096KiB = 1004KiB$
- Con esto, y como tengo que $1004KiB \lt 2048KiB$, tengo que solo voy a necesitar acceder al primer bloque de referencias de la entrada doble. En particular, voy a necesitar $\frac{1004KiB}{4KiB} = 251$ bloques del mismo, luego, tengo $1 + 1 + 251 = 253$ bloques para procesar este cacho
- Juntando todo, tenemos $5 + (2^{10} + 2) + 253 = 1284$ bloques para procesar el archivo
## Ej4
- Primero diganme cuanto para las LBA, dicho eso, es trivial y se deduce del anterior 
### a)
## Ej5
- Voy a asumir tamaño de LBA 8B y tamaño de bloque $4KiB$ pq no especifican
- Notar que en todas la cantidad de accesos con FAT es la misma idea (recorrer la tabla e ir fetcheando bloques)
- Para determinar si el bloque buscado se encuentra en las entradas directas, algunas de las indiretas, o en las dobles y triples indirectas, puedo usar el hecho de que sé por el punto anterior que en cada entrada indirecta tengo $2^{9}$ bloques, y en la doble indirecta $2^{18}$ bloques, luego, sea n el número del bloque buscado:
	- Si n < 13, se encuentra en algunas de las entradas directas
	- Si (n) < $2 \times 2^{9}$, se encuentra en algunos de las entradas indirectos 
	- Si $n < 2^{18}$, se encuentra en la doble indirecta
	- Caso contrario, se encuentra en la triple
### I)
- Fat
	- Notar que esto es simplemente recorrer la tabla hasta llegar a la entrada correspondiente al i-ésimo bloque y ahí cargamos el bloque, con esto en cuenta, tenemos 9 accesos a disco.
- ext2:
	- Tenemos 6 accesos ya que los primeros 6 bloques se encuentran todos en las entradas, y después tengo que pedir un bloque extra (el primer bloque de acceso indirecto), para poder acceder a las úlltimas 3. En total, accedimos a 10 bloques
### II) 
- ext2:
	- Ahora tenemos seis accesos a bloques cuyas LBAs se encuentran en las entradas directas, y después tres accesos más para acceder al último bloque pues tenemos que acceder a la entrada doblemente indirecta y elegir de ahí el bloque indirecto donde se encuentra la LBA correspondiente al 10001 bloque
### III)
- ext2:
	- Accedo a la primer entrada indirecta para el bloque 13, accediendo a 2 bloques
	- Para el bloque 10000 acceda a la doble indirecta, después a un bloque indirecta, y después al bloque buscado, para un total de 3 accesos
	- Para el bloque 1000000, accedo a la triple indirecta, después a alguna doble indirecta, después a una simple indirecta, y finalmente accedo al bloque buscado, sumando un total de 4 accesos
	- Juntando todo, tengo $2 + 3 + 4 = 9$ accesos a bloques
### IV)
- ext2:
	- Accedo al primer bloque indirecto, y después todos los bloques se encuentras ahí, por lo que tengo un total de $1 + (50 - 13)= 38$ accesos 
## EJ6
### a)
- Para acceder a los bloques de datos, primero tengo que acceder al bloque distinguido de root que se encuentra en disco, ahí ubicamos la entrada de directorio correspondiente a home, y nos traemos el bloque correspondiente. Acá buscamos entonces la entrada de directorio correspondiente a aprobar.txt, y a empezamos a buscar todos sus bloques de datos.
### b)
- Nos traemos el inodo correspondiente a root, que es el 2, luego, buscamos el enlace simbólico, y nos traemos el inodo correspondiente, del cual vamos a tener que leer el bloque de datos para poder determinar el path, luego, nuevamente arrancamos desde root a buscar home, y después ahí buscamos aprobar.txt, como al enunciado le falta información, no puedo determinar la cantidad de bloques necesarios de manera exacta
## EJ7
### 1.
- FAT por default no soporta links, si la idea es que comparemos la versión FAT estándar entonces necesariamente vamos a necesitar usar inodos
### 2.
- En este caso tenemos que FAT no puede ser ya que el mismo  usa la tabla FAT y un duplicado como estructuras auxiliares, pero las mismas crecen con el tamaño del disco. Por otro lado, una implementación con inodos 
- NOC la verdad, no depende siempre del tamaño del disco?
### 3.
- FAT, pues inodos están técnicamente acotados,
### 4.
- Inodos
## EJ8
### a)
- Tenemos que cada bloque ocupa 2 sectores, es decir 2KiB. Luego, tenemos $\frac{{16\times{2}^{30}B}}{2 \times 2^{10}B} = 8 \times 2^{20}$ bloques que entran en disco. Como cada identificador ocupa $24 \text{ bits}=3 \text{ bytes}$ tenemos que el tamaño que ocupa la FAT es $3 B \times 8 \times 2^{20} = 24 MiB$
- Si los hashes son de 16 bits, tenemos $2^{16}$ posibles hashes, cada uno ocupa 2 bytes para el hash en sí, mas 3 bytes más para el identificador de bloque inicial, y supongamos que me alcanzan 4 bytes para indicar el tamaño del archivo, luego, tenemos que el espacio total es $2^{16}\times (2B + 3B + 4B)= 576 KiB$
- Asumiendo que se hace una copia de respaldo de ambas estructuras, el espacio que queda en disco va a ser $16Gib - 2\times 24MiB - 2\times 576KiB$
### b)
- Discutir este y el c
## EJ9
- La verdad que no estoy seguro. Conceptualmente sé que un file descriptor apunta a una entrada de la tabla de archivos global (donde hay información acerca de offsets, permisos, etc) que a su vez tienen un puntero al inodo en sí? No estoy seguro de todo esto, consultar
- Supongo que una posibilidad es cargar el inodo, y después recorrer root y todos los subdirectorios hasta encontrar un direntry que apunte al mismo inodo?
### Ej10
- Pendiente, me da fiaca hacer el código ahora, pero la idea es ir recorriendo los bloques corresponientes a cada directorios, por facilidad podría traerme todos los bloque de cada uno, y para determinar cuales son sus bloques recorro la FAT hasta encontrar un EOF
```c
struct entrada_directorio {
	bloque_inicial;
	nombre;
	es_directorio;
}

cargar_archivo(directorios[]) {
	root_table = root_table();
	dir_entry root_dirs[] =parse_directory_entries(raw_data);
	int i = 0;
	while (root_dirs[i].name != directorios[0]) {
		i++;
	}
	int next_dir = 1;
	int curr_block = read_blocks(root_dirs[i].bloque_inicial)
	
}
```