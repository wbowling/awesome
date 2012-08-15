--==============================================================================
--                                 icons.lua
--
--  author  : wlourf
--  version : v20111114 1.1
--  license : Distributed under the terms of GNU GPL version 2 or later
--
-- some widgets for awesome wm, created with cairo
-- with the path defined in the theme.lua
--==============================================================================

--[[
In your theme.lua, you can define default parameters :
theme.colour_bg={{0,0x0C0C0C,1}, {0.5,0x1C1C1C,1} , {1,0x0C0C0C,0}}
theme.colour_fg={{0,0x333333,1}, {0.5,0xDADADA,1} , {1,0x333333,1}}
theme.colour_alarm={{0,0xFF8383,1},{0.5,0xFF0000,1},{1,0xFF8385,1}}

theme.panel_height=48

theme.black_bg=true

theme.panel_font="clean"
theme.panel_italic=false
theme.panel_bold=true
theme.panel_font_size=12

theme.panel_thickness = 3

]]


local widget = widget
local io = io
local string = string 
local tonumber = tonumber
local math=math
local os=os
local loadstring = loadstring
local assert = assert
local awful = awful
local image=image
local vicious = require("vicious")
local beautiful = require("beautiful")
local naughty = require("naughty")
local config=awful.util.getdir("config")



local tostring=tostring
local dofile = dofile

local Cairo = require("oocairo")
local theme=beautiful
local h= beautiful.panel_height

module("cairowidgets")

--============================================ FUNCTIONS for CAIRO STUFF

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

local function linear_pattern(tcolour)
	local pattern = Cairo.pattern_create_linear (0,0,0,beautiful.panel_height)
	for i=1, #tcolour do
		pattern:add_color_stop_rgba ( tcolour[i][1], rgba_to_r_g_b_a(tcolour[i]))
	end
	return pattern
end

local function has_black_bg(bbg)
	if bbg ~= nil then
		return bbg
	else
		return beautiful.black_bg
	end
end	

local function has_bold_text(b)
	if b ~= nil then
		return b
	else
		return beautiful.panel_bold
	end
end	
local function has_italic_text(i)
	if i ~= nil then
		return i
	else
		return beautiful.panel_italic
	end
end

function init_image(w,h,black_bg,colour_bg)
	local cs = Cairo.image_surface_create("argb32", w, h)
	local cr = Cairo.context_create(cs)

	if black_bg then cr:paint() end

	cr:set_source(linear_pattern(colour_bg))
	cr:rectangle(0,0,w,h)
	cr:fill()
	cr:set_line_cap("round")
    cr:set_line_join("round")	
	return cs,cr
end

function init_font(italic, bold)
	local font_slant = "normal"
	local font_weight = "normal"
	if italic then font_slant="italic" end
	if bold  then font_weight="bold" end
	return font_slant, font_weight
end
init_colours()

--======================================================USEFUL FUNCTIONS
-------------------------------------------------------------get_fs_perc
--return the fs usage of a partition
function get_fs_perc(fs)
	local f = io.popen("df")
	local value = 0
	for line in f:lines() do
		if string.match(line, fs) then --root
			value = string.match(line, "([%d]+)%%")
			break
		end
	end
	f:close()
	return tonumber(value)
end

-------------------------------------------------------------active_batt
--without acpitool
local function active_batt(NumBatt)
	local path, perct, res, f
	local charge_full, charge_now, present

	path = "/sys/class/power_supply/BAT" .. tostring(NumBatt-1) .. "/" 
	local f=io.open(path .. "present")
	if f~=nil then 
		io.close(f)
	else 
		return -1
	end

	f = io.input(path .. "present")
	present = io.read("*number")
	f:close()

	if (present == 0) then 
		res = -1 
	else
		f = io.input(path .. "charge_now")
		charge_now = io.read("*number")
		f:close()

		f = io.input(path .. "charge_full")
		charge_full = io.read("*number")
		f:close()
		
		res =(charge_now/charge_full) * 100
	end
	
	return tonumber(res)
end

