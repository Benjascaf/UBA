- https://web.ecs.syr.edu/~wedu/seed/Book/book_sample_buffer.pdf
- 
## Ej1
### a)
- Para verificar si un usuario ingresó su contraseña correctamente, puede computar la función de hash con el input del usuario como entrada, y comparar resultados
- Esto es asumiendo que se utilice un sistema que no haga uso de salt, caso contrario, se genera el número a usar como salt de manera random y se lo agrega al texto que inputeo el usuario, de esta manera, se vuelve computablemente imposible computar y guardar en una tabla todas las posibles contraseñas (sin mencionar que se debería tener acceso al salt en sí mismo)
### b)
- Sería la posibilidad de que un input cualquiera dé justo el valor de hash de la contraseña ($\frac{1}{2^{64}}$) ?
### c)
- Tenemos que vamos a llegar a un 50% de probabilidad de acertar en el valor de hash al haber tratado la mitad de todos los posible inputs, es decir, $2^{63}$ valores, si consideramos que estamos probando $10^9 \text{hashes/seg}$, tenemos que por año estamos probando $10^9 \text{ hashes/seg} * 3.1536 \times 10^{7} \text{ seg/year}= 3.1536\times 10^{16} \text{ hashes / year}$
- Luego tenemos que $\frac{2^{63}\text{hashes}}{3.1536\times 10^{16} \text{ hashes/year}} = \frac{2^{63}\text{hashes}}{3.1536\times 2^{16}\times 5^{16} \text{ hashes/year}} = \frac{2^{47}\text{ year}}{3.1536\times 5^{16}}\approx 292 \text{ year}$
### d)
- El hecho de que los carácteres sean sólo letras minúsculas o dígitos (un total de 36 posibles valores), y la longitud de la contraseña sea 6, nos dice que tenemos un total de $36^{6}$ posibles combinaciones
- Suponiendo que se pueden probar $10^{9}$ contraseñas por segundo, si se hace uso de búsqueda exhaustiva, el tiempo total necesario para encontrar la contraseña es a lo sumo $\frac{36^{6}}{10^{9}}\approx 2.18$ segundos, casi nada!

## Ej2
### a)
- Si nuestra única medida de seguridad fuese enviar una contraseña hasheada, pordríamos estar expuestos a un man-in-the-middle donde un third-party podría intervenir en el pasaje de la contraseña, recibir la contraseña hasheada, y mandarle otra al destinatario original. De esta manera, el mismo puede comunicarse con ambas partes e identificarse apropiadamente, engañando al usuario y al sistema
### b)
- Tenemos que el atacante tiene el seed y el valor de hash, para poder obtener el valor de la contraseña  offline debería hacer uso de fuerza bruta con esta información, asumiendo que no conoce la función de hasheo. Caso contrario, si se usó un algoritmo apropiado, sería imposible ya que sabemos que las mismas están optimizadas para que calcular su preimágen (o dominio, si prefieren ese término), sea ***Computationally infeasible***

## Ej3
### a) y b)
- La vulnerabilidad surge debido al uso de la función gets
	- Lo siguiente es calcado del manual:
	- Never use gets().  Because it is impossible to tell without knowing the data in advance how many characters gets() will read, and because gets() will continue  to  store  characters past the end of the buffer, it is extremely dangerous to use.  It has been used to break computer security.  Use fgets() instead.
- Debido a esto, el usuario podría meter como input un string lo suficientemente grande como para sobreescribir la dirección de retorno de la función
	- Este es el exploit más común, pero podría escribir incluso más y afectar el stackframe en su totalidad
### c)
- Me parece que no, el stack crece en dirección contraria (direcciones más altas) al sentido en el que se escribe el input del buffer 
### d)
- No, por la justificación dada en el ejercicio anterior el último printf no nos salva del error

