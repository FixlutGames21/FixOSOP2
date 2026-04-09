local env = {}

local function safeRequire(name)
  local ok, value = pcall(require, name)
  if ok then
    return value
  end
  return nil
end

env.filesystem = _G.filesystem or safeRequire("filesystem") or safeRequire("fs")
env.term = _G.term or safeRequire("term")
env.computer = _G.computer or safeRequire("computer")
env.shell = _G.shell or safeRequire("shell")

local function normalize(path)
  if not path or path == "" then
    return "/"
  end
  path = tostring(path):gsub("\\", "/")
  if path:sub(1, 1) ~= "/" then
    path = "/" .. path
  end
  path = path:gsub("/+", "/")
  if #path > 1 and path:sub(-1) == "/" then
    path = path:sub(1, -2)
  end
  return path
end

function env.join(...)
  local parts = {...}
  return normalize(table.concat(parts, "/"))
end

function env.exists(path)
  local fs = env.filesystem
  path = normalize(path)
  if fs and fs.exists then
    return fs.exists(path)
  end
  local file = io.open("." .. path, "rb")
  if file then
    file:close()
    return true
  end
  return false
end

function env.isDirectory(path)
  local fs = env.filesystem
  path = normalize(path)
  if fs and fs.isDirectory then
    return fs.isDirectory(path)
  end
  return false
end

function env.list(path)
  local fs = env.filesystem
  path = normalize(path)
  local items = {}
  if fs and fs.list then
    for entry in fs.list(path) do
      items[#items + 1] = entry
    end
  end
  table.sort(items)
  return items
end

function env.makeDirectory(path)
  local fs = env.filesystem
  path = normalize(path)
  if fs and fs.makeDirectory then
    return fs.makeDirectory(path)
  end
  return false
end

function env.readFile(path)
  path = normalize(path)
  if env.filesystem and env.filesystem.open then
    local handle = env.filesystem.open(path, "r")
    if not handle then
      return nil
    end
    local chunks = {}
    while true do
      local chunk = env.filesystem.read(handle, math.huge)
      if not chunk then
        break
      end
      chunks[#chunks + 1] = chunk
    end
    env.filesystem.close(handle)
    return table.concat(chunks)
  end

  local file = io.open("." .. path, "rb")
  if not file then
    return nil
  end
  local data = file:read("*a")
  file:close()
  return data
end

function env.writeFile(path, data)
  path = normalize(path)
  if env.filesystem and env.filesystem.open then
    local handle = env.filesystem.open(path, "w")
    if not handle then
      return false
    end
    env.filesystem.write(handle, data)
    env.filesystem.close(handle)
    return true
  end

  local file = io.open("." .. path, "wb")
  if not file then
    return false
  end
  file:write(data)
  file:close()
  return true
end

function env.getTime()
  if env.computer and env.computer.uptime then
    return env.computer.uptime()
  end
  return os.time()
end

function env.getResolution()
  if env.term and env.term.getViewport then
    return env.term.getViewport()
  end
  if env.term and env.term.getSize then
    return env.term.getSize()
  end
  return 80, 25
end

function env.clear()
  if env.term and env.term.clear then
    env.term.clear()
  else
    io.write(string.rep("\n", 30))
  end
end

function env.setCursor(x, y)
  if env.term and env.term.setCursor then
    env.term.setCursor(x, y)
  end
end

function env.readLine()
  if env.term and env.term.read then
    return env.term.read() or ""
  end
  return io.read() or ""
end

function env.sleep(seconds)
  if os.sleep then
    os.sleep(seconds)
  end
end

return env
