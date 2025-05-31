#import "globals.typ": *

== Outline <touying:hidden>

#components.adaptive-columns(outline(title: "Índice", indent: 1em, depth: 1))

= Introducción

== Motivación
Modelamiento de tráfico vehicular urbano para el desarrollo de _Gemelos Digitales_ para ciudades.

#figure(
  image("images/ejemplo-simulacion.png", width: 70%)
)

#speaker-note(
  [La idea de esta tesis nace del proyecto de implementación de una plataforma generadora de Gemelos Digitales para ciudades por parte del Barcelona Supercomputing Center. Para poder generar un gemelo digital de una ciudad, es necesario poder modelar su tráfico vehicular, ya que esto determina gran parte de las interacciones y dinámicas de una ciudad.]
)

== SUMO
- Herramienta de simulación de tráfico continuo y microscópico diseñado para manejar grandes redes de caminos @SUMO. 
- Es portable, de código abierto y puede importar redes desde diversas fuentes.
- Las redes de caminos se representan como grafos de nodos y aristas unidireccionales que representan calles y veredas.

#speaker-note(
  [Para este trabajo en particular, decidí enfocarme en el software SUMO, dada su alta portabilidad y por su apertura de código, además de su compatibilidad con redes de caminos de diversas fuentes para simular.]
)

#figure(
  scale(
    x: 80%,
    y: 80%,
    diagram(
      spacing: (10mm, 5mm),
      node-stroke: 1pt,
      edge-stroke: 1pt,
      node((-1,-2), "Red de caminos", name:<1>, width: 40mm),
      node((-1,-1), "Rutas", name: <2>, width: 40mm),
      node((-1,0), "Tiempo de inicio", name: <3>, width: 40mm),
      node((-1,1), "Tiempo de fin", name: <4>, width: 40mm),
      node((-1,2), "Otros elementos", name: <5>, width: 40mm),
      edge((-1,-2), "r,d,d,r", "-|>"),
      edge((-1,-1), "r,d,r", "-|>"),
      edge((-1,0), "r", "-"),
      edge((-1,1), "r,u,r", "-|>"),
      edge((-1,2), "r,u,u,r", "-|>"),
      node((1,0), "Simulación (SUMO)", name: <6>),
      node((3,-1), "Estadísticas de uso de la red", name: <7>, width: 50mm),
      node((3,0), "Estados de la red", name: <8>, width: 50mm),
      node((3,1), "Salida de detectores", name: <9>, width: 50mm),
      edge((1,0),"r,u,r", "-|>"),
      edge((1,0),"r,r", "-|>"),
      edge((1,0),"r,d,r", "-|>"),
      ),
  ),      
  caption: [(adaptado de @Krajzewicz2003)]
)


== Problema

=== Pruebas de escalabilidad en SUMO basadas en el tamaño de la red

#figure(
  grid(
    columns: 2,
    gutter: 1fr,
    image("images/s_time_edges.png"),
    image("images/cpu_edges.png")
  )
)

=== Pruebas de escalabilidad en SUMO basadas en la carga de tráfico vehicular

#figure(
  grid(
    columns: 2,
    gutter: 1fr,
    image("images/s_time_freq.png"),
    image("images/cpu_freq.png")
  )
)

=== Planteamiento del Problema

- Existe un crecimiento exponencial respecto a los tiempos de ejecución en relación a la frecuencia de inserción de vehículos en las simulaciones (a mayor carga, mucho mayor el tiempo de simulación).
- En cada simulación, se ocupa el 100% de los recursos asignados.
- La escalabilidad se ve afectada para simulaciones que contemplen una gran cantidad de agentes en áreas extensas

#linebreak()
#linebreak()
#linebreak()
#align(center)[Pero, *¿y si paralelizamos?*]


== Preguntas de investigación

- ¿Cómo se diferencian en cuanto a _performance_ la versión secuencial de simulaciones en SUMO respecto a una versión paralelizada?
- ¿Es posible mejorar la _performance_ de simulaciones de tráfico vehicular urbano en orden de poder simular áreas metropolitanas completas a nivel microscópico?
- ¿Cómo se comporta la influencia de la carga vehicular a simular en la _performance_ de las simulaciones paralelizadas?

