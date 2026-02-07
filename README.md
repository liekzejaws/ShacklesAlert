# ShacklesAlert

A World of Warcraft Classic (1.12) addon that provides prominent on-screen warnings for dangerous boss and trash mob debuffs.

## Features

### Shackles of the Legion
- Detects boss emotes containing "Shackles of the Legion"
- Detects the debuff when applied to your character
- Displays a large red warning centered on screen
- Darkens the screen with a semi-transparent overlay
- Plays an alert sound
- Warning auto-dismisses after 9 seconds

### Astral Insight (Karazhan)
- Monitors for the Astral Insight debuff in Karazhan zones
- Displays a yellow "DO NOT CAST" warning with the debuff icon
- Darkens the screen while the debuff is active
- Zone-restricted to configured Karazhan subzones

### Don't Move (Karazhan)
- Monitors for the Immolation-type debuff in Karazhan zones
- Displays a red "DON'T MOVE!" warning with the debuff icon
- Darkens the screen while the debuff is active
- Plays an alert sound once per debuff application
- Zone-restricted to configured Karazhan subzones

## Installation

1. Download or clone this repository.
2. Copy the `ShacklesAlert` folder into your `World of Warcraft/Interface/AddOns/` directory.
3. Restart the game or reload the UI with `/reload`.

## Usage

The addon runs automatically with no configuration required.

### Slash Commands

| Command | Description |
|---|---|
| `/shacklesalert test` | Triggers a test warning to verify the addon is working |
| `/shacklesalert` | Shows available commands |

## Configuration

To change which zones the Astral Insight and Don't Move warnings are active in, edit the `ACTIVE_ZONES` table in `ShacklesAlert.lua`:

```lua
ShacklesAlert.ACTIVE_ZONES = {
    ["Tower of Karazhan"]  = true,
    ["Guardian's Library"] = true,
    ["Gamesman's Hall"]    = true,
}
```

Add or remove zone entries as needed. Names must match the exact subzone text shown in-game.

## Compatibility

- **Client:** World of Warcraft Classic (1.12, Interface 11200)

## License

This project is licensed under the GNU General Public License v2. See the [LICENSE](LICENSE) file for details.
