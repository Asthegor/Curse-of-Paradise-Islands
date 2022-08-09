local LogoWG = {}

-- Require
local Dina = require("Dina")

-- Local variables
local timer = 0
local wait = 1
local delay = 2
local color = {1,1,1,1}


function LogoWG.load()
  local Logo = Dina("Image", "datas/images/logo/WeeklyGameJam.png")
  Logo:setPosition(Dina.width / 2, Dina.height / 2)
  Logo:centerOrigin()
  timer = 0
end
--
function LogoWG:update(dt)
  timer = timer + dt
  if timer >= wait and timer <= delay then
    color[4] = color[4] - dt
    if color[4] < 0 then color[4] = 0 end
  end
  if timer > delay then
    self:toMenu()
    timer = 0
  end
  Dina:update(dt, false)
end
--
function LogoWG:draw()
  love.graphics.setColor(color)
  Dina:draw(false)
end
--
function LogoWG:toMenu()
  if timer >= wait then
    Dina:setState("logodina")
  end
end
--
return LogoWG