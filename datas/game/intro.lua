local Intro = {}

-- Require
local Dina = require("Dina")

-- Locale variables
local MainFont = "datas/font/SairaStencilOne-Regular.ttf"

function Intro:load()
  Dina:resetActionKeys()
  
  local controller = Dina:getGlobalValue("Controller")
  local controllerAction = Dina:getGlobalValue("Controller_Action")
  Dina:setActionKeys(Intro, "ToGame", "pressed", controllerAction)
  
  Dina("Text", "Objectives", 0, 20, Dina.width, 50, Colors.WHITE, MainFont, 50, "center", "center")
  
  
  local image = Dina("Image", "datas/images/brush_pres.png", Dina.width / 2, Dina.height / 2)
  image:centerOrigin()
  local ix, iy = image:getPosition()
  local iw, ih = image:getDimensions()
  
  local twmax = iw/3 - 5
  local text1 = Dina("Text", "1- Some colored bricks are falling for the top.", 0, 0, twmax, 100, Colors.WHITE, MainFont, 15)
  local t1h = text1:getTextHeight()
  
  local text2 = Dina("Text", "2- With your brush, you paint them in white.", 0, 0, twmax, 100, Colors.WHITE, MainFont, 15)
  local t2h = text2:getTextHeight()
  
  local text3 = Dina("Text", "3- And you must collect them to increase the timer.", 0, 0, twmax, 100, Colors.WHITE, MainFont, 15)
  local t3h = text3:getTextHeight()
  local t3w = text3:getTextWidth()
  
  local th = t1h
  if th < t2h then th = t2h end
  if th < t3h then th = t3h end
  text1:setPosition(ix - iw/2, iy - ih/2 - th)
  text2:setPosition(ix - twmax/2, iy - ih/2 - th)
  text3:setPosition(ix + iw/2 - twmax, iy - ih/2 - th)
  
  local msg = "Press '" .. controllerAction[2] .. "' to play."
  Dina("Text", msg, 0, Dina.height - 150, Dina.width, 20, Colors.WHITE, MainFont, 20, "center", "center", 0, 1, 3, -1)
  
  Dina:setGlobalValue("Skip_Intro", true)
end
--
function Intro:update(dt)
  Dina:update(dt, false)
end
--
function Intro:draw()
  Dina:draw(false)
end
--
function Intro:ToGame()
  Dina:setState("game")
end

--Intro.__index = Intro
return Intro