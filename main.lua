-- main.lua
require "constants"
local Paddle      = require "paddle"
local Ball        = require "ball"
local AI          = require "ai"
local collision   = require "collision"
local Perspective = require "perspective"

local player, opponent, ball
local playerScore, opponentScore
local gameState = "start"
local aiStrategy = AI.clever

-- ---------- helpers: table ------------------------------------

local function drawTableOutline()
    local spec = Perspective.tableSpec()
    local P = spec.trapezoid
    love.graphics.setColor(COLOR_FG)
    love.graphics.setLineWidth(2.4)
    love.graphics.polygon("line",
        P.bl.x, P.bl.y, P.br.x, P.br.y, P.tr.x, P.tr.y, P.tl.x, P.tl.y
    )
end

-- === HORIZONTAL dotted line EXACTLY IN THE MIDDLE OF THE VISIBLE TABLE ===
-- We are looking for such a depth x_mid, where scanY (projection line) is exactly
-- between the top and bottom edges of the trapezoid. We draw dashes from left to right.
local function drawCenterLineHorizontal()
    local spec = Perspective.tableSpec()
    local P = spec.trapezoid
    local T = spec.size

    -- screen Y top/bottom edges table
    local bottomY = (P.bl.y + P.br.y) * 0.5
    local topY    = (P.tl.y + P.tr.y) * 0.5
    local scanY_target = 0.5 * (bottomY + topY)

    -- function: return scanY for depth fraction t
    local function scanY_at_t(t)
        local x = T.d * t
        local _, y = Perspective.project(x, 0, 0)
        return y
    end

    -- binary search t, so that scanY coincides with the middle
    local lo, hi = 0.0, 1.0
    for _ = 1, 24 do
        local mid = 0.5 * (lo + hi)
        if scanY_at_t(mid) > scanY_target then
            lo = mid
        else
            hi = mid
        end
    end
    local t_mid = 0.5 * (lo + hi)
    local x_mid = T.d * t_mid

    -- draw a dotted line along the WIDTH (axis across / logical
    local dash = 28
    local gap  = 16
    love.graphics.setColor(COLOR_FG)
    love.graphics.setLineWidth(2)
    for y = 0, T.w - dash, dash + gap do
        local x1, y1 = Perspective.project(x_mid, y, 0)
        local x2, y2 = Perspective.project(x_mid, y + dash, 0)
        love.graphics.line(x1, y1, x2, y2)
    end
end

-- --------------- LOVE callbacks ------------------------------

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(COLOR_BG)
    math.randomseed(os.time())

    --Game objects (logic remains 2D)
    player   = Paddle:create(PADDLE_OFFSET_X,
                             (WINDOW_HEIGHT - PADDLE_HEIGHT)/2,
                             BAT_MIN_X, BAT_MAX_X)
    opponent = Paddle:create(WINDOW_WIDTH - PADDLE_OFFSET_X - PADDLE_WIDTH,
                             (WINDOW_HEIGHT - PADDLE_HEIGHT)/2,
                             OPP_MIN_X, OPP_MAX_X)
    ball     = Ball:create()

    playerScore, opponentScore = 0, 0
end

function love.update(dt)
    if gameState ~= "play" then return end

    -- Player controls: W/S - depth (x), A/D - across (y)
    local vdir, hdir = 0, 0
    if love.keyboard.isDown('a') then vdir = -1 elseif love.keyboard.isDown('d') then vdir = 1 end
    if love.keyboard.isDown('s') then hdir = -1 elseif love.keyboard.isDown('w') then hdir = 1 end
    player:update(dt, vdir, hdir)

    -- Opponent (AI)
    local ovdir, ohdir = aiStrategy(ball, opponent)
    opponent:update(dt, ovdir, ohdir)

    -- Ball — 2D physics
    ball:update(dt)

    -- Bounce off top/bottom (Y axis)
    if ball.y - ball.radius <= 0 then
        ball.y = ball.radius
        ball.dy = -ball.dy
    elseif ball.y + ball.radius >= WINDOW_HEIGHT then
        ball.y = WINDOW_HEIGHT - ball.radius
        ball.dy = -ball.dy
    end

    -- Collisions with paddles (as in 2D, from the sides)
    if collision.sweptCollision(ball, player) then
        collision.bounceRelative(ball, player)
        -- need to prevent sticking
        local cx = math.max(player.x, math.min(ball.x, player.x + player.width))
        local cy = math.max(player.y, math.min(ball.y, player.y + player.height))
        local nx, ny = ball.x - cx, ball.y - cy
        local len = math.sqrt(nx*nx + ny*ny); if len == 0 then len = 1 end
        ball.x = cx + nx/len * (ball.radius + 1)
        ball.y = cy + ny/len * (ball.radius + 1)
    elseif collision.sweptCollision(ball, opponent) then
        collision.bounceRelative(ball, opponent)
        local cx = math.max(opponent.x, math.min(ball.x, opponent.x + opponent.width))
        local cy = math.max(opponent.y, math.min(ball.y, opponent.y + opponent.height))
        local nx, ny = ball.x - cx, ball.y - cy
        local len = math.sqrt(nx*nx + ny*ny); if len == 0 then len = 1 end
        ball.x = cx + nx/len * (ball.radius + 1)
        ball.y = cy + ny/len * (ball.radius + 1)
    end

    -- Goals
    if ball.x + ball.radius < 0 then
        opponentScore = opponentScore + 1
        ball:reset()
        if opponentScore >= WIN_SCORE then gameState = "done" end
    elseif ball.x - ball.radius > WINDOW_WIDTH then
        playerScore = playerScore + 1
        ball:reset()
        if playerScore >= WIN_SCORE then gameState = "done" end
    end
end

function love.draw()
    love.graphics.clear(COLOR_BG)
    love.graphics.setColor(COLOR_FG)

    drawTableOutline()
    drawCenterLineHorizontal()      -- << divides the field into top/bottom

    player:draw()
    opponent:draw()
    ball:draw()

    -- Score/Start
    love.graphics.print(tostring(playerScore), WINDOW_WIDTH / 2 - 60, SCORE_OFFSET_Y)
    love.graphics.print(tostring(opponentScore), WINDOW_WIDTH / 2 + 40, SCORE_OFFSET_Y)

    if gameState == "done" then
        love.graphics.printf("Game Over", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    elseif gameState == "start" then
        love.graphics.printf("Press Space to Start", 0, WINDOW_HEIGHT / 2 - 16, WINDOW_WIDTH, 'center')
    end

    love.graphics.setColor(0.6,0.6,0.6)
    love.graphics.print("Left: WASD | Right: AI | Start: Space | Quit: Esc",
                        20, WINDOW_HEIGHT - 28)
    love.graphics.setColor(COLOR_FG)
end

function love.keypressed(key)
    if key == 'space' then
        if gameState ~= "play" then
            playerScore, opponentScore = 0, 0
            ball:reset()
            gameState = "play"
        end
    elseif key == 'escape' then
        love.event.quit()
    end
end
