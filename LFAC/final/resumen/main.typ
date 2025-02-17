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
       - $a_1 | ... | a_p$ con $a_l$ simbolos del alfabeto, si $delta(q_i, a_l) = q_j$ y j $eq.not$ i 
       - $a_1 | ... | a_p | lambda$ con $a_l$ simbolos del alfabeto, si $delta(q_i, a_l) = q_j $ y  j $eq$ i
    
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
      $LenguajeDe(M) = union.big_(q_j #h(.3em) in #h(.3em) F) R_(1,j)^n = union.big_(q_j #h(.3em) in #h(.3em) F) LenguajeDe(r_(1,j)^n) = LenguajeDe(r_(1,j 1)^n | ... | r_(1,j m)^n)$
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

#theorem[Para toda gramática G y cadena $w in T^*$, $w$ tiene dos árboles de derivación distintos $sii w$ tiene dos derivaciones a izquierda distintas a partir de S] <unambiguous>

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

  #theorem[Si M es un APD, entonces existe una GLC G tal que:
    
    #align(center)[
      $LenguajeDe_lambda (M) = LenguajeDe(G)$]

    ] <apglc>

  #proof[Sea M = $angle.l Q, Sigma, Gamma, delta, q_0, Z_0, emptyset angle.r$ un APD, definimos G = #Gramática($V_N$, $V_T$, $P$, $S$) tal que:
  
  - $V_N  = {[q Z p]: q, p in Q, Z in Gamma} union {S}, V_T = Sigma, $ y P dado por: 
    
   
    - $S -> [q_0 Z_0 q]$, para cada p en Q
 
    - $[q Z q_1] -> x$ sii $(q_1, lambda) in delta(q, x, Z)$
 
    - $[q Z q_1] -> lambda$ sii $(q_1, 
    lambda) in delta(q, lambda, Z)$
    - Para cada $q, q_1, ... q_m+1 in Q, x in Sigma " y " Z, Y_1...Y_m in Gamma$:
    
      - $[q Z q_(m+1)] -> x [q_1 Y_1 q_2] ... [q_m Y_m q_(m+1)]$ en P sii $(q_1, Y_1...Y_m) in delta(q, x, Z)$
    
      - $[q Z q_(m+1)] -> [q_1 Y_1 q_2] ... [q_m Y_m q_(m+1)]$ en P sii $(q_1, Y_1...Y_m) in delta(q, lambda, Z)$
  
