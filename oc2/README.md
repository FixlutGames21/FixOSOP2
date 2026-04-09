# FixOS for OpenComputers 2

This folder contains the OC2-oriented Lua shell version of FixOS.

Included:

- `fixos/main.lua` - main desktop shell
- `fixos/apps/explorer.lua` - file explorer
- `fixos/apps/browser.lua` - browser placeholder with internal pages
- `fixos/apps/settings.lua` - settings screen
- `fixos/apps/about.lua` - system information
- `installer.lua` - installer for copying FixOS into `/home/fixos`

Expected install flow inside OpenComputers 2:

1. Copy this `oc2` folder to a mounted disk.
2. Make sure it is accessible as `/mnt/fixos`.
3. Run `lua /mnt/fixos/installer.lua`
4. Then run `lua /home/fixos.lua`

Notes:

- this build is text UI first, for easier OC2 adaptation
- it is designed as a base shell that can later gain real windows, mouse support and hardware integration