--------------------------------------------------------------active_cpu
--http://awesome.naquadah.org/wiki/CPU_Usage
--return active cpu value 
	nbcpu=0
	for line in io.lines("/proc/cpuinfo") do
		for key , value in string.gmatch(line, "processor") do
			   nbcpu=nbcpu+1
		end
	end

	local jiffies = {} 
	lastcpu = 0
	
	function active_cpu(refresh_time) local s, str
		for line in io.lines("/proc/stat") do
			local cpu,newjiffies = string.match(line, "(cpu)\ +(%d+)")
			if cpu and newjiffies then
				if not jiffies[cpu] then
					jiffies[cpu] = newjiffies
				end
				cpuusg = (newjiffies-jiffies[cpu])/(refresh_time)
				jiffies[cpu] = newjiffies
				lastcpu=cpuusg
			end
		end
		return cpuusg
	end

--------------------------------------------------------------active_ram
	for line in io.lines("/proc/meminfo") do
		local tmp= string.match(line, "MemTotal:\ +(%d+)")
		if tmp then
			memtot = tmp
			break
		end
	end

	function active_ram()
		local active, ramusg
	 
		for line in io.lines("/proc/meminfo") do
			for key , value in string.gmatch(line, "(%w+):\ +(%d+).+") do
				if key == "Active" then active = tonumber(value)
				end
			end
		end
		return 100*active/memtot
	end
	
--------------------------------------------------------active_fan_speed	
        function active_fan_speed(fan_file)
                local f = io.open(fan_file)
                v=0
                if f~= nil then
                        local v = f:read()
                        f:close()
                end
                return tonumber(v)
        end

---------------------------------------------------------active_cpu_temp
function active_cpu_temp(temp_file)
	local f=io.open(temp_file,"r")
	if f == nil then return 0 end
	io.close(f)
 	io.input(temp_file)
	local temp = io.read("*number")/1000
	io.close() 
	return temp
end

--===============================================================WIDEGTS

-------------------------------------------------------------cairo_space
-- @param width : width of the space
-- @param black_bg : apply black bg before background colour (true/false)
-- @param colour_bg : colour of space
function cairo_space(args)
	local w = args.width or 10
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local black_bg = has_black_bg(args.black_bg)
	
	local cs,cr=init_image(w,h,black_bg,colour_bg)

	return image.argb32(w, h, cs:get_data())	
end


----------------------------------------------------------cairo_gradient
-- @param width : width of the space
-- @param black_bg : apply black bg before background colour (true/false)
-- @param colour_bg : colour of space
function cairo_gradient(args)
	local w = args.width or 10
	local black_bg = has_black_bg(args.black_bg)
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	
	local cs,cr=init_image(w,h,black_bg,colour_bg)
	
	local mask = Cairo.pattern_create_linear(0,0,w,0)
	mask:add_color_stop_rgba (0,	0,0,0,0)
	mask:add_color_stop_rgba (1,	0,0,1,1)
	
	cr:set_source(mask)
	cr:set_operator("dest-out")
	cr:rectangle(0,0,w,h)
	cr:fill()	
	
	return image.argb32(w, h, cs:get_data())	
end

------------------------------------------------------------cairo_circle
-- @param text : text to display, default =""
-- @param value : value to display, default = 0
-- @param maxi : maximum value, default = 100
-- @param thickness : thickness of the ring
-- @param font : font name
-- @param italic : display text with italic slant (true/false)
-- @param bold : display text with bold weight (true/false)
-- @param font_size : font size
-- @param colour_bg : colour of background
-- @param colour_fg : colour of foreground
-- @param colour_alarm : colour of alarm
-- @param black_bg : apply black bg before background colour (true/false)
-- @param colour_fg : colour of foreground
-- @param radius : radius of the ring
-- @param alarm : threshold to change to colour_alarm

