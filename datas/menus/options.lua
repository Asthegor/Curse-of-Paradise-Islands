local Options = {}

-- Require
local Dina = require("Dina")

-- Locale variables
local MainFont = "datas/font/TurretRoad.ttf"
local MainFontSize = 25

local MenuManager = {}
local ValueManager = {}

local ButtonChange = {}
local MenuItemCtrl = {}
local MenuItemCtrlUp = {}
local MenuItemCtrlDown = {}
local MenuItemCtrlLeft = {}
local MenuItemCtrlRight = {}
local MenuItemCtrlAction = {}
local MenuItemCtrlPause = {}

local MenuItemSound = {}
local pressMenuButton = {}

-- Local functions
local function OnSelection(Item)
  if next(MenuItemSound) then MenuItemSound:play() end
  Item:setTextColor(Colors.LIME)
end
local function OnDeselection(Item)
  if next(MenuItemSound) then MenuItemSound:stop() end
  Item:setTextColor(Colors.WHITE)
end
local function RefreshMenuItems()
  local itemName = Dina:getGlobalValue("Controller")
  MenuItemCtrl:setContent(itemName)
  itemName = Dina:getGlobalValue("Controller_Up")
  MenuItemCtrlUp:setContent(itemName[2] .. (itemName[3] and " "..itemName[3] or ""))
  itemName = Dina:getGlobalValue("Controller_Down")
  MenuItemCtrlDown:setContent(itemName[2] .. (itemName[3] and " "..itemName[3] or ""))
  itemName = Dina:getGlobalValue("Controller_Left")
  MenuItemCtrlLeft:setContent(itemName[2] .. (itemName[3] and " "..itemName[3] or ""))
  itemName = Dina:getGlobalValue("Controller_Right")
  MenuItemCtrlRight:setContent(itemName[2] .. (itemName[3] and " "..itemName[3] or ""))
  itemName = Dina:getGlobalValue("Controller_Action")
  MenuItemCtrlAction:setContent(itemName[2])
  itemName = Dina:getGlobalValue("Controller_Pause")
  MenuItemCtrlPause:setContent(itemName[2])
  local vw, vh = ValueManager:getItemsDimensions()
  ValueManager:setItemsDimensions(Dina.width * 2/5, vh, "vertical", true)
end
--

local ChangeKey = {}
function ChangeKey:Up(dir, dt, keybtn)
  self:SetMenuKeys("Up", keybtn, dir)
end
function ChangeKey:Down(dir, dt, keybtn)
  self:SetMenuKeys("Down", keybtn, dir)
end
function ChangeKey:Left(dir, dt, keybtn)
  self:SetMenuKeys("Left", keybtn, dir)
end
function ChangeKey:Right(dir, dt, keybtn)
  self:SetMenuKeys("Right", keybtn, dir)
end
function ChangeKey:Action(dir, dt, keybtn)
  self:SetMenuKeys("Action", keybtn)
end
function ChangeKey:Pause(dir, dt, keybtn)
  self:SetMenuKeys("Pause", keybtn)
end
function ChangeKey:SetMenuKeys(Item, KeyBtn, Dir)
  local controller = Dina:getGlobalValue("Controller")
  if KeyBtn ~= Dina:getGlobalValue("Controller_Action")[2] then
    if Dir then
      Dina:setGlobalValue("Controller_"..Item, { controller, KeyBtn, Dir })
    else
      Dina:setGlobalValue("Controller_"..Item, { controller, KeyBtn })
    end
  end
  DefineController[controller](DefineController, MenuManager)
  RefreshMenuItems()
  Dina:removeComponent(ButtonChange)
end
function ChangeKey:DisplayMsg(KeyName)
  local msg = ""
  if string.lower(Dina:getGlobalValue("Controller")) == "gamepad" then
    msg = "Press a button to set the " .. KeyName .. " button."
  elseif string.lower(Dina:getGlobalValue("Controller")) == "keyboard" then
    msg = "Press a key to set the " .. KeyName .. " key."
  end
  local x = (Dina.width - Dina.width/4) / 2
  local y = (Dina.height - Dina.height/4) / 2
  ButtonChange = Dina("Button", x, y, Dina.width/4, Dina.height/4, msg, MainFont, MainFontSize, Colors.WHITE, Colors.GRAY, 10)
end
local function ChangeController()
  if string.lower(Dina:getGlobalValue("Controller")) == "keyboard" then
    Dina:setGlobalValue("Controller", "Gamepad")
    DefineController:Gamepad(MenuManager, true, RefreshMenuItems)
  elseif string.lower(Dina:getGlobalValue("Controller")) == "gamepad" then
    Dina:setGlobalValue("Controller", "Keyboard")
    DefineController:Keyboard(MenuManager, true, RefreshMenuItems)
  end
