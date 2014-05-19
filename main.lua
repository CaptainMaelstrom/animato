
require 'scripts/libs/serializeTable'
tween = require 'scripts/libs/tween'
require 'scripts/helpers'
require 'scripts/aliases'

function love.load()
	flags = {}
	fnt.bigFont = lg.newFont(36)
	fnt.medFont = lg.newFont(14)
	sw,sh = love.window.getDimensions()
	mx,my,lx,ly = 0,0,0,0
	initParts()
	keyframes = {}
	numberLine = {'1','2','3','4','5','6','7','8','9','0'}
	anim = {
		state = "paused",
		timer = 0,
		tweens = {},
		lastLoadedKeyframe = 0,
		finalTime = function()
			local sum = 0
			for i,v in ipairs(keyframes) do
				if i~=#keyframes then sum = sum+v.length end
			end
			return sum/1000
		end,
		loadKeyframe = function(index)
			--adjust anim.timer
			anim.timer = 0
			for i,f in ipairs(keyframes) do
				if index > i then
					anim.timer = anim.timer+f.length/1000
				end
			end
			--empty parts out and put keyframe contents in
			parts = {}
			tween.stopAll()
			anim.tweens = {}
			for i,p in ipairs(keyframes[index]) do
				local kf1 = keyframes[index]
				local kf2 = keyframes[index+1]
				parts[#parts+1] = table.deepcopy(p)
				if #keyframes >= index+1 then
					if #kf2[i]~=#kf1[i] then error("A part is missing from one keyframe to the next.") end
					anim.tweens[#anim.tweens+1] = tween(kf1.length/1000,parts[#parts].tbl,kf2[i].tbl,easings[kf1.easing],function() anim.loadKeyframe(index+1) end)
				else
					if smoothLoop and #keyframes > 1 then
						local kf2 = keyframes[1]
						anim.tweens[#anim.tweens+1] = tween(kf1.length/1000,parts[#parts].tbl,kf2[i].tbl,easings[kf1.easing],function() if anim.loop then anim.loadKeyframe(1) else anim.timer = 0 anim.state = 'paused' end end)
					else
						if anim.loop then
							anim.loadKeyframe(1)
						else
							anim.state = 'paused'
						end
					end
				end
			end
			anim.lastLoadedKeyframe = index
		end,
		update = function(dt)
			if anim.state=='playing' then
				if anim.timer==0 then
					if #keyframes >=1 then anim.loadKeyframe(1) end
				end
				if anim.timer > anim.finalTime() and #keyframes >= 1 and not smoothLoop then
					anim.loadKeyframe(1)
					anim.timer = 0
				end
				anim.timer = anim.timer+dt
				tween.update(dt)
			elseif anim.state=='stopped' then
				anim.timer = 0
			end
		end
	}
	easings = {
		'linear',
		'inQuad','outQuad','inOutQuad','outInQuad',
		'inCubic','outCubic','inOutCubic','outInCubic',
		'inQuart','outQuart','inOutQuart','outInQuart',
		'inQuint','outQuint','inOutQuint','outInQuint',
		'inSine','outSine','inOutSine','outInSine',
		'inExpo','outExpo','inOutExpo','outInExpo',
		'inCirc','outCirc','inOutCirc','outInCirc',
		'inElastic','outElastic','inOutElastic','outInElastic',
		'inBounce','outBounce','inOutBounce','outInBounce',
		'inBack','outBack','inOutBack','outInBack'
	}
	help = {
		{"","Mouse Controls"},
		{"Left click", "Select active part or active keyframe"},
		{"Click and drag", "Move active part (hold ctrl for smaller changes)"},
		{"Mouse wheel", "Change scale"},
		{"Shift+Drag", "Rotate part"},
		{"",""},
		{"","Keyboard Shortcuts"},
		{'Esc, Esc', "Closes Animato"},
		{"D","Duplicate part"},
		{"Backspace", "Remove active part"},
		{"Delete", "Remove active keyframe"},
		{"N", "New draw order"},
		{"M", "Set draw order"},
		{"B", "See/Hide bounding boxes"},
		{"P", "Play/Pause"},
		{"L", "Toggle looping"},
		{"Ctrl+L", "Toggle smoothing (last keyframe tweens to first)"},
		{"S", "Stop"},
		{"Ctrl+S", "Save animation"},
		{"Ctrl+O", "Load keyframes from an animation"},
		{"F", "Toggle fullscreen"},
		{"Up arrow", "Change active keyframe's easing function"},
		{"Down", "Change easing function"},
		{"Left", "Change easing function"},
		{"Right", "Change easing function"},
		{"Keypad 0", "Change keyframe easing to 'linear'"},
		{"Tab", "Cycle through active parts (shift to cycle backwards)"}
	}
end

function love.update(dt)
	mx,my = lmo.getPosition()
	local dx,dy = mx-lx,my-ly
	if lk.isDown('lctrl') or lk.isDown('rctrl') then ctrlMod = true else ctrlMod = nil end
	if lk.isDown('lshift') or lk.isDown('rshift') then shiftMod = true else shiftMod = nil end
	if lk.isDown(' ') then showHelp = true else showHelp = nil end
	if lk.isDown('a') then		--move all
		for i,p in ipairs(parts) do
			movePart(p,dx,dy)
		end
	else
		if heldPart then
			local p = parts[heldPart]
			movePart(p,dx,dy)
		end
		if rotPart then
			local p = parts[rotPart]
			local newRot = (dx+dy)/100
			if not ctrlMod then
				p.tbl.rot = p.tbl.rot + newRot
			else
				p.tbl.rot = p.tbl.rot + newRot/4
			end
		end
	end
	anim.update(dt)
	lx,ly = mx,my
	flags[1] = activePart
end

function love.draw()
	lg.setColor(80,80,80)
	lg.setFont(fnt.default)
	lg.print("Hold space bar for instructions",sw/2-fnt.default:getWidth("Hold space bar for instructions")/2, sh-16)
	lg.setColor(200,200,200)
	--translate coord system so when table.save writes to file, the parts are close to 0, but they are drawn here close to the center of the screen
	lg.push()
		lg.translate(sw/2,sh-150)
		lg.line(-75,0,75,0)
		lg.setPointSize(5)
		lg.point(0,0)
		drawParts()
	lg.pop()
	drawKeyframes()
	drawAnimState()
	lg.setColor(white)
	lg.setFont(fnt.medFont)
	lg.print(tostring(anim.timer):sub(1,6),10,sh-110)
	
	if showHelp then
		lg.setColor(0,0,0,240)
		lg.rectangle('fill',0,0,sw,sh)
		lg.setFont(fnt.medFont)
		lg.setColor(white)
		for i,tbl in ipairs(help) do
			lg.print(tbl[1],20,18*i)
			lg.print(tbl[2],200,18*i)
		end
	end
	lg.setColor(white)
	lg.setFont(fnt.medFont)
	for i,f in ipairs(flags) do
		lg.print(f,200,18*i)
	end
	if nameBuffer then lg.print("Enter a name for the animation: " .. nameBuffer, 20,80) end
	if newLength then lg.print(newLength,400,20) end
end

function love.keypressed(key,isrepeat)
	if nameBuffer then
		if key=='return' then
			anim.name = nameBuffer
			if saveWaiting then saveAnimation() saveWaiting = nil end
			if loadWaiting then loadAnimation() loadWaiting = nil end
			nameBuffer = nil
		end
		if key=='backspace' then
			if nameBuffer~=nil then nameBuffer = nameBuffer:sub(1,-2) end
		end
	else
		if activeKeyframe then
			inputToKeyframe(key)
		end
		if key=='escape' then
			if die then love.event.quit() end
			die = true
		else
			die = nil
		end
		if key=='d' then
			if activePart then
				local p = table.deepcopy(parts[activePart])
				p.tbl.x = p.tbl.x + 80
				parts[#parts+1] = p
				drawOrder[#drawOrder+1] = #parts
			end
		elseif key=='f' then
			if not lw.getFullscreen() then lw.setFullscreen(true, 'desktop') else lw.setFullscreen(false) end
		elseif key=='backspace' then
			if activePart then removePart(activePart) end
		elseif key=='delete' then
			if activeKeyframe then removeKeyframe() end
		elseif key=='home' then
			initParts()
		elseif key=='k' then
			newKeyframe()
			activeKeyframe = nil
		elseif key=='n' then
			drawOrder2 = {}
		elseif key=='m' then
			drawOrder = drawOrder2
			drawOrder2 = nil
		elseif key=='b' then
			if noBoxes then noBoxes = nil else noBoxes = true end
		elseif key=='p' then
			if anim.state=='playing' then anim.state = 'paused' else anim.state = 'playing' end
		elseif key=='l' then
			if ctrlMod then
				if not smoothLoop then smoothLoop = true else smoothLoop = nil end
			else
				if anim.loop then anim.loop = nil else anim.loop = true end
			end
		elseif key=='s' then
			if not ctrlMod then
				if #keyframes~=0 then anim.loadKeyframe(1) end
				anim.timer = 0
				anim.state = 'stopped'
			else
				saveWaiting = true
				loadWaiting = nil
				nameBuffer = anim.name or ''
			end
		elseif key=='o' and ctrlMod then
			saveWaiting = nil
			loadWaiting = true
			nameBuffer = ''
		elseif key=='up' then
			if activeKeyframe then keyframes[activeKeyframe].easing = (keyframes[activeKeyframe].easing + 1)%41 end
		elseif key=='down' then
			if activeKeyframe then keyframes[activeKeyframe].easing = (keyframes[activeKeyframe].easing - 1)%41 end
		elseif key=='left' then
			if activeKeyframe then keyframes[activeKeyframe].easing = (keyframes[activeKeyframe].easing - 4)%41 end
		elseif key=='right' then
			if activeKeyframe then keyframes[activeKeyframe].easing = (keyframes[activeKeyframe].easing + 4)%41 end
		elseif key=='kp0' then
			if activeKeyframe then keyframes[activeKeyframe].easing = 1 end
		elseif key=='tab' and #parts >= 1 then
			if not activePart then activePart = 1 else
				if shiftMod then
					activePart = activePart - 1
					if activePart == 0 then activePart = #parts end
				else
					activePart = activePart + 1
					if activePart > #parts then activePart = 1 end
				end
			end
		end
		if activeKeyframe then
			if keyframes[activeKeyframe].easing == 0 then keyframes[activeKeyframe].easing = 1 end
		end
	end
end

function love.textinput(t)
	if nameBuffer then nameBuffer = nameBuffer .. t end
end

function love.mousepressed(mx,my,button)
	--select activePart
	if not activePart then
		for i,p in ipairs(parts) do
			if pointBox(mx,my,{p.tbl.x-p.ox*p.tbl.sx+sw/2,p.tbl.y-p.oy*p.tbl.sy+(sh-150),p.w*p.tbl.sx,p.h*p.tbl.sy}) then
				activePart = i
			end
		end
	else
		local ap = parts[activePart]
		if not pointBox(mx,my,{ap.tbl.x-ap.ox*ap.tbl.sx+sw/2,ap.tbl.y-ap.oy*ap.tbl.sy+(sh-150),ap.w*ap.tbl.sx,ap.h*ap.tbl.sy}) then
			for i,p in ipairs(parts) do
				if pointBox(mx,my,{p.tbl.x-p.ox*p.tbl.sx+sw/2,p.tbl.y-p.oy*p.tbl.sy+(sh-150),p.w*p.tbl.sx,p.h*p.tbl.sy}) then
					activePart = i
				end
			end
		end
	end
	if activePart then mouseToPart(activePart,button) end
	
	--select keyframe
	for i,kf in ipairs(keyframes) do
		if pointBox(mx,my,{10+90*(i-1),sh-30,20,25}) then
			activeKeyframe = i
			anim.loadKeyframe(i)
			activePart = nil
		end
	end
end

function love.mousereleased(x,y,button)
	heldPart = nil
	rotPart = nil
end

function initParts()
	parts = {}
	drawOrder = {}
	local xoff = 0
	for n,i in pairs(img) do
		local part = {}
		part.tbl = {}
		part.name = n
		if #parts==0 then
			part.w,part.h = i:getDimensions()
			part.tbl.x = part.w/8-(sw/2)
			part.tbl.y = part.h/8-(sh-150)
		else
			local last = parts[#parts]
			part.w,part.h = i:getDimensions()
			part.tbl.x = part.w/8 + xoff - (sw/2)
			part.tbl.y = last.tbl.y + part.h/4
			if part.tbl.y+last.h/4 > sh then
				xoff = xoff+100
				part.tbl.x = part.w/8 + xoff - (sw/2)
				part.tbl.y = 0 + part.h/8
			end
		end
		part.tbl.sx = 0.25
		part.tbl.sy = 0.25
		part.tbl.rot = 0
		part.ox,part.oy = part.w/2,part.h/2
		parts[#parts+1] = part
		drawOrder[#drawOrder+1] = #drawOrder+1
	end
end

function movePart(p,dx,dy)
	if not ctrlMod then
		p.tbl.x = p.tbl.x + dx
		p.tbl.y = p.tbl.y + dy
	else
		p.tbl.x = p.tbl.x + dx/4
		p.tbl.y = p.tbl.y + dy/4
	end
end

function removePart(ind)
	table.remove(parts,ind)
	local dind = table.find(drawOrder,ind)
	local j = dind
	while dind do
		table.remove(drawOrder,dind)
		dind = table.find(drawOrder,ind)
	end
	for i,v in ipairs(drawOrder) do
		if i >= j then drawOrder[i] = v-1 end
	end
end

function newKeyframe()
	local kf = table.deepcopy(parts)	--keyframe starts with copy of parts
	kf.easing = 1
	kf.length = 400 						--400 ms is the default time
	if activeKeyframe then
		if activeKeyframe==#keyframes then
			table.insert(keyframes,kf)
		else
			keyframes[activeKeyframe] = kf
		end
	else
		table.insert(keyframes,kf)
	end
end

function drawParts()
	for i = 1,#drawOrder do
		local p = parts[drawOrder[i]]
		lg.setColor(white)
		if drawOrder2 then lg.setColor(255,255,255,100) end
		lg.draw(img[p.name],p.tbl.x,p.tbl.y,p.tbl.rot,p.tbl.sx,p.tbl.sy,p.ox,p.oy)
		if not noBoxes then
			lg.setColor(120,120,120,128)
			if activePart then if activePart==drawOrder[i] then lg.setColor(255,255,255,148) end end
			lg.push()
				lg.translate(p.tbl.x,p.tbl.y)
				lg.rotate(p.tbl.rot)
				-- lg.rectangle('line',p.tbl.x-p.ox*p.tbl.sx,p.tbl.y-p.oy*p.tbl.sy,p.w*p.tbl.sx,p.h*p.tbl.sy)
				lg.rectangle('line',-p.w*p.tbl.sx/2,-p.h*p.tbl.sy/2,p.w*p.tbl.sx,p.h*p.tbl.sy)
			lg.pop()
		end
	end
	if drawOrder2 then
		for i = 1,#drawOrder2 do
			local p = parts[drawOrder2[i]]
			lg.setColor(white)
			lg.draw(img[p.name],p.tbl.x,p.tbl.y,p.tbl.rot,p.tbl.sx,p.tbl.sy,p.ox,p.oy)
		end
	end
end

function drawKeyframes()
	for i,kf in ipairs(keyframes) do
		lg.setColor(120,20,160)
		if activeKeyframe==i then lg.setColor(210,80,250) end
		lg.rectangle('fill',10+(i-1)*90,sh-30,20,25)
		lg.setFont(fnt.default)
		lg.print(tostring(i),10+(i-1)*90,sh-46)
		if i~=#keyframes then
			lg.setColor(60,10,80)
			lg.rectangle('line',30+90*(i-1),sh-30,70,25)
			lg.print(easings[kf.easing], 40+90*(i-1),sh-30)
			lg.print(kf.length .. 'ms',40+90*(i-1),sh-18)
		end
	end
end

function drawAnimState()
	if anim.state=='playing' then
		lg.setColor(10,240,25)
		lg.polygon('fill',10,sh-50,10,sh-80,40,sh-65)
	elseif anim.state=='stopped' then
		lg.setColor(220,20,15)
		lg.rectangle('fill',10,sh-80,25,25)
	else
		lg.setColor(115,115,215)
		lg.rectangle('fill',10,sh-80,8,30)
		lg.rectangle('fill',25,sh-80,8,30)
	end
	if anim.loop then
		lg.setColor(200,200,200)
		lg.circle('fill',70,sh-65,18,28)
		lg.setColor(black)
		lg.circle('fill',70,sh-65,12,28)
		lg.rectangle('fill',62,sh-65,16,25)
		lg.setColor(200,200,200)
		lg.polygon('fill',70,sh-65,90,sh-45,70,sh-45)
	end
	if smoothLoop then
		lg.setColor(white)
		lg.setFont(fnt.bigFont)
		lg.print('S',105,sh-85)
	end
end

function removeKeyframe()
	anim.timer = 0
	anim.state = 'stopped'
	table.remove(keyframes,activeKeyframe)
	activeKeyframe = nil
end

function saveAnimation()
	if not lfs.exists('animations') then lfs.createDirectory('animations') end
	if not anim.name then anim.name = 'untitled' end
	if anim.name=='' then anim.name = 'untitled' end
	table.save(keyframes,anim.name .. '.anm')
end

function loadAnimation()
	local flag = io.open(anim.name .. ".anm")
	if flag then
		keyframes = table.load(anim.name .. ".anm")
	end
end

function inputToKeyframe(key)
	if table.find(numberLine,key) then
		if not newLength then newLength = key else newLength = newLength .. key end
	end
	if key=='return' and newLength then
		keyframes[activeKeyframe].length = tonumber(newLength)
		newLength = nil
	end
	if key=='backspace' then
		if newLength then
			if newLength:len() > 1 then 
				newLength = newLength:sub(1,-2)
			else
				newLength = nil
			end
		end
	end
end

function love.resize(swv,shv)
	sw = swv
	sh = shv
end

function mouseToPart(ind,button)
	local p = parts[ind]
	if drawOrder2 then
		drawOrder2[#drawOrder2+1] = ind
	else
		if button=='l' then
			if not shiftMod then
				heldPart = ind
			else
				rotPart = ind
				heldPart = nil
			end
		end
		if button=='m' then
			p.tbl.sx = 0.25
			p.tbl.sy = 0.25
		end
		if button =='wd' then
			if ctrlMod then
				p.tbl.sx = p.tbl.sx - 0.01
				p.tbl.sy = p.tbl.sy - 0.01
			else
				p.tbl.sx = p.tbl.sx - 0.05
				p.tbl.sy = p.tbl.sy - 0.05
			end
		elseif button=='wu' then
			if ctrlMod then
				p.tbl.sx = p.tbl.sx + 0.01
				p.tbl.sy = p.tbl.sy + 0.01
			else
				p.tbl.sx = p.tbl.sx + 0.05
				p.tbl.sy = p.tbl.sy + 0.05
			end
		end
	end
end





