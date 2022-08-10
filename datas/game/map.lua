local Map = {}

local Dina = require("Dina")

local BIOME_MER = 1
local BIOME_SABLE = 2
local BIOME_JUNGLE = 3
local BIOME_FORET = 4
local BIOME_MONTAGNE = 5

local NbBiomeCells = {}

local function Distance(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
local function Normalize(value, min, max) return (value - min) / (max - min) end
local function AddBiomeDatas(biome, biome_type, row, col, Width)
  if biome[biome_type].minrow > row then
    biome[biome_type].minrow = row
  end
  if biome[biome_type].maxrow < row then
    biome[biome_type].maxrow = row
  end
  if biome[biome_type].mincol > col then
    biome[biome_type].mincol = col
  end
  if biome[biome_type].maxcol < col then
    biome[biome_type].maxcol = col
  end
  biome[biome_type][(row - 1) * Width + col] = biome_type
  NbBiomeCells[biome_type] = NbBiomeCells[biome_type] + 1
end
local function GetNoiseValues(Width, Height, Scale)
  local map = {}
  local min = 9999
  local max = 0
  local seed = love.math.random(400, 600)
  local noise
  for row = 1, Height do
    map[row] = {}
    for col = 1, Width do
      noise = love.math.noise((col + seed) / Scale, (row + seed) / Scale)
      map[row][col] = noise
      if noise < min then
        min = noise
      end
      if noise > max then
        max = noise
      end
    end
  end
  return map, min, max
end
local function GetMapNormalize(Map, Width, Height, Min, Max)
  local midWidth = Width / 2
  local midHeight = Height / 2
  local hauteur, distance, ratio, ratiorow, ratiocol
  for row = 1, Height do
    for col = 1, Width do
      hauteur = Normalize(Map[row][col], Min, Max)
      if row < midHeight then
        ratiorow = (midHeight - row) / midHeight
      else
        ratiorow = (row - midHeight) / midHeight
      end
      if col < midWidth then
        ratiocol = (midWidth - col) / midWidth
      else
        ratiocol = (col - midWidth) / midWidth
      end
      ratio = 1 - math.max(ratiocol, ratiorow)
      hauteur = hauteur * ratio
      if hauteur < 0 then hauteur = 0 end
      Map[row][col] = hauteur
    end
  end
end
local function GetBiomeMap(Map, Width, Height)
  local biome_found = false
  local biome = {}
  biome[BIOME_MER] = {minrow = Height, maxrow = 0, mincol = Width, maxcol = 0}
  biome[BIOME_SABLE] = {minrow = Height, maxrow = 0, mincol = Width, maxcol = 0}
  biome[BIOME_JUNGLE] = {minrow = Height, maxrow = 0, mincol = Width, maxcol = 0}
  biome[BIOME_FORET] = {minrow = Height, maxrow = 0, mincol = Width, maxcol = 0}
  biome[BIOME_MONTAGNE] = {minrow = Height, maxrow = 0, mincol = Width, maxcol = 0}
  NbBiomeCells[BIOME_MER] = 0
  NbBiomeCells[BIOME_SABLE] = 0
  NbBiomeCells[BIOME_JUNGLE] = 0
  NbBiomeCells[BIOME_FORET] = 0
  NbBiomeCells[BIOME_MONTAGNE] = 0
  for row = 1, Height do
    for col = 1, Width do
      local hauteur = Map[row][col]
      biome[BIOME_MER][(row - 1) * Width + col] = 0
      biome[BIOME_SABLE][(row - 1) * Width + col] = 0
      biome[BIOME_JUNGLE][(row - 1) * Width + col] = 0
      biome[BIOME_FORET][(row - 1) * Width + col] = 0
      biome[BIOME_MONTAGNE][(row - 1) * Width + col] = 0
      if hauteur < 0.22 then
        AddBiomeDatas(biome, BIOME_MER, row, col, Width)
      elseif hauteur < 0.25 then
        AddBiomeDatas(biome, BIOME_SABLE, row, col, Width)
        biome_found = true
      elseif hauteur < 0.55 then
        AddBiomeDatas(biome, BIOME_JUNGLE, row, col, Width)
        biome_found = true
      elseif hauteur < 0.85 then
        AddBiomeDatas(biome, BIOME_FORET, row, col, Width)
        biome_found = true
      else
        AddBiomeDatas(biome, BIOME_MONTAGNE, row, col, Width)
        biome_found = true
      end
    end
  end
  return biome_found, biome, NbBiomeCells
end
--
function Map:load(Width, Height, TileWidth, TileHeight)

  local GameCompass = Dina:getGlobalValue("Game_Compass")

  local scale = 70
  local biome_found = false
  self.nbBiomeCells = {}
  local biome = {}
  while (not biome_found) do
    local map, min, max = GetNoiseValues(Width, Height, scale)
    GetMapNormalize(map, Width, Height, min, max)
    biome_found, biome, self.nbBiomeCells = GetBiomeMap(map, Width, Height)
  end

  self.island = {
    class = "",
    orientation = "orthogonal",
    renderorder = "left-up",
    width = Width,
    height = Height,
    tilewidth = TileWidth,
    tileheight = TileHeight,
    nextlayerid = 8,
    nextobjectid = 3,
    properties = {},
    tilesets = {
      {
        name = "Land",
        firstgid = 1,
        class = "",
        tilewidth = 32,
        tileheight = 32,
        spacing = 0,
        margin = 0,
        columns = 5,
        image = "datas/images/game/Land.png",
        imagewidth = 160,
        imageheight = 32,
        objectalignment = "unspecified",
        tilerendersize = "tile",
        fillmode = "stretch",
        tileoffset = {
          x = 0,
          y = 0
        },
        grid = {
          orientation = "orthogonal",
          width = 32,
          height = 32
        },
        properties = {},
        wangsets = {},
        tilecount = 5,
        tiles = {}
      },
      {
        name = "Characters",
        firstgid = 6,
        class = "",
        tilewidth = 48,
        tileheight = 48,
        spacing = 0,
        margin = 0,
        columns = 12,
        image = "datas/images/game/Characters.png",
        imagewidth = 576,
        imageheight = 192,
        objectalignment = "unspecified",
        tilerendersize = "tile",
        fillmode = "stretch",
        tileoffset = {
          x = 0,
          y = 0
        },
        grid = {
          orientation = "orthogonal",
          width = 48,
          height = 48
        },
        properties = {},
        wangsets = {},
        tilecount = 48,
        tiles = {}
      },
      {
        name = "Items",
        firstgid = 54,
        class = "",
        tilewidth = 32,
        tileheight = 32,
        spacing = 0,
        margin = 0,
        columns = 6,
        image = "datas/images/game/Items.png",
        imagewidth = 192,
        imageheight = 96,
        objectalignment = "unspecified",
        tilerendersize = "tile",
        fillmode = "stretch",
        tileoffset = {
          x = 0,
          y = 0
        },
        grid = {
          orientation = "orthogonal",
          width = 32,
          height = 32
        },
        properties = {},
        wangsets = {},
        tilecount = 18,
        tiles = {}
      }
    },
    layers = {
      {
        type = "tilelayer",
        x = 0,
        y = 0,
        width = Width,
        height = Height,
        id = 1,
        name = "Sea",
        class = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        encoding = "lua",
        data = biome[BIOME_MER]
      },
      {
        type = "tilelayer",
        x = 0,
        y = 0,
        width = Width,
        height = Height,
        id = 2,
        name = "Sand",
        class = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        encoding = "lua",
        data = biome[BIOME_SABLE]
      },
      {
        type = "tilelayer",
        x = 0,
        y = 0,
        width = Width,
        height = Height,
        id = 3,
        name = "Jungle",
        class = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        encoding = "lua",
        data = biome[BIOME_JUNGLE]
      },
      {
        type = "tilelayer",
        x = 0,
        y = 0,
        width = Width,
        height = Height,
        id = 4,
        name = "Forest",
        class = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        encoding = "lua",
        data = biome[BIOME_FORET]
      },
      {
        type = "tilelayer",
        x = 0,
        y = 0,
        width = Width,
        height = Height,
        id = 5,
        name = "Mountain",
        class = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        encoding = "lua",
        data = biome[BIOME_MONTAGNE]
      },
      {
        type = "objectgroup",
        draworder = "topdown",
        id = 7,
        name = "GameObjs",
        class = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {}
      },
      {
        type = "objectgroup",
        draworder = "topdown",
        id = 6,
        name = "PlayerObjs",
        class = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "Ship",
            class = "",
            shape = "rectangle",
            x = 0,
            y = 48,
            width = 48,
            height = 48,
            rotation = 0,
            gid = 42,
            visible = true,
            properties = {}
          },
          {
            id = 2,
            name = "Character",
            class = "",
            shape = "rectangle",
            x = 0,
            y = 48,
            width = 48,
            height = 48,
            rotation = 0,
            gid = 6,
            visible = true,
            properties = {}
          }
        }
      }
    }
  }
  --
  local rndFood = love.math.random(5, 20)
  self:addFood(rndFood)

  if not GameCompass then
    local addCompass = false
    local rndCompass = love.math.random(1, 100)
    if rndCompass > 80 then
      self:addCompass()
    end
  else
    GameCompass.remainIslands = GameCompass.remainIslands - 1
  end

  local rndFountain = love.math.random(1, 100)
  if (GameCompass and GameCompass.remainIslands == 0) or rndFountain > 95 then
    self:addFountain()
  end

  return self.island