\
 
  Antes de coninuar, primero probamos el siguiente lema:

  #lema[ 
    Para todo $q, p in Sigma, Z in Gamma $:
    #align(center)[
      $(q, w, Z) tack.r^*_M (p, lambda, lambda) "sii" [q Z p] =>^*_G w$
    ]
  ]
  
  - $implica)$ Veamos por inducción sobre i que vale: 
    
    #align(center)[
        Si $(q, w, Z) tack.r^i_M (p, lambda, lambda) "entonces" [q Z p] =>^*_G w$
    ]

    - Caso base: i = 1

      En este caso, tenemos que $(q, x, Z) tack.r^1_M (q, lambda , lambda)$, por lo que $(q, lambda) in delta(q, x, Z)$, entonces, 
      
      por definición de G, tenemos que, $[q Z p]  -> x. "Por lo tanto, " [q Z q] =>_G x$

    - Paso inductivo:\

      Sea $w = x alpha$, con $alpha in Sigma*$, tenemos que $(q, w, Z) tack.r^i_M (p, lambda, lambda)$. Sean $Y_1...Y_k in Gamma$, tenemos que necesariamente el primer 
      movimiento del apd debe ser :

      #align(center)[
        $(q, x alpha, Z) tack.r_M (q_1, alpha, Y_1...Y_k) tack.r^(i - 1)_M (p, lambda, lambda)$

      ]

      Descomponiendo a $alpha = alpha_1...alpha_k$ tales que $alpha_j$ es el input consumido al terminar de popear a $Y_j$ de la pila, y sean $p_j " y " p_(j + 1)$ los estados cuando se popea $Y_j$, y cuando se termina se tiene a $Y_(j + 1)$ al tope, respectivamente. Tenemos que:
      #align(center)[
        $(q_i, alpha_j, Y_j) tack.r^(k_i)_M (q_(j + 1), lambda, lambda)$
        
      ]

      
      Pero como $k_i lt i$, tenemos:
      #align(center)[
        Si $(q_i, alpha_j, Y_j) tack.r^(k_i)_M (q_(j + 1), lambda, lambda)$ entonces $[q_j Y_j q_(j + 1)] =>^*_G alpha_j$
      ]

      Como en G se tiene la producción $[q Z p] -> x [q_1 Y_1 q_2]...[q_k Y_k p]$, tenemos que podemos armar la derivación:

      #align(center)[
        $[q Z p] => x [q_1 Y_1 q_2] [q_2 Y_2 q_3]...[q_k Y_k p] =>^* x alpha_1 [q_2 Y_2 q_3]... [q_k Y_k p] =>^* x alpha_1 alpha_2 ...alpha_k = w$
      ]

    - $implicaVuelta)$ Veamos por inducción sobre i que vale:

    #align(center)[
      Si $[q Z p] =>^i w$ entonces $(q, w, Z) tack.r^*_M (p, lambda, lambda)$
      ]
    
    - Caso base: i = 1
      
      En este caso, tenemos que $[q Z p] =>^1 x$, por lo que necesariamente $[q Z p] -> x $ es una producción de G y por definición$(q, x, Z) tack.r_M (p, lambda, lambda)$, por lo que $(q, x, Z) in delta(q, x, Z)$

    - Paso inductivo:

      Tenemos que $[q Z p] =>^i_G  w$, pero sabemos que necesariamente el primer paso de la derivación debe ser y ser continuada por una derivación del estilo: 
        #align(center)[ 
          
          $
          [q Z p] => x [q_1 Y_1 q_2]...[q_n Y_n p] =>^(i-1)  w
          $

        ]


        Sea entonces $w = x w_1 ... w_n$ de manera tal que, para $1 lt.eq j lt.eq n, k_i lt i$ se cumpla que:
          #align(center)[
            $[q_j Y_j q_(j + 1)] =>^(k_i) w_j$ (Es decir, la variable deriva en $w_j$)

          ]
        Por H.I, tenemos que se cumple que, $(q_j, w_j, Y_j) tack.r^*_M (q_(j+1), lambda, lambda)$

        Notemos que también se cumple que  $(q_j, w_j, Y_j Y_(j+1)...Y_n) tack.r^*_M (q_(j+1), lambda, Y_(j+1)...Y_n)$

        Por lo que tenemos por como construimos G que hay un cambio de configuración: 

        #align(center)[
                    $(q, x, Z) tack.r_M (q_1, lambda, Y_1...Y_n)$
        ]

        Juntando todo:
        #align(center)[
          $(q, x w_1...w_n, Z) tack.r_M (q_1, w_1...w_n, Y_1...Y_n) tack.r^*_M (p, lambda, lambda)$
        ]


  Con el lema probado, podemos tomar q = $q_0$ y Z = $Z_0$ tal que nos queda:

  #align(center)[
    $(q_0, w, Z_0) tack.r^*_M (p, lambda, lambda) "sii" [q_0 Z_0 p] =>^*_G w$
  ]

  Por la definición de G, $S -> [q_0 Z_0 p] in P$, luego:

  #align(center)[
    $(q_0, w, Z_0) tack.r^*_M (p, lambda, lambda) "sii" S =>^*_G w$
  ]

  Que es equivalente a decir que:
    #align(center)[
    $w in LenguajeDe_lambda (M) "sii" w in LenguajeDe(G)$
  ]
  ]

  == Autómatas de pila deterministicos 
    #definition[Un autómata de pila es determinístico si para todo estado q, símbolo x y Z en la pila se cumple que:

      - #$delta(q, x, Z) lt.eq 1$ (tiene a lo sumo un movimiento a partir de cada configuración)
      - #$delta(q, lambda, Z) lt.eq 1$ (tiene a lo sumo un movimiento que no consuma la cadena a partir de cada configuración)
      - Si #$delta(q, lambda, Z) = 1$, entonces #$delta(q, x, Z) = emptyset$ 

    ]

    #theorem[No es cierto que para todo APD no determinístico exista otro determinístico que reconozca el mismo lenguaje]

    #theorem[Si L es un lenguaje regular, entonces existe un APD P determinístico tal que $LenguajeDe(P) = L$]

    #proof[La idea es sencilla, se construye un APD que esencialmente ignora la pila para simular un AFD. De manera más formal, sea A = #tupla un AFD, constrimos el APD determinístico P = $angle.l Q, Sigma, {Z_0}, delta_P, q_0, Z_0, F angle.r$ tal que:

      - $delta_P (q, x, Z_0) = {(delta(q, x), Z_0)}$
   
    Lo único que quedaría es probar por inducción sobre |w| que:
    #align(center)[
      $(q_0, w, Z_0) tack.r^*_P (p, lambda, Z_0) "sii" deltaSombrero(q_0, w) = p$
    ]
]

  #definition[ Un lenguaje L tiene la propiedad del prefijo sii para todo par de cadenas no nulas x e y, se cumple que 
    
    #align(center)[
      $x in L implica x y in.not L $

    ]
  ]

  #theorem[Un lenguaje L es $LenguajeDe_lambda (P)$ para algun APD determinístico P, si y solo si L tiene la propiedad del prefijo y existe algún APD determinísto $P_2$ tal que $LenguajeDe(P_2) = L$] <pref>

  #theorem[Los lenguajes aceptados por APDs determinísticos incluyen a los regulares, y están incluidos en los libres de contexto] <det2>

  #theorem[Si L = $LenguajeDe_lambda (P)$, para algún APD determinístico P, entonces L tiene una GLC no ambigua]

  #proof[ El plan va a ser probar que la construcción utilizada en @apglc produce una GLC no ambigua cuando se basa en APD determinístico. Primero, recordemos que por @unambiguous tenemos que va a ser suficiente demostrar que tiene únicas derivaciones a izquierda para probar que G no es ambigua. 
  
  Supongamos entonces que P acepta la cadena $w$ por pila vacía, tenemos que lo hace en una única secuencia de movimientos, pues es determinístico, por lo que podemos determinar qué producción permite que G derive a w. 
  
  Nunca va a haber más de una opción para qué cambio de configuración motivó la producción a utilizar, pero sí podemos tener más de una posible producción para un cambio dado. Por ejemplo, supongamos $delta(q, alpha, X) = {(r, Y_1...Y_k)}$, tenemos que para este movimiento tenemos todas las producciones en G, causada por todos los posibles órdenes en los que pueden estar los estados de P. 
  
  Sin embargo, solo una de estas producciones va a representar realmente los cambios realizados por P (pues si en algún momento tuviera más de una opción que lo llevara a aceptar w, el mismo no sería determinístico), luego, solo una de estas producciones realmente derivan en w.
  ]

  #theorem[Si L = $LenguajeDe(P)$ para algun APD determinístico P, entonces L tiene una gramática no ambigua]

  #proof[
    Hagamos uso de un símbolo especial \$ tal que no aparezca en las cadenas de L, y definamos L´ = L\$. Tenemos entonces que necesariamente L´ cumple la propiedad del prefijo, y, por @pref, tenemos que existe un P´ tal que L´ = $LenguajeDe_lambda (P´)$. Además, por @det2 tenemos que existe una gramática G´ que genera el lenguaje de pila vacía de P´, es decir, L´. 

    Ahora construyamos un autómata G a partir de G´ tal que $LenguajeDe(G) = L$. Para lograr esto, simplemente tenemos que deshacernos de los símbolos especiales \$ en las cadenas. Para lograr esto, podemos tratar estos símbolos como variables en las producciones de G, y hacer que sean la cabeza de una producción cuyo cuerpo es $lambda$, o sea $\$ -> lambda$. 

    El resto de las producciones se mantienen, luego, como $LenguajeDe(G´) = L´, "tenemos que " LenguajeDe(G) = L$. Nos queda determinar no ambigüedad. 

    sin embargo, las derivaciones a izquierda de G son exactamente las mismas que para G´, con la excepción que al final de las derivaciones en G, se toma un paso más para deshacese del símbolo especial. Como tenemos que G´ es ambigua, G necesariamente también lo es.
    
  ]


  = Propiedades de Lenguajes Libres de Contexto 
  
    == Formas normales de GLCs (*Innecesario si repasando para final*)
      #align(center)[*El contenido en esta sección (más allá de la mención de las formas normales), \ 
      no se dictó en el segundo cuatrimestre de 2024 de la materia y es solo por interés personal*]

    #definition[Llamamos forma normal de Chomsky a una producción la cual, siendo A, B, C variables, y $a$ un símbolo terminal, es de alguna de las siguientes formas: 
      #align(center)[

        - $A -> B C$
        - $A -> a$
      ]
    ]

    El objetivo de esta sección va a ser demostrar que todo lenguaje libre de contexto (sin $lambda$) generado por una GLC G, es generado por otra en cuyas producciones estén todas en forma normal de Chomsky. Para lograrlo, vamos a:

    + Eliminar símbolos inútiles
    + Eliminar producciones $lambda$
    + Eliminar producciones unitarias 

    === Eliminando símbolos inútiles
      #definition[Decimos que un símbolo X es útil para una gramática G si hay alguna derivación tal que $s =>^* alpha X beta =>^* w$, para algún $w in V^*_T$ (es decir, es parte de alguna forma sentencial). Notar que X puede o ser una variable o un símbolo terminal.]

      Si un símbolo no es útil, decimos que es inútil. Claramente, evitar estos símbolos no afecta el lenguaje generado por la gramática.
      
      El proceso que vamos a utilizar para eliminar estos símbolos empieza por la identificación de dos propiedades que todo símbolo necesita para ser útil:

      + Decimos que un símbolo X está generando si se tiene que $X =>^* w$, para alguna cadena $w$. Notar que todo terminal está generando, pues deriva en sí mismo en 0 pasos 
      + Decimos que X es alcanzable si existe una derivación $S => alpha X beta$, para $alpha, beta in (V_N union V_T)^*$

      #theorem[
        
        Sea G una GLC, tal que $LenguajeDe(G) eq.not emptyset$; Sea $G_1 = angle.l V_(N 1), V_(T 1), P_1, S_1 angle.r$ la gramática obtenida a partir de:

          + Eliminar todos los símbolos inútiles, y toda producción que contenga a uno o más de esos símbolos
          + Eliminar todos los símbolos no alcanzables en la gramática resultante del proceso anterior 
        
        Entonces $G_1$ no tiene símbolos inútiles, y $LenguajeDe(G_1) = LenguajeDe(G_2)$
          

      ]

      #let g1(A) = A_1
      #let g2(A) = (A)
      #proof[
Supongamos, sin pérdida de generalidad,  que X es un símbolo que no es eliminado, es decir, tenemos que $X in (V_(T 1) union V_(N 1))$. Sea $G_2$ la gramática resultante de aplicar la primera regla a G. Como X esta en $G_1$, necesariamente tenemos que $X =>^*_(G_1) w$. Además, tenemos que cada símbolo usado en esta derivación
también está generando, por lo que $X =>^*_(G_2) w$.

Dado que X no fue eliminado al aplicar la segunda regla, tenemos que hay $alpha, beta$ tales que $S =>^*_(G_2) alpha X beta$, y como todos estos símbolos son alcanzables, tenemos $S =>^*_(G_1) alpha X beta$

Tenemos que todos los símbolos en $alpha X beta$ son alcanzables, y además, como todos están incluidos en $(V_(N 2) union V_(T 2))$, tenemos que están generando. Luego, una derivación del estilo $S =>^*_(G_2) alpha X beta =>^*_(G_2) x w y$
involucra símbolos alcanzables, pues son alcanzados por algún símbolo de $alpha X beta$, por lo que necesariamente se trata de una derivacíon que también se encuentra en 
$G_1$, es decir: 

#align(center)[$S =>^*_(G_1) alpha X beta =>^*_(G_1) x w y$]
   
Concluimos entonces que X es un símbolo útil que se encuentra en $G_1$. Como X se trataba de un símbolo cualquiera, concluimos también que $G_1$ no tiene símbolos inútiles.

Ahora queda demostrar que $LenguajeDe(G_1) = LenguajeDe(G)$

- $LenguajeDe(G_1) subset.eq LenguajeDe(G)$

    Dado que simplemente eliminamos símbolos y producciones de G, es evidente (hará falta probar que eliminar símbolos y producciones de una gramática genera subconjuntos de su lenguaje?).

