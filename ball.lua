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
        radius = BALL_RADIUS,  -- нужен для физики
        dx = BALL_SPEED_X,
        dy = BALL_SPEED_Y
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

-- Draw puck as an ellipse on the table plane (h = 0)
function Ball:draw()
    local cx, cy = Perspective.project(self.x, self.y, 0)

    local rx = BALL_RADIUS_SCREEN
    local ry = BALL_RADIUS_SCREEN * KY

    love.graphics.setColor(COLOR_FG)
    love.graphics.ellipse("fill", cx, cy, rx, ry)
    love.graphics.setLineWidth(1.6)
    love.graphics.ellipse("line", cx, cy, rx, ry)
end





return Ball