end
--
function Map:getNextObjectId()
  local id = self.island.nextobjectid
  self.island.nextobjectid = self.island.nextobjectid + 1
  return id
end
function Map:getGameObjLayer()
  local gameObjLayer = {}
  for _, layer in pairs(self.island.layers) do
    if layer.name == "GameObjs" then
      gameObjLayer = layer
      break
    end
  end
  return gameObjLayer
end
function Map:getLandLayers()
  local layers = {}
  for _, layer in pairs(self.island.layers) do
    if layer.type == "tilelayer" and string.lower(layer.name) ~= "sea" then
      table.insert(layers, layer)
    end
  end
  return layers
end
--
function Map:getFoodDetector(X, Y)
  local idObj = self:getNextObjectId()
  local foodDetection = 
    {
      id = idObj,
      name = "FoodDetector_"..tostring(idObj),
      class = "Detector",
      shape = "rectangle",
      x = X,
      y = Y,
      width = 160,
      height = 160,
      rotation = 0,
      visible = true,
      properties = {}
    }
  return foodDetection
end
function Map:getFood(X, Y, IsInSand)
  local poisonous = (love.math.random(1,100)>75)
  local qty = love.math.random(-2,5)
  if qty < 0 then qty = 0 end
  local idObj = self:getNextObjectId()
  local food = 
  {
    id = idObj,
    name = "Food_"..tostring(idObj),
    class = "Food",
    shape = "rectangle",
    x = X,
    y = Y,
    width = 32,
    height = 32,
    rotation = 0,
    gid = 54 + (IsInSand and 3 or 0),
    visible = false,
    properties = 
      {
        ["poisonous"] = poisonous,
        ["quantity"] = qty,
        ["detected"] = false
      },
  }
  return food
