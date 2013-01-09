---------------------------
-- Default awesome theme --
---------------------------

local getdir = require('awful.util').getdir

themedir = getdir('config') .. '/themes/diehard/'

theme = {}

theme.font          = 'Consolas 7.5'
--theme.font          = 'NovaMono 10'
--theme.font          = 'Ubuntu Mono 8.5'
--theme.font          = 'Envy Code R 7.5'

theme.bg_normal     = '#0D161D'
theme.bg_focus      = '#131F2B'
theme.bg_urgent     = '#16293A'
theme.bg_minimize   = theme.bg_normal
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = '#828B94'
theme.fg_focus      = '#E0E0E0'
theme.fg_urgent     = theme.fg_normal
theme.fg_minimize   = theme.fg_normal

theme.border_width            = 2
theme.border_focus            = '#9A273B'
--theme.border_focus            = '#698C46'
--theme.border_focus            = '#5D7347'
--theme.border_focus            = '#44596C'
theme.border_normal           = '#171D24'
theme.border_marked           = theme.bg_normal

theme.taglist_squares_sel     = themedir .. 'taglist/squarefw.png'
theme.taglist_squares_unsel   = themedir .. 'taglist/squarew.png'

theme.tasklist_floating_icon  = themedir .. 'layouts/floatingw.png'

theme.menu_submenu_icon = themedir .. 'submenu.png'
theme.menu_height       = 15
theme.menu_width        = 100

-- Define the image to load
theme.titlebar_close_button_normal              = themedir .. 'titlebar/close_normal.png'
theme.titlebar_close_button_focus               = themedir .. 'titlebar/close_focus.png'

theme.titlebar_ontop_button_normal_inactive     = themedir .. 'titlebar/ontop_normal_inactive.png'
theme.titlebar_ontop_button_focus_inactive      = themedir .. 'titlebar/ontop_focus_inactive.png'
theme.titlebar_ontop_button_normal_active       = themedir .. 'titlebar/ontop_normal_active.png'
theme.titlebar_ontop_button_focus_active        = themedir .. 'titlebar/ontop_focus_active.png'

theme.titlebar_sticky_button_normal_inactive    = themedir .. 'titlebar/sticky_normal_inactive.png'
theme.titlebar_sticky_button_focus_inactive     = themedir .. 'titlebar/sticky_focus_inactive.png'
theme.titlebar_sticky_button_normal_active      = themedir .. 'titlebar/sticky_normal_active.png'
theme.titlebar_sticky_button_focus_active       = themedir .. 'titlebar/sticky_focus_active.png'

theme.titlebar_floating_button_normal_inactive  = themedir .. 'titlebar/floating_normal_inactive.png'
theme.titlebar_floating_button_focus_inactive   = themedir .. 'titlebar/floating_focus_inactive.png'
theme.titlebar_floating_button_normal_active    = themedir .. 'titlebar/floating_normal_active.png'
theme.titlebar_floating_button_focus_active     = themedir .. 'titlebar/floating_focus_active.png'

theme.titlebar_maximized_button_normal_inactive = themedir .. 'titlebar/maximized_normal_inactive.png'
theme.titlebar_maximized_button_focus_inactive  = themedir .. 'titlebar/maximized_focus_inactive.png'
theme.titlebar_maximized_button_normal_active   = themedir .. 'titlebar/maximized_normal_active.png'
theme.titlebar_maximized_button_focus_active    = themedir .. 'titlebar/maximized_focus_active.png'


theme.wallpaper                                 = themedir .. 'background-blue.png'

-- You can use your own layout icons like this:
theme.layout_fairh      = themedir .. 'layouts/fairhw.png'
theme.layout_fairv      = themedir .. 'layouts/fairvw.png'
theme.layout_floating   = themedir .. 'layouts/floatingw.png'
theme.layout_magnifier  = themedir .. 'layouts/magnifierw.png'
theme.layout_max        = themedir .. 'layouts/maxw.png'
theme.layout_fullscreen = themedir .. 'layouts/fullscreenw.png'
theme.layout_tilebottom = themedir .. 'layouts/tilebottomw.png'
theme.layout_tileleft   = themedir .. 'layouts/tileleftw.png'
theme.layout_tile       = themedir .. 'layouts/tilew.png'
theme.layout_tiletop    = themedir .. 'layouts/tiletopw.png'
theme.layout_spiral     = themedir .. 'layouts/spiralw.png'
theme.layout_dwindle    = themedir .. 'layouts/dwindlew.png'

-- note the '..'
theme.awesome_icon      = themedir .. '../icons/awesome16.png'

-- Define the icon theme for application icons. If not set then the icons 
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = 'gnome'

return theme
