# Assembly Pong

A Pong clone written in pure x86_64 assembly (NASM) for Windows 11.
No C runtime — direct WinAPI calls only (kernel32, user32).

## Tech

- **Language:** NASM x86_64 (Intel syntax)
- **Platform:** Windows 11 x64, Win32 console
- **Linker:** GCC (MinGW-w64), `-nostdlib`
- **System calls:** GetStdHandle, SetConsoleCursorPosition, WriteConsoleA,
  FillConsoleOutputCharacterA, GetAsyncKeyState, Sleep, Beep, GetTickCount, ExitProcess

## Build

Requirements: NASM, GCC (MinGW-w64)

```bash
nasm -f win64 pong.asm -o pong.obj
gcc -o pong.exe pong.obj -lkernel32 -luser32 -nostdlib -Wl,--entry=main -Wl,--subsystem=console
```

## Controls

| Action | Key |
|---|---|
| Player 1 (left) — up | W |
| Player 1 (left) — down | S |
| Player 2 (right) — up | UP |
| Player 2 (right) — down | DOWN |
| Pause / Resume | ESC |
| Return to menu from pause | Q |

## Features

- Main menu with ASCII art (PLAY, CONTROLS, EXIT, POINTS)
- Configurable score limit: 3 / 5 (default) / 10
- Pre-match 3-2-1-GO countdown with ASCII art
- Angle-based paddle reflection depending on hit position:
  - Center (pos 2): straight shot
  - Upper/lower mid (pos 1, 3): angled shot
  - Edge (pos 0, 4): angled shot + strong speed boost
- Progressive ball speed increase per paddle hit (min 10ms)
- Ball trail rendering (3-position history)
- Sound effects via Beep API (paddle hit, wall bounce, goal)
- Pause with key-release debounce
- Post-match statistics (paddle bounces, wall bounces, max speed, game time)

## File Structure

| Section | Lines | Description |
|---|---|---|
| Imports + data | 1–170 | extern declarations, variables, strings, ASCII art |
| Helpers | 140–280 | fill_screen, cur0, wprint, draw_ch, print_art |
| Game logic | 350–680 | countdown, reset, input, update_ball, check_pause |
| Render | 680–900 | borders, net, paddles, ball, trail, score |
| Menu | 900–1100 | show_menu, show_help, score_select |
| Main | 1100–1467 | game loop, win screen, statistics |

## Limitations

- Console buffer: fixed 80x25 characters
- Max speed: 10ms per frame (~100 FPS)
- No scrolling — single buffer rendering
- `SetConsoleScreenBufferSize` causes crashes — `FillConsoleOutputCharacterA` used instead