end
function Map:existFoodAt(Row, Col)
  local gameObjLayer = self:getGameObjLayer()
  local posX = (Col - 1) * self.island.tilewidth
  local posY = (Row - 1) * self.island.tileheight
  for _, obj in pairs(gameObjLayer.objects) do
    if obj.class == "Food" and obj.x == posX and obj.y == posY then
      return true
    end
  end
  return false
end
--
function Map:addFood(NbFood)
  local gameObjLayer = self:getGameObjLayer()
  local placeAvailable = false
  local nbAttempts = 5
  local minrow, maxrow, mincol, maxcol = self:getLayersLimits()
  local landLayers = self:getLandLayers()
  while nbAttempts > 0 and (not placeAvailable or NbFood > 0) do
    placeAvailable = false
    local row = love.math.random(minrow, maxrow)
    local col = love.math.random(mincol, maxcol)
    local layerName = ""
    for _, layer in pairs(landLayers) do
      if layer.data[(row - 1) * self.island.width + col] > 0 then
        layerName = layer.name
        placeAvailable = true
        break
      end
    end
    if placeAvailable and not self:existFoodAt(row, col) then
      local x = (col - 1) * self.island.tilewidth
      local y = (row - 1) * self.island.tileheight
      local food = self:getFood(x, y, layerName == "Sand")
      table.insert(gameObjLayer.objects, food)
      local foodDetection = self:getFoodDetector(x - self.island.tilewidth * 2, y - self.island.tileheight * 2)
      table.insert(gameObjLayer.objects, foodDetection)
      NbFood = NbFood - 1
      nbAttempts = 5
    else
      nbAttempts = nbAttempts - 1
    end
  end