function cairo_circle(args)
	local text = args.text or ""
	local value = args.value or 0
	local maxi = args.maxi or 100
	local thickness = args.thickness or beautiful.panel_thickness or 2
	local font = args.font or beautiful.panel_font or "FreeSans"
	local italic = has_italic_text(args.italic)
	local bold = has_bold_text(args.bold)
	local font_size = args.font_size or beautiful.panel_font_size or "12"
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local colour_alarm = args.colour_alarm or beautiful.colour_alarm or {{0,0xFF0000,1}}
	local alarm = args.alarm or maxi
	local black_bg = has_black_bg(args.black_bg)
	local radius = args.radius or h/2-thickness
	local yy = h/2
	local xx = radius+thickness
	local w=h*2

	local cs,cr=init_image(w,h,black_bg,colour_bg)
	
	if value>alarm then 
		cr:set_source(linear_pattern(colour_alarm)) 
	else
		cr:set_source(linear_pattern(colour_fg))
	end
	
	if text ~= nil then
		local font_slant, font_weight = init_font(italic, bold)
		cr:select_font_face(font,font_slant,font_weight)
		cr:set_font_size(font_size)
		te=cr:text_extents(text)
		cr:save()
		cr:translate(-te["y_bearing"]+2,(h+te["x_advance"]+te["x_bearing"])/2)
		cr:rotate(-math.pi/2)
		cr:show_text(text)
		cr:stroke()	
		cr:restore()
		xx= te["height"]-te["y_bearing"]+radius+thickness
	end

	cr:set_line_cap("butt")
	cr:set_line_width(thickness)
	cr:arc(xx,yy,radius,0,2*math.pi)
	cr:stroke()
	cr:move_to(xx,yy)
	cr:arc_negative(xx,yy,radius,0,-2*math.pi*value/maxi)
	cr:fill()

	cs2 = Cairo.image_surface_create("argb32", xx+radius+thickness, h)
	cr2 = Cairo.context_create(cs2)
	local pattern=Cairo.pattern_create_for_surface(cs)
	cr2:set_source(pattern)
	cr2:paint()
	
	return image.argb32(xx+radius+thickness, h, cs2:get_data())	
end


--------------------------------------------------------------------vbar
-- @param text : text to display
-- @param value : value to display
-- @param width : width of the bar
-- @param maxi : maximum value, default = 100
-- @param thickness : thickness of the ring
-- @param font : font name
-- @param italic : display text with italic slant (true/false)
-- @param bold : display text with bold weight (true/false)
-- @param font_size : font size
-- @param colour_bg : colour of background
-- @param colour_fg : colour of foreground
-- @param colour_alarm : colour of alarm
-- @param alarm : threshold to change to colour_alarm
-- @param black_bg : apply black bg before background colour (true/false)
function vbar(args)
	local text = args.text or ""
	local value = args.value or 0
	local maxi = args.maxi or 100
	local width = args.width or 8
	local thickness = args.thickness or beautiful.panel_thickness or 2
	local font = args.font or beautiful.panel_font or "FreeSans"
	local italic = has_italic_text(args.italic)
	local bold = has_bold_text(args.bold)
	local font_size = args.font_size or beautiful.panel_font_size or "12"
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local colour_alarm = args.colour_alarm or beautiful.colour_alarm or {{0,0xFF0000,1}}
	local alarm = args.alarm or maxi	
	local black_bg = has_black_bg(args.black_bg)
	local w=300

	local cs,cr=init_image(w,h,black_bg,colour_bg)
	
	if value>alarm then 
		cr:set_source(linear_pattern(colour_alarm)) 
	else
		cr:set_source(linear_pattern(colour_fg))
	end

	if text ~= nil then
		local font_slant, font_weight = init_font(italic, bold)
		cr:select_font_face(font,font_slant,font_weight)
		cr:set_font_size(font_size)
		local te=cr:text_extents(text)
		cr:save()
		cr:translate(-te["y_bearing"]+2,(h+te["x_advance"]+te["x_bearing"])/2)
		cr:rotate(-math.pi/2)
		cr:show_text(text)
		cr:stroke()	
		cr:restore()
		xx= te["height"]-te["y_bearing"]
	end

	cr:set_line_width(thickness)
	cr:rectangle(xx,h-2,width,-h+4)
	cr:stroke()

	cr:rectangle(xx,h-2,width,-(h+4) *value/maxi)
	cr:fill()
	
	cs2 = Cairo.image_surface_create("argb32", xx+width+2, h)
	cr2 = Cairo.context_create(cs2)
	local pattern=Cairo.pattern_create_for_surface(cs)
	cr2:set_source(pattern)
	cr2:paint()
	
	return image.argb32(xx+width+2, h, cs2:get_data())	