end
local function ChangeUp()
  Dina:resetActionKeys()
  Dina:setActionKeys(ChangeKey, "Up", "pressed", { Dina:getGlobalValue("Controller"), "all" })
  ChangeKey:DisplayMsg("Action")
end
local function ChangeDown()
  Dina:resetActionKeys()
  Dina:setActionKeys(ChangeKey, "Down", "pressed", { Dina:getGlobalValue("Controller"), "all" })
  ChangeKey:DisplayMsg("Action")
end
local function ChangeLeft()
  Dina:resetActionKeys()
  Dina:setActionKeys(ChangeKey, "Left", "pressed", { Dina:getGlobalValue("Controller"), "all" })
  ChangeKey:DisplayMsg("Action")
end
local function ChangeRight()
  Dina:resetActionKeys()
  Dina:setActionKeys(ChangeKey, "Right", "pressed", { Dina:getGlobalValue("Controller"), "all" })
  ChangeKey:DisplayMsg("Action")
end
local function ChangeAction()
  Dina:resetActionKeys()
  Dina:setActionKeys(ChangeKey, "Action", "pressed", { Dina:getGlobalValue("Controller"), "all" })
  ChangeKey:DisplayMsg("Action")
end
local function ChangePause()
  Dina:resetActionKeys()
  Dina:setActionKeys(ChangeKey, "Pause", "pressed", { Dina:getGlobalValue("Controller"), "all" })
  ChangeKey:DisplayMsg("Pause")
end
local function ReturnToMenu()
  Dina:setState("menu")
  pressMenuButton:play()
end
--

local DefineController = {}
function DefineController.Gamepad(self, MenuManager, ForceChange, UpdateFunction)
  if ForceChange or not Dina:getGlobalValue("Controller") then Dina:setGlobalValue("Controller", "Gamepad") end
  if ForceChange or not Dina:getGlobalValue("Controller_Up") then Dina:setGlobalValue("Controller_Up", {"Gamepad", "lefty", -1}) end
  if ForceChange or not Dina:getGlobalValue("Controller_Down") then Dina:setGlobalValue("Controller_Down", {"Gamepad", "lefty", 1}) end
  if ForceChange or not Dina:getGlobalValue("Controller_Left") then Dina:setGlobalValue("Controller_Left", {"Gamepad", "leftx", -1}) end
  if ForceChange or not Dina:getGlobalValue("Controller_Right") then Dina:setGlobalValue("Controller_Right", {"Gamepad", "leftx", 1}) end
  if ForceChange or not Dina:getGlobalValue("Controller_Action") then Dina:setGlobalValue("Controller_Action", { "Gamepad", "a" }) end
  if ForceChange or not Dina:getGlobalValue("Controller_Pause") then Dina:setGlobalValue("Controller_Pause", { "Gamepad", "start" }) end
  self:SetMenuKeys(MenuManager)
  if ForceChange then UpdateFunction() end
end
function DefineController.Keyboard(self, MenuManager, ForceChange, UpdateFunction)
  if ForceChange or not Dina:getGlobalValue("Controller") then Dina:setGlobalValue("Controller", "Keyboard") end
  if ForceChange or not Dina:getGlobalValue("Controller_Up") then Dina:setGlobalValue("Controller_Up", {"Keyboard", "up"}) end
  if ForceChange or not Dina:getGlobalValue("Controller_Down") then Dina:setGlobalValue("Controller_Down", {"Keyboard", "down"}) end
  if ForceChange or not Dina:getGlobalValue("Controller_Left") then Dina:setGlobalValue("Controller_Left", {"Keyboard", "left"}) end
  if ForceChange or not Dina:getGlobalValue("Controller_Right") then Dina:setGlobalValue("Controller_Right", {"Keyboard", "right"}) end
  if ForceChange or not Dina:getGlobalValue("Controller_Action") then Dina:setGlobalValue("Controller_Action", { "Keyboard", "return" }) end
  if ForceChange or not Dina:getGlobalValue("Controller_Pause") then Dina:setGlobalValue("Controller_Pause", { "Keyboard", "backspace" }) end
  self:SetMenuKeys(MenuManager)
  if ForceChange then UpdateFunction() end
end
function DefineController.SetMenuKeys(self, MenuManager)
  Dina:resetActionKeys()
  MenuManager:setPreviousKeys( Dina:getGlobalValue("Controller_Up") )
  MenuManager:setNextKeys( Dina:getGlobalValue("Controller_Down") )
  MenuManager:setValidateKeys( Dina:getGlobalValue("Controller_Action") )
end
--

