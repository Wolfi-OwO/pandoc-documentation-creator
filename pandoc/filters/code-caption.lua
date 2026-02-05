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

        -- Add language class if specified
        if language ~= "" then
            -- Convert Pandoc language to listings language
            local lang_map = {
                python = "Python",
                py = "Python",
                java = "Java",
                javascript = "JavaScript",
                js = "JavaScript",
                typescript = "JavaScript",
                ts = "JavaScript",
                cpp = "C++",
                c = "C",
                csharp = "CSharp",
                cs = "CSharp",
                rust = "Rust",
                go = "Go",
                sql = "SQL",
                bash = "bash",
                sh = "bash",
                yaml = "YAML",
                yml = "YAML",
                json = "JSON",
                html = "HTML",
                css = "CSS",
                ruby = "Ruby",
                php = "PHP",
                swift = "Swift",
                kotlin = "Kotlin",
                matlab = "Matlab",
                r = "R",
                docker = "Docker",
                latex = "TeX"
            }

            local lang_key = lang_map[language] or ""
            if lang_key ~= "" then
                el.attributes["language"] = lang_key
            end
        end

        -- Apply listings style per language
        local style_map = {
            python = "vscode-python",
            py = "vscode-python",
            java = "vscode-java",
            javascript = "vscode-javascript",
            js = "vscode-javascript",
            typescript = "vscode-typescript",
            ts = "vscode-typescript",
            csharp = "vscode-csharp",
            cs = "vscode-csharp",
            cpp = "vscode-cpp",
            c = "vscode-c",
            rust = "vscode-rust",
            go = "vscode-go",
            sql = "vscode-sql",
            bash = "vscode-bash",
            sh = "vscode-bash",
            yaml = "vscode-yaml",
            yml = "vscode-yaml",
            json = "vscode-json",
            html = "vscode-html",
            css = "vscode-css",
            ruby = "vscode-ruby",
            php = "vscode-php",
            swift = "vscode-swift",
            kotlin = "vscode-kotlin",
            matlab = "vscode-matlab",
            r = "vscode-r",
            docker = "vscode-docker",
            latex = "vscode-latex"
        }
        local style_name = style_map[language]
        if style_name then
            el.attributes["style"] = style_name
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
