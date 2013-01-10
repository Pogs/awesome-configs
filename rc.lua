---------------------------------------------
-- Awesome 3 (git) configuration file by | -- 
--------------------------------------------- 

do
	local k, b = collectgarbage('count')
	local d    = os.date('%c')

	io.stdout:write
	(
		'\r\n' ..
		('::: Entered rc.lua ... (%s) ::: Mem: %d B\r\n'):format(d, k * 1024 + b),
		'\r\n'
	)
end

-- For loading the 5.1 lgi .so
package.cpath =
	'/usr/lib/lua/5.1/?.so;'       ..   
	'/usr/lib/lua/5.1/loadall.so;' ..
	package.cpath

-- For loading awful and friends from the git build dir
package.path =
	os.getenv('HOME') .. '/.config/awesome/lib/?.lua;'           ..
	os.getenv('HOME') .. '/clones/awesome/build/lib/?.lua;'      ..   
	os.getenv('HOME') .. '/clones/awesome/build/lib/?/init.lua;' ..
	package.path


-- Standard awesome library
local gears = require('gears')
local awful = require('awful')

awful.rules = require('awful.rules')

require('awful.autofocus')

-- Widget and layout library
local wibox = require('wibox')

-- Theme handling library
local beautiful = require('beautiful')

-- Notification library
local naughty = require('naughty')
local menubar = require('menubar')

-- table function aliases
local tins = table.insert
local trem = table.remove
local tunp = table.unpack

local tjoin = awful.util.table.join

local akey = awful.key

local sformat = string.format

-- where this sits is important, it only
-- catches bad globalling from this point forward
require('strict')

local markup = require('markup')

-- make tostring() vararg-capable
do
	local orig_tostring = tostring

	tostring =
		function (...)
			local ret = {}

			for i = 1, select('#', ...) do
				tins(ret, orig_tostring(select(i, ...)))
			end

			return tunp(ret)
		end
end

-- {{{ Preliminary naughty settings

do
	local presets =
	{
		screen        = 1, 
		position      = 'top_right',
		timeout       = 20,
		hover_timeout = 0.5
	}

	for k, v in pairs(presets) do
		for _, severity in pairs({ 'low', 'normal', 'critical' }) do
			naughty.config.presets[severity][k] = v
		end
	end
end

-- }}}

-- {{{ Error handling

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify
	(
		{
			preset = naughty.config.presets.critical,
			title  = 'STARTUP ERROR',
			text   = awesome.startup_errors
		}
	)
end

-- Handle runtime errors after startup
do
    local in_error = false

    awesome.connect_signal
	(
		'debug::error',
		function (err)
			-- Make sure we don't go into an endless error loop
			if in_error then return end

			in_error = true

			naughty.notify
			(
				{
					preset = naughty.config.presets.critical,
					title  = 'RUNTIME ERROR',
					text   = err
				}
			)

			in_error = false
		end
	)
end

awesome.connect_signal
(
	'debug::deprecation',
	function (e)
		naughty.notify
		(
			{
				preset = naughty.config.presets.critical,
				title  = 'DEPRECATION ERROR',
				text   = e
			}
		)
	end
)

awesome.connect_signal
(
	'debug::index::miss',
	function (o, k)
		naughty.notify
		(
			{
				preset = naughty.config.presets.critical,
				title  = '__INDEX ERROR',
				text   = sformat("object '%s' does not have key '%s'", tostring(o, k))
			}
		)
	end
)

awesome.connect_signal
(
	'debug::newindex::miss',
	function (o, k, v)
		naughty.notify
		(
			{
				preset = naughty.config.presets.critical,
				title  = '__NEWINDEX ERROR',
				text   = sformat([[object '%s' does not have key '%s', could not set to '%s']], tostring(o, k, v))
			}
		)
	end
)

-- }}}

-- {{{ Variable definitions

-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir('config') .. '/themes/diehard/theme.lua')

-- This is used later as the default terminal and editor to run.
local terminal = 'urxvt'
local editor = os.getenv('EDITOR') or 'vim'
local editor_cmd = terminal .. ' -e ' .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = 'Mod4'

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
--    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
}

-- }}}

