# Diagram Cookbook

Ready-to-copy recipes for building rich diagrams **directly in Markdown**.
Every diagram below is a normal fenced code block. During the build the
Kroki filter (`pandoc-kroki-filter.py`) turns it into an image automatically —
no external tools, no manual exports.

General syntax:

````markdown
```{#some-id .mermaid caption="My caption" max-width=80%}
... diagram code ...
```
````

- `.mermaid`, `.plantuml`, `.graphviz` (or `.dot`), `.ditaa`, `.nomnoml`,
  `.svgbob`, `.erd` select the diagram engine.
- `caption="..."` adds a figure caption.
- `max-width=80%` (or `12cm`, `0.7\linewidth`, …) limits the rendered size.

---

## 1. Concept cards in a row

A row of colored, rounded "cards" — great for summarizing a handful of related
concepts (e.g. the *5 V's of Big Data*). Built with a Mermaid flowchart: the
cards are nodes, joined by **invisible links** (`~~~`) so they line up without
arrows, and colored via `classDef`.

```{#fig-cards .mermaid caption="Die 5 V's von Big Data" max-width=100%}
flowchart LR
    V1["<b>Volume</b><br/>Datenmenge<br/>TB–PB"]
    V2["<b>Velocity</b><br/>Geschwindig-<br/>keit"]
    V3["<b>Variety</b><br/>Vielfalt der<br/>Formate"]
    V4["<b>Veracity</b><br/>Daten-<br/>qualität"]
    V5["<b>Value</b><br/>analytischer<br/>Nutzen"]

    V1 ~~~ V2 ~~~ V3 ~~~ V4 ~~~ V5

    classDef blue   fill:#dbe4ff,stroke:#3b5bdb,color:#1c2f80;
    classDef green  fill:#d3f9d8,stroke:#2f9e44,color:#0b6b2f;
    classDef orange fill:#ffe8cc,stroke:#e8590c,color:#9c4221;
    classDef purple fill:#eee0ff,stroke:#7048e8,color:#4a2c8f;
    classDef red    fill:#ffe3e3,stroke:#e03131,color:#8c1a1a;

    class V1 blue;
    class V2 green;
    class V3 orange;
    class V4 purple;
    class V5 red;
```

**Adapt it:** add/remove `Vn[...]` nodes, extend the `~~~` chain, and assign a
`classDef` color with `class Vn <name>;`. Use `<br/>` for line breaks inside a card.

---

## 2. Styled sequence diagram

A sequence diagram with participants, activation bars, side notes and a summary
note across the bottom — ideal for protocols, synchronization or request flows
(e.g. a *binary semaphore / mutex*). The `rect rgb(...)` blocks tint a region to
draw attention (here: the blocked thread).

```{#fig-sequence .mermaid caption="Semaphor – Synchronisation des kritischen Abschnitts" max-width=95%}
sequenceDiagram
    participant A as Thread A
    participant S as Semaphor (S=1)
    participant B as Thread B

    A->>S: wait(S) → S=0
    Note left of A: kritischer Abschnitt<br/>(liest/schreibt sicher)

    rect rgb(255, 240, 230)
        B->>S: wait(S) → S<0
        Note right of B: BLOCKIERT (wartet)
    end

    A->>S: signal(S) → S=1
    S->>B: weckt Thread B
    Note right of B: kritischer Abschnitt<br/>(jetzt korrekt)

    Note over A,B: Binärer Semaphor (Mutex):<br/>nur EIN Thread darf gleichzeitig in den kritischen Abschnitt
```

**Adapt it:** declare each lane with `participant X as Label`, draw messages with
`->>` (solid) or `-->>` (dashed), annotate with `Note left of`, `Note right of`
or `Note over A,B`, and wrap steps in `rect rgb(r,g,b) ... end` to highlight them.

---

## 3. Circular process cycle

A true circular layout for iterative processes (e.g. the *CRISP-DM* phases).
Mermaid lays out top-down, so for a clean ring we use **Graphviz with the
`circo` engine**: list the phases as filled circular nodes and connect them in a
loop. The last edge back to the first node closes the cycle.

```{#fig-cycle .graphviz caption="Die sechs Phasen von CRISP-DM (zyklisch)" max-width=70%}
digraph crispdm {
    layout=circo;
    bgcolor="transparent";
    node [shape=circle, style=filled, fixedsize=true, width=1.3,
          fontname="Helvetica-Bold", fontcolor=white, fontsize=11];
    edge [color="#555555", penwidth=1.4, arrowsize=0.8];

    BU [label="Business\nUnderstanding", fillcolor="#3b82f6"];
    DU [label="Data\nUnderstanding", fillcolor="#10b981"];
    DP [label="Data\nPreparation",    fillcolor="#f59e0b"];
    MO [label="Modeling",             fillcolor="#8b5cf6"];
    EV [label="Evaluation",           fillcolor="#ef4444"];
    DE [label="Deployment",           fillcolor="#06b6d4"];

    BU -> DU -> DP -> MO -> EV -> DE -> BU;
}
```

**Adapt it:** add nodes with `ID [label="...", fillcolor="#hex"]`, then chain
them `A -> B -> C -> A;`. Keep `layout=circo` for the ring; switch to `dot`
for a top-down flow or `neato` for an organic layout. Use `\n` for line breaks
in Graphviz labels.

---

## 4. Neural-network diagrams (TikZ, native LaTeX)

For node-and-edge figures like perceptrons or multi-layer networks, **TikZ** gives
the most control. Because the build already targets LaTeX, you can drop a TikZ
picture straight into Markdown as a **raw LaTeX block** — no Kroki, no external
service. The required libraries (`arrows.meta`, `positioning`, `calc`, `fit`, …)
are already loaded by the template, so you only write the picture itself.

Wrap the picture in a ` ```{=latex} … ``` ` raw block. To get a caption and a
figure number, put it inside a `figure` environment.

### Single perceptron

```{=latex}
\begin{figure}[H]
\centering
\begin{tikzpicture}[
  neuron/.style={circle, draw, minimum size=0.8cm},
  >=Stealth, node distance=1.5cm
]
  % Inputs — edit this list to add/remove inputs
  \foreach \i/\lbl in {1/x_1, 2/x_2, 3/x_3, 4/x_4}
    \node[neuron] (x\i) at (0, -\i*1.2) {$\lbl$};

  \node[neuron] (b)   at (2, 0.5)  {$b$};
  \node[neuron] (sum) at (3, -2.4) {$\Sigma$};
  \node[neuron] (f)   at (5.5, -2.4) {$f$};
  \node[right=1cm of f] (out) {$\hat{y} \in \{0,1\}$};

  % Weighted edges (\w = label, \col = colour)
  \foreach \i/\w/\col in {1/w_1/black, 2/w_2/black, 3/w_3/blue, 4/w_4/blue}
    \draw[->, \col] (x\i) -- node[above, sloped, font=\tiny] {$\w$} (sum);

  \draw[->] (b) -- (sum);
  \draw[->] (sum) -- node[above, font=\tiny] {$z$} (f);
  \draw[->] (f) -- (out);
\end{tikzpicture}
\caption{Perzeptron: gewichtete Summe und Aktivierungsfunktion}
\end{figure}
```

### Multi-layer network

Change the four counts at the top to resize the network — everything else (nodes
and the fully-connected edges) is generated with `\foreach`.

```{=latex}
\begin{figure}[H]
\centering
\begin{tikzpicture}[
  neuron/.style={circle, draw, minimum size=0.7cm, fill=white},
  >=Stealth, node distance=0.9cm
]
  % --- adjust these numbers, the rest adapts automatically ---
  \def\nin{4}\def\nha{5}\def\nhb{5}\def\nout{3}

  \foreach \i in {1,...,\nin} {
    \node[neuron] (I\i) at (0, -\i*1.1) {};
    \node[left=0.2cm of I\i, font=\small] {$x_\i$};
  }
  \foreach \i in {1,...,\nha} \node[neuron] (A\i) at (2.5, {-\i*1.1+0.55}) {};
  \foreach \i in {1,...,\nhb} \node[neuron] (B\i) at (5,   {-\i*1.1+0.55}) {};
  \foreach \i in {1,...,\nout} \node[neuron] (O\i) at (7.5, {-\i*1.1-0.55}) {};

  % Fully-connected edges
  \foreach \i in {1,...,\nin}  \foreach \j in {1,...,\nha} \draw[gray!50,->] (I\i) -- (A\j);
  \foreach \i in {1,...,\nha}  \foreach \j in {1,...,\nhb} \draw[gray!50,->] (A\i) -- (B\j);
  \foreach \i in {1,...,\nhb}  \foreach \j in {1,...,\nout} \draw[gray!50,->] (B\i) -- (O\j);

  \node[below=0.6cm of I\nin, font=\small, align=center] {Input\\Layer};
  \node[font=\small, align=center] at (3.75, -6.6) {Hidden Layers};
  \node[below=0.6cm of O\nout, font=\small, align=center] {Output\\Layer};
  \draw[->] (0,-7.2) -- (7.5,-7.2) node[midway, below, font=\small] {Forward Propagation};
\end{tikzpicture}
\caption{Mehrschichtiges neuronales Netz (vollständig verbunden)}
\end{figure}
```

**Adapt it:** node coordinates are `(x, y)`; columns share an `x`, rows step in
`y`. The `\foreach \i \foreach \j` double loop draws every edge between two
layers — change a count and the wiring follows. For very large nets the dedicated
`neuralnetwork` package is an alternative, but the `\foreach` recipe above needs
no extra packages.

> **Note:** TikZ pictures are compiled by LaTeX directly, so they only render in
> the PDF build — not in a Markdown preview. Keep them in ` ```{=latex} ``` `
> raw blocks so other output formats simply skip them.

## More engines

The same `.engine` mechanism works for many other Kroki diagram types, e.g.:

- **PlantUML** (`.plantuml`) — UML, sequence, component, state diagrams.
- **GraphViz** (`.graphviz` / `.dot`) — any node/edge graph.
- **nomnoml** (`.nomnoml`) — lightweight UML-ish class diagrams.
- **ditaa** (`.ditaa`) — turn ASCII art into clean diagrams.
- **svgbob** (`.svgbob`) — ASCII art → SVG.
- **erd** (`.erd`) — entity-relationship diagrams.

See the rendered results in `documentation.md` and the official galleries for
[Mermaid](https://mermaid.js.org), [PlantUML](https://plantuml.com) and
[Graphviz](https://graphviz.org/gallery/).
