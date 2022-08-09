breed [papers paper] ; breed turtles for paper submissions
breed [reviewers reviewer] ; breed turtles for reviewers
breed [accepts accept] ;breed turtle for accept decision
breed [rejects reject] ;breed turtle for reject decision

;links signifying whether a reviewer reviewed a paper fairly

undirected-link-breed  [fair-reviews fair-review]
undirected-link-breed  [unfair-reviews unfair-review]


;links signifying paper decisions after being reviewed

undirected-link-breed [fair-accepts fair-accept]
undirected-link-breed [fair-rejects fair-reject]
undirected-link-breed [unfair-accepts unfair-accept]
undirected-link-breed [unfair-rejects unfair-reject]


papers-own[good? ;internal quality of paper submission
           score] ;reviewer score of paper after assessment

reviewers-own[biased?] ; reviewer bias

to setup
  ca

  setup-reviewers ;setup reviewers
  setup-decisions ;setup accept (smiley face) and reject (sad face) nodes

  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;
;;;setup functions;;;
;;;;;;;;;;;;;;;;;;;;;


to setup-reviewers

  crt n-reviewers
      [set breed reviewers
       set shape "person"
       setxy random-xcor -10
       set size 5

       ;assign biases
       set biased? random-float 1 < reviewer-bias
       ifelse biased? = TRUE [
            set color red]
        [set color green]
      ]

end

to setup-decisions

  ;create accept node (happy face)
  crt 1
      [set breed accepts
       set shape "face happy"
       setxy -10 10
       set color green
       set size 4
       ]

  ;create reject node (sad face)
  crt 1
      [set breed rejects
       set shape "face sad"
       setxy 10 10
       set color red
       set size 4
       ]

end

;;;;;;;;;;;;;;;;;;
;;;go functions;;;
;;;;;;;;;;;;;;;;;;



to go
  submit-paper
  ask turtles [assign-reviewers]
  ask turtles [assess-papers]
  ask turtles [give-decision]
  tick
end



to submit-paper ;make one submission

  ;create paper
  crt  1[
      set breed papers
      set good? random-float 1 < n-good
          ifelse good? = TRUE [
      set color green]
     [ set color red ]
      set shape "square"
    setxy random-xcor 0]
end

to assign-reviewers ;assign reviewers to review a submission

  ;;connecting reviewers with good papers
  ask reviewers with [biased?] [create-unfair-reviews-with papers with [good?] ;biased reviewers create unfair reviews of good papers
    ask unfair-reviews [set color red]]
  ask reviewers with [not biased?] [create-fair-reviews-with papers with [good?] ;fair reviewers create fair reviews of good papers
    ask fair-reviews [set color green]]
  ;;connecting reviewers with bad papers
  ask reviewers with [biased?] [create-unfair-reviews-with papers with [not good?] ;biased reviewers create unfair reviews of bad papers
    ask unfair-reviews [set color red]]
  ask reviewers with [not biased?] [create-fair-reviews-with papers with [not good?] ;fair reviewers create fair reviews of bad papers
    ask fair-reviews [set color green]]
end


to assess-papers ;assess papers based on reviewer bias and paper quality
;;I need help optimizing the code in this function

ask papers [

    ifelse good?
    [ set score score + (count my-fair-reviews - count my-unfair-reviews) ] ;scoring for good papers
    [ set score score + (count my-unfair-reviews - count my-fair-reviews) ] ;scoring for bad papers

  ]

end

to give-decision ;use scores to accept or reject submission

;fair accept
ask papers[
    if score > n-reviewers * accept-threshold and good? = TRUE[
      create-fair-accepts-with accepts

      ;color fair accepts
      ask fair-accepts [set color blue]
    ]
  ]

;unfair accept
ask papers[
    if score > n-reviewers * accept-threshold and good? = FALSE[
      create-unfair-accepts-with accepts

      ;color unfair accepts
      ask unfair-accepts [set color orange]
    ]
  ]

;fair reject
ask papers[
    if score < n-reviewers * accept-threshold and good? = FALSE[
      create-fair-rejects-with rejects

      ;color fair rejects
      ask fair-rejects [set color blue]
    ]
  ]

;unfair reject
ask papers[
    if score < n-reviewers * accept-threshold and good? = TRUE[
      create-unfair-rejects-with rejects

      ;color unfair rejects
      ask unfair-rejects [set color orange]
    ]
  ]

end

;Juven Nino Villacastin (2022)
;University of the Philippines Diliman
@#$#@#$#@
GRAPHICS-WINDOW
207
17
644
455
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
17
23
80
56
setup
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
96
24
173
57
go
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
15
194
187
227
n-reviewers
n-reviewers
1
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
16
149
188
182
n-good
n-good
0
1
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
14
237
186
270
reviewer-bias
reviewer-bias
0
1
0.5
0.1
1
NIL
HORIZONTAL

MONITOR
655
19
866
64
biased reviewers
count reviewers with [biased? = TRUE]
17
1
11

