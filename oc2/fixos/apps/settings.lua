local ui = require("fixos.lib.ui")

local settings = {}

local themes = {
  "Aero Blue",
  "Slate",
  "Emerald"
}

function settings.run(state)
  while true do
    local choice = ui.menu("Settings", {
      "Theme: " .. state.theme,
      "Computer Name: " .. state.computerName,
      "Back"
    }, "1 = change theme, 2 = rename computer, 3 = return")

    if choice == 1 then
      local themeChoice = ui.menu("Select Theme", themes, "Pick theme number")
      if themes[themeChoice] then
        state.theme = themes[themeChoice]
      end
    elseif choice == 2 then
      ui.clear()
      ui.header("FixOS", "Rename Computer")
      local name = ui.prompt("\nNew name: ")
      if name ~= "" then
        state.computerName = name
      end
    else
      return
    end
  end
end

return settings