- $LenguajeDe(G_1) supset.eq LenguajeDe(G)$

  Tenemos que probar que si $w in LenguajeDe(G) implica w in LenguajeDe(G_1)$. Sin embargo, que una cadena $w$ esté en el lenguaje generado por $G_1$, implica necesariamente que 
  $S =>^*_(G) w$. Sin embargo, tenemos que todos los símbolos en esta derivación son necesariamente alcanzables y están generando, por lo que $S =>^*_(G_1) w$
   
==== Computando símbolos alcanzables y generadores 
#definition[Sea G una gramática, para computar los símbolos generadores de G hacemos uso de la siguiente inducción: 

  - Caso base:
      Todo símbolo en $V_T$ es generador, pues se genera a sí mismo 

  - Paso inductivo: 

      Sea $A -> alpha$ una producción de G, y sea todo símbolo en $alpha$ un símbolo que ya fue reconocido como generador, entonces A es un generador.
]      
      
#theorem[El algoritmo propuesto solo encuentra todos los símbolos generadores]

#proof[ En otras palabras, queremos demostrar que el algoritmo encuentra un 
símbolo X sii X es generador. 

$implica$) Por como definimos el algoritmo, tenemos que necesariamente el símbolo encontrado debe ser generador (Se puede hacer induccion en el orden en el que se agragaron los símbolos para algo más formal, pero lo veo inecesario)

$implicaVuelta)$ Tenemos entonces que X es un generador, es decir, $X =>^i_G w$. Probamos por recursión en el largo de la derivación que X es encontrado por el algoritmo.

  - Caso base: i = 0
      
      Tenemos entonces que X $in V_T$, por lo que es un generador de sí mismo 
  
  - Caso i = n, n $gt$ 0:

    Como n $gt$ 0, tenemos que X es una variable. Sea entonces la derivación $X => alpha =>^* w$, 
    es decir, la primera produccion utilizada para la derivación es $X -> alpha$. Tenemos que cada símbolo en $alpha$ genera  
    o an símbolo terminal de $w$, o a $lambda$, además, cada una de estas derivaciones toma menos de i pasos, por lo que por H.I sabemos
    que el algoritmo los reconoce como generadores. Luego, en el paso inductivo del algoritmo, el mismo va a reconocer a X como generador al considerar la producción $X -> alpha$
      


]]

#definition[Sea G una gramática, para computar los símbolos alcanzables hacemos uso de la inducción:

  - Caso base: 

      S es alcanzable 
  
  - Paso inductivo: 

      Supongamos que descubrimos que A es alcanzable, entonces tenemos que para todas las producciones con A en la cabeza, se cumple que todos los símbolos en ellas son alcanzables

]

#theorem[El algoritmo propuesto solo encuentre todos los símbolos alcanzables]