end
--
function Map:addCompass()
  local gameObjLayer = self:getGameObjLayer()
  print("Compass added")
  local minrow, maxrow, mincol, maxcol = self:getLayersLimits()
  local placeAvailable = false
  local landLayers = self:getLandLayers()
  local row, col
  while not placeAvailable do
    placeAvailable = false
    row = love.math.random(minrow, maxrow)
    col = love.math.random(mincol, maxcol)
    for _, layer in pairs(landLayers) do
      if layer.data[(row - 1) * self.island.width + col] > 0 then
        placeAvailable = true
        break
      end
    end
  end
  local compass =
  {
    id = self:getNextObjectId(),
    name = "Compass",
    class = "",
    shape = "rectangle",
    x = (col - 1) * self.island.tilewidth,
    y = (row - 1) * self.island.tileheight,
    width = 32,
    height = 32,
    rotation = 0,
    gid = 66,
    visible = false,
    properties = {},
    remainIslands = love.math.random(2, 10)
  }
  table.insert(gameObjLayer.objects, compass)
  local compassDetector = self:getCompassDetector((col - 2) * self.island.tilewidth, (row - 2) * self.island.tileheight)
  table.insert(gameObjLayer.objects, compassDetector)
end
function Map:getCompassDetector(X, Y)
  local idObj = self:getNextObjectId()
  local detector = 
    {
      id = idObj,
      name = "CompassDetector_"..tostring(idObj),
      class = "Detector",
      shape = "rectangle",
      x = X,
      y = Y,
      width = 160,
      height = 160,
      rotation = 0,
      visible = true,
      properties = {}
    }
  return detector
end
--
function Map:addFountain()
  local gameObjLayer = self:getGameObjLayer()
  print("Fountain added")
  local minrow, maxrow, mincol, maxcol = self:getLayersLimits()
  local placeAvailable = false
  local landLayers = self:getLandLayers()
  local row, col
  while not placeAvailable do
    placeAvailable = false
    row = love.math.random(minrow, maxrow)
    col = love.math.random(mincol, maxcol)
    for _, layer in pairs(landLayers) do
      if layer.data[(row - 1) * self.island.width + col] > 0 then
        placeAvailable = true
        break
      end
    end
  end
  local fountain =
  {
    id = self:getNextObjectId(),
    name = "Fountain",
    class = "",
    shape = "rectangle",
    x = (col - 1) * self.island.tilewidth,
    y = (row - 1) * self.island.tileheight,
    width = 48,
    height = 48,
    rotation = 0,
    gid = 0,
    visible = true,
    properties = {}
  }
  table.insert(gameObjLayer.objects, fountain)
end
--

function Map:getLayersLimits()
  local minrow = self.island.height
  local maxrow = 0
  local mincol = self.island.width
  local maxcol = 0
  local landLayers = self:getLandLayers()
  for _, layer in pairs(landLayers) do
    if minrow > layer.data.minrow then minrow = layer.data.minrow end
    if maxrow < layer.data.maxrow then maxrow = layer.data.maxrow end
    if mincol > layer.data.mincol then mincol = layer.data.mincol end
    if maxcol < layer.data.maxcol then maxcol = layer.data.maxcol end
  end
  return minrow, maxrow, mincol, maxcol
end

Map.__index = Map
return Map
