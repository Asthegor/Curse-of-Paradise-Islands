local Menu = {}

-- Require
local Dina = require("Dina")

-- Locale variables
local MenuManager = {}
local MessageText = {}

local MenuItemSound = {}

local ImageBoat = {}
local speedBoat = 150
local flipBoat = -1

local MainFont = "datas/font/TurretRoad.ttf"
local MainFontSize = 25

-- Locales functions
local function OnSelection(Item)
  if MenuItemSound then MenuItemSound:play() end
  Item:setTextColor(Colors.LIME)
end
local function OnDeselection(Item)
  if MenuItemSound then MenuItemSound:stop() end
  Item:setTextColor(Colors.WHITE)
end
local function LaunchGame()
  Dina:setState("selection")
end
local function DisplayOptions()
  Dina:setState("options")
end
local function DisplayCredits()
  Dina:setState("credits")
end
local function Quit()
  love.event.quit(0)
end
--
local DefineController = {}
function DefineController:Gamepad()
  Dina:resetActionKeys()
  Dina:setGlobalValue("Controller", "Gamepad")
  if not Dina:getGlobalValue("Controller_Up") then Dina:setGlobalValue("Controller_Up", {"Gamepad", "lefty", -1}) end
  MenuManager:setPreviousKeys( Dina:getGlobalValue("Controller_Up") )
  if not Dina:getGlobalValue("Controller_Down") then Dina:setGlobalValue("Controller_Down", {"Gamepad", "lefty", 1}) end
  MenuManager:setNextKeys( Dina:getGlobalValue("Controller_Down") )
  if not Dina:getGlobalValue("Controller_Action") then Dina:setGlobalValue("Controller_Action", { "Gamepad", "a" }) end
  MenuManager:setValidateKeys( Dina:getGlobalValue("Controller_Action") )
  MessageText:setContent("Select Play to launch the game.")
end
function DefineController:Keyboard()
  Dina:resetActionKeys()
  Dina:setGlobalValue("Controller", "Keyboard")
  if not Dina:getGlobalValue("Controller_Up") then Dina:setGlobalValue("Controller_Up", {"Keyboard", "up"}) end
  MenuManager:setPreviousKeys( Dina:getGlobalValue("Controller_Up") )
  if not Dina:getGlobalValue("Controller_Down") then Dina:setGlobalValue("Controller_Down", {"Keyboard", "down"}) end
  MenuManager:setNextKeys( Dina:getGlobalValue("Controller_Down") )
  if not Dina:getGlobalValue("Controller_Action") then Dina:setGlobalValue("Controller_Action", { "Keyboard", "return" }) end
  MenuManager:setValidateKeys( Dina:getGlobalValue("Controller_Action") )
  MessageText:setContent("Select Play to launch the game.")
end
--

function Menu:load()
  MenuManager = Dina("MenuManager")
  MenuManager:setCtrlSpace(20)
  
  local background = MenuManager:addImage("datas/images/menu/WeeklyGameJam234_Intro.png", Dina.width/2, Dina.height/2, true)
  background:setZOrder(-100)
  ImageBoat = MenuManager:addImage("datas/images/menu/boat-6735188_640.png", 0, Dina.height * 3/4, true)
  local ibw, ibh = ImageBoat:getDimensions()
  ImageBoat:setZOrder(-50)
  ImageBoat:setFlip(flipBoat, 1)
  ImageBoat:setPosition(0 - ibw, Dina.height * 3/4)
  
  MenuManager:addItem("Play", MainFont, MainFontSize, OnSelection, OnDeselection, LaunchGame)
  MenuManager:addItem("Options", MainFont, MainFontSize, OnSelection, OnDeselection, DisplayOptions)
  MenuManager:addItem("Credits", MainFont, MainFontSize, OnSelection, OnDeselection, DisplayCredits)
  MenuManager:addItem("Quit", MainFont, MainFontSize, OnSelection, OnDeselection, Quit)
  
  local mx, my, mw, mh = MenuManager:getItemsDimensions()
  local ty = Dina.height - (Dina.height - my - mh) * 3/4
  local msg = "Press a key to activate the keyboard or a button for the gamepad"
  MessageText = Dina("Text", msg, 0, ty, Dina.width, nil, Colors.WHITE, "datas/font/SairaStencilOne-Regular.ttf", 20, "center", "center", nil, 1, 3)

  --
  local controller = Dina:getGlobalValue("Controller")
  if not controller then
    Dina:setActionKeys(DefineController, "Gamepad", "continuous", { "Gamepad", "all" })
    Dina:setActionKeys(DefineController, "Keyboard", "continuous", { "Keyboard", "all" })
  else
    DefineController[controller]()
  end
  
  -- Music
  --local music = Dina("Sound", "datas/musics/", "stream", -1, 1)
  --music:play()
  
  --Sounds
  --MenuItemSound = Dina("Sound", "datas/sounds/", "static", 1, 1)
end
--

function Menu:update(dt)
  local x, y = ImageBoat:getPosition()
  local w, h = ImageBoat:getDimensions()
  ImageBoat:setPosition(x - speedBoat * dt * flipBoat, y)
  if (flipBoat > 0 and x < 0 - w*2) or (flipBoat < 0 and x > Dina.width + w) then
    flipBoat = 0 - flipBoat
    ImageBoat:setFlip(flipBoat, 1)
  end
  
  Dina:update(dt, false)
end
--
function Menu:draw()
  Dina:draw(false)
end

return Menu