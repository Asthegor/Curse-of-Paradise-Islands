local Victory = {}

-- Require
local Dina = require("Dina")

-- Locale variables
local MainFont = "datas/font/SairaStencilOne-Regular.ttf"

function Victory:load()
  -- Title
  local title = Dina("Text", "Victory", 0, 0, nil, nil, Colors.WHITE, MainFont, 80)
  local tw, th = title:getDimensions()
  title:setPosition((Dina.width - tw) / 2, Dina.height / 4)
  
  -- Thanks
  local thanks = Dina("Text", "Thanks for playing my game!", 0, 0, nil, nil, Colors.WHITE, MainFont, 40)
  local thw, thh = thanks:getDimensions()
  thanks:setPosition((Dina.width - thw) / 2, Dina.height / 2)
  
  -- Message "Key/Button to return to menu"
  local controllerAction = Dina:getGlobalValue("Controller_Action")
  local msg = "Press '" .. controllerAction[2] .. "' to return to the menu."
  Dina("Text", msg, 0, Dina.height / 2, Dina.width, Dina.height / 2, Colors.WHITE, MainFont, 25, "center", "center", 0, 1, 3, -1)
  
  -- Action after pressing key/button
  Dina:setActionKeys(Victory, "ToMenu", "pressed", controllerAction)
  
  -- Music
  --local music = Dina("Sound", "datas/musics/", "stream", -1, 1)
  --music:play()
end
--
function Victory:update(dt)
  Dina:update(dt, false)
end
--
function Victory:draw()
  Dina:draw(false)
end
--
function Victory:ToMenu()
  Dina:setState("menu")
end

return Victory