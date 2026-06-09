-- pdf-style.lua
-- Applies PDF visual themes and injects table header-row coloring.
--
-- Reads `pdf-theme` from document metadata (modern | classic | minimal).
-- Also supports per-property overrides:
--   table-header-color  hex color for the header row background (with or without #)
--   table-accent-color  hex color for rules and the header/footer accent
--   table-row-color     hex color for alternating row backgrounds
--
-- The generated LaTeX is written to a dedicated `pdf-style-preamble` metadata
-- variable (rendered last in the template preamble) rather than to
-- `header-includes`. This matters because the build pipeline passes header.tex
-- via --include-in-header (-H), which sets the `header-includes` *variable* and
-- would otherwise clobber anything a filter appends to the `header-includes`
-- metadata. A dedicated variable is immune to that and still runs in the
-- preamble, so accent colors apply to the title page and header/footer too.

local function stringify(val)
  if val == nil then return nil end
  return pandoc.utils.stringify(val)
end

local function strip_hash(hex)
  return (hex or ''):gsub('#', ''):upper()
end

function Meta(meta)
  local theme = stringify(meta['pdf-theme']) or 'modern'

  local parts = {}
  local function add(latex) table.insert(parts, latex) end

  -- ── Theme-specific overrides ─────────────────────────────────────────────

  if theme == 'classic' then
    -- Traditional LaTeX look: no colored rows, black rules, standard booktabs.
    add([[
% === Classic Theme ===
\arrayrulecolor{black}
\setlength\heavyrulewidth{0.08em}
\setlength\lightrulewidth{0.05em}
\renewcommand{\PDFTableHeaderColor}{}
% Disable alternating row colors for the classic look.
\renewenvironment{longtable}{%
  \oldlongtable
}{%
  \endoldlongtable
}]])

  elseif theme == 'minimal' then
    -- Clean modern: no colored header, very subtle alternating rows.
    add([[
% === Minimal Theme ===
\definecolor{headercolor}{RGB}{70,70,70}
\definecolor{table-rule-color}{RGB}{180,180,180}
\arrayrulecolor{table-rule-color}
\renewcommand{\PDFTableHeaderColor}{}
\renewenvironment{longtable}{%
  \rowcolors{2}{white}{table-row-color}%
  \oldlongtable
}{%
  \endoldlongtable
}]])
  end
  -- modern theme: template defaults apply (colored header, alternating rows).

  -- ── Per-property color overrides ─────────────────────────────────────────

  local overrides = {}

  local hdr = strip_hash(stringify(meta['table-header-color']))
  if hdr ~= '' then
    table.insert(overrides, string.format('\\definecolor{table-header-bg}{HTML}{%s}', hdr))
    -- Re-enable the header color command even if a theme disabled it.
    table.insert(overrides, '\\renewcommand{\\PDFTableHeaderColor}{\\rowcolor{table-header-bg}}')
  end

  local accent = strip_hash(stringify(meta['table-accent-color']))
  if accent ~= '' then
    table.insert(overrides, string.format('\\definecolor{headercolor}{HTML}{%s}', accent))
    table.insert(overrides, string.format('\\definecolor{table-rule-color}{HTML}{%s}', accent))
    table.insert(overrides, '\\arrayrulecolor{table-rule-color}')
  end

  local row_col = strip_hash(stringify(meta['table-row-color']))
  if row_col ~= '' then
    table.insert(overrides, string.format('\\definecolor{table-row-color}{HTML}{%s}', row_col))
  end

  if #overrides > 0 then
    add('% === User Table Color Overrides ===\n' .. table.concat(overrides, '\n'))
  end

  if #parts > 0 then
    local latex = table.concat(parts, '\n')
    meta['pdf-style-preamble'] = pandoc.MetaBlocks(pandoc.Blocks({
      pandoc.RawBlock('latex', latex)
    }))
  end

  return meta
end

-- ── Table header row coloring ─────────────────────────────────────────────
-- Prepend \PDFTableHeaderColor{} to the first cell of every table header row.
-- In the modern theme this expands to \rowcolor{table-header-bg}; in other
-- themes it is redefined to a no-op so no coloring is applied.

function Table(tbl)
  if not tbl.head or not tbl.head.rows or #tbl.head.rows == 0 then
    return nil
  end

  local first_row = tbl.head.rows[1]
  if not first_row or not first_row.cells or #first_row.cells == 0 then
    return nil
  end

  local first_cell = first_row.cells[1]
  local color_cmd  = pandoc.RawBlock('latex', '\\PDFTableHeaderColor{}')

  local new_blocks = { color_cmd }
  for _, block in ipairs(first_cell.contents) do
    table.insert(new_blocks, block)
  end
  first_cell.contents = pandoc.Blocks(new_blocks)

  return tbl
end
