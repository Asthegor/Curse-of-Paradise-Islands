local Game = {}

-- Require
local Dina = require("Dina")
local Map = require("datas/game/map")
local Player = require("datas/game/player")

-- Constantes
local BIOME_MER = 1
local BIOME_SABLE = 2
local BIOME_JUNGLE = 3
local BIOME_FORET = 4
local BIOME_MONTAGNE = 5

local MIDWIDTH = Dina.width / 2
local MIDHEIGHT = Dina.height / 2

local PI = 355/113

-- Locale variables
local MainFont = "datas/font/SairaStencilOne-Regular.ttf"
local MainFontSize = 20

local LevelManager = {}

local pauseGame = false
local PauseBtn = {}

local FoodProgressBar = {}
local FoodQuantity = {}
local CompassUI = {}

local showCompass = false
local CompassImg = {}
local ArrowImg = {}
local arrowAngle = -1
local speedArrowMove = 80

local camera = {x = 0, y = 0}

local SailingMusic = {}
local LandMusic = {}
local PauseSound = {}


-- local functions
local function LoadActionKeys()
  Dina:resetActionKeys()
  local controller = Dina:getGlobalValue("Controller")
  if controller then controller = string.lower(controller) end
  if controller == "gamepad" then
    if not Dina:getGlobalValue("Controller_Left") then Dina:setGlobalValue("Controller_Left", {"Gamepad", "leftx", -1}) end
    if not Dina:getGlobalValue("Controller_Right") then Dina:setGlobalValue("Controller_Right", {"Gamepad", "leftx", 1}) end
    if not Dina:getGlobalValue("Controller_Up") then Dina:setGlobalValue("Controller_Up", {"Gamepad", "lefty", -1}) end
    if not Dina:getGlobalValue("Controller_Down") then Dina:setGlobalValue("Controller_Down", {"Gamepad", "lefty", 1}) end
    if not Dina:getGlobalValue("Controller_Action") then Dina:setGlobalValue("Controller_Action", { "Gamepad", "a" }) end
    if not Dina:getGlobalValue("Controller_Pause") then Dina:setGlobalValue("Controller_Pause", { "Gamepad", "start" }) end
  elseif controller == "keyboard" then
    if not Dina:getGlobalValue("Controller_Left") then Dina:setGlobalValue("Controller_Left", {"Keyboard", "left"}) end
    if not Dina:getGlobalValue("Controller_Right") then Dina:setGlobalValue("Controller_Right", {"Keyboard", "right"}) end
    if not Dina:getGlobalValue("Controller_Up") then Dina:setGlobalValue("Controller_Up", {"Keyboard", "up"}) end
    if not Dina:getGlobalValue("Controller_Down") then Dina:setGlobalValue("Controller_Down", {"Keyboard", "down"}) end
    if not Dina:getGlobalValue("Controller_Action") then Dina:setGlobalValue("Controller_Action", { "Keyboard", "return" }) end
    if not Dina:getGlobalValue("Controller_Pause") then Dina:setGlobalValue("Controller_Pause", { "Keyboard", "backspace" }) end
  else
    assert(false, "Please contact the game creator. Error while loading Action keys (Controller="..(controller and tostring(controller) or "nil")..")")
  end
  Dina:setActionKeys(Player, "left", "continuous", Dina:getGlobalValue("Controller_Left"))
  Dina:setActionKeys(Player, "right", "continuous", Dina:getGlobalValue("Controller_Right"))
  Dina:setActionKeys(Player, "up", "continuous", Dina:getGlobalValue("Controller_Up"))
  Dina:setActionKeys(Player, "down", "continuous", Dina:getGlobalValue("Controller_Down"))
  Dina:setActionKeys(Game, "compass", "pressed", Dina:getGlobalValue("Controller_Action"))
  Dina:setActionKeys(Game, "pause", "pressed", Dina:getGlobalValue("Controller_Pause"))
end
local function LoadUserInterface()
  FoodProgressBar = Dina("ProgressBar", 10, 10, 64, 97, 100, 100)
  local imgBack = love.graphics.newImage("datas/images/game/barrel02.png")
  local imgFront = love.graphics.newImage("datas/images/game/barrel01.png")
  FoodProgressBar:setImages(imgBack, imgFront)
  FoodProgressBar:setZOrder(FoodProgressBar:getZOrder() + 1)
  local fpx, fpy = FoodProgressBar:getPosition()
  local fpw, fph = FoodProgressBar:getDimensions()
  local foodqty = 0
  if next(Player) then
    foodqty = Player:getFoodQty()
  end
  FoodQuantity = Dina("Text", foodqty, fpx + fpw + 10, fpy, 100, fph, Colors.WHITE, MainFont, MainFontSize, "left", "center")
  FoodQuantity:setZOrder(FoodQuantity:getZOrder() + 1)

  local fqx, fqy = FoodQuantity:getPosition()
  local fqw, fqh = FoodQuantity:getDimensions()
  CompassUI = Dina("Image", "datas/images/game/compass_UI.png", fqx + fqw, fqy)
  local gameCompass = Dina:getGlobalValue("Game_Compass")
  if gameCompass then
    CompassUI:setVisible(true)
  else
    CompassUI:setVisible(false)
  end
  CompassUI:setZOrder(CompassUI:getZOrder() + 1)
