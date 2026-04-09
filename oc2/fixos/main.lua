local ui = require("fixos.lib.ui")
local env = require("fixos.lib.env")

local apps = {
  explorer = require("fixos.apps.explorer"),
  browser = require("fixos.apps.browser"),
  settings = require("fixos.apps.settings"),
  about = require("fixos.apps.about"),
  start = require("fixos.apps.start")
}

local state = {
  theme = "Aero Blue",
  computerName = "FixOS-PC",
  currentPath = "/",
  browserAddress = "fixos://home",
  running = true
}

local function clockString()
  local uptime = math.floor(env.getTime())
  return "uptime:" .. tostring(uptime)
end

local function renderDesktop()
  ui.clear()
  ui.header("FixOS Desktop", "OpenComputers 2 Reimagine")
  ui.box(3, 6, 28, 5, "Desktop")
  ui.writeAt(5, 8, "1. Explorer")
  ui.writeAt(5, 9, "2. Browser")
  ui.writeAt(5, 10, "3. Settings")
  ui.box(34, 6, 28, 5, "System")
  ui.writeAt(36, 8, "4. About")
  ui.writeAt(36, 9, "5. Start Menu")
  ui.writeAt(36, 10, "6. Shutdown")
  ui.box(3, 13, 59, 6, "Taskbar")
  ui.writeAt(5, 15, "Theme: " .. state.theme)
  ui.writeAt(5, 16, "Computer: " .. state.computerName)
  ui.writeAt(5, 17, "Path: " .. state.currentPath)
  ui.statusBar("[Start]", clockString())
end

local function runChoice(choice)
  if choice == "1" then
    apps.explorer.run(state)
  elseif choice == "2" then
    apps.browser.run(state)
  elseif choice == "3" then
    apps.settings.run(state)
  elseif choice == "4" then
    apps.about.run(state)
  elseif choice == "5" then
    local selected = apps.start.run()
    if selected == "shutdown" then
      state.running = false
    elseif selected and apps[selected] then
      apps[selected].run(state)
    end
  elseif choice == "6" then
    state.running = false
  end
end

while state.running do
  renderDesktop()
  local choice = ui.prompt("\nOpen app: ")
  runChoice(choice)
end

ui.clear()
ui.header("FixOS", "Shutdown")
ui.writeAt(3, 7, "Session closed.")
