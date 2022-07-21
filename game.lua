local composer = require( "composer" )
local scene = composer.newScene()

system.activate( "multitouch" )


local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 5 )

local backGroup, mainGroup, mainCellGroup, uiGroup, leftButtonsGroup

local q = require"base"

local greed = {}
local cellSize
local cubeSize 
local w, h
local worldType

local c = {
	wall = nil,
	backGround = nil,
	sun = nil,
	died = nil,
}
local draw = true --false
local drawRotate = false
local function genSize(sizeW,sizeH)
	cubeSize = math.max(sizeW,sizeH)
	local cray
	local screen = {w=q.fullw, h=q.fullh}
	
	if q.fullw<q.fullh then
		if (q.fullw/q.fullh) > (sizeW/sizeH) then
			-- print("-[]-")
			if sizeW<sizeH then
				-- print("a")
				cray = screen.h * (sizeH/(sizeH+2))
			else
				-- print("b")
				cray = screen.w * (sizeW/sizeH)
			end
		else
			-- print("-\n[]\n-")
			if sizeW<sizeH then
				-- print("a")
				cray = screen.w * (sizeW/(sizeW+2)) * (sizeH/sizeW)
			else
				-- print("b")
				cray = screen.w * (sizeW/(sizeW+2)) 
			end
		end
	else
		local screen = {w=q.fullw, h=q.fullh}
		if (screen.w/screen.h) > (sizeW/sizeH) then
			print("-[]-")
			if sizeW<sizeH then
				print("a")
				cray = screen.h
			else
				print("b")
				cray = screen.h * (sizeW/sizeH)
			end
		else
			print("-\n[]\n-")
			if sizeW<sizeH then
				print("a")
			else
				print("b")
				cray = screen.w --* (sizeH/sizeW) 
			end
		end
	end
	cellSize = cray/cubeSize--math.floor(q.fullw/cubeSize)
	w, h = math.floor(sizeW), math.floor(sizeH)--math.floor(cubeSize*(q.fullh/q.fullw))
end
local function removeCell(x,y)
	local buteNum = y~=nil and x+w*(y-1) or x
	-- if greed[buteNum] and greed[buteNum].body then 
		display.remove(greed[buteNum].body)
	-- end
	greed[buteNum]=nil
	buteNum, x, y = nil, nil, nil
end
--[[
2 3 4 5, 1
]]
local eventsList = {}

local function addList(tag,events)
	eventsList[tag] = events
end

local function onList(tag)
	for i=1, #eventsList[tag] do
		q.event.on(eventsList[tag][i])
	end
end
local function offList(tag)
	for i=1, #eventsList[tag] do
		q.event.off(eventsList[tag][i])
	end
end
local function addCellBody(cell,x,y)
	cell.body = display.newRect( 
		mainCellGroup, 
		cellSize*(x-.5), 
		cellSize*(y-.5), 
		cellSize*.6,--*(18/20), 
		cellSize*.6--*(18/20) 
	)
	cell.body.fill= c.died
end
local function addCell(x,y)
	local buteNum = x+w*(y-1)
	if greed[buteNum]~=nil then return end
	-- removeCell(buteNum)
	local cell = {} 
	if draw then 
		addCellBody(cell,x,y)
	end
	cell.func="food"
	
	greed[buteNum] = cell
	buteNum, x, y, cell = nil, nil, nil, nil
end

local function addWall(x,y)
	local buteNum = x+w*(y-1)
	local cell = display.newRect( 
		mainCellGroup, 
		cellSize*(x-1), 
		cellSize*(y-1), 
		cellSize,--*(18/20), 
		cellSize--*(18/20) 
	)
	cell.fill = c.wall
	cell.anchorX=0
	cell.anchorY=0
	cell.func = "wall"
	cell.hp = 200
	
	greed[buteNum] = cell
end


local coloriseBot 


local pop -- поп с информацией о клетке
local width = 700
local height = width*1.1
local down = -height*.5
local left = -width*.5
local function removePop()
	transition.to( leftButtonsGroup, {x=0, time=500} )
	q.event.remove("editGen")
	q.event.remove("save1dop")
	q.event.remove("rodView")
	q.event.remove("rod2View")
	q.event.remove("close1dop")
	display.remove(pop)
	if pop~=nil and pop.bot~=nil and pop.bot.body~=nil then
		color = coloriseBot(pop.bot)
		if color then
			pop.bot.body.fill = color
		end
	end 
	pop=nil
end
-- local function checkPop()
-- 	if pop==nil then return end
-- 	if pop.bot.body.x==nil then removePop() return end
-- 	pop.x, pop.y = pop.bot.allBody.x, pop.bot.allBody.y
	
-- 	local rightSide = 0>(pop.x-(width*pop.xScale)-39)--pop.bot.x<math.floor(w/2)
-- 	-- display.newRect(mainGroup, pop.x-(width*pop.xScale)-39, pop.y, 200, 200)
-- 	pop.strelka.x = rightSide and 70 or -70
-- 	pop.popIn.x= rightSide and (50+width*.5) or (-50-width*.5)
	
-- 	-- local scale = (q.fullw*.45)/width
-- 	local downSide = cellSize> (pop.y-(height*pop.xScale*.5))
-- 	-- display.newRect(mainGroup, pop.x, pop.y-(height*pop.xScale*.5), 20, 20)
-- 	local upSide = cellSize*h< (pop.y+(height*pop.xScale*.5))
-- 	-- display.newRect(mainGroup, pop.x, pop.y+(height*pop.xScale*.5), 20, 20)
-- 	if downSide then
-- 		-- local a = math.ceil((height*.5)/cellSize)--cellSize*a-
-- 		pop.popIn.y = (height*.5)-5 - (pop.bot.y-1) *cellSize
-- 	elseif upSide then
-- 		local a = math.ceil((height*.5)/cellSize)
-- 		pop.popIn.y = cellSize*(h-a)-pop.y
-- 	end
-- end
local isDevice = (system.getInfo("environment") == "device")
local function checkPop()
	if pop==nil then return end
	if pop.bot.body.x==nil then removePop() return end
end


local function textSize(text,maxSize)
	local scale = (maxSize / text.width)
	if scale<1 then
		return scale
	else
		return 1
	end
end
local step = 0
local lblStep

local lblPopulation, lblRelatives

local startEnergy = 200
local diedBodyEnergy = 300
local maxEnergy = 1000
local newOld = 2000
local moveCost = 8
local liveCost = 1

local bots = {}
local draw4Code = {}
local drawmode = 1

local sunBack
local counter = 5000
local zima = false
local nowZima = false
local maxSun = 8
local lowSun = 1
local mineralEn = 4

local dmg = 25
local teleportDMG = 25
local botHp = 100

local minRodDna = 32+32 --по какую днк проверять родство

local colorsDna = {
	q.CL"774C60",
	q.CL"B75D69",
	q.CL"60D394",
	q.CL"FFD97D",
	q.CL"FF9B85",
}

local blockSize = 96
local sunSize = 32+16 --чётное

local sunMap = {}

local function sunHowMuch(bot)
	local sunEn
	local x, y = (bot.x-1)%#sunMap+1, (bot.y-1)%#sunMap+1

	if not nowZima then
		sunEn = math.floor((10 - math.floor((bot.y-2)*(10/(h*.6)))))
	else
		sunEn = math.floor((8 - math.floor((bot.y-2)*(8/(h*.4)))))
	end
	sunEn = sunMap[x][y]*maxSun
	return sunEn
end



local guideLabel
local guideTimer
local backGuide
local needGuide = true
local function showAndHideBackGuide(text,y)
	if not needGuide then return end
	guideLabel.text = text
	if y then guideLabel.y = y end
	backGuide.x, backGuide.y, backGuide.width, backGuide.height = guideLabel.x, guideLabel.y - guideLabel.height*.5, guideLabel.width+40,guideLabel.height+40 


	if guideTimer then timer.cancel(guideTimer) end
	transition.cancel( "guide" )
	transition.to( guideLabel, {time=200, alpha=1, tag="guide"} )
	transition.to( backGuide, {time=200, alpha=1, tag="guide"} )
	guideTimer = timer.performWithDelay( 6000, function()
		
		transition.to( guideLabel, {time=1000, alpha=0, tag="guide"} )
		transition.to( backGuide, {time=1000, alpha=0, tag="guide"} )
		guideTimer = nil
	end)
end

local groupsColors = {
	q.CL"F9C80E",
	q.CL"F86624",
	q.CL"EA3546",
	q.CL"662E9B",
	q.CL"43BCCD",

	q.CL"FFCB77",
	q.CL"227C9D",
	q.CL"FDFCDC",
	q.CL"b48291",

}

coloriseBot = function(bot, draw)
	draw = draw or drawmode
	local color
	if draw==1 then --"eat"
		local all = bot.eated + bot.sun + bot.mineted
		if all==0 then
			-- color = {	.5, .5, .5}
		else
			color = {	.3+bot.eated/all*2.8, .3+bot.sun/all*.5-bot.eated/all*3, .3+bot.mineted/all*.5-bot.eated/all*.8}
		end
	elseif draw==2 then --"energy"
		color = {	.8+bot.energy/maxEnergy*.2, .8-bot.energy/maxEnergy*.4, 0}
	elseif draw==3 then --"old"
		color = {	.1+bot.new/newOld*.7, .1+bot.new/newOld*.7, 1}
	elseif draw==4 then --"old"
		color = groupsColors[bot.zoneNum]
	end
	return color
end

local createList
local function checkOutRange(num,max)

	-- while num>max do num = num - max end
	num = (num-1)%max + 1
	while num<1 do num = num + max end
	return num
end
local function colorMulti(color,m)
	color[1] = color[1] * m
	color[2] = color[2] * m
	color[3] = color[3] * m
	return color
end

local stopTimerIcon, TimerIcon, checkAll
local simOnGoing = false
local function startSim()
	timer.cancel("check")
	timer.performWithDelay( 20, checkAll, 0, "check" )
	simOnGoing = true
	TimerIcon.alpha=0
	stopTimerIcon.alpha=1
end
local function stopSim()
	timer.cancel("check")
	simOnGoing = false
	TimerIcon.alpha=1
	stopTimerIcon.alpha=0
end

