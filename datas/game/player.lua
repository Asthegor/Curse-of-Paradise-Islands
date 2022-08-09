local Player  = {}

-- Require
local Dina = require("Dina")

-- Local variables
local LevelManager = {}

local BoardingSound = {}
local LandingSound = {}
local AddingFoodSound = {}
local PoisonedSound = {}
local EatingSound = {}
local SailingSound = {}
local WalkingSound = {}
local seaExplorationMusic = {}
local landExplorationMusic = {}

local isSeaMusicPlaying = false
local isLandMusicPlaying = false

function Player:load(LManager, Reload)
  LevelManager = LManager
  self.mapwidth, self.mapheight = LevelManager:getMapDimensions()
  self.ship = LevelManager:getObjectByName("Ship")
  self.char = LevelManager:getObjectByName("Character")
  self.poisoned = false
  self.food = { max = 20, qty = 20, starvespeed = 10, items = {} }
  self.char.visible = false
  self.ship.visible = true
  self.compass = Dina:getGlobalValue("Game_Compass")
  
  -- Player type
  self.typechar = Dina:getGlobalValue("Player_Type")
  if not self.typechar then
    self.typechar = "soldier"
  end
  if string.lower(self.typechar) == "botanist" then
    self.firstimgid = 6
  elseif string.lower(self.typechar) == "explorer" then
    self.firstimgid = 18
    self.food.starvespeed = 4
  elseif string.lower(self.typechar) == "soldier" then
    self.firstimgid = 30
  end
  LevelManager:setImageId(self.char, self.firstimgid + 1)
  
  self:setOnBoard(true)
  self:addFood(20, false)
  
  -- First position
  if not Reload then
    local x = love.math.random(self.ship.width * 2, self.mapwidth - self.ship.width * 2)
    local y = love.math.random(self.ship.height * 2, self.mapheight - self.ship.height * 2)
    while LevelManager:getTileIdsAtCoord(x, y)[1] > 1 do
      x = love.math.random(self.ship.width * 2, self.mapwidth - self.ship.width * 2)
      y = love.math.random(self.ship.height * 2, self.mapheight - self.ship.height * 2)
    end
    self:setPosition(x,y)
  end
  
  -- Sounds
  BoardingSound = Dina("Sound", "datas/audio/soundeffects/shipEnter.mp3", "static", 0.8, 0.8)
  BoardingSound:setLooping(0)
  LandingSound = Dina("Sound", "datas/audio/soundeffects/shipExit.mp3", "static", 1, 1)
  LandingSound:setLooping(0)
  AddingFoodSound = Dina("Sound", "datas/audio/soundeffects/collectFood1.mp3", "static", 0.2, 0.2)
  AddingFoodSound:setLooping(0)
  --PoisonedSound = Dina("Sound", "datas/sounds/", "static", 1, 1)
  EatingSound = Dina("Sound", "datas/audio/soundeffects/eatfood1.mp3", "static", 1, 1)
  EatingSound:setLooping(0)
  SailingSound = Dina("Sound", "datas/audio/soundeffects/shipMove.mp3", "static", 0.1, 0.1)
  SailingSound:setLooping(0)
 
  --WalkingSound = Dina("Sound", "datas/sounds/", "static", 1, 1)
if isSeaMusicPlaying == false then
  seaExplorationMusic = Dina("Sound", "datas/audio/music/seaExploration.mp3", "stream", 0.3, 0.3)
  seaExplorationMusic:setLooping(0)
  seaExplorationMusic:play()
  isSeaMusicPlaying = true
end
  landExplorationMusic = Dina("Sound", "datas/audio/music/islandExploration.mp3", "stream", 0.3,0.3)
  landExplorationMusic:setLooping(0)
end
--

-- Player movements
function Player:PlayMoveSounds()
  if self.onboard then
   --if not SailingSound:isPlaying() then
   --SailingSound:play()
   --SailingSound:setLooping(-1)
--end
 -- else
--    if not WalkingSound:isPlaying() then
--      WalkingSound:play()
end
  end
  function Player:StopMovementSound()
    if self.onboard then
   --   if SailingSound:isPlaying() then
     --   SailingSound:stop()
     -- else
        -- if WalkingSound:isPlaying() then
        -- WalkingSound:stop()

    --  end
      
    end
    
  end
function Player:checkMovement(X, Y)
  local move = false
  local ids = LevelManager:getTileIdsAtCoord(X, Y)
  if ids[1] > 1 then
    move = true
  elseif ids[1] == 1 then
    if self.onboard then
      move = true
    else
      if CollidePointRect(X, Y, self.ship.x, self.ship.y - self.ship.height, self.ship.width, self.ship.height) then
        self:setOnBoard(true)
        move = true
      end
    end
  end
  return move
end
function Player:left(dir, dt)
  self:PlayMoveSounds()
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  if x-w/2 < 0 then return end
  if self:checkMovement(x-w/2, y) then
    x = x - self.speed * dt
    self:setPosition(x, y)
  end
  self.moveleft = true