=== Eliminando producciones $lambda$
    #definition[Decimos que una variable A es anulable si $A =>_* lambda$]

    #definition[Sea G una gramática, para computar los símbolos anulables aplicamos el siguiente algoritmo iterativo: 
    
    - Base: 

        Si $A -> lambda$ es una producción de G, entonces A es anulable
    
    - Paso inductivo: 

        Si hay una producción $B -> C_1...C_k$ donde cada $C_i$ es anulable, entoces B es anulable
    ]

    #theorem[El algoritmo encuentra un símbolo A sii es anulable]

    #proof[

      - $implica)$ Por inducción en el orden en el que es encontrado 

      - $implicaVuelta)$ Por inducción en el mínimo i tal que $A ->^i lambda$:

        - Caso base i = 1: 

            En este caso tenemos que necesariamente $A -> lambda$ es una producción de G, por lo que es descubierta en el paso base

        - Caso i = n, n $gt$ 1:

            Tenemos que $A =>^n lambda$. El primer paso de la derivación debe ser del estilo $A => C_1...C_k =>^(n - 1) lambda$. Tenemos entonces que cada $C_i$ deriva en $lambda$ en menos de n pasos, por lo que, por H.I, tenemos que el algoritmo lo identifica como anulable. Finalmente, el algoritmo determina a A como símbolo anulable mediante la producción $A -> C_1...C_k$ 
    
    ]

    #theorem[Sea G = $angle.l V_N, V_T, P, S angle.r$ una GLC, existe una GLC $G ´ = angle.l V_N, V_T, P´, S angle.r$ tal que  G´ no tenga símbolos inútiles y $LenguajeDe(G´) = LenguajeDe(G) - {lambda}$]
    #proof[Primero definimos P´ (pues es la única modificación en comparación a G). 
    
    Una vez identificados los símbolos inútiles, definimos P´ tal que:

    - Por cada producción $A -> X_1 X_2 ... X_k$, con $k gt.eq 1$, sea m la cantidad de símbolos anulables en el cuerpo de la producción, entonces P´ va a tener $2^m$ versiones de esta producción, una por cada posible combinación en la que uno o más de los símbolos anulables no están presente (representando así el hecho de haber tomado estas producciones en G, y luego seguir hasta llegar a $lambda$)
    - Si tenemos que m = k, (todos los símbolos son anulables), entonces va a haber una menos, pues el caso en el que se tomaron todas hasta llegar a $lambda$ no está incluido 
    
    Queremos ahora probar que $w in LenguajeDe(G´) sii w in LenguajeDe(G) - {lambda}$. Para ello. vamos a probar primero que: 
      #align(center)[$A =>^*_(G´) w "sii" A =>^*_G w$ y $w eq.not lambda$]
    
    - $implica$)

      Tenemos $A =>^i_(G´) w$, por lo que necesariamente $w eq.not lambda$ ya que G´ no tienen producciones $lambda$. Probamos ahora por inducción sobre el largo de la derivación que $A =>^*_(G) w$:

        - Caso base i = 1: 
            En este caso tenemos que hay una producción $A ->_(G´) w$ en P´. Por como construimos G´, tenemos que G debe tener una producción $A -> alpha$ tal que los símbolos de w se encuentren en el cuerpo de la producción, y que haya cero o más símbolos anulables entre ellos, por lo que tenemos que $A =>_G alpha =>^*_G w$ (el resto de los símbolos derivan en $lambda$)
        
        - Caso i = n, n $gt 1$: 
            Tenemos entonces que la derivación es de la forma $A =>_(G´) X_1...X_k =>^*_(G´) w$. Por definición de P´, tenemos que
            la primera producción utlizada para esta derivación debe haber sido construida a partir de una producción en G del estilo $A -> Y_1...Y_j$, donde la secuencia de Ys son los Xs, ordenados, pero con cero o mas símbolos anulables entre sí. 

            Sea entonces $w = w_1...w_k$ una descomposición de $w$ tal que $X_l =>^*_(G´) w_l$. 
            Tenemos que o bien $X_l$ es una variable, o bien es un terminal, pero en ambos casos se puede aplicar la H.I, por lo que sabemos que $X_l =>^*_G w_l$.

            Con esto, podemos construir la siguiente derivación en G:
              #align(center)[$A =>_G Y_1...Y_j =>^*_G X_1...X_k =>^*_(underbrace(G, H.I)) w_1...w_k = w$]

            Donde el primer paso de la derivación proviene del uso de la priducción $A -> Y_1...Y_j$, que por lo argumentado
            anteriormente sabemos que existe. El siguiente paso proviene  de la derivación en $lambda$ de todos los símbolos anulables que no son ningunos de los $X_l$, y el último paso proviene de la derivación de estos símbolos en $w_l$, que sabemos está en G también por la H.I   
    
    
    - $implicaVuelta$) Tenemos que $A =>^i_G w$ y $w eq.not lambda$. Probamos ahora por inducción en i que esto implica $A =>^*_(G´) w$

    - Caso base i = 1:
      En este caso tenemos que $A -> w$ necesariamente es una producción de G y que, como $w eq.not lambda$, también se encuentra en G´, por lo que $A =>_(G´) w$

    - Caso i = n, n > 1:
      Tenemos entonces que la derivación es del estilo $A =>_G Y_1...Y_m =>^*_G w$. Sea entonces $w = w_1...w_m$ tal que $Y_j =>^*_G w_j$. 

      Sean $X_1...X_k$ aquellos $Y_j$ s, en orden, tales que $w_j eq.not lambda$. Tenemos que por definición de G´ que tiene una producción $A -> X_1...X_k$. 
      Necesariamente $X_1...X_k =>^*_G w$, pues aquellas variables que ahora no están presente originalmente derivaban en $lambda$ y, como cada una de las derivaciones $X_l =>^* w_l$, toma menos de n pasos, podemos usar la H.I para concluir que: 
      #align(center)[$A =>_(G´) X_1...X_k =>^*_(underbrace(G´, H.I)) w_1...w_k = w$]

  Terminamos la demostración reemplazando A por S:
      #align(center)[$w in LenguajeDe(G_1) sii S =>^*_(G´) w 
      \ sii S =>^*_G and w eq.not lambda sii w in LenguajeDe(G) - {lambda}
      $]

  ]

  === Eliminando producciones unitarias 
      #definition[LLamamos produccón unitaria a aquellas producciones de la forma $A -> B$ tal que A y B son variables]

      #definition[LLamamos parejas unitarias a todas las parejas de variables (A, B) tales que $A =>^* B$ usando solo producciones unitarias. Inductivamente: 

        - Base:
          (A, A) es una pareja unitaria para cualquier variable A 
        
        - Inductivo: 
          Sea (A, B) una pareja que ya se determinó es unitaria, y sea $B -> C$ una producción, con C una variable, entonces (A, C) es una pareja unitaria
      
      ]

      #theorem[Sea G una GLC, el algoritmo identifica una pareja unitaria (A, B) sii $A =>^*_G B$ usando solo producciones unitarias]

      #proof[
        - $implica$) inducción en el orden en el que son agragados
        
        - $implicaVuelta$) Tenemos que $A =>^i_G B$, demostramos por inducción sobre i que el algoritmo encuentra la pareja (A, B)

          - Caso base i = 0:
            Tenemos $A = B$, por lo que la pareja (A, A) es identificada en el caso base 
          
          Caso i = n, n > 0: 
            Tenemos $A =>^n_G B$ solo haciendo uso de producciones unitarias, en particular, 
            
            tenemos que la derivación es de la forma: 
              #align(center)[$A =>^(n - 1)_G C => B$]

            La derivación $A =>^(n-1)_G C$ toma menos de n pasos y solo usa producciones unitarias, por lo que, por H.I, tenemos que 
            el algoritmo identifica la pareja (A, C). Luego, como necesariamente tiene que estar la producción $C -> B$ en la gramática, el algoritmo identifica por el caso recursivo la pareja (A, B)
      ]

      #theorem[Sea G una GLC, existe una GLC $G_1 = angle.l V_N, V_T, P_1, S angle.r$ sin producciones unitarias tal que $LenguajeDe(G) = LenguajeDe(G_1)$]

      #proof[
        Definimos $P_1$ tal que no tenga producciones unitarias, para cada pareja (A, B), si $B -> alpha$ no es una producción unitaria de P, entonces $A -> alpha$ es una producción de $P_1$. 


        Ahora queda demostrar que $w in LenguajeDe(G) sii w in LenguajeDe(G_1)$
        - $implicaVuelta)$ Tenemos $S =>^*_(G_1) w$. Como cada producción en $G_1$ es quivalente a una secuencia de zero o más producciones unitarias en G, tenemos que $alpha =>^*_(G_1) beta " implica  que " alpha =>^*_G beta$ 
          . Es decir, toda paso en una derivación en $G_1$ puede ser reemplazado por uno o más pasos en G, luego $S =>^*_G w$

        - $implica)$ Tenemos que $w in LenguajeDe(G)$, por lo que sabemos que w tiene una derivación a izquierda, es decir
          $S =>_L w$. Cada vez que se hace uso de una producción unitaraia para un paso de la derivación, tenemos que la única variable en el cuerpo de la priducción se vuelva la variable
          más a la izquierda, por lo que es inmediatamente reemplazada. Por lo que podemos separar una derivación en G en una secuencia de pasos donde 0 o más producciones unitarias son seguidas por una no unitaria.
          Sin embargo, tenemos que son estos mismos pasos los simulados por $G_1$, , ya que la construcción de $P_1$ salta estas derivaciones \"intermedias\" entre las producciones no unitarias.  
          Por lo que tenemos que $S =>^*_(G_1) w$
      ]


  === Forma normal de Chomsky 

  #definition[Recordando la definición de FNC, tenemos que se trata de una GLC G tal que todas 
  sus producciones estén en una de dos formas: 

    + $A -> B C$, con todos los símbolos siendo variables 
    + $A -> a$ , con A una variable y a un terminal 

    Además, G no tiene símbolos inútiles
  ]


  #theorem[Si G es una GLC que contiene al menos una cadena además de $lambda$, entonces hay otra CFG $G_1$ tal que la misma no tiene, producciones lambda, producciones unitarias, ni símbolos inútiles, y se cumple que $LenguajeDe(G_1) = LenguajeDe(G) - {lambda}$] <tt>
  #proof[Aplicamos, en orden, los siguientes pasos: 
  
  + Eliminamos producciones $lambda$
  + Eliminamos producciones unitarias 
  + Eliminamos símbolos inútiles  
  ]


  #theorem[Si G es una GLC cuyo lenguaje contiene al menos una cadena además de $lambda$, existe una gramática $G_1$ en FNC tal que $LenguajeDe(G_1) = LenguajeDe(G) - {lambda}$]
  
  #proof[ Primero usamos @tt para conseguir una gramática $G_2$ que no tenga producciones $lambda$, producciones unitarias, ni símbolos inútiles, y que cumpla que $LenguajeDe(G_2) = LenguajeDe(G) - {lambda}$. Con esto
  ahora construimos $G_1$ de la siguiente manera: 

