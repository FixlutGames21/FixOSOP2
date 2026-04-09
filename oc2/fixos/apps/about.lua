local ui = require("fixos.lib.ui")

local about = {}

function about.run(state)
  ui.clear()
  ui.header("FixOS", "About System")
  ui.writeAt(3, 6, "FixOS Reimagine for OpenComputers 2")
  ui.writeAt(3, 8, "Style target: Windows 8 / Windows 10")
  ui.writeAt(3, 10, "Included modules:")
  ui.writeAt(5, 11, "- desktop shell")
  ui.writeAt(5, 12, "- start menu")
  ui.writeAt(5, 13, "- explorer")
  ui.writeAt(5, 14, "- settings")
  ui.writeAt(5, 15, "- browser")
  ui.writeAt(5, 16, "- context actions")
  ui.writeAt(3, 18, "Current theme: " .. state.theme)
  ui.writeAt(3, 19, "Current path: " .. state.currentPath)
  ui.footer("This OC2 build is text UI first and can be expanded later")
  ui.pause("\nPress Enter to return...")
end

return about