SLIDER
13
279
185
312
accept-threshold
accept-threshold
0.1
1
0.3
.1
1
NIL
HORIZONTAL

PLOT
653
76
866
247
papers
NIL
# submissions
0.0
2.0
0.0
10.0
true
true
"" ""
PENS
"good papers" 1.0 1 -13210332 true "" "plotxy 0 count papers with [good? = TRUE]"
"bad papers" 1.0 1 -8053223 true "" "plotxy 1 count papers with [good? = FALSE]"

PLOT
873
19
1080
247
decisions 
ticks
# of submissions
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"fair-accepts" 1.0 2 -13840069 true "" "plot count fair-accepts"
"fair-rejects" 1.0 2 -2674135 true "" "plot count fair-rejects\n"
"unfair-accepts" 1.0 2 -14333415 true "" "plot count unfair-accepts"
"unfair-rejects" 1.0 2 -10873583 true "" "plot count unfair-rejects"

BUTTON
52
67
129
100
go-once
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

PLOT
652
253
1079
454
distribution of decisions
# of papers
# of decisions
0.0
1.0
0.0
1.0
true
true
"" ""
PENS
"fair decisions" 1.0 2 -13791810 true "" "plotxy (count fair-accepts + count fair-rejects) count papers"
"unfair decisions" 1.0 2 -955883 true "" "plotxy (count unfair-accepts + count unfair-rejects) count papers"
"line of equality" 1.0 0 -16777216 true "" "plotxy count papers (count fair-accepts + count unfair-accepts + count fair-rejects + count unfair-rejects)"

TEXTBOX
17
331
167
349
Legend:\n\n
11
0.0
1

TEXTBOX
15
352
165
370
BLUE links - fair accept/reject
11
104.0
1

TEXTBOX
14
370
164
398
ORANGE links - unfair accept/reject
11
25.0
1

@#$#@#$#@
# Naive Reviewer Bias Game

## VERSION NOTES

version 1.0

For comments and improvement. The following aspects of the model need attention:
1. scoring system for assessments in ASSESS-PAPERS
2. decision-making model in GIVE-DECISION

## WHAT IS IT?

This model simulates how unfair assessments of article submissions influence the acceptance of article submissions. This model makes the following baseline assumption:

**If no reviewer bias, n(good papers) = n(accepted papers)**

Alternatively:

**If all reviewers are biased, n(bad papers) = n(accepted papers)**

Similarly:

**If no reviewer bias, n(papers) = n(fair decisions)**


## HOW TO USE IT

Before pressing **setup**, you can adjust the following variables:

1. **n-good** - probability that submitted paper is GOOD, [0,1]
3. **n-reviewers** - number of reviewers [1,10]
4. **reviewer-bias** - ratio of bias/fair reviewers [0,1]
5. **accept-threshold** - percentage of votes from reviewers needed for a paper to be accepted [0,1]

## THINGS TO NOTICE

Try running the model when the number of biased reviewers = number of fair reviewers. Notice the distribution of decisions (fair and unfair).


## EXTENDING THE MODEL

1. **Scoring submission quality before assessments** - some GOOD submissions can be better than others. Similarly some not GOOD submissions are worse than others. Incorporating this may reveal different patterns for assessments and decisions made. 

2. **Introducing quotas** - realistically, journal issues and conferences have a set quota of number of articles to accept. You can extend this model by introducing different quota rules (e.g. only top 10 highest scoring papers get accepted).

3. **Adding more decisions** - in addition to accept and reject, you can also extend this model by adding more reviewer decisions (e.g. accept with minor revisions for papers with a certain score). 

4. **Improved rules for scoring** - due to the author's limited knowledge of using Netlogo, a make-shift rule for reviewer scoring was used in this model. You can extend this model by optimizing the code for **assess-papers**.

5. **Operationalizing single and double-blind reviews** - single-blind reviews can potentially open possibilities for bias when the reviewer is able to positively or negatively discriminate the author/s based on demographic factors or affiliation. This can also be added to the model. 

## CREDITS AND REFERENCES

Villacastin, J.N. (2022). Naive reviewer bias game. 
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
<experiments>
  <experiment name="experiment 1" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1"/>
    <metric>count papers with [good? = TRUE]</metric>
    <metric>count papers with [good? = FALSE]</metric>
    <metric>count pasars</metric>
    <metric>count walas</metric>
    <enumeratedValueSet variable="n-reviewers">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reviewer-bias">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-papers">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-good">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 2" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1"/>
    <metric>count papers with [good? = TRUE]</metric>
    <metric>count papers with [good? = FALSE]</metric>
    <metric>count pasars</metric>
    <metric>count walas</metric>
    <steppedValueSet variable="n-reviewers" first="1" step="1" last="5"/>
    <steppedValueSet variable="reviewer-bias" first="0" step="0.2" last="1"/>
    <steppedValueSet variable="n-papers" first="10" step="10" last="100"/>
    <steppedValueSet variable="n-good" first="0" step="0.2" last="1"/>
  </experiment>
</experiments>
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