\
  + Por cada símbolo terminal $a$ en una producción cuyo cuerpo tenga longitud mayor a 2, creamos una nueva variable, A, y agregamos la producción $A -> a$
    , reemplazando todas las apariciones previas de $a$ por esta nueva variable 
  
  + Por cada producción $A -> B_1...B_k$, con k $gt.eq 3$ (observar que son todas variables por el paso anterior), las dividimos en un grupo de particiones introduciendo k - 2 nuevas variables 
    $C_1...C_(k -2)$, y reemplazamos la producción original por k - 1 producciones nuevas tal que se tenga: 
      #align(center)[ $A -> B_1 C_1, #h(.8em) C_1 -> B_2 C_2, #h(.8em) ... #h(.8em)  C_(k - 2) -> B_(k - 1) B_k$] 
  
  Queremos ahora probar que $w in LenguajeDe(G_2) sii w in LenguajeDe(G_1)$
  
  - $implica)$ Si w tiene una derivación en $G_2$, podemos reemplazar las producciones utilizadas en un paso arbitrario, digamos $A -> X_1...X_k$ con una secuencia de producciones en $G_1$. 

    Si $X_i$ es un terminal, entonces tenemos que $G_1$ tiene una variable $B_i$, tal que $B_i -> B_i$. Si k $gt 2$ tenemos que 
    $G_1$ tiene una secuencia de producciones $A -> B_1 C_1, #h(.8em) C_1 -> B_2 C_2 ...$ donde cada $B_i$ es o bien la variable introducida para representar al 
    terminal $X_i$ si el mismo era un terminal, o el mismo $X_i$, si se trataba de una variable en $G_2$. Como esta secuencia de producciones simulan cualquier producción 
    utilizada en algún paso de la derivación de $w$ en $G_2$, tenemos que $w in LenguajeDe(G_1)$
  
  - $implicaVuelta$)  
  ]

  == Lema de Pumping para Lenguajes Libres de Contexto 

    #lema[Sea $G = Gramática(V_N, V_T, P, S)$ una GLC con P $eq.not emptyset$, sea $alpha in (V_N union V_T)^*$ y sea $cal(T)(S)$ un árbol de derivacíon  con altura 
    h. Sea: 
    #align(center)[

      $a = max { k : (k = |beta|, A -> beta in P, beta eq.not lambda) #h(.5em) o #h(.5em) (k = 1, A -> lambda in P)}$

    ]
    Entonces $a^h gt.eq |alpha|$. (Informalmente, como mucho podemos haber usado la produccion con el cuerpo más largo en cada paso de la derivación)
    ]

    #proof[Por inducción en h. 

      - Caso base, h = 0: 
       
        El único árbol de derivación posible es aquél en el que el único nodo es S, por lo que tenemos $a^0 = 1 = |S|$

      - Paso inductivo: 
        
        Sea $gamma$ la base del árbol de altura h (es decir, su producción), tenemos que, por H.I: $a^h gt.eq gamma$. Sea $alpha$ entonces el producto Del
        árbol de altura h + 1.

        #align(center)[*Falta dibujito*]

        Tenemos que, como a lo sumo cada símbolo de $gamma$ pudo haber hecho uso de la produccion más larga (es decir, de longitud $a$) para seguir con la derivación, resulta que: 

        #align(center)[$a |gamma| gt.eq |alpha|$
        
        Por H.I, tenemos $a^h gt.eq |gamma|$, por lo que
        
        $a^(h+1) = a a^h gt.eq a |gamma| gt.eq |alpha|$]   
    
    ]

    #definition[Para todo lenguaje libre de contexto L, existe n $gt$ 0 tal que para toda cadena $alpha in L$ con $|alpha| gt.eq n$ se cumple que:

    - Existe una descomposición de $alpha$ tal que $alpha = r x y z s$

    - $|x y z| lt.eq n$

    - $|x z| gt.eq 1$

    - Para todo $i gt.eq 0$, la cadena $r x^i y z^i s$ pertenece a L. 

    ]

    #proof[Sea G una GLC tal que L = $LenguajeDe(G)$ y sea b = $ max { k : (k = |beta|, A -> beta in P, beta eq.not lambda) #h(.5em) o #h(.5em) (k = 1, A -> lambda in P)}$
    
    - Caso $a = 1$:
        En este caso, tenemos que las únicas producciones de G solo consisten o de un sólo terminal, o de $lambda$, o se tratan de producciones unitarias. Sin importar el caso, tenemos que 
        la cadena resultante de cualquier derivación en esta gramática tendrá longitud a lo sumo 1, por lo que con n $gt.eq 2$ tenemos que el antecedente del teorema es falso, por lo que el teorema en sí es trivialmente verdadero.

    
    - Caso $a gt.eq 2$:
      
      Tomemos $n = a^(|V_N| + 1)$, y consideremos la cadena $alpha$ tal que $|alpha| gt.eq n$. Sea $cal(T)(S)$ unrbol mínimo de derivación para 
      $alpha$. Tenemos que, por el lema anterior, que la altura del árbol debe ser al menos $|V_N| + 1$, pues: 

      #align(center)[$a^h gt.eq |alpha| gt.eq n = a^(|V_N| + 1) sii h gt.eq |V_N| + 1$ ]  

      Luego, necesariamente debe haber un camino hacia alguno de los símbolos de $alpha$ producidos, uno de longitud  
      $h gt.eq |V_N| + 1$, pero como solo hay $|V_N|$ variables, tenemos que debe haber alguno repetido.

      Llamemos A a alguna de estas variables que se repiten en el camino, en particular, escogemos la primera que aparezca recorriendo el árbol de manera ascendente: 

          #align(center)[*Acá falta dibujito :(*]

      La segunda aparición de A da lugar a la cadena $x y z$. Tenemos, además, que esta segunda aparición debe estar a una altura h´ $lt.eq |V_N| + 1$ de la base (por que a esa altura necesariamente tiene que haber ocurrido una repetición de alguna variable), por lo que: 
      #align(center)[$| x y z | lt.eq a^(h´)lt.eq a^(|V_N| + 1)= n$]
      
      Cumpliendo así la primera condición.

      Cuando las cadenas x y z son simultáneamente nulas, tenemos que podemos reemplazar la segunda aparición de A por la primera, "compactando" el árbol, y seguir generando a $alpha$, sin embargo,
      dijimos que $cal(T)(S)$ era el árbol mínimo que generaba $alpha$, por lo que llegamos a un absurdo. 
      El absurdo vino de suponer que z y x podían ser simultanemente nulas, por lo que con esto tenemos la segunda condición.

      #align(center)[*Falta dibuuuuu*]

      Finalmente, demostremos que $forall i gt.eq 0, r x^i y z^i s in L,$ por inducción en i:

      - Caso base i = 0: 

        Tenemos que $S =>^* r A s =>^* r y s$, por lo que necesariamente $r y s = r x^0 y z^0 s in L$
      
      - Caso i $gt 0$:
        Tenemos por H.I que $r x^i y z^i s in L$, veamos que vale para i + 1.

        Sabemos que $S =>^* r x^i A z^i s =>^* r x^i y z^i s$, pero también tenemos que, en vez de hacer que A tome el camino de producciones que deriva en $y$, puede volver a derivar $x A z$, es decir: 
        #align(center)[$S =>^* r x^i A z^i s =>^* r x^i x A z z^i s =>^* r x^(i+1) y z^(i+1) s$]

        Por lo que $r x^(i+1) y z^(i+1) s in L$
    ] 

  == Propiedades de clausura de Lenguajes Libres de Contexto (#link("https://cs.uwaterloo.ca/~s4bendav/files/CS360S22Lec10.pdf")[Link a Demos más formales])
  === Unión 
    #theorem[Si $L_1$ y $L_2$ son lenguajes libres de contexto, $L_1 union L_2$ también lo es]
    #proof[Como ambos lenguajes son libres de contexto, entonces existen $G_1$ y $G_2$ GLCs tales que $LenguajeDe(G_1) = L_1$ y $LenguajeDe(G_2) = L_2$. Supogamos, sin pérdida de generalidad, que $V_N_1 sect V_N_2 eq emptyset$ Definimos entonces la gramática G = $Gramática(V_N_1 union V_N_2 union {S}, Sigma, P_1 union P_2 union {S -> S_1, S -> S_2}, S)$
    
    Puede demostrarse fácilmente por inducción sobre el largo de la cadena $w$ que $w in LenguajeDe(G) sii w in LenguajeDe(G_1) union LenguajeDe(G_2)$

  === Concatenación 
    #theorem[Si $L_1$ y $L_2$ son lenguajes libres de contexto, $L_1 L_2$ también lo es]

    #proof[Como ambos lenguajes son libres de contexto, entonces existen $G_1$ y $G_2$ GLCs tales que $LenguajeDe(G_1) = L_1$ y $LenguajeDe(G_2) = L_2$. Supogamos, sin pérdida de generalidad, que $V_N_1 sect V_N_2 eq emptyset$ Definimos entonces la gramática 
    G = $Gramática(V_N_1 union V_N_2 union {S}, Sigma, P_1 union P_2 union {S -> S_1 S_2}, S)$
    
    Puede demostrarse fácilmente por inducción sobre el largo de la cadena $w$ que $w in LenguajeDe(G) sii w in LenguajeDe(G_1) LenguajeDe(G_2)$]
    ]

  === Clausura de Kleene
    #theorem[Si $L$ es un lenguaje libre de contexto, $L^*$ también lo es]
    #proof[Como $L$ es un lenguaje libre de contexto, existe G GLC tal que $LenguajeDe(G) = L$. Sea entonces G´ = $Gramática(V_N, Sigma, P union {S -> S S´ | lambda}, S´)$
    
    Solo queda demostarr que $w in LenguajeDe(G) sii w in L^*$
    ]

  === Reversa

    #theorem[Si L es un lenguaje libre de contexto, también lo es $L^R$]
    #proof[Sea G una GLC cuyo lenguaje es L, construimos $G^R = Gramática(V_N, Sigma, P^R, S)$ donde $P^R$ es el \"reverso\" de cada producción en P. De manera más específica, 
    si $A -> alpha$ es una producción en G, entonces $A -> alpha^R$ lo es en $G^R$.

    Queda demostrar, por inducción en la cantidad de pasos de la derivación, que $LenguajeDe(G^R) = L^R$
    ]
  
  === Intersección 
    #theorem[Los lenguajes libres de contexto no están cerrados respecto de la intersección]
    #proof[
      Tenemos que $L = {0^n 1^n 2^n | n gt.eq 1}$ no es libre de contexto, pero $L_1 = {0^n 1 ^n 2 ^i | n, i gt.eq 1}$
      y $L_2 = {0^i 1 ^n 2 ^n | n, i gt.eq 1}$ lo son. 
    ]

  === Complemento 
    #theorem[Los lenguajes libres de contexto no son cerrados respecto del complemento]
    #proof[Si lo fueran, entonces $L_1 sect L_2 eq overline(overline(L_1) union overline(L_2))$ lo sería]

  === Diferencia 
    #theorem[$L_1$ - $L_2$ no es necesariamente libre de contexto]
    #proof[Si lo fuera, entonces, como sabemos que $SigmaEstrella$ es libre de contexto, deberíamos tener que $SigmaEstrella - L = overline(L)$ es libre de contexto]

  === Intersección con un lenguaje regular 
    #theorem[Si L es un lenguaje libre de contexto, y R uno regular, entoces $L sect R$ es libre de contexto]
    #proof[Sea $P = angle.l Q_P, Sigma, Gamma, delta_P, q_P, Z_0, F_P angle.r$ un autómata de pila para L, y $M = angle.l Q_M, Sigma, delta_A, q_A, F_A angle.r$ un AFD para R, construimpos el APD \  $P´ = angle.l Q_P times Q_M, Sigma, Gamma, delta, (q_P, q_A), Z_0, F_P times F_A angle.r$, donde: 
    
    - $delta((q, p), a, X) = {((r,s), gamma) : s = deltaSombrero_A (p, a) and (r, gamma) in delta_P (q, a, X)}$

    Queda demostrar, por inducción sobre la cantidad de movimientos, que $(q_P, w, Z_0) tack.r^*_P (q, lambda, gamma) sii ((q_P, q_A), w, Z_0) tack.r^*_(P´) ((q, deltaSombrero_A (q_A, w)), lambda, gamma)$. 
     
     ]
  
  == Problemas de decisibilidad para Lenguajes Libres de contexto 
    - Determinar si un Lenguaje es vacío se puede hacer en orden lineal respecto al tamaño de la representación 
    - Determinar si una cadena pertenece a un lenguaje se puede hacer en orden cúbico
    - Determinar si un lenguaje libre de contexto es finito o infinito
    - Los siguientes problemas no son decidibles: 
      - Determinar si una GLC es ambigua 
      - Determinar si un Lenguaje libre de contexto es inherentemente ambiguo 
      - DEterminar si la intersección de dos lenguajes libres de contexto es ambigua
      - Determinar si dos lenguajes libres de contexto son iguales
      - Determinar si un lenguaje libre de contexto es $SigmaEstrella$

