-- ripple-line.nvim/lua/ripple-line/init.lua
-- A statuscolumn gradient animator with water-ripple effects for Neovim + Neovide

local M = {}

-- Default configuration
local config = {
  max_steps = 6,                -- gradient distance (0 = cursor line, 6 = far)
  duration_move = 200,          -- ms for cursor line change ripple
  duration_enter = 300,         -- ms for Enter key ripple (stronger)
  duration_idle_fade = 400,     -- ms to fade when idle
  idle_timeout = 1500,          -- ms before starting idle fade
  fps = 60,                     -- animation frame rate
  max_brightness = 0.6,         -- 0-1, peak ripple intensity
  base_opacity = 0.3,           -- 0-1, resting gradient visibility
  colors = {                    -- gradient palette (inner to outer)
    "#88c0ff",
    "#7ab8ff", 
    "#6cb0ff",
    "#5ea8ff",
    "#50a0ff",
    "#4298ff",
    "#3490ff",
  },
  extra_column = false,         -- add decorative │ bar after numbers
  wiggle = {
    enabled = true,
    radius = 8,                 -- neighborhood size (wider effect)
    duration = 800,             -- ms (slower for smoother effect)
    frames = 40,                -- more frames for ultra-smooth motion
    base_amplitude = 6,         -- increased base max offset
    max_amplitude = 12,         -- increased max amplitude for big jumps
    jump_scale = 0.3,           -- how much jump distance scales amplitude
    cycles = 0.5,               -- fewer cycles = much slower, smoother oscillation
    phase_per_step = math.pi / 8,  -- smaller phase lag for wider wave
    sigma = 3.0,                -- wider gaussian falloff
  },
}

-- Runtime state
local state = {
  last_line = 0,
  wave_id = 0,
  animating = false,
  idle_timer = nil,
  current_colors = {},
  wiggle_center = 0,
  wiggle_tick = 0,
  wiggle_active = false,
  wiggle_amplitude = 6,         -- dynamic amplitude based on jump distance
}

-- ============================================================================
-- Color utilities
-- ============================================================================

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1,2), 16),
         tonumber(hex:sub(3,4), 16),
         tonumber(hex:sub(5,6), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", 
    math.min(255, math.max(0, math.floor(r))),
    math.min(255, math.max(0, math.floor(g))),
    math.min(255, math.max(0, math.floor(b))))
end

local function lerp(a, b, t)
  return a + (b - a) * t
end

local function ease_out_cubic(x)
  return 1 - math.pow(1 - x, 3)
end

local function ease_in_out_quad(x)
  return x < 0.5 
    and 2 * x * x 
    or 1 - math.pow(-2 * x + 2, 2) / 2
end

-- Smoother easing for wiggle
local function ease_in_out_sine(x)
  return -(math.cos(math.pi * x) - 1) / 2
end

-- ============================================================================
-- Color animation
-- ============================================================================

