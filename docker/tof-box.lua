-- tof-box.lua

function CodeBlock(el)
  if el.classes:includes("tof") then

    local lines = {}
    for line in el.text:gmatch("[^\r\n]+") do
      table.insert(lines, line)
    end

    if #lines == 0 then
      return nil
    end
    local latex = "{\n\\renewcommand{\\arraystretch}{1.5}"
    latex = latex .. "\\begin{tabular}{|p{0.7cm}|p{14.4cm}|}\n"
    latex = latex .. "\\hline\n"
    latex = latex .. "\\small{W/F} & \\emph{Aussage}\\\\\n \\hline\n"

    for i, statementLine in ipairs(lines) do
        local lineAsDoc = pandoc.read(statementLine, "markdown")
        local inlines = {}
        for _, blk in ipairs(lineAsDoc.blocks) do
        if blk.t == "Para" then
            for _, inline in ipairs(blk.content) do
            table.insert(inlines, inline)
            end
        end
        end
        local processedLine = pandoc.Pandoc({pandoc.Para(inlines)})
        local latexLine = pandoc.write(processedLine, "latex")      
      
      latex = latex .. "$\\square$ $\\square$ & ".. latexLine .. " \\\\\n\\hline\n"
    end

    latex = latex .. "\\end{tabular}\n"
    latex = latex .. "}\n"

    return pandoc.RawBlock('latex', latex)
  end
end
