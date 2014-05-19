--aliases (helper variables)

lg = love.graphics
la = love.audio
lfs = love.filesystem
li = love.image
lm = love.math
lmo = love.mouse
lf = love.font
lk = love.keyboard
lt = love.timer
lw = love.window
lj = love.joystick

-- lw.setMode()

sw = love.window.getWidth()
sh = love.window.getHeight()

math.randomseed(os.time())
math.random()
math.random()
math.random()
lm.setRandomSeed(os.time())
lm.random()
lm.random()
lm.random()

-- class = middleclass.class

white = {255,255,255}
black = {0,0,0}

crs = {}
img = {}
fnt = {}
snd = {}
loadResources(img,"images")
loadResources(fnt,"fonts")
loadResources(snd,"sounds	")

fnt.default = lg.getFont()