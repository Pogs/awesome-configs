------------------------------------------
-- Author: Andrei 'Garoth' Thorp        --
-- Copyright 2009 Andrei 'Garoth' Thorp --
------------------------------------------

local setmetatable = setmetatable
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

local defaults =
{
	opacity             = 1.0, -- fully opaque
	prompt_string       = ' RUN: ',
	slide               = false, -- animation disabled by default
	width               = 0.6, -- 60% of screen width
	height              = 22, -- 22px
	border_width        = 1,
	move_time           = 0.2, -- total time for animation
	move_amount         = 5, -- 5px moves
	run_function        = awful.util.spawn,
	completion_function = awful.completion.shell,
	cache               = '/poprun_history'
}

local settings = setmetatable({}, { __index = defaults })

local w, p = nil, nil

local inited = false

local move_to_center =
	function (s)
		local geom = screen[s].geometry

		w:geometry
		{
			width  = geom.width * settings.width,
			height = settings.height,
			x      = geom.x + geom.width * ((1 - settings.width) / 2),
			y      = geom.y + mfloor((geom.height - w:geometry().height) / 2)
		}
	end

local move_to_bottom =
	function (s)
		local geom = screen[s].geometry

		w:geometry
		{
			width  = geom.width * settings.width,
			height = settings.height,
			x      = geom.x + geom.width * ((1 - settings.width) / 2),
			y      = geom.y + geom.height - w:geometry().height
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
		p:set_valign('center')
		p:set_align('center')

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
					border_color = beautiful.fg_focus,
					ontop        = true,
					opacity      = settings.opacity
				}
			)

		w.visible = false

		w:set_widget(w_layout)

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
			move_to_center(s)
			return
		end

		move_to_bottom(s)

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
			move_to_center(s)
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

-- SETTINGS

set_prompt_string       = function (self, string) settings.prompt_string       = string end
set_width               = function (self, amount) settings.width               = amount end
set_height              = function (self, amount) settings.height              = amount end
set_prompt_font         = function (self, font  ) settings.prompt_font         = font   end
set_slide               = function (self, tf    ) settings.slide               = tf     end
set_move_amount         = function (self, amount) settings.move_amount         = amount end
set_run_function        = function (self, fn    ) settings.run_function        = fn     end
set_completion_function = function (self, fn    ) settings.completion_function = fn     end
set_cache               = function (self, c     ) settings.cache               = c      end

set_border_width =
	function (self, amount)
		settings.border_width = amount
		w.border_width        = settings.border_width
	end

set_move_time =
	function (self, amount)
		settings.move_time = amount
		ticker = nil -- invalidate the only timer
	end

set_opacity =
	function (self, amount)
		settings.opacity = amount
		w.opacity        = settings.opacity
	end

return _ENV