end




-----------------------------------------------------------cairo_battery
-- @param battery = battery number 
-- @param width : width of the icon
-- @param thickness : thickness of the border
-- @param colour_bg : colour of background
-- @param colour_fg : colour of foreground
-- @param colour_alarm : colour of alarm
-- @param alarm : threshold to change to colour_alarm
-- @param black_bg : apply black bg before background colour (true/false)
function cairo_battery(args)
	local battery = args.battery or 1
	local w = args.width or 20
	local thickness = args.thickness or beautiful.panel_thickness or 2
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local colour_alarm = args.colour_alarm or beautiful.colour_alarm or {{0,0xFF0000,1}}
	local alarm = args.alarm or 25
	local value = active_batt(battery)
	local black_bg = has_black_bg(args.black_bg)
	
	local d=thickness*1.25
	local cs,cr=init_image(w,h,black_bg,colour_bg)
	local function  draw_batt_border(cr)
		cr:set_line_width(thickness)
		cr:move_to(d*3,d)
		cr:line_to(w-d*3,d)
		cr:line_to(w-d*3,d*2)
		cr:line_to(w-d*2,d*2)
		cr:line_to(w-d*2,h-d*2)
		cr:line_to(d*2,h-d*2)
		cr:line_to(d*2,d*2)        
		cr:line_to(d*3,d*2)
		cr:line_to(d*3,d)        
		cr:close_path()
		cr:stroke()
	end

	cr:set_source(linear_pattern(colour_fg))

	if value == -1 then
		draw_batt_border(cr)
		cr:set_source(linear_pattern(colour_fg))
		cr:move_to(d,d)
		cr:line_to(w-d,h-d)
		cr:stroke()
		cr:move_to(w-d,d)
		cr:line_to(d,h-d)
		cr:stroke()
	else
		if value<alarm then
			cr:set_source(linear_pattern(colour_alarm))
		end

		if value>=95 then
			cr:rectangle(d*3,d,		w-6*d,d*2)
			cr:rectangle(d*2,d*2,	w-4*d,(h-d*3))
		end
		if value<95 then
			local pc=d*2+(h-d*2)*((95-value)/100.0)
			cr:rectangle(d*2,h-d, w-d*4, -h+pc)
		end
		cr:fill()
		draw_batt_border(cr)
	end

    return image.argb32(w, h, cs:get_data())

end


