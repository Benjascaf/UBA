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

          ]

        == Propiedades de clausura de los lenguajes regulares\
         === Unión 
         #theorem[El conjunto de lenguajes regulares incluidos en $SigmaEstrella$  es cerrado respecto de la unión]
         
         #proof[
          Sean $L_1$ y $L_2$ lenguajes regulares. Sea $M_1 = AF(Q_1, Sigma, delta_1, q_1, F_1)$ tal que $LenguajeDe(M_1) = L_1$ y $M_2 = AF(Q_2, Sigma, delta_2, q_2, F_2)$ tal que $LenguajeDe(M_2) = L_2$ y $Q_1 sect Q_2 eq emptyset$. Sea $M = AF(Q_1 union Q_2 union {q_0}, Sigma, delta, q_0, F_1 union F_2)$ tal que:

          - $forall q_1 in Q_1, forall q_2 in Q_2, forall a in Sigma, delta((q_1, q_2), a) = (delta_1(q_1, a), delta_2(q_2, a))$

          - $F = {(f_1, f_2) : f_1 in F_1 or f_2 in F_2}$

          tal que $LenguajeDe(M) = L$. \

          Para probar que $L = L_1 union L_2$, basta probar que: $x in LenguajeDe(M) sii x in LenguajeDe(M_1) or x in LenguajeDe(M_2)$.

          #align(center)[
            $x in LenguajeDe(M) &sii delta((q_1_0, q_2_0), x) in F \
            &sii (delta_1(q_1_0, x), delta_2(q_2_0, x)) in F \
            &sii delta_1(q_1_0, x) in F_1 or delta_2(q_2_0, x) in F_2 \
            &sii x in LenguajeDe(M_1) or x in LenguajeDe(M_2).$
          ]


         ]

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
    
  + 