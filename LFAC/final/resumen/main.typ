#import "@preview/ilm:1.2.1": *
#import "@preview/codly:1.0.0": *
#import "@preview/syntree:0.2.0": *
#import "@preview/finite:0.4.1": *
#import "@preview/ctheorems:1.1.3": *
#show: thmrules
#show: codly-init.with()

#let comment = rgb("777777")
#let important = gradient.linear(
  rgb("#0d0887"),
  rgb("#42039d"),
  rgb("#6a00a8"),
  rgb("#900da3"),
  rgb("#b12a90"),
  rgb("#cb4678"),
  rgb("#e16462"),
  rgb("#cb4678"),
  rgb("#b12a90"),
  rgb("#900da3"),
  rgb("#6a00a8"),
  rgb("#42039d"),
  rgb("#0d0887"),
)

#import "@preview/ctheorems:1.1.3": *
#show: thmrules.with(qed-symbol: $square$)

#set page(width: 16cm, height: auto, margin: 1.5cm)
#set heading(numbering: "1.1.")

#let theorem = thmbox("theorem", "Teorema", fill: rgb("#eeffee"))
#let lema = thmbox("theorem", "Lema", fill: rgb("#ffe6e6"))
#let corollary = thmplain(
  "corollary",
  "Corolario",
  base: "theorem",
  titlefmt: strong
)
#let definition = thmbox("definition", "Definición", inset: (x: 1.2em, top: 1em))

#let example = thmplain("example", "Ejemplo").with(numbering: none)
#let proof = thmproof("proof", "Demostración")
#let sequent = $tack.r$
#let sii = $arrow.l.r.double.long$
#let sii2 = $arrow.l.r.double$
#let implica = $arrow.r.double.long$
#let implica2 = $arrow.r.double$
#let implicaVuelta = $arrow.l.double.long$
#let implicaVuelta2 = $arrow.l.double$
#let QED = align(right)[$square$]
#let SigmaEstrella = $Sigma^*$
#let SigmaMás = $Sigma^+$
#let Gramática(NoTerminales, Terminales, Producciones, Start) = $angle.l NoTerminales, Terminales, Producciones, Start angle.r$
#let AF(Estados, AlfabetoEntrada, FunciónTransición, EstadoInicial, Final) = $angle.l Estados, AlfabetoEntrada, FunciónTransición, EstadoInicial, Final angle.r$
#let AP(Estados, AlfabetoEntrada, AlfabetoPila, FunciónTransición, EstadoInicial, ConfiguraciónInicialPila,  Final) = $angle.l Estados, AlfabetoEntrada, FunciónTransición, EstadoInicial, ConfiguraciónInicialPila, Final angle.r$
#let deltaSombrero = $accent(delta, hat)$
#let ComplementoConjunto(Conjunto) = $accent(Conjunto, -)$
#let ClausuraLambda = $C l_lambda$
#let PartesDe = $cal(P)$
#let LenguajeDe = $cal(L)$
#let to = $->$

#set text(lang: "es")

#show: ilm.with(
  title: [Lenguajes Formales, Autómatas y Computabilidad],
  author: "BAS",
  date: datetime.today(),
  date-format: "Fecha de compilación: [day padding:zero] / [month padding:zero] / [year repr:full].",
  abstract: [
    Resumen de la materia Lenguajes Formales, Autómatas y Computabilidad
    dictada en el segundo cuatrimestre de 2024, pensado principalmente para uso personal y orientado a practicar para el final \
  ],
  preface: [
    #align(center + horizon)[ 
      Este resumen esta basado en la bibliografía y clases de la materia dictadas en el segundo cuatrimestre de 2024, así como también clases de cuatrimestres pasados de las materias (*F*) de Teoría de Lenguajes y Lógica y Computabilidad \ 
      
      El template de este resumen es esencialmente el mismo usado por \@valn y como soy un sinvergüenza lo pedí prestado sin avisar. Si quieren usar un resumen como guía de estudio, recomiendo que usen el suyo antes que el mío. \ 
      Link al resumen original: \
      (https://gitlab.com/valn/uba/-/tree/main/Lenguajes%20Formales%2C%20Aut%C3%B3matas%20y%20Computabilidad/Final?ref_type=heads)
    ]
  ],
)

= Lenguajes y Gramáticas
  == Por qué nos interesa la teoría de autómatas?
    Los autómatas finitos son un modelo útil para varios tipos de software y hardware. Por ejemplo:
      - Software para la verificación del comportamiento de circuitos digitales, así como de sistemas con una cantidad finita de estados (protocolos de comunicación, entre otros)
      - Los analizadores léxicos de los compiladores
      - Software para escanear grandes cuerpos de texto

  == Pero entonces, qué son autómatas? (informalmente)
    Antes de discutir la definición formal de estos modelos, consideremos primero como un autómata finito se ve y qué es lo que hace. 
    #align(center)[#automaton((
  off: (on:"Push"),
  on: (off: "Push")),
  final: none)]
  Acá tenemos un autómata que simula un interruptor de encendido / apagado. el dispositivo recuerda si está en estado "prendido" o "apagado", y permite presionar un botón cuyo efecto va a ser diferente dependiendo del estado en el que se encuentre en ese momento (representado por los arcos saliendo de los estados). Notar la etiqueta "Start", la cual indica el estado inicial del autómata  

  Hay muchos sistemas que pueden ser vistos de una manera similar, es decir, que cumplen que en cualquier momento determinado se encuentran en uno de un número finito de estados. El propósito de estos estados es recordar la porción relevante de la historia del sistema, para poder actuar de acuerdo a ésta. 

  Otro ejemplo de un autómata puede ser un analizador léxico. Por ejemplo, un autómata que sólo reconozca la palabra "fuego" podría estar dado por:

  #align(center)[#automaton((
  "": (f:"f"),
  f: (fu: "u"),
  fu: (fue: "e"),
  fue: (fueg: "g"),
  fueg: (fuego: "o"),
  fuego: ()))]

  Como queremos que sea capaz de reconocer la palabra "fuego", el autómata precisa de 5 estados, cada uno representando una posición diferente de la palabra que ya fue alcanzada. Y los arcos representan un input de una letra Notar ahora el uso de un estado con doble círculos, el mismo denota un estado final, un estado especial que determina que el autómata aceptó el input dado    

  == Los Conceptos Centrales de la Teoría de Autómatas
    Ahora vamos a introducir definiciones esenciales para el estudio de autómatas: el *alfabeto*, las *cadenas*, y el *lenguaje*
    === Alfabetos
      #definition[
        Un _alfabeto_ es conjunto finito no vacío de símbolos, que por convención denotamos $Sigma$. 
      ]
      #example[$Sigma = {0, 1}$. El alfabeto binario]
      #example[$Sigma = {a, b, ..., z}$. El alfabeto de todas las letras minúsculas]
  === Cadenas
    #definition[Una _cadena_ (también conocida como palabra) es una secuencia finita de símbolos pertenecientes a un mismo alfabeto]
    #example[La cadena 0110 formada por símbolos pertenecientes al alfabeto binario]
    #definition[Nos referimos con _longitud_ de una cadena a la cantidad de símbolos en la misma, y denotamos la longitud de la cadena w usando |w| ]
  ==== Potencias de un alfabeto
  #definition[Si $Sigma$ es un alfabeto, podemos denotar al conjunto de todas las cadenas pertenecientes al alfabeto de cierto longitud usando notación exponencial. Definimos $Sigma^k$ como el conjunto de cadenas de longitud k, con todos sus símbolos pertenecientes a $Sigma$]

  #example[Para el alfabeto binario, $Sigma^1 = {0, 1}, Sigma^2 = {00, 01, 10, 11}$ ]
  #example[Notar que $Sigma^0 = {lambda}$, sin importar el alfabeto. Es la única cadena de longitud 0]
  #definition[Usamos la notación $SigmaEstrella$ para referirnos al conjunto de todas las cadenas de un alfabeto, y lo denominamos *clausura de Kleene*, y usamos $SigmaMás$ para referirnos a su clausura positiva (es decir, que no incluya la palabra vacía),  se definen como:\ 
  $ SigmaEstrella =  union.big_(i gt.eq 0) Sigma^i $ \ 
  $ SigmaMás =  union.big_(i gt.eq 1) Sigma^i $]

  === Hay tantas palabras como números naturales
  #theorem[$|SigmaEstrella|$ es igual a la cardinalidad de $NN$]
  #definition[Definimos el orden lexicográfico $prec #h(.5em) subset #h(.5em) SigmaEstrella times SigmaEstrella$. Asumimos el orden lexicográfico entre los elementos de un mimso alfabeto, y luego lo extendemos a un orden lexicográfico entre palabras de una misma longitud. De esta manera, las palabras de menor longitud son menores en este sentido que las de mayor longitud]
  #proof[Definimos una biyección $f: NN -> SigmaEstrella$ tal que $f(i) = $ la i-ésima palabra en el orden $prec$ sobre $SigmaEstrella$. Luego, como tenemos una biyección entre los conjuntos $SigmaEstrella$ y $NN$, tenemos que necesariamente deben tener la misma cardinalidad]

  == Lenguajes
    #definition[Un lenguaje $L$ sobre un alfabeto $Sigma$ es un conjunto de palabras pertenecientes a $Sigma$. Es decir, $L subset.eq SigmaEstrella$]
    #example[ 
      - $emptyset$, el lenguaje vacío, es un lenguaje para cualquier alfabeto
      - ${lambda}$, el lenguaje que consiste sólo de la cadena vacía, que también es un lenguaje sobre cualquier alfabeto. (Notar que $emptyset eq.not {lambda}$)
      - El lenguaje de todas las cadenas formadas por n 1s seguidos por n 0s sobre $sigma = {0, 1}.$ Algunas cadenas de este lenguaje son: {$lambda$, 10, 1100, 111000, ...}
    La única restricción importante en cuanto qué puede ser un lenguaje, es que el alfabeto del mismo siempre es finito
  ]
  #definition[Sea A un conjunto, $PartesDe(A)$ es el conjunto de todos los subconjuntos de A,\ $PartesDe(A) = {B subset.eq A}$. Si tenemos que A es un conjunto finito, entonces $PartesDe(A) = 2^(|A|)$]
  #theorem[$|SigmaEstrella| < PartesDe(SigmaEstrella),$ es decir, la cantidad de lenguajes sobre un alfabeto $Sigma$ no es numerable]
  #proof[Supongamos que $PartesDe$($SigmaEstrella$) es numerable, entonces tenemos que podemos enlistar los lengajes y para cada lenguaje $L_i$ (es decir cada lenguaje $subset PartesDe(SigmaEstrella)$ ), podemos ordenar las palabras pertenecientes al mismo según el orden lexicográfico definido anteriormente de la siguiente manera: \
  $L_1$: $w_(1,1), w_(1, 2), w_(1, 3), ...$\
  $L_2$: $w_(2,1), w_(2, 2), w_(2, 3), ...$\
  ... \
  Ahora consideremos el lenguaje $L = {u_1, u_2, u_3, ...}$ tal que, para todo i, se cumpla que $w_(i, i) prec u_i$. Pero entonces tenemos un lenguaje cuyo iésimo elemento de $L$ siempre es "mayor" que el iésimo elemento de $L_i$, entonces no puede ser que $L$ pertenezca a nuestra lista de lenguajes. Pero entonces tenemos un lenguaje sobre $SigmaEstrella$ que no estaba incluido en nuestra ennumeración de todos los lenguajes, por lo que tenemos un absurdo. El mismo vino de suponer que $PartesDe(SigmaEstrella)$ era numerable.]
  == Gramáticas
  #definition[Una gramática es una 4-upla G = $angle.l V_N, V_T, P, S angle.r$ donde: \ 
  - $V_N$ es un conjunto de símbolos llamados no terminales
  - $V_T$ es un conjunto de símbolos terminales
  - $P$ es el conjunto de producciones, que es un conjunto finito de \ #align(center)[$[(V_N union V_T)^* #h(.5em) V_N #h(.5em) (V_N union V_T)^*] times (V_N union V_T)^*$] \ 
    donde las producciones son tuplas $(a, b)$ y usualmente las notamos $a -> b$
  - S es el símbolo distinguido o inicial de $V_N$]
  #example[ Sea $G_("arithm") = angle.l V_N, V_T, P, S angle.r$ una  gramática libre de contexto (esto último lo introducimos más tarde) tal que: \ 
  - $V_N = {S}$
  - $V_T = {+, *, a, (,)}$
  - Y producciones determinadas por: \ 
    $S -> S + S$, \
    $S -> S * S$, \
    $S -> a$, \
    $S -> (S)$]

    === Lenguaje generado por una gramática
    #definition[Dada una gramática G = $angle.l V_N, V_T, P, S angle.r$, definimos a $LenguajeDe(G)$ como: \
    #align(center)[$LenguajeDe(G) = {w #h(.5em) in V_T^*: S =>^+_G w}$] \ 
    donde $=>^+_G$ es la derivación en uno o más pasos, que se obtiene de la clausura transitiva de $=>_G$ (la derivación directa, cuya definición se da en un momento)]
    === Forma sentencial de una gramática
    #definition[Sea G  $= angle.l V_N, V_T, P, S angle.r$. \ 
    - S es una forma sentencia de G
    - Si $alpha beta gamma$ es una forma sentencial de G, y tenemos que ($beta -> delta$) $in P$, entonces $alpha delta gamma$ es también una forma sentencial de G \ 
    Las formas sentenciales pertenecen a $(V_N union V_T)^*$]
    === Derivación directa de una gramática
    #definition[Si $alpha beta gamma in (V_N union V_T)^*$ y $(beta -> delta) in P$, entonces $alpha beta gamma$ deriva directamente en G a $alpha delta gamma$ y lo denotamos: \ 
    #align(center)[$alpha beta gamma =>_G alpha delta gamma$] \
    Observemos que como la derivación directa es una relación sobre $(V_N union V_T)$, podemos componerla consigo misma 0 o más veces: \
    
    
    - $(=>_G)^0 = id_((V_N union V_T)^*)$ 

    - $(=>_G)^+ = union.big_(k = 1)^oo  (=>_G)^k $
  
    - $(=>_G)^* = (=>_G)^+ union id_((V_N union V_T)^*)$
    \ 
  Según como elijamos derivar, podemos considerar:
  - Derivación más a la izquierda: $=>_L$
  - Derivación más a la derecha: $=>_R$
  Así como también sus derivaciones en uno o más pasos, y sus calusuras transitivas y de Kleene]
  === La Jerarquía de Chomsky
  #definition[La jerarquía de Chomsky clasifica las gramáticas en 4 tipos en una jerarquía tal que puedan generar lenguajes cada vez más complejos, y donde cada uno de las gramáticas puede generar también los lenguajes de una de complejidad inferior. Las clasificaciones son: \
  
  - *Gramáticas de tipo 0 (o sin restricciones)*: \ 
    $alpha -> beta$ \
    
  - *Gramáticas de tipo 1 (o sensibles al contexto)*: \ 
  $alpha -> beta$, con $|alpha| lt.eq |beta|$ \ 
  
  - *Gramáticas de tipo 2 (o libres de contexto)*: \
  A $-> gamma$ con A $in V_N$ \ 
  
  - *Gramáticas de tipo 3 (o regulares)*: \
  $A -> a, A -> a B, A -> lambda$, con $A,B in V_N, a in V_T$ \ 
  
  La jerarquía de grmáticas da origen también a la jerarquía de lenguajes: \
  - *Recursivamente enumerables* \ 
  
  - *Sensitivos al contexto* \

  - *Libres de contexto* \
  
  - *Regulares*
  #align(center)[#figure(
  image("Chomsky.svg"),
  caption: [
    Imagen perteneciente al repo de \@Valn (No sé que haces acá todavía a ser honesto).
  ],
)]
  ]
