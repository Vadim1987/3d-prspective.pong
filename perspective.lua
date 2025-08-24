-- perspective.lua
-- Map table-space (x = depth, y = across, h = height) -> screen (sx, sy)
-- We keep h = 0 (everything on the table plane).

local Perspective = {}

-- We’ll treat the existing WINDOW_* space as your table-space in logic.
-- The trapezoid controls how that space is drawn on screen.
local function trapezoid()
  -- Bottom edge (near) = closer to viewer; Top edge (far) = farther
  local BL = { x = 120, y = WINDOW_HEIGHT - 50 }
  local BR = { x = WINDOW_WIDTH - 120, y = WINDOW_HEIGHT - 50 }
  local TL = { x = 260, y = 80 }
  local TR = { x = WINDOW_WIDTH - 260, y = 80 }
  return BL, BR, TL, TR
end

-- Logical table size (in your game’s coords). We map:
-- x (depth) ∈ [0 .. WINDOW_WIDTH], y (across) ∈ [0 .. WINDOW_HEIGHT]
local function tableSize()
  return { d = WINDOW_WIDTH, w = WINDOW_HEIGHT }
end

function Perspective.tableSpec()
  local BL, BR, TL, TR = trapezoid()
  return {
    trapezoid = { bl = BL, br = BR, tl = TL, tr = TR },
    size = tableSize()
  }
end

-- Project (x:depth, y:across, h) to screen
function Perspective.project(x, y, h)
  local T = tableSize()
  -- clamp to table range
  if x < 0 then x = 0 elseif x > T.d then x = T.d end
  if y < 0 then y = 0 elseif y > T.w then y = T.w end

  local BL, BR, TL, TR = trapezoid()
  local t = x / T.d

  -- scanline at given depth
  local leftX  = BL.x + (TL.x - BL.x) * t
  local rightX = BR.x + (TR.x - BR.x) * t
  local scanY  = BL.y + (TL.y - BL.y) * t
  local width  = rightX - leftX

  local sx = leftX + (y / T.w) * width

  -- height scale (not used: h=0, but keep for completeness)
  local heightScale = width / T.w
  local sy = scanY - (h or 0) * heightScale

  return sx, sy, width, heightScale
end

return Perspective
