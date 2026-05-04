# Fish Game

A small arcade-style fish game built with [Processing](https://processing.org/). You control an orange fish with the mouse, eat smaller fish to grow, and avoid anything bigger than you.

## Gameplay

- Move the orange fish by moving your mouse.
- Eat fish that are smaller than you.
- Avoid fish that are the same size or larger.
- Your fish grows after eating enough smaller fish.
- Win by eating every fish on screen.
- If no smaller fish are left, survive for 10 seconds to win.
- Click the start screen to begin. Click after a win or loss to restart.

## Requirements

- Processing 4 or newer
- Processing Sound library

If the sound library is missing, install it from Processing:

1. Open Processing.
2. Go to `Sketch > Import Library > Manage Libraries...`.
3. Search for `Sound`.
4. Install the library named `Sound` by The Processing Foundation.

## Running the Game

1. Clone or download this repository.
2. Open `fish_game.pde` in Processing.
3. Press the Run button.

Processing will load the other `.pde` files in the folder automatically.

## Project Structure

- `fish_game.pde` - main sketch setup, draw loop, game states, bubbles, and restart handling
- `Fish.pde` - player and non-player fish drawing, movement, growth, and direction logic
- `Rest.pde` - fish interactions, collision checks, win/loss state, and enemy movement behavior
- `Bubble.pde` - animated background bubbles
- `SoundEffects.pde` - generated bubble sound effects
- `sketch.properties` - Processing sketch metadata

## License

This project is licensed under the terms in `LICENSE`.
