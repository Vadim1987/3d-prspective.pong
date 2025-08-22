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
    paddle.vspeed = 0
    paddle.hspeed = 0
    paddle.min_x = min_x
    paddle.max_x = max_x
    return paddle
end

function Paddle:update(dt, vdir, hdir)
    -- Vertical (across)
    if vdir ~= 0 then
        self.vspeed = PADDLE_SPEED * vdir
        self.y = math.max(0, math.min(WINDOW_HEIGHT - self.height, self.y + self.vspeed * dt))
    else
        self.vspeed = 0
    end
    -- Horizontal (depth)
    if hdir ~= 0 then
        self.hspeed = PADDLE_HSPEED * hdir
        self.x = math.max(self.min_x, math.min(self.max_x, self.x + self.hspeed * dt))
    else
        self.hspeed = 0
    end
end

-- Draw as a flat trapezoid on the table plane (h = 0)
function Paddle:draw()
    local xN = self.x
    local xF = self.x + self.width
    local halfY = self.height * 0.5
    local yTop = self.y
    local yBot = self.y + self.height

    -- 4 projected corners (near-left, near-right, far-right, far-left)
    local nLx, nLy = Perspective.project(xN, yTop, 0)
    local nRx, nRy = Perspective.project(xN, yBot, 0)
    local fRx, fRy = Perspective.project(xF, yBot, 0)
    local fLx, fLy = Perspective.project(xF, yTop, 0)

    -- Fill (FG) and outline (FG) — no shadow
    love.graphics.setColor(COLOR_FG)
    love.graphics.polygon("fill", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy)
end

return Paddle
