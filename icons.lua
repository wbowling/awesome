
--this module creates directories, if needed,
-- and draws icons in these directories

local awful = require("awful")
local beautiful = require("beautiful")
local Cairo = require("oocairo")
local string = string
local os = os
local math = math

module("icons")

local function rgba_to_r_g_b_a(tc)
	local colour = tc[2]
	local alpha = tc[3]
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

local function init_colours()
	local colour_bg=beautiful.colour_bg
	local colour_fg=beautiful.colour_fg
	local colour_alarm=beautiful.colour_alarm
	
	linear_bg = Cairo.pattern_create_linear (0,0,0,beautiful.panel_height)
	linear_fg = Cairo.pattern_create_linear (0,0,0,beautiful.panel_height)
	linear_alarm = Cairo.pattern_create_linear (0,0,0,beautiful.panel_height)

	for i=1, #colour_bg do
		linear_bg:add_color_stop_rgba ( colour_bg[i][1], rgba_to_r_g_b_a(colour_bg[i]))
	end
	for i=1, #colour_fg do
		linear_fg:add_color_stop_rgba ( colour_fg[i][1], rgba_to_r_g_b_a(colour_fg[i]))
	end
	for i=1, #colour_alarm do
		linear_alarm:add_color_stop_rgba ( colour_alarm[i][1], rgba_to_r_g_b_a(colour_alarm[i]))
	end	
end

local function init_img_square()
	local h= beautiful.panel_height
	local thickness = beautiful.panel_thickness
	local thickness = beautiful.panel_thickness
	local cs = Cairo.image_surface_create("argb32",h,h)
	local cr = Cairo.context_create(cs)
	init_colours()

	if beautiful.draw_bg then 
		cr:set_source_rgb(0,0,0)
		cr:paint()
	end

	cr:set_source (linear_bg)
	cr:paint()

	cr:set_line_cap("round")
	cr:set_line_join("round")

	cr:set_line_width(thickness)
	cr:set_source (linear_fg)
	return cs,cr
end

local function save_file(outfile)
	--os.execute doesn't work in a module, works in dofile
	os.execute("mkdir -p "  .. string.gsub(outfile, "(.*/)(.*)", "%1"))
	--awful.util.spawn("mkdir -p "  .. string.gsub(outfile, "(.*/)(.*)", "%1"))
	cs:write_to_png (outfile)
end
	
	
local function icons_awesome(outfile)
	cs,cr=init_img_square()
	cr:move_to(0,h/3)
	cr:line_to(w*2/3,h/3)    
	cr:stroke()
	cr:move_to(w/3,h*2/3)
	cr:line_to(w*2/3,h*2/3)    
	cr:line_to(w*2/3,h)    
	cr:stroke()
	save_file(outfile) 
end

local function icons_phone(outfile)
	cs,cr=init_img_square()
	d=cr:get_line_width()
	cr:arc(w/2,h/2,h/2-d,0,2*math.pi)
	cr:stroke()
	
	cr:translate(w/2-2*d,h/2-2*d)
	for j=0,2 do
		for i=0,2 do
			cr:rectangle(i*3,j*3,d,d)
			cr:fill()
		end
	end
	save_file(outfile) 
end


local function icons_submenu(outfile)
	local cs2 = Cairo.image_surface_create("argb32",h,h)
	local cr = Cairo.context_create(cs2)
	init_colours()
	local d=cr:get_line_width()*2

	if beautiful.draw_bg then
		cr:move_to(d,d)
		cr:line_to(w-d,h/2)
		cr:line_to(d,h-d)
		cr:close_path()
		cr:set_source_rgb(0,0,0)
		cr:fill()
	end
	cr:move_to(d,d)
	cr:line_to(w-d,h/2)
	cr:line_to(d,h-d)
	cr:close_path()
	cr:set_source(linear_bg)
	cr:fill()
	
	cr:move_to(d,d)
	cr:line_to(w-d,h/2)
	cr:line_to(d,h-d)
	cr:close_path()
	cr:set_source(linear_fg)
	cr:fill()

	os.execute("mkdir -p "  .. string.gsub(outfile, "(.*/)(.*)", "%1"))
	cs2:write_to_png (outfile)
end



function layout_tile(tiletype,outfile)
	cs,cr=init_img_square()
    if tiletype=="left" then
        cr:translate(w/2.0,h/2.0)
        cr:rotate(math.pi/2)
        cr:translate(-w/2.0,-h/2.0)   
    elseif tiletype=="right" then
        cr:translate(w/2.0,h/2.0)
        cr:rotate(-math.pi/2)
        cr:translate(-w/2.0,-h/2.0)   
    elseif tiletype=="top" then
        cr:translate(w/2.0,h/2.0)
        cr:rotate(math.pi)
        cr:translate(-w/2.0,-h/2.0)   
	end
    cr:move_to(w/3,h/2)
    cr:line_to(w/3,h)    
    cr:stroke()
    cr:move_to(w*2/3,h/2)
    cr:line_to(w*2/3,h) 
    cr:stroke()
    save_file(outfile) 
end

function layout_fair(fairtype,outfile)
    cs,cr=init_img_square()
    if fairtype=="h" then
        cr:translate(w/2,h/2)
        cr:rotate(math.pi/2)
        cr:translate(-w/2,-h/2)
    end
    cr:move_to(0,h/3)
    cr:line_to(w*2/3,h/3)    
    cr:stroke()
    cr:move_to(0,h*2/3)
    cr:line_to(w*2/3,h*2/3)    
    cr:stroke()
    cr:move_to(w*2/3,h/2)
    cr:line_to(w,h/2)    
    cr:stroke()    
    save_file(outfile) 
