extensions[ bitmap ]

breed [passengers passenger]
breed [vicini1 vicino1]
breed [vicini2 vicino2]

globals [
  exit1 exit2 exits-list ;;to define exit door of the train

  ;;Variabile per PS-Distanza
  num_uscite
  cell_exit1
  cell_exit2
  dist1
  dist2
  r1
  r2
  R12
  PSr1
  PSr2

  ;;Variabili per PS-OD
  d1
  d2
  D12
  d1k
  d2k
  PSd1
  PSd2

  ;;Variabili per PS-Finale
  alpha1
  alpha2
  alpha_tot

  beta1
  beta2
  beta_tot

  PS1
  PS2

  ;; Variabili Uscite & Ostacoli
  LPP1
  LPP2

  safe-exits
  safe-exits1
  safe-exits2
  obstacle1
  ostacolo1
  distanza_ostacolo1
  LPP_avoid
  N

]

passengers-own[
  in-seat?
  safe? ;;when escaped succesfully out of the train

  target-enter
  target-exit
  target-area-exit
  my-exits-list
]


patches-own[
  accessible?
  exit1?
  exit2?
  areauscita1?
  areauscita2?
  obstacle1?
  contatore ;; varibile usata per creare l'heatmap
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNZIONI SETUP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  __clear-all-and-reset-ticks
  ask patches [set contatore 0]

  initialize-globals
  initialize-room
  initialize-exits
  initialize-passengers
  initialize-obstacles
  reset-ticks
end



to initialize-globals
  set num_uscite 2
  set safe-exits 0
  set safe-exits1 0
  set safe-exits2 0
end



to initialize-room


  if (Posizione_uscite = "Centrali") [
    import-pcolors "images/esteso.png"
    if (obstacle = true)[import-pcolors "images/esteso_obstacle2.png" ]

  ]

    if (Posizione_uscite = "Angoli") [
    import-pcolors "images/esteso2.png"
    if (obstacle = true)[import-pcolors "images/esteso2_obstacle2.png" ]

  ]




  ask patches[
    if pcolor = 85.2 [set pcolor cyan]
    if pcolor = 0 [set pcolor black]
    if pcolor = 64.3 [set pcolor green]
    if pcolor = 9.9 [set pcolor white]

    if pcolor = 14.9 [set pcolor magenta] ;;area uscita1
    if pcolor = 87.1 [set pcolor sky] ;;area uscita2

    if pcolor = 17.9 [set pcolor pink] ;;uscita1
    if pcolor = 95.2 [set pcolor blue] ;;uscita2

    if pcolor = 6.7 [set pcolor gray] ;;ostacolo1
  ]

  ask patches[
    set accessible? false
  ]

  ask patches with [pcolor = white or pcolor = sky or pcolor = magenta][
    set accessible? true
  ]

end



to initialize-exits

  ;; setup uscite
  ask patches with [pcolor = pink] [
    set exit1? true
    set exit2? false
  ]

  ask patches with [pcolor = blue] [
    set exit1? false
    set exit2? true
  ]

  set exit1 patches with [pcolor = pink]
  set exit2 patches with [pcolor = blue]

  ;; setup aree uscite
    ask patches with [pcolor = magenta] [
    set areauscita1? true
    set areauscita2? false
  ]

  ask patches with [pcolor = sky] [
    set areauscita1? false
    set areauscita2? true
  ]


end



to initialize-obstacles
  set obstacle1 patches with [pcolor = gray]
end






;;creo passeggeri
to initialize-passengers


  create-passengers passenger-count[
    ;set shape "person business"
    set size 1.5
    set target-enter (random 2) + 1
    set target-exit (random 2) + 1

    set safe? false

  ]

  ask passengers[
    let empty-cell patches with [pcolor = white or pcolor = sky or pcolor = magenta] with [not any? turtles-here]
    if any? empty-cell
    [
      let target one-of empty-cell
      face target
      move-to target
    ]

    if (target-enter = 1) [set color pink]
    if (target-enter = 2) [set color blue]
  ]


end
















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNZIONI GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go

  ;if (patch-) []
  ask patches [let conta count turtles-here set contatore (contatore + conta) ]

  if not any? turtles [
    if (Heatmap = true) [mappa]
    stop ]

  ;; Controllo se sono nell'uscita allora muori
  ask turtles-on exit1 [
    set safe-exits safe-exits + 1
    set safe-exits1 safe-exits1 + 1

    die

  ]
  ask turtles-on exit2 [
    set safe-exits safe-exits + 1
    set safe-exits2 safe-exits2 + 1
    die
  ]

  ;; Calcolo PP delle uscite nel vicinato di ogni passeggero
  let sorted-turtles sort passengers
  foreach sorted-turtles [ x -> ask x [

    set cell_exit1 min-one-of exit1 [distance myself] ;;mi ritorna la cella dell'uscita 1 che è più vicina a me, sarà il mio riferimento dell'uscita 1 ; è anche Ri
    set cell_exit2 min-one-of exit2 [distance myself] ;;mi ritorna la cella dell'uscita 2 che è più vicina a me, sarà il mio riferimento dell'uscita 2 ; è anche Ri

    set dist1 [distance myself] of cell_exit1  ;distanza effettiva dall'uscita1
    set dist2 [distance myself] of cell_exit2  ;distanza effettiva dall'uscita2


    let sorted-neighbors sort neighbors
    let colore1 [pcolor] of item 0 sorted-neighbors
    let colore2 [pcolor] of item 1 sorted-neighbors
    let colore3 [pcolor] of item 2 sorted-neighbors
    let colore4 [pcolor] of item 3 sorted-neighbors
    let colore5 [pcolor] of item 4 sorted-neighbors
    let colore6 [pcolor] of item 5 sorted-neighbors
    let colore7 [pcolor] of item 6 sorted-neighbors
    let colore8 [pcolor] of item 7 sorted-neighbors
    let colori (list colore1 colore2 colore3 colore4 colore5 colore6 colore7 colore8)
    ;show colori





    ;; Calcolo PP
    set_PP

    ;;Calcolo PS
    calcolo_PS

    ;;Calcolo LPP
    let front-patches patches in-cone 4 30
    ifelse not any? front-patches with [pcolor = gray] [
       calcolo_LPP
    ]
    [
      calcolo_LPP_ostacolo
    ]



    ;; Effettuo il movimento
    ifelse (PS1 > PS2)[
      set target-exit 1
      if (not any? turtles-on LPP1)[
        face cell_exit1
        move-to LPP1

      ]
    ]
    [
      set target-exit 2
      if (not any? turtles-on LPP2) [
        face cell_exit2
        move-to LPP2

      ]
    ]


    ;;risetto i colori
    ask item 0 sorted-neighbors [set pcolor colore1]
    ask item 1 sorted-neighbors [set pcolor colore2]
    ask item 2 sorted-neighbors [set pcolor colore3]
    ask item 3 sorted-neighbors [set pcolor colore4]
    ask item 4 sorted-neighbors [set pcolor colore5]
    ask item 5 sorted-neighbors [set pcolor colore6]
    ask item 6 sorted-neighbors [set pcolor colore7]
    ask item 7 sorted-neighbors [set pcolor colore8]
  ]]



  tick
end
















to set_PP
  let sorted-neighbors sort neighbors
  foreach sorted-neighbors [y -> ask y [
    if (pcolor != black) and (pcolor != gray)[
      let dist11 [distance myself] of cell_exit1
      let dist22 [distance myself] of cell_exit2
      ;show dist11
      ;show dist22


      ;; setto PP1 && PP2
      ifelse (dist11 < dist22)[
        ifelse (dist11 <= dist1)[
          set pcolor pink
        ]
        [
          if (dist22 < dist2)[
            set pcolor blue
          ]
        ]

      ]
      [
        ifelse (dist22 <= dist2)[
          set pcolor blue
        ]
        [
          if (dist11 < dist1)[
            set pcolor pink
          ]
        ]

      ]
    ]

  ]]
end


to calcolo_PS
  ;;;; PS-DISTANZA
  set N 2
  set r1 (dist1 ^ Kr)
  set r2 (dist2 ^ Kr)
  set R12 (r1 + r2)

  set PSr1 (1 -  (((N - 1) * r1) / R12) )
  set PSr2 (1 -  (((N - 1) * r2) / R12) )



  ;;;; PS-OD
  ;; calcolo quante persone sono nelle arree uscite
  set d1 count turtles-on patches with [pcolor = magenta]
  set d2 count turtles-on patches with [pcolor = sky]

  set d1k (d1 ^ Kd)
  set d2k (d2 ^ Kd)
  set D12 (d1k + d2k)

  ;; deafult PS-OD, se non ci sono persone nelle uscite
  set PSd1 0.5
  set PSd2 0.5

  ;;se ci sono persone dentro l'area1 calcolo PS-OD
  if (d1 > 0) [
    set PSd1 (1 -  (((N - 1) * d1k) / D12) )
    if (d2 = 0 )[
      set Psd2 (1 - PSd1)
    ]
  ]

  ;se ci sono persone dentro l'area2 calcolo PS-OD
  if (d2 > 0) [
    set PSd2 (1 -  (((N - 1) * d2k) / D12) )
    if (d1 = 0 )[
      set Psd1 (1 - PSd2)
    ]
  ]


  ;; CASO IN CUI SIAMO RIMASTI IN POCHI PASSEGGERI,
  ;; non ha più senso tenere in considerazione quante persone ci sono nelle uscite, usciamo dall'uscita più vicina tanto usciamo tutti senza problemi

  ;(prima versione)
  if ((d1 + d2) < 8)[
    set PSd1 0.5
    set PSd2 0.5
  ]

  ;(seconda versione)
  ;  if ([pcolor] of patch-here = magenta) and (d1 < 25)[
  ;    set PSd1 0.5
  ;    set PSd2 0.5
  ;  ]
  ;
  ;  if ([pcolor] of patch-here = sky) and (d2 < 25)[
  ;    set PSd1 0.5
  ;    set PSd2 0.5
  ;  ]





  ;;;; CALCOLO PS finale in base a SD e OD
  set alpha1 (abs (1 -  ((dist1 *  N) / R12)))
  set alpha2 (abs (1 -  ((dist2 *  N) / R12)))
  set alpha_tot (((alpha1 + alpha2 ) ^ K_alpha) / N)



  set beta1 0
  set beta2 0

  if (D12 > 0)[
    set beta1 (abs (1 -  ((d1 *  N) / D12)))
    set beta2 (abs (1 -  ((d2 *  N) / D12)))
  ]
  set beta_tot (((beta1 + beta2 ) ^ K_beta ) / N)

  ;show alpha_tot
  ;show beta_tot

  ;; caso quando sono equamente distante dalle uscire, e non ci sono persone nelle uscite
  ifelse (alpha_tot = 0) and (beta_tot = 0) [

    ;set PS1 0.6
    ;set PS2 0.4
    set PS1 0.5
    set PS2 0.5
  ]
  [
    set PS1 ((alpha_tot * PSr1) + (beta_tot * PSd1)) / (alpha_tot + beta_tot)
    set PS2 ((alpha_tot * PSr2) + (beta_tot * PSd2)) / (alpha_tot + beta_tot)
  ]



  ;; PS-Unadventurous effect
  if (PS1 != 1 and PS2 != 1 )[



    if (target-enter = 1)[
      let Pie (PS1 * Ke)
      let diff (Pie - PS1)
      let Pje abs(PS2 - (PS2 / (1 - PS1)) * diff)

      let p1 Pie / (Pie + Pje)
      let p2 Pje / (Pie + Pje)

      ;    show p1
      ;    show p2
      ;    show p1 + p2

      set PS1 p1
      set PS2 p2
    ]


    if (target-enter = 2)[
      let Pie (PS2 * Ke)
      let diff (Pie - PS2)
      let Pje abs(PS1 - (PS1 / (1 - PS2)) * diff)


      let p1 Pie / (Pie + Pje)
      let p2 Pje / (Pie + Pje)

      ;    show p1
      ;    show p2
      ;    show p1 + p2

      set PS1 p2
      set PS2 p1
    ]
  ]


  ;;PS-Inertial effect
  if (PS1 != 1 and PS2 != 1)[


    if (target-exit = 1) [


      let Pie (PS1 * Inertial)
      let diff (Pie - PS1)
      let Pje abs(PS2 - (PS2 / (1 - PS1)) * diff)

      let p1 Pie / (Pie + Pje)
      let p2 Pje / (Pie + Pje)

      set PS1 p1
      set PS2 p2
    ]



    if (target-exit = 2) [

      let Pie (PS2 * Inertial)
      let diff (Pie - PS2)
      let Pje abs(PS1 - (PS1 / (1 - PS2)) * diff)

      let p1 Pie / (Pie + Pje)
      let p2 Pje / (Pie + Pje)

      set PS1 p2
      set PS2 p1
    ]
  ]



end


to calcolo_LPP
  ;;Scelgo verso quale PP spostarmi
  let PP1 neighbors with [pcolor = pink]
  let PP2 neighbors with [pcolor = blue]

  ;; Calcolo LPP, ogni PP ha la stessa probabilità di essere scelta come LPP
  set LPP1 one-of PP1
  set LPP2 one-of PP2


  ;;Caso in cui l'uscita dove voglio andare non abbia un PP nel mio vicinato
  if count PP1 = 0 [set LPP1 LPP2]
  if count PP2 = 0 [set LPP2 LPP1]
end




to calcolo_LPP_ostacolo
  let patch_corrente patch-here

  ;;Scelgo verso quale PP spostarmi
  let PP1 neighbors with [pcolor = pink]
  let PP2 neighbors with [pcolor = blue]

  ;; ordino i vicini
  let pp1k sort PP1
  let pp2k sort PP2

  let num_vicini1 count PP1
  let num_vicini2 count PP2

  if(target-exit = 1) [

    if num_vicini1 = 1 [set LPP1 item 0 pp1k]


    if num_vicini1 = 2 [
      let minimo 200

      move-to item 0 pp1k
      let grigi11 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 1 pp1k
      let grigi12 count patches in-cone distanza raggio with [pcolor = gray]

      if (grigi11 < minimo) [set minimo grigi11 set LPP1 item 0 pp1k]
      if (grigi12 < minimo) [set minimo grigi12 set LPP1 item 1 pp1k]

    ]



    if num_vicini1 = 3 [
      let minimo 200

      move-to item 0 pp1k
      let grigi11 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 1 pp1k
      let grigi12 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 2 pp1k
      let grigi13 count patches in-cone distanza raggio with [pcolor = gray]

      if (grigi11 < minimo) [set minimo grigi11 set LPP1 item 0 pp1k]
      if (grigi12 < minimo) [set minimo grigi12 set LPP1 item 1 pp1k]
      if (grigi13 < minimo) [set minimo grigi13 set LPP1 item 2 pp1k]

    ]

    if num_vicini1 = 4 [
      let minimo 200
      move-to item 0 pp1k
      let grigi11 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 1 pp1k
      let grigi12 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 2 pp1k
      let grigi13 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 3 pp1k
      let grigi14 count patches in-cone distanza raggio with [pcolor = gray]

      if (grigi11 < minimo) [set minimo grigi11 set LPP1 item 0 pp1k]
      if (grigi12 < minimo) [set minimo grigi12 set LPP1 item 1 pp1k]
      if (grigi13 < minimo) [set minimo grigi13 set LPP1 item 2 pp1k]
      if (grigi14 < minimo) [set minimo grigi14 set LPP1 item 3 pp1k]

    ]

    set LPP2 one-of PP2

  ]

    if(target-exit = 2)[

    if num_vicini2 = 1 [set LPP2 item 0 pp2k]


    if num_vicini2 = 2 [
      let minimo 200

      move-to item 0 pp2k
      let grigi11 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 1 pp2k
      let grigi12 count patches in-cone distanza raggio with [pcolor = gray]

      if (grigi11 < minimo) [set minimo grigi11 set LPP2 item 0 pp2k]
      if (grigi12 < minimo) [set minimo grigi12 set LPP2 item 1 pp2k]

    ]



    if num_vicini2 = 3 [
      let minimo 200

      move-to item 0 pp2k
      let grigi11 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 1 pp2k
      let grigi12 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 2 pp2k
      let grigi13 count patches in-cone distanza raggio with [pcolor = gray]

      if (grigi11 < minimo) [set minimo grigi11 set LPP2 item 0 pp2k]
      if (grigi12 < minimo) [set minimo grigi12 set LPP2 item 1 pp2k]
      if (grigi13 < minimo) [set minimo grigi13 set LPP2 item 2 pp2k]

    ]

    if num_vicini2 = 4 [
      let minimo 200
      move-to item 0 pp2k
      let grigi11 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 1 pp2k
      let grigi12 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 2 pp2k
      let grigi13 count patches in-cone distanza raggio with [pcolor = gray]

      move-to item 3 pp2k
      let grigi14 count patches in-cone distanza raggio with [pcolor = gray]

      if (grigi11 < minimo) [set minimo grigi11 set LPP2 item 0 pp2k]
      if (grigi12 < minimo) [set minimo grigi12 set LPP2 item 1 pp2k]
      if (grigi13 < minimo) [set minimo grigi13 set LPP2 item 2 pp2k]
      if (grigi14 < minimo) [set minimo grigi14 set LPP2 item 3 pp2k]

    ]

    set LPP1 one-of PP1

  ]

    move-to patch_corrente

    ;;Caso in cui l'uscita dove voglio andare non abbia un PP nel mio vicinato
    if count PP1 = 0 [set LPP1 LPP2]
    if count PP2 = 0 [set LPP2 LPP1]


end

to mappa
  ask patches with [accessible? = true] [
    set pcolor white

    if(contatore > 0 and contatore < 5)[set pcolor 19]
    if(contatore >= 5 and contatore < 10)[set pcolor 18]
    if(contatore >= 10 and contatore < 15)[set pcolor 17]
    if(contatore >= 15 and contatore < 20)[set pcolor 16]
    if(contatore >= 20 and contatore < 25)[set pcolor 15]
    if(contatore >= 25 and contatore < 30)[set pcolor 14]
    if(contatore >= 30 and contatore < 35)[set pcolor 13]
    if(contatore >= 35 and contatore < 40)[set pcolor 12]
    if(contatore >= 40 and contatore < 45)[set pcolor 11.5]
    if(contatore >= 45 )[set pcolor 11]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
0
10
921
803
-1
-1
12.86
1
10
1
1
1
0
0
0
1
-35
35
-30
30
1
1
1
ticks
30.0

BUTTON
949
144
1015
177
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1109
145
1172
178
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
953
274
1125
307
Kr
Kr
0
1
1.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
954
257
1160
289
Effetto SD 
11
0.0
1

SLIDER
952
331
1124
364
Kd
Kd
0
1
1.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
954
316
1205
348
Effetto OD 
11
0.0
1

SLIDER
952
408
1124
441
K_alpha
K_alpha
0
1
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
952
471
1124
504
K_beta
K_beta
0
1
1.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
955
389
1105
407
Relative Importance of SD
12
0.0
1

TEXTBOX
954
453
1121
483
Relative Importance of OD
12
0.0
1

SWITCH
1137
193
1246
226
obstacle
obstacle
0
1
-1000

PLOT
951
519
1413
791
Persone Evacuate
Ticks
Evacuati
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Evacuati Totali" 1.0 0 -16777216 true "" "plot safe-exits"
"Evacuati Exit 1" 1.0 0 -2674135 true "" "plot safe-exits1"
"Evacuati Exit 2" 1.0 0 -13345367 true "" "plot safe-exits2"

BUTTON
1031
144
1094
177
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1188
318
1360
351
raggio
raggio
0
180
50.0
1
1
NIL
HORIZONTAL

TEXTBOX
1190
252
1399
294
Campo di visione: 
11
0.0
1

SWITCH
1199
142
1310
175
Heatmap
Heatmap
0
1
-1000

TEXTBOX
961
114
1111
134
Setup
16
0.0
1

SLIDER
1189
409
1361
442
Ke
Ke
1
2
1.2
0.1
1
NIL
HORIZONTAL

TEXTBOX
1191
392
1341
410
Unadventurous effect
11
0.0
1

SLIDER
1191
471
1363
504
Inertial
Inertial
1
2
1.0
0.1
1
NIL
HORIZONTAL

TEXTBOX
1191
453
1341
471
Inertial Effect
11
0.0
1

SLIDER
947
193
1119
226
passenger-count
passenger-count
0
300
250.0
1
1
NIL
HORIZONTAL

CHOOSER
1269
190
1407
235
Posizione_uscite
Posizione_uscite
"Centrali" "Angoli"
0

SLIDER
1188
272
1360
305
distanza
distanza
0
10
2.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fire
false
0
Polygon -7500403 true true 151 286 134 282 103 282 59 248 40 210 32 157 37 108 68 146 71 109 83 72 111 27 127 55 148 11 167 41 180 112 195 57 217 91 226 126 227 203 256 156 256 201 238 263 213 278 183 281
Polygon -955883 true false 126 284 91 251 85 212 91 168 103 132 118 153 125 181 135 141 151 96 185 161 195 203 193 253 164 286
Polygon -2674135 true false 155 284 172 268 172 243 162 224 148 201 130 233 131 260 135 282

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
