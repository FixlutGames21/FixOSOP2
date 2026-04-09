local filesystem = _G.filesystem or (_G.require and require("filesystem"))

local sourceRoot = "/mnt/fixos"
local targetRoot = "/home/fixos"

local files = {
  "main.lua",
  "apps/about.lua",
  "apps/browser.lua",
  "apps/explorer.lua",
  "apps/settings.lua",
  "apps/start.lua",
  "lib/env.lua",
  "lib/ui.lua"
}

local function normalize(path)
  path = tostring(path or ""):gsub("\\", "/"):gsub("/+", "/")
  if path == "" then
    path = "/"
  end
  if path:sub(1, 1) ~= "/" then
    path = "/" .. path
  end
  if #path > 1 and path:sub(-1) == "/" then
    path = path:sub(1, -2)
  end
  return path
end

local function join(...)
  return normalize(table.concat({...}, "/"))
end

local function exists(path)
  path = normalize(path)
  return filesystem and filesystem.exists and filesystem.exists(path)
end

local function makeDirectory(path)
  path = normalize(path)
  if filesystem and filesystem.makeDirectory then
    filesystem.makeDirectory(path)
  end
end

local function readFile(path)
  path = normalize(path)
  if not (filesystem and filesystem.open) then
    return nil
  end
  local handle = filesystem.open(path, "r")
  if not handle then
    return nil
  end
  local parts = {}
  while true do
    local chunk = filesystem.read(handle, math.huge)
    if not chunk then
      break
    end
    parts[#parts + 1] = chunk
  end
  filesystem.close(handle)
  return table.concat(parts)
end

local function writeFile(path, data)
  path = normalize(path)
  if not (filesystem and filesystem.open) then
    return false
  end
  local handle = filesystem.open(path, "w")
  if not handle then
    return false
  end
  filesystem.write(handle, data)
  filesystem.close(handle)
  return true
end

local function ensureDirectory(path)
  local current = ""
  for part in path:gmatch("[^/]+") do
    current = current .. "/" .. part
    if not exists(current) then
      makeDirectory(current)
    end
  end
end

local function copyFile(relativePath)
  local src = join(sourceRoot, "fixos", relativePath)
  local dst = join(targetRoot, relativePath)
  local directory = dst:match("(.+)/[^/]+$")
  if directory then
    ensureDirectory(directory)
  end
  local data = readFile(src)
  if not data then
    io.write("Missing source: " .. src .. "\n")
    return false
  end
  writeFile(dst, data)
  io.write("Copied " .. relativePath .. "\n")
  return true
end

io.write("FixOS installer for OpenComputers 2\n")
io.write("Source root: " .. sourceRoot .. "\n")
io.write("Target root: " .. targetRoot .. "\n\n")

ensureDirectory(targetRoot)

for _, file in ipairs(files) do
  copyFile(file)
end

local launcher = "package.path = package.path .. ';/home/?.lua;/home/?/init.lua'\nrequire('fixos.main')\n"
writeFile("/home/fixos.lua", launcher)

io.write("\nInstall complete.\n")
io.write("Run with: lua /home/fixos.lua\n")
