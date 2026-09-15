-- ============================================================
-- Rivals Modular -- ESP (DISABLED)
-- Removed for stability - will rebuild later
-- ============================================================

local ESP = {}

function ESP.Update(_dt) end
function ESP.Refresh() end
function ESP.Init(deps)
    print("[rivals] ESP module disabled.")
end
function ESP.Cleanup() end

return ESP