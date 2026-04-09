local ui = require("fixos.lib.ui")

local browser = {}

local pages = {
  ["fixos://home"] = {
    "Welcome to FixOS Browser",
    "",
    "This is an internal page inside the FixOS shell.",
    "Use the browser to open internal docs or record URLs."
  },
  ["fixos://docs"] = {
    "FixOS docs",
    "",
    "Main modules:",
    "- desktop",
    "- explorer",
    "- settings",
    "- browser",
    "- start menu"
  },
  ["fixos://oc2"] = {
    "OpenComputers 2 Notes",
    "",
    "This build is designed as a shell starter for OC2.",
    "Next step is wiring real hardware and APIs."
  }
}

local function showPage(address)
  ui.clear()
  ui.header("FixOS Browser", address)
  local lines = pages[address] or {
    "External address or unknown page",
    "",
    "Saved URL: " .. address,
    "If your OC2 environment gets a network layer later,",
    "this module can be upgraded into a real browser."
  }

  for index, line in ipairs(lines) do
    ui.writeAt(3, 5 + index, line)
  end
  ui.pause("\nPress Enter to continue...")
end

function browser.run(state)
  while true do
    local choice = ui.menu("Browser", {
      "Home page",
      "Docs page",
      "OpenComputers 2 page",
      "Type custom address",
      "Back"
    }, "Browser stores and displays internal pages for now")

    if choice == 1 then
      state.browserAddress = "fixos://home"
      showPage(state.browserAddress)
    elseif choice == 2 then
      state.browserAddress = "fixos://docs"
      showPage(state.browserAddress)
    elseif choice == 3 then
      state.browserAddress = "fixos://oc2"
      showPage(state.browserAddress)
    elseif choice == 4 then
      ui.clear()
      ui.header("FixOS Browser", "Custom Address")
      local address = ui.prompt("\nAddress: ")
      if address ~= "" then
        state.browserAddress = address
        showPage(address)
      end
    else
      return
    end
  end
end

return browser
