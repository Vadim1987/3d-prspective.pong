-- Game window
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

-- Paddle (bat) parameters
PADDLE_WIDTH = 10
PADDLE_HEIGHT = 60
PADDLE_SPEED = 300     -- Vertical movement
PADDLE_HSPEED = 200    -- Horizontal movement

-- Horizontal limits (not beyond half of the table)
BAT_MIN_X = 0
BAT_MAX_X = (WINDOW_WIDTH / 2) - PADDLE_WIDTH - 10
OPP_MIN_X = (WINDOW_WIDTH / 2) + 10
OPP_MAX_X = WINDOW_WIDTH - PADDLE_WIDTH

-- Ball
BALL_RADIUS         = 8   -- logic radius (physics, collisions)
BALL_RADIUS_SCREEN  = 8   -- screen radius for drawing
BALL_SPEED_X = 240
BALL_SPEED_Y = 120

-- Heights (abstract "table height" units projected by Perspective.project)
PUCK_HEIGHT = 12
BAT_TOP_HEIGHT = PUCK_HEIGHT * 3

-- Score
WIN_SCORE = 10

-- Offsets and display
PADDLE_OFFSET_X = 30
SCORE_OFFSET_Y = 40

-- Colors (base B/W + overlay colors for tops)
COLOR_BG = {0, 0, 0}
COLOR_FG = {1, 1, 1}        -- base shapes on h=0 (white on black)

COLOR_PUCK_TOP = {0.15, 0.8, 1.0}  -- top plane of puck (above the table)
COLOR_BAT_TOP  = {1.0, 0.45, 0.7}  -- top planes of bats (higher than puck)
