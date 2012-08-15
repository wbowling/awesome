--in this module : pop-up functions called when mouse is over a widget


local os=os
local math=math
local naughty=naughty
local awful=awful
local string=string

local config = awful.util.getdir("config") 
local icon_calendar =  config .. "/icons/gnome-calendar.png"
local icon_file_system =  config .. "/icons/gtk-harddisk.png"

module("popup")

----------------------------------------------------------------calendar
--from awesome wiki : http://awesome.naquadah.org/wiki/Naughty#Popup_calendar
local calendar = nil
local offset = 0

function remove_calendar()
	if calendar ~= nil then
		naughty.destroy(calendar)
		calendar = nil
		offset = 0
	end
end

function add_calendar(inc_offset)
	local save_offset = offset
	remove_calendar()
	offset = save_offset + inc_offset
	local datespec = os.date("*t")
	
	datespec = datespec.year * 12 + datespec.month - 1 + offset
	datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
	local cal = awful.util.pread("ncal -M " .. datespec)
	cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
	calendar = naughty.notify({
		title= string.format('<span font_desc="%s"><b>%s</b></span>',"monospace",os.date("%a, %d %B %Y") .. "\n" .. string.rep("-",string.len(os.date()))),
		icon=icon_calendar,
		gap=50,
		border_width = 1,
		text = string.format('<span font_desc="%s">%s</span>', "monospace",  cal),
		timeout = 0, 
		hover_timeout = 0.5,
	--    width =250 ,
	})
end

-------------------------------------------------------------file_system
local file_system = nil

function remove_file_system()
	if file_system ~= nil then
		naughty.destroy(file_system)
		file_system = nil
	end
end

function add_file_system()
	remove_file_system()
	local fs = awful.util.pread("df -h")
	file_system = naughty.notify({
		title= string.format('<span font_desc="%s"><b>%s</b></span>',"monospace",os.date("%a, %d %B %Y") .. "\n" .. string.rep("-",string.len(os.date()))),
		icon=icon_file_system,
		gap=50,
		border_width     = 1,
		text = string.format('<span font_desc="%s">%s</span>', "monospace",  fs),
		timeout = 0, hover_timeout = 0.5,
	})
end


	
	
	