=== Árbol de derivación de gramáticas 
#definition[Un árbol de derivación es una representación gráfica de una derivación (look at me I'm so smart) donde: \ 
- Las etiquetas de las hojas están en $V_T union {lambda}$ \ 
- Las etiquetas de los nodos internos están en $V_N$. Las etiquetas de sus símbolos son los símbolos del cuerpo de una producción
- Un nodo tiene etiqueta A y tiene n descendientes etiquetados $X_1,X_2, ...,X_N$ sii hay una derivación que usa una producción $A -> X_1X_2...X_N$]
#example[Considerande la gramática $G_("arithm")$ definida anteriormente, un posible árbol de derivación podría ser el siguiente: \ 
#align(center)[
      #syntree(
        terminal: (weight: "bold"),
        child-spacing: 4em, // default 1em
        layer-spacing: 2em, // default 2.3em
          "[S ( [S [S a] + [S a]] )]"
      )
      #text(size: 9.9pt)[$S =>_L (S) =>_L (S + S) =>_L (a + S) =>_L (a + S) =>_L (a + a)$]
    ]
]
=== Algunos lemas relevantes
#lema[Sea $G = angle.l V_N, V_T, P, S angle.r$ regular, no recursiva a izquierda. Si $A =>_L^i w B$ entonces \ $i = |w|$]
#proof[Consideremos el árbol de derivación de la cadena w = $a_1a_2a_3...a_n$. Si entonces cortamos el árbol en una altura h determinada, para $h gt.eq 1$ se obtiene un subarbol de h hojas, con el único nodo que no es hoja con una etiqueta de $V_N$. Por la forma que las producciones de una gramática regular tiene, tenemos que cada derivación pone un símbolo no terminal a lo sumo y uno terminal , luego, tenemos que en n derivaciones (altura n del árbol) tenemos n hojas y el no terminal de la derecha]

#align(center)[
      #syntree(
        terminal: (weight: "bold"),
        child-spacing: 1.6em, // default 1em
        layer-spacing: 2em, // default 2.3em
        "[S a [A a [B a [A a]]]]"
      )
      #align(center)[Un posible árbol de derivación para las producciones: \ ]
      $S to a A | lambda$ \
      $A to a | a B$ \
      $B to a A$ \
    ]
#lema[Sea G = $angle.l V_N, V_T, P, S angle.r $ libre de contexto, no recursiva a izquierda (es decir, no tiene derivaciones $A =>_L^+A alpha$). Existe una constante c tal que si $A =>_L^i omega B alpha$ entonces $i lt.eq c^(|omega| + 2)$]
#proof[Pendiente (soy *_vago_*)]
= Autómatas Finitos Determinísticos, no Determinísticos, y Gramáticas Regulares
  == Autómata Finito Determinístico (AFD)
    #definition[Un autómata finito determinístico es una 5-upla $angle.l Q, Sigma, delta, q_0, F angle.r$ donde:
    - $Q$ es un conjunto finito de estados
    - $Sigma$ es el alfabeto de entrada del autómata
    - $delta$ es la función de trancición del autómata que toma como argumentos un estado y un símbolo de input, y devuelve un estado, es decir: $delta: Q times Sigma -> Q$. 
    - $q_0 in Q$ es el estado inicial del autómata
    - $F subset.eq Q$ es el conjunto de estados finales del autómata
  Para determinar si un autómata acepta cierta cadena, se hace uso de su función de transición y se confirma si se termina llegando a un estado $q_f in F$ final. Es decir, suponiendo que se busca. Como es poco práctico escribir la función $delta$ en su totalidad, se suele hacer uso de diagramas de autómatas (como el usado al principio de este resumen) y se aceptan los arcos del mismo como una definición implícita.]
  #example[En nuestro primer autómata, teníamos (notar que "Push" es sólo un símbolo, no una cadena / palabra)\ 
  
  #align(center)[#automaton((
  off: (on:"Push"),
  on: (off: "Push")),
  final: none)]
  Luego, la 5-upla correspondiente sería $angle.l {"off", "on"}, {"Push"}, delta, "off", emptyset}$ con $delta$ definido por: \
  $delta("off", "Push") = "on"$ \ 
  $delta("on", "Push") = "off"$]
  === Función de transición generalizada $deltaSombrero$
  Ahora necesitamos definir precisamente qué ocurre cuando estamos en un estado determinado y recibimos como input una cadena, no un símbolo. Para esto, lo definimos por inducción en el largo de la cadena
  #definition[Definimos $deltaSombrero$ como: \
  - $deltaSombrero(q, lambda) = q$
  - $deltaSombrero(q, omega alpha) = delta(deltaSombrero(q, omega), alpha)$ con $omega in SigmaEstrella y alpha in Sigma$
  Cabe recalcar que $deltaSombrero(q, alpha) = delta(deltaSombrero(q, lambda), alpha) = delta(q, alpha)$ y que muchas veces vamos a hacer uso de la misma notación para ambas funciones]
  === El Lenguaje de un AFD
  #definition[Ahora podemos definir el lenguaje aceptado por un AFD como: \ 
  #align(center)[$LenguajeDe(M) = {omega in SigmaEstrella : deltaSombrero(q_0, omega) in F }$] 
  Es decir, el lenguaje de un autómata M es el conjunto de cadenas que mediante $deltaSombrero$ llegan desde el estado inicial $q_0$ a un estado final. Llamamos *lenguajes regulares* a aquellos aceptados por un AFD]
  == Autómatas Finitos no Determinísticos (AFND)
  #definition[Un AFND es una 5-upla $angle.l Q, Sigma, delta, q_0, F angle.r$ donde: \ 
  - Q es un conjunto finito de estados
  - $Sigma$ es el alfabeto de entrada
  - $delta$ es la función de trancición, que toma un estado en Q y un símbolo en $Sigma$, pero que ahora devuelve un subconjunto de Q. Es decir: \ 
    #align(center)[$delta: Q times Sigma -> PartesDe(Q)$]
  - $q_0 in Q$ es el estado inicial
  - $F subset.eq Q$ es el conjunto de estados finales]
  === Función de trancisión generalizada $deltaSombrero$
    #definition[Definimos $deltaSombrero: Q times Sigma^* -> PartesDe(Q): $ \ 
    - $deltaSombrero(q, lambda) = {q}$
    
    - $deltaSombrero(q, x alpha) = {p in Q : exists r in deltaSombrero(q, x) #h(.5em) y #h(.5em) p in delta(r, a)}$

    - Una definición alternativa, siendo $w = x a$, con $w, x in SigmaEstrella y #h(.5em) a in Sigma$ y suponiendo que $deltaSombrero(q, x) = {p_1, ..., p_k}$. Sea
        
        $union.big_(i=1)^k delta(p_i, a) = {r_1, ..., r_k}$
      
        Entonces tenemos
        $deltaSombrero(q, w) = {r_1, ..., r_k}$
    
    \
    
  Notar que: \ 
  
  $deltaSombrero(q, lambda alpha) = {p in Q : exists r in deltaSombrero(q, lambda) #h(.5em) y #h(.5em) p in delta(r, a)} \ #h(3.7em) = {p in Q : exists r in {q} #h(.5em) y #h(.5em) p in delta(r, a)} \ #h(3.7em) = {p in Q : p in delta(q, a)} \ #h(3.7em) = delta(q, a)$]

  === Lenguaje aceptado por un AFND
    #definition[El lenguaje aceptado por un AFND M, $LenguajeDe(M)$, es el conjunto de cadenas aceptadas por M y está definido como:  \ 
    #align(center)[$LenguajeDe(M) = {x in SigmaEstrella : deltaSombrero(q_0, x) sect F eq.not emptyset}$]]
 === Función de transición de conjuntos de estados
  #definition[Podemos extender la función de transición aún más, haciendo que mapee
conjuntos de estados y cadenas en conjuntos de estados. Sea entonces $delta: PartesDe(Q) times SigmaEstrella -> PartesDe(Q)$ dada por: \ 
#align(center)[$delta(P, x) = union.big_(q in P) deltaSombrero(q, x)$]]

== Equivalencia Entre AFND y AFD 
  #theorem[Dado un AFND $N = angle.l Q_N, Sigma, delta_N, q_0, F_N angle.r$, existe un AFD \ $D = angle.l Q_D, Sigma, delta_D, {q_0}, F_D angle.r$ tal que $LenguajeDe(N) = LenguajeDe(D)$]
  #proof[La demostración comienza mediante una construcción llamada _construcción de subconjunto_, llamada así porque construye un autómata a partir de subconjuntos del conjunto de estados de otro (es decir, subconjuntos de $PartesDe(Q)$). \ 
  Dado el autómata N AFND, construimos al autómata D de la siguiente manera: \
  
  - $Q_D$ es el conjunto de subconjuntos de $Q_N$ (es decir, $PartesDe(Q_N)$). Notar que si $Q_N$ tenía n estados, $Q_D$ va a tener $2^n$ estados (ouch)
  - $F_D$ es el conjunto de subconjuntos $S$ de $Q_N$ tal que $S sect F_N eq.not emptyset$
  - Para cada S $subset.eq Q_N$ y símbolo $alpha in Sigma$:  \
    #align(center)[$delta_D (S, a) = union.big_(p #h(.3em) in #h(.3em) S) delta_N (p, a)$] \ 
  Ahora, probamos primero por inducción sobre |$omega$| que vale: \ 
  #align(center)[$deltaSombrero_D ({q_0}, omega) = deltaSombrero_N (q_0, omega)$] \ 
  Notar que ambas $deltaSombrero$ devuelven un conjunto de estados de $Q_N$, pero para nuestro AFD D el resultado es interpretado como un estado, mientras que en el AFND N se trata de un subconjunto de estados de $Q_N$. \ 
  
  - Caso Base: |$omega$| = 0 (O sea, $omega = lambda$) \ 
    Por la definición de ambos $deltaSombrero$ tenemos que ambos son ${q_0}$
    
  - Paso Inductivo:  Sea $omega$ delongitud n + 1 y asumiendo que la H.I vale para n. Separamos $omega$ = $x alpha$, donde $alpha$ es el último símbolo de $omega$. Por la H.I, tenemos que $deltaSombrero_D ({q_0}, x) = deltaSombrero_N (q_0, x) = {p_1, ..., p_k}$. conjuntos de estados $in Q_N$. \ 
  Recordando la definición de AFND teníamos que: \ 
  #align(center)[$deltaSombrero_N (q_0, omega) = union.big^k_(i=1) delta_N (p_i, alpha)$] \
  
  Por otro lado, al construir el AFD definimos que: \ 
  #align(center)[$delta_D ({p_1, p_2, ..., p_k}, alpha) = union.big_(i=1)^k delta_N (p_i, alpha)$] \ 
  
  Con esto en mente, podemos resolver: \
  #align(center)[$deltaSombrero_D ({q_0}, omega) = delta_D (deltaSombrero_D ({q_0}, x), alpha) =_(H I) delta_D ({p_1, ..., p_k}, alpha) = union.big_(i=1)^k delta_N (p_i, alpha) = deltaSombrero_N (q_0, omega)$] \ 
  Sabiendo ahora que ambas funciones de transición son \"equivalentes\" y que ambas aceptan una cadena sii el conjunto resultante contiene un estado final, tenemos que $LenguajeDe(N) = LenguajeDe(D)$]

#let tupla = $angle.l Q, Sigma, delta, q_0, F angle.r$
#let cl = $C l_lambda $

  == AFND con transiciones $lambda #h(.5em) (A F N D - lambda)$
  #definition[Un AFND-$lambda$ es una 5-upla #tupla donde todos los componentes tienen la misma interpretación que antes con la excepción de que $delta$ ahora tiene su dominio definido como: \ 
  #align(center)[$delta: Q times (Sigma union {lambda}) -> PartesDe(Q)$] 
  ]
  #definition[Definimos como *clausura $lambda$* de un estado q, denotado $cl(q)$, al conjunto de estados alcanzables desde q mediante transiciones $lambda$. Es decir, sea R $subset.eq Q times Q$ tal que (q, p) $in R sii p in delta(q, lambda)$. Definimos $cl: Q -> PartesDe(Q)$ como: \ 
  #align(center)[$cl(q) = {p: (q, p) in R^*}$]]

  #definition[Podemos también extender la definición para un conjunto de estados P: \ 
  #align(center)[$cl(P) = union.big_(q in P) cl(q)$]]

  #definition[La función de trancisión $delta$ puede extenderse para acept                                                                                                                                                                                                                                                          ar cadenas en $Sigma$, es decir, $deltaSombrero: Q times SigmaEstrella -> P(Q)$, y la definimos de la siguiente manera: \ 
  \ 
  
  #align(center)[
    - $deltaSombrero(q, lambda) = cl(q)$.
    \ 
    
    - $deltaSombrero(q, x alpha) = cl({p : exists r in deltaSombrero(q, x) : p in delta(r, alpha)})$ con x $in SigmaEstrella$ y $alpha in Sigma$ o, lo que es equivalente \
    $deltaSombrero(q, x alpha) = cl(union.big_(r in deltaSombrero(q, x)) delta(r, alpha))$
  ] \ 
  Extendiendo la definición a conjunto de estados, tenemos que: \ 
  
  #align(center)[
    - $delta(P, alpha) = union.big_(q in P) delta(q, alpha)$
    
    - $deltaSombrero(P, x) = union.big_(q in P) deltaSombrero(q, x)$
  ] \
  Lo que nos permite reescribir $deltaSombrero(q, x alpha)$ como: 
  #align(center)[
    $deltaSombrero(q, x alpha)$ = $cl(delta(deltaSombrero(q, x), alpha))$
  ]
]

