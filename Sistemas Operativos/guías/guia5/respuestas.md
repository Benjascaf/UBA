## Ej 1
- Es una pieza de software, que es parte del SO, 
## EJ2 
```

semaphore sem;
int init() {
	sem_init(&sem, 1);
	//Esto está bien?
	OUT(CHRONO_CTRL, CHRONO_RESET);
	
	return IO_OK;

}

  

int driver_write(int *data) {
sem_wait(&sem);
OUT(CHRONO_CTRL, CHRONO_RESET);
sem_signal(&sem);

return IO_OK;

}

  

int driver_read(int *data) {
	sem_wait(&sem);
	int tiempo = IN(CHRONO_CURRENT_TIME)
	sem_signal(&sem);
	copy_to_user(data, &tiempo, sizeOf(int));
	return IO_OK;
}
```

## EJ3
```

semaphore sem;
int init() {
	sem_init(&sem, 1);
	return IO_OK;

}


  
int result = BTN_PRESSED
int driver_read(int *data) {
	sem_wait(&sem);
	int state;
	while((state = IN(BTN_STATUS)) && 0x01) == 0) {};
	// ~2 = NOT(00000010) = 11111101
    OUT(BTN_STATUS, state & ~2);
	copy_to_user(data, &result, sizeOf(result));
	sem__signal(&sem);
	return IO_OK;
}
```

### Ej4
```c
semaphore mutex;
semaphore ready;
int waiting = 0;
  
void handler() {

	if (waiting) {
	
		waiting = 0;
		
		sem_signal(&ready);
		
		}
	
}

int driver_init() {

	sem_init(&sem, 1);
	
	sem_init(&ready, 0);
	
	if (request_irq(7, handler) == IRQ_ERROR) return IO_ERROR;
	
	OUT(BTN_STATUS, BTN_INIT)
	
	return IO_OK;

}

  

int driver_remove() {

	free_irq(7);

	return IO_OK;

}

  

int driver_read(int *data) {

	sem_wait(&sem);
	
	waiting = 1;
	
	sem_wait(ready);
	
	copy_to_user(data, &BTN_PRESSED, sizeOf(result));
	
	sem__signal(&sem);
	
	return IO_OK;

}

```

### Ej5
- Queda pendiente, discutir maso y donde puedo encontrar una respuesta exacta
### EJ6
- El nivel de acceso de las mismas debería ser de nivel 0, pues si no tendríamos que el usuario podria escribir y leer directamente desde memoria
### Ej7
#### a)
```c

semaphore mutex;

  

int driver_init() {

sem_init(&mutex, 1);

}

  

int driver_write(int sector, void* data) {

// Primero tenemos que obtener el sector y pista a partir de la dirección LBA

pista, sectorcito;

pista = sector / cantidad_de_sectores_por_pista();

sectorcito = sector % cantidad_sectores_por_pista();

  

void* kdata = kmalloc(sizeof(data));

copy_from_user(kdata, data);

sem_wait(&mutex);

// Prendemos el motor

OUT(DOR_IO, 1);

while(IN(DOR_STATUS == 0)){};

  

// Esperamos por velocidad rotacional

sleep(50);

  

// Mandamos el disco a la pista

OUT(ARM, pista);

// Esperamos a que legue

while(IN(ARM_STATUS) == 0){};

  

OUT(SEEK_SECTOR, sectorcito);

  

escribir_datos(kdata);

  

// Esperamos a que se envié el dato

while (IN(DATA_READY) != 1){};

  
  

// Apagamos el disco y esperamos para asegurarnos que termine de apagarse

OUT(DOR_IO, 0);

sleep(200);

  

sem_signal(&mutex);

  

return IO_OK;

}

  

```



#### b)
```c

semaphore mutex;

semaphore state_sem;

semaphore timer_sem;

int ticks = 0;

int waiting = 0;

int waiting_timer = 0;

  

void disk_state_handler() {

if (waiting) {

waiting = 0;

sem_signal(&state_sem);

}

}

  

void timer_tick_handler() {

  

if (waiting_timer) {

ticks++;

sem_signal(&timer_sem);

}

}

int driver_init() {

sem_init(&mutex, 1);

sem_init(&timer_sem, 0);

sem_init(&state_sem, 0);

request_irq(6, disk_state_handler);

request_irq(7, timer_tick_handler);

return IO_OK;

}

  

int driver_write(int sector, void* data) {

// Primero tenemos que obtener el sector y pista a partir de la dirección LBA

pista, sectorcito;

pista = sector / cantidad_de_sectores_por_pista();

sectorcito = sector % cantidad_sectores_por_pista();

  

void* kdata = kmalloc(sizeof(data));

copy_from_user(kdata, data);

sem_wait(&mutex);

// Prendemos el motor

OUT(DOR_IO, 1);

// Esperamos por velocidad rotacional

waiting_timer = 1;

while (ticks < 1) {

sem_wait(timer_sem);

}

waiting_timer = 0;

ticks = 0;

  

// Mandamos el disco a la pista, seteamos en true para no perdernos la interrupción

waiting = 1;

OUT(ARM, pista);

// Esperamos a que llegue

sem_wait(&state_sem);

waiting = 0;

  

OUT(SEEK_SECTOR, sectorcito);

escribir_datos(kdata);

  

// Esperamos a que se envié el dato

while (IN(DATA_READY) != 1){};

  
  

// Apagamos el disco y esperamos para asegurarnos que termine de apagarse

OUT(DOR_IO, 0);

waiting_timer = 1;

while (ticks < 4) {

sem_wait(timer_sem);

}

waiting_timer = 0;

ticks = 0;

  

sem_signal(&mutex);

  

return IO_OK;

}

  

int driver_remove() {

free_irq(6);

}

  

```

