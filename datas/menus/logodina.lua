local LogoDina = {}

local Dina = require("Dina")

local timer = 0
local wait = 1
local delay = 2
local color = {1,1,1,1}
local text = {}

function LogoDina.load()
  local logo = Dina("Image", "datas/images/logo/Dina_Logo.png")
  logo:setPosition(Dina.width / 2, Dina.height / 2)
  logo:centerOrigin()
  text = Dina("Text", "dina.lacombedominique.com", 0, Dina.height * 3/4, Dina.width, 50, Colors.WHITE, "datas/font/SairaStencilOne-Regular.ttf", 25, "center", "center")
end

function LogoDina:update(dt)
  timer = timer + dt
  if timer >= wait and timer <= delay then
    color[4] = color[4] - dt
    if color[4] < 0 then color[4] = 0 end
    text:setTextColor(color)
  end
  if timer > delay then
    self:toMenu()
    timer = 0
    return
  end
  Dina:update(dt, false)
end

function LogoDina:draw()
  love.graphics.setColor(color)
  Dina:draw(false)
end

function LogoDina:toMenu()
  if timer >= wait then
    Dina:setState("menu")
  end
end

return LogoDina