= APDs y LCs Determinísticos 


  Recordemos la definición de un APD determinístico 

  #definition[Un autómata de pila $P = #apd,$ con: 
  #align(center)[$delta: Q times (Sigma union {lambda}) times Gamma -> PartesDe(Q times Gamma^*) $]
  es determinístico si para cada $a in Sigma, q in Q, Z in Gamma$:

  - $delta(q, a, Z)$ contiene a lo sumo un elemento y $delta(q, lambda, Z)$ es $emptyset$
  O
  - $delta(q, a, Z) = emptyset$, y $delta(q, lambda,Z)$ contiene a lo sumo un elemento
  Para facilitar la notación, vamos a escribir $delta(q, a, Z) = (r, gamma)$ en vez de $delta(q, a, Z) = {(r, gamma)}$
  ]

== APDs determinísticos capaces de leer toda la cadena
  #lema[Sea $P = apd$ un APD determinístico. Es posible construir un APD determinístico equivalente P´ tal que: 
    
    + Para todo $a in Sigma, q in Q´, Z in Gamma´$: 
      
      a) O bien $delta´ (q, a, Z)$ contiene exactamente un elemnete y $delta´(q, lambda, Z) = emptyset$

      b) O bien $delta´ (q, a, Z)  = emptyset$ y $delta´ (q, lambda, Z)$ contiene exactamente un elemento 

    + Si $delta´(q, a, Z_0´) = (r, gamma)$, entonces $gamma = alpha Z_0´, alpha in Gamma*$
  
  ] <lee>

  #proof[La idea es usar como marcador a $Z_0´$ para evitar que se vacíe la pila. Sea $Gamma´ = Gamma union {Z_0´}, Q´ = Q union {q_0´, q_lambda}. delta´$ queda definida como: 
  
    + $delta´(q_0´, lambda, Z_0´) = (q_0, Z_0 Z_0´)$

    + $forall q in Q, Z in Gamma, a in Sigma union {lambda}$ tales que $delta(q, a,  Z) eq.not emptyset$, tenemos que $delta´(q, a,  Z) = delta(q, a,  Z)$

    + Si $delta(q, lambda, Z) - emptyset " y " delta(q, a, Z) = emptyset$, entonces $delta´(q, a, Z) = (q_lambda, Z)$

    + $forall a in Sigma, Z in Gamma´, delta´(q_lambda, a, Z) = (q_lambda, Z)$

    Queda probar que $LenguajeDe(P) = LenguajeDe(P´)$
  ]

