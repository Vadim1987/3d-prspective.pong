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
BALL_RADIUS      = 8   -- радиус для логики (физика, столкновения)
BALL_RADIUS_SCREEN = 8 -- радиус для отрисовки на экране
BALL_SPEED_X = 240
BALL_SPEED_Y = 120

-- Score
WIN_SCORE = 10

-- Offsets and display
PADDLE_OFFSET_X = 30
SCORE_OFFSET_Y = 40

-- Colors
COLOR_BG = {0, 0, 0}
COLOR_FG = {1, 1, 1}