#definition[Definimos al lenguaje aceptado por un AFND-$lambda$ E: \
#align(center)[$LenguajeDe(E) = {w | deltaSombrero(q_0, w) sect F eq.not emptyset}$]]

#theorem[Dado un AFND-$lambda$ E = $angle.l Q, Sigma, delta_lambda, q_0, F_lambda angle.r$ puede encontrarse un AFND \ N = $angle.l Q, Sigma, delta_N, q_0, F_N angle.r$ que reconoce el mismo lenguaje]
#proof[Tomemos \ \

#align(center)[$F_N = cases(F_lambda #h(.5em) union #h(.5em) {q_0} "si " cl(q_0) #h(.5em) sect #h(.5em) F_lambda #h(.5em) eq.not #h(.5em) emptyset, F_lambda "si no")$] \ 
Y tomemos $deltaSombrero_N (q, alpha) = deltaSombrero_lambda (q, alpha)$. Para empezar, vamos a probar que $deltaSombrero_N (q, x) = deltaSombrero_lambda (q, x)$\  para $|x| gt.eq 1.$ Lo hacemos por inducción:

- Para |x| = 1: \ 
  $x = alpha$, es decir, un símbolo del alfabeto, por lo que se cumple por definición
- Para |x| $gt$: \ 
  Tomemos $x = omega alpha$ entonces: \
  
    #align(center)[$deltaSombrero_N (q_0, omega alpha) = deltaSombrero_N (deltaSombrero_N (q_0, omega), alpha) =_(H. I) deltaSombrero_N (deltaSombrero_lambda (q_0, omega), alpha)$] \ 

  Por otro lado, tenemos que para $P subset.eq Q$ es cierto que $deltaSombrero_N (P, alpha) = deltaSombrero_lambda (P, alpha)$ ya que: \
  
  #align(center)[$deltaSombrero_N (P, alpha) = union.big_(q in P) deltaSombrero_N (q, alpha) = union.big_(q in P) deltaSombrero_lambda (q, alpha) = deltaSombrero_lambda (P, alpha)$] 

  Luego, con $P = deltaSombrero_lambda (q_0, omega)$ tenemos que ambas funciones de transición son \"equivalentes\" pues: \ 
  #align(center)[$deltaSombrero_N (q_0, omega) = deltaSombrero_N (deltaSombrero_lambda (q_0, omega), alpha) = deltaSombrero_lambda (deltaSombrero_lambda (q_0, omega), alpha) = deltaSombrero_lambda (q_0, omega alpha)$]

  Ahora queda ver que $LenguajeDe(N) = LenguajeDe(E).$ Para $x = lambda$ tenemos
  
  
  #align(center)[ - $lambda in LenguajeDe(E) sii deltaSombrero_lambda (q_0, lambda) sect F_lambda eq.not emptyset sii_(deltaSombrero_lambda (q_0, lambda) = cl(q_0)) cl(q_0) sect F_lambda eq.not emptyset \ 
  implica q_0 in F_N sii lambda in LenguajeDe(N)$ 
]\
  #align(center)[ - $lambda in LenguajeDe(N) sii q_0 in F_N implica q_0 in F_lambda or cl(q_0) sect F_lambda eq.not emptyset sii \ cl(q_0) sect F_lambda eq.not emptyset or lambda in LenguajeDe(E) sii lambda in LenguajeDe(E) or lambda in LenguajeDe(E) sii lambda in LenguajeDe(E)$]
  \ 
  Para |x| $eq.not lambda$:
  
  \
  #align(center)[- $x in LenguajeDe(E) sii_("def cadena aceptada" \ "AFND-"lambda) deltaSombrero_lambda (q_0, x) sect F_lambda eq.not emptyset implica_("porque " F_lambda subset F_N \ deltaSombrero_lambda (q_0, x) = deltaSombrero_N (q_0, x)) \  deltaSombrero_N (q_0, x) sect F_N eq.not emptyset implica x in LenguajeDe(N)$]

  Por el otro lado:
    #align(center)[
      - $x in LenguajeDe(N) sii deltaSombrero_N (q_0, x) sect F_N eq.not emptyset \ implica deltaSombrero_lambda (q_0, x) sect F_lambda eq.not emptyset or (deltaSombrero_lambda (q_0, x) sect {q_0} eq.not emptyset and cl(q_0) sect F_lambda eq.not emptyset)$ 
      \ 
      
      - Del lado izquierdo de la disyunción tenemos: \ 
         $deltaSombrero_lambda (q_0, x) sect F_lambda eq.not emptyset implica x in LenguajeDe(E)$
          
          \ 
          
      - Del lado derecho tenemos que:
        \ 
        
        - $deltaSombrero_lambda (q_0, x) sect {q_0} eq.not emptyset implica "existe un loop x de" q_0 "sobre sí mismo"$ 
        \

        - $cl(q_0) sect F_lambda eq.not emptyset implica $ existe un camino $lambda$ desde $q_0$ hasta $F_lambda$, \ por lo que existe un camino x desde $q_0$ hasta $F_lambda$

        \

      - Juntando los dos, tenemos que:
              
        $(deltaSombrero_lambda (q_0, x) sect {q_0} eq.not emptyset and cl(q_0) sect F_lambda eq.not emptyset) implica x in LenguajeDe(E)$
        
        
    ]

    Finalmente, podemos concluir que: 
    \ 
    
      #align(center)[$x in LenguajeDe(E) sii x in LenguajeDe(N)$]
]
== Gramáticas regulares y AFDs
Recordemos que una gramática G = #Gramática($V_N$, $V_T$,$P$, $S$) es regular si todas sus producciones son de la forma $A -> lambda, $ $A -> a$ o $A -> a B$

#theorem[Dada una gramática regular G = #Gramática($V_N$, $V_T$,$P$, $S$), existe un AFND $N = angle.l Q, Sigma, delta, q_0, F angle.r$ tal que $LenguajeDe(G) = LenguajeDe(M)$]

#proof[Definamos N de la siguiente manera: 
- $Q = V_N union {q_f}.$ A partir de ahora, usamos $q_A$ para referirnos al estado correspondiente al no terminal A

- $Sigma = V_T$

- $q_0 = q_S$

- $q_B in delta (q_A, a) sii A -> a B in P$

- $q_f in delta (q_A, a) sii A -> a in P$

- $q_A in F sii A -> lambda in P$
- $q_f in F$

Como paso intermedio, ahora probamos el siguiente lema:

#lema[Para todo $omega in V_T^*,$ si $A ->^* omega B$ entonces $q_B in deltaSombrero (q_A, omega)$]

#proof[Por inducción en la longitud de $omega$ 

\

- Caso base |$omega| = 0$, ($omega = lambda$) 
\ 
  Como $A ->^* A$ y $q_a in deltaSombrero(q_A, lambda)$ tenemos por definición de N que $A ->^* A sii q_a in deltaSombrero(q_A, lambda)$
  
\
- Caso $|omega| = n + 1, n gt.eq 0$, con, $omega = x alpha$:

\
  #align(center)[$A ->^* x alpha B sii exists C in V_N : A ->^* x C and C -> alpha B in P \ 
  #h(4.57em)implica_(H I) exists q_C in Q : q_C in deltaSombrero(q_A, x) and q_B in delta(q_C, a) \
  #h(4.57em) sii q_B in delta(deltaSombrero(q_A, x), a) \
  #h(4.57em) sii q_B in deltaSombrero(q_A, x alpha)
  $]
]

\
Volviendo ahora con el teorema, \ 

#align(center)[
  $omega alpha in LenguajeDe(G) sii_("def lenguaje generado" \ "por una gramática") S ->^* omega alpha \ 
  #h(1.5em)sii (exists A in V_N, S ->^* omega A and A -> alpha in P) or (exists B in V_N, S ->^* omega alpha B and B -> lambda) \ 
  sii (exists A in V_N, S ->^* omega A and q_f in delta(q_A, alpha)) or (exists B in V_N, S ->^* omega alpha B and q_B in F) \
  implica_("por lema") (exists q_A in Q: q_A in deltaSombrero(q_S, omega) and q_f in delta(q_A, alpha)) or (exists q_B in Q: q_B in deltaSombrero(q_S, omega alpha) and q_B in F) \ 
  sii (q_f in deltaSombrero(q_S, omega alpha)) or (deltaSombrero(q_S, omega alpha) sect F eq.not emptyset)\
  sii(deltaSombrero(q_S, omega alpha) sect F eq.not emptyset) or (deltaSombrero(q_S, omega alpha) sect F eq.not emptyset) \ 
  sii (deltaSombrero(q_S, omega alpha) sect F eq.not emptyset) \ 
  sii omega alpha in LenguajeDe(N)$
]
Luego, queda demostrado que $LenguajeDe(G) = LenguajeDe(N)$
]


#theorem[Dado un AFD $M = tupla$ existe una gramática regular \  $G = angle.l V_N, V_T, P, S angle.r$ tal que $LenguajeDe(M) = LenguajeDe(G)$]

#proof[Para comenzar definimos una gramática $G = angle.l V_N, V_T, P, S angle.r$, donde $V_N = Q$ y llamaremos $A_p$ al no terminal correspondiente a p $in Q; S = A_(q_0); V_T = Sigma$ y el conjunto P es: 

\

#align(center)[$A_p -> a A_q in P sii delta(p, a) = q$ \ 
              $A_p -> a in P sii delta(p, a) = q in F$ \ 
              $S -> lambda in P sii q_0 in F$]
            
Ahora vamos a probar el siguiente lema como paso intermedio:
#lema[$delta(p, omega) = q sii A_p ->^* omega A_q$]

Lo probamos por induccion en la longitud de $omega$: 

\

Para $omega = lambda$ tenemos que $delta(p, lambda) = p $ y que $A_p ->^* A_p$, por lo que $delta(p, lambda) = p sii A_p ->^* A_p$

\

Veamos que vale ahora para $omega = x alpha$:

#align(center)[$delta(p, x alpha) = q sii exists r in Q, deltaSombrero(p, x) = r and delta(r, alpha) = q \ 
sii_(H I) exists A_r, A_p ->^* x A_r and A_r -> alpha A_q in P \ sii A_P ->^* x alpha A_q$]

Luego, probamos el lema. Volviendo ahora a la demo del teorema: 

\ 

#align(center)[
  $lambda in LenguajeDe(M) &sii q_0 in F \
  &sii (S to lambda) in P \
  &sii S =>^* lambda \
  &sii lambda in LenguajeDe(G).$
]

Caso cadena no vacía: \
#align(center)[
  $w a in LenguajeDe(M) &sii delta(q_0, w a) in F \
  &sii exists p in Q : delta(q_0, w) = p and delta(p, a) in F \
  &sii_("Lema") exists A_p in V_N : A_(q_0) =>^* w A_p and (A_p to a) in P \
  &sii A_(q_0) =>^* w a \
  &sii w a in LenguajeDe(G).$
]

Con esto queda demostrado que $LenguajeDe(M) = LenguajeDe(G)$. \ 
]

    



= Expresiones Regulares
  #definition[Una expresión regular es una cadena de símbolos de un alfabeto que denotan un lenguaje sobre el alfabeto. Las expresiones regulares se construyen a partir de los siguientes elementos: \

  - $nothing$ es una expresión regular que representa el lenguaje vacío $emptyset$
  - $lambda$ es una expresión regular que representa el lenguaje que contiene sólo la cadena vacía ${lambda}$
  - $a$ es una expresión regular que representa el lenguaje que contiene la cadena $a$ para cada $a in Sigma$ (${a}$)
  - Si $r$ y $s$ son expresiones regulares que denotan los lenguajes R y S, entonces:
    - $(r + s)= (r | s)$ es una expresión regular que representa la unión de los lenguajes R y S.
    - $(r s)$ es una expresión regular que representa la concatenación de los lenguajes R y S.
    - $(r^*)$ es una expresión regular que representa la clausura de Kleene del lenguaje representado por $r$.
    - $r^+$ representa la clausura positiva del lenguaje representado por $r$.
  ]
  #example[Algunos ejemplos de expresiones regulares son: \
  - $a + b$ representa el lenguaje que contiene las cadenas $a$ y $b$
  - $a^* b$ representa el lenguaje que contiene las cadenas que comienzan con una cantidad arbitraria de $a$ seguida de una $b$
  - $(a + b)^*$ representa el lenguaje que contiene todas las cadenas que contienen únicamente $a$ y $b$]
  #theorem[Dada una expresión regular $r$, existe un AFND-$lambda$ con un solo estado final y sin transiciones a partir del mismo $E = angle.l Q, Sigma, delta, q_0, F angle.r$ tal que $LenguajeDe(r) = LenguajeDe(E)$] 

  #proof[Por inducción sobre la estructura de la expresión regular r: \

  - Caso base: $r = emptyset$ \
    #align(center)[
      #automaton((
  q0: (), qf:(),))
]


  - Caso base: $r = lambda$ \
   #align(center)[
      #automaton((
  q0: ()))
]

  - Caso base: $r = a$ \  
    #align(center)[
      #automaton((
  q0: (qf: "a"), qf:(),))
]

  - Caso inductivo: $r = r_1 + r_2$ 
    Por H.I, existen $M_1 = AF(Q_1, Sigma_1, delta_1, q_1, {f_1})$ y $M_2 = AF(Q_2, Sigma_2, delta_2, q_2, {f_2})$ tales que $LenguajeDe(M_1) = LenguajeDe(r_1)$ y $LenguajeDe(M_2) = LenguajeDe(r_2)$. Sea $M = AF(Q_1 union Q_2 union {q_0, q_f}, Sigma_1 union Sigma_2, delta, q_0, {q_f})$: 



