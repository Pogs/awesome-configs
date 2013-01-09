-- Text Markup Functions by Majic

local type         = type
local pairs        = pairs
local ipairs       = pairs
local tostring     = tostring
local sformat      = string.format
local setmetatable = setmetatable
local beautiful    = require('beautiful')

_ENV = {}

--[[

  +--------------------------+
  | Little map of how I      |
  | organized this for usage |
  +--------------------------+

  +-- markup
  |
  |`--+ tag
  |   |`-- b()     bold
  |   |`-- i()     italic
  |   |`-- s()     strikethrough
  |   |`-- u()     underline
  |   |`-- big()   big
  |   |`-- small() small
  |   |`-- sub()   subscript
  |   |`-- sup()   superscript
  |    `-- tt()    teletype or monospaced
  |
  |`--+ attr --.
  |            v
  |`--+ attribute
  |   |`-- font()                -- Of the form: [Font] [Style] [Size] ('Dejavu Sans Mono Bold 12')
  |   |`-- font_desc()           -- ^
  |   |`-- font_family()         -- Set font family ('sans')
  |   |`-- face()                -- ^
  |   |`-- font_size()           -- Set font size (in 1024th's of a point or 'xx-small', 'x-small', 'small', 'medium', 'large', 'x-large', 'xx-large')
  |   |`-- size()                -- ^
  |   |`-- font_style()          -- Set font style ('normal', 'oblique', 'italic', ...)
  |   |`-- style()               -- ^
  |   |`-- font_weight()         -- Set font weight (examples: 'ultralight', 'light', 'normal', 'bold', 'ultrabold', 'heavy', or numeric weight (100, 200, 300, ...))
  |   |`-- weight()              -- ^
  |   |`-- font_variant()        -- Set font variant (examples: 'normal', 'smallcaps', ...)
  |   |`-- variant()             -- ^
  |   |`-- font_stretch()        -- Set font stretch ('ultracondensed', 'extracondensed', 'semicondensed', 'normal', 'semiexpanded', 'expanded', 'extraexpanded', 'ultraexpanded')
  |   |`-- stretch()             -- ^
  |   |`-- foreground()          -- Set foreground color (RGB color of form #00FF00 or color name like 'red')
  |   |`-- fgcolor()             -- ^
  |   |`-- color()               -- ^
  |   |`-- background()          -- Set background color (RGB color of form #00FF00 or color name like 'red')
  |   |`-- bgcolor()             -- ^
  |   |`-- underline()           -- Set underline style ('none', 'single', 'double', 'low', 'error')
  |   |`-- underline_color()     -- Set underline color (RGB color of form #00FF00 or color name like 'red')
  |   |`-- rise()                -- Set font rise (vertical displacement in 10000ths of an em, negative for subscript, positive for superscript)
  |   |`-- strikethrough()       -- Set strikethrough state ('true' or 'false')
  |   |`-- strikethrough_color() -- Set strikethrough color (RGB color of form #00FF00 or color name like 'red')
  |   |`-- fallback()            -- Set font fallback state ('true' or 'false' to use a fallback font or not)
  |   |`-- lang()                -- Set language code (language code indicating the text language)
  |   |`-- letter_spacing()      -- Set letter spacing (inter-letter spacing in 1024ths of a point)
  |   |`-- gravity()             -- Set gravity ('south', 'east', 'north', 'west', 'auto')
  |    `-- gravity_hint()        -- Set gravity hint ('natural', 'strong', 'line')
  |
  | -- Friendly aliases.  Out the wazoo. --
  |
  |`-- bold()          -> markup.tag.b()
  |`-- italic()        -> markup.tag.i()
  |`-- strike()        -> markup.tag.s()
  |`-- strikethrough() -> markup.tag.s()
  |`-- under()         -> markup.tag.u()
  |`-- underline()     -> markup.tag.u()
  |`-- large()         -> markup.tag.big()
  |`-- big()           -> markup.tag.big()
  |`-- tiny()          -> markup.tag.small()
  |`-- small()         -> markup.tag.small()
  |`-- sub()           -> markup.tag.sub()
  |`-- subscript()     -> markup.tag.sub()
  |`-- sup()           -> markup.tag.sup()
  |`-- super()         -> markup.tag.sup()
  |`-- superscript()   -> markup.tag.sup()
  |`-- mono            -> markup.tag.tt()
  |`-- monospace       -> markup.tag.tt()
  |`-- fixed           -> markup.tag.tt()
  |`-- font            -> markup.attribute.font_desc()
  |`-- color           -> markup.attribute.color()
  |
  | -- Below this is all Beautiful-specific functions that rely on what's above --
  |
  |`--+ bg() -.
  |   |       v
  |   |`-- color()   Set background color.
  |   |`-- focus()   Set focus  background color.
  |   |`-- normal()  Set normal background color.
  |    `-- urgent()  Set urgent background color.
  |
  |`--+ fg() -.
  |   |       v
  |   |`-- color()   Set foreground color.
  |   |`-- focus()   Set focus  foreground color.
  |   |`-- normal()  Set normal foreground color.
  |    `-- urgent()  Set urgent foreground color.
  |
  |`-- focus()       Set both foreground and background focus  colors.
  |`-- normal()      Set both foreground and background normal colors.
   `-- urgent()      Set both foreground and background urgent colors.

]]


tag = {}

do
	-- Convenience tags. :-)
	local convenience_tags =
		{ 'b', 'i', 's', 'u', 'big', 'small', 'sub', 'sup', 'tt' }

	local tag_fmt = [[<%s>%s</%s>]]

	-- Build our convenience tag functions. e.g. markup.tag.b('text')
	for _, t in ipairs(convenience_tags) do
		tag[t] =
			function (s)
				return sformat(tag_fmt, t, tostring(s), t)
			end
	end
end


attribute = {}

-- alias to ^
attr = attribute

do
	local text_attributes =
	{
		-- Attributes on the same line are equivalent.
		'font',            'font_desc',          -- Of the form: [Font] [Style] [Size]
		'font_family',     'face',               -- can be anything
		'font_size',       'size',               -- font size in 1024th's of a point or xx-small, x-small, xmall, medium, large, x-large, xx-large
		'font_style',      'style',              -- normal, oblique, italic
		'font_weight',     'weight',             -- ultralight, light, normal, bold, ultrabold, heavy, or numeric weight
		'font_variant',    'variant',            -- normal or smallcaps
		'font_stretch',    'stretch',            -- ultracondensed, extracondensed, semicondensed, normal, semiexpanded, expanded, extraexpanded, ultraexpanded
		'foreground',      'fgcolor',   'color', -- RGB color of form #00FF00 or color name like 'red'
		'background',      'bgcolor',            -- RGB color of form #00FF00 or color name like 'red'
		'underline',                             -- none, single, double, low, error
		'underline_color',                       -- RGB color of form #00FF00 or color name like 'red'
		'rise',                                  -- vertical displacement in 10000ths of an em, negative for subscript, positive for superscript
		'strikethrough',                         -- true or false
		'strikethrough_color',                   -- RGB color of form #00FF00 or color name like 'red'
		'fallback',                              -- true or false, use a fallback font or not
		'lang',                                  -- language code indicating the text language
		'letter_spacing',                        -- inter-letter spacing in 1024ths of a point
		'gravity',                               -- south, east, north, west, auto
		'gravity_hint'                           -- natural, strong, line
	}

	local span_fmt = [[<span %s="%s">%s</span>]]

	-- Build or text attribute functions. eg.g. markup.attribute.weight('bold', 'this')
	for _, a in ipairs(text_attributes) do
		attribute[a] =
			function (a_state, s)
				s = tostring(s)

				-- span_fmt -> <span %s="%s">%s</span>
				return a_state == nil and s or sformat(span_fmt, a, tostring(a_state), s)
			end
	end
end


-- markup.fg.color(color, text)
fg = { color = attribute.foreground }

-- markup.bg.color(color, text)
bg = { color = attribute.background }

-- Building helpers like:
-- markup.fg.focus(text)
-- markup.bg.focus(text)
--    markup.focus(text)

for _, state in ipairs({ 'focus', 'normal', 'urgent' }) do
	fg[state] = function (text) return fg.color(beautiful['fg_' .. state], text) end
	bg[state] = function (text) return fg.color(beautiful['bg_' .. state], text) end
	_ENV[state] = function (text) return bg[state](fg[state](text))                end
end

-- markup.fg() -> markup.fg.color(); markup.bg() -> markup.bg.color()

do
	-- Share this, same behavior.
	local tmp = { __call = function (self, ...) return self.color(...) end }

	setmetatable(fg, tmp)
	setmetatable(bg, tmp)
end

do
	-- ALIAS ALL THE THINGS
	local aliases =
	{
		bold                                          = tag.b,
		italic                                        = tag.i,
		[{ 'strike', 'strikethrough'               }] = tag.s,
		[{ 'under',  'underline'                   }] = tag.u,
		[{ 'large',  'big'                         }] = tag.big,
		[{ 'tiny',   'small'                       }] = tag.small,
		[{ 'sub',    'subscript'                   }] = tag.sub,
		[{ 'sup',    'super',        'superscript' }] = tag.sup,
		[{ 'mono',   'monospace',    'fixed'       }] = tag.tt,
		font                                          = attribute.font_desc,
		color                                         = attribute.color,
	}

	-- Create our aliases. markup.bold('this') -> markup.tag.b('this')
	for a, f in pairs(aliases) do
		-- BUWHAHahahahahaha *cackle* *cackle*
		for _, x in ipairs(type(a) == 'table' and a or { a }) do
			_ENV[x] = f
		end
	end
end

return _ENV

--[[

IDEAS
=====

-- A function to check to see if already-formed markup text has an attribute applied?
-- A function to add an attribute to already-formed markup text.
-- make markup() generate a text formatting function

Eventually I want to be able to do this:
---------------------------------------

local tmp = markup_generator({ weight = true, gravity = south })

tmp('herp') -> '<span weight="true" gravity="south">herp</span>'

tmp:add_attribute({ underline_color = '#ff0000' })

-- The new attribute *must* go last.
tmp('derp') -> '<span weight="true" gravity="south" underline_color="#ff0000">derp</span>'

-- Not sure if I should want this. Just create a new markup function?
tmp:del_attribute({ 'weight' })

]]

