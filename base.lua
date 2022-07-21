local round = function(num, idp)
  local mult = (10^(idp or 0))
  return math.floor(num * mult + 0.5) *(1/ mult)
end

local function CL(code)
  code = code:lower()
  code = code and string.gsub( code , "#", "") or "FFFFFFFF"
  code = string.gsub( code , " ", "")
  local colors = {1,1,1,1}
  while code:len() < 8 do
    code = code .. "F"
  end
  local r = tonumber( "0X" .. string.sub( code, 1, 2 ) )
  local g = tonumber( "0X" .. string.sub( code, 3, 4 ) )
  local b = tonumber( "0X" .. string.sub( code, 5, 6 ) )
  local a = tonumber( "0X" .. string.sub( code, 7, 8 ) )
  local colors = { r/255, g/255, b/255, a/255 }
  return colors
end

local events = {list={}}
local timers = {tags={}}

local function onTimer(tag)
  timer.performWithDelay( timers[tag].time, timers[tag].func, timers[tag].cycle, tag )
end


local json = require( "json" )
local function openFile(dir)
  local file = io.open( dir, "r" )
 
  local data
  if file then
    local contents = file:read( "*a" )
    io.close( file )
    data = json.decode( contents )
  end
  return data
end

local function saveFile(data,dir)
  local file = io.open( dir, "w" )
 
  if file then
    file:write( json.encode( data ) )
    io.close( file )
  end
end

local texLabel, memLabel
local monitorMem, updateFPS, updateWarnig, fpsLabel, back, deBag, warningGroup

local botsPath = system.pathForFile( "bots.json", system.DocumentsDirectory )
local worldsPath = system.pathForFile( "worlds.json", system.DocumentsDirectory )
local presetPath = system.pathForFile( "preset.json", system.DocumentsDirectory )
local Gbots = {}
local Gmax = nil

local function findMax(bots)
  local Gbots = bots
  local max = 0
  for k, v in pairs(Gbots) do
    if k~="start" then
      max = math.max(Gbots[k].num,max)
    end
  end
  return max
end

local function checkBots()
  local bots = openFile(botsPath)
  if bots==nil then
    print("BOT IS NIL")
    bots={
      start = "sun",
      sun = {num=1,code={}},
      min = {num=2,code={}},
      idol = {num=3,code={11,9,11,11,14,13,10,8,0,16,9,11,0,11,1,10,11,5,11,11,11,5,14,9,6,3,13,7,11,0,11,7,11,13,2,13,8,5,11,3,16,2,0,11,12,12,16,9,11,5,11,10,12,4,5,7,14,14,11,15,13,14,1,6}},
      down = {num=4,code={2,11,0,2,7,4,10,13,13,15,0,10,0,13,1,2,11,2,6,11,5,15,14,10,14,3,3,9,2,10,10,5,13,1,12,12,2,12,1,11,9,2,8,11,10,12,1,15,11,13,0,9,4,0,6,5,14,14,6,4,4,1,6,16}},
      up = {num=5,code={11,9,11,11,14,13,10,8,0,16,9,11,0,11,1,10,11,5,11,11,11,5,14,9,6,3,13,7,11,0,11,7,11,13,2,13,8,5,11,3,16,2,0,11,12,12,16,9,11,5,11,10,12,4,5,7,14,14,11,15,13,14,1,6}},
      XD = {num=6,code={11,12,34,6,4,15,5,6,9,25,41,49}},
    }
    -- for i=1, 64 do
    --   bots.min.code[i]=10
    -- end
    for k, v in pairs(bots) do
      if k~="start" then
        for i=#bots[k].code+1, 64 do
          bots[k].code[i]=11
        end
      end
    end
   
  end
  --[[ 
  abc = {11,11,11}
  abc = {num=1,code = {11,11,11}}
  ]]
  local noneNum = false
  local max = 0
  for k, v in pairs(bots) do
    if k~="start" then

      if bots[k].num~=nil then
        max = math.max(bots[k].num,max)
      else
        noneNum = true
      end

    end
  end


  if noneNum then
    for k, v in pairs(bots) do
      if k~="start" then
        if bots[k].num==nil then
          bots[k].code = {unpack(bots[k])}
          for i=1, 64 do
            bots[k][i] = nil
          end
          max = max + 1
          bots[k].num = max
        end
      end
    end
  end
  --[[ 
  abc = {11,11,11}
  abc = {num=1,code = {11,11,11}}
  ]]

  if bots.start==nil or bots.start.code~=nil then
    bots.start = "sun"
    max = max + 1
    bots.sun = {code = {}, num = max}
    for i=1, 64 do
      bots.sun.code[i]=11
    end
    saveFile(bots, botsPath)
  end

  if bots[bots["start"]]==nil then
    max = max + 1
    bots.start = "sun"
    bots.sun = {code = {}, num = max}
    for i=1, 64 do
      bots.sun.code[i]=11
    end
  end
  saveFile(bots, botsPath)

  -- for k, v in pairs(bots) do
  --   if k~="start" then
  --     if bots[k]["1"]~=nil then
  --       -- print(k,"changed")
  --       for i=1, 64 do
  --         local j = tostring(i)
  --         bots[k].code = {}
  --         bots[k].code[i] = bots[k][j]
  --         bots[k][j] = nil
  --       end
  --     end
  --   end
  --   saveFile(bots, botsPath)
  -- end
  -- local bots = openFile(bVVotsPath)
  -- for k,v in pairs(bots) do
  --   if k~="start" then
  --     local code = {}
  --     for i=1, 64 do
  --       code[i] = bots[k][tostring(i)]
  --       bots[k][tostring(i)] = nil
  --     end
  --     bots[k] = code
  --   end
  -- end
  -- saveFile(bots, bVVotsPath)