-------------------------------------------------------cairo_double_hbar
-- @param width : width of the bars
-- @param text1 : text to display for top bar
-- @param text2 : text to display for bottom bar
-- @param value1 : value to display for top bar
-- @param value2 : value to display for bottom bar
-- @param maxi1 : maximum value for top bar, default = 100
-- @param maxi2 : maximum value for bottom bar, default = 100
-- @param alarm1 : threshold to change to colour_alarm
-- @param alarm2 : threshold to change to colour_alarm
-- @param thickness : thickness of the border
-- @param font : font name
-- @param italic : display text with italic slant (true/false)
-- @param bold : display text with bold weight (true/false)
-- @param font_size : font size
-- @param colour_bg : colour of background
-- @param colour_fg : colour of foreground
-- @param colour_alarm : colour of alarm
-- @param black_bg : apply black bg before background colour (true/false)
function cairo_double_hbar(args)
	local w = args.width or 100
	local text1 = args.text1 or ""
	local text2 = args.text2 or ""
	local value1 = args.value1 or 0
	local value2 = args.value2 or 0
	local maxi1 = args.maxi1 or 100
	local maxi2 = args.maxi2 or 100
	local thickness = args.thickness or beautiful.panel_thickness or 2
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local colour_alarm = args.colour_alarm or beautiful.colour_alarm or {{0,0xFF0000,1}}
	local alarm1 = args.alarm1 or maxi1
	local alarm2 = args.alarm2 or maxi2
	local font = args.font or beautiful.panel_font or "FreeSans"
	local italic = has_italic_text(args.italic)
	local bold = has_bold_text(args.bold)
	local font_size = args.font_size or beautiful.panel_font_size or "12"
	local black_bg = has_black_bg(args.black_bg)
		
	local cs,cr=init_image(w,h,black_bg,colour_bg)
    local font_slant, font_weight = init_font(italic, bold)
    
	cr:set_source(linear_pattern(colour_fg))
	cr:select_font_face(font,font_slant,font_weight)
	cr:set_font_size(font_size)
	local te=cr:text_extents(text1)
	local xh1 = te["x_advance"]
	cr:move_to(1, h * 0.40 -(h*0.30-te["height"])/2)
	cr:show_text(text1)

	local te=cr:text_extents(text2)
	local xh2 = te["x_advance"]

	cr:move_to(1, h * 0.85 -(h*0.30-te["height"])/2)
	cr:show_text(text2)
	cr:stroke()	
	local xh=math.max(xh1,xh2)

	cr:set_line_width(thickness)

	if value1>alarm1 then cr:set_source(linear_pattern(colour_alarm)) end
	cr:rectangle(xh+4,h * 0.40,w-(xh+6),-h * 0.30)
	cr:stroke()			
	cr:rectangle(xh+4, h * 0.40, (w-(xh+6))*value1/maxi1,-h * 0.30)
	cr:fill()			

	if value2>alarm2 then 
		cr:set_source(linear_pattern(colour_alarm)) 
	else
		cr:set_source(linear_pattern(colour_fg))
	end
	cr:rectangle(xh+4, h * 0.85,w-(xh+6),-h * 0.30)
	cr:stroke()			
	cr:rectangle(xh+4,h * 0.85, (w-(xh+6))*value2/maxi2,-h * 0.30)
	cr:fill()

	return image.argb32(w, h, cs:get_data())	

end


function cairo_double_text(args)
	local w = args.width or 100
	local text1 = args.text1 or ""
	local text2 = args.text2 or ""
	local thickness = args.thickness or beautiful.panel_thickness or 2
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local colour_alarm = args.colour_alarm or beautiful.colour_alarm or {{0,0xFF0000,1}}
	local alarm1 = args.alarm1 or maxi1
	local alarm2 = args.alarm2 or maxi2
	local font = args.font or beautiful.panel_font or "FreeSans"
	local italic = has_italic_text(args.italic)
	local bold = has_bold_text(args.bold)
	local font_size = args.font_size or beautiful.panel_font_size or "12"
	local black_bg = has_black_bg(args.black_bg)
		
	local cs,cr=init_image(w,h,black_bg,colour_bg)
        local font_slant, font_weight = init_font(italic, bold)
    
	cr:set_source(linear_pattern(colour_fg))
	cr:select_font_face(font,font_slant,font_weight)
	cr:set_font_size(font_size)
	local te=cr:text_extents(text1)
	local xh1 = te["x_advance"]
	cr:move_to(1, h * 0.40 -(h*0.30-te["height"])/2)
	cr:show_text(text1)

	local te=cr:text_extents(text2)
	local xh2 = te["x_advance"]

	cr:move_to(1, h * 0.85 -(h*0.30-te["height"])/2)
	cr:show_text(text2)
	cr:stroke()	
	local xh=math.max(xh1,xh2)

	cr:set_line_width(thickness)

	return image.argb32(w, h, cs:get_data())	

end


