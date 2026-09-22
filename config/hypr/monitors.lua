-- Monitor configuration

-- Laptop internal display (bottom)
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })

-- External display placed on top of internal display
-- Specific monitor rules followed by fallback for any external monitor
hl.monitor({ output = "desc:Dell Inc. DELL S2421HN BM9NQ83", mode = "preferred", position = "auto-up", scale = 1 })
hl.monitor({ output = "desc:Samsung Electric Company S27C31x H9DWC00168", mode = "preferred", position = "auto-up", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto-up", scale = 1 })

-- Workspace bindings
local function is_internal(name)
  return name:match("^eDP") or name:match("^LVDS") or name:match("^DSI")
end

local internal_monitor = "eDP-1"
local external_monitor = "HDMI-A-1"

if hl.get_monitors then
  for _, m in ipairs(hl.get_monitors()) do
    if not is_internal(m.name) then
      external_monitor = m.name
      break
    end
  end
end

-- Internal display has workspace 7
hl.workspace_rule({ workspace = "7", monitor = internal_monitor, default = true })

-- External display has workspaces 1-6
for ws = 1, 6 do
  local rule = { workspace = tostring(ws), monitor = external_monitor }
  if ws == 1 then
    rule.default = true
  end
  hl.workspace_rule(rule)
end
