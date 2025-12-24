
# ripple-line.nvim

A Neovim statuscolumn plugin that creates a smooth, water-ripple gradient effect in the line-number column. Optimized for Neovide's animation system.

## Features

- 7-step gradient centered on cursor line
- Smooth water-ripple animation when cursor moves between lines
- Stronger ripple effect when pressing Enter
- Auto-fades to subtle gradient when idle or typing on same line
- Contained to line-number column only (optional decorative bar)
- Zero interference with Neovide's smooth cursor animations

## Requirements

- Neovim ≥ 0.9 (for statuscolumn support)
- Neovide (recommended for best visual experience)
- LazyVim or similar Lua-based config

## Installation

### With LazyVim

``` -- lua/plugins/ripple-line.lua
return {
{
"ripple-line",
dir = vim.fn.stdpath("config") .. "/lua/ripple-line",
event = "VeryLazy",
opts = {
-- Your config here (see Configuration)
},
},
}
```

### Manual

1. Copy `ripple-line/` to `~/.config/nvim/lua/`
2. In your `init.lua`:

``` -- lua/plugins/ripple-line.lua
require("ripple-line").setup({
-- Your config here
})
```

## Configuration

All options are optional. Defaults shown:

``` -- lua/plugins/ripple-line.lua
require("ripple-line").setup({
max_steps = 6, -- gradient distance (0 = cursor, 6 = furthest)
duration_move = 200, -- ms for normal cursor move ripple
duration_enter = 300, -- ms for Enter key ripple
duration_idle_fade = 400, -- ms to fade when idle
idle_timeout = 1500, -- ms before idle fade starts
fps = 60, -- animation frame rate
max_brightness = 0.6, -- 0-1, peak ripple flash intensity
base_opacity = 0.3, -- 0-1, resting gradient visibility
colors = { -- gradient palette (inner to outer)
"#88c0ff",
"#7ab8ff",
"#6cb0ff",
"#5ea8ff",
"#50a0ff",
"#4298ff",
"#3490ff",
},
extra_column = false, -- add decorative │ bar
})
```

## Tuning for Your Setup

### For Weaker Machines

``` -- lua/plugins/ripple-line.lua
opts = {
fps = 30,
max_steps = 4,
duration_move = 150,
}
```

### For Maximum Visual Impact

``` -- lua/plugins/ripple-line.lua
opts = {
max_brightness = 0.8,
duration_enter = 400,
extra_column = true,
}
```

### Subtle/Minimal

``` -- lua/plugins/ripple-line.lua
opts = {
base_opacity = 0.15,
max_brightness = 0.4,
duration_move = 120,
}
```

### Matching Your Colorscheme

Replace the `colors` array with 7 hex codes from your theme. Example for gruvbox:

``` -- lua/plugins/ripple-line.lua
opts = {
colors = {
"#83a598", -- blue0
"#7e9f93",
"#79998e",
"#749389",
"#6f8d84",
"#6a877f",
"#65817a",
}
}
```

## How It Works

1. **Statuscolumn**: Uses Neovim's `statuscolumn` to apply different highlight groups per line based on distance from cursor
2. **Ripple trigger**: On cursor line change, starts animation that moves a bright "ring" outward through gradient steps
3. **Easing**: Uses cubic easing and Gaussian amplitude for smooth, water-like motion
4. **Idle fade**: After 1.5s of no movement, gradually fades to a very subtle base gradient
5. **Neovide sync**: Updates highlights at intervals that complement Neovide's own rendering, avoiding frame conflicts

## Performance Notes

- Only 7 highlight groups updated per frame
- Animation runs for ~200-400ms total
- No redraws forced - Neovide handles visual interpolation
- Idle state has zero CPU overhead
- Tested smooth on files with 10k+ lines

## Troubleshooting

### Gradient doesn't appear

- Check `:echo &statuscolumn` - should be `%!v:lua.RippleLine_statuscolumn()`
- Verify Neovim ≥ 0.9: `:echo has('nvim-0.9')`

### Animation feels stuttery in Neovide

- Lower `fps` to 30-40
- Reduce `duration_move` to 120-150
- Check Neovide's own animation settings (e.g., `g:neovide_cursor_animation_length`)

### Colors clash with theme

- Replace `colors` array with palette from `:Telescope highlights`
- Adjust `base_opacity` and `max_brightness`

### Want gradient in text area too

This plugin intentionally limits itself to the statuscolumn for performance. If you want full-line highlighting, consider combining with `nvim-cursorline` plugins.

## Roadmap

- [ ] Radial wave mode (expand from cursor column horizontally)
- [ ] Preset color palettes (nord, catppuccin, tokyonight)
- [ ] Custom easing function support
- [ ] Wave "reflection" (bounce back after hitting edge)
- [ ] Integration with mode changes (different colors per mode)

## License

MIT

## Credits

Inspired by:

- Neovide's smooth cursor animations
- smear-cursor.nvim's animation approach
- undo-glow.nvim's highlight tweening