--------------------------------------------------------------cairo_hbar
-- @param text : text to display
-- @param unit : unit to display, default=""
-- @param value : value to display
-- @param width : width of the bar
-- @param enlarge : 
-- @param maxi : maximum value, default = 100
-- @param thickness : thickness of the ring
-- @param font : font name
-- @param italic : display text with italic slant (true/false)
-- @param bold : display text with bold weight (true/false)
-- @param font_size : font size
-- @param colour_bg : colour of background
-- @param colour_fg : colour of foreground
-- @param colour_alarm : colour of alarm
-- @param alarm : threshold to change to colour_alarm
-- @param black_bg : apply black bg before background colour (true/false)
function cairo_hbar(args)
	local w = args.width or 100
	local text = args.text or ""
	local value = args.value or 0
	local unit = args.unit or ""
	local maxi = args.maxi or 100
	local thickness = args.thickness or beautiful.panel_thickness or 2
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local colour_alarm = args.colour_alarm or beautiful.colour_alarm or {{0,0xFF0000,1}}
	local alarm = args.alarm or maxi
	local font = args.font or beautiful.panel_font or "FreeSans"
	local italic = has_italic_text(args.italic)
	local bold = has_bold_text(args.bold)
	local font_size = args.font_size or beautiful.panel_font_size or "12"
	local black_bg = has_black_bg(args.black_bg)
	local enlarge = args.enlarge 
	if enlarge==nil then enlarge=true end
	local offset=2 --padding 
		
	local cs,cr=init_image(1000,h,black_bg,colour_bg)	
	local font_slant, font_weight = init_font(italic, bold)
    
	if value>alarm then 
		cr:set_source(linear_pattern(colour_alarm)) 
	else
		cr:set_source(linear_pattern(colour_fg))
	end
	
	cr:select_font_face(font,font_slant,font_weight)
	cr:select_font_face(font,font_slant,font_weight)
	cr:set_font_size(font_size)
	local textall = text .. tostring(value) .. ' ' .. unit
	local te=cr:text_extents(textall)
	cr:move_to(offset, h * 0.50 + te["y_bearing"]/2)
	cr:show_text(textall)	
	
	local ww=w
	if enlarge then ww= te["width"] end 
	cr:set_line_width(thickness)
	cr:rectangle(offset, h*0.85, ww,-h * 0.30)
	cr:stroke()			
	cr:rectangle(offset, h*0.85, ww*value/maxi,-h * 0.30)
	cr:fill()
	
	local w2 = te["width"]+te["x_bearing"]+offset*2
	local ww
	if  w2>w then
		ww=w2
	else
		ww=w
	end
	local cs2 = Cairo.image_surface_create("argb32", ww, h)
	local cr2 = Cairo.context_create(cs2)
	local pattern=Cairo.pattern_create_for_surface(cs)
	cr2:set_source(pattern)
	cr2:paint()
	return image.argb32(ww, h, cs2:get_data())	

end

------------------------------------------------------------- cairo_text
-- @param text : text to display
-- @param value : value used for compare with alarm
-- @param alarm : threshold to change to colour_alarm
-- @param width : width of the bars
-- @param black_bg : apply black bg before background colour (true/false)
-- @param font : font name
-- @param italic : display text with italic slant (true/false)
-- @param bold : display text with bold weight (true/false)
-- @param font_size : font size
-- @param angle in degrees
-- @param x : x position of text
-- @param y : y position of text
-- @param colour_bg : colour of background
-- @param colour_fg : colour of foreground
-- @param colour_alarm : colour of alarm
-- @param black_bg : apply black bg before background colour (true/false)
function cairo_text(args)
	local text = args.text or ""
	local value = args.value or 100
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local font = args.font or beautiful.panel_font or "FreeSans"
	local italic = has_italic_text(args.italic)
	local bold = has_bold_text(args.bold)
	local font_size = args.font_size or beautiful.panel_font_size or "16"
	local colour_alarm = args.colour_alarm or beautiful.colour_alarm or {{0,0xFF0000,1}}
	local alarm = args.alarm or value +1	
	local x = args.x or 2
	local y = args.y or h/2
	local angle = args.angle or 0
	local black_bg = has_black_bg(args.black_bg)
	
	local cs,cr=init_image(500,h,black_bg,colour_bg)
	local font_slant, font_weight = init_font(italic, bold)
	cr:select_font_face(font,font_slant,font_weight)
	cr:set_font_size(font_size)
	
	local te=cr:text_extents(text)
	cr:move_to(x,y)

	if value>alarm then 
		cr:set_source(linear_pattern(colour_alarm)) 
	else
		cr:set_source(linear_pattern(colour_fg))
	end
	cr:rotate(angle*math.pi/180)
	cr:show_text(text)
	cr:stroke()	
	
	local width=te['x_advance']*math.cos(math.abs(angle)*math.pi/180)
	cs2 = Cairo.image_surface_create("argb32", x+width, h)
	cr2 = Cairo.context_create(cs2)
	local pattern=Cairo.pattern_create_for_surface(cs)
	cr2:set_source(pattern)
	cr2:paint()
	
	return image.argb32(x+width, h, cs2:get_data())	
