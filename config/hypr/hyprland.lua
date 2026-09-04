-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Personal environment variables
hl.env("XCURSOR_SIZE", "18")
hl.env("HYPRCURSOR_SIZE", "18")

-- Window rules
o.window("^(chrome-chatgpt\\.com.*|chrome-claude\\.ai.*)$", { workspace = "3" })
o.window("^(chrome-web\\.telegram\\.org.*|org\\.telegram\\.desktop|chrome-web\\.whatsapp\\.com.*|chrome-discord\\.com.*|chrome-teams\\.microsoft\\.com.*|com\\.github\\.IsmaelMartinez\\.teams_for_linux)$", { workspace = "5" })
o.window("org.gnome.Boxes", { workspace = "6" })

o.window("float-window", {
  float = true,
  center = true,
  size = "800 600",
})

o.window("float-paste", {
  float = true,
  center = true,
  size = "750 550",
})

o.window("float-paste-image", {
  float = true,
  center = true,
})
