// Three-slide presentation — Room occupancy under a sensor outage
// Group G12, assigned outage: L (light sensor)

#let accent   = rgb("#1b3a5c")
#let accent2  = rgb("#2e7d9a")
#let warm     = rgb("#b5541f")
#let ink      = rgb("#1a1a1a")
#let muted    = rgb("#5f6b76")
#let panel    = rgb("#f2f5f8")
#let panel2   = rgb("#fdf3ea")
#let rule     = rgb("#d4dde5")

#set page(
  paper: "presentation-16-9",
  margin: (x: 1.9cm, top: 1.35cm, bottom: 1.15cm),
  footer: context [
    #set text(size: 9pt, fill: muted)
    #line(length: 100%, stroke: 0.5pt + rule)
    #v(-3pt)
    #grid(columns: (1fr, auto),
      align: (left, right),
      [Group *G12* · outage *L* (light) · Room Occupancy Estimation, UCI (CC BY 4.0)],
      [#counter(page).display() / 3],
    )
  ],
)

#set text(font: ("Helvetica Neue", "Helvetica", "Arial"), size: 15pt, fill: ink)
#set par(leading: 0.6em)

#let title(main, sub) = {
  text(size: 26pt, weight: 700, fill: accent)[#main]
  v(-10pt)
  block(inset: (left: 1pt))[#text(size: 12pt, fill: muted)[#sub]]
  v(-3pt)
  line(length: 100%, stroke: 1.6pt + accent2)
  v(2pt)
}

#let card(fill: panel, stroke-col: rule, body) = block(
  fill: fill, stroke: 0.8pt + stroke-col, radius: 5pt,
  inset: (x: 10pt, y: 8pt), width: 100%, body
)

#let lab(t) = text(size: 10.5pt, weight: 700, fill: accent2)[#upper(t)]

// ─────────────────────────────── SLIDE 1 ───────────────────────────────
#title[Model and assumption][
  A naive-Bayes network over one occupancy state and five discretised sensors \
  #text(size: 10.5pt)[Giovani Mambrim Leme · Yanis Blot--EL Mazouzi · Abdelbasset El Hamrit · Dhruv Gupta]
]

#let vnode(letter, name, states) = box(
  width: 3.5cm, fill: white, stroke: 1pt + accent2, radius: 4pt,
  inset: (x: 5pt, y: 6pt),
)[
  #align(center)[
    #text(size: 15pt, weight: 700, fill: accent)[#letter]
    #v(-6pt)
    #text(size: 9pt, fill: ink)[#name]
    #v(-6pt)
    #text(size: 8pt, fill: muted)[states #states]
  ]
]

#block(width: 100%, height: 4.6cm)[
  #let cx = (2.05cm, 7.15cm, 12.25cm, 17.35cm, 22.45cm)
  #for x in cx {
    place(line(start: (12.25cm, 1.35cm), end: (x, 3.05cm), stroke: 1pt + accent2.lighten(25%)))
  }
  #place(dx: 10.5cm, dy: 0cm)[
    #box(width: 3.5cm, fill: accent, radius: 4pt, inset: (x: 5pt, y: 7pt))[
      #align(center)[
        #text(size: 16pt, weight: 700, fill: white)[O]
        #v(-6pt)
        #text(size: 9pt, fill: white)[occupancy · $>=$ 1 occupant]
        #v(-6pt)
        #text(size: 8pt, fill: white.darken(12%))[states 0, 1 · root]
      ]
    ]
  ]
  #for x in cx { place(dx: x - 4pt, dy: 2.82cm)[#text(size: 11pt, fill: accent2)[#sym.triangle.filled.b]] }
  #place(dx: cx.at(0) - 1.75cm, dy: 3.15cm)[#vnode[T][temperature][0,1,2]]
  #place(dx: cx.at(1) - 1.75cm, dy: 3.15cm)[#vnode[L][light][0,1]]
  #place(dx: cx.at(2) - 1.75cm, dy: 3.15cm)[#vnode[S][sound][0,1,2]]
  #place(dx: cx.at(3) - 1.75cm, dy: 3.15cm)[#vnode[C][CO₂][0,1,2]]
  #place(dx: cx.at(4) - 1.75cm, dy: 3.15cm)[#vnode[M][motion][0,1]]
]