end




------------------------------------------------------------ cairo_graph
--IMPORTANT : define an empty table when rc.lua starts and call it with param array
------------------------------------------------------------------------
-- @param text : text to display
-- @param value : last value to display
-- @param nb_values : number of values in array
-- @param array : table containing the values
-- @param thickness : thickness of the graph
-- @param width : width of the bars
-- @param font : font name
-- @param italic : display text with italic slant (true/false)
-- @param bold : display text with bold weight (true/false)
-- @param font_size : font size
-- @param colour_bg : colour of background
-- @param colour_fg : colour of foreground
-- @param colour_alarm : colour of alarm
-- @param black_bg : apply black bg before background colour (true/false)
-- @param maxi : maximum value for y axis
-- @param autoscale : autocale the y axis
function cairo_graph(args)
	local text = args.text or ""
	local value = args.value or 0
	local nb_values = args.nb_values or 30
	local array = args.array or {}
	local thickness = args.thickness or beautiful.panel_thickness or 2
	local font = args.font or beautiful.panel_font or "FreeSans"
	local italic = has_italic_text(args.italic)
	local bold = has_bold_text(args.bold)	
	local font_size = args.font_size or beautiful.panel_font_size or "12"
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local colour_alarm = args.colour_alarm or beautiful.colour_alarm or {{0,0xFF0000,1}}	
	local black_bg = has_black_bg(args.black_bg)
	local alarm = args.alarm or value +1
	local yy = h*.9
	local xx = thickness
	local w= args.width or 200
	local maxi = args.maxi or 100
	local autoscale = args.autoscale or false
	local first_call =false
	if #array==0 then
		for x=1, nb_values do array[x]=0 end
		first_call = true
	end
	local black_bg = has_black_bg(args.black_bg)
	local cs,cr=init_image(w,h,black_bg,colour_bg)

	if value>alarm then 
		cr:set_source(linear_pattern(colour_alarm)) 
	else
		cr:set_source(linear_pattern(colour_fg))
	end
		
	if text ~= nil then
		local font_slant, font_weight = init_font(italic, bold)
		cr:select_font_face(font,font_slant,font_weight)
		cr:set_font_size(font_size)
		local te=cr:text_extents(text)
		cr:save()
		cr:translate(-te["y_bearing"]+2,(h+te["x_advance"]+te["x_bearing"])/2)
		cr:rotate(-math.pi/2)
		cr:show_text(text)
		cr:stroke()	
		cr:restore()
		xx= te["height"]-te["y_bearing"]
	end	

	local width=w-xx-5
	local height=h*.8

	cr:translate(xx,yy)
	--cr:move_to(0,-array[1]*height/100)
	cr:set_line_width(thickness)
	local maxgraph=0
	for i=2,nb_values do 
		array[i-1]=array[i]
		maxgraph=math.max(maxgraph, array[i])
	end
	array[nb_values]= value

	local maxgraph=math.max(maxgraph, value)
	
	if autoscale then maxi = maxgraph end
	if first_call then 
		cr:move_to(width/nb_values,0)
		cr:line_to(width,0)
		cr:stroke()
	end
	for i=1,nb_values do 
		cr:line_to(width*i/nb_values,-(array[i]/maxi)*height)
	end
	cr:stroke()

	return image.argb32(w, h, cs:get_data())	
end