end

local function loadBots()
  local bots = openFile(botsPath)

  local max = 0
  for k, v in pairs(bots) do
    if k~="start" then
      max = math.max(bots[k].num,max)
    end
  end

  if bots.start==nil or bots.start.code~=nil then
    bots.start = "sun"
    max = max + 1
    bots.sun = {code = {}, num = max}
    for i=1, 64 do
      bots.sun.code[i]=11
    end
    saveFile(bots, botsPath)
  end

  if bots[bots["start"]]==nil then
    bots["start"] = "sun"
    max = max + 1
    bots["sun"] = {code = {}, num = max}
    for i=1, 64 do
      bots.sun.code[i]=11
    end
    saveFile(bots, botsPath)
  end

  return bots
end


local function loadPresets()
  local presets = openFile(presetPath)

  if presets==nil then
    presets = {
      {
        ["dopInfo"] = {
          ["i"] = 1,
          ["name"] = "СТАНДАРТ ВОДОЁМ",
          ["type"] = "sea",
        },
        ["colors"] = {
          ["wallscolor"] = "CC11CC",
          ["diedcolor"] = "999999",
          ["backgroundcolor"] = "191919",
          ["suncolor"] = "FF00FF",
          ["outlinecolor"] = "FF00FF",
          ["mineralcolor"] = "2255DD",
        },
        ["bots"] = {
          ["dmg"] = "25",
          ["movecost"] = "8",
          ["teleportdmg"] = "25",
          ["diedenergy"] = "300",
          ["hp"] = "100",
          ["maxlive"] = "2000",
          ["livecost"] = "1",
          ["startenergy"] = "200",
          ["maxenergy"] = "1000",
        },
        ["world"] = {
          ["maxsun"] = "12",
          ["wallstype"] = 1,
          ["maxsunwinter"] = "8",
          ["width"] = "60",
          ["height"] = "60",
          ["minsun"] = "2",
          ["mineralenergy"] = "4",
          ["winter"] = 1,
          ["mineralspace"] = "5",
        },
      }
    }
    saveFile(presets, presetPath)
  end

  return presets
end


local worldsTable = {
  options = {
    start = 1,
  },
  worlds = {
    {
      ["dopInfo"] = {
        i = 1,
        name = "test1",
        type = "sea",
        map = world, 
        createDate={day={12,02,22}, time={20,31,57}},
        date={day={12,02,22}, time={20,31,57}}, 
        population = 2256, 
        steps = 1300,
        drawmode = 1,
        comm = "Первый мир для теста",
      },
      ["colors"] = {
        ["wallscolor"] = "334dcc",
        ["diedcolor"] = "999999",
        ["backgroundcolor"] = "191919",
        ["suncolor"] = "FF00FF",
        ["outlinecolor"] = "FF00FF",
      },
      ["bots"] = {
        ["dmg"] = "25",
        ["movecost"] = "8",
        ["teleportdmg"] = "25",
        ["diedenergy"] = "300",
        ["hp"] = "100",
        ["maxlive"] = "2000",
        ["livecost"] = "1",
        ["startenergy"] = "200",
        ["maxenergy"] = "1000",
      },
      ["world"] = {
        ["maxsun"] = "12",
        ["wallstype"] = 1,
        -- ["maxsunwinter"] = "8",
        ["width"] = "60",
        ["height"] = "60",
        ["minsun"] = "2",
        ["mineralenergy"] = "4",
        -- ["winter"] = 1,
        ["mineralspace"] = "5",
      },
    },
    {name = "Lolotype"},
    {name = "Potype"},
    {name = "Sototype"},
    {name = "Xotype"},
  }
}

