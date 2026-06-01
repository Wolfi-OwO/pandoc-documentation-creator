local DIAGRAM_CLASSES = {
  mermaid = true,
  plantuml = true,
  graphviz = true,
  dot = true,
  ditaa = true,
  erd = true,
  nomnoml = true,
  svgbob = true
}

local MAX_WIDTH_KEYS = {
  'max-width',
  'max_width',
  'maxwidth',
  'maxWidth'
}

local DIMENSION_UNITS = {
  bp = true,
  cc = true,
  cm = true,
  dd = true,
  em = true,
  ex = true,
  ['in'] = true,
  mm = true,
  pc = true,
  pt = true,
  sp = true
}

local LATEX_BASE_DIMENSIONS = {
  ['\\columnwidth'] = true,
  ['\\linewidth'] = true,
  ['\\paperwidth'] = true,
  ['\\textwidth'] = true
}

local function trim(value)
  return (value or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function format_number(value)
  return string.format('%.6g', value)
end

local function get_attribute(attributes, keys)
  for _, key in ipairs(keys) do
    local value = attributes[key]
    if value and value ~= '' then
      return value
    end
  end
  return nil
end

local function has_diagram_class(elem)
  for _, class in ipairs(elem.classes) do
    if DIAGRAM_CLASSES[class:lower()] then
      return true
    end
  end
  return false
end

local function normalize_dimension(value, percent_base)
  value = trim(value)
  if value == '' then
    return nil
  end

  local percent = value:match('^([%+%-]?%d*%.?%d+)%s*%%$')
  if percent then
    local number = tonumber(percent)
    if number and number > 0 then
      return format_number(number / 100) .. percent_base
    end
    return nil
  end

  local amount, unit = value:match('^([%+%-]?%d*%.?%d+)%s*([%a]+)$')
  if amount and unit then
    local number = tonumber(amount)
    if number and number > 0 then
      unit = unit:lower()
      if unit == 'px' then
        return format_number(number * 0.75) .. 'bp'
      end
      if DIMENSION_UNITS[unit] then
        return format_number(number) .. unit
      end
    end
    return nil
  end

  local coefficient, base = value:match('^([%+%-]?%d*%.?%d+)%s*(\\[%a]+)$')
  if coefficient and base and LATEX_BASE_DIMENSIONS[base] then
    local number = tonumber(coefficient)
    if number and number > 0 then
      return format_number(number) .. base
    end
    return nil
  end

  if LATEX_BASE_DIMENSIONS[value] then
    return value
  end

  local fraction = tonumber(value)
  if fraction and fraction > 0 and fraction <= 1 then
    return format_number(fraction) .. percent_base
  end

  return nil
end

local function includegraphics_options(elem)
  local options = {}
  local width = normalize_dimension(elem.attributes.width, '\\linewidth')
  local height = normalize_dimension(elem.attributes.height, '\\textheight')

  if width then
    table.insert(options, 'width=' .. width)
  end
  if height then
    table.insert(options, 'height=' .. height)
  end
  if #options > 0 then
    table.insert(options, 'keepaspectratio')
    return '[' .. table.concat(options, ',') .. ']'
  end

  return ''
end

local function detokenize_path(src)
  return '\\detokenize{' .. (src or ''):gsub('}', '\\}') .. '}'
end

local function Image(elem)
  if not FORMAT:match('latex') then
    return nil
  end

  if not has_diagram_class(elem) then
    return nil
  end

  local max_width = normalize_dimension(
    get_attribute(elem.attributes, MAX_WIDTH_KEYS),
    '\\linewidth'
  )

  if not max_width then
    return nil
  end

  local latex = string.format(
    '\\adjustbox{max width=%s,max height=\\textheight}{\\includegraphics%s{%s}}',
    max_width,
    includegraphics_options(elem),
    detokenize_path(elem.src)
  )

  return pandoc.RawInline('latex', latex)
end

return {Image = Image}
