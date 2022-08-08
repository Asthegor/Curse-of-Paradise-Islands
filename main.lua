-- The lines below is used for debugging.
if arg[#arg] == "-debug" then require("mobdebug").start() end
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")


-- Dina Game Engine
local Dina = require('Dina')

function love.load()
  Dina:addState("logowg", "datas/menus/logowg")
  Dina:addState("logodina", "datas/menus/logodina")
  Dina:addState("menu", "datas/menus/menu")
  Dina:addState("options", "datas/menus/options")
--  Dina:addState("credits", "datas/menus/credits")
--  Dina:addState("intro", "datas/game/intro")
  Dina:addState("selection", "datas/game/select")
  Dina:addState("game", "datas/game/game")
  Dina:addState("victory", "datas/menus/victory")
  Dina:addState("gameover", "datas/menus/gameover")

  Dina:setGlobalValue("Skip_Intro", true)

  Dina:setState("logowg")
--  Dina:setState("game")
end
--
function love.update(dt)
  Dina:update(dt)
end
--

function love.draw()
  Dina:draw()
end
--