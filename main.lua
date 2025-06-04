Object = require 'libraries/classic/classic'
Input = require 'libraries/input/Input'
-- Timer = require 'libraries/hump/timer'
Moses = require 'libraries/moses/moses'
Timer = require 'libraries/enhancedtimer/EnhancedTimer'
Camera = require 'libraries/hump/camera'
Physics = require 'libraries/windfield'
DraftLib = require 'libraries/draft/draft'
Vector = require 'libraries/hump/vector'
-- tree = require 'tree'

require 'libraries/utf8/utf8'

require 'GameObject'
require 'utils'
require 'globals'

function love.load(args)
	love.graphics.setBackgroundColor(love.math.colorFromBytes(background_color))
	
	love.graphics.setDefaultFilter('nearest')
	love.graphics.setLineStyle('rough')

	slow_amount = 1
	flash_frames = nil

	local object_files = {}
	recursiveEnumerate('objects', object_files)
	requireFiles(object_files)

	local room_files = {}
	recursiveEnumerate('rooms', room_files)
	requireFiles(room_files)

	loadFonts('resources/fonts')

	camera = Camera()
	input = Input()
	timer = Timer()
	m = Moses()
	Draft = DraftLib()
	-- vector = Vector()

	input:bind('f3', function() camera:shake(4,60,1) end)

	current_room = nil

	gotoRoom('SkillTree')

	resize(3)

    input:bind('f4', function() 
        if current_room then
            current_room:destroy()
            current_room = nil
        end
    end)
	input:bind('f5', function() gotoRoom('Stage') end)

	input:bind('left', 'left')
    input:bind('right', 'right')
	input:bind('up', 'up')
    input:bind('down', 'down')
	input:bind('mouse1', 'mouse1')
	input:bind('wheelup', 'zoom_in')
	input:bind('wheeldown', 'zoom_out')

	input:bind('f1', function()
        print("Before collection: " .. collectgarbage("count")/1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count")/1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
    end)
end

function love.update(dt)
	time = time + dt
	timer:update(dt)
	camera:update(dt)
	-- if input:pressed('mouse1') then print('pressed') end
	if current_room then current_room:update(dt*slow_amount) end
end

function love.draw()

	if current_room then current_room:draw() end

	if flash_frames then
		flash_frames = flash_frames - 1
		if flash_frames == -1 then flash_frames = nil end
	end
	if flash_frames then
		love.graphics.setColor(love.math.colorFromBytes(background_color))
		love.graphics.rectangle('fill', 0, 0, sx*gw, sy*gh)
		love.graphics.setColor(love.math.colorFromBytes(255,255,255))
	end

end

function recursiveEnumerate(folder, file_list)
	local items = love.filesystem.getDirectoryItems(folder)
	for _, item in ipairs(items) do
		local file = folder .. '/' .. item
		local info = love.filesystem.getInfo(file)

		for k, v in pairs(info) do
			if k == 'type' and v == 'file' then
				table.insert(file_list, file)
			elseif k == 'type' and v =='directory' then
				recursiveEnumerate(file, file_list)
			end
		end
	end
end

function requireFiles(files)
	for _, file in ipairs(files) do
		local file = file:sub(1, -5)
		require(file)
	end
end

function loadFonts(path)
    fonts = {}
    local font_paths = {}
    recursiveEnumerate(path, font_paths)
    for i = 8, 16, 1 do
        for _, font_path in pairs(font_paths) do
            local last_forward_slash_index = font_path:find("/[^/]*$")
            local font_name = font_path:sub(last_forward_slash_index+1, -5)
            local font = love.graphics.newFont(font_path, i)
            font:setFilter('nearest', 'nearest')
            fonts[font_name .. '_' .. i] = font
        end
    end
end

function addRoom(room_type, room_name, ...)
	local room = _G[room_type](room_name, ...)
	rooms[room_name] = room
	return room
end

function gotoRoom(room_type, ...)
	if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
end

function resize(s)
	love.window.setMode(s*gw, s*gh)
	sx,sy = s,s 
end

function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
	    seen[t] = true
	    for k,v in pairs(t) do
	        if type(v) == "table" then
		    count_table(v)
	        elseif type(v) == "userdata" then
		    f(v)
	        end
	end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
	global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function slow(amount,duration)
    slow_amount = amount
	timer:tween('slow', duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function flash(frames)
	flash_frames = frames
end