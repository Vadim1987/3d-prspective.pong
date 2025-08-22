-- perspective.lua
-- Map table-space (x = depth, y = across, h = height) -> screen (sx, sy)
-- Near edge is at the bottom of the screen; far edge at the top.

local Perspective = {}

-- Trapezoid describing the visible table on screen
local function trapezoid()
  -- Bottom edge (near) = closer to viewer; Top edge (far) = farther
  local BL = { x = 120, y = WINDOW_HEIGHT - 50 }
  local BR = { x = WINDOW_WIDTH - 120, y = WINDOW_HEIGHT - 50 }
  local TL = { x = 260, y = 80 }
  local TR = { x = WINDOW_WIDTH - 260, y = 80 }
  return BL, BR, TL, TR
end

-- Dimensions of logical table space
local function tableSize()
  return { d = WINDOW_WIDTH, w = WINDOW_HEIGHT }
end

-- Return public spec for other modules (table outline + size)
function Perspective.tableSpec()
  local BL, BR, TL, TR = trapezoid()
  return {
    trapezoid = { bl = BL, br = BR, tl = TL, tr = TR },
    size = tableSize()
  }
end

-- Project table-space (x,y,h) onto screen
function Perspective.project(x, y, h)
  local T = tableSize()
  local BL, BR, TL, TR = trapezoid()

  local t = (x / T.d)
  if t < 0 then t = 0 elseif t > 1 then t = 1 end

  -- Interpolate the current scanline across the trapezoid at depth t
  local leftX  = BL.x + (TL.x - BL.x) * t
  local rightX = BR.x + (TR.x - BR.x) * t
  local scanY  = BL.y + (TL.y - BL.y) * t
  local width  = rightX - leftX

  -- Across-axis mapping: y in [0..T.w] maps to [leftX..rightX]
  local sx = leftX + (y / T.w) * width

  -- Height compresses with depth similarly to width
  local heightScale = width / T.w
  local sy = scanY - (h or 0) * heightScale

  return sx, sy, width, heightScale
end

return Perspective
