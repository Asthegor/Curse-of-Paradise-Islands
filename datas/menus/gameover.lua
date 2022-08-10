local GameOver = {}

-- Require
local Dina = require("Dina")

-- Constantes
local MainFont = "datas/font/SairaStencilOne-Regular.ttf"

-- Locale variables
local music = {}
local pressMenuButton = {}

function GameOver:load()
  local title = Dina("Text", "Game Over", 0, 0, nil, nil, Colors.WHITE, MainFont, 80)
  local tw, th = title:getDimensions()
  title:setPosition((Dina.width - tw) / 2, (Dina.height - th) / 2)
  
  local controllerAction = Dina:getGlobalValue("Controller_Action")
  local msg = "Press '" .. controllerAction[2] .. "' to return to the menu."
  Dina("Text", msg, 0, Dina.height / 2, Dina.width, Dina.height / 2, Colors.WHITE, MainFont, 25, "center", "center", 0, 1, 3, -1)
  
  Dina:setActionKeys(GameOver, "ToMenu", "pressed", controllerAction)
  
  -- Music
  music = Dina("Sound", "datas/audio/music/gameOver.mp3", "stream", 0.7, 0.7)
  music:play()

  pressMenuButton = Dina("Sound", "datas/audio/soundeffects/menuButtonPress", "stream", 1, 0.3)
end
--
function GameOver:update(dt)
  Dina:update(dt, false)
end
--
function GameOver:draw()
  Dina:draw(false)
end
--
function GameOver:ToMenu()
  music:stop()
  pressMenuButton.play()
  Dina:setState("menu")
end
--
return GameOver