local Player  = {}

local Dina = require("Dina")
local LevelManager = {}



function Player:load(LManager, Reload)
  LevelManager = LManager
  self.mapwidth, self.mapheight = LevelManager:getMapDimensions()
  self.ship = LevelManager:getObjectByName("Ship")
  self.char = LevelManager:getObjectByName("Character")
  self.poisoned = false
  
  if not Reload then
    local x = love.math.random(self.ship.width * 2, self.mapwidth - self.ship.width * 2)
    local y = love.math.random(self.ship.height * 2, self.mapheight - self.ship.height * 2)
    while LevelManager:getTileIdsAtCoord(x, y)[1] > 1 do
      x = love.math.random(self.ship.width * 2, self.mapwidth - self.ship.width * 2)
      y = love.math.random(self.ship.height * 2, self.mapheight - self.ship.height * 2)
    end
    self:setPosition(x,y)
  end
  -- Food
  self.food = 
    { 
      max = 20, 
      qty = 20,
      starvespeed = 10,
      items = {}
    }

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
  
  self.char.visible = false
  self.ship.visible = true
  self.compass = Dina:getGlobalValue("Game_Compass")
end
--

-- Player movements
function Player:checkMovement(IDs, X, Y)
  local move = false
  if IDs[1] > 1 then
    move = true
  elseif IDs[1] == 1 then
    if self.onboard then
      move = true
    end
  end
  return move
end

function Player:left(dir, dt)
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  local lw, lh = LevelManager:getMapDimensions()
  if x-w/4 < w then return end
  local ids = LevelManager:getTileIdsAtCoord(x-w/4, y)
  if self:checkMovement(ids) then
    x = x - self.speed * dt
    if x < 0 then
      x = 0
    end
    self:setPosition(x, y)
  end
end
function Player:right(dir, dt)
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  local lw, lh = LevelManager:getMapDimensions()
  if x+w/2 > lw then return end
  local ids = LevelManager:getTileIdsAtCoord(x+w/2, y)
  if self:checkMovement(ids) then
    local w, h = self:getDimensions()
    x = x + self.speed * dt
    if x > self.mapwidth - w then
      x = self.mapwidth - w
    end
    self:setPosition(x, y)
  end
end
function Player:up(dir, dt)
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  local lw, lh = LevelManager:getMapDimensions()
  if y+h/4 < w then return end
  local ids = LevelManager:getTileIdsAtCoord(x, y+h/4)
  if self:checkMovement(ids) then
    y = y - self.speed * dt
    if y < h then
      y = h
    end
    self:setPosition(x, y)
  end
end
function Player:down(dir, dt)
  local x, y = self:getPosition()
  local w, h = self:getDimensions()
  local lw, lh = LevelManager:getMapDimensions()
  if y+h/2 > lh then
    return
  end
  local ids = LevelManager:getTileIdsAtCoord(x, y+h/2)
  if self:checkMovement(ids) then
    y = y + self.speed * dt
    if y > self.mapheight then
      y = self.mapheight
    end
    self:setPosition(x, y)
  end
end
--
function Player:getPosition()
  return self.x, self.y
--  return self.char.x, self.char.y
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
--
function Player:getTypeChar()
  return self.typechar
end

function Player:isInShip()
  local x, y = self:getPosition()
  return CollidePointRect(x, y, self.ship.x, self.ship.y - self.ship.height, self.ship.width, self.ship.height)
end
function Player:setOnBoard(Value)
  if Value == self.onboard then
    self.char.visible = not self.onboard
    return
  end
  if Value and not self.onboard then
    self.onboard = true
    
    self.speed = 75
    if string.lower(self.typechar) == "explorer" then
      self.speed = 125
    elseif string.lower(self.typechar) == "botanist" then
      self.speed = 60
    end
    
    self.char.visible = false
  elseif not Value and self.onboard then
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
  for i = 1, NbFood do
    if #self.food.items == self.food.max then
      break
    end
    local food = {poisoned = Poisoned}
    table.insert(self.food.items, food)
  end
--  self.food.qty = self.food.qty + NbFood
--  if self.food.qty > self.food.max then
--    self.food.qty = self.food.max
--  end
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
  table.remove(self.food.items, 1)
    
--  self.food.qty = self.food.qty - 1
end
function Player:isDead()
  return #self.food.items == 0
--  return self.food.qty < 0
end
function Player:isPoisoned()
  return self.poisoned
end
--

function Player:update(dt)
end
function Player:draw()
end
--


-- DO NOT REMOVE THE LINE BELOW
Player.__index = Player
return Player