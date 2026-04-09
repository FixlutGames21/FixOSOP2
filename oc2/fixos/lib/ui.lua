local env = require("fixos.lib.env")

local ui = {}

local function clip(text, width)
  text = tostring(text or "")
  if #text <= width then
    return text
  end
  if width <= 3 then
    return text:sub(1, width)
  end
  return text:sub(1, width - 3) .. "..."
end

function ui.clear()
  env.clear()
end

function ui.writeAt(x, y, text)
  env.setCursor(x, y)
  io.write(text or "")
end

function ui.hline(x, y, width, char)
  ui.writeAt(x, y, string.rep(char or "-", width))
end

function ui.box(x, y, width, height, title)
  ui.writeAt(x, y, "+" .. string.rep("-", width - 2) .. "+")
  for row = y + 1, y + height - 2 do
    ui.writeAt(x, row, "|" .. string.rep(" ", width - 2) .. "|")
  end
  ui.writeAt(x, y + height - 1, "+" .. string.rep("-", width - 2) .. "+")
  if title and title ~= "" then
    ui.writeAt(x + 2, y, "[" .. clip(title, width - 6) .. "]")
  end
end

function ui.center(y, text)
  local width = select(1, env.getResolution())
  local x = math.max(1, math.floor((width - #text) / 2))
  ui.writeAt(x, y, text)
end

function ui.header(title, subtitle)
  local width = select(1, env.getResolution())
  ui.hline(1, 1, width, "=")
  ui.center(2, title)
  ui.center(3, subtitle or "")
  ui.hline(1, 4, width, "=")
end

function ui.footer(text)
  local width, height = env.getResolution()
  ui.hline(1, height - 1, width, "=")
  ui.writeAt(2, height, clip(text or "", width - 2))
end

function ui.prompt(label)
  io.write(label or "> ")
  local value = env.readLine()
  return tostring(value or ""):gsub("[\r\n]+", "")
end

function ui.pause(label)
  ui.prompt(label or "Press Enter...")
end

function ui.menu(title, items, footer)
  ui.clear()
  ui.header("FixOS", title)
  for index, item in ipairs(items) do
    ui.writeAt(4, 5 + index, string.format("%d. %s", index, item))
  end
  ui.footer(footer or "Select menu item number")
  local value = tonumber(ui.prompt("\nChoice: "))
  return value
end

function ui.statusBar(left, right)
  local width, height = env.getResolution()
  local rightText = right or ""
  local leftText = left or ""
  local spacer = math.max(1, width - #leftText - #rightText - 2)
  ui.writeAt(1, height, leftText .. string.rep(" ", spacer) .. rightText)
end

return ui