## Ej4
```c
struct credential {
	char name[32];
	char pass[32];
}
bool login(void) {
	char realpass[32];
	struct credential user;
	// Pregunta el usuario
	printf("User: ");
	fgets(user.name, sizeof(user), stdin);
	// Obtiene la contraseña real desde la base de datos y lo guarda en realpass
	db_get_pass_for_user(user.name, realpass, sizeof(realpass));
	// Pregunta la contraseña
	printf("Pass: ");
	fgets(user.pass, sizeof(user), stdin);
	return strncmp(user.pass, realpass, sizeof(realpass)-1) == 0;
	// True si user.pass == realpass
}
```
### a) 
- Soy un vago, y tampoco tengo tiempo, así que acá va una explicación de cómo se ve la pila (voy a ignorar registros de propósito general, callee-saved, etc, y limitarme principalmente a variables locales a nivel del código en C)
	- Primero tenemos las variables locales de la función login, realpass y un struct de nombre credential inicializado como user
		- En total tenemos espacio para 3 arreglos de 32 bytes (ignorando padding para el struct)
	- Al llamar a `printf` seguimos convención ABI, pusheando dirección de retorno y...
	- Para llamar a `fgets`, pusheamos los argumentos en orden inverso (primero `stdin=0`), notar acá que cuánto límitamos a escribir es el tamaño del struct, y no del buffer (`fgets` acepta input hasta newline o EOF)
	- Seguimos usando convención de ABI para llamar a db_get_pass...
	- Nuevamente, al llamar a `fgets` el tamaño es el incorrecto
	- Seguimos ABI para `strncmp`...
- Como mencioné en el punto anterior, el contenido de los buffers se escribe en el sentido de las direcciones más bajas, mientra que el stack crece al revés
### b)
- En el primer prompt, escribimos admin, y el programa va a ir a fetchear la password del mismo
- En el segundo prompt, escribimos $2 \times 32$ carácteres iguales, por como se encuentran ordenados los buffers en el stack, esto va a causar que el buffer correspondiente con realpass tenga el mismo contenido que pass, por lo que la comparación va a ser exitosa

## Ej5
```c
bool check_pass(const char* user) {
	2 char pass[128], realpass[128], salt[2];
	3 // Carga la contraseña (encriptada) desde /etc/shadow
	4 load_pass_from(realpass, sizeof(realpass), salt, user, "/etc/shadow");
	5
	6 // Pregunta al usuario por la contraseña.
	7 printf("Password: ");
	8 gets(pass);
	9
	10 // Demora de un segundo para evitar abuso de fuerza bruta
	11 sleep(1);
	12
	13 // Encripta la contraseña y compara con la almacenada
	14 return strcmp(crypt(pass, salt), realpass) == 0;`
