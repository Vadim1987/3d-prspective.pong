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

-- Horizontal dashed center line along table mid-depth
local function drawCenterLineHorizontal()
    local spec = Perspective.tableSpec()
    local P = spec.trapezoid
    local T = spec.size

    local bottomY = (P.bl.y + P.br.y) * 0.5
    local topY    = (P.tl.y + P.tr.y) * 0.5
    local scanY_target = 0.5 * (bottomY + topY)

    local function scanY_at_t(t)
        local x = T.d * t
        local _, y = Perspective.project(x, 0, 0)
        return y
    end

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

    -- Left paddle: WASD (A/D = depth, W/S = across)
    local vdir, hdir = 0, 0
    if love.keyboard.isDown('a') then vdir = -1 elseif love.keyboard.isDown('d') then vdir = 1 end
    if love.keyboard.isDown('s') then hdir = -1 elseif love.keyboard.isDown('w') then hdir = 1 end
    player:update(dt, vdir, hdir)

    -- Right paddle AI
    local ovdir, ohdir = aiStrategy(ball, opponent)
    opponent:update(dt, ovdir, ohdir)

    -- Ball physics
    ball:update(dt)

    -- Bounce on top/bottom bounds (across axis)
    if ball.y - ball.radius <= 0 then
        ball.y = ball.radius
        ball.dy = -ball.dy
    elseif ball.y + ball.radius >= WINDOW_HEIGHT then
        ball.y = WINDOW_HEIGHT - ball.radius
        ball.dy = -ball.dy
    end

    -- Collisions with paddles
    if collision.sweptCollision(ball, player) then
        collision.bounceRelative(ball, player)
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

    -- (1) Table & center line (iteration 1, B/W)
    drawTableOutline()
    drawCenterLineHorizontal()

    -- (2) Base silhouettes on table (iteration 1)
    player:draw()
    opponent:draw()
    ball:draw()

    -- (2.5) Vertical faces + puck stack with correct interleaving (iteration 3)
    local faceColors = {
        left  = {0.95, 0.85, 0.35},
        right = {0.35, 0.85, 0.95},
        front = {0.85, 0.45, 0.95},
        back  = {0.45, 0.95, 0.65},
    }

    -- screen center X for side-wall rule
    local SCREEN_CX = WINDOW_WIDTH * 0.5

    -- depth proxy: screen Y of object center at h=0 (larger Y => closer to viewer)
    local function depthY_of(x, y) local _, yy = Perspective.project(x, y, 0); return yy end

    local ballCY = depthY_of(ball.x, ball.y)

    local playerCX = player.x + player.width  * 0.5
    local playerCY = player.y + player.height * 0.5
    local playerDY = depthY_of(playerCX, playerCY)

    local oppCX = opponent.x + opponent.width  * 0.5
    local oppCY = opponent.y + opponent.height * 0.5
    local oppDY = depthY_of(oppCX, oppCY)

    -- "Behind" means farther from viewer -> smaller depthY
    local playerBehindBall   = (playerDY < ballCY)
    local opponentBehindBall = (oppDY   < ballCY)

    -- draw side walls only if paddle currently moves along depth (A/D or AI)
    local showSidesPlayer = math.abs(player.hspeed or 0)   > 0.1
    local showSidesOpp    = math.abs(opponent.hspeed or 0) > 0.1

    local function puck_stack()
        -- According to spec: bottom already drawn in ball:draw();
        -- now draw side-rectangle, then top.
        ball:drawSideRect(PUCK_HEIGHT, COLOR_PUCK_TOP)
        ball:drawTop(PUCK_HEIGHT, COLOR_PUCK_TOP)
    end

    -- First: faces of bats that are BEHIND the puck
    if playerBehindBall then
        player:drawVerticalFaces(BAT_TOP_HEIGHT, faceColors, SCREEN_CX, true,  showSidesPlayer)
    end
    if opponentBehindBall then
        opponent:drawVerticalFaces(BAT_TOP_HEIGHT, faceColors, SCREEN_CX, false, showSidesOpp)
    end

    -- Then: the puck (once)
    puck_stack()

    -- Finally: faces of bats that are IN FRONT of the puck
    if not playerBehindBall then
        player:drawVerticalFaces(BAT_TOP_HEIGHT, faceColors, SCREEN_CX, true,  showSidesPlayer)
    end
    if not opponentBehindBall then
        opponent:drawVerticalFaces(BAT_TOP_HEIGHT, faceColors, SCREEN_CX, false, showSidesOpp)
    end

    -- (3) Raised tops of bats (iteration 2 — only tops above the puck)
    player:drawTopOnly(BAT_TOP_HEIGHT, COLOR_BAT_TOP)
    opponent:drawTopOnly(BAT_TOP_HEIGHT, COLOR_BAT_TOP)

    -- HUD
    love.graphics.setColor(COLOR_FG)
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
