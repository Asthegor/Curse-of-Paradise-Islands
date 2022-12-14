local Select = {}

-- Require
local Dina = require("Dina")

-- Constantes
local MainFont = "datas/font/TurretRoad.ttf"
local MainFontSize = 25

-- Local variables
local DefineController = {}

local SelectionMenu = {}
local MessageText = {}

local MenuItemSound = {}
local pressMenuButton = {}
local music = {}

-- Local functions
local function LaunchGame(PlayerType)
  music:stop()
  pressMenuButton:play()
  Dina:setGlobalValue("Player_Type", PlayerType)
  if Dina:getGlobalValue("Skip_Intro") then
    Dina:setState("game")
  else
    Dina:setState("intro")
  end
end
local function OnSelection(Item)
  if next(MenuItemSound) then MenuItemSound:play() end
  Item:setTextColor(Colors.LIME)
end
local function OnDeselection(Item)
  if next(MenuItemSound) then MenuItemSound:stop() end
  Item:setTextColor(Colors.WHITE)
end
local function SelectExplorer()
  LaunchGame("Explorer")
end
local function SelectBotanist()
  LaunchGame("Botanist")
end
local function SelectSoldier()
  LaunchGame("Soldier")
end
local function GetImagePosition(Item, Image)
  local itw, ith = Item:getDimensions()
  local itx, ity = Item:getPosition()
  local imw, imh = Image:getDimensions()
  
  local x = itx + (itw - imw) / 2
  local y = ity - imh
  return x, y
end
--

function DefineController:Gamepad()
  Dina:resetActionKeys()
  if not Dina:getGlobalValue("Controller_Left") then Dina:setGlobalValue("Controller_Left", {"Gamepad", "leftx", -1}) end
  SelectionMenu:setPreviousKeys( Dina:getGlobalValue("Controller_Left") )
  if not Dina:getGlobalValue("Controller_Right") then Dina:setGlobalValue("Controller_Right", {"Gamepad", "leftx", 1}) end
  SelectionMenu:setNextKeys( Dina:getGlobalValue("Controller_Right") )
  if not Dina:getGlobalValue("Controller_Action") then Dina:setGlobalValue("Controller_Action", { "Gamepad", "a" }) end
  SelectionMenu:setValidateKeys( Dina:getGlobalValue("Controller_Action") )
end
function DefineController:Keyboard()
  if not Dina:getGlobalValue("Controller_Left") then Dina:setGlobalValue("Controller_Left", {"Keyboard", "left"}) end
  SelectionMenu:setPreviousKeys( Dina:getGlobalValue("Controller_Left") )
  if not Dina:getGlobalValue("Controller_Right") then Dina:setGlobalValue("Controller_Right", {"Keyboard", "right"}) end
  SelectionMenu:setNextKeys( Dina:getGlobalValue("Controller_Right") )
  if not Dina:getGlobalValue("Controller_Action") then Dina:setGlobalValue("Controller_Action", { "Keyboard", "return" }) end
  SelectionMenu:setValidateKeys( Dina:getGlobalValue("Controller_Action") )
end
--


function Select:load()
  local x, y
  SelectionMenu = Dina("MenuManager")
  SelectionMenu:setCtrlSpace(20)

  SelectionMenu:addTitle("Select the type of navigator", 100, MainFont, 50, Colors.WHITE)
  local explorer = SelectionMenu:addItem("Explorer", MainFont, MainFontSize, OnSelection, OnDeselection, SelectExplorer)
  local botanist = SelectionMenu:addItem("Botanist", MainFont, MainFontSize, OnSelection, OnDeselection, SelectBotanist)
  local soldier = SelectionMenu:addItem("Soldier", MainFont, MainFontSize, OnSelection, OnDeselection, SelectSoldier)
  SelectionMenu:setItemsDimensions(Dina.width, Dina.height / 4, "horizontal")
  
  local imgExplorer = SelectionMenu:addImage("datas/images/game/Explorer.png", 0, 0)
  x, y = GetImagePosition(explorer, imgExplorer)
  imgExplorer:setPosition(x, y)

  local imgBotanist = SelectionMenu:addImage("datas/images/game/Botanist.png")
  x, y = GetImagePosition(botanist, imgBotanist)
  imgBotanist:setPosition(x, y)
  
  local imgSoldier = SelectionMenu:addImage("datas/images/game/Soldier.png")
  x, y = GetImagePosition(soldier, imgSoldier)
  imgSoldier:setPosition(x, y)
  
  local rnd = love.math.random(1,3)
  for i = 1, rnd do
    SelectionMenu:nextItem()
  end
  
  local mx, my, mw, mh = SelectionMenu:getItemsDimensions()
  local ty = Dina.height - (Dina.height - my - mh) * 3/4

  local msg = "Press '".. Dina:getGlobalValue("Controller_Action")[2] .."' to launch the game."
  MessageText = Dina("Text", msg, 0, ty, Dina.width, nil, Colors.WHITE, "datas/font/SairaStencilOne-Regular.ttf", 20, "center", "center", nil, 1, 3)
  
  DefineController[Dina:getGlobalValue("Controller")]()
  
  -- Music
  music = Dina("Sound", "datas/audio/music/characterSelect.mp3", "stream", -1, 0.7)
  music:play()
  
  -- Sounds
  MenuItemSound = Dina("Sound", "datas/audio/soundeffects/menuLightUp3.mp3", "static", 1, 0.3)
  pressMenuButton = Dina("Sound", "datas/audio/soundeffects/menuButtonPress.mp3", "static", 1, 0.3)
end

function Select:update(dt)
  Dina:update(dt, false)
end
--
function Select:draw()
  Dina:draw(false)
end
--
return Select