15 }
```
### a)
- El mecanismo que permite el acceso al archivo es el permiso especial SETUID, que hace que el archivo siempre se ejecute como su dueño. 
- En nuestro caso, si el ejecutable tuviese SETUID y su dueño fuese root, podríamos acceder a archivos de niveles de privilegio superiores
### b)
-  Esto no me queda claro el layout de las variables en el stack, en un principio creí que era sólo que podía hacer code injection, pero tal vez también al resto de los buffers?
### c)
- Si, compremete al sistema ya q cualquier usuario malicioso (no es necesario ser un agente externo para serlo) puede hacer uso de esta vulnerabilidad

## Ej6
```c
#define NEGATIVO 1
#define CERO 2
#define POSITIVO 3
int signo(float f) {
if (f < 0.0) return NEGATIVO;
if (f == 0.0) return CERO;
Página 3 de 14
Sistemas Operativos, Exactas, UBA – Práctica 7 1er cuatrimestre de 2025
if (f > 0.0) return POSITIVO;
assert(false && "Por aca no paso nunca");
return 0; // Si no pongo esto el compilador se queja =(
}
```
### a)
- Si el usuario pasara un NaN como parámetro, tenemos que el assert se ejecutaría, pues cualquier comparación entre NaN y un número retorna falso
### b)
- No, por lo indicado recién

## Ej7
### a)
- En este caso deberíamos poder ser capaces de sobreescribir la dirección de retorno incluso a pesar de la nueva estrategia de defensa, ya que la misma siempre es posible calcular de manera relativa a la linea en ejecución
### b)
- En este caso, al tener que ahora la dirección del stack está randomizada, se vuelve mucho más difícil poder predecir dónde debería ir a parar para ejecutar el código malicioso
### c)
- Consultar este, pero me parecería que no lo afecta, ya que tenemos conocimiento a la posición exacta de la syscall
## eJ8
```c
#define BUF_SIZE 1024
void wrapper_ls(const char * dir) {
	char cmd[BUF_SIZE];
	snprintf(cmd, BUF_SIZE-1, "ls %s", dir);
	system(cmd);
}
```
### a)
- `;cat /etc/passwd`
### b)
- `";cat /etc/passwd"`
- Entiendo que la idea es usar las "" para que siga funcando, pero en mi máquina corrión sin necesidad de usarlos?
### c)
- Se puede hacer uso de otro concatenador de instrucciones, como por ejemplo `&&`
### d)
- Lo que debería hacer es sanitizar el input, pero mepa igual no bastaría para q sea seguro
- Esto creo sí anda
```c
#define BUF_SIZE 1024
void wrapper_ls(const char * dir) {
execl("/bin/ls", "ls", dir, NULL); /* no shell and no PATH search */
}
```

## Ej 9
- Fiaca pensarlo, pero tiene pinta de integer overflow sobre la variable b
## EJ10
```
#define BUF_SIZE 1024
int suma_indirecta(void) {
	int buf[BUF_SIZE];
	int i, v;
	memset(buf, 0, sizeof(buf));
	while (cin >> i >> v) { // Leo el índice y el valor
	if (i == -1) break; // Un índice -1 significa que tengo que terminar.
	if (i < BUF_SIZE) buf[i] = v; // Guardo el valor en el buffer
	}
	// Calculo la suma de los valores
	v = 0
	for (i=0; i < BUF_SIZE; i++)
	v += buf[i];
	return v;
}
```
### a)
- No, con un i negativo podemos lograr escribir afuera del buffer
### b)
- Lo interesante 
### c)
- Sí, podemos intentar estimar la posición exacta donde se encuentra la dirección de retorno y escribir ahí diréctamente, notar que en este caso no es necesario llenar el buffer más allá de su límite
## EJ11
- Links copados que usé para entender bien en detalle esto
	- https://devel0pment.de/?p=351?lab4B
	- https://web.ecs.syr.edu/~wedu/Teaching/cis643/LectureNotes_New/Format_String.pdf
	- https://youtu.be/t1LH9D5cuK4?si=RFhZsKITBIVQ28Bg
	- https://youtu.be/0WvrSfcdq1I?si=R-jD-w5lp8V4lLTk
	- 
```c
#define MAX_BUF 4096
void saludo(void) {
	char nombre[MAX_BUF];
	printf("Ingrese su nombre: ");
	fgets(nombre, MAX_BUF, stdin);
	printf(nombre);
}
```

### a)
- Sorprendentemente, en el uso del printf. Un agente malicioso podría usar como input un string formateado, por ejemplo  `Hola%s%s%s%s%s` leería posiciones de memoria como si fueran punteros a strings, por lo que si llegase a intentar leer un puntero inválido (NULL o a una dirección que no tiene acceso), entonces rompería la ejecución del programa
### b)
- De manera parecida a un buffer overflow, una porción de los datos ubicados en las posiciones más altas pueden ser leídos, sobreescritos, etc
### c)
- Sí es posible, haciendo uso de format strings, podemos o bien leer valores hasta llegar a un punto donde estimamos se encuentra la dirección de retorno del printf en el stack, o bien usar strings con especificadores tales como $ para leer directamente el offset deseado.
- De esta manera, podemos incluso escribir/leer todo lo que se encuentra en el stack
### d)
- No, nuevamente, podemos modificar la dirección de retorno del printf, o leer valores en el stack, por lo que el exit, si bien evita que romper la direccción de retorno saludo rompa algo, no evita la vulnearibilidad. 
- Una mejor solución sería usar `printf("%s", nombre)`, evitando el problema directamente


## Ej 12
- No, no solo podemos modificar la direccion de retorno de printf, o acceder a cualquier valor en las posiciones más altas respecto del llamado a printf, sino que también tenemos un gets dando vuelta
## Ej13
```c
char *SSL_get_shared_ciphers(
char* ciphers[],
int cant_chipers,
char *buf,
int len
) {
	char *p;
	const char *cp;
	int i;
	if (len < 2) return(NULL);
	p=buf;
	for (i=0; i<cant_ciphers; i++) {
	/* Decrement for either the ’:’ or a ’\0’ */
		len--;
		for (cp=ciphers[i]; *cp; ) {
			if (len-- == 0) {
				*p=’\0’;
				return(buf);
			}
			else {
				*(p++)= *(cp++);
			}
			*(p++)=’:’;
	}
	p[-1]=’\0’;
	return(buf);
}
```
### a)
- Si tuviéramos que el usuario pudiese tener conocimiento del valor de len, podría hacer uso de una cantidad adecuada de ciphers tal que justo dé que en la iteración con len=1 se tenga `*cp='\0`, esto causaría que entre en la clausa del else, y que en la siguiente iteración del for exterior decremente len nuevamente, causando que sea < 0 y sobrepasando siempre el if clause
### b)

## Ej14

## Ej15
```c 
void imprimir_habilitado(const char *nombre_usuario, const char* clave,
const char * imprimir, int tam_imprimir) {
	char *cmd = malloc(tam_imprimir+5 * sizeof(char));
	if (cmd == NULL)
		exit(1);
	if (usuario_habilitado("/etc/shadow", nombre_usuario, clave)) {
		snprintf(cmd, tam_imprimir+4, "echo %s", imprimir);
		system(cmd);
	} else {
		printf("El usuario o clave indicados son incorrectos.");
		assert(-1);
	}
}
```
### a)
- Sí, es necesario que el binario sea ejecutado con privilegios de root para poder llamar exitósamente a la función `usuario_habilitado`,  para esto, sería necesario que se tenga el setuid bit prendido, que el owner sea root, y que esté habilitado el bit de ejecución para `others`, de manera que cualquier usuario pueda ejecutarlo
### b)
- Una posible vulnerabilidad es a cambios en la variable de entorno PATH, lo que podría permitir al usuario levantarse una shell, o correr cualquier comando que quisiese, al hacer que el comando echo en realidad ejecute el binario del usuario
- Otra manera es mediante code injection, ya que no se sanitiza el input de `char *imprimir`
### c)
- Fiaca, lo hicimos mil veces ya
### d)
- Recordemos primero las definiciones:
	- **Confidenciabilidad:** Garantizar que la información esté disponible solo para personas autorizadas y protegerla de accesos no autorizados.
	- **Integridad:** Asegurar que los datos se mantengan precisos y sin alteraciones no autorizadas 
	- **Disponibilidad:** Mantener la información accesible y disponible para usuarios autorizados, evitando interrupciones no planificadas
- Con esto en cuenta, tenemos que a nivel de confidenciabilidad fallamos completamente ya que cualquier usuario puede una vez identificado elevar sus privilegios fácilmente. 
- En términos de la integridad, una vez que el usuario gane permisos de root hay pocas cosas que no pueda modificar del sistema
- En términos de disponibilidad, tenemos que el usuario que ahora tiene permisos elevados es capaz de interrumpir el acceso a la información de otros usuarios, e incluso interrumpir sus sesiones (algo extremo que podría hacer, `rm -rf /`)
### e)
- Para evitar el exploit por variables de ambiente, podemos usar un path completo para ejecutar el comando echo
- Para evitar command injection, podemos sanitizar de manera correcta el input mediante allowlists y blocklists
## Ej16
```c
/**
* Dado un usuario y una clave, indica si la misma es válida
*/
extern bool clave_es_valida(char* usuario, char* clave);
bool validar_clave_para_usuario(char *usuario){
	// fmt = " %......."
	char fmt[8];
	fmt[0] = ’%’;
	printf("Ingrese un largo para la clave: ");
	// fmt = " %NNNN\0"
	scanf(" %4s", fmt+1);
	int l = strlen(fmt+1);
	// max_size <- atoi(NNNN)
	unsigned char max_size = atoi(fmt+1);
	char clave[max_size+1];
	// fmt = " %NNNNs\0"
	fmt[l+1] = ’s’;
	fmt[l+2] = ’\0’;
	scanf(fmt, clave);
	return clave_es_valida(usuario, clave);
}
int main(int argc, char **argv){
	setuid(0);
	bool es_valida = validar_clave_para_usuario(argv[1]);
	if(es_valida) {
		system("/bin/bash");
	} else {
		exit(EXIT_FAILURE);
	}
}
```
- Arranquemos por `main`
	- La misma arranca elevendo sus privilegios a root, voy a asumir que esto anda bien y que el ejecutable tiene el setuid bit prendido con owner root
	- valida el primer argumento recibido al ejecutar el binario, y, en caso de éxito, **levanta una terminal**
- Veamos ahora `validar_clave_para_usuario`
	- declara un buffer de tamaño 8 `fmt` y setea la primera posición con el valor `%`
	- Luego, lee hasta 4 caractéres de stdin y los guarda en las siguientes 4 posiciones de `fmt`
	- Se guarda la longitud del string empezando desde la segunda posición en `l`
	- Se convierte el input a un int y se guarda el resultado en una variable `max_size` de tipo **unsigned char**
	- Se inicializa un arreglo `clave` de tamaño `max_size + 1`
	- Se agrega un carácter s al final de fmt y se mueve el caracter null
	- Leemos la cantidad de caracteres especificados en `fmt` en el buffer `clave`
	- Llamamos a la función `clave_es_valida`
- La vulnerabilidad principal se da con el hecho que guardamos un int en una variable de tipo unsigned_char, abusando el overflow, esto nos permite escribir más caracteres de los que entran en el buffer, lo que nos podría permitir, con un payload adecuado, sobreescibir la dirección de retorno de la función, en particular, podríamos intentar adivinar la dirección del stack y escribir un binario que se encargue de levantar una shell, junto con un nopsled para facilitar la posibilidad de pegarle a la dirección de lo escrito.
- Se puede hacer uso de stack randomization (ASLR), o de directamente no permitir que el stack sea a la vez ejecutable y escribible (DEP). También se podría hacer uso de canaries
### Ej17
```c
char MAX_SIZE = 127;
unsigned char buffer[128];
char *format = "%s %d %s\n";
char* algo_asi_si(char *cadena) {
	scanf(" %127s", buffer);
	printf(format, buffer, MAX_SIZE, cadena);
	return cadena;
}
char* algo_asi_no(char *cadena){
	if(strlen(cadena) > MAX_SIZE) exit(EXIT_FAILURE);
	sprintf(buffer, format, "echo" , atoi(cadena), "asi si?\n");
	system(buffer);
	return cadena;
}
int main(int argc, char **argv){
	setuid(0);
	printf(algo_asi_no(algo_asi_si(argv[1])));
}
```
- Voy a tomar cada uno de los puntos del ejercicio como un ítem para que la solución quede mejor estructurada que el anterior
### a)
- El programa declara 3 variables globales, `MAX_SIZE`, `buffer` de tamaño 128, y un `char* format`, que esperaría procesar un puntero a un string, un dígito, y otro string
- Analizando `main`, tenemos que:
	- Eleva sus privilegios a root
	- usa **printf** para imprimir a stdout el output de la función `algo_asi_no` con el resultado de la función `algo_asi_si` después de haberla llamado con el argumento pasado por el usuario al correr el ejecutable
- Veamos ahora `algo_asi_si`
	- La misma devuelve un puntero a char
	- Primero lee hasta 127 caractéres de stdin en `buffer`
	- Luego imprime a stdout usando el formato especificado por `format` (string, int, string), los contenidos del buffer, el tamaño máximo, y la cadena que uso el usuario
	- Devuelve la cadena que tomó como argumento
- Veamos ahora `algo_asi_no`:
	- Tenemos que primero valida que la longitud de la cadena no se pase de `MAX_SIZE`
	- Luego, escribimos en `buffer` el comando `echo`, seguido del input del usuario pasado a int (notar que si esto no es posible el valor de retorno es 0, y como la función no informa acerca de errores no hay manera de distinguir entre el 0 siendo el input o que un error ocurrió), y un string más
	- Se llama a `system` con los contenidos de buffer
	- se devuelve la cadena que recibió como input
### b)
- Sólo detecto dos vulnerabilidades, el cambio a la variable de entorno, causando que se ejecute otro binario al usar system con echo (**Environment variable**)
- Y el hecho de que atoi no reporta errores, y al recibir un input no numérico retorna 0, pero en este caso no es posible verificar si este fue el valor de retorno o si se debe a un error, aunque no me convence que esto califique como vulnerabilidad e fines de este ejercicio
- El otro error que sí es grave es el `printf` que se encuentra en `main`, lo que si el usuario corre el ejecutable con un format string, va a permitirle leer/escribir posiciones del stack (**Format string**)
### c)
- Este me da fiaca ahora, imaginemos que los hice
### d)
- La verdad que acá no sé cual calificaría como más grave, el format string me permite leer/pisar valores en el stack, pero se vuelve bastante difícil lograr ejecución de lo que querramos considerando que tenemos que ser capaces de encontrar dónde está ubicada la irección de retorno, ser capaces de escribir el binario del ejecutable, y después redirigir la dirección de retorno al mismo. 
- Por otro lado, el otro se trata de un simple cambio de una variable de ambiente, la verdad no estaría seguro cual sería más grave

## Ej18
```c
void registrar_ganador(char *nombre_ganador, char *frase) {
	char directorio_ganadores[] = "/tmp";
	char archivo_ganador[256];
	snprintf(archivo_ganador, sizeof(archivo_ganador), "%s/ %s",
	directorio_ganadores, nombre_ganador);
	if(!existe_archivo(archivo_ganador)) {
		char command[512];
		snprintf(command, sizeof command, "echo ’ %s’ > %s",
		frase, archivo_ganador);
		system(command);
	}
}
```
- El código expone tres vulnerabilidades
- Primero, se puede usar como frase un payload apropiado para poder levantar una shell con privilegios, o correr cualquier comando que queramos realmente, por ejemplo `';/bin/sh'` levantaría la terminal que buscamos (notar los '' necesarios porque el código intenta usarlos para evitar code injection)
- Luego, también es potencialmente vulnearable a cambios en la variable de entorno PATH, ya que no usa un path absoluto al ejecutar echo, aunque esto depende de las implementaciones de seguridad que tenga el sistema operativo
- Finalmente, como dice el enunciado, es posible usar race conditions para lograr que, cuando el código chequea la existencia del archivo y falla en encontrarlo, crear un link simbólico con el mismo nombre que linkee a `/etc/passwd`. Con esto, podríamos lograr reemplaar los usuarios del sistema con lo que nosotros querramos, en particular, podríamos reescribir los mismos oara evitar posibbles problemas, pero eliminando la contraseña de root
	- https://en.wikipedia.org/wiki/Symlink_race
	- https://capec.mitre.org/data/definitions/27.html
	- https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152082
### Ej19
```c
void seleccionar_funcion(unsigned int opcion) {
	func (*funciones)[1000] = [ &f1, &f2, ..., &f1000 ];
	int costos[1000] = [10, 100, 10000, 100000, ..., 10000000];
	if (opcion>=1000) { return; };
	usuario *usuario_actual = get_user();
	creditos = usuario_actual->creditos;
	return ejecutar_si_quedan_creditos(&creditos, costos[opcion-1], funciones[opcion-1]);
}
void ejecutar_si_quedan_creditos(int *creditos, int costo, func *f) {
	unsigned int saldo = (*creditos) - costo;
	if (saldo == 0) {
		return; // No tiene crédito.
	}
	// Sí tiene.
	(*f)(); // Se ejecuta f().
	*creditos = saldo; // Se actualiza el saldo.
}
```
- El código presenta dos errores. Por un lado, el chequeo de opción parece ser incorrecta y no permite que el usuario elija la última función (esto se debe a que para accede al arreglo luego se le resta 1 a la opción, y como la opción correspondiente a la última posición del arreglo es la 1000, no podemos accederla)
- Por otro lado, y probablemente de lo que habla el ejercicio, es el tema que al calcular el saldo restanto del usuario, lo estamos guardando en una variable de tipo `unsigned int`, por lo que, si tenemos que el costo era mayor que los créditos del usuario, va a causar un underflow. 
- Esto último tiene 2 consecuencias principales:
	- Por un lado, la guarda del if no verifica correctamente que el usuario tenía créditos suficientes para elegir la opción, por lo que estamos permitiendo la ejecución de la función a alguien sin los créditos necesarios
	- Por otro lado, y probablemente de mayor impacto, es el hecho de que el valor calculado en saldo, que debido al underflow probablemente se encuentre en valores muy altos, es asignado a los créditos del usuario, 
## Ej20
```c
int main(void) {
	cambiarPassword();
	return 0;
}

void cambiarPassword() {
	int numeroDeUsuario = obtenerUsuarioActual ( ) ;
	char password[250];
	char passwordConfirmacion[250];
	printf("Ingrese su password actual");
	fgets (password , 250, stdin ) ;
	if (hash(password) == hashDePasswordActual(numeroDeUsuario)) {
	printf( " Ingrese su nuevo password" );
	fgets(password,250 , stdin );
	printf("Confirme su nuevo password");
	gets(passwordConfirmacion);
	if(sonIguales(password , passwordConfirmacion)) {
	actualizarPassword(numeroDeUsuario, password ) ;
	}
	}
}
```
### a)
- El capo de Bob usa un gets para leer la confirmación de la contraseña del usuario, con esto podemos hacer banda de cosas, entre ellas y probablemente la que más relacionada con el contexto es sobreescribir valor en numeroDeUsuario
- Para lograrlo, escribimos alrededor de 500 caracteres iguales para guardarlos en `password` y `passwordConfirmación`, lo que va a hacer que pasen la guarda del final, y luego ponemos lo que queramos como número de usuario
- Con esto, cualquier usuario tiene la capacidad de usar este ataque para cambiar la contraseña de cualquier otro, incluyendo a root
### b)
- Lo respondí en el a)
### c)
- Puede setear el setuid bit en el ejecutable, y darle el permiso de ejecución a todos los usuarios y grupos
### d)
- Voy a suponer que Alice no es un usuario del sistema, pq si no no entiendo la relevancia con el punto 
- Si las contraseñas no estuviesen hasheadas, tendríamos que tendría accesos a las contraseñas de todos los usuarios de manera directa
- Si las contraseñas estuviesen hasheadas, se podría hacer uso de hash-tables precomputadas, e intentar forzar las contraseñas de esta manera
- Con el uso de salt, esto hace que el approach anterior se vuelva mucho más dificil para Alice. Si bien tiene acceso al valor del salt (ya que suelen ser guardados con los hashes de las contraseñas), el salt hace que sea realísticamente imposible precomputar una tabla con todos los posibles valores debido a cuestiones de espacio, colisiones, cant de aplicaciones de salt, y el hecho de que se suele usar un salt diferente para cada contraseñá. lo que previene a Alice de saber si múltiples usuarios tienen la misma contraseña si llegase a crackear una
## Ej21
### a)
- No estoy seguro de cómo funciona esto, pero parecería que no hay problema pq, si bien tenemos un buffer overflow, el mismo se pasa sólo 4 bytes, lo que solo terminaría escribiendo el valor en a
### b)
- Suponiendo que la optimización sólo eliminace las variables a y b, tendríamos que sería posible escribir la función de retorno de la función
### c)
- Si no me equivoco, sería posible escribir un binario compilado y después tratar de adivinar y escribir en la dirección de retorno la dirección donde se encuentra para lograr que se ejecute. 