#align(center)[
  #cetz.canvas({
    import cetz.draw: circle, line, content
    import draw: state, transition

    state((0, 0), "q0", label: $q_0$, initial: "")


    circle((6,2), name: "M1", radius: (3.2, 1.6), stroke: black, fill: auto)
    content((rel: (-2.5, 1.5), to: "M1"), text($M_1$))
    state((4, 2), "q1", label: $q_1$)
    state((8, 2), "f1", label: $f_1$)

    circle((6,-2), name: "M2", radius: (3.2, 1.6), stroke: black, fill: auto)
    content((rel: (-2.5, 1.5), to: "M2"), text($M_2$))
    state((4, -2), "q2", label: $q_2$)
    state((8, -2), "f2", label: $f_2$)

    state((12, 0), "qf", label: $q_f$, final:true)

    transition("q0", "q1", label: $lambda$, curve: 1)
    transition("q0", "q2", label: $lambda$, curve: -1)

    transition("f1", "qf", label: $lambda$, curve: 1)
    transition("f2", "qf", label: $lambda$, curve: -1)
  })
]

    - $delta(q_0, lambda) = {q_1, q_2}$.
    - $delta(q, a) = delta_1(q, a)$ para $q in Q_1 - {f_1}$ y $a in Sigma_1 union {lambda}$.
    - $delta(q, a) = delta_2(q, a)$ para $q in Q_2 - {f_2}$ y $a in Sigma_2 union {lambda}$.
    - $delta(f_1, lambda) = delta(f_2, lambda) = {q_f}$.

De manera informal, podemos alcanzar, a partir del nuevo estado inicial, cualquiera de los estados iniciales correspondientes a los autómatas para $r_1$ y $r_2$ mediante transiciones $lambda$. Luego, podemos seguir las transiciones de los autómatas hasta llegar a sus estados previamente finales correspondientes, y luego tomar una úlima transición $lambda$ al nuevo estado final.

  - Caso inductivo: $r = r_1 r_2$ \
    Por HI existen $M_1 = AF(Q_1, Sigma_1, delta_1, q_1, {f_1})$ y $M_2 = AF(Q_2, Sigma_2, delta_2, q_2, {f_2})$ tales que $LenguajeDe(M_1) = LenguajeDe(r_1)$ y $LenguajeDe(M_2) = LenguajeDe(r_2)$. \
   Entones sea $M = AF(Q_1 union Q_2, Sigma_1 union Sigma_2, delta, q_1, {f_2})$: \

    #align(center)[
      #cetz.canvas({
        import cetz.draw: circle, line, content
        import draw: state, transition

        circle((2,0), name: "M1", radius: (3.2, 1.6), stroke: black, fill: auto)
        content((rel: (-2.5, 1.5), to: "M1"), text($M_1$))
        state((0.3, 0), "q1", label: $q_1$, initial: "")
        state((4, 0), "f1", label: $f_1$)

        circle((10,0), name: "M2", radius: (3.2, 1.6), stroke: black, fill: auto)
        content((rel: (-2.5, 1.5), to: "M2"), text($M_2$))
        state((8, 0), "q2", label: $q_2$)
        state((12, 0), "f2", label: $f_2$, final: true)

        transition("f1", "q2", label: $lambda$, curve: 0.5)
      })
    ]

    - $delta(q, a) = delta_1(q, a)$ para $q in Q_1 - {f_1}$ y $a in Sigma_1 union {lambda}$.
    - $delta(f_1, lambda) = {q_2}$.
    - $delta(q, a) = delta_2(q, a)$ para $q in Q_2 - {f_2}$ y $a in Sigma_2 union {lambda}$. \


  - Caso inductivo: $r = r_1^*$ \
    Por HI existe $M_1 = AF(Q_1, Sigma_1, delta_1, q_1, {f_1})$          tal que $LenguajeDe(M_1) = LenguajeDe(r_1)$. \
    Entonces, podemos construir el autómata $M = AF(Q_1 union {q_0, f_0}, Sigma_1, delta, q_0, {f_0})$. \

    #align(center)[
      #cetz.canvas({
        import cetz.draw: circle, line, content
        import draw: state, transition

        circle((6,0), name: "M1", radius: (3.2, 1.6), stroke: black, fill: auto)
        content((rel: (-2.5, 1.5), to: "M1"), text($M_1$))
        state((4, 0), "q1", label: $q_1$)
        state((8, 0), "f1", label: $f_1$)

        state((0, 0), "q0", label: $q_0$, initial: "")
        state((12, 0), "f0", label: $f_0$, final: true)

        transition("q0", "q1", label: $lambda$, curve: 0.5)
        transition("f1", "f0", label: $lambda$, curve: 0.5)
        transition("f1", "q1", label: $lambda$, curve: 0.8)
        transition("q0", "f0", label: $lambda$, curve: 2.6) 
      })
    ]

    - $delta(q, a) = delta_1(q, a)$ para $q in Q_1 - {f_1}$ y $a in Sigma_1 union {lambda}$.
    - $delta(q_0, lambda) = delta(f_1, lambda) = {q_1, f_0}$. \

- Caso infuctivo $r = r_1^+$:

    Dado que $r_1^+ = r_1 r_1^*$, queda demostrado por los casos anteriores.


  Con esto, queda demostrado que $LenguajeDe(r) = LenguajeDe(M)$ para todo $r$ expresión regular.
  ]

  #theorem[Dado un AFD $M = angle.l Q, Sigma, delta, q_0, F angle.r$, existe una expresión regular $r$ tal que $LenguajeDe(r) = LenguajeDe(M)$]
  #proof[Como tenemos que los estados de un autómata son finitos, podemos renombrar los mismos como ${q_1, q_2 ..., q_n} $con $n = |Q|$. Con esto en cuenta, denotamos con $R_(i, j)^k$ al conjunto de cadenas que llevan al autómata de $q_i$ a $q_j$ sin pasar por ningún estado intermedio con índice mayor que k. Luego, definimos $R_(i, j)^k$ inductivamente como: \ 

    - $R_(i, j)^0 = cases({a: delta(q_i, a) = q_j}: #h(.5em) a #h(.5em) in #h(.5em) Sigma #h(.5em) "si " #h(.5em) i #h(.5em) eq.not #h(.5em) j, {a: delta(q_i, a) = q_j} #h(.5em) union #h(.5em) {lambda} #h(.5em) "si " #h(.5em) i #h(.5em) eq #h(.5em) j)$

    - $R_(i, j)^k = R_(i, j)^(k - 1) union R_(i, k)^(k - 1) (R_(k, k)^(k - 1))^* R_(k, j)^(k - 1)$
    
    Como paso intermedio, queremos demostrar que para todo $R_(i, j)^k$ existe una e.r $r_(i, j)^k$ tal que $LenguajeDe(r_(i, j)^k) = R_(i, j)^k$ Haciendo inducción sobre k:
    \ 
    - Caso base: $k = 0$ \
      $R_(i, j)^0$ es el conjunto de cadenas de un solo caracter o $lambda$. Por lo que la e.r $r_(i, j)^k$ que lo denota será:
       - $nothing$ si no existe ningún $a_i$ que una $q_i$ y $q_j$ y i $eq.not$ j 
       - $lambda$ si no existe ningún $a_i$ que una $q_i$ y $q_j$, pero con i = j
       - $a_1 | ... | a_p$ con $a_l$ simbolos del alfabeto, si delta(q_i, a_l) = q_j y j $eq.not$ i 
       - $a_1 | ... | a_p | lambda$ con $a_l$ simbolos del alfabeto, si delta(q_i, a_l) = q_j y j $eq$ i
    
    - Paso inductivo: Por H.I tenemos que: 
      #align(center)[
    $LenguajeDe(r^(k-1)_(i,k)) = R^(k-1)_(i,k)$ #h(1em) $LenguajeDe(r^(k-1)_(k,k)) = R^(k-1)_(k,k)$ #h(1em) $LenguajeDe(r^(k-1)_(k,j)) = R^(k-1)_(k,j)$ #h(1em) $LenguajeDe(r^(k-1)_(i,j)) = R^(k-1)_(i,j)$
]
 \

    Si definimos $r_(i, j)^k = r_(i, k)^(k - 1)(r_(k, k)^(k-1))^*r_(k, j)^(k-1) | r_(i, j)^(k-1)$ tenemos que:
    #align(center)[
      $LenguajeDe(r_(i, j)^k) = \
      LenguajeDe(r_(i, k)^(k - 1)(r_(k, k)^(k-1))^*r_(k, j)^(k-1) | r_(i, j)^(k-1)) = \
      LenguajeDe(r_(i, k)^(k - 1)(r_(k, k)^(k-1))^*r_(k, j)^(k-1)) union LenguajeDe(r_(i, j)^(k-1)) = \
      LenguajeDe(r_(i, k)^(k - 1)) LenguajeDe((r_(k, k)^(k-1))^*) LenguajeDe(r_(k, j)^(k-1)) union LenguajeDe(r_(i, j)^(k-1)) = \
      LenguajeDe(r_(i, k)^(k - 1)) (LenguajeDe(r_(k, k)^(k-1))^*) LenguajeDe(r_(k, j)^(k-1)) union LenguajeDe(r_(i, j)^(k-1)) = \
      R_(i, k)^(k - 1)(R_(k, k)^(k-1))^*R_(k, j)^(k-1) union R_(i, j)^(k-1) = \
      R_(i, j)^k$
    ]

    Con esto en mente, notemos primero que el lenguaje denotado por el autómata M está dado por todas las cadenas que llevan al autómata de $q_0$ a un estado final. Es decir:
    #align(center)[
      $LenguajeDe(M) = union.big_(q_j #h(.3em) in #h(.3em) F) R_(1,j)^n$
    ]
    Luego, tenemos que:
    #align(center)[
      $LenguajeDe(M) = union.big_(q_j #h(.3em) in #h(.3em) F) LenguajeDe(R_(1,j)^n) = union.big_(q_j #h(.3em) in #h(.3em) F) LenguajeDe(r_(1,j)^n) = LenguajeDe(r_(1,j 1)^n | ... | r_(1,j m)^n)$
    ]
    Por lo que concluimos que $LenguajeDe(M)$ es denotado por la e.r $r_(1,j 1)^n | ... | r_(1,j m)^n$
]


= Lema de Pumping y propiedades de clausura de los lenguajes regulares
== Configuración instantánea de un AFD 
Para comenzar, vamos a introducir una nueva notación que nos facilitará un par de prubas
#definition[Sea AFD M = #tupla. Una configuración instantánea es un par $(q, w) in Q times Sigma*$ donde $q$ es el estado en el que está el autómata y $w$ es la cadena que resta consumir \ ]

#definition[Llamamos transición a la siguiente relación sobre $Q times SigmaEstrella$: \ 

#align(center)[$(q, w) tack.r (p, beta)$ si ($delta(q, a) = p$ y $w = a beta$)] \ 

De esto  tenemos que $(q, alpha beta) tack.r^* (p, beta) sii deltaSombrero(q, alpha) = p$. Es decir, se puede llegar al estado p consumiendo la cadena $alpha$]

#lema[Sea M = #tupla un AFD. Para todo $q in Q$ y $alpha, beta in SigmaEstrella$ se tiene que: \

  #align(center)[
    si $(q, alpha beta) tack.r^* (q, beta) "entonces" forall i gt.eq 0, (q, alpha^i beta) tack.r^* (q, beta)$]
]

#proof[Por inducción sobre i: \

- Caso base: $i = 0$ \
  $(q, alpha^0 beta) tack.r^0 (q, beta)$