#grid(columns: (1.12fr, 1fr), gutter: 14pt,
  card[
    #lab[Factorisation — 5 edges, 6 nodes]
    #v(3pt)
    #align(center)[#text(size: 13.5pt)[
      $P(O,T,L,S,C,M) = P(O) product_(X in {T,L,S,C,M}) P(X | O)$
    ]]
    #v(3pt)
    #text(size: 11pt, fill: muted)[
      Occupancy is the single common cause; each sensor is a leaf with one parent.
      Every arrow points *from* the hidden state *to* the observed reading.
    ]
  ],
  card(fill: panel2, stroke-col: warm.lighten(55%))[
    #lab[The modelling assumption we accept]
    #v(3pt)
    #text(size: 12.5pt)[
      The five sensors are *conditionally independent given O*:
      e.g. #text(fill: warm)[$L perp perp C | O$].
    ]
    #v(3pt)
    #text(size: 11pt, fill: muted)[
      This is an approximation, not a measured fact. Light and CO₂ also share
      time-of-day drivers, so residual correlation is absorbed as if it were
      independent evidence — a point we return to on slide 3.
    ]
  ]
)

#pagebreak()

// ─────────────────────────────── SLIDE 2 ───────────────────────────────
#title[Protocol and evidence][
  One fitted model, one test set, three evidence conditions
]

#grid(columns: (1fr, 1fr, 1.05fr), gutter: 10pt,
  card[
    #lab[Fixed chronological split]
    #v(2pt)
    #text(size: 11pt)[
      *Train* 7 090 rows #text(fill: muted)[(22→26 Dec 2017)] \
      #h(9pt)#text(size: 10pt, fill: muted)[O=0: 5 483 · O=1: 1 607] \
      *Test* #h(3pt) 3 039 rows #text(fill: muted)[(26 Dec→11 Jan)] \
      #h(9pt)#text(size: 10pt, fill: muted)[O=0: 2 745 · O=1: 294]
    ]
    #v(2pt)
    #text(size: 9.5pt, fill: muted)[
      No shuffling. Bins fitted on the training period only; CPDs by Dirichlet
      posterior mean, one pseudocount per cell.
    ]
  ],
  card[
    #lab[Decision rule, held fixed]
    #v(2pt)
    #text(size: 11pt)[
      Declare occupied when $P(O=1 | e) >= 1\/6$. \
      Costs: FP = 1, FN = 5, correct = 0. \
      #v(1pt)
      #align(center)[$"mean loss" = ("FP" + 5 dot "FN") \/ n$]
    ]
    #v(1pt)
    #text(size: 9.5pt, fill: muted)[
      Fitted prior $P(O=1) = 0.2267 >= 1\/6$, so the prior-only baseline declares
      *every* record occupied.
    ]
  ],
  card(fill: panel2, stroke-col: warm.lighten(55%))[
    #lab[One number, read carefully]
    #v(2pt)
    #align(center)[#text(size: 12.5pt)[
      $P(M=1|O=1) = (939+1)/(1607+2) = 0.5842$
    ]]
    #v(2pt)
    #text(size: 9.5pt, fill: muted)[
      *Numerator:* 939 training rows with motion, +1 Dirichlet pseudocount.
      *Denominator:* 1 607 rows in the parent configuration O=1, +1 pseudocount for
      *each* of M's two states. Hand count and pgmpy agree to 1e−12.
    ]
  ]
)

#v(5pt)
#lab[Same model, same 3 039 test records — only the evidence changes]
#v(2pt)

