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
local timer  = timer
local modf   = math.modf

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
defaults.move_time = 0.2

-- When sliding, it'll move this many pixels per move
defaults.move_amount = 5

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

local w = nil
local p = nil

local inited = false

local set_center  =
	function (s)
		local geom = screen[s].geometry

		w:geometry
		{
			width  = geom.width * settings.width,
			height = settings.height,
			x      = geom.x + geom.width * ((1 - settings.width) / 2),
			y      = geom.y + mfloor((geom.height - settings.height) / 2)
		}
	end

local set_default =
	function (s)
		local geom = screen[s].geometry

		w:geometry
		{
			width  = geom.width * settings.width,
			height = settings.height,
			x      = geom.x + geom.width * ((1 - settings.width) / 2),
			y      = geom.y + geom.height - settings.height
		}
	end

-- We want to 'lazy init' so that in case beautiful inits late or something,
-- this is still likely to work.
local ensure_init =
	function ()
		if inited then return end

		inited = true

		p = tbox()

		p:set_align('left')

		local left_layout = wibox.layout.fixed.horizontal()

		left_layout:add(p)

		local w_layout = wibox.layout.align.horizontal()

		w_layout:set_left(left_layout)

		defaults.border_width = beautiful.border_width

		w = 
			wibox
			(
				{
					fg           = beautiful.fg_focus,
					bg           = beautiful.bg_normal,
					border_width = settings.border_width,
					border_color = beautiful.bg_focus,
					ontop        = true,
					opacity      = settings.opacity
				}
			)

		w:set_widget(w_layout)

		w.visible = false
	end

local ticker = nil -- one timer for both up and down sliders, because we're trying to be good to mem. :(

local do_slide_up = nil

do_slide_up =
	function ()
		local s = mouse.screen

		w:geometry({ y = w:geometry().y - settings.move_amount })

		if w:geometry().y <= screen[s].geometry.y + mfloor(screen[s].geometry.height / 2) then
			ticker:disconnect_signal('timeout', do_slide_up)
			ticker:stop()
		end
	end

local do_slide_down = nil

do_slide_down =
	function ()
		local s = mouse.screen

		w:geometry({ y = w:geometry().y + settings.move_amount })

		if w:geometry().y >= screen[s].geometry.y + screen[s].geometry.height then
			ticker:stop()
			ticker:disconnect_signal('timeout', do_slide_down)
			w.visible = false
		end
	end

local show_wibox =
	function (s)
		local geom = screen[s].geometry

		w.visible = true

		if not settings.slide then
			set_center(s)
			return
		end

		set_default(s)

		-- changing visible property would reset wibox geometry to its defaults
		-- Might be 0 if position is set to 'top'
		-- Thus the wibox has to be shown before setting its original slide up
		-- position. As a side effect, the top bar might blink if position is set
		-- to 'top'.

		if not ticker then
			-- try to calculate the number of moves
			local moves = (geom.height / 2) / settings.move_amount

			ticker = timer({ timeout = settings.move_time / moves })
		end

		ticker:connect_signal('timeout', do_slide_up)
		ticker:start()
	end

local hide_wibox =
	function ()
		local s = mouse.screen

		local geom = screen[s].geometry

		if not settings.slide then
			set_center(s)
			w.visible = false
			return
		end

		if not ticker then
			-- try to calculate the number of moves
			local moves = (geom.height / 2) / settings.move_amount

			ticker = timer({ timeout = settings.move_time / moves })
		end

		ticker:connect_signal('timeout', do_slide_down)
		ticker:start()
	end

run_prompt =
	function ()
		if not inited then
			ensure_init()
		end

		show_wibox(mouse.screen)

		awful.prompt.run
		(
			{ prompt = settings.prompt_string, font = settings.prompt_font },
			p,
			settings.run_function,
			settings.completion_function,
			awful.util.getdir('cache') .. settings.cache,
			100,
			hide_wibox
		)
	end

local update_settings =
	function ()
		w.border_width = settings.border_width

		w.opacity = settings.opacity
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

set_prompt_font         = function (font  ) settings.prompt_font         = font   or defaults.prompt_font         end
set_slide               = function (tf    ) settings.slide               = tf     or defaults.slide               end
set_move_time           = function (amount) settings.move_time           = amount or defaults.move_time           end
set_move_amount         = function (amount) settings.move_amount         = amount or defaults.move_amount         end
set_run_function        = function (fn    ) settings.run_function        = fn     or defaults.run_function        end
set_position            = function (p     ) settings.position            = p                                      end
set_completion_function = function (fn    ) settings.completion_function = fn     or defaults.completion_function end
set_cache               = function (c     ) settings.cache               = c      or defaults.cache               end

return _ENV