local function saveWorlds(worlds)
  saveFile(worlds, worldsPath)
end

local function loadWorlds(id)
  local worldsTable = openFile(worldsPath)
  worldsTable = worldsTable or 
  {
    options = { start = 1 },
    worlds = {}
  }
  if id==nil then
    return worldsTable
  else
    return worldsTable.worlds[id]
  end
end

local function removeWorld(id)
  local worldsTable = loadWorlds()
  
  table.remove(worldsTable.worlds, id)  

  if worldsTable.options.start>id then
    worldsTable.options.start = worldsTable.options.start - 1
  end

  local start = worldsTable.options.start
  if start==id then
    worldsTable.worlds.start = 0
  end

  saveFile(worldsTable, worldsPath)
end


local function addWorld(name, params)
  -- world, bots, step, drawmode, viewPoint, w, h, blockSize, sunSize, maxSun

  local worldsTable = loadWorlds()

  local numberInWorlds = #worldsTable.worlds+1
  for i=1, #worldsTable.worlds do 
    if worldsTable.worlds[i].world.name == name then
      numberInWorlds = i
      break
    end
  end
  
  params.dopInfo.drawmode = (params.dopInfo.drawmode<1) and 1 or params.dopInfo.drawmode
  params.dopInfo.i = numberInWorlds

  worldsTable.worlds[numberInWorlds] = params
  saveFile(worldsTable, worldsPath)
  return numberInWorlds
end

local stopGame = function()
  timer.cancel("check")