-- Compute color for a step at animation progress t
local function compute_color(step, t, wave_center, intensity)
  local base_hex = config.colors[step + 1] or config.colors[#config.colors]
  local br, bg, bb = hex_to_rgb(base_hex)
  
  -- Distance from wave center (ripple front moves outward)
  local front = wave_center + t * config.max_steps
  local dist = math.abs(step - front)
  
  -- Gaussian-like ripple shape
  local sigma = 1.5
  local amplitude = math.exp(-dist * dist / (2 * sigma * sigma))
  
  -- Apply easing and intensity
  amplitude = amplitude * intensity * ease_out_cubic(t)
  
  -- Brighten toward white
  local tr = lerp(br, 255, amplitude)
  local tg = lerp(bg, 255, amplitude)
  local tb = lerp(bb, 255, amplitude)
  
  -- Apply base opacity when not animating
  local opacity = lerp(config.base_opacity, 1, amplitude)
  tr = lerp(br, tr, opacity)
  tg = lerp(bg, tg, opacity)
  tb = lerp(bb, tb, opacity)
  
  return rgb_to_hex(tr, tg, tb)
end

-- Apply highlight groups
local function apply_highlights(colors)
  for i = 0, config.max_steps do
    local group = "RippleLine" .. i
    vim.api.nvim_set_hl(0, group, { fg = colors[i] })
  end
  state.current_colors = colors
end

-- Initialize resting gradient
local function set_base_gradient()
  local colors = {}
  for i = 0, config.max_steps do
    local base_hex = config.colors[i + 1] or config.colors[#config.colors]
    local r, g, b = hex_to_rgb(base_hex)
    -- Apply base opacity
    r = lerp(r, 128, 1 - config.base_opacity)
    g = lerp(g, 128, 1 - config.base_opacity)
    b = lerp(b, 128, 1 - config.base_opacity)
    colors[i] = rgb_to_hex(r, g, b)
  end
  apply_highlights(colors)
end

-- Animation loop
local function animate(duration, intensity, wave_id)
  local start = vim.loop.now()
  local frame_time = 1000 / config.fps
  
  state.animating = true
  
  local function frame()
    if state.wave_id ~= wave_id then return end -- cancelled by newer wave
    
    local elapsed = vim.loop.now() - start
    local t = math.min(1, elapsed / duration)
    
    local colors = {}
    for i = 0, config.max_steps do
      colors[i] = compute_color(i, t, 0, intensity)
    end
    apply_highlights(colors)
    
    if t < 1 then
      vim.defer_fn(frame, frame_time)
    else
      state.animating = false
      -- Start idle fade timer after animation completes
      start_idle_timer()
    end
  end
  
  frame()
end

-- Start idle fade timer
function start_idle_timer()
  if state.idle_timer then
    vim.loop.timer_stop(state.idle_timer)
  end
  
  state.idle_timer = vim.defer_fn(function()
    if not state.animating then
      fade_to_base()
    end
  end, config.idle_timeout)
end

-- Fade to base gradient when idle
function fade_to_base()
  local start = vim.loop.now()
  local duration = config.duration_idle_fade
  local frame_time = 1000 / config.fps
  
  local start_colors = vim.deepcopy(state.current_colors)
  local target_colors = {}
  for i = 0, config.max_steps do
    local base_hex = config.colors[i + 1] or config.colors[#config.colors]
    local r, g, b = hex_to_rgb(base_hex)
    r = lerp(r, 128, 1 - config.base_opacity * 0.5) -- fade to subtle
    g = lerp(g, 128, 1 - config.base_opacity * 0.5)
    b = lerp(b, 128, 1 - config.base_opacity * 0.5)
    target_colors[i] = rgb_to_hex(r, g, b)
  end
  
  local function frame()
    local elapsed = vim.loop.now() - start
    local t = math.min(1, elapsed / duration)
    t = ease_in_out_quad(t)
    
    local colors = {}
    for i = 0, config.max_steps do
      local sr, sg, sb = hex_to_rgb(start_colors[i])
      local tr, tg, tb = hex_to_rgb(target_colors[i])
      colors[i] = rgb_to_hex(
        lerp(sr, tr, t),
        lerp(sg, tg, t),
        lerp(sb, tb, t)
      )
    end
    apply_highlights(colors)
    
    if t < 1 then
      vim.defer_fn(frame, frame_time)
    end
  end
  
  frame()
end

-- ============================================================================
-- Wiggle animation (FIXED: smoother, wider range, proper reset)
-- ============================================================================

local function wiggle_offset_for_dist(dist)
  if not (config.wiggle and config.wiggle.enabled) then return 0 end
  if not state.wiggle_active then return 0 end
  if dist > (config.wiggle.radius or 8) then return 0 end

  -- Use dynamic amplitude based on jump distance
  local amp = state.wiggle_amplitude

  -- Distance falloff (strongest at center)
  local falloff = math.exp(-dist * dist / (2 * (config.wiggle.sigma or 3.0)^2))

  -- Progress through animation (0 to 1)
  local t = state.wiggle_tick / (config.wiggle.frames or 40)
  
  -- FIXED: Use sine easing for smooth motion
  local eased_t = ease_in_out_sine(t)
  
  local omega = (config.wiggle.cycles or 0.5) * 2 * math.pi
  local phase = dist * (config.wiggle.phase_per_step or (math.pi / 8))

  -- Wave equation
  local wave = math.sin(omega * eased_t - phase)
  
  -- FIXED: Proper envelope that goes to exactly 0 at both ends
  local envelope = math.sin(t * math.pi)
  
  -- Combined offset
  local s = wave * envelope * falloff * amp

  -- FIXED: Return raw float for smoother interpolation
  return s
end

local function clamp(x, lo, hi)
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

local function format_wiggle_number(lnum, width, offset)
  local s = tostring(lnum)
  local len = #s
  
  -- FIXED: Simpler formatting - just center the number with offset applied
  local avail = math.max(0, width - len)
  local center = math.floor(avail / 2)
  
  -- Apply offset (round to nearest integer)
  local adjusted = center + math.floor(offset + 0.5)
  adjusted = clamp(adjusted, 0, avail)
  
  local left = adjusted
  local right = avail - left
  
  return string.rep(" ", left) .. s .. string.rep(" ", right)
end

local function check_wiggle_complete()
  -- Check if all visible lines have returned to near-zero offset
  local max_offset = 0
  local radius = config.wiggle.radius or 8
  
  for dist = 0, radius do
    local offset = math.abs(wiggle_offset_for_dist(dist))
    if offset > max_offset then
      max_offset = offset
    end
  end
  
  -- Consider complete if max offset is less than 0.1 pixels
  return max_offset < 0.1
end

local function start_wiggle(jump_distance)
  if not (config.wiggle and config.wiggle.enabled) then return end

  local my_id = state.wave_id
  local frames = math.max(10, config.wiggle.frames or 40)
  local total = config.wiggle.duration or 800
  local dt = math.floor(total / frames)

  -- Scale amplitude based on jump distance
  local base_amp = config.wiggle.base_amplitude or 6
  local max_amp = config.wiggle.max_amplitude or 12
  local scale = config.wiggle.jump_scale or 0.3
  
  state.wiggle_amplitude = math.min(max_amp, base_amp + jump_distance * scale)
  
  state.wiggle_center = vim.fn.line(".")
  state.wiggle_tick = 0
  state.wiggle_active = true

  local function tick()
    if state.wave_id ~= my_id then return end
    state.wiggle_tick = state.wiggle_tick + 1

    -- Forces statuscolumn re-evaluation during animation
    vim.cmd("redraw")

    -- FIXED: Continue until animation is complete AND all offsets are near zero
    local past_min_frames = state.wiggle_tick >= frames
    local all_settled = check_wiggle_complete()
    
    if not (past_min_frames and all_settled) then
      -- Continue animating
      vim.defer_fn(tick, dt)
    else
      -- Animation complete - clean reset
      state.wiggle_active = false
      state.wiggle_amplitude = base_amp
      state.wiggle_tick = 0
      vim.cmd("redraw")
    end
  end

  tick()
end

-- ============================================================================
-- Statuscolumn function (FIXED: no duplicate numbers)
-- ============================================================================

function _G.RippleLine_statuscolumn()
  local cur = vim.fn.line(".")
  local lnum = vim.v.lnum
  local relnum = vim.v.relnum
  
  -- Calculate distance for gradient
  local dist = math.abs(lnum - cur)
  local step = math.min(dist, config.max_steps)
  local group = "RippleLine" .. step

  -- Apply wiggle offset based on distance from wiggle center
  local wiggle_dist = math.abs(lnum - state.wiggle_center)
  local offset = wiggle_offset_for_dist(wiggle_dist)
  
  -- FIXED: Proper width calculation with padding for wiggle
  local base_width = vim.o.numberwidth
  local wiggle_padding = 10  -- Extra space for wiggle range
  local width = base_width + wiggle_padding
  
  -- Show absolute number on cursor line, relative on others
  local display_num = (dist == 0) and lnum or relnum
  
  local numtxt = format_wiggle_number(display_num, width, offset)
  
  local tail = config.extra_column and "│ " or " "
  return string.format("%%#%s#%s%s", group, numtxt, tail)
end

-- ============================================================================
-- Event handling & triggers
-- ============================================================================

-- Trigger ripple
local function trigger_ripple(mode, jump_distance)
  state.wave_id = state.wave_id + 1
  
  -- Cancel idle timer
  if state.idle_timer then
    vim.loop.timer_stop(state.idle_timer)
    state.idle_timer = nil
  end
  
  local duration = mode == "enter" and config.duration_enter or config.duration_move
  local intensity = mode == "enter" and config.max_brightness * 1.2 or config.max_brightness
  
  animate(duration, intensity, state.wave_id)
  start_wiggle(jump_distance)
end

-- Event handlers
local function on_cursor_moved()
  local current_line = vim.fn.line(".")
  
  if current_line ~= state.last_line then
    -- Calculate jump distance
    local jump_distance = math.abs(current_line - state.last_line)
    
    -- Detect if Enter was pressed
    local mode = vim.fn.mode()
    local is_insert = mode == "i" or mode == "R"
    
    trigger_ripple(is_insert and "enter" or "move", jump_distance)
    state.last_line = current_line
  end
end

local function on_text_changed()
  local current_line = vim.fn.line(".")
  if current_line == state.last_line and not state.animating then
    -- Typing on same line - just reset idle timer
    start_idle_timer()
  end
end

-- ============================================================================
-- Setup function
-- ============================================================================

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  
  -- Enable relative line numbers with absolute on cursor line
  vim.opt.number = true
  vim.opt.relativenumber = true
  
  -- FIXED: Increase numberwidth to accommodate wiggle animation
  vim.opt.numberwidth = 6
  
  -- Initialize
  set_base_gradient()
  state.last_line = vim.fn.line(".")
  
  -- Set statuscolumn
  vim.o.statuscolumn = "%!v:lua.RippleLine_statuscolumn()"
  
  -- Create autocommands
  local group = vim.api.nvim_create_augroup("RippleLine", { clear = true })
  
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    callback = on_cursor_moved,
  })
  
  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    group = group,
    callback = on_text_changed,
  })
  
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = set_base_gradient,
  })
  
  -- Start idle timer
  start_idle_timer()
end

return M