-- {{{ Wallpaper

if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.tiled(beautiful.wallpaper, s)
    end
end

-- }}}

-- {{{ Tags

-- Define a tag table which hold all screen tags.
tags = {}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
end

-- }}}

-- {{{ Menu

-- Create a laucher widget and a main menu
myawesomemenu =
{
	{ 'manual',      terminal .. ' -e man awesome'         },
	{ 'edit config', editor_cmd .. ' ' .. awesome.conffile },
	{ 'restart',     awesome.restart                       },
	{ 'quit',        awesome.quit                          }
}

mymainmenu =
	awful.menu
	(
		{
			items =
			{
				{ 'awesome',       myawesomemenu, beautiful.awesome_icon },
				{ 'open terminal', terminal                              }
			}
		}
	)

mylauncher =
	awful.widget.launcher
	(
		{
			image = beautiful.awesome_icon,
			menu = mymainmenu
		}
	)

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- }}}

-- {{{ Wibox

-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox     = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist   = {}

mytaglist.buttons =
	tjoin
	(
		awful.button({        }, 1, awful.tag.viewonly                                        ),
		awful.button({ modkey }, 1, awful.client.movetotag                                    ),
		awful.button({        }, 3, awful.tag.viewtoggle                                      ),
		awful.button({ modkey }, 3, awful.client.toggletag                                    ),
		awful.button({        }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
		awful.button({        }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
	)

mytasklist = {}

mytasklist.buttons =
	tjoin
	(
		awful.button
		(
			{},
			1,
			function (c)
				if c == client.focus then
					c.minimized = true
				else
					-- Without this, the following
					-- :isvisible() makes no sense
					c.minimized = false

					if not c:isvisible() then
						awful.tag.viewonly(c:tags()[1])
					end

					-- This will also un-minimize
					-- the client, if needed
					client.focus = c
					c:raise()
				end
			end
		),
		awful.button
		(
			{},
			3,
			function ()
				if instance then
					instance:hide()
					instance = nil
				else
					instance = awful.menu.clients({ width = 250 })
				end
			end
		),
		awful.button
		(
			{},
			4,
			function ()
				awful.client.focus.byidx(1)

				if client.focus then
					client.focus:raise()
				end
			end
		),
		awful.button
		(
			{},
			5,
			function ()
				awful.client.focus.byidx(-1)

				if client.focus then
					client.focus:raise()
				end
			end
		)
	)

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()

	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)

	mylayoutbox[s]:buttons
	(
		tjoin
		(
			awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
			awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
			awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
			awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
		)
	)

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = 'bottom', height = 18, screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()

    left_layout:add(mylauncher    )
    left_layout:add(mytaglist[s]  )
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()

    if s == 1 then
		right_layout:add(wibox.widget.systray())
	end

    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()

    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end

-- }}}

-- {{{ Mouse bindings

root.buttons
(
	tjoin
	(
		awful.button({ }, 3, function () mymainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext                 ),
		awful.button({ }, 5, awful.tag.viewprev                 )
	)
)

-- }}}

-- {{{ Key bindings
globalkeys =
	tjoin
	(
		akey({ modkey            }, 'Left',   awful.tag.viewprev       ),
		akey({ modkey            }, 'Right',  awful.tag.viewnext       ),
		akey({ modkey            }, 'Escape', awful.tag.history.restore),

		akey({ modkey            }, 'j', function () awful.client.focus.byidx( 1) if client.focus then client.focus:raise() end end),
		akey({ modkey            }, 'k', function () awful.client.focus.byidx(-1) if client.focus then client.focus:raise() end end),
		akey({ modkey            }, 'w', function () mymainmenu:show() end),

		-- Layout manipulation
		akey({ modkey, 'Shift'   }, 'space', function () awful.layout.inc(layouts,  1)                end),
		akey({ modkey, 'Control' }, 'Left',  function () awful.layout.inc(layouts,  1)                end),
		akey({ modkey, 'Control' }, 'Right', function () awful.layout.inc(layouts, -1)                end),

		akey({ modkey,           }, 't',     function () awful.layout.set(awful.layout.suit.tile    ) end),
		akey({ modkey,           }, 'e',     function () awful.layout.set(awful.layout.suit.fair    ) end),
		akey({ modkey,           }, 'f',     function () awful.layout.set(awful.layout.suit.floating) end),
		akey({ modkey,           }, 'm',     function () awful.layout.set(awful.layout.suit.max     ) end),

		akey({ modkey            }, '.',     function () awful.screen.focus_relative( 1)              end),
		akey({ modkey            }, ',',     function () awful.screen.focus_relative(-1)              end),

		akey({ modkey, 'Shift'   }, 'j', function () awful.client.swap.byidx(  1)    end),
		akey({ modkey, 'Shift'   }, 'k', function () awful.client.swap.byidx( -1)    end),

		akey({ modkey, 'Control' }, 'j', function () awful.screen.focus_relative( 1) end),
		akey({ modkey, 'Control' }, 'k', function () awful.screen.focus_relative(-1) end),

		akey({ modkey            }, 'u', awful.client.urgent.jumpto),

		akey
		(
			{ modkey },
			'Tab',
			function ()
				awful.client.focus.history.previous()

				if client.focus then
					client.focus:raise()
				end
			end
		),

		-- Standard program
		akey({ modkey            }, 'Return', function () awful.util.spawn(terminal)    end),
		akey({ modkey, 'Shift'   }, 'Return', function () awful.util.spawn(os.getenv('BROWSER') or 'chromium') end),
		akey({         'Control' }, 'Escape', function () awful.util.spawn('slock') end),

		akey({ modkey, 'Control' }, 'r', awesome.restart),
		akey({ modkey, 'Control' }, 'q', awesome.quit   ),

		akey({ modkey            }, 'l',     function () awful.tag.incmwfact( 0.05)      end),
		akey({ modkey            }, 'h',     function () awful.tag.incmwfact(-0.05)      end),

		akey({ modkey, 'Shift'   }, 'h',     function () awful.tag.incnmaster( 1)        end),
		akey({ modkey, 'Shift'   }, 'l',     function () awful.tag.incnmaster(-1)        end),

		akey({ modkey, 'Control' }, 'h',     function () awful.tag.incncol( 1)           end),
		akey({ modkey, 'Control' }, 'l',     function () awful.tag.incncol(-1)           end),

		-- Volume control.
		akey({           }, 'XF86AudioMute',        function () awful.util.spawn_with_shell('amixer -q set Master toggle') end),
		akey({           }, 'XF86AudioLowerVolume', function () awful.util.spawn_with_shell('amixer -q set Master 3dB-'  ) end),
		akey({           }, 'XF86AudioRaiseVolume', function () awful.util.spawn_with_shell('amixer -q set Master 3dB+'  ) end),

		-- Media player control.
		akey({           }, 'XF86AudioPlay', function () awful.util.spawn_with_shell('mocp --toggle-pause') end),
		akey({           }, 'XF86AudioPrev', function () awful.util.spawn_with_shell('mocp --previous'    ) end),
		akey({           }, 'XF86AudioNext', function () awful.util.spawn_with_shell('mocp --next'        ) end),
		akey({ 'Shift'   }, 'XF86AudioPrev', function () awful.util.spawn_with_shell('mocp -k -10'        ) end),
		akey({ 'Shift'   }, 'XF86AudioNext', function () awful.util.spawn_with_shell('mocp -k +10'        ) end),

		akey({           }, 'XF86Eject',     function () awful.util.spawn_with_shell('eject --traytoggle &') end),

		-- Prompt
		akey({ modkey            }, 'r',     function () mypromptbox[mouse.screen]:run() end),

		akey
		(
			{ modkey },
			'x',
			function ()
				awful.prompt.run
				(
					{ prompt = 'Run Lua code: ' },
					mypromptbox[mouse.screen].widget,
					awful.util.eval,
					nil,
					awful.util.getdir('cache') .. '/history_eval'
				)
			end
		),

		-- Menubar
		akey({ modkey }, 'p', function() menubar.show() end)
)

clientkeys =
	tjoin(
		akey({ modkey          }, 'space',  awful.client.floating.toggle                               ),
		akey({ modkey          }, 'f',      function (c) c.fullscreen = not c.fullscreen            end),
		akey({ modkey          }, 'c',      function (c) c:kill()                                   end),
		akey({ modkey, 'Shift' }, 't',      function (c) c.ontop = not c.ontop                      end),
		akey({ modkey          }, '\\',     function (c) c:swap(awful.client.getmaster())           end),
		akey({ modkey, 'Shift' }, '.',      function (c) awful.client.movetoscreen(c, c.screen + 1) end),
		akey({ modkey, 'Shift' }, ',',      function (c) awful.client.movetoscreen(c, c.screen - 1) end),
		akey
		(
			{ modkey },
			'm',
			function (c)
				c.maximized_horizontal = not c.maximized_horizontal
				c.maximized_vertical   = not c.maximized_vertical
			end
		)
	)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0

for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
	globalkeys =
		tjoin
		(
			globalkeys,
			akey
			(
				{ modkey },
				'#' .. i + 9,
				function ()
					local screen = mouse.screen

					if tags[screen][i] then
						awful.tag.viewonly(tags[screen][i])
					end
				end
			),
			akey
			(
				{ modkey, 'Control' },
				'#' .. i + 9,
				function ()
					local screen = mouse.screen

					if tags[screen][i] then
						awful.tag.viewtoggle(tags[screen][i])
					end
				end
			),
			akey
			(
				{ modkey, 'Shift' },
				'#' .. i + 9,
				function ()
					if client.focus and tags[client.focus.screen][i] then
						awful.client.movetotag(tags[client.focus.screen][i])
					end
				end
			),
			akey
			(
				{ modkey, 'Control', 'Shift' },
				'#' .. i + 9,
				function ()
					if client.focus and tags[client.focus.screen][i] then
						awful.client.toggletag(tags[client.focus.screen][i])
					end
				end
			)
		)
end

clientbuttons =
	tjoin
	(
		awful.button({        }, 1, function (c) client.focus = c c:raise() end),
		awful.button({ modkey }, 1, awful.mouse.client.move                    ),
		awful.button({ modkey }, 3, awful.mouse.client.resize                  )
	)

-- Set keys
root.keys(globalkeys)

-- }}}

-- {{{ Rules

awful.rules.rules =
{
	-- All clients will match this rule.
	{
		rule       = {},
		properties =
		{
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus        = awful.client.focus.filter,
			keys         = clientkeys,
			buttons      = clientbuttons
		}
	},

    { rule = { class = 'MPlayer'       }, properties = { floating = true } },
    { rule = { class = 'gnome-mplayer' }, properties = { floating = true } },
    { rule = { class = 'gtk2_prefs'    }, properties = { floating = true } }

    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = 'Firefox' }, properties = { tag = tags[1][2] } },
}

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal
(
	'manage',
	function (c, startup)
		-- no gaps.
		c.size_hints_honor = false

		-- don't you fucking hide. :|
		c.hidden           = false
		c.minimized        = false
		c.skip_taskbar     = false

		-- Enable sloppy focus
		c:connect_signal
		(
			'mouse::enter',
			function (c)
				if
					awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and
					awful.client.focus.filter(c)
				then
					client.focus = c
				end
			end
		)

		if not startup then
			-- Set the windows at the slave,
			-- i.e. put it at the end of others instead of setting it master.
			awful.client.setslave(c)

			-- Put windows in a smart way, only if they does not set an initial position.
			if
				not c.size_hints.user_position and
				not c.size_hints.program_position
			then
				awful.placement.no_overlap(c)
				awful.placement.no_offscreen(c)
			end
		end
	end
)

for s = 1, screen.count() do
	screen[s]:connect_signal
	(
		'arrange',
		function ()
			local clients = awful.client.visible(s)
			local layout  = awful.layout.getname(awful.layout.get(s))

			for _, c in pairs(clients) do -- Floaters are always on top
				-- Don't mess with the .above state
				-- unless it's not a fullscreen window and it's in a non-floating layout..
				if
					not c.fullscreen and
					layout ~= 'floating' and
					layout ~= 'magnifier'
				then 
					if awful.client.floating.get(c) then
						c.above = true
					end
--					c.above = awful.client.floating.get(c)
                end  
            end  
        end  
    )    
end

client.connect_signal('focus',   function(c) c.border_color = beautiful.border_focus  end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)

-- }}}