- Paso inductivo: \
  Supongamos que vale para i, es decir  si $(q, alpha beta) tack.r^* (q, beta) "entonces" (q, alpha^i beta) tack.r^* (q, beta)$. Veamos que vale para i + 1:

  $(q, alpha^(i + 1) beta) = (q, alpha alpha^i beta) implica_("por el antecedente" \ "q asumimos") (q, alpha alpha^i beta) tack.r^* (q, alpha^i beta) tack.r^*_(H I) (q, beta)  $

]
== Lema de Pumping
  #theorem[Sea L un lenguaje regular, entonces existe un número n tal que para toda cadena z en L con |z| $gt.eq$ n, existen cadenas $u, v, w$ tales que: \ 
  - z = $u v w$,
  - $|u v|$ $lt.eq$ n,
  - |v| $gt.eq$ 1

   $forall$i $gt.eq$ 0, $u v^i w$ $in$ L
  ]

  #proof[Sea M un AFD tal que $LenguajeDe(M)$ = L. Sea n su cantidad de estados. Sea z una cadena de longitud $m gt.eq n, z = a_1...a_m$ los símbolos que forman la cadena. 
        \
        Para aceptar z usamos $m$ transiciones, por lo tanto pasamos a través de m + 1 estados. Como $m + 1 gt n$, tenemos que necesariamente debemos pasar al menos dos veces por un mismo estado
        para aceptar la cadena (pigeonhole principle). \ 
        Sea entonces $q_(l 0) ... q_(l m)$ la sucesión de estados desde $q_0 (q_(l 0))$ hasta un estado final ($q_(l m)$)

        #align(center)[
        #cetz.canvas({
          import draw: state, transition

          state((-4, 0), "q0", label: $q_0$, initial: "")
          state((2, 0), "ql1", label: $q_(l i) = q_(l j)$, radius: (1., 1))
          state((8, 0), "qf", label: $q_l m$, final: true)

          transition("q0", "ql1", label: $a_1 ... a_i$, curve: .5)
          transition("ql1", "ql1", label: $a_(i+1) ... a_j$, curve: 1.3)
          transition("ql1", "qf", label: $a_(j+1) ... a_m$, curve: .4)
        })
      ]
        


        Existen entonces j y k mínimos tales que $q_(l j) = q_(l k)$ con $0 lt.eq j lt k lt.eq n$. Esto separa a z en tres subcadenas:
        - $u = cases(a_1...a_(j) "si " j gt 0, lambda "si " j = 0)$
        - $v = a_(j + 1)...a_( k)$

        - $w = cases(a_( k + 1)...a_m "si " k lt m, lambda "si " k eq m)$

        Juntando todo esto, tenemos que:
        #align(center)[$|u v| lt.eq n$ \ 
                      $|v| gt.eq 0$ ]
        y que:
          #align(center)[($q_0, u v w) tack.r^* (q_(l j), v w) tack.r^* (q_(l k), w) tack.r^* (q_(l m), lambda)$]

        Pero como $q_(l j) = q_(l k)$, y por el lema probado en la sección anterior, tenemos que:
        \

        #align(center)[$forall i gt.eq 0 (q_(l j), v^i w) tack.r^* (q_(l j), w) = (q_(l k), w)$ que tenemos alcanza un estado final]

        Por lo tanto, $u v^i w in $ L, $forall i gt.eq 0$ 
   ]    

   #example[Sea AFD $M = tupla$, con $|Q|$ = n. Determinar veracidad y justificar:
        + $LenguajeDe(M)$ es no vacío si y solo si existe $w in SigmaEstrella$ tal que $deltaSombrero(q_0, w) in F y |w| lt n$ 

          #rect[ \  
            #proof[
              - $implicaVuelta$) Es trivial ver que el lenguaje no es vacío

              - $implica)$ Supongamos que el lenguaje no es vacío y regular. Entonces, supongamos existe una cadena $z in LenguajeDe(M)$. Hay dos posibilidades, o bien la longitud de la cadena es menor a n, o bien es mayor. En el primer caso, no hace falta demostrar nada mas. En el segundo caso, por el lema de pumping, podemos descomponer la cadena en $u v w$ tal que $|u v| lt.eq n$ y $|v| gt.eq 1$ y estar seguros que para todo i se cumple que $u v^i w in LenguajeDe(M)$. Luego por el lema de pumping, podemos \"pumpear\" a $v$ con i = 0, reduciendo el tamaño de la cadena y repitiendo este proceso hasta llegar a una con longitud menor a n. 
            ]
          ]
        + $LenguajeDe(M)$ es infinito si y solo si existe $w in SigmaEstrella$ tal que $deltaSombrero(q_0, w) in F$ y $n lt.eq |w| lt 2 n$

          #rect[ \
            #proof[
              - $implicaVuelta$) Suponemos $z in LenguajeDe(M)$ y $n lt.eq |z| lt 2n$. Por el lema de Pumping, tenemos $z = u v x$ con $|u v| lt.eq n$ y $|v| gt.eq 1$ y $u v^i x in LenguajeDe(M)$ para todo i. Luego $LenguajeDe(M)$ es infinito

              - $implica)$ Supongamos $LenguajeDe(M)$ es infinito y regular. Supongamos también que no existe una cadena z en el lenguaje con longitud entre n y 2n - 1. Primero notemos que como el lenguaje es infinito, necesariamente debe haber cadenas de longitud mayor a n (Pues lo único que puede aportar a la \"infinitez\"(? es que el tamaño de las cadenas pueda ser arbitrariamente grandes)  
               
                Sin pérdida de generalidad, supongamos que |z| = 2n (Notar que si la longitud fuese mayor, Simplemente podríamos bombear hacia repetir el argumento hasta que se cumpla esta condición o se llegue al rango deseado. Notar también que no es posible \" saltearse\" el rango pues el mismo es de longitud n + 1, y saltearlo implicaría un ciclo que abarca más que la cantidad de estados del autómata)

                Por Lema de Pumping, tenemos que existen $u, v, x$ tales que $z = u v x$, con $|u v | lt.eq n$, $v gt.eq 1$ y $forall i u v^i x in LenguajeDe(M)$. En particular, $u v^0 x = u x$ está en el lenguaje. 

                Como $|u v x| = 2 n $ y $1lt.eq |v| lt.eq n$ tenemos que $n lt.eq |u x| lt.eq 2 n - 1$, contradiciendo nuestra suposición que dicha cadena no existía.
            ]

          ]]

        == Propiedades de clausura de los lenguajes regulares\
         === Unión 
         #theorem[El conjunto de lenguajes regulares incluidos en $SigmaEstrella$  es cerrado respecto de la unión]
         
         #proof[
          Sean $L_1$ y $L_2$ lenguajes regulares. Sea $M_1 = AF(Q_1, Sigma, delta_1, q_1, F_1)$ tal que $LenguajeDe(M_1) = L_1$ y $M_2 = AF(Q_2, Sigma, delta_2, q_2, F_2)$ tal que $LenguajeDe(M_2) = L_2$ y $Q_1 sect Q_2 eq emptyset $. 
          definimos $M = AF(Q, Sigma, delta, q_0, F)$ tal que:

          - $Q = Q_1 times Q_2$
          - $q_0$ = $(q_1, q_2)$
          - $delta((q, r), a) = (delta_1 (q, a), delta_2(r,a))$ para $q in Q_1, r in Q_2, a in Sigma$

          - $F = {(p, q) : p in F_1 or q in F_2}$

          con $LenguajeDe(M) = L_1 union L_2$. \

          Ahora queda demostrar la pertenencia

          #align(center)[
            $x in LenguajeDe(M) &sii delta((q_1_0, q_2_0), x) in F \
            &sii (delta_1(q_1_0, x), delta_2(q_2_0, x)) in F \
            &sii delta_1(q_1_0, x) in F_1 or delta_2(q_2_0, x) in F_2 \
            &sii x in LenguajeDe(M_1) or x in LenguajeDe(M_2).$
          ]


         ]
         (*Si no me equivoco, acá falta demostrar la equivalencia para $deltaSombrero$, si no no se puede asumir nada sobre la aplicación de la misma a cadenas. No debería ser difícil, pero si llego debería corregir esto*)

         Una demostración alternativa es hacer uso de las expresiones regulares. Dados $r_1$ y $r_2$ expresiones regulares que denotan los lenguajes $L_1$ y $L_2$, respectivamente, podemos construir una expresión regular $r = r_1 | r_2$ que denota la unión de los lenguajes, por definición.

        === Concatenación y clausura de Kleene
        #theorem[El conjunto de lenguajes regulares incluidos en $SigmaEstrella$  es cerrado respecto de la concatenación y la clausura de Kleene]
        (*La demo más aceptada es hacer uso nuevamente de expresiones regulares, ya que por definición trivializan la prueba, pero me gustaría demostrar también que los
        autómatas que armamos son válidos, considerar agregarla / hacerla como ejercicio*)


        === Complemento
        #theorem[El conjunto de lenguajes regulares incluidos en $SigmaEstrella$  es cerrado respecto del complemento]

        #proof[Sea L = $LenguajeDe(M)$ para algún AFD M = #tupla cuya función de transición $delta$ está completamente definida. 
        Tenemos entonces que el autómata:
          #align(center)[$M' = AF(Q, Sigma, delta, q_0, Q - F)$]
        Como tenemos que ahora todas las cadenas que no eran aceptadas por M lo son, y viceversa, tenemos que $LenguajeDe(M') = SigmaEstrella - L = overline(L)$.
          ]
         === Intersección
          #theorem[El conjunto de lenguajes regulares incluidos en $SigmaEstrella$  es cerrado respecto de la intersección]

          #proof[Sea $L_1$ y $L_2$ lenguajes regulares. Sea $M_1 = AF(Q_1, Sigma, delta_1, q_0_1, F_1)$ tal que $LenguajeDe(M_1) = L_1$ y $M_2 = AF(Q_2, Sigma, delta_2, q_0_2, F_2)$ tal que $LenguajeDe(M_2) = L_2$. Definamos $M = AF(Q, Sigma, delta, q_0, F)$ tal que:

          - $Q = Q_1 times Q_2$
          - $q_0$ = $(q_0_1, q_0_2)$
          - $delta((q, r), a) = (delta_1 (q, a), delta_2(r,a))$ para $q in Q_1, r in Q_2, a in Sigma$
          - F = $F_1 times F_2$ = ${(p, q) : p in F_1 and q in F_2} $ =

          Con una inducción sobre $|w|$ es fácil ver que $deltaSombrero((q,r), w) = (deltaSombrero_1(q,w), deltaSombrero_2(r,w))$. Con esto en cuenta, tenemos que:
          #align(center)[$w in LenguajeDe(M) sii deltaSombrero((p, r), w) in F \ 
          sii (deltaSombrero_1(p, w), deltaSombrero_2(r, w) in F_1 times F_2)) \ 
          sii (deltaSombrero_1(p, w) in F_1) and (deltaSombrero_2(r, w) in F_2) \ 
          sii w in L_1 and w in L_2$]
          ] 

          == Unión e Intersección finitos de lenguajes regulares 
            #theorem[$forall n in NN,  union.big_(i=1)^n  L_i $ es regular] 

            #theorem[$forall n in NN,  sect.big_(i=1)^n  L_i $ es regular]

            #proof[Demostramos la unión por inducción sobre n, la intersección es similar: \

            - Caso base: $n = 0$ \
              $union.big_(i=1)^0  L_i = emptyset$, que sabemos es regular 

            - Paso inductivo: \
              Supongamos que $union.big_(i=1)^n  L_i$ es regular. Sea $L_{n + 1}$ un lenguaje regular.
            
             Entonces, por la propiedad de clausura de la unión, tenemos que $union.big_(i=1)^(n + 1)  L_i = union.big_(i=1)^n  L_i union L_{n + 1}$ es regular. 
            ] 

          #lema[Los lenguajes regulares no están clausurados por union infinita]

          #proof[Sea $L_i = {a^i b^i}$, si lo estuvieran,  entonces  $union.big_(i=1)^oo  L_i$ sería regular, pero:\

            #align(center)[ $union.big_(i=1)^oo  L_i$ =  $union.big_(i=1)^oo  {a^i b^i} = {a^k b^k : k in NN}$, que sabemos no es regular]
          
          ]

          == Todo lenguaje finito es regular 
          #theorem[Todo lenguaje finito es regular]
          #proof[Sea L un lenguaje finito, con n cadenas ${w_1, w_2, ..., w_n}$. 
            Para cada $1 lt.eq i lt.eq n$, sea $L_i = {w_i}$

            Entonces $L = union.big_(i=1)^n L_i$, que sabemos es regular pues cada $L_i$ lo es
          ]
    == Problemas de decisibilidad de lenguajes regulares 
    === Vacuidad 
    #theorem[El problema de la vacuidad de un lenguaje regular es decidible]
    #proof[suponiendo que la representación del lenguaje está dada mediante un AFD (notar que siempre se puede convertir de una representación a otra, y en esta materia estamos ignorando complejidad, porque el plan nuevo de la carrera es *muy bueno*)

          - Se determina el conjunto de estados alcanzables desde el estado inicial 
          - Si ninguno de los estados alcanzables es final, entonces el lenguaje es vacío] 
    === Pertenencia 
    #theorem[El problema de la pertenencia de un lenguaje regular es decidible]
    #proof[Suponiendo que la representación del lenguaje está dada mediante un AFD, se puede determinar si una cadena pertenece simplemente determinando si la misma es aceptada por el autómata]

    === Finititud 
    #theorem[El problema de la finitud de un lenguaje regular es decidible]
    #proof[Anteriormente demostramos cual era la condición suficiente y necesaria para que un lenguaje fuese infinito]

    === Equivalencia 
    #theorem[El problema de la equivalencia de dos lenguajes regulares es decidible]
    #proof[$L_1 Delta L_2 = (L_1 sect overline(L_2)) union (overline(L_1) sect L_2) = emptyset sii L_1 eq L_2$]
    (*El libro propone una demostración más constructiva y eficiente, introduciendo el concepto de equivalencia de estados*)

  = Gramáticas Libres de Contexto
    #definition[Recordemos que, llamamos a una gramática $G = Gramática(V_N, V_T, P, S)$ libre de contexto si las producciones P son de la forma:
    #align(center)[
      $A -> alpha$ con $A in V_N$ y $alpha in (V_N union V_T)*$
    ]
    ]

    == Derivación 
      Si $alpha, beta, gamma_1, gamma_2 in (V_N union V_T)^*$ y $alpha -> beta in P$ entonces:
      #align(center)[
        $ gamma_1 alpha gamma_2 => gamma_1 beta gamma_2$
      ]

      La relación $=>$ es un subconjunto de $(V_N union V_T)^* times (V_N union V_T)^*$ y significa derivar en un solo paso

      Las relaciones $=>^*$ y $=>^+$ son las clausuras reflexiva y transitiva de $=>$, respectivamente

      Si $alpha in (V_N union V_T)^* y #h(.5em) S =>^* alpha$ decimos que la misma es una forma sentencial de G.  

    == Inferencia 
    #definition[Una manera alternativa de determinar la pertenencia de una cadena es partir desde el cuerpo de las producciones, identificando las cadenas que ya sabemos pertenecen al lenguaje
    , y concatenandolas formando así cadenas más complejas]
    
    == Lenguaje de una Gramática
    #definition[El lenguaje de una gramática G, denotado $LenguajeDe(G)$ es el conjunto de todas las cadenas que pueden ser derivadas desde el símbolo inicial S de G. Es decir:
      #align(center)[$LenguajeDe(G) = {w in V_T^*: S =>^+ w}$]
    ]


    #let arbol(A) = $cal(T)(A)$
    == árbol de derivación 
    #definition[Un árbol de derivación para una gramática G es un árbol tal que: 
      - Sus hojas están etiquetadas con símbolos de $V_T$, $V_N$ o $lambda$, caso en el cual el mismo debe ser el único hijo de su padre.
      - Sus nodos internos están etiquetados con símbolos de $V_N$.
      - La raíz está etiquetada con el símbolo inicial S
      - Si un nodo interno está etiquetado con A y sus hijos están etiquetados con $X_1, X_2, ..., X_n$ entonces $A -> X_1 X_2 ... X_n$ es una producción de G

      El árbol de derivación correspondiente a una variable A lo notaremos con $arbol(A)$
    ]


    #definition[Llamamos producto (yield) de un árbol de derivación a la cadena que se obtiene al concatenar las etiquetas de las hojas de izquierda a derecha. En particular, 
    tenemos que aquellos árboles que cumplen que: \ 
    
    - Todas las hojas están etiquetadas con símbolos de $V_T$ o con $lambda$

    - La raíz está etiquetada con el símbolo inicial S

    Son los árboles cuyo producto son las cadenas en el lenguaje de la gramática correspondiente  
    ]

    #definition[LLamamos camino de X en un árbol $arbol(A)$ a la cadena $A, X_1,..., X_k, X$ tal que:
    #align(center)[$A => .....X_1.....=>.....X_2.....=> .... => ......X_k.....=> X$]
    ]

    #definition[Llamamos altura de $arbol(A)$ a: 
    #align(center)[${max {|a x| : x "es una hoja de " arbol(A) "y " A a x "es un camino de x"}}$]
    ]

    == Equivalencia inferencia, árbol Derivación y Derivaciones 
    
    #theorem[Sea G una GLC. Si el procedimiento de inferencia recursivo determina que una cadena $w$ con sólo terminales esta en el lenguaje de una gramática definido por una variable, entoces hay una árbol de derivación
    con raíz en esa variable que produce $w$]
    #proof[Por inducción en la cantidad de pasos utilizados para inferir que $w$ esta en el lenguaje de la variable A: 
    
    - Caso base: Un sólo paso.
    En este caso, tenemos que $A -> w$ debe ser una producción de la gramática, y por lo tanto, el árbol de derivación es simplemente un nodo con raíz en A y hojas etiquetadas con los símbolos de w. 
    #align(center)[#syntree(
  child-spacing: 3em, // default 1em
  layer-spacing: 4em, // default 2.3em
  "[^A <====== w =======>]"
)]
    - Paso inductivo: 
    Supongamos que el hecho de que $w$ esté en el lenguaje es inferido luego de n + 1 pasos, y que el teorema 
    vale para todas las cadenas $x$ y variables B tal que su pertenencia fue determinada con n o menos pasos. Consideremos el último paso de 
    la inferencia utilizada para determinar que $w$ está en el lenguaje de A. Por definición, la inferencia usa alguna producción de A, 
    supongamos que es $A -> X_1 X_2 ... X_k$, donde cada $X_i$ es o bien una variable o un terminal. Podemos entonces tomar $w = w_1...w_k$como: 
    
    - Si $X_i$ es un terminal, entonces $X_i = w_i$, es decir, $w_i$ solo consiste de este terminal en la producción 
    - Si $X_i$ es una variable, entonces $w_i$ es una cadena que fue inferida con n pasos que está en el lenguaje de esa variable, y por hipótesis inductiva, sabemos que hay un árbol de derivación con raíz en $X_i$ que produce $w_i$

     Con esto, podemos armar el siguiente árbol de derivación, notar que en el primer caso los subárboles correspondiientes son triviales de un solo nodo: 