#set text(size: 11.5pt)
#table(
  columns: (2.9fr, 1fr, 1.25fr, 1fr, 1fr, 1fr, 0.85fr, 0.85fr, 0.85fr, 0.85fr),
  stroke: none,
  align: (left, right, right, right, right, right, right, right, right, right),
  inset: (x: 6pt, y: 5pt),
  table.header(
    ..([Condition], [Brier], [Mean loss], [Acc.], [Prec.], [Recall], [TN], [FP], [FN], [TP])
      .map(h => text(size: 10.5pt, weight: 700, fill: accent)[#h])
  ),
  table.hline(stroke: 1pt + accent),
  [Prior only #text(size: 9pt, fill: muted)[(no sensors)]],
    [0.10428], [0.90326], [0.0967], [0.0967], [1.0000], [0], [2 745], [0], [294],
  table.hline(stroke: 0.5pt + rule),
  [Full sensors], [0.02350], [0.08292], [#strong[0.9829]], [#strong[0.9919]], [0.8299], [2 743], [2], [50], [244],
  table.hline(stroke: 0.5pt + rule),
  table.cell(fill: panel2)[#text(fill: warm, weight: 700)[Without L #text(size: 9pt, weight: 400)[(our outage)]]],
    ..([#strong[0.01118]], [#strong[0.04673]], [0.9546], [0.6814], [#strong[0.9966]], [2 608], [137], [1], [293])
      .map(c => table.cell(fill: panel2)[#c]),
  table.hline(stroke: 1pt + accent),
)
#set text(size: 15pt)

#v(4pt)
#text(size: 11pt)[
  The *full sensors → without L* pair isolates the outage: identical CPDs, records,
  threshold and costs. Losing L trades #text(fill: warm)[+135 false positives] for
  #text(fill: warm)[−49 false negatives]; at a 5:1 cost ratio that *lowers* mean loss
  from 0.08292 to 0.04673, even though accuracy and precision fall.
]

#pagebreak()

// ─────────────────────────────── SLIDE 3 ───────────────────────────────
#title[Engineering conclusion][
  What the outage costs us, what this evidence cannot settle, and what to run next
]

#grid(columns: (1fr, 1fr), gutter: 13pt,
  card[
    #lab[Outage consequence — assigned incident]
    #v(3pt)
    #text(size: 11pt)[
      Record *8929*, 2018-01-10 22:41 \
      #text(size: 9.5pt, fill: muted)[
        full: {T=0, L=0, S=1, C=0, M=0} → without L: {T=0, S=1, C=0, M=0}
      ]
    ]
    #v(4pt)
    #table(
      columns: (1fr, auto, auto), stroke: none, inset: (x: 5pt, y: 4pt),
      align: (left, right, center),
      ..([], [$P(O=1|e)$], [decision]).map(h => text(size: 9.5pt, weight: 700, fill: accent)[#h]),
      table.hline(stroke: 0.5pt + rule),
      text(size: 10.5pt)[full sensors], text(size: 10.5pt)[$5.07 times 10^(-9)$], text(size: 10.5pt)[empty],
      text(size: 10.5pt)[without L], text(size: 10.5pt)[$3.51 times 10^(-6)$], text(size: 10.5pt)[empty],
    )
    #v(4pt)
    #text(size: 10.5pt, fill: muted)[
      The posterior rises by a factor of about 700, yet stays far below 1/6: *this*
      decision is unchanged. The outage degrades confidence, not the verdict — the
      four surviving sensors already agree. Aggregate effect: recall 0.83 → *0.997*,
      precision 0.99 → *0.68*.
    ]
  ],
  card(fill: panel2, stroke-col: warm.lighten(55%))[
    #lab[The limitation that matters most]
    #v(3pt)
    #text(size: 11.5pt)[
      A lower loss without L is *not* evidence that the light sensor is harmful.
    ]
    #v(3pt)
    #text(size: 10.5pt, fill: muted)[
      All 50 full-sensor false negatives occur at L=0 and none at L=1. Under the
      naive-Bayes assumption, L=0 multiplies in as *independent* evidence for "empty",
      overwhelming the other sensors and pushing genuinely occupied night-time records
      below the threshold. Dropping L removes an over-counted factor — it does not
      remove a bad sensor.
      #v(4pt)
      The result is tied to this split, this discretisation, this 1/6 threshold and
      this 5:1 cost ratio. It is not causal, and it does not transfer to another
      building or season.
    ]
  ]
)

#v(7pt)

#card(fill: accent, stroke-col: accent)[
  #grid(columns: (auto, 1fr), gutter: 12pt, align: horizon,
    text(size: 10.5pt, weight: 700, fill: white.darken(8%))[NEXT VALIDATION],
    text(size: 11pt, fill: white)[
      Rolling-origin evaluation over successive day boundaries, with every modelling
      choice frozen — if "without L" keeps winning across folds *and* across a sweep of
      cost ratios, the finding is about the independence assumption, not about this one
      17-day test window. A dependency-aware structure (an edge $L arrow C$, or a
      time-of-day parent) is the direct test of the same hypothesis.
    ]
  )
]
