-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
theme = {}
theme.wallpaper_cmd = { "randwall" }
-- }}}

theme.theme_dir = "/home/will/.config/awesome/themes/mine/"


theme.panel_height=32

theme.black_bg=false

theme.panel_font="clean"
theme.panel_italic=false
theme.panel_bold=true
theme.panel_font_size=10

theme.panel_thickness = 3


-- {{{ Styles
theme.font      = "sans 10"

-- {{{ Colors
theme.fg_normal = "#DCDCCC"
theme.fg_focus  = "#F0DFAF"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#3F3F3F"
theme.bg_focus  = "#1E2320"
theme.bg_urgent = "#3F3F3F"
-- }}}



theme.colour_bg={{0,0x3F3F3F,1}, {0.5,0x4F4F4F,1} , {1,0x3F3F3F,0}}
theme.colour_fg={{0,0x666666,1}, {0.5,0xEAEAEA,1} , {1,0x666666,1}}
theme.colour_alarm={{0,0xFF8383,1},{0.5,0xFF0000,1},{1,0xFF8385,1}}



-- {{{ Borders
theme.border_width  = "2"
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#6F6F6F"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
theme.fg_widget        = "#AECF96"
theme.fg_center_widget = "#88A175"
theme.fg_end_widget    = "#FF5656"
theme.bg_widget        = "#494B4F"
theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = "15"
theme.menu_width  = "100"
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = "/home/will/.config/awesome/themes/mine/taglist/squarefz.png"
theme.taglist_squares_unsel = "/home/will/.config/awesome/themes/mine/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = "/home/will/.config/awesome/themes/mine/awesome-icon.png"
theme.menu_submenu_icon      = "/home/will/.config/awesome/themes/mine/submenu.png"
theme.tasklist_floating_icon = "/home/will/.config/awesome/themes/mine/tasklist/floatingw.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = "/home/will/.config/awesome/themes/mine/layouts/tile.png"
theme.layout_tileleft   = "/home/will/.config/awesome/themes/mine/layouts/tileleft.png"
theme.layout_tilebottom = "/home/will/.config/awesome/themes/mine/layouts/tilebottom.png"
theme.layout_tiletop    = "/home/will/.config/awesome/themes/mine/layouts/tiletop.png"
theme.layout_fairv      = "/home/will/.config/awesome/themes/mine/layouts/fairv.png"
theme.layout_fairh      = "/home/will/.config/awesome/themes/mine/layouts/fairh.png"
theme.layout_spiral     = "/home/will/.config/awesome/themes/mine/layouts/spiral.png"
theme.layout_dwindle    = "/home/will/.config/awesome/themes/mine/layouts/dwindle.png"
theme.layout_max        = "/home/will/.config/awesome/themes/mine/layouts/max.png"
theme.layout_fullscreen = "/home/will/.config/awesome/themes/mine/layouts/fullscreen.png"
theme.layout_magnifier  = "/home/will/.config/awesome/themes/mine/layouts/magnifier.png"
theme.layout_floating   = "/home/will/.config/awesome/themes/mine/layouts/floating.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = "/home/will/.config/awesome/themes/mine/titlebar/close_focus.png"
theme.titlebar_close_button_normal = "/home/will/.config/awesome/themes/mine/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = "/home/will/.config/awesome/themes/mine/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = "/home/will/.config/awesome/themes/mine/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = "/home/will/.config/awesome/themes/mine/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = "/home/will/.config/awesome/themes/mine/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = "/home/will/.config/awesome/themes/mine/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = "/home/will/.config/awesome/themes/mine/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = "/home/will/.config/awesome/themes/mine/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = "/home/will/.config/awesome/themes/mine/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = "/home/will/.config/awesome/themes/mine/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = "/home/will/.config/awesome/themes/mine/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = "/home/will/.config/awesome/themes/mine/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = "/home/will/.config/awesome/themes/mine/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = "/home/will/.config/awesome/themes/mine/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = "/home/will/.config/awesome/themes/mine/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = "/home/will/.config/awesome/themes/mine/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = "/home/will/.config/awesome/themes/mine/titlebar/maximized_normal_inactive.png"
-- }}}
-- }}}

return theme
