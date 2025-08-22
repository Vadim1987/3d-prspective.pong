-- ball.lua
-- Puck drawn as bottom ellipse (on table), vertical body rectangle, and top ellipse at height.

local Perspective = require("perspective")

local Ball = {}
Ball.__index = Ball

-- Ellipse vertical squash factor (looks nicer than perfect circle)
local KY = 0.55

function Ball:create()
    local this = {
        x = WINDOW_WIDTH / 2,
        y = WINDOW_HEIGHT / 2,
        radius = BALL_RADIUS,  -- physics
        dx = BALL_SPEED_X,
        dy = BALL_SPEED_Y,
        prev_x = WINDOW_WIDTH / 2,
        prev_y = WINDOW_HEIGHT / 2
    }
    setmetatable(this, Ball)
    return this
end

function Ball:reset()
    self.x = WINDOW_WIDTH / 2
    self.y = WINDOW_HEIGHT / 2
    self.dx = BALL_SPEED_X * (math.random(2) == 1 and 1 or -1)
    self.dy = BALL_SPEED_Y * (math.random(2) == 1 and 1 or -1)
    self.prev_x = self.x
    self.prev_y = self.y
end

function Ball:update(dt)
    self.prev_x = self.x
    self.prev_y = self.y
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

-- Bottom ellipse on the table plane (iteration 1)
function Ball:drawBottom()
    local cx, cy = Perspective.project(self.x, self.y, 0)
    local rx = BALL_RADIUS_SCREEN
    local ry = BALL_RADIUS_SCREEN * KY

    love.graphics.setColor(COLOR_FG)
    love.graphics.ellipse("fill", cx, cy, rx, ry)
    love.graphics.setLineWidth(1) -- thinner outline to avoid seams with body/top
    love.graphics.ellipse("line", cx, cy, rx, ry)
end

-- Vertical "body" rectangle from the center of bottom to the center of top (iteration 3)
function Ball:drawBodyRect(topHeight)
    local cx0, cy0 = Perspective.project(self.x, self.y, 0)
    local cx1, cy1 = Perspective.project(self.x, self.y, topHeight)
    local rx = BALL_RADIUS_SCREEN
    -- Draw rectangle spanning the puck width, between cy1 and cy0, same color as bottom (white)
    love.graphics.setColor(COLOR_FG)
    love.graphics.rectangle("fill", cx0 - rx, cy1, rx * 2, cy0 - cy1)
end

-- Top ellipse at height h (iteration 2)
function Ball:drawTop(h, color)
    local cx, cy = Perspective.project(self.x, self.y, h)
    local rx = BALL_RADIUS_SCREEN
    local ry = BALL_RADIUS_SCREEN * KY

    love.graphics.setColor(color or COLOR_FG)
    love.graphics.ellipse("fill", cx, cy, rx, ry)
    love.graphics.setLineWidth(1)
    love.graphics.ellipse("line", cx, cy, rx, ry)
end

return Ball