== Configuraciones ciclantes
  #definition[Decimos que una configuración $(q, w, a)$ de un APD  determinístico P está en un ciclo si, $forall i, i gt.eq 1$, esiste una configuración $(p_i, w, beta_i)$ tal que $|beta_i| gt.eq |alpha|$ y:
  
  #align(center)[$(q, w, alpha) tack.r (q_1, w, beta_1) tack.r (q_2, w, beta_2) ... $]

  Es decir, una configuración está en un ciclo si P puede hacer una cantidad infinita de movimientos $lambda$ sin reducir el tamaño de la pila
  
  ] <cicla>

  #definition[El siguiente algoritmo detecta configuraciones ciclantes: 
 
  Input: Un APD deterministico P = #apd

  Output: Dado por los siguientes dos conjuntos 
    + $C_1 = {(q, A) | (q, lambda, A) " es una configuración ciclante, y" exists.not r in F " tal que" (q, lambda, A) tack.r^* (r, lambda, alpha)}$
    + $C_2 = {(q, A) | (q, lambda, A) " es una configuración ciclante y" (q, lambda, A) tack.r (r, lambda, alpha), "para algún estado final "r}$
  
  Método: 
    Sea $\#Q = n_1, \#Gamma = n_2, y #h(.5em) l$ es la longitud de la cadena más larga que P puede escribir en la pila en un sólo movimiento. 
    Sea $n_3 = n_1 (n_2^(n_1 n_2 l) - n_2) / (n_2 - 1)$. $n_3$ es la máxima cantidad de movimientos $lambda$ que P puede hacer sin ciclar. 

    + Por cada $q in Q y A in Gamma$ determinar si $(q, lambda, A) tack.r^(n_3) (r, lambda, alpha), $para algún $r in Q, alpha in Gamma^+$. Caso positivo, $(q, lambda, A)$
      es una configuración ciclante
    + Si $(q, lambda, A)$ es una configuración ciclante, determinar si existe algún $r in F$ tal que $(q, lambda, A) tack.r^j (r, lambda, alpha), 0 lt.eq j lt.eq n_3.$ Caso positivo, agregarlo a $C_2$, caso negativo, a $C_1$

  ]

  #theorem[El algoritmo correctamente determina $C_1$ y $C_2$]

  #proof[*Pendiente*]

  == APDs determinísticos continuos
    #definition[Un APD deterministico P = #apd es continuo si para todo $w in SigmaEstrella, exists p in Q, alpha in Gamma^*$ tal que $(q_0, w, Z_0) tack.r^* (p, lambda, alpha).$ En otras palabras, se trata de un autómata que siempre consume toda la cadena de entrada]

    #lema[Sea P = #apd un APD determinístico, existe otro P´ tal que el mismo sea equivalente y continuo]
    #proof[Supongamos, por @lee, que P siempre tiene un siguiente movimiento. Sea $P´ = (Q union {p, r}, Sigma, Gamma, delta´, q_0, Z_0, F union {p})$, con $delta´$ definida por: 

      + $forall q in Q, a in Sigma, Z in Gamma,  delta´(q,a, Z) = delta(q, a, Z)$
      + $forall q in Q, a in Sigma, Z in Gamma$ tales que $(q, lambda, Z)$ no sea una configuración ciclante, entonces $delta´(q, lambda, Z) = delta(q, lambda, Z)$
      + Para todo $(q, Z) in C_1, delta´(q, lambda, Z) = (r, Z)$
      + Para todo $(q, Z) in C_2, delta´(q, lambda, Z) = (p, Z)$
      + Para todo $a in Sigma, Z in Gamma, delta´(p, a , Z) = (r, Z)$ y $delta´(r, a, Z) = (r, Z)$

      De esta manera, P´ simula P. Si se entra a una configuración ciclante en P cuyo ciclo pasaba por un estado final, ahora va a ir a parar directamente a p, (desde donde si todavía no consumió toda la cadena va al estado r)  caso contrario va a r directamente, donde va a terminar de consumir la cadena.
    
    ]

  == Clausura de APDs determinísticos bajo complemento 

  #theorem[Si L = $LenguajeDe(P)$ para algún APD determinístico P, entonces $overline(L) = LenguajeDe(P´)$ para algún APD determinístico P´
  
  
  
  ] 

  #proof[Sea P = #apd continuo. Definimos \ P´ = $angle.l Q´, Sigma, Gamma, delta´, q_0´, Z_0, F´angle.r$ donde: 
  
      #align(center)[Q´ = {[q, k]: q in Q and k in {0,1,2}}]

    El propósito de k es indicar si entre transiciones con consumo de entrada en P pasó o no por un estado final

      #align(center)[$q_0 = cases([q_0, 0] "si" q_0 in.not F, [q_0, 1] "si" q_0 in F)$ \ 
     
      $F´ = {[q, 2]: q in Q}$
      ]

    0 indica que P no pasó por F

    1 indica que P sí paso por F 

    2 indica que P no pasó por F y P va a seguir leyendo 
  
  Para todo $q in Q, [q, 2]$ es un estado final al que llega P´ antes que P lea un nuevo símbolo 

  La función de transición $delta´$ queda definidda por:

    - Si P lee desde q un símbolo $a, delta(q, lambda, Z) = emptyset, y , delta(q, a, Z) = (p, gamma)$ entonces

      $delta´([q, 0], lambda, Z) = ([q,2], Z)$

      P´ acepta la entrada antes de leer $a$ porque P no la aceptó, 

      #align(center)[$delta´([q, 1], a, Z) = delta´([q, 2], a, Z) = cases(([p, 0], gamma) "si" p in.not F, ([p, 1], gamma) "si" p in F)$]

    - Si P no lee desde q símbolo $a, delta(q, lambda, Z) = (p, gamma) , y, delta(q, a, Z) = emptyset$ entonces: 

      #align(center)[$delta´([q, 1], lambda, Z) = ([p,1], gamma) \ 
                    \ 
                    delta´([q,0], lambda, Z) = cases(([p, 0], gamma) "si" p in.not F, ([p,1], gamma) "si " o in F) $]

    Para terminar, ahora queda ver que $delta(q_0, w, Z_0) in $

  ]

  = Máquinas de Turing 
    *Por ahora solo voy a dejar los teoremas y lemas sin probarlos*

    #definition[Una Máquina de Turing (MT) es una tupla $M = angle.l Q, Sigma, Gamma, delta, q_0, B, F angle.r$ donde: 

      - $Q$ es el conjunto finito de estados del controlador finito (o cabeza)
      - $Sigma$ es el conjunto finito de símbolos de entrada 
      - $Gamma$ es el conjunto de símbolos de cinta; $Sigma$ es siempre un subconjunto de $Gamma$
      - $delta$ es la función de transición. Los argumentos de $delta(q, X)$ son un estado q y un símbolo de cinta $X$ y su valor, si está definido, es una tripla $(p, Y, D)$ tal que: 
        
        - $p in Q$ es el siguiente estado 
        - $Y in Gamma$ es el ßimbolo escrito en la celda siendo escaneada, reemplazando cualquier símbolo que estuviese ahí
        - D es una dirección, L o R, denotando \"derecha\" o \"izquierda\", indicando la dirección en la que se mueve la cabeza
      - $q_0 in Q$ es el estado inicial 
      - $B in Gamma, in.not Sigma$ es el símbolo denotando una celda blanca
      - $F subset Q$ es el conjunto de estados finales  
    
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

  
  + Sea N un AFND tal que tenga a lo sumo una opción para cualquier estado y símbolo \ (es decir, |$delta(q, alpha)| lt.eq 1$), entonces el AFD D reducido (es decir, solo consiste de aquellos estados alcanzables) construido tiene la misma cantidad de transiciones y estados más las trancisiones necesarias para ir a un  nuevo estado trampa cuando una transición no esté definida para un estado particular 

    #rect[ \ #align(center)[#proof[
      Voy a justificar este hecho, debería pensar un poco más como demostrarlo más formalmente. 

      Como tenemos que para cada estado q de N y símbolo $a in Sigma$ se cumple que $|delta_N (q, a)| lt.eq 1$, tenemos que aquellos subconjuntos de $PartesDe(Q_N)$ de tamaño mayor a 1 no van a ser alcanzables en D, pues 
      si lo fuesen implicaría que en N había una transición que permitía llegar a los dos \"al mismo tiempo\". Luego, tenemos que: 

      #align(center)[$delta_D ({q_i, ..., q_k}, a) = union.big^k_(l=i) delta_N (q_l, a)$ 

        (Por lo argumentado antes, i = k necesariamente)

        $delta_D ({q_i}, a) = delta_N (q_i, a)$
      
      ]

      Notemos ahora que, por un lado, las transiciones que estaban definidas originalmente se mantienen, pero también hay un nuevo estado alcanzable $emptyset$, en el caso de aquellas transiciones que no 
      iban a ningún estado originalmente

    ]]]
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
      
        La cantidad de transiciones puede ser acotada por k + (k + 1)|w|, donde k es la cantidad de transiciones $lambda$ del autómata.

        La justificación es como sigue: Sea p un camino en el grafo entre $q_0$ y algún estado final tal que reconozca la cadena $w$ (sí, me gustaría sacar algo más parecido a las demos de la materia), tenemos que el mismo debe ser del estilo 
        $p_0e_0p_1e_1...p_(|w|)e_(|w| + 1)p_(|w| + 1),$ donde cada $e_i$ representa atravesar un arco que consuma la cadena, y cada $p_i$ consiste solamente de transiciones $lambda$. Tenemos que, si algúna de los ejes con transiciones $lambda$ se repite en algún $p_i$
        , siempre se puede existe otro camino en el que no se repite (esencialmente evitar el ciclo), y como no aportaba al reconocimiento de la cadena, podemos hacerlo sin problemas.  luego, cada $p_i$ puede tener a lo sumo un recorrido de longitud k (pues es la cantidad de transiciones $lambda$ distintas)
        Por lo que tenemos (|w| + 1)k por todos los $p_i$ y |w| por todos los $e_i$.
      ] \ ]]
  + Sea  $E = angle.l Q, Sigma, delta, q_(0), {q_f} angle.r$ un AFND-$lambda$ tal queno haya transiciones hacia $q_0$ ni desde $q_f$. Describir los lenguajes que se obtienen a partir de las siguientes modificaciones: 

      a) Agregar una transición $lambda$ desde $q_f$ hacia $q_0$ \

      #rect()[
        
        #align(center)[$L^+$]
      ]
      b) Agregar una transición $lambda$ desde $q_0$ hacia cada estado alcanzables desde $q_0$ (notar que no es sólo aquellos directos) \

      #rect()[
        Sufijo(L)
      ]

      c) Agregar una transición $lambda$ hacia $q_F$ desde cada estado que tiene un camino  hacia $q_f$ \

      #rect()[
        
        #align(center)[prefijo(L)]
      ]
      d) El autómata obtenido haciendo b) y c) 

      #rect()[
        
        #align(center)[Sub(L)]
      ]
    
  + Demostrar que los lenguajes regulares son cerrados respecto de la concatenación y la clausura de Kleene mediante la construcción de un autómata.

  + Demostrar que los lenguajes regulares son cerrados respecto de la diferencia de conjuntos.

  + Demosstrar que los lenguajes regulares son cerrados respecto al reverso del lenguaje, donde el reverso está definido como el lenguaje formado por el reverso de todas sus cadenas. 

  + Idem para homomorfismos y sus inversos (?

  + Sea L un lenguaje regular, y $a$ un símbolo, llamamos L/$a$ al cociente de L y a al conjunto de cadenas $w$ tales que $w a in L$. Por ejemplo, si L = {a, aab, baa} entonces L/a = {$lambda$, ba}. Demostrar que si L es un lenguaje regular, entonces L/a también.

    #rect()[
      \
      #align(center)[#proof[Construimos un nuevo autómata tal que, con excepción de F, es igual, y definimos F´ como el conjunto de estados p tales que $delta(p, a) in F$. Luego, tenemos que $delta´(p, w) in F sii delta(p, w a ) in F$]
      
      \ ]
    ]

  + De manera similar, probar que a \\ L es un lenguaje regular, donde a \\ L es el conjunto de cadenas $w$ talesque a$w in L$

    #rect()[
      \
      #align(center)[#proof[ $ a w in L sii w^r a in L^r sii w^r in L^r \/ a sii w in (L^r \/ a)^r$
      
      Y como tenemos que los lenguajes regulares son cerrados bajo todas estas operaciones, tenemos que el lenguaje resultante es regular. 
      
      (No pensé si había algún método más directo, debería considerarlo) ]]
      
      \ ]


  + Demostrar que los lenguajes regulares son cerrados respecto de las siguientes operaciones:

    a) $min(L) = {w | w in L$ y no existe $alpha$ tal que $alpha  w in L$}

      #rect()[
      \
      #align(center)[#proof[Eliminando todas las transiciones saliendo de estados finales mediante un estado trampa]
      
      \ ]
    ]


    b) $max(L) = {w | w in L$ y no existe $alpha eq.not lambda$ tal que $w alpha in L$}

    #rect()[
      \
      #align(center)[#proof[]
      
      \ ]
    ]

    c) init(L) = ${w | "Para algún " x, w x in L}$

  + La mayoría de los ejs de la sección 4.2 (Me dió fiaca seguir copiando xd) 

  + Sea L un lenguaje regular, y sea n la constante del Lema de Pumping para L. Determinar veracidad y demostrar: 

    a) Para cada cadena z en L, con $|z| gt.eq n$, la descomposición de $z$ en $u v w$, con $|v| gt.eq 1$ y $|u v| lt.eq n$, es única. 
    
      #rect()[
      \
      #align(center)[#proof[Falso.
      ]
      
      \ ]
    ]

    b) Cada cadena $z$ en L, con $|z| gt.eq n$, es de la forma $u v^i w$ para algún $u, v, w$ con $|v| gt.eq 1$ y $|u v| lt.eq n$ y algún i 

      #rect()[
      \
      #align(center)[#proof[verdadero. 
      
      Como tenemos que L es regular, cualquier cadena de laogitud al menos n cumple las condiciones del lema de pumping
      
      ]
      
      \ ]
    ]

    c) Hay lenguajes no regulares que satisfacen la condición afirmada por el Lema de Pumping 

      #rect()[
      \
      #align(center)[#proof[verdadero. 
      
      
      ]
      
      \ ]
    ]

    d) Sean $L_1, L_2$ lenguajes sobre el alfabeto $Sigma$ tal que $L_1 union L_2$ es un lenguaje regular.
    Entonces $L_1 $ y $L_2$ son regulares.

      #rect()[
      \
      #align(center)[#proof[Falso. 
      Esto no es necesariamente cierto. Por ejemplo, si tomamos $L_1$ como un lenguaje no regular, y $L_2$ como su complemento, tenemos que su union es regular, pues $Sigma^*$ es regular pero que $L_1$ no.
      
      ]
      
      \ ]
    ]


  + Sea $cal(C)$ el mínimo conjunto que contiene todos los lenguajes finitos, y está cerrado por unión finita, intersección, complemento, y concatenación ¿Cuál es la relación entre $cal(C)$ y el conjunto de todos los lenguajes regulares? 

    #rect()[
      \
      #align(center)[#proof[

        De este no tengo mucha idea, puede ser que $cal(C)$ pueda generar cualquier lenguaje regular, pero no estoy seguro. 
      ]
      
      \ ]
    ]

  + Dar un algoritmo de decisión que determine si el lenguaje aceptado por un autómata finito es el conjunto de todas las cadenas del alfabeto 

    #rect()[
      \
      #align(center)[#proof[
      
      Una opción es armarse el automata para $Sigma^*$, y después determinar si los dos son iguales. Otra opción es tomar el complemento y ver si es $emptyset$.
      ]
      
      \ ]
    ]

  + Dar un algoritmo de decisión que determine si el lenguaje aceptado por un autómata finito es cofinito 

    #rect()[
      \
      #align(center)[#proof[Tomas el complemento del lenguaje y verificas si el mismo cumple las condiciones necesarias de infinitud]
      
      \ ]
    ]

  + Demostrar que todo lenguaje regular es libre de contexto. *Pista*: construir una gramática mediante inducción en la cantidad de operadores de una expresión regular

      #rect()[
      \
      #align(center)[#proof[Se puede construir una GLC inductivamente a partir de una e.r r: 
      
      - Caso $r = emptyset$: 

        Este no estoy seguro si con simplemente no agregar nada basta 

      - Caso $r = a$: 

        $S -> a$

      - Caso $r = lambda$: 

        $S -> lambda$ 

      - Caso $r = v | t$: 

        $S -> V | T$ 

      - Caso $r = v t$: 

        $S -> V T$ 

      - Caso $r = v^*$:


        $S -> S´$

        $S´ -> V S´ | lambda$ 


      quedaría demostrar que $w in LenguajeDe(G) sii w in LenguajeDe(r)$
      ]
      
      \ 
      ]

    ]
     
  + Una GLC es linear a derecha si el cuerpo de cada producción  tiene a lo sumo una variable, y la misma aparece más a la derecha. Es decir, todas las producciones son de la forma $A -> w B$ o $A -> w$.
    s
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
  
    #rect[
      \ 
      #align(center)[
        #proof[ 
