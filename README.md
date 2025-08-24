# love2d-modular-pong
# Modular Pong for Love2D

A clean, modular version of the classic single-player Pong game, written in Lua for the [Love2D](https://love2d.org/) framework.

- **Modular codebase:** Each part of the game is a separate file for maximum clarity and future extensions.
- **No magic numbers:** All constants are named and collected in one file.
- **Multiple AI strategies:** Switch between simple, random, delayed, or perfect AI for the right paddle.
- **Flexible bounce logic:** Switch between simple reflection or bounce with paddle velocity effect.
- **Ready for upgrades:** Horizontal paddle movement, round puck, custom rendering, and more.

## Controls

- **Left Paddle:**  
    - `Q` — move up  
    - `A` — move down  
    - (Or adapt code for mouse/touch if needed.)
- **Quit:** `ESC`

## Structure
main.lua # Entry point, game loop
conf.lua # Window settings for Love2D
constants.lua # All game constants
paddles.lua # Paddle logic (creation, movement, drawing)
puck.lua # Ball logic (creation, movement, drawing)
ai.lua # AI strategies for right paddle
collision.lua # Collision and bounce logic
render.lua # Drawing field, dotted line, score


## How to Run

1. [Install Love2D](https://love2d.org/).
2. Clone this repo or download as ZIP.
3. Run with:
    ```
    love .
    ```

## License

MIT — do whatever you want, just don't sue me.

---

Classic never dies.

