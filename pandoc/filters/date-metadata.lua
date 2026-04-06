local stringify = pandoc.utils.stringify

local function meta_to_string(meta, key)
  local value = meta[key]
  if value == nil then
    return nil
  end

  local text = stringify(value)
  if text == "" then
    return nil
  end

  return text
end

function Meta(meta)
  local explicit_date = meta_to_string(meta, "date")
  if explicit_date ~= nil then
    return meta
  end

  local date_format = meta_to_string(meta, "date-format")
  if date_format == nil then
    return meta
  end

  local ok, formatted_date = pcall(os.date, date_format)
  if ok and formatted_date ~= nil and formatted_date ~= "" then
    meta.date = pandoc.MetaInlines({ pandoc.Str(formatted_date) })
  end

  return meta
end
