local env = require("fixos.lib.env")
local ui = require("fixos.lib.ui")

local explorer = {}

local function parentPath(path)
  if path == "/" then
    return "/"
  end
  local parent = path:match("(.+)/[^/]+$")
  if not parent or parent == "" then
    return "/"
  end
  return parent
end

local function readTextFile(path)
  local data = env.readFile(path)
  ui.clear()
  ui.header("Explorer", path)
  if not data then
    ui.writeAt(3, 6, "Unable to read file.")
  else
    local row = 6
    for line in tostring(data):gmatch("([^\n]*)\n?") do
      if line == "" and row > 20 then
        break
      end
      ui.writeAt(3, row, line)
      row = row + 1
      if row > 20 then
        break
      end
    end
  end
  ui.pause("\nPress Enter to continue...")
end

function explorer.run(state)
  while true do
    ui.clear()
    ui.header("Explorer", state.currentPath)
    local entries = env.list(state.currentPath)
    ui.writeAt(3, 6, "[0] ..")
    for index, entry in ipairs(entries) do
      local fullPath = env.join(state.currentPath, entry)
      local marker = env.isDirectory(fullPath) and "[DIR]" or "[FILE]"
      ui.writeAt(3, 6 + index, string.format("[%d] %s %s", index, marker, entry))
    end
    ui.writeAt(3, 8 + #entries, "M. Make folder")
    ui.writeAt(3, 9 + #entries, "R. Refresh")
    ui.writeAt(3, 10 + #entries, "B. Back")
    ui.footer("Explorer supports browsing, mkdir and text preview")

    local answer = ui.prompt("\nOpen item: ")
    if answer == "b" or answer == "B" then
      return
    elseif answer == "r" or answer == "R" then
    elseif answer == "m" or answer == "M" then
      local name = ui.prompt("Folder name: ")
      if name ~= "" then
        env.makeDirectory(env.join(state.currentPath, name))
      end
    else
      local choice = tonumber(answer)
      if choice == 0 then
        state.currentPath = parentPath(state.currentPath)
      elseif choice and entries[choice] then
        local target = env.join(state.currentPath, entries[choice])
        if env.isDirectory(target) then
          state.currentPath = target
        else
          readTextFile(target)
        end
      end
    end
  end
end

return explorer
