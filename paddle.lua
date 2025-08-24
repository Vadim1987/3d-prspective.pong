-- paddle.lua
local Perspective = require("perspective")

local Paddle = {}
Paddle.__index = Paddle

function Paddle:create(x, y, min_x, max_x)
    local paddle = setmetatable({}, self)
    paddle.x = x
    paddle.y = y
    paddle.width  = PADDLE_WIDTH   -- along depth (x)
    paddle.height = PADDLE_HEIGHT  -- across (y)
    paddle.vspeed = 0              -- across speed (W/S)
    paddle.hspeed = 0              -- depth  speed (A/D or AI)
    paddle.min_x = min_x
    paddle.max_x = max_x
    return paddle
end

function Paddle:update(dt, vdir, hdir)
    -- Across (vertical on screen)
    if vdir ~= 0 then
        self.vspeed = PADDLE_SPEED * vdir
        self.y = math.max(0, math.min(WINDOW_HEIGHT - self.height, self.y + self.vspeed * dt))
    else
        self.vspeed = 0
    end
    -- Depth (horizontal on screen)
    if hdir ~= 0 then
        self.hspeed = PADDLE_HSPEED * hdir
        self.x = math.max(self.min_x, math.min(self.max_x, self.x + self.hspeed * dt))
    else
        self.hspeed = 0
    end
end

-- Flat trapezoid on table plane (iteration 1)
function Paddle:draw()
    local xN = self.x
    local xF = self.x + self.width
    local yTop = self.y
    local yBot = self.y + self.height

    local nLx, nLy = Perspective.project(xN, yTop, 0)
    local nRx, nRy = Perspective.project(xN, yBot, 0)
    local fRx, fRy = Perspective.project(xF, yBot, 0)
    local fLx, fLy = Perspective.project(xF, yTop, 0)

    love.graphics.setColor(COLOR_FG)
    love.graphics.polygon("fill", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
end

-- Top-only (iteration 2): same silhouette at height h (no side walls)
function Paddle:drawTopOnly(h, color)
    local xN = self.x
    local xF = self.x + self.width
    local yTop = self.y
    local yBot = self.y + self.height

    local nLx, nLy = Perspective.project(xN, yTop, h)
    local nRx, nRy = Perspective.project(xN, yBot, h)
    local fRx, fRy = Perspective.project(xF, yBot, h)
    local fLx, fLy = Perspective.project(xF, yTop, h)

    love.graphics.setColor(color or COLOR_FG)
    love.graphics.polygon("fill", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy) -- no outline to avoid seams
end

-- Vertical faces (iteration 3 — the hard part)
-- faceColors = { left={r,g,b}, right={...}, front={...}, back={...} }
-- screenCx: WINDOW_WIDTH * 0.5
-- isPlayer1: true -> near bat (back face visible), false -> far bat (front face visible)
-- showSideWalls: draw left/right sides only when moving along depth
function Paddle:drawVerticalFaces(h, faceColors, screenCx, isPlayer1, showSideWalls)
    local xN = self.x
    local xF = self.x + self.width
    local yTop = self.y
    local yBot = self.y + self.height

    -- bottom (h=0)
    local nLx, nLy = Perspective.project(xN, yTop, 0)
    local nRx, nRy = Perspective.project(xN, yBot, 0)
    local fRx, fRy = Perspective.project(xF, yBot, 0)
    local fLx, fLy = Perspective.project(xF, yTop, 0)
    -- top (h>0)
    local nLxT, nLyT = Perspective.project(xN, yTop, h)
    local nRxT, nRyT = Perspective.project(xN, yBot, h)
    local fRxT, fRyT = Perspective.project(xF, yBot, h)
    local fLxT, fLyT = Perspective.project(xF, yTop, h)

    local function quad(a1,a2,a3,a4, col)
        if not col then return end
        love.graphics.setColor(col[1], col[2], col[3])
        love.graphics.polygon("fill",
            a1[1],a1[2], a2[1],a2[2], a3[1],a3[2], a4[1],a4[2]
        )
        -- no outline here to avoid double lines ("seams")
    end

    -- ===== Side walls visibility (ONLY when moving along depth) =====
    if showSideWalls then
        -- mid X of each side on screen
        local leftMidX  = 0.5 * (nLx + fLx)
        local rightMidX = 0.5 * (nRx + fRx)

        -- Fully left of center -> show RIGHT only
        if rightMidX < screenCx and leftMidX < screenCx then
            quad({nRx,nRy},{fRx,fRy},{fRxT,fRyT},{nRxT,nRyT}, faceColors and faceColors.right or COLOR_FG)
        -- Fully right of center -> show LEFT only
        elseif rightMidX > screenCx and leftMidX > screenCx then
            quad({nLx,nLy},{fLx,fLy},{fLxT,fLyT},{nLxT,nLyT}, faceColors and faceColors.left or COLOR_FG)
        end
        -- If straddling center -> no side walls.
    end

    -- ===== Near/far face rule (always visible) =====
    if isPlayer1 then
        -- Near bat: visible near face is BACK
        quad({nLx,nLy},{nRx,nRy},{nRxT,nRyT},{nLxT,nLyT}, faceColors and faceColors.back or COLOR_FG)
    else
        -- Far bat: visible near face is FRONT
        quad({fLx,fLy},{fRx,fRy},{fRxT,fRyT},{fLxT,fLyT}, faceColors and faceColors.front or COLOR_FG)
    end
end

return Paddle
