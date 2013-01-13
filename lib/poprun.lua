------------------------------------------
-- Author: Andrei 'Garoth' Thorp        --
-- Copyright 2009 Andrei 'Garoth' Thorp --
------------------------------------------

local mouse  = mouse
local awful  = require('awful')
local screen = screen
local ipairs = ipairs
local pairs  = pairs
local io     = io

local mfloor = math.floor

local beautiful = require('beautiful')

local wibox = require('wibox')
local tbox  = require('wibox.widget.textbox')

local _ENV = {}

defaults = {}

-- Default is 1 for people without compositing
defaults.opacity = 1.0
defaults.prompt_string = ' RUN: '
defaults.prompt_font = nil

-- Whether or not the bar should slide up or just pop up
defaults.slide = false

-- Bar will be percentage of screen width
defaults.width = 0.6

-- Bar will be this high in pixels
defaults.height = 22
defaults.border_width = 1

-- When sliding, it'll move this often (in seconds)
defaults.move_speed = 0.02

-- When sliding, it'll move this many pixels per move
defaults.move_amount = 3

-- Default run function
defaults.run_function = awful.util.spawn

-- Default completion function
defaults.completion_function = awful.completion.shell

-- Default cache
defaults.cache = '/history'

-- Default position
defaults.position = 'top'

-- Clone the defaults for the used settings
settings = {}

for key, value in pairs(defaults) do
    settings[key] = value
end

runwibox    = {}
mypromptbox = {}

inited = false

local set_default =
	function (s)
		local geom = screen[s].geometry

		runwibox[s]:geometry
		(
			{
				width  = geom.width * settings.width,
				height = settings.height,
				x      = geom.x + mfloor((geom.width - (settings.width * geom.width)) / 2),
				y      = geom.y + mfloor((geom.height - settings.height) / 2)
			}
		)
	end

-- We want to 'lazy init' so that in case beautiful inits late or something,
-- this is still likely to work.
local ensure_init =
	function ()
		if inited then return end

		inited = true

		for s = 1, screen.count() do
			mypromptbox[s] = tbox()

			mypromptbox[s]:set_align('left')

			defaults.border_width = beautiful.border_width

			runwibox[s] =
				wibox
				(
					{
						screen       = s,
						fg           = beautiful.fg_focus,
						bg           = beautiful.bg_normal,
						border_width = settings.border_width,
						border_color = beautiful.bg_focus,
						ontop        = true,
						opacity      = settings.opacity
					}
				)

			set_default(s)

			local left_layout = wibox.layout.fixed.horizontal()

			left_layout:add(mypromptbox[s])

			local layout = wibox.layout.align.horizontal()

			layout:set_left(left_layout)

			runwibox[s]:set_widget(layout)
		end
	end

local do_slide_up =
	function ()
		local s = mouse.screen

		startgeom = runwibox[s]:geometry()

		runwibox[s]:geometry({ y = startgeom.y - settings.move_amount })

		if runwibox[s]:geometry().y <= screen[s].geometry.y + screen[s].geometry.height - startgeom.height then
			set_default(s)

			runwibox[s].timer_up:stop()
		end
	end

local do_slide_down =
	function ()
		local s = runwibox.screen

		startgeom = runwibox[s]:geometry()

		runwibox[s]:geometry({ y = startgeom.y + settings.move_amount })

		if runwibox[s]:geometry().y >= screen[s].geometry.y + screen[s].geometry.height then
			runwibox[s].visible = false

			runwibox[s].timer_down:stop()
		end
	end

local show_wibox =
	function (s)
		runwibox.screen = s

		if settings.slide == true then
			startgeom = runwibox[s]:geometry()
			-- changing visible property would reset wibox geometry to its defaults
			-- Might be 0 if position is set to 'top'
			-- Thus the wibox has to be shown before setting its original slide up
			-- position. As a side effect, the top bar might blink if position is set
			-- to 'top'.
			runwibox[s].visible = true
			runwibox[s]:geometry({ y = screen[s].geometry.y + screen[s].geometry.height })

			if runwibox[s].timer_up then
				runwibox[s].timer_up:start()
			else
				local t = timer(settings.move_speed)

				runwibox[s].timer_up = t

				t:connect_signal('timeout', do_slide_up)
			end
		else
			set_default(s)

			runwibox[s].visible = true
		end
	end

local hide_wibox =
	function ()
		local s = runwibox.screen or mouse.screen

		if settings.slide == true then
			runwibox[s].visible = true

			set_default(s)

			if runwibox[s].timer_down then
				runwibox[s].timer_down:start()
			else
				local t = timer(settings.move_speed)

				runwibox[s].timer_down = t

				t:connect_signal('timeout', do_slide_down)
			end
		else
			set_default(s)

			runwibox[s].visible = false
		end
	end

local update_settings =
	function ()
		for s, value in ipairs(runwibox) do
			value.border_width = settings.border_width

			set_default(s)

			runwibox[s].opacity = settings.opacity
		end
	end

run_prompt =
	function ()
		ensure_init()

		show_wibox(mouse.screen)

		awful.prompt.run
		(
			{
				prompt = settings.prompt_string,
				font   = settings.prompt_font
			},
			mypromptbox[mouse.screen],
			settings.run_function,
			settings.completion_function,
			awful.util.getdir('cache') .. settings.cache,
			100,
			hide_wibox
		)
	end

-- SETTINGS
set_opacity =
	function (amount)
		settings.opacity = amount or defaults.opacity

		update_settings()
	end

set_prompt_string =
	function (string)
		settings.prompt_string = string or defaults.prompt_string
	end

set_prompt_font =
	function (font_string)
		settings.prompt_font = font_string or defaults.prompt_font
	end

set_slide =
	function (tf)
		settings.slide = tf or defaults.slide
	end

set_width =
	function (amount)
		settings.width = amount or defaults.width

		update_settings()
	end

set_height =
	function (amount)
		settings.height = amount or defaults.height

		update_settings()
	end

set_border_width =
	function (amount)
		settings.border_width = amount or defaults.border_width

		update_settings()
	end

set_move_speed =
	function (amount)
		settings.move_speed = amount or defaults.move_speed
	end

set_move_amount =
	function (amount)
		settings.move_amount = amount or defaults.move_amount
	end

set_run_function =
	function (fn)
		settings.run_function = fn or defaults.run_function
	end

set_completion_function =
	function (fn)
		settings.completion_function = fn or defaults.completion_function
	end

set_position =
	function (p)
		settings.position = p
	end

set_cache =
	function (c)
		settings.cache = c or defaults.cache
	end

return _ENV