end
--


function Game:load()
  arrowAngle = -1
  if not Dina:getGlobalValue("Controller") then
    Dina:setGlobalValue("Controller", "Keyboard")
  end
  Game:generateIsland()

  LoadUserInterface()

  local x, y = Player:getPosition()
  Player:setPosition(x, y)

  Game:updateCamera()

  -- Music
  --SailingMusic = Dina("Sound", "datas/musics/", "stream", -1, 1)
  --LandMusic = Dina("Sound", "datas/musics/", "stream", -1, 1)
  --SailingMusic:play()

  -- Sounds
  --PauseSound = Dina("Sound", "datas/sounds/", "static", 1, 1)
end
--

function Game:pause()
  pauseGame = not pauseGame
  if pauseGame then
    if next(PauseSound) then PauseSound:play() end
    PauseBtn = Dina("Button", Dina.width/4, (Dina.height - Dina.width/4)/2, MIDWIDTH, Dina.width/4, "PAUSE", MainFont, 60, Colors.PURPLE, Colors.GRAY)
    PauseBtn:setThickness(4)
    PauseBtn:setBorderColor(Colors.YELLOW)
    Dina:resetActionKeys()
    Dina:setActionKeys(Game, "pause", "pressed", Dina:getGlobalValue("Controller_Pause"))
  else
    Dina:removeComponent(PauseBtn)
    LoadActionKeys()
  end
end
--
function Game:compass()
  local gameCompass = Dina:getGlobalValue("Game_Compass")
  if gameCompass then
    showCompass = not showCompass
    if showCompass then
      CompassImg = Dina("Image", "datas/images/game/compass_big.png", 0, 0)
      CompassImg:centerOrigin()
      CompassImg:setPosition(MIDWIDTH, MIDHEIGHT)
      CompassImg:setZOrder(CompassImg:getZOrder() + 1)

      ArrowImg = Dina("Image", "datas/images/game/arrow.png", 0, 0)
      ArrowImg:centerOrigin()
      ArrowImg:setPosition(MIDWIDTH, MIDHEIGHT)
      ArrowImg:setZOrder(CompassImg:getZOrder() + 1)

      Dina:resetActionKeys()
      Dina:setActionKeys(Game, "compass", "pressed", Dina:getGlobalValue("Controller_Action"))
    else
      Dina:removeComponent(CompassImg)
      Dina:removeComponent(ArrowImg)
      LoadActionKeys()
    end
  end
end

function Game:update(dt)
  if pauseGame then
    return
  end

  if showCompass then
    self:updateCompass(dt)
    return
  end

  if Player:isDead() then
    Dina:setState("gameover")
    return
  end

  local px, py = Player:getPosition()
  local ids = LevelManager:getTileIdsAtCoord(px, py)
  -- Only one id at a given coordinate
  if not Player.onboard then
    if ids[1] == BIOME_MER and Player:isInShip() then
      Player:setOnBoard(true)
    end
  elseif Player.onboard and ids[1] > BIOME_MER then
    Player:setOnBoard(false)
  end

  -- Collision with Detectors
  local detectors = LevelManager:getAllObjectsByClass("Detector")
  for _, detector in pairs(detectors) do
    if detector.visible then
      if CollidePointRect(px, py, detector.x, detector.y, detector.width, detector.height) then
        local sepPos = string.find(detector.name, "_")
        local numItem = string.sub(detector.name, sepPos + 1)
        detector.visible = false
        if string.sub(detector.name, 1, 4) == "Food" then
          local item = LevelManager:getObjectByName("Food_"..tostring(numItem - 1))
          item.visible = true
          item.properties["detected"] = true
          if string.lower(Player:getTypeChar()) == "botanist" then
            local id = LevelManager:getImageId(item)
            LevelManager:setImageId(item, id + 1 + (item.properties["poisonous"] and 1 or 0))
          end
        else
          local item = LevelManager:getObjectByName("Compass")
          item.visible = true
          item.properties["detected"] = true
        end
      end
    end
  end
  -- Collision with Food
  local foods = LevelManager:getAllObjectsByClass("Food")
  for _, food in pairs(foods) do
    if food.visible then
      if CollidePointRect(px, py, food.x, food.y, food.width, food.height) then
        food.visible = false
        Player:addFood(food.properties["quantity"], food.properties["poisonous"])
      end
    end
  end

  -- Collision with the Compass
  local compass = LevelManager:getObjectByName("Compass")
  if compass then
    if compass.visible then
      if CollidePointRect(px, py, compass.x, compass.y, compass.width, compass.height) then
        Player.compass = true
        Dina:setGlobalValue("Game_Compass", compass)
        CompassUI:setVisible(true)
        compass.visible = false
      end
    end
  end
  -- Collision with the Fountain
  local fountain = LevelManager:getObjectByName("Fountain")
  if fountain then
    fountain.visible = true
    if CollidePointRect(px, py, fountain.x, fountain.y, fountain.width, fountain.height) then