#focus-slide(
  text(
    [Es posible aumentar la escalabilidad de las simulaciones de alta granularidad mediante la paralelización de los procesos del _software_ SUMO en un ambiente de supercomputación, incrementando el _speedup_ de éstos en al menos un 5% de los tiempos de simulación secuenciales, optimizando así el uso de recursos para simulaciones que contemplen áreas metropolitanas de gran extensión y alta carga de tráfico vehicular.],
    size: 28pt
  )
)



== Objetivos
=== Objetivo general

Avanzar en el estado del arte acerca de la paralelización de procesos de simulación de tráfico urbano para supercomputadores, estudiando la escalabilidad de dichos procesos luego de su paralelización.
#pagebreak()
=== Objetivos específicos

+ Aplicar la contenerización de SUMO en _Singularity Containers_ para su ejecución en supercomputadores.
+ Diseñar e implementar un modelo de paralelización de los procesos contenerizados, determinando los parámetros necesarios para la efectiva comunicación y sincronización entre los procesos.
+ Medir la escalabilidad de la solución implementada y comparar con las mediciones previamente realizadas.

= Solución propuesta

== Trabajos relacionados

- Modelo de particiones de mapa simplificadas para la simulación en paralelo de tráfico en zonas urbanas @Arroyave2018
  - Incrementa el nivel de error de la simulación de manera proporcional con el número de particiones realizadas.
- QarSUMO: una versión paralelizada de SUMO orientada a computadores personales @Chen2020
  - Incrementa la eficiencia de las simulaciones.
  - Posee un alcance limitado al no estar orientado a entornos de _High-Performance Computing_.
  - Disminuye el nivel de granularidad de las simulaciones.

#focus-slide(
  text(
    [A partir de esto, se plantea un modelo de paralelización orientado a supercomputadores que haga uso de un algoritmo de particiones de grafos (_SPartSim_), y que a partir de la contenerización de instancias de SUMO ejecute distintos nodos de simulación con una partición asignada.],
    size: 28pt
  )
)

== Diseño de la solución
=== Herramientas a utilizar
#linebreak()
#linebreak()
#figure(
  grid(
    columns: 3,
    column-gutter: 1fr,
    align: center,
    image("images/SUMO-Logo-4024430496.png", width: 120%),
    image("images/singularity.png", width: 60%),
    image("images/openmp-logo-1404253148.png", width: 90%)
  )
)

== Partición de mapas
- Se hizo uso de una implementación del algoritmo _SPartSim_ @SPartSim, el cual ejecuta una división por zonas geográficas.
- Se debió implementar un módulo de compatibilidad con archivos `XML` de SUMO, dado que originalmente la implementación sólo recibía archivos `GeoJSON`. 

#figure(
  diagram(
      spacing: (10mm, 5mm),
      node-stroke: 1pt,
      edge-stroke: 1pt,
      node((-10, 0), `XML File`, name: <1>, width: 20mm),
      node((-6, 0), `XMLGraph

- String version
- double limitTurnSpeed
- NetLocation location
- List<NetType> types
- List<NetEdge> edges
- List<NetJunction> junctions`, name: <2>, width: 100mm),
  node((-2, 0), `Graph
  
- Map<Integer, Vertex> vertices
- Map<Integer, Edge> edges`, name: <3>, width: 70mm),
  edge(<1>, <2>, "-|>", label: `read()`),
  edge(<2>,<3>, "-|>", label: `parse()`)
  )
)

== Generación y partición de rutas
- Se evaluaron dos opciones para la generación de rutas vehiculares:
  + Generar rutas a partir de datos reales de movilidad urbana
  + Generar rutas de manera pseudo-aleatoria por medio de _randomTrips.py_ (herramienta provista por SUMO).
- Por simplicidad y para propósitos generales del trabajo, se eligió la segunda opción.
- Para la partición de las rutas generadas, se hizo uso de la herramienta _cutRoutes.py_ provista por SUMO, además de las particiones de mapa generadas a partir de _SPartSim_.
  - No obstante, la herramienta presenta sus limitaciones en cuanto al cálculo de los tiempos de partida de los vehículos.

== Paralelización de simulaciones

