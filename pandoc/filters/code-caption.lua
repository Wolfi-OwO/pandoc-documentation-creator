-- code-caption.lua
function CodeBlock(el)
  local id = el.identifier or ""
  local classes = el.classes or {}

  -- Mapping table for VSCode styles defined in listings-languages.tex
  local style_map = {
    cs = "vscode-csharp",
    csharp = "vscode-csharp",
    c = "vscode-c",
    cpp = "vscode-cpp",
    ["c++"] = "vscode-cpp",
    java = "vscode-java",
    js = "vscode-javascript",
    javascript = "vscode-javascript",
    ts = "vscode-typescript",
    typescript = "vscode-typescript",
    py = "vscode-python",
    python = "vscode-python",
    go = "vscode-go",
    rust = "vscode-rust",
    php = "vscode-php",
    ruby = "vscode-ruby",
    sql = "vscode-sql",
    bash = "vscode-bash",
    sh = "vscode-bash",
    shell = "vscode-bash",
    yaml = "vscode-yaml",
    yml = "vscode-yaml",
    json = "vscode-json",
    html = "vscode-html",
    xml = "vscode-xml",
    dockerfile = "vscode-docker"
  }

  -- IMPORTANT: Use 'style' attribute. 
  -- Pandoc --listings maps this to [style=...] in LaTeX.
  if not el.attributes["style"] then
    for _, cls in ipairs(classes) do
      local key = cls:lower()
      if style_map[key] then
        el.attributes["style"] = style_map[key]
        break
      end
    end
  end

  -- Clean Caption Logic:
  -- We rely on Pandoc's --listings to handle "Listing X:" automatically.
  local user_caption = el.attributes["caption"] or ""
  if user_caption ~= "" then
    el.attributes["caption"] = user_caption
  end

  return el
end