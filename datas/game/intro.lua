local Intro = {}

-- Require
local Dina = require("Dina")

-- Locale variables

function Intro:load()
  Dina:resetActionKeys()
  
  local controller = Dina:getGlobalValue("Controller")
  local controllerAction = Dina:getGlobalValue("Controller_Action")
  Dina:setActionKeys(Intro, "ToGame", "pressed", controllerAction)
  
  
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