#figure(
  diagram(
    spacing: (9mm,1.5mm),
      node-stroke: 1pt,
      edge-stroke: 1pt,
      node((-14,0), `Generate sim_i.sumocfg`, name: <1>, width: 55mm),
      edge((-16.5,0), "r,r", "-|>", label: `start`),
      node((-4,0), `SUMO instance`, name: <2>, width: 40mm),
      node((-4,1), `SUMO instance`, name: <3>, width: 40mm),
      node((-4,-1), `SUMO instance`, name: <4>, width: 40mm),
      node((-4,2), `SUMO instance`, name: <5>, width: 40mm),
      node((-4,-2), `SUMO instance`, name: <6>, width: 40mm),
      node((-2,0), `partition_3.log`, name: <7>, width: 65mm),
      node((-2,1), `partition_4.log`, name: <8>, width: 65mm),
      node((-2,-1), `partition_2.log`, name: <9>, width: 65mm),
      node((-2,2), `partition_5.log`, name: <10>, width: 65mm),
      node((-2,-2), `partition_1.log`, name: <11>, width: 65mm),
      edge(<1>,<1>, "-|>", bend: 130deg, label: `for each partition`),
      node(
          enclose: (<2>, <3>, <4>, <5>, <6>),
          name: <parallel>,
          corner-radius: 3pt,
      ),
      edge(<1>,<parallel>, "-|>", label: `#pragma omp parallel`),
      edge(<2>, <7>, "-|>"),
      edge(<3>, <8>, "-|>"),
      edge(<4>, <9>, "-|>"),
      edge(<5>, <10>, "-|>"),
      edge(<6>, <11>, "-|>"),
      edge(<parallel>,<parallel>, "-|>", bend: 100deg, label: `run simulation`)
  )
)
#pagebreak()
- Cada hilo de ejecución posee una instancia de SUMO contenerizada en _Singularity_.
- De esta manera, se evitan los conflictos de lectura/escritura para las simulaciones paralelizadas.
- Se llama a la directiva de compilación `#pragma omp parallel` para realizar la distribución de los nodos de ejecución con cada una de las particiones asignadas.

== Sincronización de simulaciones

=== Reensamblaje de rutas
- Se implementó un módulo en `Python` que reconstruye las rutas particionadas para tener información de cuál es la ruta y partición que sigue a la salida de un vehículo.
- Si no existe una ruta siguiente, entonces el vehículo termina por salir de la simulación.
- Se logró una reconstrucción parcial de los viajes generados
   - Parcial, dado que _cutRoutes.py_ no conserva las rutas tal como uno las entrega (hay pérdida de información).
#pagebreak()
=== Comunicación entre nodos
- Se implementó una cola global en la cual se escriben los vehículos salientes de cada partición con el nodo al que les corresponde entrar en el siguiente paso.
- De esta manera, cada nodo se encarga de insertar los vehículos correspondientes a su partición.
- Para evitar conflictos de lectura/escritura, esta cola se implementa por medio del uso de secciones críticas.
#pagebreak()

=== Impedimentos para la sincronización
- _cutRoutes.py_ presenta limitaciones.
  - Principalmente, al momento de definir los tiempos de partida de los vehículos (_departure times_).
  - Lo que hace finalmente es redefinir aquellas rutas que cruzan más de una partición como rutas independientes con el mismo tiempo de partida.
  - Esto provoca que al ingreso de los vehículos en los nodos de simulación, éstos no se reconozcan dado que los mismos ya han salido de la simulación.
- Es posible solucionar estos problemas mediante la modificación del código fuente de la herramienta.

=== Test de carga
==== Versión secuencial

- *_Setup_*: define los períodos de generación de vehículos y genera los archivos de rutas para el mapa definido.
  - Se definen 20 períodos y para cada período se crea el archivo de configuración correspondiente.
- *Ejecución*: cada simulación se ejecuta un total de 50 veces con una versión contenerizada de SUMO y se promedian los tiempos de ejecución para cada período.
#pagebreak()
==== Versión paralelizada
- *_Setup_*: genera los períodos, rutas, particiones y archivos de configuración para cada nodo, y organiza los archivos en sus directorios correspondientes.
- *_start_test_*: por cada _set_ de particiones realizadas, se inicia el test de carga para cada período dado.
- *_load_test_*: ejecuta las simulaciones llamando al módulo encargado de paralelizar los procesos de simulación según el número de particiones realizadas. Cada simulación es ejecutada 50 veces para luego promediar los tiempos de ejecución.