\ \

      #align(center)[#syntree(
  child-spacing: 3em, // default 1em
  layer-spacing: 3em, // default 2.3em
  "[A [^X1 [w1]] [^X2 [w2]] [...] [^Xk [wk]]]"
)]
  ]

#theorem[Sea G una GLC. Si hay un árbol de derivación con raíz en una variable A que produce una cadena $w$, tal que $w in V_T^*$. Entonces hay una derivación a izquierda $A =>_L^* w$ en la gramática]
#proof[Por inducción en la altura del árbol de derivación:

- Caso base: Altura 1

  En este caso, tenemos que el árbol de derivación es simplemente un nodo con raíz en A y hojas etiquetadas con los símbolos de w. Como se trata de un arbol de derivación, $A -> w$ debe ser una producción, por lo que la derivación es simplemente $A =>_L w$

  #align(center)[#syntree(
  child-spacing: 3em, // default 1em
  layer-spacing: 4em, // default 2.3em
  "[^A <====== w =======>]"
)]

- Paso inductivo: 

  Supongamos que el árbol de derivación tiene altura n + 1. Entonces, la raíz del árbol de derivación es A, y tiene hijos $X_1, X_2, ..., X_k$:
    
    - Si $X_i$ es un terminal, definimos $w_i$ como la cadena que consiste solo de $X_i$, es decir $w_i = X_i$
    - Si $X_i$ es una variable, entonces debe ser la raíz para algún subárbol con una producción de sólo terminales (pues si no no se cumpliría el precedente), a la que identificamos como $w_i$.
      Notar que por hipótesis inductiva, sabemos que hay una derivación a izquierda $X_i =>_L^* w_i$. 

  Ahora podemos armar la derivación a izquierda $A =>_L^* w$ de la siguiente manera:  

  #align(center)[
    $A =>_L X_1 X_2 ... X_k =>_L^* w_1 X_2 ... X_k =>_L^* w_1 w_2 ... X_k =>_L^* w_1 w_2 ... w_k = w$
  ]
]

#theorem[Sea G una GLC. Si hay una derivación $A =>^* w$ en la gramática, entonces el procedimiento de inferencia recursivo determina que $w$ está en el lenguaje de la variable A]
#proof[Por inducción en la cantidad de pasos de la derivación:

- Caso base: Un solo paso

  En este caso, tenemos que $A -> w$ debe ser una producción de la gramática, y por lo tanto, el procedimiento de inferencia recursivo determina que $w$ está en el lenguaje de A de manera inmediata.

- Paso inductivo:
  
  Supongamos que la derivación tiene n + 1 pasos, y que la hipótesis vale para cualquier derivación con menos de n pasos. Escribiendo la primera derivación de la forma $A => X_1 X_2 ... X_k$, separamos a $w = w_1...w_k$ tal que:
    - Si $X_i$ es un terminal, entonces $X_i = w_i$, es decir, $w_i$ solo consiste de este terminal en la producción
    - Si $X_i$ es una variable, entonces $X_i => w_i$. Como sabemos que $A =>^* w$ no es parte de esta derivación, (pues la misma tiene más pasos) tenemos que la misma tiene menos de n pasos, por lo que, por H.I sabemos que se puede inferir que $w_i$ está en $X_i$
  
  Por lo tanto, tenemos una producción de la forma $A -> X_1 X_2 ... X_k$, con cada $w_i$ quivalente a $X_i$ o en el lenguaje del mismo,  por lo tanto, el procedimiento de inferencia recursivo determina en el siguiente paso que $w$ está en el lenguaje de A



]

== Gramáticas Ambiguas
#definition[Una gramática es ambigua si existe al menos una cadena $w in V_T*$ para la cual haya al menos dos árboles de derivación, ambos con raíz S y que produzcan $w$]

#theorem[Para toda gramática G y cadena $w in T^*$, $w$ tiene dos árboles de derivación distintos $sii w$ tiene dos derivaciones a izquierda distintas a partir de S]

#proof[]

#definition[Un Lenguaje libre de contexto es inherentemente ambiguo  si no existe una gramática no ambigua que genere el  lenguaje]


#let apd = $angle.l Q, Sigma, Gamma, delta, q_0, Z_0, F angle.r$
= Autómatas de Pila
#definition[Un autómata de pila es una tupla $M = apd$ donde:
\
  - Q es un conjunto finito de estados
  - $Sigma$ es un alfabeto finito de entrada
  - $Gamma$ es un alfabeto finito de la pila
  - $q_0 in Q$ es el estado inicial
  - $Z_0 in Gamma$ es la configuración inicial de la pila
  - $F subset.eq Q$ es el conjunto de estados finales
  - $delta: Q times (Sigma union {lambda}) times  Gamma -> P(Q times Gamma^*)$ es la función de transición

La interpretación de $delta(q, x, Z) = {(p_1, gamma_1), ..., (p_n, gamma_n)}$ es como sigue:

Cuando el estado del autómata es q, el símbolo que la cabeza lectora está
inspeccionando en ese momento es x, y en el tope de la pila hay Z, se realizan las sigueintes acciones: 

- Si $x in Sigma$ ($eq.not lambda$), la cabeza lectora avanza una posición para inspeccionar el siguiente símbolo 
- Se elimina el símbolo Z del tope de la pila
- Se selecciona un par $(p_i, gamma_i)$ entre los existentes
- Se apila la cadena $gamma_i = c_1 c_2...c_k$, con $c_i in Gamma$ en la pila del autómata, con el símbolo $c_1$ quedando en el tope 
- Se cambia el control del autómata al estado $p_i$
]

== Configuración de un AP
#definition[Una configuración instánea de un AP es una terna $(q, w, gamma)$ donde:

- q es el estado actual del autómata
- $w$ es la cadena de entrada que queda por leer
- $gamma$ es el contenido de la pila
La configuración inicial de un AP para una cadena $w_0$ es $(q_0, w_0, Z_0)$
]

#definition[Representamos al cambio entre configuraciones instantáneas de un autómata tal que, 
para todo $x in Sigma, w in SigmaEstrella, Z in Gamma, gamma, pi in Gamma^*, q, p in Q$:

#align(center)[
 -  $(q, x w, Z pi) tack.r (p, w, gamma pi) "si" (p, gamma) in delta(q, x, Z)$
 - $(q, w, Z pi) tack.r (p, w, gamma pi) "si" (p, gamma) in delta(q, lambda, Z)$
]
]

#theorem[Información que el AP no utiliza no afecta su comportamient. Formalmente, sea $P = apd$ un AP, y $(q, x, alpha) tack.r^* (p, v, beta)$, entonces, para toda cadena $w in Sigma^*$ y $gamma in Gamma^*$:
#align(center)[
  $(q, x w, alpha gamma) tack.r^* (p, v w, beta gamma)$]

 ]

#proof[Se trata de una simple inducción sobre la cantidad de pasos en los cambios de configuración]

== Lenguaje de un AP
#definition[El lenguaje de un AP P, denotado $LenguajeDe(P)$ es el conjunto de todas las cadenas que consume y a la vez alcanzan un estado final, es decir:
#align(center)[
  $LenguajeDe(P) = {w in SigmaEstrella: exists (p in F, gamma in Gamma^*) #h(.5em) (q_0, w, Z_0) tack.r^* (p, lambda, gamma)}$
]
]

#definition[El lenguaje reconocido por P por pila vacía es: 
#align(center)[
  $LenguajeDe_lambda(P) = {w in SigmaEstrella: exists (p in Q) #h(.5em) (q_0, w, Z_0) tack.r^* (p, lambda, lambda)}$
]
]

== Equivalencia $LenguajeDe(P)$ y $LenguajeDe_lambda (P)$

#theorem[Para todo AP $P_F = angle.l Q_F, Sigma, Gamma_F, delta_F, q_0_F, Z_0, F_F angle.r$, existe un  AP $P_lambda$ tal que: 

#align(center)[
  $LenguajeDe(P_F) = LenguajeDe_lambda (P_lambda)$]
]

#proof[Definimos $P_lambda$ = $angle.l Q_F union {q_0_lambda, q_lambda}, Sigma, Gamma union {X_0}, delta_lambda, q_0_lambda, emptyset angle.r$ tal que:

+ $delta_lambda (q_0_lambda, w, X_0) = {(q_0_F, Z_0 X_0)}$

+ $forall (q in Q_F, x in Sigma union {lambda}, Z in Gamma_F), delta_lambda (q, x, Z) = delta_F (q, x, Z)$ 

+ $forall (q in F_F, Z in Gamma_F union {X_0}) , (q_lambda, lambda) in delta_lambda (q, lambda, Z)$

+ $forall (Z in Gamma_F union {X_0}), (q_lambda, lambda) in delta_lambda (q_lambda, lambda, Z)$ 
\ 

#align(center)[
      #cetz.canvas({
        import cetz.draw: circle, line, content
        import draw: state, transition

        circle((3,0), name: "PF", radius: (6, 3), stroke: black, fill: auto)
        content((rel: (-2.5, 1.5), to: "PF"), text($P_F$))

        circle((5,0), name: "FF", radius: (3,2), stroke: black, fill: auto)
        content((rel: (-1, 1.5), to: "FF"), text($F_F$))

        content((rel: (-6, 3), to: "PF"), text($P_lambda$))

        state((-2.1, 0), "q1", label: $q_0_F$)
        state((5, -.7), "f1", label: $$)
        state((6, .9), "f2", label: $$)

        state(( -6, 0), "q0", label: $q_0_lambda$, initial: "")
        state((11.5, 0), "f0", label: $q_lambda$)

        transition("f1", "f0")
        transition("f2", "f0", label: $lambda, Z | lambda$)
        transition("f0", "f0", label: $lambda, X_0 | Z_0 X_0$, curve: 0.6)
        transition("q0", "q1", label: $lambda, X_0 | Z_0 X_0$, curve: 0.3)
      })
    ] 

Queremos ahora ver que $w in LenguajeDe(P_F) sii w in LenguajeDe_lambda (P_lambda)$:

- $implica$) Si $w in LenguajeDe(P_F)$ entonces $(q_0_F, w, Z_0) tack.r^*_P_F (q, lambda, gamma)$, con $q in F_F, gamma in Gamma^*$
Por la regla 1 de $delta_lambda, delta_lambda (q_0_lambda, lambda, X_0) = {(q_0_f, Z_0 X_0)}$, por lo que: 
#align(center)[$q_0_lambda, w, X_0 tack.r_P_lambda (q_0_F, w, Z_0 X_0)$

 ]

Por la regla 2 de $delta_lambda$, tenemos que todas las transiciones de $P_F$ están en $P_lambda$ (lo \"simula\"), por lo que:
#align(center)[$(q_0_F, w, Z_0) tack.r^*_P_lambda (q, lambda, gamma)$]
Entonces: 
#align(center)[$(q_0_lambda, w, X_0) tack.r_P_lambda (q_0_F, w, Z_0 X_0) tack.r^*_P_lambda (q, lambda, gamma X_0)$]

Nuevamente por las regals 3 y 4 $delta_lambda$, para todo estado final q $in F_F$ y $Z in Gamma union {X_0}$ tenemos que una vez que se alcanza un estado final en $P_F$, se puede llegar a $P_lambda$ con la pila vacía, por lo que: 

#align(center)[$(q, lambda, gamma X_0) tack.r_P_lambda (q_lambda, lambda, gamma X_0)$]

Y que, una vez en $q_lambda$, se puede llegar a la pila vacía sin importar el tope de la pila, por lo que: 
#align(center)[$(q_lambda, lambda, gamma) tack.r^*_P_lambda (q_lambda, lambda, lambda)$]

Juntando todo, tenemos:
#align(center)[
  $(q_0_lambda, w, X_0) tack.r_P_lambda (q_0_F, w, Z_0 X_0) tack.r^*_P_lambda (q, lambda, gamma X_0) tack.r_P_lambda (q_lambda, lambda, gamma X_0) tack.r^*_P_lambda (q_lambda, lambda, lambda)$]

Por lo que si $w in LenguajeDe(P_F), $ entonces $w in LenguajeDe_lambda (P_lambda)$

- $implicaVuelta$) Tenemos que $w in LenguajeDe_lambda (P_lambda)$. Sabemos por la definición de $delta_lambda$ que la única manera de que $P_lambda$ vacíe su pila es mediante el estado $p_lambda$ (pues es el único estado que puede identificar $X_0$), además, sabemos que la única manera en la que $P_lambda$ alcance este estado, es si el autómata simulado alcanza un estado final de $P_F$. Finalmente, sabemos que el primer movimiento del autómata es siempre saltar al autómata simulado, por lo que tenemos:

#align(center)[
  $(q_0_lambda, w, X_0) tack.r_P_lambda underbrace((q_0_F, w, Z_0 X_0) tack.r^*_P_lambda (q, lambda, gamma X_0), A) tack.r_P_lambda (q_lambda, lambda, gamma X_0) tack.r^*_P_lambda (q_lambda, lambda, lambda)$]

  Pero la tranisción en A necesariamente implica que (pues la misma no hace uso de $X_0$):
  #align(center)[
    $(q_0_F, w, Z_0) tack.r^*_P_F (q, lambda, gamma)$
  ] 
  Por lo que si $w in LenguajeDe_lambda (P_lambda), $ entonces $w in LenguajeDe(P_F)$
]

#theorem[Para todo AP $P_lambda = angle.l Q_lambda, Sigma, Gamma_lambda, delta_lambda, q_0_lambda, X_0, emptyset angle.r$ , existe un AP $P_F$ tal que:
#align(center)[
  $LenguajeDe_lambda (P_lambda) = LenguajeDe(P_F)$]
]

#proof[Definimos $P_F$ = $angle.l Q_lambda union {q_0_F, q_f}, Sigma, Gamma union {X_0}, delta_F, q_0_lambda, F_lambda angle.r$ tal que:

+ $delta(q_0_F, lambda, Z_0) = {(q_0_lambda, X_0 Z_0)}
$

+ $forall( q in Q_lambda, x in Sigma union {lambda}, Z in Gamma_lambda), delta_F(q, x, Z) = delta_lambda (q, x, Z)$

+ $forall q in Q_lambda, (q_f, lambda) in delta_F(q, lambda, Z_0 )$

Ahora tenemos que demostrar que $w in LenguajeDe(P_F) sii w in LenguajeDe_lambda (P_lambda)$:

- $implicaVuelta)$ Si $w in LenguajeDe_lambda (P_lambda)$ entonces tenemos que $(q_0_lambda, w, X_0) tack.r^*_P_lambda (q, lambda, lambda)$

Por definición de delta, tenemos que
  #align(center)[$(q_0_F, w, Z_0 ) tack.r_P_F (q_0_lambda, w, X_0  Z_0) tack.r^*_P_F (q,lambda, lambda) tack.r_P_F (q_F, lambda, lambda)$]
Y por lo tanto $w in LenguajeDe(P_F)$
]

- $implica)$ Si $w in LenguajeDe(P_F)$, tenemos que: 
  #align(center)[$(q_0_F, w, Z_0) tack.r_P_F (q_0_lambda, w, X_0 Z_0) tack.r^*_P_F (p, lambda, Z_0) tack.r_P_F (q_f, lambda, lambda)$]

  Pero por definición de $P_F$:

  #align(center)[$(q_0_lambda, w, X_0 Z_0) tack.r_P_F (p, lambda, Z_0) sii (q_0_lambda, w, X_0) tack.r_P_lambda (p, lambda, lambda)$]

  Luego, tenemos que $(q_0_lambda, w, X_0) tack.r_P_lambda (p, lambda, lambda)$, por lo que $w in LenguajeDe_lambda (P_lambda)$

