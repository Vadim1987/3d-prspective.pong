-- AI strategies for horizontal & vertical movement

local AI = {}

-- "Follow" strategy: anticipates both axes, tracks the ball but with a deadzone
function AI.follow(ball, paddle)
    local vdir, hdir = 0, 0
    local cy = paddle.y + paddle.height / 2
    local cx = paddle.x + paddle.width / 2
    if ball.y < cy - 6 then vdir = -1 elseif ball.y > cy + 6 then vdir = 1 end
    if ball.x < cx - 10 then hdir = -1 elseif ball.x > cx + 10 then hdir = 1 end
    return vdir, hdir
end

-- Clever: Move horizontally toward the center if ball is far, then vertical as ball approaches
function AI.clever(ball, paddle)
    local vdir, hdir = 0, 0
    local centerX = (OPP_MIN_X + OPP_MAX_X) / 2
    if math.abs(ball.x - centerX) > 40 then
        hdir = (ball.x > centerX) and 1 or -1
    else
        local cy = paddle.y + paddle.height / 2
        if ball.y < cy - 8 then vdir = -1 elseif ball.y > cy + 8 then vdir = 1 end
    end
    return vdir, hdir
end

return AI