### Ej8 
```c

semaphore mutex;

semaphore printing_sem;

#define INK_CHECKS 5

int checks_left = INK_CHECKS;

  
  

void finished_print_handler() {

sem_signal(&printing_sem);

}

  

int driver_init() {

sem_init(&mutex, 1);

sem_init(&printing_sem, 0);

request_irq(HP_FINISHED_INT, finished_print_handler);

return IO_OK;

}

  

int driver_remove() {

free_irq(HP_FINISHED_INT);

return IO_OK;

}

int driver_write(void* data) {

sem_wait(mutex);

// Acá en realidad debería ser más cuidadoso y calcular bien el tamaño, pero fiaca

OUT(LOC_TEXT_POINTER, data);

OUT(LOC_TEXT_SIZE, strlen(data));

OUT(LOC_CTRL, START);

  

// El enunciado especifica que la impresora va a avisar rápidamente si tiene baja tinta

// Asumo con esto que puedo revisar en este momento el estado de la tinta sin tener que preocuparme acerca de

// que todavía se enquentre lo que escribí

  

// Hago uso de polling acá en vez de interrupciones ya que sé que siempre que lo vaya a buscar voy a tener la información necesaria

// para determinar como seguir, si me tira que queda poca tinta trato de empezar de nuevo

while (IN(LOC_CTRL) == LOW_INK && checks_left > 0) {

checks_left--;

OUT(LOC_CTRL, START);

// Esperamos hasta que que empiece un nuevo intento

while(IN(LOC_CTRL != START)) {};

}

  

if (checks_left == 0) {

checks_left = INK_CHECKS;

sem_signal(&mutex);

return IO_ERROR;

}

checks_left = INK_CHECKS;

  

sem_wait(&printing_sem);

  

sem_singal(&mutex);

  

return IO_OK;

  

}

  

```

### EJ9 
```c
  

// Constantes para acceder a bits necesarios

#define ID 0xC000

#define KEYCODE 0x3FFF

  
  

// Estructuras dadas por enunciado

char input_mem[3][100];

char buffer_lectura[3][1000];

atomic_int buffer_start[3];

atomic_int buffer_end[3];

boolean procesos_activos[3];

  

// funciones auxiliares del enunciado

// Asumí que todas las de write chequean validez de escritura y actualizan tamaño de los buffers pq soy vago

  

int get_buffer_length(int i);

boolean write_to_buffer(int i, char src);

boolean write_to_all_buffers(char src);

char keycode2ascii(int keycode);

void copy_from_buffer(int i, char* dst, int size);

  

// Semáforos para bloquear read sin hacer busy waiting

semaphore mutex;

semaphore blocks[3];

  

// Para determinar si hace falta señalar

int waiting_for[3];

  

// Asumo que hago esto lo uficientemente rápido antes de que me llegue otra interrupción

void keypress_handler() {

int data = IN(KEYB_REG_DATA);

int id = data && ID;

int keycode = data && KEYCODE;

bool write_was_succesful = false;

  

// Asumo que estas funciones son capacaces de usar los valores indicando el tamaño de los buffers para determinar validad del write

// Y además que me actualizan de manera acorde dichos valores

if (id != 0) {

write_was_succesful = write_to_buffer(id, keycode2ascii(keycode));

// Si está bloqueado esperando y esta escritura lleno tamnto como hace falta, señalo semáforo correspondiente

if (waiting[id] != -1) {

if (get_buffer_length(id) >= waiting[id]) {

waiting[id] = -1;

sem_signal(blocks[id]);

}

}

} else {

write_was_succesful= write_to_all_buffers(keycode2ascii(keycode));

// Debería hacer el mismo chequeo pero para todos los procesos, queda pendiente

}

  

write_outcome = write_was_succesful ? READ_OK : READ_FAILED;

  

OUT(KEYB_REG_CONTROL, write_outcome);

}

  

void driver_init() {

// Se corre al cargar el driver al kernel.

request_irq(IRQ_KEYB, keypress_handler);

for (int i = 0; i < 3; i++) {

// Muy vago para escribirlo tres veces

mem_map(input_mem[i], INPUT_MEM(i));

sem_init(&blocks[i]);

}

  

sem_init(&mutex);

  

}

void driver_unload() {

// Se corre al eliminar el driver del kernel.

free_irq(IRQ_KEYB);

for (int i = 0; i < 3; i++) {

// Muy vago para escribirlo tres veces

mem_unmap(input_mem[i]);

}

}

int driver_open() {

// Debe conectar un proceso, asignandole un ID y retornandolo,

// o retornando -1 en caso de falla.

sem_wait(&mutex);

int available_slot = -1;

for (int i = 0; i < 3; i++) {

if (!procesos_activos) available_slot = i;

procesos_activos[i] = true;

}

if (available_slot == -1) return IO_ERROR;

OUT(KEYB_REG__STATUS, APP_UP);

OUT(KEYB_REG_AUX, available_slot + 1);

sem_signal(&mutex);

  
  

return available_slot;

}

void driver_close(int id) {// Debe desconectar un proceso dado por parametro.

procesos_activos[id] = true;

OUT(KEYB_REG__STATUS, APP_DOWN);

OUT(KEYB_REG_AUX, available_slot);

}

int driver_read(int id, char* buffer, int length) {

// Debe leer los bytes solicitados por el proceso ’’id’’

// Hacemos busy waiting hasta q el tamaño sea suficiente

while(get_buffer_length(id) < length) {};

copy_from_buffer(id, buffer, length);

buffer_start[id] += length;

}

int driver_write(char* input, int size, int proceso) {

copy_from_user(input_mem[proceso], input, size);

return size;

}
```