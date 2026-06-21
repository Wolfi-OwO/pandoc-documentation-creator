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