local listGroups = {}
local function genEditor(cod, bot)
	q.event.off("clearAll")
	q.event.off("timerStart")
	-- q.event.off("skip")
	q.event.off("guide")
	q.event.off("toMenu")
	q.event.off("loadBots")
	q.event.off("deleteBot")
	q.event.off("oneStep")
	q.event.off("viewChange")
	q.event.off("canMoveCube")
	q.event.off("spawnMode")
	q.event.off("saveWorld")



	q.event.off("editGen")
	q.event.off("save1dop")
	q.event.off("rodView")
	q.event.off("rod2View")
	q.event.off("close1dop")
	
	stopSim()
	
	local code = {unpack(cod)}
	for i=1, #cod do
		code[i] = {cmd=code[i]} 
	end
	local drawGroup = display.newGroup()
	uiGroup:insert(drawGroup)

	local newBack = display.newRect( drawGroup, q.cx, q.cy, q.fullw, q.fullh)
	newBack:setFillColor( unpack(q.CL"1A1423")) newBack=nil
	-- newBack.fill = {type="image", path=""}
	-- local newBack = display.newImageRect( drawGroup,"back.jpg", q.fullw, q.fullh)
	-- newBack.x, newBack.y = q.cx, q.cy
	-- newBack:setFillColor( .4 ) newBack=nil

	local spase = 10
	local size = (math.min(q.fullh,q.fullw)-spase*11)/9

	local left = (q.fullw-(size*8 + spase*7))*.5 
	local down = (q.fullh-(size*8 + spase*7))*.5 
	local fall = 0
	local fallTP = 0
	local infoText = {}
	-- local inOptText = {
	-- 	rotate={"Перед собой","на num градусов"},
	-- 	erg={"Меньше ли num энергии"},
	-- }
	local inOptText = ""
	-- local r = {"Перед собой","на num градусов"}
	-- local erg = {"Меньше ли num энергии"}
	local rod = 0
	local info = 0

	local x = bot.gen[bot.workingDna].step + 0
	-- while x>#cod do
	-- 	x = x - #cod
	-- end
	x = (x-1)%(#cod) + 1
	local first = x + 0
	local changePos = false

	local dopInfo = false

	local preview = {}
	local labels ={
			"Поворот", 
			"Перемещение", 
			"Перемещение+",
			"Посмотреть", 
			"Посмотреть+", 
			"Съесть", 
			"Съесть+",
			"Дать энергию", 
			"Дать энергию+", 
			"Минерал в эн", 
			"Фотосинтез",
			"Энергии меньше?", 
			"Окружен?", 
			"Есть минералы?", 
			"Размножиться", 
			"Размножиться+", 
			"-",
			"Стэк",
		}

	local list

	local dirS = {
		[0]="влево вверх","вверх","вправо вверх",
	     	"вправо","вправо вниз","вниз","влево вниз","влево"              
	}

	local colorsQ = 
	{
		startPos = {1*.8,.5*.8,.5*.8},
		newPos = {1,.5,.5},
		command = {1},
		info = {.9,.9,1},
		teleport = {1,1,.9},
		nothing = {1,.8,1},
		text = {0}, 
	}

	colorsQ = 
	{
		startPos = q.CL"fe7f2d",
		newPos = q.CL"fcca46",
		command = q.CL"233d4d",
		info = q.CL"233d4d",
		teleport = q.CL"233d4d",
		nothing = q.CL"233d4d",

		infoText = q.CL"a1c1e1",
		teleportText = q.CL"a1c181",
		nothingText = q.CL"B75D69",

		posText = q.CL"233d4d",
		text = {.8,.9,.8}, 

		button = q.CL"233d4d",

	}
	colorsQ.info = colorMulti(colorsQ.info, .65)
	colorsQ.nothing = colorMulti(colorsQ.nothing, .65)
	colorsQ.teleport = colorMulti(colorsQ.teleport, .65)
	
	colorsQ.posText = colorMulti(colorsQ.posText, .65)

	-- colorsQ.button = colorMulti(colorsQ.button, .65)

	local function updateIcons()
		fall, fallTP = 0, 0
		print("==")
		for KK=1, #code do

			-- local posY = math.floor((KK-1)/8)+1
			-- local posX = KK - (posY-1)*8
			local k = KK + x - 1

			-- while k>#code do k = k - #code end
			k = (k-1)%(#code) + 1
			display.remove(preview[k].image)

			if fall==0 and fallTP==0 then
				local path
				local cmd = code[k].cmd
				if cmd==1 then
					path = "images/rotate.png"
					inOptText={"rotateDir","Поворот"}
					fall=1
					info=1
				elseif cmd==2 then
					path = "images/move.png"
					fall=1
					fallTP=5
					inOptText={"rotate","Сходить"}
					infoText = {[0]="Сходил на","пусто","стена","еда","бот","родня"}
					rod=k
					info=1
				elseif cmd==3 then
					path = "images/move.png"
					fall=1
					fallTP=5
					inOptText={"rotateDir","Сходить"}
					infoText = {[0]="Сходил на","Пусто","Стена","Еда","Бот","Родня"}
					rod=k
					info=1
				elseif cmd==4 then
					path = "images/view.png"
					fall=1
					fallTP=5
					inOptText={"rotate","Посмотреть"}
					infoText = {[0]="Посмотрел на","Пусто","Стена","Еда","Бот","Родня"}
					rod=k
					info=1
				elseif cmd==5 then
					path = "images/view.png"
					fall=1
					fallTP=5
					inOptText={"rotateDir","Посмотреть"}
					infoText = {[0]="Посмотрел на","Пусто","Стена","Еда","Бот","Родня"}
					rod=k
					info=1
				elseif cmd==6 then
					path = "images/eat.png"
					fall=1
					fallTP=3
					inOptText={"rotate","Съесть"}
					infoText = {[0]="Съел","Пусто","Еда","Бот"}
					rod=k
					info=1
				elseif cmd==7 then
					path = "images/eat.png"
					fall=1
					fallTP=3
					inOptText={"rotateDir","Съесть"}
					infoText = {[0]="Съел","Пусто","Еда","Бот"}
					rod=k
					info=1
				elseif cmd==8 then
					path = "images/giveenergy.png"
					fall=1
					fallTP=3
					inOptText={"rotate","Дать энергию"}
					infoText = {[0]="Дал энергию","Пусто","Бот","Родня"}
					rod=k
					info=1
				elseif cmd==9 then
					path = "images/giveenergy.png"
					fall=1
					fallTP=3
					inOptText={"rotateDir","Дать энергию"}
					infoText = {[0]="Дал энергию","Пусто","Бот","Родня"}
					rod=k
					info=1
				elseif cmd==10 then
					path = "images/min.png"
				elseif cmd==11 then
					path = "images/sun.png"
				elseif cmd==12 then
					path = "images/ifenergy.png"
					fall=1
					fallTP=2
					inOptText={"energy"}
					infoText = {[0]="У бота","Меньше","Больше"}
					rod=k
					info=1
				elseif cmd==13 then
					path = "images/ifspase.png"
					infoText = {[0]="Бот","Окружен","Свободен"}
					rod=k
					fallTP=2
				elseif cmd==14 then
					path = "images/min_li.png"
					infoText = {[0]="Минералы","Получает","Не получает"}
					rod=k
					fallTP=2
				elseif cmd==15 then
					path = "images/razm.png"
					inOptText={"rotate","Размножиться"}
					fall=1
					info=1
				elseif cmd==16 then
					path = "images/razm.png"
					inOptText={"rotate","Размножиться"}
					fall=1
					info=1
				-- elseif cmd==17 then
				-- 	path = "dna.png"
					
				-- 	inOptText = {"codein","Заразитdь кодом","Cколькdо перенести","ss"}
				-- 	infoText = {[0]="Дал энергию","Пусто","Бот","Родня","Родня","Родня","Родня","Родня","Родня","Родня","Родня","Родня","Родня"}
				-- 	fall=3
				-- 	fallTP=code[checkOutRange(k+2,#code)].cmd
				-- 	info=1
				elseif cmd==18 then
					path = "images/ret.png"
				else
					path=cmd
				end

				if type(path)=="string" then
					local image = display.newImageRect(	drawGroup, path, size*.9,size*.9 )
					image.x, image.y = preview[k].rect.x+preview[k].rect.width*.5, preview[k].rect.y+preview[k].rect.width*.5
					preview[k].image=image
					preview[k].rect.fill = colorsQ.command
					preview[k].text = labels[cmd]
					preview[k].type={"cmd"}
				else
					-- print(path,"num")
					local image = display.newText(	drawGroup, tostring(path),preview[k].rect.x+preview[k].rect.width*.5, preview[k].rect.y+preview[k].rect.width*.5, native.newFont( "consola.ttf" ), 50 )
					image:setFillColor( unpack(colorsQ.nothingText) )
					preview[k].image=image
					preview[k].type={"cmd"}
					preview[k].rect.fill = colorsQ.nothing
				end
				print(k,first)
				if k==first then
					print("SUKAAA")
					preview[k].rect.fill = colorsQ.startPos
					if (preview[k].type=="cmd" and cmd>16) or (preview[k].type~="cmd") then
						preview[k].image:setFillColor( unpack(colorsQ.posText) )
					end 
				end
				if k==x then
					preview[k].rect.fill = colorsQ.newPos
					if (preview[k].type=="cmd" and cmd>16) or (preview[k].type~="cmd") then
						preview[k].image:setFillColor( unpack(colorsQ.posText) )
					end 
				end
			else
				if fall~=0 then
					local image = display.newText(	drawGroup, code[k].cmd, preview[k].rect.x+preview[k].rect.width*.5, preview[k].rect.y+preview[k].rect.width*.5, native.newFont( "consola.ttf" ), 50 )
					image:setFillColor( unpack(colorsQ.infoText) )
					preview[k].image=image
					preview[k].rect.fill = colorsQ.info
					preview[k].type={"option",{unpack(inOptText)}}
					if inOptText[1]=="rotateDir" then
						local r = 45*(code[k].cmd%8)
						if r>180 then
							r =  - 180 +  r - 180
						end
						r = r==0 and ("перед собой") or ("на " .. r .. "`")
						preview[k].text = inOptText[2]..": ".. r

					elseif inOptText[1]=="rotate" then
						local r = (code[k].cmd%8)
						r = dirS[r]
						preview[k].text = inOptText[2]..": ".. r

					elseif inOptText[1]=="energy" then
						preview[k].text = "Меньше ли ".. (code[k].cmd*15) .." энергии"
					elseif inOptText[1]=="codein" then
						if fall==3 then
							preview[k].type={"option",{"codein","В каком направ"}}
						elseif fall==2 then
							preview[k].type={"option",{"codein","Cколько перенести"}}
						else
							preview[k].type={"option",{"codein","С какой cmd"}}
						end
					end
					fall = fall - 1
					if k==first then
						preview[k].rect.fill = colorsQ.startPos
						if (preview[k].type=="cmd" and cmd>16) or (preview[k].type~="cmd") then
							preview[k].image:setFillColor( unpack(colorsQ.posText) )
						end
					end
				else
					preview[k].type={"plus"}
					local image = display.newText(	drawGroup, code[k].cmd, preview[k].rect.x+preview[k].rect.width*.5, preview[k].rect.y+preview[k].rect.width*.5, native.newFont( "consola.ttf" ), 50 )
					image:setFillColor( unpack(colorsQ.teleportText) )
					preview[k].image=image
					preview[k].rect.fill = colorsQ.teleport
					preview[k].text = (infoText[0] or "")..": "..(infoText[#infoText-fallTP+1] or "")
					preview[k].rod = rod
					fallTP = fallTP - 1
					if k==first then
						preview[k].rect.fill = colorsQ.startPos
						if (preview[k].type=="cmd" and cmd>16) or (preview[k].type~="cmd") then
							preview[k].image:setFillColor( unpack(colorsQ.posText) )
						end
					end
				end

			end
		end
	end
	local function spisok(event)
		if list~=nil then return end
		-- display.remove(list)
		list = display.newGroup()
		drawGroup:insert(list)
		local scaleWith = math.min(q.cx,q.cy)
		local backSize = {x=500,y=250}

		if (event.target.x+size*.5+backSize.x*(scaleWith/backSize.x))<q.fullw then
			list.x = event.target.x + size*.5
		else
			list.x = event.target.x - backSize.x*(scaleWith/backSize.x) + size*.5
		end

		list.y = event.target.y + size*.5
		
		if list.y+backSize.y*(scaleWith/backSize.x)>q.fullh then
			list.y = list.y - backSize.y*(scaleWith/backSize.x)
		end
		local back = display.newRect(list, 0, 0, backSize.x, backSize.y)
		list.xScale = scaleWith/backSize.x
		list.yScale = scaleWith/backSize.x
		back.fill={.2}
		back.alpha=.9
		back.anchorX=0
		back.anchorY=0

		local backLeft = display.newRect(list, 30, 30+(200-30*2)*.5-10, 90, 200-30*2)
		backLeft.fill={.28}
		backLeft.anchorX=0
		backLeft.anchorY=0

		local tapIcon = display.newPolygon( list, (backLeft.x+backLeft.width*.5)-10, backLeft.y+backLeft.height*.5, {0,-35, 35,0, 0,35})
		tapIcon.rotation=180

		local backRight = display.newRect(list, 500-30, 30+(200-30*2)*.5-10, 90, 200-30*2)
		backRight.fill={.28}
		backRight.anchorX=1
		backRight.anchorY=0

		local tapIcon = display.newPolygon( list, (backRight.x-backRight.width*.5)+10, backRight.y+backRight.height*.5, {0,-35, 35,0, 0,35})

		local backInfo = display.newRect(list, 250, 30, 450, (200-30*2)*.5-10)
		backInfo.fill={.45}
		backInfo.anchorY=0

		local backCmd = display.newRect(list, 250, 250-20, 200, 200-30*2-20)
		backCmd.fill={.35}
		backCmd.anchorY=1

		local cmdlbl = display.newText(
			list, code[event.target.i].cmd,
			250,backCmd.y-backCmd.height*.5,
			native.newFont("consola.ttf"),45)

		local infolbl = display.newText(
			list, code[event.target.i].cmd<=#labels and labels[code[event.target.i].cmd] or "+"..tostring(code[event.target.i].cmd),
			250,backInfo.y+backInfo.height*.5,
			native.newFont("consola.ttf"),38)
		infolbl.xScale = (backInfo.width-20)/infolbl.width<1 and (backInfo.width-20)/infolbl.width or 1
		-- 
		local last
		local lastColors = { cmd = {1}, option = {.9,.9,1}, plus = {1,1,.9} }
		local function lastColor( last )
			if last then
				preview[last].rect.fill = lastColors[ preview[last].type[1] ]
			end
		end
		local function plusFill ( next, text, first )
			next = (next-1)%(#code) + 1
			preview[first].rect.fill={.7,1,.7}
			preview[next].rect.fill={.7,1,.7}
			infolbl.text = text
			lastColor(last)
			last = next
			return next
		end
		local function chk()
			cmdlbl.text = code[event.target.i].cmd
			local type = preview[event.target.i].type
			-- print(type[1],event.target.i)
			if type[1]=="cmd" then
				if code[event.target.i].cmd<=#labels then
					infolbl.text = labels[code[event.target.i].cmd]
					lastColor(last)
					last = nil
				else
					plusFill( event.target.i+tonumber(code[event.target.i].cmd), "+"..tostring(code[event.target.i].cmd), event.target.i)
				end
			elseif type[1]=="option" then
				local text
				if type[2][1]=="rotateDir" then
					local r = 45*(code[event.target.i].cmd%8)
					if r>180 then
						r =  - 180 +  r - 180
					end
					r = r==0 and ("перед собой") or ("на " .. r .. "`")
					text = type[2][2]..": ".. r

				elseif type[2][1]=="rotate" then
					local r = (code[event.target.i].cmd%8)
					r = dirS[r]
					text = type[2][2]..": ".. r

				elseif type[2][1]=="energy" then
					text = "Меньше ли ".. (code[event.target.i].cmd*15) .." энергии"
				elseif type[2][1]=="codein" then
					text = type[2][2]
				end
				infolbl.text = text
			elseif type[1]=="plus" then
			
				plusFill( preview[event.target.i].rod+tonumber(code[event.target.i].cmd), preview[event.target.i].text, preview[event.target.i].rod)
			
			end
			infolbl.xScale = (backInfo.width-20)/infolbl.width<1 and (backInfo.width-20)/infolbl.width or 1
		end
		chk()
		backLeft:addEventListener( "tap", function()
			code[event.target.i].cmd=code[event.target.i].cmd-1
			code[event.target.i].cmd=code[event.target.i].cmd==-1 and 63 or code[event.target.i].cmd
			chk()
		end )
		backRight:addEventListener( "tap", function()
			code[event.target.i].cmd=code[event.target.i].cmd+1
			code[event.target.i].cmd=code[event.target.i].cmd==64 and 1 or code[event.target.i].cmd
			chk()
		end )
		backCmd:addEventListener( "tap", function()
			timer.performWithDelay( 10, function()
				display.remove(list)
				list=nil
			end )
			updateIcons()
		end )

	end
	local function view(event)
		if list~=nil then return end
		-- display.remove(list)
		list = display.newGroup()
		drawGroup:insert(list)
		local scaleWith = math.min(q.cx,q.cy)
		local backSize = {x=500,y=200}

		if (event.target.x+size*.5+backSize.x*(scaleWith/backSize.x))<q.fullw then
			list.x = event.target.x + size*.5
		else
			list.x = event.target.x - backSize.x*(scaleWith/backSize.x) + size*.5
		end

		list.y = event.target.y + size*.5
		
		if list.y+backSize.y*(scaleWith/backSize.x)>q.fullh then
			list.y = list.y - backSize.y*(scaleWith/backSize.x)
		end
		local back = display.newRect(list, 0, 0, backSize.x, backSize.y)
		list.xScale = scaleWith/backSize.x
		list.yScale = scaleWith/backSize.x
		back.fill={.2}
		back.alpha=.8
		back.anchorX=0
		back.anchorY=0

		local infolbl = display.newText(
			list, preview[event.target.i].text,
			250,100,
			native.newFont("consola.ttf"),38)
		local a = (500*list.xScale)/infolbl.width
		infolbl.xScale = a<1 and a or 1 

		local next
		if preview[event.target.i].rod then
			next = preview[event.target.i].rod+tonumber(code[event.target.i].cmd)
			-- while next>#code do next = next - #code end
			next = (next-1)%(#code) + 1
			preview[preview[event.target.i].rod].rect.fill={.7,1,.7}
			preview[next].rect.fill={.7,1,.7}
		end


		back:addEventListener( "tap", function()
			if preview[event.target.i].rod then
				preview[preview[event.target.i].rod].rect.fill={1,1,1}
				preview[next].rect.fill={1,1,.9}
			end
			timer.performWithDelay( 10, function()
				display.remove(list)
				list=nil
			end)
		end )
	end
	local btXchange
	local function chengeX(event)
		if list~=nil then return end
		for i=1, #code do
			preview[i].rod=nil
		end
		changePos=false
		x=event.target.i
		event.target:setFillColor( 1,.9,.9 )
		updateIcons()
		btXchange.fill= colorsQ.command
		bot.gen[bot.workingDna].step = x
	end

	for k=1, #code do
		local posY = math.floor((k-1)/8)+1
		local posX = k - (posY-1)*8

		local cmdBack = display.newRect( drawGroup, left+(posX-1)*(size+spase), down+(posY-1)*(size+spase), size, size )
		cmdBack.anchorX=0
		cmdBack.anchorY=0
		cmdBack.i=k
		cmdBack:addEventListener( "tap", 
			function(e)
				if listGroups["paint"]~=nil then return end
				if changePos==true then
					chengeX(e)
				elseif dopInfo==false then
					spisok(e)
				else
					view(e)
				end
			end)
		preview[k] = {}	
		preview[k].rect = cmdBack
	end

	updateIcons()

	-------------------------------------------------------------------
	-------------------------------------------------------------------

	local btSave = display.newRect(drawGroup, 50, 50, 100, 100)
	local btName = native.newTextField( 100, 0, 200,100 ) 
	drawGroup:insert(btSave)
	btName.anchorX = 0
	btName.anchorY = 0
	-- btSave.fill={.2}
	btSave.fill = colorsQ.button

	local btSaveIcon = display.newImageRect( drawGroup, "images/saveshape.png", 90,90 )
	btSaveIcon.x=btSave.x
	btSaveIcon.y=btSave.y

	btSave:addEventListener( "tap", 
	function()
		if #btName.text<1 or btName.text=="start" then return end
		btSave.fill = {1}
		timer.performWithDelay( 100, function() transition.to(btSave.fill,{r=.2,g=.2,b=.2}) end )
		local dump = {}
		for i=1, #code do
			dump[i] = code[i].cmd
		end
		q.addBot(btName.text, dump)
	end )

	local btLoad = display.newRect(drawGroup, 0, 200, 100, 100)
	btLoad.anchorX = 0
	btLoad.fill = colorsQ.button
	if q.fullh<q.fullw then btLoad.x=0 btLoad.y=350 end 

	local btLoadIcon = display.newImageRect( drawGroup, "images/dna.png", 100,100 )
	btLoadIcon.x=btLoad.x+50
	btLoadIcon.y=btLoad.y

	local btInfo = display.newRect(drawGroup, 550, 50, 100, 100)
	btInfo.anchorX = 0
	btInfo.fill = colorsQ.button
	if q.fullh<q.fullw then btInfo.x=0 btInfo.y=200 end 

	local btInfoIcon = display.newImageRect( drawGroup, "images/zoom.png", 90,90 )
	btInfoIcon.x=btInfo.x+50
	btInfoIcon.y=btInfo.y

	btXchange = display.newRect(drawGroup, 550, 50+125, 100, 100)
	btXchange.fill = colorsQ.button
	btXchange.anchorX = 0
	if q.fullh<q.fullw then 
		-- btXchange.anchorX = 1
		btXchange.x=q.fullw-100
		btXchange.y=200 
	end 


	local btXchangeIcon = display.newImageRect( drawGroup, "images/move.png", 90,90 )
	btXchangeIcon.x=btXchange.x+50
	btXchangeIcon.y=btXchange.y
	-- btLoadIco.xScale=90/3
	-- btLoadIco.yScale=90/3
	-- btLoadIco.anchorX=0
	-- btLoad.anchorY = 0
	btXchange:addEventListener( "tap", function()
		if changePos==false then
			changePos=true
			btXchange.fill={.7,1,.7}
		else
			changePos=false
			btXchange.fill= colorsQ.command
		end
	end )

	btInfoIcon:addEventListener( "tap", function()
		if dopInfo==false then
			dopInfo=true
			btInfo.fill={.7,1,.7}
		else
			dopInfo=false
			btInfo.fill=colorsQ.command
		end
	end )
	

	local listGroup
	btLoad:addEventListener( "tap", 
	function()
		if list~=nil then return end
		
		local bots = q.loadBots()
		local i = -1 --   -1 start
		for k,v in pairs(bots) do
			i = i + 1
		end

		i = math.floor((i-1)/10)

		createList(btLoad.x+50+200, btLoad.y+50, 1, drawGroup, {text=colorsQ.infoText,rect=colorsQ.info}, "paint", 
		function(k, v)
			createList(btLoad.x+50+200, btLoad.y+50, 1, drawGroup, {text={1,1,1},rect={.6,.6,.6,1}}, "paint") 
			
			code = {}
			for i=1, #v do
				code[i] = {cmd=v[i]} 
			end
			updateIcons()

		end 
		)
		if listGroups["paint"]~=nil then
			listGroups["paint"].x = btLoad.x+50+(200*(i+1)) * listGroups["paint"].xScale
		end
	end )

	local onKeyEvent
	local btExit = display.newRect(drawGroup, q.fullw-50, 50, 100, 100)
	btExit.fill = colorsQ.button
	local exit = display.newImageRect(drawGroup, "images/ex.png", 80, 80)
	exit.x, exit.y = q.fullw-50, 50
	exit:setFillColor( 0 )
	btExit:addEventListener( "tap", function() 
		local dump = {}
		for i=1, #code do
			dump[i] = code[i].cmd
		end
		bot.gen[bot.workingDna].code=dump
		display.remove(drawGroup) 
		display.remove(btName)
  	if isDevice==false then 
  		Runtime:removeEventListener( "key", onKeyEvent )
		end
		q.event.on("clearAll")
		q.event.on("timerStart")
		-- q.event.on("skip")
		q.event.on("guide")
		q.event.on("toMenu")
		q.event.on("loadBots")
		q.event.on("deleteBot")
		q.event.on("oneStep")
		q.event.on("viewChange")
		q.event.on("canMoveCube")
		q.event.on("spawnMode")
		q.event.on("saveWorld")


		q.event.on("editGen")
		q.event.on("save1dop")
		q.event.on("rodView")
		q.event.on("rod2View")
		q.event.on("close1dop")
	end)
end

local function genRodCheck(rod, bot)
	local izm = 0
	for j=1, minRodDna do
		if bot[j]~=rod[j] then
			izm = izm + 1
		end
		if izm>1 then break end
	end
	return izm
end

local uncheckRod = {}
local rodColor = {
	{{0,.9,.9},{.4,.8,.4},{.2,.4,.2}},
	{{.8,.3,.8},{.8,.2,.2},{.4,.05,.05}},
}
local function showPop(bot)
	
	if pop then  return end
	pop = display.newGroup()

 
	uiGroup:insert(pop)
	pop:toBack( )

	pop.bot = bot
	bot.body.fill=rodColor[1][1]
	pop.x, pop.y = bot.allBody.x+cellSize*.5, bot.allBody.y+cellSize*.5
	pop.xScale = (math.min(q.fullw,q.fullh))/width --* (1/mainGroup.xScale) 
	pop.yScale = (math.min(q.fullw,q.fullh))/width --* (1/mainGroup.yScale)
	local xx = q.cx - pop.bot.x*cellSize * mainGroup.xScale
	local yy = q.cy - pop.bot.y*cellSize * mainGroup.yScale - (height*pop.yScale)*.5
	mainGroup.x = xx
	mainGroup.y = yy

		-- display.newRect( q.cx, (24+80)*7-5+12, q.fullw,5)
		-- display.newRect( q.cx, q.fullh-(height*pop.yScale-30), q.fullw,6)
	if (24+80)*7-5 + (height*pop.yScale-30) > q.fullh then -- если доп инфа налазит на кнопки - скрыть кнопки
		-- transition.to( leftButtonsGroup, {x=-120, time=500} )
		leftButtonsGroup.x = -120
	end
	pop.bot = bot
	pop.startDna = bot.workingDna + 0

	pop.x = q.fullw+55
	pop.y = q.fullh-height*pop.yScale*.5+25

	local strelka = display.newRoundedRect( pop, 0, 0, 100, 100, 10 )
	strelka.x = -70
	strelka.rotation=45
	strelka.fill={.3}
	pop.strelka = strelka
	strelka.alpha=0

	local popIn = display.newGroup()
	pop:insert(popIn)
	popIn.x= -50-width*.5
	pop.popIn = popIn


	local back = display.newRoundedRect( popIn, 0, 0, width, height, 0)
	back.fill={.3}

	local b =display.newRect(popIn, 0, down+20, width*.95, 260)
	b.fill={.2}
	b.anchorY=0

	local buttonSize = 90
	local logoSize = buttonSize*.8
	local spaseSize = buttonSize*.2
	local sps = buttonSize+spaseSize
	local halfB = buttonSize*.5

	local greenRod = display.newRect( popIn, width*.5-buttonSize+20, down+height*.5-40, buttonSize, buttonSize )
	greenRod.alpha = .2
	local greenRodIcon = display.newImageRect( popIn, "images/rod.png", logoSize, logoSize)
	greenRodIcon.x, greenRodIcon.y = greenRod.x, greenRod.y

	local redRod = display.newRect( popIn, width*.5-buttonSize+20, down+height*.5-40+sps, buttonSize, buttonSize )
	redRod.alpha = .2
	local redRodIcon = display.newImageRect( popIn, "images/rod2.png", logoSize, logoSize)
	redRodIcon.x, redRodIcon.y = redRod.x, redRod.y

	local close = display.newPolygon( popIn, width*.5-buttonSize+20, down+70, {0,0, 1,0, 1,1, 2,1, 2,2, 1,2, 1,3, 0,3, 0,2, -1,2, -1, 1, 0,1 } )
	close.rotation = 45
	close.xScale=19
	close.yScale=19

	q.event.add("rodView",greenRod,function()
		showAndHideBackGuide("Ярко-зелёные клетки прямые родственники выбранной клетки. Темно-зелёные родственники с одной мутацией. Серые - чужаки, две и более мутаций", q.cy+250)
		drawmode=-1
		draw4Code[1] = bot.gen[bot.workingDna].code


		local relatives = 0
		if draw4Code[2] then
			local unheck = {}				
			for i=1, #bots do
				local izm = genRodCheck(bots[i].gen[bot.workingDna].code,draw4Code[1])
				if izm>=2 then 
					bots[i].body.fill={.6}
				else 
					unheck[i] = true 
					relatives = relatives + 1
					bots[i].body.fill=rodColor[1][izm+2]
				end -- team
			end

			for i=1, #bots do
				if unheck[i]~=true then 
					local izm = genRodCheck(bots[i].gen[bot.workingDna].code,draw4Code[2])
					if izm>=2 then 
						bots[i].body.fill={.6}
					else 
						bots[i].body.fill=rodColor[2][izm+2]
					end -- team
				end
			end
		else
			for i=1, #bots do
				local izm = genRodCheck(bots[i].gen[bot.workingDna].code,draw4Code[1])
				if izm>=2 then 
					bots[i].body.fill={.6}
				else 
					relatives = relatives + 1
					bots[i].body.fill=rodColor[1][izm+2]
				end -- team
			end
		end

		lblRelatives.text = "Родствеников: " .. relatives
		lblRelatives.fill = {.8,.8*1.2,.8}
		-- draw4Code.num = relatives
		bot.body.fill=rodColor[1][1]
	end)

	q.event.add("rod2View",redRod,function()
		-- if draw4Code[1]==nil then return end
		showAndHideBackGuide("Ярко-красные клетки прямые родственники выбранной клетки. Темно-красные родственники с одной мутацией. Серые - чужаки, две и более мутаций", q.cy+250)
		drawmode=-1
		draw4Code[2] = bot.gen[bot.workingDna].code

		local relatives = 0
		if draw4Code[1] then
			local unheck = {}				
			for i=1, #bots do
				local izm = genRodCheck(bots[i].gen[bot.workingDna].code,draw4Code[2])
				if izm>=2 then 
					bots[i].body.fill={.6}
				else 
					unheck[i] = true 
					relatives = relatives + 1
					bots[i].body.fill=rodColor[2][izm+2]
				end -- team
			end

			for i=1, #bots do
				if unheck[i]~=true then 
					local izm = genRodCheck(bots[i].gen[bot.workingDna].code,draw4Code[1])
					if izm>=2 then 
						bots[i].body.fill={.6}
					else 
						bots[i].body.fill=rodColor[1][izm+2]
					end -- team
				end
			end
		else
			for i=1, #bots do
				local izm = genRodCheck(bots[i].gen[bot.workingDna].code,draw4Code[2])
				if izm>=2 then 
					bots[i].body.fill={.6}
				else 
					relatives = relatives + 1
					bots[i].body.fill=rodColor[2][izm+2]
				end -- team
			end
		end
		lblRelatives.text = "Родствеников: " .. relatives
		lblRelatives.fill = {1,.8,.8}
		bot.body.fill=rodColor[2][1]
	end)


	q.event.add("close1dop",close,
	function()
		timer.performWithDelay( 10, removePop )
	end)

	local text = {font=native.newFont( "fifaks.ttf" ), size=34} 

	local infoGroup = display.newGroup()
	popIn:insert( infoGroup )
	infoGroup.y=-120

	local textMaxWidth = width*.5-45-30
	local steplbl = display.newText( infoGroup, "Шаг:"..bot.gen[bot.workingDna].step, left+45, down+180, text.font, text.size )
	steplbl.anchorX=0
	pop.steplbl=steplbl
	-- steplbl.xScale= textSize(steplbl,width*.5-45)

	local energylbl = display.newText( infoGroup, "Энергия:"..bot.energy, left+45, down+180+45, text.font, text.size )
	energylbl.anchorX=0
	energylbl.xScale= textSize(energylbl,textMaxWidth)
	pop.energylbl=energylbl

	local minlbl = display.newText( infoGroup, "Криcталлов:"..bot.min, left+45, down+180+45*2, text.font, text.size )
	minlbl.anchorX=0
	minlbl.xScale= textSize(minlbl,textMaxWidth)
	pop.minlbl=minlbl
	-- local back =  display.newRect( popIn, left+45, down+180+45*2, width*.5-45, 30 )
	-- back.anchorX=0

	local eatlbl = display.newText( infoGroup, "Съедено:"..bot.eated, left+45, down+180+45*3, text.font, text.size )
	eatlbl.anchorX=0
	eatlbl.xScale= textSize(eatlbl,textMaxWidth)
	pop.eatlbl=eatlbl

	local sunEn = sunHowMuch(bot)
	local cordlbl = display.newText( infoGroup, "X:"..bot.x..", Y:"..bot.y.."(+"..sunEn..")", left+45, down+180+45*4, text.font, text.size )
	cordlbl.anchorX=0
	pop.cordlbl=cordlbl
	-- ===========
	-- ---
	-- ===========
	local sunlbl = display.newText( infoGroup, "Солнце:"..bot.sun, 0, down+180, text.font, text.size )
	sunlbl.anchorX=0
	sunlbl.xScale= textSize(sunlbl,textMaxWidth+40)
	pop.sunlbl=sunlbl

	local freelbl = display.newText( infoGroup, "В дар:"..bot.freeEnergyLastStep, 0, down+180+45, text.font, text.size )
	freelbl.anchorX=0
	pop.freelbl=freelbl

	local minetedlbl = display.newText( infoGroup, "Обработано:"..bot.mineted, 0, down+180+45*2, text.font, text.size )
	minetedlbl.anchorX=0
	minetedlbl.xScale= textSize(minetedlbl,textMaxWidth+40)
	pop.minetedlbl=minetedlbl

	local kidslbl = display.newText( infoGroup, "Детей:"..bot.kids, 0, down+180+45*3, text.font, text.size )
	kidslbl.anchorX=0
	pop.kidslbl=kidslbl

	local diedlbl = display.newText( infoGroup, "Клетка мертва", 0, down+180+45*4, text.font, text.size )
	diedlbl.anchorX=0
	diedlbl:setFillColor(.9,.7,.15)
	diedlbl.alpha=0
	pop.diedlbl=diedlbl

	local cmdSize = text.size-3
	
	local a = display.newText( " ",-1000,-1000,text.font,cmdSize )
	local oneSize = a.width+1-1
	display.remove(a) 
	
	local cmdS = ""
	local s=0
	for i=1, #bot.gen[bot.workingDna].code do
		local step = bot.gen[bot.workingDna].step==i and "" or ""
		cmdS = cmdS..step..bot.gen[bot.workingDna].code[i]..", "
		if i%8==0 then cmdS = cmdS .. "\n" end
	end

	-- local cmdlbl = display.newText( popIn, cmdS, left+45, down+180+45*5, text.font, cmdSize )
	-- cmdlbl.anchorX=0
	-- cmdlbl.anchorY=0
	-- cmdlbl.fill={0}
	pop.cmdLabels = {[0]=1}

	local cubeGroup = display.newGroup()
	popIn:insert( cubeGroup )
	cubeGroup.y=-110
	cubeGroup.x=-35
	cubeGroup.xScale = .95
	-- cubeGroup.yScale = .95

	local ij = 0
	local s = 0
	for i=1, #bot.gen[bot.workingDna].code do
		local j = math.floor((i-1)/8)+1
		-- print(i+1,j)
		local check = bot.gen[bot.workingDna].code[i]<10
		local cmdlbl = display.newText( cubeGroup, bot.gen[bot.workingDna].code[i].." ", left+45+s*oneSize, down+180+45*5+(j-1)*41, text.font, cmdSize )
		cmdlbl.anchorX=0
		cmdlbl.anchorY=0
		
		local light = .08 * (bot.used.cmd[i] or 0)
		local yellow = .08 * (bot.used.skip[i] or 0)
		-- pop.cmdLabels[i].fill = {.7+light+yellow,.7+light+yellow,.7+light}
		cmdlbl.fill = {.7+light+yellow,.7+light+yellow,.7+light}

		pop.cmdLabels[i] = cmdlbl
		s = s + #(tostring( bot.gen[bot.workingDna].code[i] ))+.5--+ 2 + (check and 1 or 0)
		if i%8==0 and i~=0 then
			s = 0
		end
	end

	local saveBack = display.newRect( popIn, width*.5-buttonSize+20-sps, down+height*.5-40+sps, buttonSize, buttonSize )
	saveBack.fill = {.4}
	local savelbl = display.newText( popIn, "Save", saveBack.x, saveBack.y, text.font, text.size )
	local open = false
	local sizeIn, cancelBack, cancellbl 


	q.event.add("save1dop",saveBack,function()
		if open==false then
			timer.cancel("check")
  		showAndHideBackGuide("Для сохранине клетки(генома) введите название и нажмите SAVE опять.",q.cy+200)
			open = true
			sizeIn = native.newTextField(saveBack.x, saveBack.y+sps, sps*3-spaseSize, buttonSize)
			sizeIn.font = native.newFont( "fifaks.ttf", 80),

			popIn:insert( sizeIn )
			sizeIn.text=""
		  sizeIn.isEditable = true

		  cancelBack = display.newRect(  popIn, saveBack.x-sps, saveBack.y, buttonSize, buttonSize )
			cancelBack.fill = {.4}
			cancellbl = display.newText( popIn, "Cancel", cancelBack.x, cancelBack.y, text.font, text.size )
			cancellbl.xScale=.8*.9
			cancellbl.yScale= 1*.9
			cancelBack:addEventListener( "tap", function()
				display.remove(sizeIn)
				display.remove(cancelBack)
				display.remove(cancellbl)
				open=false
			end )
		else--if open==true then
  		showAndHideBackGuide("Отмена сохрания",q.cy+200)
			if #sizeIn.text>0 or sizeIn.text=="start" then
				open = false
				saveBack.fill = {.8}
				timer.performWithDelay( 100, function() transition.to(saveBack.fill,{r=.4,g=.4,b=.4}) end )
				local text = "{\n"
				for i=1, #bot.gen[bot.workingDna].code do
					text = text..bot.gen[bot.workingDna].code[i]..", "
					if i%8==0 then text = text .. "\n" end
				end
				print(text.."}")
				q.addBot(sizeIn.text, bot.gen[bot.workingDna].code)
				display.remove(sizeIn)
				display.remove(cancelBack)
				display.remove(cancellbl)
			end

		end
	end )

	local loadBack = display.newRect( popIn, width*.5-buttonSize+20-sps, down+height*.5-40, buttonSize, buttonSize )
	loadBack.fill = {.4}
	local loadlbl = display.newText( popIn, "Edit", loadBack.x, loadBack.y, text.font, text.size )
	-- loadBack:addEventListener( "tap", function() genEditor(bot.code, bot) end )
	q.event.add("editGen",loadBack, function() genEditor(bot.gen[bot.workingDna].code, bot) end )
	checkPop()

	local step = bot.gen[bot.workingDna].step
	step = checkOutRange(step, #bot.gen[bot.workingDna].code)
	pop.cmdLabels[step].fill = {1,.4,.4}

	q.event.on("editGen")
	q.event.on("save1dop")
	q.event.on("rodView")
	q.event.on("rod2View")
	q.event.on("close1dop")
end

local function createRot(bot)
	local view = display.newRect(bot.allBody,0,0,cellSize*.15,cellSize*.45)
	view.anchorY=1
	view.fill={1}
	view.rotation=-45 + bot.dir*45
	bot.view = view
end


local startsColor = {
	{.2,.8,.2},
	{	.8+startEnergy/maxEnergy*.2, .8-startEnergy/maxEnergy*.4, 0},
	{	.8, .8, 1},
	{unpack(colorsDna[1])},
	{.2,.2,.2},
}



local function addBotBody(bot, x,y)
	bot.allBody=display.newGroup()
	mainCellGroup:insert(bot.allBody)
	bot.allBody.x=cellSize*(x-.5)
	bot.allBody.y=cellSize*(y-.5)
	
	bot.body=display.newRect( 
	bot.allBody, 
	0, 
	0, 
	cellSize,--*(18/20), 
	cellSize--*(18/20) 
	)
	bot.body.xScale=.8
	bot.body.yScale=.8

	if drawmode>0 then
		if drawmode==4 then
			bot.body.fill = groupsColors[bot.zoneNum]
		else
			bot.body.fill = startsColor[drawmode]
		end
	end

	if drawRotate then
		local back = display.newRect(bot.allBody,0,0,cellSize,cellSize)
		back.fill={0}
		back:toBack()
		createRot(bot)
	end
	-- bot.body.anchorX=0
	-- bot.body.anchorY=0
	
	local param = function()
		return showPop(bot)
	end
	bot.allBody:addEventListener( "tap", param ) 
	
end

local function addBot(x,y,rod,zoneNum)
	local buteNum = x+w*(y-1)
	local bot = {x=x, y=y, func="bot", energy=startEnergy, dir=7, min=0, health=botHp,
	eated=0,sun=0,mineted=0, kids=0, new=newOld, freeEnergyLastStep=0,used={cmd={},skip={}}, workingDna=1}

	-- bot.die=false

	-- === 000 === --
	bot.gen = {
		{
			code={},step=1,
		},
		-- {code={},step=1,param = nil},
	}
	
	
	-- bot.workingDna = 2

	-- === 000 === --

	if rod then
		bot.zoneNum = rod.zoneNum
		-- if #rod.gen<2 then
		-- 	error("dssss")
		-- end
		for i=1, #rod.gen do
			bot.gen[i].code = {unpack(rod.gen[i].code)}
		end
		
		bot.newBotEnergy = rod.newBotEnergy 
		

		if math.random(4)==1 then
			local whith = math.random(1)
			if whith==1 then -- DNA MUTANT
				local gen = math.random(#bot.gen)
				bot.gen[gen].code[math.random(#bot.gen[gen].code)]=math.random(0,63)
				bot.newBotEnergy = math.random( 1,9 )*.1
			-- elseif whith==2 then -- EVENT MUTANT
			-- 	local list = {}
			-- 	local i = 1
			-- 	for k, v in pairs(bot.eventDna) do
			-- 		list[i] = k
			-- 		i = i + 1
			-- 	end
			-- 	bot.eventDna [list[math.random(#list)]] = 
			-- 	math.random(#bot.gen)
			end
		end
		if draw then
			addBotBody(bot, x, y)
			if drawmode~=-1 then
				bot.body.fill = coloriseBot(rod)
			end
		end

	else
		bot.zoneNum = zoneNum
		-- for i=1, 16 do
		-- 	bot.gen[2].code[i] = 11
		-- end
		-- bot.gen[2].code[31] = 18
		-- bot.gen[2].code[32] = 11
		bot.newBotEnergy = math.random( 1,9 )*.1

		local bots = q.loadBots()
		bot.gen[1].code = bots[bots["start"]].code
		
		-- bot.gen[1].code = { 1,2,3,4,5,6,7,8,9,10,11}
		-- bot.gen[1].code = { 11,11,11,}

		for i=#bot.gen[1].code+1, 32 do
			bot.gen[1].code[i]=11--math.random(0,63)
		end

		-- bot.gen[1].code[math.random(64)]=math.random(0,63)
		if draw then
			addBotBody(bot, x, y)
		end
	end
	


	bots[#bots+1] = bot
	bot.i =  #bots
	greed[buteNum] = bot
	return bot
end

local function removeBot(x, y)
	local buteNum = y~=nil and x+w*(y-1) or x
	local i = greed[buteNum].i
	local bot = bots[i]
	if bot==nil then 
		greed[buteNum]=nil
		return 
	end
	-- display.remove(bot.body)
	if draw then
		bot.body:toFront()
		transition.to(bot.allBody,{alpha=.1,time=100, 
		onComplete=function()
			display.remove(bot.allBody)
		end})
	else
		display.remove(bot.allBody)
	end

	table.remove(bots, i)
	for j=i, #bots do
		bots[j].i = bots[j].i - 1
	end
	greed[buteNum]=nil
	buteNum, x, y = nil, nil, nil
end
-- local function move(bot,dir)
-- 	local sum = (bot.dir + dir%8)%8
-- end
-- 0 1 2
-- 7   3
-- 6 5 4

local function ifprint(text)
	if true then return end
	print(text)
end


local function getXY(num)
	local x, y = 0, 0
	if num==0 then
		x = -1
		y = -1
	elseif num==1 then
		y = -1
	elseif num==2 then
		x = 1
		y = -1
	elseif num==3 then
		x = 1
	elseif num==4 then
		x = 1
		y = 1
	elseif num==5 then
		y = 1
	elseif num==6 then
		x = -1
		y = 1
	elseif num==7 then
		x = -1
	end
	return x, y
end

local function chetPlus(bot,info)
	local plus = checkOutRange(bot.gen[bot.workingDna].step + info,#bot.gen[bot.workingDna].code)
	bot.used.skip[plus]=(bot.used.skip[plus] or 0)+1
	bot.gen[bot.workingDna].step = bot.gen[bot.workingDna].step + bot.gen[bot.workingDna].code[plus]
end

local function rotate(bot,num)
	num = num%8
	bot.dir = ( bot.dir + num )%8
	if draw then
		-- transition.to(bot.view,{rotation = -45 + 45*bot.dir, time=15})
		if drawRotate then
			bot.view.rotation = -45 + 45*bot.dir
		end
	end
	-- print(bot.i,"rat")
end

local function move(bot,num)
	local oldX, oldY = bot.x, bot.y
	local x, y = getXY(num)
	bot.x, bot.y = bot.x+x, bot.y+y
	local noAnim = false
	if bot.x<1 then 
		bot.health = bot.health - teleportDMG 
		if bot.health<=0 then
			removeBot(oldX,oldY)
			return
		end
		bot.x=w noAnim=true 
	end
	if bot.x>w then
		bot.health = bot.health - teleportDMG 
		if bot.health<=0 then
			removeBot(oldX,oldY)
			return
		end
		bot.x=1 noAnim=true bot.x=w noAnim=true 
	end
	if bot.y<1 then 
		bot.health = bot.health - teleportDMG 
		if bot.health<=0 then
			removeBot(oldX,oldY)
			return
		end 
		bot.y=h noAnim=true 
	end
	if bot.y>h then 
		bot.health = bot.health - teleportDMG 
		if bot.health<=0 then
			removeBot(oldX,oldY)
			return
		end 
		bot.y=1 noAnim=true 
	end

	local buteNum = bot.x+w*(bot.y-1)
	local nextXYcell = greed[buteNum]
	if nextXYcell==nil or nextXYcell.func=="food" then
		bot.energy = bot.energy-moveCost
		if nextXYcell~=nil then bot.energy = bot.energy + diedBodyEnergy
		removeCell(bot.x,bot.y) end
			-- print("h")
		if draw then
			if noAnim then
				bot.allBody.x=cellSize*(bot.x-.5)
				bot.allBody.y=cellSize*(bot.y-.5)
			else
				transition.to(bot.allBody,{x=cellSize*(bot.x-.5),y=cellSize*(bot.y-.5),time=100})
			end
		end
		local buteNumOld = oldX+w*(oldY-1)
		greed[buteNumOld]=nil
		greed[buteNum]=bot
	else
		bot.x, bot.y = oldX, oldY
	end

	local info = 1
	if nextXYcell==nil then
		info = 2
	elseif nextXYcell.func=="wall" then
		info = 3
	elseif nextXYcell.func=="food" then
		info = 4
	elseif nextXYcell.func=="bot" then
		local izm = genRodCheck(bot.gen[bot.workingDna].code, greed[buteNum].gen[greed[buteNum].workingDna].code)
		if izm > 1 then 
			info = 5 -- bot
		else 
			info = 6 -- team
		end 
	end

	chetPlus(bot,info)
end

local function eat(bot,num)
	local x, y = getXY(num)
	x, y = bot.x+x, bot.y+y

	local buteNum = x+w*(y-1)
	local nextXYcell = greed[buteNum]

	local info = 1
	if nextXYcell==nil then
		info = 2
	elseif nextXYcell.func=="food" then
		info = 3
	elseif nextXYcell.func=="bot" then
		info = 4
	end

	if nextXYcell~=nil then 
		if nextXYcell.func=="food" then
			-- bot.eated = bot.eated + 1
			bot.energy = bot.energy + diedBodyEnergy
			removeCell(x,y)
			display.remove(nextXYcell.body)
			nextXYcell=nil
		elseif nextXYcell.func=="bot" then
			bot.eated = bot.eated + 1
			greed[buteNum].health = greed[buteNum].health - dmg
			if greed[buteNum].health<=0 then
				
				-- if greed[buteNum].die~=false then
					bot.energy = bot.energy + math.floor(diedBodyEnergy*1.2)--math.floor(greed[buteNum].energy*.6)
					removeBot(x,y)
				-- end
			else
				-- вместо стеков, повернуть клетку к атакуещей
			end
		end
	end

	chetPlus(bot,info)
end

local function dirCheck(bot,num)
	local x, y = getXY(num)
	x, y = bot.x+x, bot.y+y

	local buteNum = x+w*(y-1)
	local nextXYcell = greed[buteNum]

	local info = 1
	if nextXYcell==nil then
		info = 2
	elseif nextXYcell.func=="wall" then
		info = 3
	elseif nextXYcell.func=="food" then
		info = 4
	elseif nextXYcell.func=="bot" then
		local izm = genRodCheck(bot.gen[bot.workingDna].code, greed[buteNum].gen[greed[buteNum].workingDna].code)
		if izm > 1 then 
			info = 5 -- bot
		else 
			info = 6 
		end -- team
	end

	-- local plus = checkOutRange(bot.gen[bot.workingDna].step + info)
	-- bot.used[plus].Temp=(bot.used[plus].Temp or 0)+1
	-- bot.step = bot.step + bot.code[plus]
	chetPlus(bot,info)
end

local function giveEnergy(bot,num)
	local x, y = getXY(num)
	x, y = bot.x+x, bot.y+y

	local buteNum = x+w*(y-1)
	local nextXYcell = greed[buteNum]

	local info = 1
	if nextXYcell==nil then
		info = 2
	elseif nextXYcell.func=="bot" then
		local izm = genRodCheck(bot.gen[bot.workingDna].code, greed[buteNum].gen[greed[buteNum].workingDna].code)
		if izm > 1 then 
			info = 3 -- bot
		else 
			info = 4 
		end -- team
	end

	if nextXYcell~=nil then 
		if nextXYcell.func=="bot" and bot.energy>200 then
			local can = bot.energy - 100
			bot.energy = bot.energy - can
			greed[buteNum].energy = greed[buteNum].energy + can
			greed[buteNum].freeEnergyLastStep = greed[buteNum].freeEnergyLastStep + can
		end
	end

	chetPlus(bot,info)
end


local function ifEnergy(bot)
	if bot==nil then return end
	local next = checkOutRange(bot.gen[bot.workingDna].step + 1,#bot.gen[bot.workingDna].code)
	next = next==0 and 1 or next
	local plus
	if bot.energy<(bot.gen[bot.workingDna].code[next])*15 then
		plus = 2
	else
		plus = 3
	end

	chetPlus(bot,plus)
end

local function ifposY(bot)
	local plus
	if bot.y<bot.gen[bot.workingDna].code[bot.gen[bot.workingDna].step+1] then
		plus = 2
	else
		plus = 3
	end
	chetPlus(bot,plus)
end

local function ifMin(bot)
	local plus
	if bot.y>math.floor(h/2) then
		plus = 1
	else
		plus = 2
	end
	chetPlus(bot,plus)
end

local function ifnoSpase(bot)

	local allNextdoors = {} 
	for i=1, 8 do
		local x, y = getXY(i)
		x = bot.x + x
		y = bot.y + y

		x = x<1 and w or x
		x = x>w and 1 or x
		if y<=h and y>=1 then 
			allNextdoors[#allNextdoors+1] = x+w*(y-1)
		end
	end

	local spase = false
	for i=1, #allNextdoors do
		if greed[allNextdoors[i]]==nil then
			spase=true break
		end
	end

	local info = 1
	if spase then
		info = 2
	end
	chetPlus(bot,info)
end

local function ifFreeEnergy(bot)
	local info = 1
	if bot.freeEnergyLastStep>100 then
		info = 2
	end
	chetPlus(bot,info)
end

local wallProtect = false
local function razm(bot, num)
	local allNextdoors =
	{
	{-1,-1},{0,-1},{1,-1},
	{-1,0},   {1,0},
	{-1,1},{0,1},{1,1},
	}
	if num then
		local x, y = getXY(num)
		x, y = bot.x+x, bot.y+y
		
		x = x<1 and w-x or x
		x = x>w and x-w or x
		y = y<1 and h-y or y
		y = y>h and y-h or y

		local buteNum = x+w*(y-1)
		local nextXYcell = greed[buteNum]

		if nextXYcell==nil then
			if bot.energy<maxEnergy*.5 then
				local x, y = bot.x,bot.y
				removeBot(bot.x,bot.y)
				addCell(x, y)
				return
			end
			bot.kids = bot.kids + 1

			local newBot = addBot(x, y, bot)
			local e = math.floor((bot.energy-100)*.5)
			bot.energy = math.floor(e*(1-bot.newBotEnergy))
			newBot.energy = math.floor(e*bot.newBotEnergy)
			if draw and drawmode==-1 then
				local unheck
				if draw4Code[1] then
					local izm = genRodCheck(draw4Code[1], newBot.gen[newBot.workingDna].code)
					if izm==2 then 
						newBot.body.fill={.6}
					else 
						unheck = true
						newBot.body.fill=rodColor[1][izm+2]
					end -- team
				end
				if draw4Code[2] and unheck~=true then
					local izm = genRodCheck(draw4Code[2], newBot.gen[newBot.workingDna].code)
					if izm==2 then 
						newBot.body.fill={.6}
					else 
						newBot.body.fill=rodColor[2][izm+2]
					end -- team
				end
			end
		end
	else
		local buteFree = {}
		for i=1, 8 do--sizey
			local nd = allNextdoors[i]
			local x = bot.x+nd[1]
			x = x<1 and w-x or x
			x = x>w and x-w or x
			local y = bot.y+nd[2]
			y = y<1 and h-y or y
			y = y>h and y-h or y
			buteFree[i] = {x+w*(y-1),{x,y}}
		end

		local free = {}
		for i=1, 8 do
			if greed[buteFree[i][1]]==nil then
				-- if not (buteFree[i][2][2]<0 or buteFree[i][2][2]>h) or (buteFree[i][2][2]>-50) then
				if not (buteFree[i][2][2]<0 or buteFree[i][2][2]>h) then
					free[#free+1]=buteFree[i][2]
				end
			end
		end

		if #free==0 then
			-- if bot.die~=false then 
				local x, y = bot.x,bot.y
				removeBot(bot.x,bot.y)
				addCell(x, y)
			-- else
			-- 	if math.random(25)==1 then
			-- 		bot.code[math.random(64)]=math.random(0,64)
			-- 	end
			-- end
		else
			bot.kids = bot.kids + 1
			local pos = free[math.random(#free)]

			local newBot = addBot(pos[1], pos[2], bot)
			local e = math.floor((bot.energy-100)*.5)

			bot.energy = math.floor(e*(1-bot.newBotEnergy))
			newBot.energy = math.floor(e*bot.newBotEnergy)

			if draw and drawmode==-1 then
				local unheck
				if draw4Code[1] then
					local izm = genRodCheck(draw4Code[1], newBot.gen[newBot.workingDna].code)
					if izm==2 then 
						newBot.body.fill={.6}
					else 
						unheck = true
						newBot.body.fill=rodColor[1][izm+2]
					end -- team
				end
				if draw4Code[2] and unheck~=true then
					local izm = genRodCheck(draw4Code[2], newBot.gen[newBot.workingDna].code)
					if izm==2 then 
						newBot.body.fill={.6}
					else 
						newBot.body.fill=rodColor[2][izm+2]
					end -- team
				end
			end
		end
	end
end

local function codein(bot,num)
	if bot.energy<=300 then bot.gen[bot.workingDna].step = checkOutRange(bot.gen[bot.workingDna].step + 2 + num + 1, #bot.gen[bot.workingDna].code) return end
	local x, y = getXY(num)
	x, y = bot.x+x, bot.y+y

	local buteNum = x+w*(y-1)
	local nextXYcell = greed[buteNum]

	local num = bot.gen[bot.workingDna].code[checkOutRange(bot.gen[bot.workingDna].step+2,#bot.gen[bot.workingDna].code)]
	-- while num>16 do num = num - 16 end
	num = (num-1)%16 + 1
	if nextXYcell and nextXYcell.func=="bot" then
		local already = true
		for i=1, num do
			if nextXYcell.gen[nextXYcell.workingDna].code[i+nextXYcell.gen[nextXYcell.workingDna].code[checkOutRange(nextXYcell.gen[nextXYcell.workingDna].step+3,#bot.gen[bot.workingDna].code)-1]] ~= 
					bot.gen[bot.workingDna].code[checkOutRange(bot.gen[bot.workingDna].step+3+i,#bot.gen[bot.workingDna].code)] then
				already = false
			end
		end
		if not already then
			bot.energy = bot.energy - 300
			nextXYcell.body.fill = {.4,.1,.4}
			nextXYcell.zaraza = bot.gen[bot.workingDna].code

			for i=1, num do
				nextXYcell.gen[nextXYcell.workingDna].code[i+nextXYcell.gen[nextXYcell.workingDna].code[checkOutRange(nextXYcell.gen[nextXYcell.workingDna].step+3,#bot.gen[bot.workingDna].code)-1]] = 
					bot.gen[bot.workingDna].code[checkOutRange(bot.gen[bot.workingDna].step+3+i,#bot.gen[bot.workingDna].code)]
			end
			nextXYcell.gen[nextXYcell.workingDna].step = 1
		end
	end
	bot.gen[bot.workingDna].step = checkOutRange(bot.gen[bot.workingDna].step + 2 + num + 1,#bot.gen[bot.workingDna].code)
end 




local sixH
local donwSunLine
local mineralSpace
local ostOneTherd 
local function minCheck(bot)
	if bot.y>ostOneTherd[3] then
		bot.min = bot.min + 3
	elseif bot.y>ostOneTherd[2] then
		bot.min = bot.min + 2
	elseif bot.y>ostOneTherd[1] then
		bot.min = bot.min + 1
	end
end

local function includeDir(dir,num)
	return ((num)%8+dir)%8
end



-- === 000 === -- 
-- === 000 === -- 
local function doGenCode(bot)
	minCheck(bot)
	bot.new = bot.new>0 and bot.new - 1 or 0

	if draw then 
		local color = coloriseBot(bot)
		if color then bot.body.fill = color end
	end
	bot.energy = bot.energy - liveCost
	
	local temp = 1
	local dna = bot.workingDna
	if dna>#bot.gen then dna=1 error("blat") end
	local code = bot.gen[dna].code
	while temp<5 do
		if bot.energy>=maxEnergy then
			razm(bot)
			-- if bot.die~=false then
				break
			-- end 
		end
		
		bot.gen[dna].step = checkOutRange(bot.gen[dna].step,#bot.gen[bot.workingDna].code)
		local nowStep = bot.gen[dna].step
		local nextStep = checkOutRange(nowStep+1,#bot.gen[bot.workingDna].code)

		local cmd = code[nowStep]
		local nextCmd = code[nextStep]

		bot.used.cmd[nowStep]=(bot.used.cmd[nowStep] or 0)+1

		if cmd==nil then bot.gen[dna].step=1 break end
		if cmd==1 then -- поворот
			rotate( bot, nextCmd%8 )
			bot.gen[dna].step = checkOutRange(nowStep + 2,#bot.gen[bot.workingDna].code)
			temp = temp + 1
		elseif cmd==2 then -- двинуться 
			move(bot, (nextCmd)%8)
			break
		elseif cmd==3 then -- относительно двинуться 
			move(bot, includeDir(bot.dir,nextCmd))
			break
		elseif cmd==4 then -- посмотреть
			dirCheck(bot, nextCmd%8)
			temp = temp + 1
		elseif cmd==5 then -- относительно посмотреть
			dirCheck(bot, includeDir(bot.dir,nextCmd))
			temp = temp + 1
		elseif cmd==6 then -- сьесть
			eat(bot, nextCmd%8)
			break
		elseif cmd==7 then -- относительно сьесть
			eat(bot, includeDir(bot.dir,nextCmd))
			break
		elseif cmd==8 then -- дать энергию
			giveEnergy(bot, (nextCmd%8))
			temp = temp + 1
		elseif cmd==9 then -- относительно дать энергию
			giveEnergy(bot, includeDir(bot.dir,nextCmd))
			temp = temp + 1
		elseif cmd==10 then -- минерал в энергию
			bot.mineted = bot.mineted + 1
			if bot.min>0 then
				bot.min = bot.min - 1
				bot.energy = bot.energy + mineralEn
			end
			bot.gen[dna].step = nextStep
			break
		elseif cmd==11 then -- фотосинтез
			bot.sun = bot.sun + 1
			bot.energy = bot.energy + sunHowMuch(bot)
			bot.gen[dna].step = nextStep
			break
		elseif cmd==12 then -- сколько энергии
			ifEnergy(bot)
			temp = temp + 1
		elseif cmd==13 then -- окружен ли
			ifnoSpase(bot)
			temp = temp + 1
		elseif cmd==14 then -- получаю миниралы?
			ifMin(bot)
			temp = temp + 1
		elseif cmd==15 then -- размножиться
			razm(bot, nextCmd%8)
			bot.gen[dna].step = nextStep
			break
		elseif cmd==16 then -- относительно размножиться
			razm(bot, includeDir(bot.dir,nextCmd))
			bot.gen[dna].step = nextStep
			break
		-- elseif cmd==17 then -- прописать свой код в соседа
		-- 	-- ifprint("#"..i.." "..cmd.." cmd:codein")
		-- 	codein(bot, (nextCmd%8))
		-- 	-- bot.step = checkOutRange(bot.step + 1)
		-- 	break
		-- elseif cmd==18 then -- вернуться к основному геному
			
		-- 	openStack(bot)
		-- 	temp = temp + 1

		elseif cmd==666 then
			razm(bot)
			bot.gen[dna].step = nextStep
			break
		else 
			bot.gen[dna].step = bot.gen[dna].step + cmd
			temp = temp + 1
			bot.used.skip[nowStep]=(bot.used.skip[nowStep] or 0)+1
		end
	end
	if temp>4 then bot.gen[dna].step = checkOutRange(bot.gen[dna].step+1,#bot.gen[bot.workingDna].code) end 
end
-- === 000 === -- 
-- === 000 === -- 
local function updatePop()
	checkPop()
	if pop.startDna~=pop.bot.workingDna then
		local undelBot = pop.bot
		removePop()
		showPop(undelBot)
		pop.startDna=pop.bot.workingDna
		undelBot = nil
	end

	local textMaxWidth = width*.5-45-30

	pop.steplbl.text="Шаг:"..pop.bot.gen[pop.bot.workingDna].step

	pop.energylbl.xScale= textSize(pop.energylbl,textMaxWidth)
	pop.energylbl.text="Энергия:"..pop.bot.energy

	pop.minlbl.xScale= textSize(pop.minlbl,textMaxWidth)
	pop.minlbl.text="Криcталлов:"..pop.bot.min

	pop.eatlbl.xScale= textSize(pop.eatlbl,textMaxWidth)
	pop.eatlbl.text="Съедено:"..pop.bot.eated

	local sunEn = sunHowMuch(pop.bot)
	pop.cordlbl.text="X:"..pop.bot.x..", Y:"..pop.bot.y.."(+"..sunEn..")"

	-- ===========
	-- ---
	-- ===========
	pop.sunlbl.xScale= textSize(pop.sunlbl,textMaxWidth+40)
	pop.sunlbl.text="Солнце:"..pop.bot.sun

	pop.freelbl.text="В дар:"..pop.bot.freeEnergyLastStep

	pop.minetedlbl.xScale= textSize(pop.minetedlbl,textMaxWidth+40)
	pop.minetedlbl.text="Обработано:"..pop.bot.mineted

	pop.kidslbl.text="Детей:"..pop.bot.kids

	for i=1, #pop.bot.gen[pop.bot.workingDna].code do
		local light = .08 * (pop.bot.used.cmd[i] or 0)
		local yellow = .08 * (pop.bot.used.skip[i] or 0)
		pop.cmdLabels[i].fill = {.7+light+yellow,.7+light+yellow,.7+light}
	end
	local step = pop.bot.gen[pop.bot.workingDna].step
	step = checkOutRange(step, #pop.bot.gen[pop.bot.workingDna].code)
	pop.cmdLabels[step].fill = {.8,.2,.2}
end
checkAll = function()
	step = step + 1
	lblStep.text = "Шагов: "..step
	lblPopulation.text = "Популяция: "..#bots
	counter = counter - 1
	-- if zima and counter<=0 then 
	-- 	if nowZima==false then 
	-- 		counter = math.ceil(maxEnergy*.6)
	-- 		nowZima = true
	-- 	else
	-- 		counter = 5000
	-- 		nowZima = false
	-- 	end 
	-- end
	
	for i=1, #bots do
		local bot = bots[i]

		if bot~=nil then
			if bot.energy<1 or bot.new<10 then -- СМЕРТЬ ОТ СТАРОСТИ
				local x, y = bot.x,bot.y
				removeBot(x, y)
			 	addCell(x, y)
			else
				doGenCode(bot)
				if pop then
					pop.bot.body.fill=rodColor[1][1]
				end
			end
		end
	end
	if pop~=nil and pop.bot.body.x~=nil then
		updatePop()
	elseif pop~=nil and pop.bot.body.x==nil then
		pop.diedlbl.alpha=1
	end

end

createList = function(x,y, anchor, group, color, id, func)
	-- print(id)
	if listGroups[id]~=nil then
		display.remove(listGroups[id])
		listGroups[id] = nil
		-- print("delet")
	else
		listGroups[id] = display.newGroup()
		listGroups[id].x, listGroups[id].y = x, y
		group:insert(listGroups[id])
		local bots = q.loadBots()
		local Bots = {}
		for k, v in pairs(bots) do
			if k~="start" then
				Bots[bots[k].num] = {name = k, code = bots[k].code} 
			end
		end

		local r,g,b = unpack(color.text)
		for i=1, #Bots do
			print(i)
			local k = Bots[i].name
			local v = Bots[i].code
			if k~="start" then
				local x, y
				if i>10 then 
					local stolb = math.floor((i-1)/10)
					x=-100-200*stolb
					y= 35+70*(i-1 -10*stolb)
				else
					x = -100
					y= 35+70*(i-1)
				end

				local text = display.newText( listGroups[id], k, x, y, "fifaks", 50 )
				if text.width>180 then 
					local a = text.width
					local i = 1
					while a>180 do
						a = a*.8
						i = i*.8
					end
					text.xScale=i 
				end
				text:setFillColor( r,g,b ) 
				if k==bots["start"] then
					text:setFillColor( r,g*1.5,b ) 
				end
				text:addEventListener( "tap", function() func(k, v) end )
			end

		end
		local numBots = #Bots
		local j = numBots>10 and 10 or numBots 
		local back = display.newRect(listGroups[id], 0, 0, 200, 70*j )
		back.anchorX=1
		back.anchorY=0
		back:toBack()
		if numBots>10 then back.width=200+200* math.floor((numBots-1)/10) end
		local r,g,b,a = unpack(color.rect)
		back:setFillColor( r,g,b,a )

		local _width = back.width
		if _width>(q.fullw+50) then 
			local a = _width*(200/180)
			local i = 1
			-- local r = display.newRect(q.fullw-50,10,150,20)
			-- r.anchorX = 1
			-- print(a,q.fullw+50)
			while a>(q.fullw+50) do
				a = a*.95
				i = i*.95
				-- local r = display.newRect(q.fullw-50,100*i,a,20)
				-- r.anchorX = 1
				-- print(a,q.fullw)
			end
			print("ss",i)
			listGroups[id].xScale=i 
			listGroups[id].yScale=i 
		end
		if anchor==0 then listGroups[id].x = listGroups[id].x+listGroups[id].width end

	end
end

local function lengthOf( a, b )
	local width, height = b.x-a.x, b.y-a.y
	return (width*width + height*height)^0.5
end

local function calcAvgCentre( points )
	local x, y = 0, 0

	for i=1, #points do
		local pt = points[i]
		-- print(i.."#",pt.x,pt.x)
		x = x + pt.x
		y = y + pt.y
	end

	return { x = x / #points, y = y / #points }
end

local function updateTracking( centre, points )
	for i=1, #points do
		local point = points[i]

		point.prevDistance = point.distance
		point.distance = lengthOf( centre, point )
	end
end

local function calcAverageScaling( points )
	local total = 0

	for i=1, #points do
		local point = points[i]
		total = total + point.distance / point.prevDistance
	end

	return total / #points
end

local function newTrackDot(e)
	local circle = display.newCircle( e.x, e.y, 50 )
	circle.alpha = 0
	local rect = e.target

	function circle:touch(e)
		local target = circle
		e.parent = rect
		if (e.phase == "began") then
			display.getCurrentStage():setFocus(target, e.id)
			target.hasFocus = true
			return true
		elseif (target.hasFocus) then
			if (e.phase == "moved") then
				target.x, target.y = e.x, e.y
			else -- "ended" and "cancelled" phases
				display.getCurrentStage():setFocus(target, nil)
				target.hasFocus = false
			end
			rect:touch(e)
			return true
		end
		return false
	end

	circle:addEventListener("touch")

	function circle:tap(e)
		if (e.numTaps == 2) then
			e.parent = rect
			rect:touch(e)
		end
		return true
	end

	if (not isDevice) then
		circle:addEventListener("tap")
	end

	circle:touch(e)
	return circle
end

local spawnPos
local function spawnEditor()
	--[[
	НУЖНО НЕ ГЕНЕРИРОВАТЬ ВСЕ КВАДРАТЫ, А СОЗДАВАТЬ ИХ ВО ВРЕМЯ РИСОВАНИЯ
	]]
	local offPointColor = {.5}
	local drawGroup = display.newGroup()
	uiGroup:insert(drawGroup)

	local newBack = display.newRect( drawGroup, q.cx, q.cy, q.fullw, q.fullh)
	-- newBack.x, newBack.y = q.cx, q.cy
	newBack:setFillColor( 0 ) 
	newBack=nil

	local points={}
	local canvasXsize = w
	local canvasYsize = h

	local cellSize = math.floor(q.fullw/math.max(canvasXsize,canvasYsize))
	local canvasGroup = display.newGroup()
	drawGroup:insert(canvasGroup)
	canvasGroup.x= canvasYsize==math.max(canvasXsize,canvasYsize) and q.cx-w*.5*cellSize or 0
	canvasGroup.y= canvasXsize==math.max(canvasXsize,canvasYsize) and q.cy-h*.5*cellSize or 0

	for x=1, w do
		points[x] = {}
		for y=1, h do
			
			points[x][y] = display.newRect( 
				canvasGroup, 
				cellSize*(x-1),
				cellSize*(y-1),
				cellSize*(18/20),
				cellSize*(18/20)
			)
			points[x][y].anchorX=0
			points[x][y].anchorY=0
			points[x][y].filled=false
			points[x][y].alpha=.8
			points[x][y].fill=offPointColor
		end
	end

	for i=1, #spawnPos do
		local x, y = spawnPos[i][1], spawnPos[i][2]
		points[x][y].filled=true
		points[x][y]:setFillColor( .2,1,.2 )
	end
	-- if points[x]~=nil and points[x][y]~=nil then
	-- end
	
	local plus = display.newGroup()
	canvasGroup:insert(plus)
	plus.x = w*.5*cellSize
	plus.y = h*.5*cellSize

	local penEdit = display.newImageRect(plus, "images/pen.png", cellSize*.9, cellSize*.9)
	penEdit.anchorX=0
	penEdit.anchorY=0

	local eraseEdit = display.newImageRect(plus, "images/erase.png", -cellSize*.9, cellSize*.9)
	eraseEdit.anchorX=1
	eraseEdit.anchorY=0
	eraseEdit.alpha=0

	-------------------------------------------------------------------
	-------------------------------------------------------------------

		

	local moveZoom = false
	local pen = true
	local toogle = false
	local btToogle
	if isDevice==false then 
		btToogle = display.newRect(drawGroup, q.cx, q.fullh-150, 100, 100)
		btToogle.x, btToogle.y = q.cx+125, q.fullh-150
		btToogle:addEventListener( "tap", 
		function(e)
			if toogle==true then
				toogle = false 
				btToogle:setFillColor(.8)
			else
				toogle = true 
				btToogle:setFillColor(0)
			end
		end )
	end
	local function touch(self, e)
		local target = e.target
		-- print(e.phase, moveZoom and "zoom" or "movePoint" )
		local rect = canvasGroup --self
		if moveZoom then 
			if (e.phase == "began") then
				-- if isDevice==false then
				-- 	rect.dots[#rect.dots] = nil
				-- end
				local dot = newTrackDot(e)

				rect.dots[ #rect.dots+1 ] = dot
				rect.prevCentre = calcAvgCentre( rect.dots )
				updateTracking( rect.prevCentre, rect.dots )
				return true
			elseif (canvasGroup == rect) then--e.parent
				-- print("rect")
				if (e.phase == "moved") then
					local centre, scale = {}, 1
					centre = calcAvgCentre( rect.dots )
					updateTracking( rect.prevCentre, rect.dots )
					if (#rect.dots > 1) and isDevice or toogle then
						scale = calcAverageScaling( rect.dots )
						print("scale: "..scale)
						rect.xScale, rect.yScale = rect.xScale * scale, rect.yScale * scale --* 1.0005
					else
						local pt = {}
						pt.x = rect.x + (centre.x - rect.prevCentre.x)
						pt.y = rect.y + (centre.y - rect.prevCentre.y)
						pt.x = centre.x + ((pt.x - centre.x) * scale)
						pt.y = centre.y + ((pt.y - centre.y) * scale)
						rect.x, rect.y = pt.x, pt.y
						rect.prevCentre = centre
					end
				else -- "ended" and "cancelled" phases
					local centre, scale = {}, 1
					centre = calcAvgCentre( rect.dots )
					updateTracking( rect.prevCentre, rect.dots )
					if (#rect.dots > 1) and isDevice then
						scale = calcAverageScaling( rect.dots )
					end
					-- if (isDevice) then
						local index = table.indexOf( rect.dots, e.target )
						table.remove( rect.dots, index )
						e.target:removeSelf()
						rect.prevCentre = calcAvgCentre( rect.dots )
						updateTracking( rect.prevCentre, rect.dots )
					-- end
		  	end
		  	return true
			end
		else --DRAW
			if e.phase=="began" then
				-- if isDevice==false then
				-- 	plus.dots[#plus.dots] = nil
				-- end
				-- print("doot", #plus.dots)
				-- plus.homMuch = plus.homMuch + 1
				local dot = newTrackDot(e)
				-- print( #plus.dots+1, "added dot" )
				plus.dots[#plus.dots+1] = dot				
				-- plus.prevCentre = {x=dot.x, y=dot.y}
				plus.prevCentre = calcAvgCentre( plus.dots )
				updateTracking( plus.prevCentre, plus.dots )
				return true
			elseif (canvasGroup == rect) then--e.parent
				if (e.phase == "moved") then
					local centre = {}
					-- centre = {x=plus.dots[1].x, y=plus.dots[1].y}
					centre = calcAvgCentre( plus.dots )
					updateTracking( plus.prevCentre, plus.dots )

					-- local scale = calcAverageScaling( rect.dots )
					-- print(rect.xScale,"ooooooo")
					local pt = {}
					local doub = 1 --когда нажатие двумя пвльцами, замедляеется карандаш
					if (((#plus.dots > 1) and isDevice) or toogle) then
						doub=2
					end
					pt.x = plus.x + (centre.x - plus.prevCentre.x)*(1/rect.xScale)*doub
					pt.y = plus.y + (centre.y - plus.prevCentre.y)*(1/rect.xScale)*doub

					plus.prevCentre = centre
					plus.x, plus.y = pt.x, pt.y
						local nowX = 
						q.round(
							(	
								cellSize*.5 +
								plus.x
							)
						/cellSize
						)

						local nowY = 
						q.round(
							(	
								cellSize*.5 + 
								plus.y
							)
						/cellSize
						)
					-- q.valPrint({"CUBE","2DOTS","TOOGLE"},
					-- 	{
					-- 		points[nowX]~=nil and points[nowX][nowY]~=nil, 
					-- 		((#plus.dots > 1) and isDevice),
					-- 		toogle})
					if points[nowX]~=nil and points[nowX][nowY]~=nil and (((#plus.dots > 1) and isDevice) or toogle) then
						if pen==true then
							points[nowX][nowY].filled=true
							points[nowX][nowY]:setFillColor( .4,.95,.4 )
						elseif pen==false then
							points[nowX][nowY].filled=false
							points[nowX][nowY]:setFillColor( unpack(offPointColor) )	
						end
					end
				else -- "ended" and "cancelled" phases
				  -- if (isDevice) then
						local index = table.indexOf( plus.dots, e.target )
						table.remove( plus.dots, index )
						e.target:removeSelf()
						plus.prevCentre = calcAvgCentre( plus.dots )
						updateTracking( plus.prevCentre, plus.dots )
					-- end
				end
		  end
		end
	end
	-------------------------------------------------------------------
	-------------------------------------------------------------------

	local touchFront = display.newRect( drawGroup, q.cx, q.cy, q.fullw, q.fullh)
	touchFront.alpha = .01

	canvasGroup.dots = {}
	plus.dots = {}
	plus.homMuch = 0
	touchFront.touch = touch
	touchFront:addEventListener( "touch" )


	local btChangeMode = display.newRect(drawGroup, q.cx, q.fullh-150, 100, 100)
	local editMode = display.newImageRect(drawGroup, "images/edit.png", 100, 100)
	editMode.x, editMode.y = q.cx, q.fullh-150

	local zoomMode = display.newImageRect(drawGroup, "images/zoom.png", 100, 100)
	zoomMode.x, zoomMode.y = q.cx, q.fullh-150
	zoomMode.alpha=0

	btChangeMode:addEventListener( "tap", 
		function() 
			-- dopInfoText.text="Перемещение/рисование"
			if moveZoom==false then
				moveZoom = true  

				eraseEdit.alpha=0
				penEdit.alpha=0

				editMode.alpha=0
				zoomMode.alpha=1
			else
				if pen then
					penEdit.alpha=1
				else
					eraseEdit.alpha=1
				end
				moveZoom = false 
				editMode.alpha=1
				zoomMode.alpha=0
			end
		end 
	)

	local btPencil = display.newRect(drawGroup, q.cx-125, q.fullh-150, 100, 100)
	
	local penIcon =  display.newImageRect(drawGroup, "images/pen.png", 70, 70)
	penIcon.x, penIcon.y = q.cx-125, q.fullh-150
	penIcon.alpha=0

	local eraseIcon =  display.newImageRect(drawGroup, "images/erase.png", 70, 70)
	eraseIcon.x, eraseIcon.y = q.cx-125, q.fullh-150
	-- eraseIcon.alpha=0

	btPencil:addEventListener( "tap", 
		function()
			-- dopInfoText.text="Ластик/карандаш"
			if pen==false then
				pen = true  
				eraseIcon.alpha=1
				penIcon.alpha=0
				
				eraseEdit.alpha=0
				if not moveZoom then
					penEdit.alpha=1
				end
			else
				pen = false 
				eraseIcon.alpha=0
				penIcon.alpha=1

				penEdit.alpha=0
				if not moveZoom then
					eraseEdit.alpha=1
				end
			end
		end 
		)

	local btSave = display.newRect(drawGroup, 50, 50, 100, 100)
	drawGroup:insert(btSave)
	btSave.fill={.2}

	local btSaveIcon = display.newImageRect( drawGroup, "images/saveshape.png", 90,90 )
	btSaveIcon.x=btSave.x
	btSaveIcon.y=btSave.y

	btSave:addEventListener( "tap", 
	function()
		-- dopInfoText.text="Сохранить (название введи)"
		btSave.fill = {1}
		timer.performWithDelay( 100, function() transition.to(btSave.fill,{r=.2,g=.2,b=.2}) end )
		local dump = {}
		local out = "{"
		for x=1, w do
			for y=1, h do
				if points[x][y].filled==true then
					out = out.."{"..x..","..y.."},"
					dump[#dump+1]={x,y}
				end
			end
		end
		spawnPos = dump
		composer.setVariable( "spawnPos", dump)
		print(out.."}")
	end )


	local onKeyEvent
	if isDevice==false then
		local function crasit(x,y)
			if pen==true then
				points[x][y].filled=true
				points[x][y]:setFillColor( .4,.95,.4 )
			elseif pen==false then
				points[x][y].filled=false
				points[x][y]:setFillColor( .8 )	
			end
		end
		onKeyEvent = function( event )
		  -- print(event.phase)
		  local key = event.keyName
		  if event.phase == "down" then
		    -- print(key)
		    local nowX = 
				q.round(
					(	
						cellSize*.5 +
						plus.x
					)
				/cellSize
				)

				local nowY = 
				q.round(
					(	
						cellSize*.5 + 
						plus.y
					)
				/cellSize
				)
		    if key=="space" then
		      toogle = true 
					btToogle:setFillColor(0)
					crasit(nowX,nowY)
		    elseif key=="leftShift" then
		    	if pen==false then
						pen = true  
						eraseEdit.alpha=0
						eraseIcon.alpha=0
						penIcon.alpha=1
						if not moveZoom then
							penEdit.alpha=1
						end
					else
						pen = false 
						eraseIcon.alpha=1
						penEdit.alpha=0
						penIcon.alpha=0
						if not moveZoom then
							eraseEdit.alpha=1
						end
					end
		    elseif key=="w" then
		    	plus.y = plus.y - cellSize
		    	if toogle then crasit(nowX,nowY-1) end
		    elseif key=="a" then
		    	plus.x = plus.x - cellSize 
		    	if toogle then crasit(nowX-1,nowY) end
		    elseif key=="s" then
		    	plus.y = plus.y + cellSize 
		    	if toogle then crasit(nowX,nowY+1) end
		    elseif key=="d" then
		    	plus.x = plus.x + cellSize 
		    	if toogle then crasit(nowX+1,nowY) end
		    end
		  elseif event.phase == "up" then
		    -- print(key)
		    if key=="space" then
		      toogle = false 
					btToogle:setFillColor(.8)
		    end
		  end

		  return false
		end
		Runtime:addEventListener( "key", onKeyEvent )
	end
	local btExit = display.newRect(drawGroup, q.fullw-50, 50, 100, 100)
	local exit = display.newImageRect(drawGroup, "images/toMenu.png", 80, 80)
	exit.x, exit.y = q.fullw-50, 50
	exit.rotation=180
	exit:setFillColor( 0 )
	btExit:addEventListener( "tap", function() 
		for x=1, w do
			for y=1, h do
				display.remove(points[x][y])
				points[x][y]=nil
			end
		end
		points = nil
		display.remove(canvasGroup) 
		display.remove(drawGroup) 
		display.remove(btName)
  	if isDevice==false then 
  		Runtime:removeEventListener( "key", onKeyEvent )
		end
	end)
end


local function movePart(self, e)
	local target = e.target
	local rect = mainGroup --self
	-- print(e.phase)
	if (e.phase == "began") then
		-- print"noooww"
		local dot = newTrackDot(e)
		rect.dots[ #rect.dots+1 ] = dot
		rect.prevCentre = calcAvgCentre( rect.dots )
		updateTracking( rect.prevCentre, rect.dots )
		return true
	elseif (e.phase == "moved") then
		-- print"hoookenfjenFWOINiww"
		local centre, scale = {}, 1
		centre = calcAvgCentre( rect.dots )
		updateTracking( rect.prevCentre, rect.dots )
		if ((#rect.dots > 1) and isDevice)  then
			scale = calcAverageScaling( rect.dots ) or 1
			mainGroup.xScale, mainGroup.yScale = mainGroup.xScale * scale, mainGroup.yScale * scale
			-- print('ca')
		else
			local pt = {}
			pt.x = rect.x + (centre.x - rect.prevCentre.x)
			pt.y = rect.y + (centre.y - rect.prevCentre.y)
			pt.x = centre.x + ((pt.x - centre.x) * scale)+1
			pt.y = centre.y + ((pt.y - centre.y) * scale)+1
			rect.x, rect.y = pt.x, pt.y
			rect.prevCentre = centre
		end
	else -- "ended" and "cancelled" phases
		-- print"hooo"
		local centre, scale = {}, 1
		centre = calcAvgCentre( rect.dots )
		updateTracking( rect.prevCentre, rect.dots )
		if (#rect.dots > 1) then
			scale = calcAverageScaling( rect.dots )
		end
		local index = table.indexOf( rect.dots, e.target )
		table.remove( rect.dots, index )
		e.target:removeSelf()
		rect.prevCentre = calcAvgCentre( rect.dots )
		updateTracking( rect.prevCentre, rect.dots )
  	return true
	end
end

local function drawAll()
	-- timer.cancel("check")
	-- print("work")
	-- print(w,h)
	-- print(greed,#greed)
	for x=1, w do
		for y=1, h do
			local buteNum = x+w*(y-1)
			local cell = greed[buteNum]
			if x<100 then
				-- print(x,y, buteNum,type(ceil))
			end
			if cell~=nil then
				-- print("not nil")
				if cell.func=="bot" then
					local botAlredyDie = true
					for i=1, #bots do
						if cell.x==bots[i].x and cell.y==bots[i].y then
							-- print("bot not died")
							addBotBody(bots[i],bots[i].x,bots[i].y)
							botAlredyDie = false
							break
						end
					end
					if botAlredyDie then print("bot not found")greed[buteNum]=nil end
				elseif cell.func=="food" then				
					addCellBody(greed[buteNum],x,y)
				end
			end
		end
	end
	draw=true
end
local function removeAll(num)
	timer.cancel("check")
	draw=false
	drawmode=1
	for x=1, w do
		for y=1, h do
			local buteNum = x+w*(y-1)
			local cell = greed[buteNum]
			if cell~=nil then 
				if cell.func=="bot" then 
					display.remove(cell.allBody)
				elseif cell.func=="food" then				
					display.remove(cell.body)
				end
			end
		end
	end
	for i=1, num do
		checkAll()
	end
	drawAll()
end

local function drawAllRotate( )
	drawRotate = true
	for i=1, #bots do
		createRot(bots[i])
	end
end

local function removeAllRotate( )
	drawRotate = false
	for i=1, #bots do
		display.remove(bots[i].view)
	end
end

local function stringToTable(str)
	local mas = {}
	for v in str:gmatch("%d+") do
		mas[#mas+1] = tonumber(v)
	end
	return mas[1], mas[2]
end

if isDevice==false then -- Перемещение с помощью клавиатуры
	local pcMove
	local moveTimer
	local toogle
	local moveNow = false
	-- local moveNow = false
	local wait = 800
	local chastot = 200
	local function moveX( x )
		if moveNow==false then return end
		mainGroup.x = (mainGroup.x or 0) + x --* (1/mainGroup.xScale)
		timer.performWithDelay(chastot, function() moveX( x ) end)
	end
	local function moveY( y )
		if moveNow==false then return end
		mainGroup.y = (mainGroup.y or 0) + y --* (1/mainGroup.xScale)
		timer.performWithDelay(chastot, function() moveY( y ) end)
	end
	pcMove = function(event)
		local key = event.keyName
		print( key )
	  if event.phase == "down" then
	    if key=="leftShift" then
	      toogle = true 
	    elseif key=="+" then  
		    	mainGroup.xScale = (mainGroup.xScale or 1) * 1.1
		    	mainGroup.yScale = (mainGroup.yScale or 1) * 1.1
	    elseif key=="-" then  
		    	mainGroup.xScale = (mainGroup.xScale or 1) * (1/1.1)
		    	mainGroup.yScale = (mainGroup.yScale or 1) * (1/1.1)
	    elseif toogle then
		    if key=="w" then
	    		moveNow = true
			    moveY(100)
		    elseif key=="a" then
	    		moveNow = true
		    	moveX(100) --* (1/mainGroup.xScale)
		    elseif key=="s" then
	    		moveNow = true
		    	moveY(-100) --* (1/mainGroup.xScale)
		    elseif key=="d" then
	    		moveNow = true
		    	moveX(-100) --* (1/mainGroup.xScale)
		    end
		  end
	  elseif event.phase == "up" then
	    -- print(key)
	    if key=="leftShift" then
	      toogle = false 
	    elseif key=="w" or key=="a" or key=="s" or key=="d" then
	    	moveNow = false
	    	-- timer.cancel("move")
	    	-- if moveTimer then timer.cancel(moveTimer) end
	    	-- print("SSSSSSS")
	    end
	  end

	  return false
	end
	Runtime:addEventListener( "key", pcMove )
end

local warningGroup
local function updateWarnig() -- баг, не останавливается игра
  local mem = q.round(collectgarbage("count"))
  if mem>=(1024*30) then
    timer.cancel("warn")
		timer.cancel( "check" )
		q.stopGame()

  	timer.performWithDelay( 1, 
  	function()
  		timer.cancel("warn")
			timer.cancel( "check" )
			q.stopGame()
  	end )
  	timer.performWithDelay( 100, 
  	function()
  		timer.cancel("warn")
			timer.cancel( "check" )
			q.stopGame()
  	end )
    warningGroup = display.newGroup()
    local back = display.newRect(warningGroup, q.cx, q.cy, q.fullw, q.fullh)
    back.fill={1,0,0,.5}
    local backWarn = display.newRect( warningGroup, q.cx, q.cy, 400*1.3, 120*1.3 )
		backWarn.fill = colorMulti(q.CL"233d4d", .85)
		local labelWarn = display.newText( warningGroup, "БОЛЬШАЯ ЗАГРУЗКА ПАМЯТИ!", q.cx, q.cy-35, nil, 30)
		local backBut = display.newRect( warningGroup, q.cx, q.cy+30, 220, 60 )
		backBut.fill = colorMulti(q.CL"233d4d", .8)
		backWarn.fill = q.CL"233d4d"local labelWarn = display.newText( warningGroup, "ПРОДОЛЖИТЬ", q.cx, q.cy+30, nil, 25)
		backBut:addEventListener( "tap", 
		function()
			display.remove( warningGroup )
		end)
  end
end

local function showAndHideGuide(text)
	if not needGuide then return end
	backGuide.alpha=0
	guideLabel.text = text
	guideLabel.y = q.fullh-140
	if guideTimer then timer.cancel(guideTimer) end
	transition.cancel( "guide" )
	transition.to( guideLabel, {time=200, alpha=1, tag="guide"} )
	guideTimer = timer.performWithDelay( 3000, function()
		transition.to( guideLabel, {time=1000, alpha=0, tag="guide"} )
		guideTimer = nil
	end)
end



local worldNum, mapParam
function scene:create( event )
	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)
	mainGroup.xScale = 1.01
	mainGroup.yScale = 1.01

	mainCellGroup = display.newGroup()
	mainGroup:insert(mainCellGroup)

	mainGroup.dots={}
	mainGroup.touch=movePart


	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	backGuide = display.newRect(uiGroup, 0, 0, 1,1)
	backGuide.alpha=0
	backGuide.fill={.2}
	
	guideLabel = display.newText( {
		group = uiGroup, 
    text = "",
    x = q.cx,
    y = q.fullh-140,
    width = q.fullw,
    font = "fifaks.ttf",
    fontSize = 55,
    align = "center",
	} )
	guideLabel.anchorY=1
	guideLabel.align="center"


	local downControlGroup = display.newGroup()
	uiGroup:insert(downControlGroup)
	downControlGroup.x = q.fullw
	downControlGroup.y = q.fullh

	local backControl = display.newRect( downControlGroup, 0, 0, q.fullw, 140)
	backControl.anchorX=1
	backControl.anchorY=1
	backControl.alpha=.5
	backControl:setFillColor( .2 )

	local buttonSize = 80
	local logoSize = buttonSize*.8
	local spaseSize = (backControl.height - buttonSize)*.4
	local halfB = buttonSize*.5
	-- local expandMenu = display.newRect( downControlGroup, 0, -140, q.fullw, 80)
	-- expandMenu.anchorX=1
	-- expandMenu.anchorY=1
	-- expandMenu.alpha=.5
	-- expandMenu:setFillColor( .2 )

	-- local expandIcon = display.newGroup()
	-- downControlGroup:insert( expandIcon )
	-- expandIcon.y = -100
	-- expandIcon.x = -720/2
	-- local a = display.newRect(expandIcon, 0, 0, 100, 20)
	
	leftButtonsGroup = display.newGroup()
	uiGroup:insert(leftButtonsGroup)

	local clearDesk = display.newRect ( leftButtonsGroup, halfB+spaseSize, halfB+spaseSize*2+buttonSize-10, buttonSize, buttonSize)
	clearDesk.alpha=.2
	local clearIcon = display.newPolygon( leftButtonsGroup, clearDesk.x, clearDesk.y, {0,0, 1,0, 1,1, 2,1, 2,2, 1,2, 1,3, 0,3, 0,2, -1,2, -1, 1, 0,1 } )
	clearIcon.fill={.85,0,0}
	clearIcon.rotation = 45
	clearIcon.xScale=20
	clearIcon.yScale=20

	local deleteShape = display.newRect( leftButtonsGroup, clearDesk.x, clearDesk.y+buttonSize+spaseSize, buttonSize, buttonSize )
	deleteShape.alpha=.2
	local deleteIcon = display.newRect( leftButtonsGroup, clearDesk.x, clearDesk.y+buttonSize+spaseSize, 60, 20 )
	deleteIcon = nil

	local spawnMode = display.newRect( leftButtonsGroup, clearDesk.x, deleteShape.y+buttonSize+spaseSize+5, buttonSize, buttonSize )
	spawnMode.alpha = .2
	local spawnIcon = display.newImageRect( leftButtonsGroup, "images/pen.png", logoSize, logoSize)
	spawnIcon.x, spawnIcon.y = spawnMode.x, spawnMode.y

	local loadShapes = display.newRect( leftButtonsGroup, clearDesk.x, spawnMode.y+buttonSize+spaseSize, buttonSize, buttonSize )
	loadShapes.alpha=.2
	local loadSPIcon = display.newImageRect( leftButtonsGroup, "images/razm.png", logoSize, logoSize)
	loadSPIcon.x, loadSPIcon.y = clearDesk.x, loadShapes.y

	local helpsBut = display.newRect( leftButtonsGroup, clearDesk.x, loadShapes.y+buttonSize+spaseSize, buttonSize, buttonSize )
	helpsBut.alpha=.4
	local helpsIcon = display.newImageRect( leftButtonsGroup, "images/info.png", logoSize, logoSize)
	helpsIcon.x, helpsIcon.y = helpsBut.x, helpsBut.y	
	helpsBut.fill = {0,1,0}

	local toMenu = display.newRect( leftButtonsGroup, helpsBut.x, helpsBut.y+buttonSize+spaseSize, buttonSize, buttonSize )
	toMenu.alpha=.2
	local toMenuIcon = display.newImageRect( leftButtonsGroup, "images/toMenu.png", logoSize, logoSize)
	toMenuIcon.x, toMenuIcon.y = toMenu.x, toMenu.y	



	local buttonSize = 100
	local logoSize = buttonSize*.8
	local spaseSize = (backControl.height - buttonSize)*.5
	local halfB = buttonSize*.5


	local autoStartGroup = display.newGroup()
	downControlGroup:insert(autoStartGroup)
	local autoStartButton = display.newRect( autoStartGroup, -spaseSize-buttonSize-spaseSize*.5, -spaseSize-halfB, buttonSize*2+spaseSize, buttonSize )
	autoStartButton.alpha=.2
	TimerIcon = display.newImageRect( autoStartGroup, "images/clock.png", 80, 80 )
	TimerIcon.x, TimerIcon.y = autoStartButton.x, autoStartButton.y
	stopTimerIcon = display.newRect( autoStartGroup, 0, 0, 60, 60 )
	stopTimerIcon.x, stopTimerIcon.y = autoStartButton.x, autoStartButton.y
	stopTimerIcon.alpha = 0

	local tapCheck  = display.newRect(downControlGroup, -buttonSize-(spaseSize+autoStartButton.width+buttonSize)*.5-spaseSize*2, -spaseSize-halfB, buttonSize, buttonSize)
	tapCheck.alpha = .2
	local tapIcon = display.newPolygon( downControlGroup, tapCheck.x, tapCheck.y, {0,-30, 30,0, 0,30})

	local drawModeChanger = display.newRect( downControlGroup, tapCheck.x-buttonSize-spaseSize, -spaseSize-halfB, buttonSize, buttonSize )
	drawModeChanger.alpha=.2
	local drawModeChangerIcon = display.newImageRect( downControlGroup, "images/view.png", logoSize, logoSize )
	drawModeChangerIcon.x, drawModeChangerIcon.y = drawModeChanger.x, drawModeChanger.y
	drawModeChangerIcon = nil

	local moveLock = display.newRect( downControlGroup, drawModeChanger.x-buttonSize-spaseSize, -spaseSize-halfB, buttonSize, buttonSize )
	moveLock.alpha = .2
	local moveLockIcon = display.newImageRect( downControlGroup, "images/zoom.png", logoSize, logoSize)
	moveLockIcon.x, moveLockIcon.y = moveLock.x, moveLock.y

	local saveWorld = display.newRect( downControlGroup, moveLock.x-100-spaseSize*2.5, moveLock.y, buttonSize*1.6, buttonSize )
	saveWorld.alpha = .2
	local saveWorldIcon = display.newImageRect( downControlGroup, "images/floppy3.png", logoSize, logoSize)
	saveWorldIcon.x, saveWorldIcon.y = saveWorld.x, saveWorld.y
  






	step = 0
	lblStep = display.newText( uiGroup, "Шагов: 0", 10, 10, native.newFont("fifaks"), 40 )
	lblStep.anchorX=0
	lblStep.anchorY=0

	lblPopulation = display.newText( uiGroup, "Популяция: 1", 10, 60, native.newFont("fifaks"), 40 )
	lblPopulation.anchorX=0
	lblPopulation.anchorY=0

	lblRelatives = display.newText( uiGroup, "Родствеников: 1", q.fullw-10, 10, native.newFont("fifaks"), 40 )
	lblRelatives.anchorX=1
	lblRelatives.anchorY=0
	lblRelatives.text = ""


	local screenBack
	q.event.add( "saveWorld", saveWorld, 
  function()
  	showAndHideGuide("Произошло сохранение мира")
  	display.remove(screenBack) --убирвю задний фон чтобы сделать скрин
  	local smallGreed = {}
		for i=1, w*h do
			if greed[i] and greed[i].func~=nil then 
				smallGreed[i] = {func=greed[i].func}
				if greed[i].func=="bot" then
					smallGreed[i].x = greed[i].x 
					smallGreed[i].y = greed[i].y 
				end
			end
		end
		for i=1, #bots do
			bots[i].used = nil
			bots[i].allBody = nil
			bots[i].body = nil
		end
		local viewPoint = {
			x = mainGroup.x,
			y = mainGroup.y,
			xScale = mainGroup.xScale,
			yScale = mainGroup.yScale,
		}

  	print("saved")
  	mapParam.dopInfo = {
  		world = smallGreed,
  		i = 1,
  		type = worldType,
  		bots = bots,
  		step = step,
  		population = #bots,
  		drawmode = drawmode,
  		viewPoint = viewPoint,
  	}
  	local num = q.addWorld(mapParam.world.name, mapParam)
  	display.save( mainGroup, { filename="world"..num..".png", baseDir=system.DocumentsDirectory, captureOffscreenArea=true, backgroundColor={0,0,0,0} } )

  	composer.setVariable("spawnPos", 0)
		display.remove(backGuide)
		display.remove(guideLabel)
		print("spawnPos is", composer.getVariable("spawnPos") )
		timer.cancelAll()
		transition.cancel( )

		composer.removeScene( "menu" )
    composer.removeScene( "game" )
    composer.gotoScene( "menu" )
  end)

	q.event.add( "guide", helpsBut,
	function()
		if needGuide==false then
			helpsBut.fill = {0,1,0}
			helpsBut.alpha = .4
			needGuide = true
  		showAndHideGuide("Подсказки включены")
		else
  		showAndHideGuide("Подсказки выключены")
			helpsBut.fill = {1,1,1}
			helpsBut.alpha = .2
			needGuide = false
		end
	end)

	q.event.add("timerStart",autoStartButton,
	function()
		if simOnGoing==false then
  		showAndHideGuide("Включение симуляции")
			startSim()
		else
  		showAndHideGuide("Остановка симуляции")
			stopSim()
			
		end
	end)
	q.event.add("oneStep",tapCheck,function()
  	showAndHideGuide("Один шаг симуляции")
		if not onGoing then
			checkAll()
		end
	end)

	q.event.add("spawnMode",spawnMode,function() 

  	showAndHideBackGuide("Редактор спавна клеток(спавн после очистки мира)",q.fullh-250)
		spawnEditor()
	end)

	
	-- -- -- -- == =
	-- -- -- -- == =
	-- -- -- -- == =
	mapParam = composer.getVariable( "loadedWolrd" )
	print( q.printTable(mapParam.world) )
	genSize(mapParam.world.width, mapParam.world.height)
	-- print("size is",mapParam.world.width)
	worldType = mapParam.dopInfo.type
	worldNum = mapParam.dopInfo.i
	print("mapParam i - ",mapParam.dopInfo.i)
	-- nowZima = tonumber(mapParam.world.winter)==2

	startEnergy = tonumber(mapParam.bots.startenergy)
	maxEnergy = tonumber(mapParam.bots.maxenergy)
	diedBodyEnergy = tonumber(mapParam.bots.diedenergy)
	
	newOld = tonumber(mapParam.bots.maxlive)
	moveCost = tonumber(mapParam.bots.movecost)
	liveCost = tonumber(mapParam.bots.livecost)
	
	botHp = tonumber(mapParam.bots.hp)
	dmg = tonumber(mapParam.bots.dmg)

	maxSun = tonumber(mapParam.world.maxsun)
	lowSun = tonumber(mapParam.world.minsun)
	mineralEn = tonumber(mapParam.world.mineralenergy)

	print("died color",mapParam.colors.diedcolor)
	c.died = q.CL(mapParam.colors.diedcolor)
	print("died color",c.died)
	c.wall = q.CL(mapParam.colors.wallscolor)
	c.back = q.CL(mapParam.colors.backgroundcolor)
	c.sun = q.CL(mapParam.colors.suncolor)
	c.outline = q.CL(mapParam.colors.outlinecolor)
	c.mineral = q.CL(mapParam.colors.mineralcolor)
	
	local mineralSpace = tonumber(mapParam.world.mineralspace)

	ostOneTherd = {}
	local niz = maxSun + mineralSpace

	ostOneTherd[1] = math.floor((niz))
	ostOneTherd[2] = math.floor((niz)+(h-niz)/3)
	ostOneTherd[3] = math.floor((niz)+(h-niz)/3*2)
	if worldType=="zone" then
		blockSize=tonumber(mapParam.blockSize)
		sunSize=tonumber(mapParam.sunSize)
		maxSun=tonumber(mapParam.maxSun)
		--[[для того чтобы во время зума(когда палец уходит за границу карты), поле не "улетало" в сторону]]
		screenBack = display.newRect(mainGroup, w*cellSize*.5, h*cellSize*.5, q.fullw*(1+2*2), q.fullh*(1+2*2) )
		screenBack.fill={.1}

		local backOutLineRed = display.newRect(mainGroup, 
			cellSize*w*.5, cellSize*h*.5, 
			cellSize*(w+2), cellSize*(h+2))
		backOutLineRed.fill={.6,0,.6}

		local backLight = display.newRect(mainGroup, 0, 0, cellSize*w, cellSize*h)
		backLight.fill={0}
		backLight.anchorX=0
		backLight.anchorY=0

		local quaSun = {} --Генерирую четверть солнечной зоны(типо от 0 до 12 солнца)
		for x=1, sunSize*.5 do
			quaSun[x] = {}
			for y=1, sunSize*.5 do
				local rez = math.min(x,y)
				rez = q.round((rez/(sunSize*.5))*maxSun)/maxSun
				quaSun[x][y] = rez
			end
		end

		for x=sunSize*.5+1, sunSize do
			quaSun[x] = {}
			for y=1, sunSize*.5 do
				quaSun[x][y] = quaSun[(sunSize-x+1)][y]
			end 
		end

		for x=1, sunSize do
			for y=sunSize*.5+1, sunSize do
				quaSun[x][y] = quaSun[x][(sunSize-y+1)]
			end
		end


		sunMap = {}
		for x=1, blockSize do
			sunMap[x] = {}
			for y=1, blockSize do
				sunMap[x][y] = 0
			end
		end

		local freeSpase = (blockSize - sunSize) * .5
		for x=1, sunSize do
			for y=1, sunSize do
				-- sunMap[freeSpase+x][freeSpase+y] = maxSun/10-quaSun[x][y]	
				sunMap[freeSpase+x][freeSpase+y] = quaSun[x][y]	
			end
		end

		local zoneSize = #sunMap
		local sunZonesPos= {}
		local numXzones, numYzones = math.floor((w+1)/zoneSize)-1, math.floor((h+1)/zoneSize)-1 
		for thisZoneY=0, numYzones do
			for thisZoneX=0, numXzones do
				sunZonesPos[thisZoneX+1+thisZoneY*(numXzones+1)] = {thisZoneX*zoneSize+1, zoneSize*thisZoneY+1}
				for x=1, zoneSize do
					for y=1, #sunMap[x] do
						if sunMap[x][y]~=0 then
							local a = display.newRect(mainGroup, (thisZoneX*zoneSize+x-.5)*cellSize, (zoneSize*thisZoneY+y-.5)*cellSize,cellSize,cellSize)
							a.fill = {sunMap[x][y],0,sunMap[x][y]}
							-- print("filled",tonumber(sunMap[x][y],16))
						end
					end
				end
			end
		end


		local spawnPoslocal = composer.getVariable("spawnPos")
		if spawnPoslocal==nil or spawnPoslocal==0 then
			spawnPos = {}
			local i = 1
			for j=1, #sunZonesPos do
				print("spawn",i)
				local x, y = unpack( sunZonesPos[j] )
				x, y = x + #sunMap*.5, y + #sunMap*.5
				spawnPos[i]={x-1,y-1} i = i + 1
				spawnPos[i]={x-1,y} i = i + 1
				spawnPos[i]={x,y-1} i = i + 1
				spawnPos[i]={x,y} i = i + 1
			end

			composer.setVariable("spawnPos",spawnPos)
		else
			spawnPos = composer.getVariable("spawnPos")
		end
	elseif worldType=="sea" then
		local sunn = maxSun+0
		if nowZima then
			sunHowMuch = function(bot)
				if not nowZima then
					sunEn = math.floor((10 - math.floor((bot.y-2)*(10/(h*.6)))))
				else
					sunEn = math.floor((8 - math.floor((bot.y-2)*(8/(h*.4)))))
				end
				sunEn = sunEn<0 and 0 or sunEn
				return sunEn
			end
		else
			sunHowMuch = function(bot)
				local sunEn = math.floor((10 - math.floor((bot.y-2)*(10/(h*.6)))))
				sunEn = sunEn<0 and 0 or sunEn
				return sunEn
			end
		end

		screenBack = display.newRect(mainGroup, w*cellSize*.5, h*cellSize*.5, q.fullw*(1+2*2), q.fullh*(1+2*2) )
		screenBack.fill={.1}

		local backOutLine = display.newRect(mainGroup, 
			cellSize*w*.5, cellSize*h*.5, 
			cellSize*(w+2), cellSize*(h+2))
		backOutLine.fill = c.outline

		local backLight = display.newRect(mainGroup, 0, 0, cellSize*w, cellSize*h)
		backLight.fill = c.back
		backLight.anchorX=0
		backLight.anchorY=0

		local limitSun = maxSun + 0
		for i=1, h do
			local a = math.floor((10 - math.floor((i-2)*(10/(h*.6)))))
			if a<1 then maxSun = i-1 break end  
		end

		for i=1, h do
			local a = math.floor((8 - math.floor((i-2)*(8/(h*.4)))))
			if a<1 then lowSun = i-1 break end  
		end

		for i=1, maxSun do
			local sunBack = display.newRect(mainGroup, 0, cellSize*(i-1), cellSize*w, cellSize)
			sunBack.fill = c.sun
			sunBack.alpha=sunHowMuch({y=i})/limitSun
			sunBack.anchorX=0
			sunBack.anchorY=0
		end

		-- local a = display.newRect( mainGroup, 0, ostOneTherd[1]*cellSize, cellSize*w, (ostOneTherd[2]-ostOneTherd[1])*cellSize )
		-- a.fill = c.mineral
		-- a.alpha  = .1
		-- a.anchorX = 0
		-- a.anchorY = 0
		-- local a = display.newRect( mainGroup, 0, ostOneTherd[2]*cellSize, cellSize*w, (ostOneTherd[3]-ostOneTherd[2])*cellSize )
		-- a.fill = c.mineral
		-- a.alpha  = .3
		-- a.anchorX = 0
		-- a.anchorY = 0
		-- local a = display.newRect( mainGroup, 0, ostOneTherd[3]*cellSize, cellSize*w, (h-ostOneTherd[3])*cellSize )
		-- a.fill = c.mineral
		-- a.alpha  = .4
		-- a.anchorX = 0
		-- a.anchorY = 0

		-- for i=1, 3 do
		-- 	local sector = display.newRect(mainGroup, 0, h*cellSize, cellSize*w, cellSize*(h/6)*i)
		-- 	sector.anchorX=0
		-- 	sector.anchorY=1
		-- 	sector.alpha=.1
		-- 	sector.fill={0,0,1}
		-- end

		local spawnPoslocal = composer.getVariable("spawnPos")
		if spawnPoslocal==nil or spawnPoslocal==0 then
			spawnPos = {}
			local i = 1
			for x = 2, w-1, 15 do
				spawnPos[i]={x,2} i = i + 1
				spawnPos[i]={x,math.floor(h/2)-5} i = i + 1
				spawnPos[i]={x,math.floor(h/2)+5} i = i + 1
			end
			composer.setVariable("spawnPos",spawnPos)
		else
			spawnPos = spawnPoslocal
		end
	end

	mainGroup.x=((q.fullw-w*cellSize)*.5)+ (1-mainGroup.xScale)*cellSize*w*.5
	mainGroup.y=((q.fullh-h*cellSize)*.5)+ (1-mainGroup.yScale)*cellSize*h*.5
	sixH = math.floor(h/6)
	
	

	q.event.add("viewChange",drawModeChanger,
	function()
		if drawmode<0 then drawmode = 0 end
		drawmode = drawmode + 1
		if drawmode>4 then drawmode=1 end
  	showAndHideBackGuide("Изменение окраски мира. Текущяя - "..drawmode..".\n1 - вид питания, зелёный - солнце, красный - другие клетки(хищник).\n2 - вид энергии, желтые - мало, красные - много.\n3 - вид возраста, чем ярче тем моложе.", q.fullh-140)

		lblRelatives.text = ""
		draw4Code = {}

		if drawmode==1 then --"eat"
			for i=1, #bots do
				local bot = bots[i]
					local all = (bot.eated + bot.sun + bot.mineted)
					if all==0 then
						bot.body.fill= {	.5, .5, .5}
					else
						bot.body.fill= {	.3+bot.eated/all*2.8, .3+bot.sun/all*.5-bot.eated/all*3, .3+bot.mineted/all*.5-bot.eated/all*.8}
					end
					-- if bot.die==false then
					-- 	bot.body.fill= {0}
					-- end
			end

		elseif drawmode==2 then --"energy"
			for i=1, #bots do
				local bot = bots[i]
				bot.body.fill= {	.8+bot.energy/maxEnergy*.2, .8-bot.energy/maxEnergy*.4, 0}
			end
		
		elseif drawmode==3 then --"old"
			for i=1, #bots do
				local bot = bots[i]
				bot.body.fill= {	.1+bot.new/newOld*.7, .1+bot.new/newOld*.7, 1}
			end		
		elseif drawmode==4 then --"pov"
			for i=1, #bots do
				local bot = bots[i]
				bot.body.fill = groupsColors[bot.zoneNum]
			end		
		end
	end)


	local listGroup


	q.event.add("loadBots",loadShapes,
	function()
  	showAndHideGuide("Выбор генома для клеток после очистки мира. Зелёный выбранный. Сохранить геном можно нажав на клетку и нажать SAVE. Ввести название и ещё раз нажать SAVE")
		createList(loadShapes.x, loadShapes.y, 0, uiGroup, {text={.8,.8,.8},rect={.2,.2,.2,1}}, "load", 
		function(k, v)
			q.addBot("start", k)
			createList(loadShapes.x, loadShapes.y, 0, uiGroup, false, "load")
		end	)
	end)

	q.event.add("clearAll",clearDesk,
	function()
  	if needGuide then
	  	showAndHideGuide("Очистка мира...")
			q.event.remove(true)
	  	timer.performWithDelay( 1000, function()
				composer.setVariable("worldNum", 0)
				timer.cancelAll()
				transition.cancel( )
				display.remove(backGuide)
				display.remove(guideLabel)
				composer.removeScene( "menu" )
		    composer.removeScene( "game" )
		    composer.gotoScene( "game" )
	    end)
	  else
	  	composer.setVariable("worldNum", 0)
			timer.cancelAll()
			transition.cancel( )
			display.remove(backGuide)
			display.remove(guideLabel)
			composer.removeScene( "menu" )
	    composer.removeScene( "game" )
	    composer.gotoScene( "game" )
	  end
	end)

	q.event.add("toMenu",toMenu,
	function()
		composer.setVariable("spawnPos", 0)
		print("spawnPos is", composer.getVariable("spawnPos") )
		timer.cancelAll()
		transition.cancel( )
		display.remove(backGuide)
		display.remove(guideLabel)

		composer.removeScene( "menu" )
    composer.removeScene( "game" )
    composer.gotoScene( "menu" )
	end)

	q.event.add("deleteBot",deleteShape,
	function()
  	showAndHideGuide("Удаленние сохранёных геномов")
		createList(deleteShape.x, deleteShape.y, 0, uiGroup, {text={.8,.2,.2},rect={.1,.1,.1,1}}, "load", 
		function(k, v)
			q.removeBot(k)
			createList(deleteShape.x, deleteShape.y, 0, uiGroup, false, "load")
		end	)
	end)

	local zoom = false
	
	q.event.add("canMoveCube",moveLock,
	function()
		if zoom==false then
  		showAndHideGuide("Движение и зум разблокированно")
			moveLock.fill = {0,1,0}
			mainGroup:addEventListener( "touch" )
			zoom = true
		else
  		showAndHideGuide("Движение и зум заблокированно")
			moveLock.fill = {1}
			mainGroup:removeEventListener( "touch" )
			zoom = false
		end
	end)
	mainCellGroup:toFront( )




	q.event.on("clearAll")
	q.event.on("timerStart")
	-- q.event.on("skip")
	q.event.on("guide")
	q.event.on("toMenu")
	q.event.on("loadBots")
	q.event.on("deleteBot")
	q.event.on("oneStep")
	q.event.on("viewChange")
	q.event.on("canMoveCube")
	q.event.on("spawnMode")
	q.event.on("saveWorld")
end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
    composer.removeScene( "menu" )
    
    if worldNum==0 then
	    for i=1, #spawnPos do
				addBot(spawnPos[i][1],spawnPos[i][2],nil, math.floor((i-1)/4)+1)
			end
		  lblPopulation.text = "Популяция: " .. #bots
		else
			local WorldsTable = q.loadWorlds(worldNum)
			bots = nil
			
			greed = WorldsTable.dopInfo.world
			bots = WorldsTable.dopInfo.bots
			for i=1, w+w*(h-1) do
				greed[i] = greed[tostring( i )]
				greed[tostring( i )]=nil
			end
			for i=1, #bots do
				local bot = bots[i]
				local buteNum = bot.x+w*(bot.y-1)
				greed[buteNum] = bot
				bots[i].used = {cmd={},skip={}}
			end
		  
		  step = WorldsTable.dopInfo.step
			drawmode = WorldsTable.dopInfo.drawmode or 1

		  lblPopulation.text = "Популяция: " .. WorldsTable.dopInfo.population
			lblStep.text = "Шагов: "..step
			
			for k, v in pairs(WorldsTable.dopInfo.viewPoint) do
				mainGroup[k] = v
			end
			drawAll()
		end

		print("wall",mapParam.world.wallstype)
		if mapParam.world.wallstype==2 then
			for y=1, h do
				addWall(1,y)
				addWall(w,y)
			end
		elseif mapParam.world.wallstype==3 then
			for x=1, w do
				addWall(x,1)
				addWall(x,h)
			end
		elseif mapParam.world.wallstype==4 then
			for x=1, w do
				addWall(x,1)
				addWall(x,h)
			end
			for y=1, h do
				addWall(1,y)
				addWall(w,y)
			end
		end
	elseif ( phase == "did" ) then
		-- showPop(bots[1])
		-- timer.performWithDelay( 1000, updateWarnig, 0, "warn" )
    

    


    -- local a = display.newRect( 100, 200+125, 100, 100 )
    -- a:addEventListener( "tap", 
    -- function() 
    -- 	local worlds = q.loadWorlds()
    -- 	for k, v in pairs(worlds) do
    -- 		print(k,type(v))
    -- 	end
    -- end)

	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then
	end
end


function scene:destroy( event )

	local sceneGroup = self.view
	-- composer.setVariable("skip",inputSkip.text)
	q.event.remove(true)
	timer.cancel( "warn" )
end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
