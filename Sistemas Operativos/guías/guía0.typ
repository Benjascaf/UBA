#set enum(numbering: "a)")


#align(center)[= Sistemas Operativos

== Práctica 0: Preliminares
]  

\

=== Parte 1 – Terminal de Linux | Bash Scripting

#rect[El comando `man` muestra el manual de usuario para cualquier comando que se pase como argumento.
Por ejemplo, para ver el manual del comando `ls`:

```bash
$ man ls
```

Escrolear para ver el contenido que se precise, y salir con `q`.
Agregar `-k` para buscar en las páginas del manual del sistema (también conocidas como "man pages")
mediante una palabra clave específica. Ejemplo:

```bash
$ man -k network
```
]
==== Ejercicio 1 (_Comandos de información_)
Utilizar `man` para responder las siguientes preguntas:

- ¿Qué hace el comando `whoami`?
- ¿Qué hace el comando `uname`? ¿Para qué sirve la opción `-a`?
- ¿Qué hace el comando `id`?
- ¿Qué hace el comando `ps`? ¿Para qué sirve la opción `-e`?
- ¿Qué hace el comando `top`? ¿Qué sucede al ejecutar `top -n 10`?

==== Ejercicio 2 (_Inspeccionar archivos y directorios_)

-  Al trabajar en una terminal de Linux, siempre estás trabajando desde un directorio específico, por 
