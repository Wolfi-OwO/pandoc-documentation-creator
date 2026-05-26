local mediabag = require 'pandoc.mediabag'
local path = require 'pandoc.path'
local system = require 'pandoc.system'
local utils = require 'pandoc.utils'

local function normalize_export_format(fmt)
  fmt = (fmt or ''):lower()
  if fmt == '' then
    return 'png'
  end
  if fmt == 'jpg' or fmt == 'jpeg' then
    return 'jpg'
  end
  if fmt == 'png' then
    return 'png'
  end
  io.stderr:write(
    string.format(
      "WARNING: Unsupported SVG_EXPORT_FORMAT=%q; falling back to \"png\".\n",
      fmt
    )
  )
  return 'png'
end

local EXPORT_FORMAT = normalize_export_format(os.getenv('SVG_EXPORT_FORMAT'))
local EXPORT_DPI = tonumber(os.getenv('SVG_EXPORT_DPI') or '') or 300
local JPG_QUALITY = tonumber(os.getenv('SVG_EXPORT_JPG_QUALITY') or '') or 92

local converted_by_sha1 = {}

local function strip_fragment_and_query(src)
  return (src or ''):gsub('[?#].*$', '')
end

local function looks_like_svg(src)
  if type(src) ~= 'string' or src == '' then
    return false
  end
  local stripped = strip_fragment_and_query(src)
  return stripped:lower():match('%.svg$') ~= nil
end

local function read_file(filename)
  local handle, err = io.open(filename, 'rb')
  if not handle then
    error(string.format('Failed to read %q: %s', tostring(filename), tostring(err)))
  end
  local contents = handle:read('*all')
  handle:close()
  return contents or ''
end

local function write_file(filename, contents)
  local handle, err = io.open(filename, 'wb')
  if not handle then
    error(string.format('Failed to write %q: %s', tostring(filename), tostring(err)))
  end
  handle:write(contents or '')
  handle:close()
end

local function pipe_ok(cmd, args, input)
  local ok, res = pcall(pandoc.pipe, cmd, args, input or '')
  return ok, res
end

local function run_or_error(cmd, args)
  local ok, res = pipe_ok(cmd, args, '')
  if ok then
    return res
  end
  error(res)
end

local function run_imagemagick(args)
  local ok, res = pipe_ok('convert', args, '')
  if ok then
    return res
  end
  local ok2, res2 = pipe_ok('magick', args, '')
  if ok2 then
    return res2
  end
  error(
    string.format(
      "ImageMagick is required for JPG export.\nconvert error: %s\nmagick error: %s",
      tostring(res),
      tostring(res2)
    )
  )
end

local function ensure_converted(svg_contents)
  local sha1 = utils.sha1(svg_contents)
  if converted_by_sha1[sha1] then
    return converted_by_sha1[sha1]
  end

  local out_rel = string.format('media/%s.%s', sha1, EXPORT_FORMAT)
  local out_mime = (EXPORT_FORMAT == 'png') and 'image/png' or 'image/jpeg'

  local existing_mime, existing_contents = mediabag.lookup(out_rel)
  if existing_mime and existing_contents then
    converted_by_sha1[sha1] = out_rel
    return out_rel
  end

  system.with_temporary_directory('pandoc-svg-', function(tmpdir)
    local in_svg = path.join({tmpdir, 'input.svg'})
    local tmp_png = path.join({tmpdir, 'output.png'})
    local tmp_jpg = path.join({tmpdir, 'output.jpg'})

    write_file(in_svg, svg_contents)

    local inkscape_args = {
      '--batch-process',
      '--export-type=png',
      '--export-filename=' .. tmp_png,
      '--export-dpi=' .. tostring(EXPORT_DPI),
      in_svg
    }

    run_or_error('inkscape', inkscape_args)

    if EXPORT_FORMAT == 'png' then
      mediabag.insert(out_rel, out_mime, read_file(tmp_png))
      return
    end

    local convert_args = {
      tmp_png,
      '-background',
      'white',
      '-alpha',
      'remove',
      '-alpha',
      'off',
      '-quality',
      tostring(JPG_QUALITY),
      tmp_jpg
    }

    run_imagemagick(convert_args)
    mediabag.insert(out_rel, out_mime, read_file(tmp_jpg))
  end)

  converted_by_sha1[sha1] = out_rel
  return out_rel
end

local function Image(elem)
  if not FORMAT:match('latex') then
    return nil
  end

  if not looks_like_svg(elem.src) then
    return nil
  end

  local fetch_src = strip_fragment_and_query(elem.src)
  local mime, contents = mediabag.fetch(fetch_src)
  if not mime or mime == '' or not contents or contents == '' then
    return nil
  end

  local new_src = ensure_converted(contents)
  elem.src = new_src
  return elem
end

return {Image = Image}
