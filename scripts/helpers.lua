--helper functions

function loadResources(a, b)
    local base_folder, resource_table
    if type(a) == 'string' then
        base_folder = a
    elseif type(b) == 'string' then
        base_folder = b
    else
        base_folder = ''
    end
    if type(a) == 'table' then
        resource_table = a
    elseif type(b) == 'table' then
        resource_table = b
    else
        resource_table = _G
    end
    local function load_directory(folder, place)
        for _, item in pairs(love.filesystem.getDirectoryItems(folder)) do
            local path = folder..'/'..item
            if love.filesystem.isFile(path) then
                local name, ext = item:match('(.+)%.(.+)$')
                if ext == 'png' or ext == 'bmp' or ext == 'jpg' or ext == 'jpeg' or ext == 'gif' or ext == 'tga' then
                    place[name] = love.graphics.newImage(path)
                elseif ext == 'ogg' or ext == 'mp3' or ext == 'wav' or ext == 'xm' or ext == 'it' or ext == 's3m' then
                    place[name] = love.audio.newSource(path)
				else
					error("found bad file.")
                end
            else
                place[item] = {}
                load_directory(path, place[item])
            end
        end
    end
    load_directory(base_folder, resource_table)
end

color = {}

function color.lightness (color,value)	--color must be a table value with 3 to 4 numbers 
	local r,g,b,a = color[1],color[2],color[3],color[4] or 255
	return {love.math.clamp(0,r+value,255), love.math.clamp(0,g+value,255), love.math.clamp(0,b+value,255), 255}
end

function love.math.order(x)		--get orders of magnitude
	if x == 0 then return x end
	if x < 0 then x = x*-1 end
	for i = 1, 1000 do
		if x < 10^i then return i end
	end
	return 1001
end

function love.math.sign(x)
	if x==0 then return 0 end
	if x<0 then return -1 end
	return 1
end

function love.math.round(x)
	if x%1 >= .5 then return math.ceil(x) else return math.floor(x) end
end

function love.math.clamp(low,val,high)
	if val >= low and val <= high then return val end
	if val < low then return low end
	if val > high then return high end
end

function love.graphics.radiusRectangle( mode, x, y, w, h, rx, ry )
	rx = rx or 1
	ry = ry or rx
	local pts = {}
	local precision = math.floor( 0.2 * ( rx + ry ) )
	local  hP =  math.pi / 2
	rx = rx >= w / 2 and w / 2 - 1 or rx
	ry = ry >= h / 2 and h / 2 - 1 or ry
	local sin, cos = math.sin, math.cos
	for i = 0, precision do   -- upper right
		local a = ( i / precision - 1 ) * hP
		pts[#pts+1] = x + w - rx * ( 1 -  cos(a) )
		pts[#pts+1] = y + ry * ( 1 +  sin(a) )
	end
	for i = 2 * precision + 2 , 1, -2 do   -- lower right
		pts[#pts+1] = pts[i-1]
		pts[#pts+1] = 2 * y - pts[i] + h
	end
	for i = 1, 2 * precision + 2, 2 do   -- lower left
		pts[#pts+1] = -pts[i] + 2 * x + w
		pts[#pts+1] = 2 * y - pts[i+1] + h
	end
	for i = 2 * precision+2 , 1, -2 do   -- upper left
		pts[#pts+1]   = -pts[i-1] + 2 * x + w
		pts[#pts+1]   = pts[i]
	end
	love.graphics.polygon( mode, pts )
end

function pointCircle(x,y,circle)
	local cx,cy,r = circle[1],circle[2],circle[3]
	return ((x-cx)^2+(y-cy)^2)^0.5 < r
end

function segmentIntersect(px,py,rx,ry,qx,qy,sx,sy)
	local d = (rx*sy - ry*sx)
	if d == 0 then return false end	--collinear or disjoint
	local t = ((qx-px)*sy - (qy-py)*sx) / d
	local u = ((qx-px)*ry - (qy-py)*rx) / d
	if t < 0 or t > 1 or u < 0 or u > 1 then return false end
	return qx+u*sx,qy+u*sy
end

function boxBox(a,b)
	return a[1] < b[1]+b[3]
		and b[1] < a[1]+a[3]
		and a[2] < b[2]+b[4]
		and b[2] < a[2]+a[4]
end

function pointBox(x,y,box)
	if x > box[1] and x < box[1]+box[3] and y > box[2] and y < box[2] + box[4] then
		return true
	end
	return false
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.find(tbl,val)
	for i,v in pairs(tbl) do
		if val==v then return i end
	end
	return nil
end

function table.shuffle(tbl) 	--returns shuffled copy of table tbl
	local rt = {}
	local k = 0
	while #tbl > 0 do
		k = math.random(1,#tbl)
		table.insert(rt,tbl[k])
		table.remove(tbl,k)
	end
	return rt
end

function prev(t,key)
	local pk
	for k,v in pairs(t) do
		if key == k then
			return pk
		end
		pk = k
	end
	return pk
end

callbacks = {
	gamepadpressed = {},
	gamepadreleased = {},
	mousepressed = {},
	mousereleased = {},
	keypressed = {},
	keyreleased = {},
	textinput = {},
	resize = {},
	register = function(str,func)
		local tbl = callbacks[str]
		local id = #tbl+1
		tbl[id] = func
		return id
	end,
	clear = function()
		local cbs = callbacks
		cbs.gamepadpressed = {}
		cbs.gamepadreleased = {}
		cbs.mousepressed = {}
		cbs.mousereleased = {}
		cbs.keypressed = {}
		cbs.keyreleased = {}
		cbs.textinput = {}
		cbs.resize = {}
	end,
	unregister = function(str,id)
		local cbs = callbacks
		cbs[str][id] = nil
	end,
	set = function()
		local cbs = callbacks
		function love.gamepadpressed(joystick,button)
			for i,f in ipairs(cbs.gamepadpressed) do
				f(joystick,button)
			end
		end
		function love.gamepadreleased(joystick,button)
			for i,f in ipairs(cbs.gamepadreleased) do
				f(joystick,button)
			end
		end
		function love.mousepressed(x,y,button)
			for i,f in ipairs(cbs.mousepressed) do
				f(x,y,button)
			end
		end
		function love.mousereleased(x,y,button)
			for i,f in ipairs(cbs.mousereleased) do
				f(x,y,button)
			end
		end
		function love.keypressed(key,isrepeat)			
			for i,f in ipairs(cbs.keypressed) do
				f(key,isrepeat)
			end
		end
		function love.keyreleased(key)
			for i,f in ipairs(cbs.keyreleased) do
				f(key)
			end
		end
		function love.textinput(text)
			for i,f in ipairs(cbs.textinput) do
				f(text)
			end
		end
		function love.resize(w,h)
			sw,sh = w,h
			for i,f in ipairs(cbs.resize) do
				f(w,h)
			end
		end
	end
}