function Options:load()
  local offsetMenuItems = 75

  MenuManager = Dina("MenuManager")
  ValueManager = Dina("MenuManager")

  local controller = Dina:getGlobalValue("Controller")
  DefineController[controller](DefineController, MenuManager)

  -- Selection menu
  MenuManager:addTitle("Options", 50, "datas/font/SairaStencilOne-Regular.ttf", 70, Colors.ORANGE, true, Colors.ORANGERED, 2, 2)
  MenuManager:addTitle("WARNING! All changes are applied immediatly", 170, MainFont, MainFontSize, Colors.RED)
  MenuManager:addTitle("Move up and down to select an item and press the Action key to change it.", 220, MainFont, MainFontSize - 5, Colors.WHITE)
  MenuManager:setCtrlSpace(10)
  MenuManager:addItem("Controller", MainFont, MainFontSize, OnSelection, OnDeselection, ChangeController)
  MenuManager:addItem("Up", MainFont, MainFontSize, OnSelection, OnDeselection, ChangeUp)
  MenuManager:addItem("Down", MainFont, MainFontSize, OnSelection, OnDeselection, ChangeDown)
  MenuManager:addItem("Left", MainFont, MainFontSize, OnSelection, OnDeselection, ChangeLeft)
  MenuManager:addItem("Right", MainFont, MainFontSize, OnSelection, OnDeselection, ChangeRight)
  MenuManager:addItem("Action", MainFont, MainFontSize, OnSelection, OnDeselection, ChangeAction)
  MenuManager:addItem("Pause", MainFont, MainFontSize, OnSelection, OnDeselection, ChangePause)
  local backItem = MenuManager:addItem("Back", MainFont, MainFontSize, OnSelection, OnDeselection, ReturnToMenu)
  local bx, by = backItem:getPosition()
  local mx, my, mw, mh = MenuManager:getItemsDimensions()
  MenuManager:setItemsPosition(Dina.width * 1/4, offsetMenuItems + (Dina.height - mh) / 2)
  backItem:setPosition(bx, by)


  -- Keys or buttons/axes for the controller
  ValueManager:setCtrlSpace(10)
  MenuItemCtrl = ValueManager:addItem(controller, MainFont, MainFontSize)
  local itemName = Dina:getGlobalValue("Controller_Up")
  MenuItemCtrlUp = ValueManager:addItem(itemName[2] .. (string.lower(controller) == "gamepad" and itemName[3] and " "..itemName[3] or ""), MainFont, MainFontSize)
  itemName = Dina:getGlobalValue("Controller_Down")
  MenuItemCtrlDown = ValueManager:addItem(itemName[2] .. (string.lower(controller) == "gamepad" and itemName[3] and " "..itemName[3] or ""), MainFont, MainFontSize)
  itemName = Dina:getGlobalValue("Controller_Left")
  MenuItemCtrlLeft = ValueManager:addItem(itemName[2] .. (string.lower(controller) == "gamepad" and itemName[3] and " "..itemName[3] or ""), MainFont, MainFontSize)
  itemName = Dina:getGlobalValue("Controller_Right")
  MenuItemCtrlRight = ValueManager:addItem(itemName[2] .. (string.lower(controller) == "gamepad" and itemName[3] and " "..itemName[3] or ""), MainFont, MainFontSize)
  itemName = Dina:getGlobalValue("Controller_Action")
  MenuItemCtrlAction = ValueManager:addItem(itemName[2] .. (string.lower(controller) == "gamepad" and itemName[3] and " "..itemName[3] or ""), MainFont, MainFontSize)
  itemName = Dina:getGlobalValue("Controller_Pause")
  MenuItemCtrlPause = ValueManager:addItem(itemName[2] .. (string.lower(controller) == "gamepad" and itemName[3] and " "..itemName[3] or ""), MainFont, MainFontSize)

  ValueManager:setItemsPosition(Dina.width * 3/5, offsetMenuItems + (Dina.height - mh) / 2)
  local vw, vh = ValueManager:getItemsDimensions()
  ValueManager:setItemsDimensions(Dina.width * 2/5, vh, "vertical", true)
  
  -- Music
  --local music = Dina("Sound", "datas/musics/", "stream", -1, 1)
  --music:play()
  
  -- Sounds
  MenuItemSound = Dina("Sound", "datas/audio/soundeffects/menuLightup3.mp3", "static", 0.3, 0.3)
  MenuItemSound:setLooping(0)

  pressMenuButton = Dina("Sound", "datas/audio/soundeffects/menuButtonPress.mp3", "static", 0.3, 0.3)
  pressMenuButton:setLooping(0)

end
--

function Options:update(dt)
  Dina:update(dt, false)
end
--
function Options:draw()
  Dina:draw(false)
end
--

return Options