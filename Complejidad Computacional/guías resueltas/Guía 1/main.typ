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

#set page(width: 16cm, height: auto, margin: 1.5cm)
#set heading(numbering: "1.1.")
#set text(lang: "es")

= Guía 1: Complejidad Computacional
  Resumen y soluciones a los ejercicios de la primera guía.


== Ejercicio 1
  *Queda pendiente pasarlo acá*

== Ejercicio 2 

  El ejercicio en realidad nos pide buscar una función $g$ que sirva como $Theta$ de $f$, yo en este ejercicio voy a identificar solamente $O$ por una cuestión de vagancia de escribir de más, pero la idea es principalmente la misma, y solo queda considerar una cota inferior. 

  - $a)$ El ejercicio nos pide identificar $g$ para $f(n) = f(n-1) + 10$. Propongo $g(n) = n$ y lo pruebo por inducción.
    #proof[Primero tengamos claro que tenemos que, mi hipótesis es que, a partir de un cierto $n_0$ hay una constante c tal que se cumple que 
    
    #align(center)[$f(n) <= c n,  forall n >= n_0$]
    
    Suponiendo en un principio que mi hipótesis vale para todo $m < n$, tenemos que 
      #align(center)[$f(n) = f(n-1) + 10 lt.eq_(H I) c(n-1) + 10 = c n - c + 10 <=_("Con c mayor a 10") c n$]
    
    Luego, tenemos que cualquier $c >= 10$ cumple con la condición. Nos queda ver un caso base, que es trivial ver que vale (Notar también que graciar a que podemos elegir un $n_0$ a partir del cual vale la hipótesis, no habría problema con que haya una cantidad finita de naturales anteriores que no la cumplan)
    ]

  - $b)$ Ahora tenemos $f(n) = f(n - 1) + n$, propongo $g(n) = n^2$, la demo es similar
  - $c)$ Ahora tenemos $f(n) = 2f(n - 1)$, propongo $g(n) = 2^n$, la demo es similar

  - $d)$ Ahora tenemos $f(n) = 2f(n/2) + 10$, por el caso 1 del teorema maestro, tenemos que $f(n) = Theta(n)$
  - $e)$ Ahora tenemos $f(n) = 2f(n/2) + n$, por el caso 2 del teorema maestro, tenemos que $f(n) = Theta(n log n)$
  - $f)$ Ahora tenemos $f(n) = 3f(n/2) + n^3$, por el caso 3 del teorema maestro, tenemos que $f(n) = Theta(n^3)$

== Ejercicio 3\
  