--      Dina:setState("victory")
      print("Fontaine trouvée")
    end
  end

  -- UI
  local playerFood = Player:getFood()
  local fpv = FoodProgressBar:getValue()
  local starvespeed = playerFood.starvespeed * dt
  if Player:getTypeChar() ~= "botanist" then
    starvespeed = starvespeed * (Player:isPoisoned() and 3 or 1)
  end
  fpv = fpv - starvespeed
  if fpv < 0 then
    Player:eatFood()
    fpv = FoodProgressBar:getMaxValue()
  end
  FoodProgressBar:setValue(fpv)
  FoodQuantity:setContent(Player:getFoodQty())


  -- Player movemants
  Dina:update(dt, false)

  -- Camera
  px, py = Player:getPosition()
  local lw, lh = LevelManager:getMapDimensions()
  if px > MIDWIDTH and px < lw - MIDWIDTH then
    camera.x = px - MIDWIDTH
  end
  if py > MIDHEIGHT and py < lh - MIDHEIGHT then
    camera.y = py - MIDHEIGHT
  end

  -- Go to next island
  local generate = true
  if string.lower(Player:getTypeChar()) == "botanist" then
    generate = self:hasExploreIsland()
  end
  if generate then
    local pw, ph = Player:getDimensions()
    if px < pw*2 or px > lw - pw*2 or py < ph*2 or py > lh - ph*2 then
      self:generateIsland()
    end
    local nlw, nlh = LevelManager:getMapDimensions()

    local npx, npy
    if px < pw * 2 then
      npx = nlw - pw * 3
    elseif px > lw - pw * 2 then
      npx = pw * 3
    else
      npx = px
    end
    if py < ph * 2 then
      npy = nlh - ph * 3
    elseif py > lh - ph * 2 then
      npy = ph * 3
    else
      npy = py
    end
    Player:setPosition(npx, npy)
    Game:updateCamera()
  end
end
--
function Game:hasExploreIsland()
  local foods = LevelManager:getAllObjectsByClass("Food")
  for _, food in pairs(foods) do
    if not food.properties["detected"] then
      return false
    end
  end
  return true
end

function Game:generateIsland()
  local reloadAction = false
  if next(LevelManager) then
    Dina:resetActionKeys()
    Dina:removeComponent(LevelManager)
    reloadAction = true
  end
  LevelManager = nil
  LevelManager = Dina("LevelManager")
  LevelManager:load(Map:load(75, 50, 32, 32))
  Player:load(LevelManager, reloadAction)
  LoadActionKeys()

  if next(FoodProgressBar) then
    local zOrder = FoodProgressBar:getZOrder()
    FoodProgressBar:setZOrder(zOrder + 1)
  end
end
function Game:updateCamera()
  local px, py = Player:getPosition()
  local lw, lh = LevelManager:getMapDimensions()
  if px <= MIDWIDTH then
    camera.x = 0
  elseif px < lw - MIDWIDTH then
    camera.x = px - MIDWIDTH
  else
    camera.x = lw - Dina.width
  end
  if py <= MIDHEIGHT then
    camera.y = 0
  elseif py < lh - MIDHEIGHT then
    camera.y = py - MIDHEIGHT
  else
    camera.y = lh - Dina.height
  end
end
--

function Game:updateCompass(dt)
  local px, py = Player:getPosition()
  local fountain = LevelManager:getObjectByName("Fountain")
  local angle = ArrowImg:getRotation()
  if fountain then
    local ux = 0
    local uy = 1
    local pfx = fountain.x - px
    local pfy = fountain.y - py
    local norme = (pfx * pfx + pfy * pfy) ^0.5
    local vx = pfx / norme
    local vy = pfy / norme

    local prodscal = ux * vx + uy * vy
    local norme_u = (ux * ux + uy * uy) ^0.5
    local norme_v = (vx * vx + vy * vy) ^0.5

    local angle = math.acos( prodscal / (norme_u * norme_v) ) * 180 / PI
    if px < fountain.x then
      arrowAngle = 180 - angle
    else
      arrowAngle = 180 + angle
    end
    ArrowImg:setRotation(arrowAngle)
  else
    if arrowAngle < 0 then
      arrowAngle = love.math.random(1,360)
    end
    speedArrowMove = love.math.random(80, 120)
    local diff = arrowAngle - angle
    if math.abs(diff) <= 2 then
      arrowAngle = -1
    elseif diff < 0 then
      angle = angle - speedArrowMove * dt
      ArrowImg:setRotation(angle)
    elseif diff > 0 then
      angle = angle + speedArrowMove * dt
      ArrowImg:setRotation(angle)
    end
  end
end
--

function Game:draw()
  LevelManager:setOffset(camera.x, camera.y)
  Dina:draw(false)
end


return Game