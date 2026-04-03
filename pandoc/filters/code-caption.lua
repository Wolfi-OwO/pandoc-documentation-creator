-- code-caption.lua - Enhanced for listings package
local code_counter = 0

local function latex_escape(text)
    local function escape_pattern(s)
        return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
    end
    local replacements = {{"\\", "\\textbackslash{}"}, {"{", "\\{"}, {"}", "\\}"}, {"%", "\\%"}, {"&", "\\&"},
                          {"#", "\\#"}, {"_", "\\_"}, {"$", "\\$"}, {"~", "\\textasciitilde{}"},
                          {"^", "\\textasciicircum{}"}}
    for _, pair in ipairs(replacements) do
        text = text:gsub(escape_pattern(pair[1]), pair[2])
    end
    return text
end

function CodeBlock(el)
    local id = el.identifier or ""
    local user_caption = el.attributes["caption"] or el.attributes["name"] or ""
    local language = ""
    if el.classes and #el.classes > 0 then
        language = el.classes[1]
    end

    code_counter = code_counter + 1
    local text = "Code " .. tostring(code_counter)
    if user_caption ~= "" then
        text = text .. ": " .. user_caption
    end

    if FORMAT:match("latex") then
        -- Use a custom caption block to avoid visible escape sequences
        local escaped = latex_escape(text)
        el.attributes["caption"] = nil
        el.attributes["title"] = nil

        -- Add language and style if specified
        if language ~= "" then
            local normalized = string.lower(language)
            local alias_map = {
                py = "python",
                js = "javascript",
                ts = "typescript",
                tsx = "typescript",
                jsx = "javascript",
                cs = "csharp",
                ["c#"] = "csharp",
                ["c++"] = "cpp",
                sh = "bash",
                shell = "bash",
                zsh = "bash",
                yml = "yaml",
                dockerfile = "docker",
                tex = "latex",
                xhtml = "xml"
            }
            if alias_map[normalized] then
                normalized = alias_map[normalized]
            end

            local language_definitions = {
                python = {listings = "Python", style = "vscode-python"},
                java = {listings = "Java", style = "vscode-java"},
                javascript = {listings = "JavaScript", style = "vscode-javascript"},
                typescript = {listings = "JavaScript", style = "vscode-typescript"},
                cpp = {listings = "C++", style = "vscode-cpp"},
                c = {listings = "C", style = "vscode-c"},
                csharp = {listings = "CSharp", style = "vscode-csharp"},
                rust = {listings = "Rust", style = "vscode-rust"},
                go = {listings = "Go", style = "vscode-go"},
                sql = {listings = "SQL", style = "vscode-sql"},
                bash = {listings = "bash", style = "vscode-bash"},
                yaml = {listings = "YAML", style = "vscode-yaml"},
                json = {listings = "JSON", style = "vscode-json"},
                html = {listings = "HTML", style = "vscode-html"},
                xml = {listings = "XML", style = "vscode-xml"},
                css = {listings = "CSS", style = "vscode-css"},
                ruby = {listings = "Ruby", style = "vscode-ruby"},
                php = {listings = "PHP", style = "vscode-php"},
                swift = {listings = "Swift", style = "vscode-swift"},
                kotlin = {listings = "Kotlin", style = "vscode-kotlin"},
                matlab = {listings = "Matlab", style = "vscode-matlab"},
                r = {listings = "R", style = "vscode-r"},
                docker = {listings = "Docker", style = "vscode-docker"},
                latex = {listings = "TeX", style = "vscode-latex"}
            }

            local def = language_definitions[normalized]
            if def then
                if def.listings and def.listings ~= "" then
                    el.attributes["language"] = def.listings
                end
                if def.style and def.style ~= "" then
                    el.attributes["style"] = def.style
                end
            end
        end

        return {el, pandoc.RawBlock("latex", "\\CodeCaption{" .. escaped .. "}")}
    end

    return el
end

function Code(elem)
    if FORMAT:match("latex") then
        -- For inline code, just pass through
        return elem
    end
    return elem
end