== Equivalencia GLCs y APDs 

  #theorem[Para toda GLC G, existe un AP M tal que:
    
    #align(center)[
      $LenguajeDe(G) = LenguajeDe_lambda (M)$]

    ]

  #proof[Sea G = #Gramática($V_N$, $V_T$, $P$, $S$) una GLC ,  definimos M = $angle.l {q}, V_T, V_T union V_N, delta, q, S, emptyset angle.r$ tal que: 

    - $delta: Q times (V_T union lambda) times (V_N union V_T) -> PartesDe(Q times (V_T union V_N)^*)$
      
      - Si $A -> alpha in P$, entonces $delta(q, lambda, A) in.rev {(q, alpha)}$ (Para toda producción en P, M lo simula desapilando la variable correspondiente y pusheando el cuerpo de la producción)
      
      - Para todo $x in V_T$, $delta(q, x, x) eq {(q, lambda)}$ (Si se tiene que el tope de la pila es un terminal, se desapila y se avanza si es igualal símbolo que la cabeza lectora está leyendo)
  Queremoe ver que $w in LenguajeDe(G) sii w in LenguajeDe_lambda (M)$:

  #lema[$forall(A in V_N, w in V_T*) A =>^+ w "sii" (q, w, A) tack.r^*_M (q, lambda, lambda)$]

  Primero demostramos este lema por inducción sobre m, la cantidad de pasos en la derivación:

  - Caso base: m = 1

    En este caso, tenemos que $A =>^1 w$ para $w = x_1 x_2 ... x_k$. Notar que si esta es una derivación posible para $w$, entonces necesariamente tiene que haber una producción $A -> x_1 x_2 ... x_k in P$, luego,  por la primer regla de $delta$, seguida por la aplicación de la segunda (que nos permite eliminar terminales del tope siempre que matcheen con la cadena), tenemos: 
    #align(center)[
      $(q,w, A) tack.r_M (q,x_1 x_2 ... x_k, x_1 x_2 ... x_k) tack.r^k_M (q, lambda, lambda)$
    ]

  - Paso inductivo:

    Por H.I, tenemos que, para todo $j lt m, A =>^j w "sii" (q, w, A) tack.r^j_M (q, lambda, lambda)$

    Sea $w = w_1...w_k$, por definición de derivación, tenemos que $A =>^m w "sii" A-> X_1 X_2... X_k$ es una producción de la gramática, y que $X_1 =>^(m_1) w_1, X_2 =>^(m_2) w_2, ..., X_k =>^(m_k) w_k$, para $m_i lt m$.

    Por otro lado, por def. de M tenemos que $A -> X_1 ... X_k in P$ sii $(q, w, A) tack.r_M (q, w, X_1...X_k)$

    Si $X_i in V_N, " entonces por H.I " (q, w_i, X_i) tack.r^*_M (q, lambda, lambda)$
    
    Si $X_i in V_T, X_i = w_i " y entonces por la segunda regla de " delta, (q, w_i, X_i) tack.r_M (q, lambda, lambda)$


    Juntando todo: 
    #align(center)[
      $(q, w, A) tack.r_M (q, w_1...w_k, X_1...X_k) tack.r^*_M (q, lambda, lambda)$
    ]

    \ 
    Volviendo al teorema, el lema nos dice que $A =>^+ w "sii" (q, w, A) tack.r^*_M (q, lambda, lambda)$, luego, tomando \ S = A obtenemos la prueba del teorema
  ]

  = Ejercicios (Después debería pasarlo a otro lado)
  + Demostra que $deltaSombrero(q, x y) = deltaSombrero(deltaSombrero(q, x), y)$ para cualquier estado q y cadenas x e y. *Pista*: hacer inducción sobre |y| \
    #proof[Siguiendo la sugerencia: \
    
    - Caso base: |y| = 0 (y = $lambda$) \ 
    $deltaSombrero(q, x lambda) = deltaSombrero(deltaSombrero(q, x), lambda) =_("def" deltaSombrero) deltaSombrero(q, x) =_(lambda "es neutro ") deltaSombrero(q, x lambda)$
    - Paso inductivo: \
    qvq  $deltaSombrero(q, x y) = deltaSombrero(deltaSombrero(q, x), y)$. Sea entonces $y = y'alpha$, tenemos, reescribiendo el lado derecho de la igualdad, $deltaSombrero(deltaSombrero(q, x), y'alpha) =_("def de " deltaSombrero) delta(deltaSombrero(deltaSombrero(q, x), y'), alpha) =_("H.I") delta(deltaSombrero(q, x y'), alpha) =_("def de " deltaSombrero) deltaSombrero(q, x y'alpha) = deltaSombrero(q, x y)$.
    ] 
    \
  + Demostrá que para cualquier estado q, cadena x, y símbolo $alpha$, $deltaSombrero(q, alpha x) = deltaSombrero(delta(q, alpha), x)$
    #proof[Por el ejercicio anterior, tenemos que $deltaSombrero(q, alpha x) = deltaSombrero(deltaSombrero(q, alpha), x)$. Luego, solo resta probar que $deltaSombrero(q, alpha) = delta(q, alpha)$ que sale fácil usando la definición]
    \

  + Sea M un AFD y q un estado del mismo, tal que $delta(q, alpha) = q$ para cualquier símbolo $alpha$. Demostrar por inducción sobre el largo de la cadena de entrada que para toda cadena $omega$, $deltaSombrero(q, omega) = q$
    
    \
    
    #rect[ \ #align(center)[#proof[Haciendo inducción sobre el largo de la cadena $w$:
    
      - Caso $|w| = 0$ ($w = lambda$)
      
          $deltaSombrero(q, lambda) =_("def " deltaSombrero)$ q
      - Caso $w = x a$
      $deltaSombrero(q, x a) =_("def " deltaSombrero) delta(deltaSombrero(q, x), a) =_(H I) delta(q, a) =_("Por enunciado") q$

    ]
      ] \ ]
  + Sea M un AFD y $alpha$ un símbolo particular de su alfabeto, tal que para todos los estados q de M tenemos que $delta(q, alpha) = q$ \
  
    *a)* Demostrar por inducción sobre n que para cualquier $n gt.eq 0, deltaSombrero(q, alpha^n) = q$ 
    
    \
     #rect[ \ #align(center)[#proof[Haciendo inducción sobre $n$:
    
      - Caso $n = 0$
      
          $deltaSombrero(q, a^0) = deltaSombrero(q, lambda)=_("def " deltaSombrero \)$ q
      - Caso $n gt.eq 1$
      $deltaSombrero(q, a^n) =_("def " deltaSombrero) delta(deltaSombrero(q, a^(n - 1)), a) =_(H I) delta(q, a) =_("Por enunciado") q$

    ]
      ] \ ]
    

    *b)* Demostrar o bien ${alpha}^* subset.eq LenguajeDe(M)$ o bien ${alpha}^* sect LenguajeDe(M) = emptyset$
    
    \

    #rect[ \ #align(center)[#proof[ Primero, una observación. Tenemos que la única manera en la que una cadena $a^k$ para algún k esté en el lenguaje de M es si el estado inicial es final, pues tenemos por enunciado que la transición por $a$ siempre es desde un estado a sí mismo. Con esta observaciones, tratamos primero de probar:
    #align(center)[${a}^* sect LenguajeDe(M) eq.not emptyset sii q_0 in F$]

    Probamos los dos lados:
    - $implica )$ Que la intersección no sea vacía implica que hay una cadena $a^k$ aceptada por el lenguaje. Supongamos que $q_0$ no fuese un estado final, por enunciado sabemos que por $a$ no podemos llegar a ningún otro estado, por lo que siempre nos quedamos en $q_0$ pero, como este no era estado final entonces nuestro autómata en realidad no acepta la cadena $a^k$. Llegamos a un absurdo, que vino de suponer que $q_0$ no era estado final 
    - $implicaVuelta)$ Sabemos por enunciado que tiene una transición por a hacia sí mismo, luego, como $q_0 in F$, tenemos que $a in LenguajeDe(M)$

    Con esto en mente, quedaría demostrar por inducción que si acepta a la cadena $a$, acepta todas las cadenas $a^k$, y una vez probado esto, como la inclusión de $q_0$ en F o bien pasa (y entonces todas las cadenas ${a}^*$ están en el lenguaje) o bien no está (por lo que ninguna cadena está): 
    #align(center)[$q_0 in F xor q_0 in.not F sii  \ 
    {a} subset.eq LenguajeDe(M) xor {a}^* sect LenguajeDe(M) eq emptyset sii  \ 
    {𝛼}^* ⊆ ℒ(𝑀) xor {a}^* sect LenguajeDe(M) eq emptyset$]

    (*Considerar terminar esto último, es fácil creo pero bue, lo que sí debería considerr es emprolijar esto porque es mucho mas fácil*) 

    ]
      ] \ ]
  
  + Sea M = $angle.l Q, Sigma, delta, q_0, {q_f} angle.r$ un AFD tal que para todos los símbolos $alpha in Sigma$ se cumple que $delta(q_0, alpha) = delta(q_f, alpha)$ \
  
    *a)* Demostrar que para todo $omega eq.not lambda, #h(.5em) deltaSombrero(q_0, omega) = deltaSombrero(q_f, omega)$ 
    
    \

    #rect[ \ #align(center)[#proof[ 
        Por inducción sobre $omega$: \  
        - Caso base: $omega = alpha$ \
        $deltaSombrero(q_0, alpha) = delta(q_0, alpha) = delta(q_f, alpha) = deltaSombrero(q_f, alpha)$
        - Paso inductivo: $omega = x alpha$ \
        $deltaSombrero(q_0, x alpha) = delta(deltaSombrero(q_0, x), alpha) =_(H I) delta(deltaSombrero(q_f, x), alpha) =_("def" deltaSombrero) deltaSombrero(q_f, x alpha)$
    ]
      ] \ ]

    *b)* Demostrar que si $omega$ es una cadena no vacía en $LenguajeDe(M)$, entonces para toda k > 0, $omega^k$ también pertenece a $LenguajeDe(M)$

    \ 

    #rect[ \ #align(center)[#proof[ 
        Por inducción sobre k: \  
        - Caso base: $k = 1$ \
        $omega^1 = omega$ y por enunciado $omega in LenguajeDe(M)$
        - Paso inductivo: $k = n + 1$ \
        $omega^(n + 1) in LenguajeDe(M) sii deltaSombrero(q_0, w^(n+1)) sect F eq.not emptyset sii deltaSombrero(q_0, w^(n+1)) = q_f sii_("Por 1)") deltaSombrero(deltaSombrero(q_0, w^n), w) = q_f sii_(H I) deltaSombrero(q_f, w) = q_f$ que sabemos es cierto por a)
    ]
      ] \ ]

  
  + Sea N un AFND tal que tenga a lo sumo una opción para cualquier estado y símbolo \ (es decir, |$delta(q, alpha)| = 1$), entonces el AFD D construido tiene la misma cantidad de transiciones y estados más las trancisiones necesarias para ir a un  nuevo estado trampa cuando una transición no esté definida para un estado particular 

  + Demostrar que para todo AFND-$lambda$ E existe un AFD D tal que $LenguajeDe(E) = LenguajeDe(D)$ (Usando la demo del libro)
  
    \

    #rect[ \ #align(center)[#proof[ 
        Sea E = $angle.l Q_lambda, Sigma, delta_lambda, q_0, F_lambda angle.r$ un AFND-$lambda$. Definimos \ D = $angle.l Q_D, Sigma, delta_D, q_D, F_D angle.r$ de la siguiente manera: \  
        - $Q_D = PartesDe(Q_lambda)$. En particular, va a ocurrir que todos los estados accesibles de D son subconjuntos de Q_lambda cerrados por la clausura lambda, es decir sea S el subconjunto, $S = cl(S)$
        - $q_D = cl(q_0)$
        - $F_D = {S subset.eq Q_lambda : S sect F_lambda eq.not emptyset}$

        - Para cada $S subset.eq Q_lambda$ y $alpha in Sigma$, definimos: \
          - $delta_D (S, alpha) = cl({r in Q_lambda: exists p in S and r in delta_lambda (p, a)})$

      Ahora probamos que para una cadena $w in SigmaEstrella, w in LenguajeDe(E) sii w in LenguajeDe(D)$: 
        - $implicaVuelta$) Simplemente podemos agregar transiciones $lambda$ en todos los estados hacia el estado representando el estado trampa, y convertimos cada una de las transiciones en el equivalente de conjuntos (i.e en vez de $q_i, {q_i}$ en las funciones de transición)

        - $implica)$ Primero demostramos por inducción sobre la longitud de la cadena $w$ que $deltaSombrero_lambda (q_0, w) = deltaSombrero_D (q_D, w)$:
          - |w| = 0: \ 
          $deltaSombrero_lambda (q_0, lambda) = cl(q_0) = q_D = deltaSombrero_D (q_D, lambda)$
          - $|w| gt 0, w = x a$: \
          $deltaSombrero_lambda (q_0, x a) = cl({r in Q_lambda : exists p in deltaSombrero_lambda (q_0, x) and r in delta_lambda (p, a)}) = cl({r in Q_lambda : exists p in deltaSombrero_D (q_D, x) and r in delta_lambda (p, a)}) = deltaSombrero_D (q_D, x a)$ 
    ]
      ] \ ]
  

  + Indicar V o F y justificar
    - Si $D = tupla$ es un AFD entonces reconoce al menos |Q| palabras distintas, es decir $\# LenguajeDe(D) gt.eq |Q|$ 

    \

    #rect[ \ #align(center)[#align(center)[Falso. Como contraejemplo, un AFD que no tiene estados finales
      ] \ ]]
     
    
    - Si $N = tupla$ es un AFND entonces todas las palabras de $LenguajeDe(N)$ tienen longitud menor o igual a $|Q|^2$ 

    \ 

    #rect[ \ #align(center)[Falso. Como contraejemplo, para $Sigma = {0, 1}, L = {w | 1 in.not w}, $ tenemos el AFND: \
      #automaton((
      q0: (q0:"0")
    ))
      ] \ ]
    
  + Cuántos AFD hay con |Q| = 2 y $|Sigma| = 3?$

      \ 

      #rect[ \ #align(center)[#align(center)[La fórmula general para la cantidad de AFDs posibles es $|Q|^(|Q| times |Sigma|) times 2 ^(|Q|) times |Q|$, por lo que para $|Q| = 2$ y $|Sigma| = 3$ tenemos 512 AFDs posibles\
        ] \ ]]

  + Qué pasa al invertir los arcos en un AFD?

    \ 

    #rect[ \ #align(center)[#align(center)[
      Noc si a esta pregunta le faltó algo más o quería darnos una pista sobre como arrancar a conseguir un AFD para el inverso de un lenguaje
      ] \ ]]


  + Qué pasa al invertir los estados finales con no finales en un AFND?

    \ 

    #rect[ \ #align(center)[#align(center)[
      A diferencia de con  un AFD, invertir los estados no nos provee con un autómata que reconozca el complemento al lenguaje original
      ] \ ]]

  + Demostrar que para cada AFND $N = tupla$ existe otro AFND-$lambda #h(.5em) E = angle.l Q_lambda, Sigma, delta_lambda, q_(0), F_lambda angle.r$ tal que $LenguajeDe(N) = LenguajeDe(E)$ y $F_lambda$ tiene un solo estado final

   #let tuplaE = $angle.l Q_lambda, Sigma, delta_lambda, q_(0lambda), F_lambda angle.r$  

    
   
   #rect[ #proof[Definimos E de la siguiente manera: \
    - $Q_lambda = Q union {q_f}$, donde $q_f$ es un nuevo estado final
    - $F_lambda = {q_f}$
    - $delta_lambda (q, alpha) = delta(q, alpha)$ para todo $q in Q, alpha in Sigma$ 
    - $delta_lambda (q, lambda) = {q_f}$ para todo $q in Q$ si $q in F$ (Esto debería definirlo así, o usar la clausura lambda?)

    Queremos demostrar que $LenguajeDe(N) = LenguajeDe(E)$, para eso primero notamos que $deltaSombrero_N (q_0, w) = deltaSombrero_E (q_(0lambda), w)$ para toda cadena $w in SigmaMás$. Con esto en mente tenemos que (Separamos en casos):

    - $lambda in LenguajeDe(N) sii delta(q_0, lambda) sect F eq.not emptyset sii {q_0} sect F eq.not emptyset implica delta_lambda (q_0, lambda) = {q_f} implica delta(q_0, lambda) sect F_lambda eq.not emptyset sii lambda in LenguajeDe(E)$

    - $lambda in LenguajeDe(E) sii delta(q_0, lambda) sect F_lambda eq.not emptyset implica delta(q_0, lambda) sect F eq.not emptyset sii lambda in LenguajeDe(N)$

    - $w in LenguajeDe(N) sii deltaSombrero_N (q_0, w) sect F eq.not emptyset implica delta_lambda (deltaSombrero_lambda (q_0, w), lambda) = {q_f} sii deltaSombrero_lambda (q_0, w) sect F_lambda eq.not emptyset sii w in LenguajeDe(E)$

    - $w in LenguajeDe(E) sii deltaSombrero_lambda (q_0, w) sect F_lambda eq.not emptyset sii delta_lambda (deltaSombrero_lambda (q_0, w), lambda) = {q_f} implica deltaSombrero (q_0, w) sect F eq.not emptyset sii w in LenguajeDe(N)$
    ]
    ] \ 
  + Sea $Sigma$ un alfabeto con al menos dos símbolos, y sea a un símbolo de $Sigma$. Sea  $N = tupla$ un AFND, considerar el AFND-$lambda$ $E = angle.l Q, Sigma \\ {a}, delta_lambda, q_(0), F angle.r$ que se obtiene por reemplazar todas las transiciones por el símbolo a por trancisiones $lambda$. Es decir: 

      - Para todo $q in Q, x in Sigma : x eq.not a, delta(q, x) = delta_lambda (q, x)$
      - Para todo $q in Q, delta_lambda (q, lambda) = delta(q, a)$
    Determinar cuál es el lenguaje aceptado por E

  + Es posible acotar superiormente cuántas trancisiones requiere la aceptación de una palabra en un AFND-$lambda$?

    \ 

    #rect[ \ #align(center)[#align(center)[
      Noc (_xd_)
      ] \ ]]
  + Sea  $E = angle.l Q, Sigma, delta, q_(0), {q_f} angle.r$ un AFND-$lambda$ tal queno haya transiciones hacia $q_0$ ni desde $q_f$. Describir los lenguajes que se obtienen a partir de las siguientes modificaciones: 

      a) Agregar una transición $lambda$ desde $q_f$ hacia $q_0$ \

      b) Agregar una transición $lambda$ desde $q_0$ hacia cada estado alcanzables desde $q_0$ (notar que no es sólo aquellos directos) \

      c) Agregar una transición $lambda$ hacia $q_F$ desde cada estado que tiene un camino  hacia $q_f$ \

      d) El autómata obtenido haciendo b) y c) 
    
  + Demostrar que los lenguajes regulares son cerrados respecto de la concatenación y la clausura de Kleene mediante la construcción de un autómata.

  + Demostrar que los lenguajes regulares son cerrados respecto de la diferencia de conjuntos.

  + Demosstrar que los lenguajes regulares son cerrados respecto al reverso del lenguaje, donde el reverso está definido como el lenguaje formado por el reverso de todas sus cadenas. 

  + Idem para homomorfismos y sus inversos (?

  + Sea L un lenguaje regular, y $a$ un símbolo, llamamos L/$a$ al cociente de L y a al conjunto de cadenas $w$ tales que $w a in L$. Por ejemplo, si L = {a, aab, baa} entonces L/a = {$lambda$, ba}. Demostrar que si L es un lenguaje regular, entonces L/a también.

  + De manera similar, probar que a \\ L es un lenguaje regular, donde a \\ L es el conjunto de cadenas $w$ talesque a$w in L$

  + Demostrar que los lenguajes regulares son cerrados respecto de las siguientes operaciones:

    a) $min(L) = {w | w in L$ y no existe $alpha$ tal que $alpha  w in L$}

    b) $max(L) = {w | w in L$ y no existe $alpha eq.not lambda$ tal que $w alpha in L$}

    c) init(L) = ${w | "Para algún " x, w x in L}$

  + La mayoría de los ejs de la sección 4.2 (Me dió fiaca seguir copiando xd) 

  + Sea L un lenguaje regular, y sea n la constante del Lema de Pumping para L. Determinar veracidad y demostrar: 

    a) Para cada cadena z en L, con $|z| gt.eq n$, la descomposición de $z$ en $u v w$, con $|v| gt.eq 1$ y $|u v| lt.eq n$, es única. 

    b) Cada cadena $z$ en L, con $|z| gt.eq n$, es de la forma $u v^i w$ para algún $u, v, w$ con $|v| gt.eq 1$ y $|u v| lt.eq n$ y algún i 

    c) Hay lenguajes no regulares que satisfacen la condición afirmada por el Lema de Pumping 

    d) Sean $L_1, L_2$ lenguajes sobre el alfabeto $Sigma$ tal que $L_1 union L_2$ es un lenguaje regular.
    Entonces $L_1 $ y $L_2$ son regulares.

  + Sea $cal(C)$ el mínimo conjunto que contiene todos los lenguajes finitos, y está cerrado por unión finita, intersección, complemento, y concatenación ¿Cuál es la relación entre $cal(C)$ y el conjunto de todos los lenguajes regulares? 
  + Dar un algoritmo de desición que determine si el lenguaje aceptado por un autómata finito es el conjunto de todas las cadenas del alfabeto 
  + Dar un algoritmo de decisión que determine si el lenguaje aceptado por un autómata finito es cofinito 
  + Demostrar que todo lenguaje regular es libre de contexto. *Pista*: construir una gramática mediante inducción en la cantidad de operadores de una expresión regular 
  + Una GLC es linear a derecha si el cuerpo de cada producción  tiene a lo sumo una variable, y la misma aparece más a la derecha. Es decir, todas las producciones son de la forma $A -> w B$ o $A -> w$.
    
    a) demostrar que toda GLC lineal a derecha genera un lenguaje regular. *Pista*: construir un autómata finito $lambda$ que simule la derivación más a izquierda de la gramática, con sus estados representando el símbolo no terminal de la forma sentencial actual.

    b) Demostrar que todo lenguaje regular tiene una GLC lineal a derecha. *Pista*: Empezar un AFD y hacer que las variables de la gramática representen estados
  
  + Considerar la gramática G definida por las producciones: 
    #align(center)[
      $S -> a S | S b | a | b$
    ]
    a) Demostrar por inducción sobre la longitud de la cadena que ninguna cadena generada por G tiene $b a$ como subcadena.

    b) Identificar $LenguajeDe(G)$

  + Sea G la gramática con producciones: 
    #align(center)[
      $S -> a S b S | b S a S | lambda$
    ]

    Demosstrar que $LenguajeDe(G)$ es es conjunto de cadenas con una misma cantidad de $a$es que de $b$s

  + Supongamos que G es una GLC sin producciones que tengan a $lambda$ del lado derecho. Si $w$ está en el lenguaje de G, |$w| eq n$ y $S =>^m w$, demostrar que $w$ tiene un arbol de derivación con n + m nodos. 

  + Supongamos lo mismo que en el ej anterior, pero ahora puede haber producciones con $lambda$ en la derecha. Demostrar que un árbol de derivación para $w$ puede tener a lo sumo $n + 2m - 1$ nodos.

  + Demostrar que si $X_1 X_2...X_k =>^* a$ entonces todos los símbolos que provienen de derivar $X_i$ están a la izquierda de todos los que provienen de derivar $X_j$, si $i lt j$. *Pista*: Usar inducción sobre la cantidad de pasos en la derivación


  + Indicar veracidad:
    - Si $ P = apd$ es un autómata de pila entonces cada cadena $w in LenguajeDe_lambda (P)$ es reconocida por P en a lo sumo $|w| * \#Q * \#Gamma$ transiciones, es decir: 
    #align(center)[
      Sea $n lt.eq |w| * \# Q * \# Gamma$, entonces existe $p in Q$ tal que $(q_0, w, Z_0) tack.r^n (p, lambda, lambda)$
    ]

  + Dado un autómata finito $M = AF(Q, Sigma, delta, q_0, F)$, dar un autómata de pila $M' = AP(Q', Sigma, Gamma', delta', q_0', Z'_0, emptyset)$ tal que $LenguajeDe(M) = LenguajeDe_(lambda)(M')$. \

  + Consideremos la demostración del teorema que afirma que para cada autómata $M = AP(Q, Sigma, Gamma, delta, q_0, Z_0, F)$ existe un autómata $M'$ tal que $LenguajeDe(M) = LenguajeDe_(lambda)(M')$. \ ¿Si $M$ es determinístico, entonces el autómata $M'$ construido en la demostración también lo es? \

  + Consideremos la demostración del teorema que afirma que dado $M' = AP(Q', Sigma, Gamma', delta', q_0', X_0, emptyset)$ existe un autómata $M$ tal que $LenguajeDe_(lambda)(M') = LenguajeDe(M)$. \ ¿Si $M'$ es determinístico, entonces el autómata $M$ construido en la demostración también lo es? \

  + Demostrar que si P es un APDm entonces existe un APD $P_2$ con solo dos símbolos de pila (es decir $|Gamma_2| = 2$) tal que $LenguajeDe_lambda (P) = LenguajeDe_lambda (P_2)$. *Pista*: Considerar una codificación binaria para la pila 

  + Un APD está restringido si en toda transición puede incrementar la altura de la pila con a lo sumo un símbolo, es decir, para toda transición $delta(q, w, Z)$ que contiene algún $(p, gamma)$, debe ocurrir que  \ $|gamma| lt.eq 2$. Demostrar que si P es un APD, entonces existe un APD restringido $P_2$ tal que $LenguajeDe (P) = LenguajeDe (P_2)$