end
function Player:right(dir, dt)
  self:PlayMoveSounds()
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  local lw, lh = LevelManager:getMapDimensions()
  if x+w/2 > lw then return end
  if self:checkMovement(x+w/2, y) then
    x = x + self.speed * dt
    self:setPosition(x, y)
  end
  self.moveright = true
end
function Player:up(dir, dt)
  self:PlayMoveSounds()
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  local lw, lh = LevelManager:getMapDimensions()
  if y-h/2 < 0 then return end
  if self:checkMovement(x, y-h/2) then
    y = y - self.speed * dt
    self:setPosition(x, y)
  end
  self.moveup = true
end
function Player:down(dir, dt)
  self:PlayMoveSounds()
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  local lw, lh = LevelManager:getMapDimensions()
  if y+h/2 > lh then return end
  if self:checkMovement(x, y+h/2) then
    y = y + self.speed * dt
    self:setPosition(x, y)
  end
  self.movedown = true
end
--

function Player:getPosition()
  return self.x, self.y
end
function Player:setPosition(X, Y)
  self.x = X
  self.y = Y
  if self.onboard then
    self.ship.x = X - self.ship.width/2
    self.ship.y = Y + self.ship.height/2
  end
  self.char.x = X - self.char.width/2
  self.char.y = Y + self.char.height/2
end
function Player:getDimensions()
  return self.char.width, self.char.height
end
function Player:getTypeChar()
  return self.typechar
end
function Player:isInShip()
  local x, y = self:getPosition()
  return CollidePointRect(x, y, self.ship.x, self.ship.y - self.ship.height, self.ship.width, self.ship.height)
end
function Player:getOnBoard()
  return self.onboard
end
function Player:setOnBoard(Value)
  if Value == self.onboard then
    self.char.visible = not self.onboard
    return
  end
  if Value and not self.onboard then
    if next(LandingSound) then LandingSound:stop() end
    if next(BoardingSound) then BoardingSound:play() end

    if isLandMusicPlaying == true then
    isLandMusicPlaying = false
    landExplorationMusic:stop()
    seaExplorationMusic:play()
    isSeaMusicPlaying = true
    end
 
    self.onboard = true
    self.speed = 75
    if string.lower(self.typechar) == "explorer" then
      self.speed = 125
    elseif string.lower(self.typechar) == "botanist" then
      self.speed = 60
    end
    self.char.visible = false
  elseif not Value and self.onboard then
    if next(BoardingSound) then BoardingSound:stop() end
    if next(LandingSound) then LandingSound:play() end

    if isSeaMusicPlaying == true then
    isSeaMusicPlaying = false
    seaExplorationMusic:stop()
    landExplorationMusic:play()
    isLandMusicPlaying = true
  end
  
   
    self.onboard = false
    self.speed = 75
    if string.lower(self.typechar) == "botanist" then
      self.speed = 60
    end
    self.char.visible = true
  end
end
--
function Player:addFood(NbFood, Poisoned)
  if string.lower(self.typechar) == "botanist" and Poisoned then
    return
  end
  if next(AddingFoodSound) then 
    AddingFoodSound:stop()
    AddingFoodSound:play()
  end
  for i = 1, NbFood do
    if #self.food.items == self.food.max then
      break
    end
    local food = {poisoned = Poisoned}
    table.insert(self.food.items, food)
  end
end
function Player:getFoodQty()
  return #self.food.items
end
function Player:getFood()
  return self.food
end
function Player:eatFood()
  local food = self.food.items[1]
  self.poisoned = food.poisoned
  if food.poisoned then
    if next(PoisonedSound) then PoisonedSound:play() end
  else
    if next(EatingSound) then EatingSound:play() end
  end
  table.remove(self.food.items, 1)
end
function Player:isDead()
  return #self.food.items == 0
end
function Player:isPoisoned()
  return self.poisoned
end
--

function Player:update(dt)
  self.moveleft = false
  self.moveright = false
  self.moveup = false
  self.movedown = false
end
local MIDWIDTH = Dina.width/2
local MIDHEIGHT = Dina.height/2
function Player:draw()
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  local lw, lh = LevelManager:getMapDimensions()
  if x > lw - MIDWIDTH then
    x = Dina.width - (lw - x)
  elseif x >= MIDWIDTH then
    x = MIDWIDTH
  end
  if y > lh - MIDHEIGHT then
    y = Dina.height - (lh - y)
  elseif y >= MIDHEIGHT then
    y = MIDHEIGHT
  end
  local xmove = x
  local ymove = y
  if self.moveleft then
    xmove = xmove - w/2
  elseif self.moveright then
    xmove = xmove + w/2
  end
  if self.moveup then
    ymove = ymove - h/2
  elseif self.movedown then
    ymove = ymove + h/2
  end
  love.graphics.setColor(0,1,0)
  love.graphics.circle("fill", x, y, 3)
  love.graphics.setColor(1,0,0)
  love.graphics.circle("fill", xmove, ymove, 3)
  love.graphics.setColor(1,1,1)
end
--


-- DO NOT REMOVE THE LINE BELOW
Player.__index = Player
return Player