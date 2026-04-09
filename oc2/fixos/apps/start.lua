local ui = require("fixos.lib.ui")

local start = {}

function start.run()
  local choice = ui.menu("Start Menu", {
    "Explorer",
    "Browser",
    "Settings",
    "About",
    "Shutdown",
    "Back"
  }, "Select app from start menu")

  if choice == 1 then
    return "explorer"
  elseif choice == 2 then
    return "browser"
  elseif choice == 3 then
    return "settings"
  elseif choice == 4 then
    return "about"
  elseif choice == 5 then
    return "shutdown"
  end
  return nil
end

return start
