-- paddle.lua
-- Draws paddle as a trapezoid on the table plane plus its vertical faces.
-- Vertical faces are colored differently for near/front, far/back (optional), and lateral side.

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

-- Compute the 4 projected corners of the paddle silhouette for a given height h.
-- Returns an array: { nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy }
local function computeCorners(self, h)
    local xN, xF = self.x, self.x + self.width
    local yT, yB = self.y, self.y + self.height

    local nLx, nLy = Perspective.project(xN, yT, h) -- near-left
    local nRx, nRy = Perspective.project(xN, yB, h) -- near-right
    local fRx, fRy = Perspective.project(xF, yB, h) -- far-right
    local fLx, fLy = Perspective.project(xF, yT, h) -- far-left
    return { nLx,nLy, nRx,nRy, fRx,fRy, fLx,fLy }
end

-- Base: flat trapezoid on the table plane (h = 0)
function Paddle:drawBase()
    local c0 = computeCorners(self, 0)
    love.graphics.setColor(COLOR_FG)
    love.graphics.polygon("fill", c0[1],c0[2], c0[3],c0[4], c0[5],c0[6], c0[7],c0[8])
    love.graphics.setLineWidth(1) -- thinner outline to avoid 1px seams
    love.graphics.polygon("line", c0[1],c0[2], c0[3],c0[4], c0[5],c0[6], c0[7],c0[8])
end

-- Top-only: same silhouette lifted to height h (no sides)
function Paddle:drawTopOnly(h, color)
    local c1 = computeCorners(self, h)
    love.graphics.setColor(color or COLOR_FG)
    love.graphics.polygon("fill", c1[1],c1[2], c1[3],c1[4], c1[5],c1[6], c1[7],c1[8])
    love.graphics.setLineWidth(1)
    love.graphics.polygon("line", c1[1],c1[2], c1[3],c1[4], c1[5],c1[6], c1[7],c1[8])
end

-- Decide which lateral (across-axis) edge is visible relative to screen center
local function chooseLateralByCenter(c0)
    -- top edge midpoint x (nL -> fL): indices 1 and 7
    local topMidX = (c0[1] + c0[7]) * 0.5
    -- bottom edge midpoint x (nR -> fR): indices 3 and 5
    local botMidX = (c0[3] + c0[5]) * 0.5
    local centerX = WINDOW_WIDTH * 0.5
    local dTop    = math.abs(topMidX - centerX)
    local dBottom = math.abs(botMidX - centerX)
    return (dTop <= dBottom) and 'top' or 'bottom'
end

-- Collect vertical faces (quads) split into two draw queues: preTop and postTop (relative to puck top).
-- Each face entry is: { poly = {x1,y1,...,x4,y4}, color = <table> }
function Paddle:collectVerticalFaces(ball, topHeight)
    local facesPre, facesPost = {}, {}

    local function add(poly, beforeTop, color)
        local entry = { poly = poly, color = color or COLOR_FG }
        if beforeTop then table.insert(facesPre, entry) else table.insert(facesPost, entry) end
    end
    local function before(depthX) return (ball.x < depthX) end

    local xN = self.x
    local xF = self.x + self.width

    -- Precompute corresponding corners at base and top — single source of truth
    local c0 = computeCorners(self, 0)
    local c1 = computeCorners(self, topHeight)
    -- indices in c*: nL(1,2), nR(3,4), fR(5,6), fL(7,8)
    -- IMPORTANT: We ONLY pass odd indices (1,3,5,7) to avoid +1 overflow.

    local function makeQuad(i0, i1, j1, j0)
        -- Build quad along edge (c0[i0]->c0[i1]) extruded to (c1[j0]->c1[j1])
        return {
            c0[i0], c0[i0+1],
            c0[i1], c0[i1+1],
            c1[j1], c1[j1+1],
            c1[j0], c1[j0+1],
        }
    end

    -- 1) Near face (front): edge nL(1) -> nR(3); top: nR(3) -> nL(1)
    local nearPoly = makeQuad(1, 3, 3, 1)
    add(nearPoly, before(xN), COLOR_BAT_FACE_NEAR)

    -- 2) Far face (back) — usually culled; enable if you want to see it:
    -- edge fL(7) -> fR(5); top: fR(5) -> fL(7)
    -- local farPoly = makeQuad(7, 5, 5, 7)
    -- add(farPoly, before(xF), COLOR_BAT_FACE_FAR)

    -- 3) Lateral face: either top edge (nL->fL) or bottom edge (nR->fR)
    local which = chooseLateralByCenter(c0)
    local puckBeforeLat = before((xN + xF) * 0.5)
    if which == 'top' then
        -- top lateral: nL(1) -> fL(7); top: fL(7) -> nL(1)
        local topPoly = makeQuad(1, 7, 7, 1)
        add(topPoly, puckBeforeLat, COLOR_BAT_FACE_SIDE)
    else
        -- bottom lateral: nR(3) -> fR(5); top: fR(5) -> nR(3)
        local bottomPoly = makeQuad(3, 5, 5, 3)
        add(bottomPoly, puckBeforeLat, COLOR_BAT_FACE_SIDE)
    end

    return facesPre, facesPost
end

return Paddle