end
local function printTable(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or false
  depth = depth or 0

  local tmp = string.rep(" ", depth)

  if name then
   if type(name)=="string" then name = '"'..name..'"' end
    tmp = tmp .. "[".. name .. "] = "
  end

  if type(val) == "table" then
      tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

      for k, v in pairs(val) do
          tmp =  tmp .. printTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
      end

      tmp = tmp .. string.rep(" ", depth) .. "}"
  elseif type(val) == "number" then
      tmp = tmp .. tostring(val)
  elseif type(val) == "string" then
      tmp = tmp .. string.format("%q", val)
  elseif type(val) == "boolean" then
      tmp = tmp .. (val and "true" or "false")
  else
      tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
  end

  return tmp
end

local warningShowed = false
local cx = round(display.contentCenterX)
local cy = round(display.contentCenterY)
local fullw  = round(display.actualContentWidth)
local fullh  = round(display.actualContentHeight)
local base = {
  cx = cx,
  cy = cy,
  fullw = fullw,
  fullh = fullh,

  checkBots = checkBots,
  printTable = printTable,

  valPrint = function(names,values, newStroke)
    local out = ""
    for i=1, #names do
      out = 
      out..(newStroke==true and "" or "  ")..
      names[i]..": "..tostring(values[i])..
      (newStroke==true and "\n" or ";")
    end
    if newStroke==nil or newStroke==false then out = out:sub(3,out:len()) end 
    print(out)
  end,
  debag = function()
    deBag = display.newGroup() 
    deBag.y=round(display.actualContentHeight)-200
    
    back = display.newRect( deBag, 0, -15, 220,180 )
    back.anchorX=0
    back.anchorY=0
    back.fill={0,0,0}
    back.alpha=.5
    
    fpsLabel = display.newText( deBag, "0FPS", 10, -5, native.systemFont, 50 )
    fpsLabel.anchorX=0
    fpsLabel.anchorY=0
    fpsLabel.last=0
    local function fillDiff(label, diff)
      label.fill=((diff==0 and {1,1,1} or (diff<0 and {0,1,0} or {1,0,0})))
    end 
    updateFPS = function()
      local fps = display.fps
      local diff = fps - fpsLabel.last
      fpsLabel.last = fps
      fpsLabel.text = fps.."FPS"
      fillDiff(fpsLabel, diff)
    end
    
    memLabel = display.newText( deBag, "0KB", 10, 45, native.systemFont, 50 )
    memLabel.anchorX=0
    memLabel.anchorY=0
    memLabel.last = 0
    
    texLabel = display.newText( deBag, "0KB", 10, 95, native.systemFont, 50 )
    texLabel.anchorX=0
    texLabel.anchorY=0
    texLabel.last = 0
    monitorMem = function()
      collectgarbage()
      local mem = round(collectgarbage("count"))
      local tex = round((system.getInfo( "textureMemoryUsed" )*(1/8))*(1/1024))
      local memT, texT
      if mem<1024 then
        memT = mem.."KB"
      else
        memT = round((mem*(1/1024)),2).."MB"
      end
      if tex<1024 then
        texT = tex.."KB"
      else
        texT = round((tex*(1/1024)),2).."MB"
      end
      memLabel.text = memT
      texLabel.text = texT
      fillDiff(memLabel, (mem-memLabel.last))
      fillDiff(texLabel, (tex-texLabel.last))
      memLabel.last = mem
      texLabel.last = tex
    end
  
    timer.performWithDelay( 1000, monitorMem, 0, "debag" )
    timer.performWithDelay( 3000, updateFPS, 0, "debag" )
    monitorMem()
    updateFPS()
  end,
  graphicsOpt = graphicsOpt,
  options = options,

  saveWorlds = saveWorld,
  removeWorld = removeWorld,
  addWorld = addWorld,
  loadWorlds = loadWorlds,

  CL = CL,
  div = function(num, hz)
    return num*(1/hz)-(num%hz)*(1/hz)
  end,
  getAngle = function(sx, sy, ax, ay)
    return (((math.atan2(sy - ay, sx - ax) *(1/ (math.pi *(1/ 180))) + 270) % 360))
  end,
  getCathetsLenght = function(hypotenuse, angle)
    angle = math.abs(angle*math.pi/180)
    local firstL = math.abs(hypotenuse*(math.sin(angle)))
    local secondL = math.abs(hypotenuse*(math.sin(90*math.pi/180-angle)))
    return firstL, secondL
  end,
  addBot = function(key, bot)
    local Bots = loadBots()
    if Bots[key]==nil then
      
      Bots[key] = {code = bot, num = findMax(Bots) + 1}
    elseif key=="start" then
      Bots[key] = bot
    else
      Bots[key].code = bot
    end
    saveFile(Bots, botsPath)
  end,
  removeBot = function(key)
    if key=="sun" or key=="min" then return end
    local Bots = loadBots()
    local num = Bots[key].num
    local start = Bots.start
    if start==key then 
      start = "sun"
    end
    Bots.start = nil
    Bots[key] = nil
    for k, v in pairs(Bots) do
      if Bots[k].num>num then
        Bots[k].num = Bots[k].num - 1
      end
    end
    Bots.start = start
    saveFile(Bots, botsPath)
  end,
  loadBots = loadBots,
  
  loadPresets = loadPresets,
  addPreset = function()
  end,

  event = {
    add = function(name, butt, funcc)
    	events.list[#events.list+1]=name
    	events[name]={eventOn=false, but=butt, func=funcc}
    end,
    remove = function(name, enable)
      if name==true then
        for i=1, #events.list do
          -- print(events.list[i])
          local event = events[events.list[i]]
          event.but:removeEventListener("tap", event.func)
        end
        events = {list={}}
      else
        local event = events[name]
        event.but:removeEventListener("tap", event.func)
        events[name]=nil
        for i=1, #events.list do
          if events.list[i]==name then
            -- print("nice")
            table.remove(events.list,i)
            break
          end
        end
      end
    end,
    off = function(name, enable)
      if name==true then
        for i=1, #events.list do
          local event = events[events.list[i]]
          if event.eventOn==true then
            event.but:removeEventListener("tap", event.func)
          end
        end
      else
      	local event = events[name]
      	event.eventOn = enable or false
      	event.but:removeEventListener("tap", event.func)
      end
    end,
    on = function(name, enable)
      if name==true then
        for i=1, #events.list do
          local event = events[events.list[i]]
          -- print(events.list[i])
          if event.eventOn==true then
            -- print("ds")
            event.but:addEventListener("tap", event.func)
          end
        end
      else
      	local event = events[name]
      	events.eventOn = enable or true
        if events~=nil then
      	 event.but:addEventListener("tap", event.func)
        end
      end
    end
  },
  stopGame = stopGame,

  timer = {
    add = function(tag, time, func, cycle)
      timers.tags[#timers.tags+1]=tag
      timers[tag] = {enabled=true, func=func, time=time, cycle = cycle or 1}
     
    end,
    restart = function(tag)
      timer.cancel(tag)
      onTimer(tag)
    end,
    remove = function(tag)
      timer.cancel(tag)
      timers[tag]=nil
      for i=1, #timers.tags do
        if timers.tags[i]==tag then
          table.remove(timers.tags, i)
          break
        end
      end
    end,
    off = function(tag, enable)
      if tag==true then
        for i=1, #timers.tags do
          local tag = timers.tags[i]
          if timers[tag].enabled==true then
            timer.cancel( tag )
          end
        end
      else
        timer.cancel( tag )
        timers[tag].enabled = enable or false
      end
    end,
    on = function(tag, enable)
      if tag==true then
        for i=1, #timers.tags do
          local tag = timers.tags[i]
          if timers[tag].enabled==true then
            onTimer(tag)
          end
        end
      else
        timers[tag].enabled = enable or true
        onTimer(tag)
      end
    end
  },
  round = round,
  }

return base