end   

function layout_floating(outfile)
	cs,cr=init_img_square()
	d= cr:get_line_width()
    cr:arc(w/2,h/2,w/2-d,0,2*math.pi)
    cr:stroke()
    save_file(outfile)
end

function layout_magnifier(outfile)
    cs,cr=init_img_square()
    d= cr:get_line_width()*1.5
    cr:move_to(w/2,0)
    cr:line_to(w/2,h)
    cr:stroke()
    cr:move_to(0,h/2)
    cr:line_to(w,h/2)
    cr:stroke()
    cr:arc(w/2.0,h/2.0,w/2.0-d,0,2*math.pi)
    cr:fill()
	
	if beautiful.bg then
		cr:set_source_rgb(0,0,0)
		cr:arc(w/2.0,h/2.0,w/2.0-d,0,2*math.pi)
		cr:fill()    
	end
	cr:set_source (linear_bg)
	cr:arc(w/2.0,h/2.0,w/2.0-d,0,2*math.pi)
	cr:fill()  

    cr:set_source (linear_fg) 
    cr:arc(w/2.0,h/2.0,w/2.0-d,0,2*math.pi)
    cr:stroke()
    save_file(outfile) 
end

function layout_maximize(outfile)
	cs,cr=init_img_square()
	d= cr:get_line_width()
	cr:move_to(d,d)
	cr:line_to(w/3,d)
	cr:stroke()
	cr:move_to(d,d)
	cr:line_to(d,h/3)
	cr:stroke()        

	cr:move_to(w-d,d)
	cr:line_to(w*2/3,d)
	cr:stroke()
	cr:move_to(w-d,d)
	cr:line_to(w-d,h/3)
	cr:stroke() 

	cr:move_to(w-d,h-d)
	cr:line_to(w*2/3,h-d)
	cr:stroke()
	cr:move_to(w-d,h-d)
	cr:line_to(w-d,h*2/3)
	cr:stroke() 

	cr:move_to(d,h-d)
	cr:line_to(w/3,h-d)
	cr:stroke()
	cr:move_to(d,h-d)
	cr:line_to(d,h*2/3)
	cr:stroke()     

	cr:move_to(d,d)
	cr:line_to(w-d,h-d)
	cr:stroke()
	cr:move_to(w-d,d)
	cr:line_to(d,h-d)
	cr:stroke()	
    save_file(outfile) 

end

function layout_fullscreen(outfile)
	cs,cr=init_img_square()
	d= cr:get_line_width()
	cr:move_to(w/2,d)
	cr:line_to(w-d,d)
	cr:line_to(w-d,h/2)
	cr:stroke()
	cr:move_to(w/2,h/2)
	cr:line_to(w-d,d)
	cr:stroke()
	save_file(outfile)
end

function layout_spiral(outfile)
	cs,cr=init_img_square()
	d= cr:get_line_width()
	cr:arc(w/2,h/2,w/2-d,0,math.pi)
	cr:stroke()
	cr:arc(w/4+d,h/2,w/4,math.pi,0)
	cr:stroke()
	save_file(outfile)
end

function layout_dwindle(outfile)
	cs,cr=init_img_square()
	cr:move_to(w/2,0)
	cr:line_to(w/2,h)
	cr:stroke()
	cr:move_to(w/2,h/2)
	cr:line_to(w,h/2)
	cr:stroke()
	cr:move_to(w/2+w/4,h/2)
	cr:line_to(w/2+w/4,h)
	cr:stroke()    
	cr:move_to(w/2+w/4,h/2+h/4)
	cr:line_to(w,h/2+h/4)
	cr:stroke()   
	save_file(outfile)
end

beautiful.colour_bg 	= beautiful.colour_bg or {{0,0x000000,1}}
beautiful.colour_fg 	= beautiful.colour_fg or {{0,0xFFFFFF,1}}
beautiful.colour_alarm 	= beautiful.colour_alarm or {{0,0xFF0000,1}}
beautiful.panel_height 	= beautiful.panel_height or 24
if beautiful.draw_bg == nil then beautiful.draw_bg = true end
beautiful.panel_thickness = beautiful.panel_thickness or 2

beautiful.awesome_icon	= beautiful.awesome_icon or beautiful.theme_dir .. "/icons/awesome.png" --
beautiful.phone_icon 	= beautiful.phone_icon or beautiful.theme_dir .. "/icons/phone.png"
beautiful.menu_submenu_icon = beautiful.menu_submenu_icon or beautiful.theme_dir .. "/icons/submenu.png"

w,h= beautiful.panel_height,beautiful.panel_height

icons_awesome(beautiful.awesome_icon)
icons_phone(beautiful.phone_icon)
icons_submenu(beautiful.menu_submenu_icon)

layout_tile("left",		beautiful.layout_tileleft)
layout_tile("right",	beautiful.layout_tile)
layout_tile("top",		beautiful.layout_tiletop)
layout_tile("bottom",	beautiful.layout_tilebottom)
layout_fair("v",		beautiful.layout_fairv)
layout_fair("h",		beautiful.layout_fairh)
layout_floating(		beautiful.layout_floating)
layout_magnifier(		beautiful.layout_magnifier)
layout_maximize(		beautiful.layout_max)
layout_fullscreen(		beautiful.layout_fullscreen)
layout_spiral(			beautiful.layout_spiral)
layout_dwindle(			beautiful.layout_dwindle)
