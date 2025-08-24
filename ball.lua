-- ball.lua
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

-- Base puck on the table plane (h = 0), black/white
function Ball:draw()
    local cx, cy = Perspective.project(self.x, self.y, 0)
    local rx = BALL_RADIUS_SCREEN
    local ry = BALL_RADIUS_SCREEN * KY

    love.graphics.setColor(COLOR_FG)
    love.graphics.ellipse("fill", cx, cy, rx, ry)
    love.graphics.setLineWidth(1.6)
    love.graphics.ellipse("line", cx, cy, rx, ry)
end

-- Top of the puck at height h (no sides), different color
function Ball:drawTop(h, color)
    local cx, cy = Perspective.project(self.x, self.y, h)
    local rx = BALL_RADIUS_SCREEN
    local ry = BALL_RADIUS_SCREEN * KY

    love.graphics.setColor(color or COLOR_FG)
    love.graphics.ellipse("fill", cx, cy, rx, ry)
    love.graphics.setLineWidth(1.6)
    love.graphics.ellipse("line", cx, cy, rx, ry)
end



-- Side rectangle connecting bottom and top ellipse centers
function Ball:drawSideRect(h, color)
    local cx0, cy0 = Perspective.project(self.x, self.y, 0)
    local cx1, cy1 = Perspective.project(self.x, self.y, h)

    local rx = BALL_RADIUS_SCREEN
    local left, right = cx0 - rx, cx0 + rx
    love.graphics.setColor(color or COLOR_PUCK_TOP)
    love.graphics.polygon("fill", left,cy0, right,cy0, right,cy1, left,cy1)
    love.graphics.setLineWidth(1.2)
    love.graphics.polygon("line", left,cy0, right,cy0, right,cy1, left,cy1)
end

return Ball
