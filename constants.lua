-- constants.lua
-- Game window
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

-- Paddle (bat) parameters
PADDLE_WIDTH  = 10
PADDLE_HEIGHT = 60
PADDLE_SPEED  = 300   -- Vertical (across)
PADDLE_HSPEED = 200   -- Horizontal (depth)

-- Horizontal limits for paddles in table-space (depth axis x)
BAT_MIN_X = 0
BAT_MAX_X = (WINDOW_WIDTH / 2) - PADDLE_WIDTH - 10
OPP_MIN_X = (WINDOW_WIDTH / 2) + 10
OPP_MAX_X = WINDOW_WIDTH - PADDLE_WIDTH

-- Ball
BALL_RADIUS        = 8   -- physics radius
BALL_RADIUS_SCREEN = 8   -- visual radius (ellipse)
BALL_SPEED_X = 240
BALL_SPEED_Y = 120

-- Heights (in abstract table-height units used by Perspective.project)
PUCK_HEIGHT    = 12
BAT_TOP_HEIGHT = PUCK_HEIGHT * 3

-- Score
WIN_SCORE = 10

-- Offsets and HUD
PADDLE_OFFSET_X = 30
SCORE_OFFSET_Y  = 40

-- Colors
COLOR_BG = {0, 0, 0}
COLOR_FG = {1, 1, 1}          -- base (iteration 1) + default lines

-- Tops (iteration 2)
COLOR_PUCK_TOP = {0.15, 0.8, 1.0}
COLOR_BAT_TOP  = {1.0, 0.45, 0.7}

-- Vertical faces (iteration 3) — distinct colors
-- "Near" = the face closer to the viewer (x = xN)
-- "Far"  = the face farther from the viewer (x = xF) — usually culled in our setup
-- "Side" = the lateral face (either y = top or y = bottom edge, whichever is visible)
COLOR_BAT_FACE_NEAR = {0.95, 0.9, 0.25}   -- front (near) face
COLOR_BAT_FACE_FAR  = {0.2, 0.8, 0.8}     -- back (far) face (optional to draw)
COLOR_BAT_FACE_SIDE = {0.95, 0.35, 0.35}  -- side face