= Resultados
#slide(
  figure(
    grid(
      columns: 3,
      rows: 2,
      gutter: 1mm,
      image("graficos/1_particion.png"),
      image("graficos/4_particiones.png"),
      image("graficos/8_particiones.png"),
      image("graficos/16_particiones.png"),
      image("graficos/32_particiones.png"),
      image("graficos/64_particiones.png")
    )
  )
)

#speaker-note(
  [Como es posible observar, hay una diferencia significativa entre la cota superior de los tiempos de simulación de la versión secuencial con las versiones paralelizadas, alcanzando un mínimo a las 16 particiones. Es importante notar que, además, para las simulaciones con 32 y 64 particiones, esta cota tiende a subir.]
)

#pagebreak()

#figure(
  image("graficos/comparativo.png")
)

#speaker-note(
  [Por otro lado, este gráfico muestra la comparación entre la evolución de los tiempos de simulación entre _sets_ de particiones. De aquí se desprende la observación de que, a medida que se aumenta el número de particiones, el costo en tiempo de ejecución para simulaciones con bajas tasas de inserción de vehículos tiende a crecer, a la vez que los tiempos de simulación se comportan de una manera más lineal (es decir, el incremento en los tiempos de simulación es menor entre período y período).]
)

#pagebreak()


== _Speedup_ y eficiencia

#figure(
  grid(
    columns: 2,
    gutter: 1mm,
    image("graficos/speedup.png"),
    image("graficos/efficiency.png")
  )
)

#speaker-note(
  [En cuanto al _speedup_, en el gráfico de la izquierda podemos ver una comparación de los _speedup_ obtenidos para cada simulación. De aquí se puede observar que, si bien es posible alcanzar altas disminuciones en el tiempo de ejecución de las simulaciones para escenarios con una tasa de inserción de vehículos moderada, para escenarios con una alta tasa de inserción la _performance_ tiende a disminuir.
  
  Ahora, en cuanto a la eficiencia (que fue calculada como la razón entre el speedup y el número de particiones), en el gráfico de la derecha podemos apreciar que para un número de particiones menor o igual a 16, se tiene una alta eficiencia sobre los tiempos de simulación para tasas de generación de vehículos que se encuentran alrededor y bajo la mediana, mientras que para escenarios con mayor congestión de tráfico la eficiencia de la solución propuesta tiende a descender.]
)

#pagebreak()
== Uso de CPU

#figure(
  image("graficos/cpu_usage_fixed.png", width: 65%)
)

#speaker-note(
  [En cuanto al uso de CPU, este gráfico muestra que aún en los casos menos óptimos, el uso de este recurso no alcanza a ser el 100% de lo que se le asigna a los procesos, mostrando que efectivamente la solución propuesta logra optimizar el uso de CPU.]
)

= Conclusiones

== Discusión

- Las simulaciones paralelizadas poseen una cota superior de tiempo de ejecución mucho menor a la versión secuencial (con un sólo nodo)
- A medida que se aumenta la cantidad de particiones, el escalamiento parece ser cada vez más lineal.
  - Las simulaciones con menor frecuencia de inserción de vehículos se ven afectadas.
- El aumento en el _speedup_ puede superar el 5% de los tiempos de simulación, pero no en todos los casos.
  - Para los _sets_ de 32 y 64 particiones, la eficiencia decrece.
- Es importante considerar en los resultados el *balance de las cargas* y la *pérdida de información* al realizar el corte de rutas.

#speaker-note(
  [Balance de cargas -> puede que estén quedando nodos con demasiada carga para números grandes de particiones y eso retrase las cosas
  
  Pérdida de información -> con el corte de rutas, hay información que se pierde, lo que implica una menor carga para los nodos de ejecución]
)

== Conclusión y trabajo futuro
- Se logró implementar un sistema de paralelización de simulaciones de tráfico vehicular urbano orientado a supercomputadores.
- Es posible mejorar la _performance_ de las simulaciones de tráfico vehicular urbano con SUMO mediante la paralelización.
  - Sin embargo, es necesario considerar el _overhead_ que implica la sincronización.
- El tamaño del área a simular no es un factor determinante en el escalamiento de las simulaciones. Aún así, se sugiere realizar mayores estudios que varíen los tamaños de los mapas así como la carga de tráfico vehicular.
- Asimismo, se sugiere realizar los experimentos variando los algoritmos de partición de grafos en búsqueda de la mayor eficiencia. 