---------------------------------------------------------------cairo_mpd
-- @param text : vertical text to display
-- @param width : width of the widget
-- @param autofit : autofit  the widget
-- @param font : font name
-- @param italic : display text with italic slant (true/false)
-- @param bold : display text with bold weight (true/false)
-- @param font_size : font size
-- @param colour_bg : colour of background
-- @param colour_fg : colour of foreground
-- @param black_bg : apply black bg before background colour (true/false)
function cairo_mpd(args)
	local text = args.text or "mpd"
	local font = args.font or beautiful.panel_font or "FreeSans"
	local italic = has_italic_text(args.italic)
	local bold = has_bold_text(args.bold)
	local font_size = args.font_size or beautiful.panel_font_size or "12"
	local colour_bg = args.colour_bg or beautiful.colour_bg or {{0,0x000000,1}}
	local colour_fg = args.colour_fg or beautiful.colour_fg or {{0,0xFFFFFF,1}}
	local black_bg = has_black_bg(args.black_bg)
	local w= args.width or 200
	local autofit = args.autofit or false
	
	if autofit then w_img= 1000 else w_img=w end
	local cs,cr=init_image(w_img,h,black_bg,colour_bg)
	local font_slant, font_weight = init_font(italic, bold)
	
	cr:set_source(linear_pattern(colour_fg))
	cr:select_font_face(font,font_slant,font_weight)
	cr:set_font_size(font_size)
	local te=cr:text_extents(text)
	cr:save()
	cr:translate(-te["y_bearing"]+2,(h+te["x_advance"]+te["x_bearing"])/2)
	cr:rotate(-math.pi/2)	
	cr:show_text(text)
	cr:restore()

	--special stuff for FIP cool radio ;-) 
	--http://sites.radiofrance.fr/chaines/fip/endirect/
	--and thers radios
	if mpd_artist=="N/A" and mpd_title=="N/A" then
		local radios = require("radios")
		mpd_artist, mpd_title = radios.get_radio()
	end
	
	local offset = te["height"]-te["y_bearing"]
	local te=cr:text_extents(mpd_artist)
	cr:move_to(offset,h*.4-te["y_advance"])
	cr:show_text(mpd_artist)		
	
	local width_artist=te["width"]+te["x_bearing"]
	local te=cr:text_extents(mpd_title)
	if mpd_artist == "" then
		cr:move_to(offset,h/2+te["height"]/2)
	else
		cr:move_to(offset,h/2+te["height"])
	end
	cr:show_text(mpd_title)
	local width_title=te["width"]+te["x_bearing"]

	if  autofit then
		local width_autofit=math.max(width_title, width_artist) +offset+2
		local cs2 = Cairo.image_surface_create("argb32", width_autofit, h)
		local cr2 = Cairo.context_create(cs2)
		local pattern=Cairo.pattern_create_for_surface(cs)
		cr2:set_source(pattern)
		cr2:paint()
		return image.argb32(width_autofit, h, cs2:get_data())	
	else
		return image.argb32(w, h, cs:get_data())	
	end
end


dummy_mpd_widget = widget({ type = "textbox" })
vicious.register(dummy_mpd_widget, vicious.widgets.mpd,
    function (widget, args)
        if args["{state}"] == "Stop" then 
			mpd_title=""
			mpd_artist=""
            return " - "
        else 
			mpd_title=args["{Title}"]
			mpd_artist= args["{Artist}"]
            return args["{Artist}"]..' - '.. args["{Title}"]
        end
    end, 10)


-------------------------------------------------------------cairo_cover
-- @param cover : cover path and file in PNG format
-- @param size : size for the image
function popup_cover(args)
	local cover = args.cover or "/tmp/cover.png"
	local f=io.open(cover,"r")
	if f == nil then return end
	io.close(f)
	local size = args.size or 200

	local img = Cairo.image_surface_create_from_png(cover)
	local w = img:get_width()
	local h = img:get_height()

	local fscale
	if w>h then
		fscale=size/h
	else
		fscale=size/w
	end
		
	local cs2 = Cairo.image_surface_create("argb32", size,size)
	local cr2 = Cairo.context_create(cs2)
	local pattern=Cairo.pattern_create_for_surface(img)
	cr2:scale(fscale,fscale)
	cr2:set_source(pattern)
	cr2:paint()
	
	mpd_cover=naughty.notify ({icon=image.argb32(size,size, cs2:get_data()), border_width=0	})
end

function popup_cover_stop()
	if mpd_cover ~= nil then
		naughty.destroy(mpd_cover)
		mpd_cover = nil
	end
end