\
          Se puede demostrar por inducción sobre la cantidad de pasos en la derivación. Como caso base m = 1 y es obvio q vale. En paso inductivo, se puede seguir las ideas de las demostraciones de quivalencias de derivaciones y árboles para separar la primera derivación en varios $X_i s$ para poder aplicar la H.I. (*Queda pendiente terminar bien este ejercicio*)
        
        ]

      ]

    ]

    

  + Supongamos lo mismo que en el ej anterior, pero ahora puede haber producciones con $lambda$ en la derecha. Demostrar que un árbol de derivación para $w eq.not lambda$ puede tener a lo sumo $n + 2m - 1$ nodos.

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

  + Demostrar que si P es un APD, entonces existe un APD $P_1$ de un solo estado tal que $LenguajeDe_lambda (P) = LenguajeDe_lambda (P_1)$

  + Suponiendo que P es un APD tal que tiene s estados, t símbolos de pila, y ninguna regla en la cual lo que se apila tenga longitud mayor a u, dar una cota ajustada para la cantidad de variables en la GLC construida según el metodo de la demo.

  + Existe, para todo lenguaje libre de contexto sin $lambda$, una gramática tal que todas sus producciones son 
    de la forma $A -> B C D$ (un cuerpo con sólo tres variables) o $A -> a$ (cuerpo con sólo un terminal)? Demostrar o dar contraejemplo (*Si no usaaste la sección de FNC salteate este*)

  + Hacer el ej 7.1.11 del libro de Hopcraft 

  + Sea L un lenguaje. Si todas las cadenas de L validan el lema de pumping para lenguajes libres de contexto, ¿Se puede concluir que L es libre de contexto?
  + Sea L un lenguaje regular. Demostrar que todas las palabras de L validan el Lema de Pumping para lenguajes libres de contexto
  + Mostrar que $L = {a^p: p " es número primo"}$ no es libre de contexto. *Pista*: Asumir L libre de contexto, y sea n la longitud dada 
    por el lema de pumping. Sea m el primo mayor o igual a n, considerar $alpha = a^m$ y bombear m+1 veces
  
  + Demostrar que hay lenguajes que pueden ser reconocidos con un autómata de dos pilas pero no por uno con sólo una pila. 

  + Demostrar que los lenguajes libres de contexto son cerrados respecto de las siguientes operaciones: 
    - Ini(L). *Pista:* Comenzar con una FNC para L 
    - L / a. *Misma que antes*

  
  + Completar las demostraciones de propiedad de clausuras para lenguajes libres de contexto
  + Eks 7.3.4 y 7.3.5 del libro 
  + Dar algoritmos para decidir si: 

    a) L es finito 
    b) L contiene al menos 100 cadenas 
    c) Dada una GLC G y una variable A, decidir si A es el primer símbolo en alguna forma sentencial 

  + Demostrar que para cualquier GLC, todos los árboles de derivación oara cadenas de longitud n tienen $2n - 1$ nodos internos 
