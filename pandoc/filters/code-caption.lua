-- code-caption.lua
local code_counter = 0

local function latex_escape(text)
    local function escape_pattern(s)
        return (s:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
    end
    local replacements = {
        {"\\", "\\textbackslash{}"},
        {"{", "\\{"},
        {"}", "\\}"},
        {"%", "\\%"},
        {"&", "\\&"},
        {"#", "\\#"},
        {"_", "\\_"},
        {"$", "\\$"},
        {"~", "\\textasciitilde{}"},
        {"^", "\\textasciicircum{}"},
    }
    for _, pair in ipairs(replacements) do
        text = text:gsub(escape_pattern(pair[1]), pair[2])
    end
    return text
end

function CodeBlock(el)
    local id = el.identifier or ""
    local user_caption = el.attributes["caption"] or el.attributes["name"] or ""

    el.attributes["numberLines"] = el.attributes["numberLines"] or "true"
    el.attributes["startFrom"] = el.attributes["startFrom"] or "1"
    local has_number = false
    for _, cls in ipairs(el.classes or {}) do
        if cls == "numberLines" then
            has_number = true
            break
        end
    end
    if not has_number then
        table.insert(el.classes, "numberLines")
    end

    if user_caption == "" and id:match("^code%-") then
        user_caption = id:gsub("^code%-", ""):gsub("%-", " ")
    end

    code_counter = code_counter + 1
    local text = "Code " .. tostring(code_counter)
    if user_caption ~= "" then
        text = text .. ": " .. user_caption
    end

    if FORMAT:match("latex") then
        local escaped = latex_escape(text)
        return { el, pandoc.RawBlock("latex", "\\CodeCaption{" .. escaped .. "}") }
    end

    return { el, pandoc.Para({ pandoc.Str(text) }) }
end