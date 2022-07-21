local widget = require( "widget" )
local composer = require( "composer" )
local scene = composer.newScene()

local q = require"base"
q.checkBots()


local backGroup, mainGroup, scrollGroup, afterGroup, uiGroup

local firldsTable = {}

local labels = {}

local function getTextSize(font,fontSize)
	local a = display.newText("A",-q.fullw,-q.fullh, font, fontSize )
	local w, h = a.width, a.height
	display.remove( a )
	return w, h
end
local function createButton(x,y,paramText)

	local left = q.cx - (q.fullw-100)*.5
	local label = display.newText(paramText.group, paramText.text, left+20, y, paramText.font, paramText.fontSize)
	label:setFillColor(unpack(q.CL"dddddd"))
	label.anchorX=0

	local back = display.newRect(paramText.group, q.cx, y, q.fullw-100, label.height+40)
	back.fill = q.CL"363b51"
	back:toBack( )

	return back, label
end

local function createField(x,y,paramText)
	local w, h = getTextSize(paramText.font, paramText.fontSize)
	local back = display.newRect(paramText.group, q.fullw-50, y, q.fullw-100-60, h+40)
	-- back.fill = {1,0,0}--q.CL"363b51"
	back.fill = q.CL"363b51"
	back.anchorX=1
	back:toBack( )
	-- print("xx",y)
	-- back.alpha = 0
	
	local left = back.x - back.width
	local label = display.newText(paramText.group, paramText.text..":", left+20, y, paramText.font, paramText.fontSize)
	label:setFillColor(unpack(q.CL"dddddd"))
	label.anchorX=0

	local white = display.newRect(paramText.group, (100+60/2)-50, y+5, 10, back.height+30+5)
	white.fill = q.CL"DDDDDD"
	white.anchorY=1

	local white2 = display.newRect(paramText.group, 130-50, y, 60/2, 10)
	white2.fill = q.CL"DDDDDD"
	white2.anchorX=0

	local Field = native.newTextField(-200, -200, 100, 110)
	paramText.group:insert(Field)
	Field.x, Field.y = label.x+label.width+20, label.y
	Field.anchorX = 0
	Field.width = q.fullw-(Field.x+100/2)

	Field.hasBackground = false
	Field.font = native.newFont( "mp_r.ttf",50)
	Field.inputType = "number"
	Field.text = "200"
	Field:resizeHeightToFitFont()
	Field:setTextColor(unpack(q.CL"dddddd"))

	return Field
end

local function createSwitcher(x,y,switch,paramText)
	local w, h = getTextSize(paramText.font, paramText.fontSize)
	local back = display.newRect(paramText.group, q.fullw-50, y, q.fullw-100-60, h+40)
	back.fill = q.CL"363b51"
	back.anchorX=1
	back:toBack( )
	back.text = 1

	local left = back.x - back.width
	local label = display.newText(paramText.group, paramText.text..": "..switch[1][1], left+20, y, paramText.font, paramText.fontSize)
	label:setFillColor(unpack(q.CL"dddddd"))
	label.anchorX=0

	local white = display.newRect(paramText.group, (100+60/2)-50, y+5, 10, back.height+30+5)
	white.fill = q.CL"DDDDDD"
	white.anchorY=1

	local white2 = display.newRect(paramText.group, 130-50, y, 60/2, 10)
	white2.fill = q.CL"DDDDDD"
	white2.anchorX=0

	back:addEventListener( "tap", function()
		back.text = back.text + 1
		if back.text>#switch then back.text=1 end
		label.text = paramText.text..": "..switch[back.text][1]

	end )

	return back, label
end

local showOldText
local function colorPreviewer(self, event)

  if(event.phase == "began" ) then
  	self.startText = self.text -- ИСХОДНЫЙ ТЕКСТ КАК ЗАПЛАТКА
  elseif(event.phase == "editing" ) then
    local text = event.newCharacters
    local old = event.oldText
    local new = event.newCharacters
  	-- self.text = self.text:upper() --СДЕЛАТЬ ВСЕ БУКВЫ ЗАГЛАВНЫЕ
		if #new>6 then --ПРОВЕРЯЕМ НЕ СЛИШКОМ ЛИ МНОГО БУКВ
   			-- showOldText.text = old.."\n"..new.."\ntoo big"
	    	self.text = old
    elseif #old<#new then --ПРОВЕРЯМ ДОБАВИЛИ ЛИ СИМВОЛ
	    local pos, newChar
	    for i=1, #event.newCharacters do -- НАХОДИМ ИЗМЕНИВШИЙСЯ СИМВОЛ
	    	local oldC = old:sub(i,i)
	    	local newC = new:sub(i,i)
	    	if oldC~=newC then
	    		pos = i
	    		newChar = newC
	    		break
	    	end
	    end
   		-- showOldText.text = old.."\n"..new.."\n"..newChar.."\n"..(newChar:find("%x") and "true" or "false")

		  if not newChar:find("%x") then --ПРОВЕРЯЕМ РАЗРЕШЕННЫЙ ЛИ СИВМОВЛ
	    	-- timer.performWithDelay( 1, function() self.text = old end)
	    	self.text = old
		  end
	  end
	  -- timer.performWithDelay( 2, function() 
	  if #self.text==6 and self.text:find("%x") then -- ЕСЛИ ВСЕ 6симв. ОКРАСТИВАТЬ КВАДРАТ
  		self.startText = self.text -- ОБНОВИТЬ ЗАПЛАТКУ
		  self.colorPoint.fill = q.CL(self.text)
		end
  	-- end)

  elseif(event.phase == "ended" ) then
  	if #self.text~=6 then -- ЕСЛИ НЕ ХВАТАЕТ СИМВ. ТО ВСТАВИТЬ ЗАПЛАТКУ, ОКРАСИТЬ КВАДРАТ
  		self.text = self.startText
		  self.colorPoint.fill = q.CL(self.text)
  	end
  end
end
local function createColorSelecter(x,y,paramText)
	local w, h = getTextSize(paramText.font, paramText.fontSize)
	local back = display.newRect(paramText.group, q.fullw-50, y, q.fullw-100-60, h+40)
	back.fill = q.CL"363b51"
	back.anchorX=1
	back:toBack( )
	
	local left = back.x - back.width
	local label = display.newText(paramText.group, paramText.text..":", left+20, y, paramText.font, paramText.fontSize)
	label:setFillColor(unpack(q.CL"dddddd"))
	label.anchorX=0

	local white = display.newRect(paramText.group, (100+60/2)-50, y+5, 10, back.height+30+5)
	white.fill = q.CL"DDDDDD"
	white.anchorY=1

	local white2 = display.newRect(paramText.group, 130-50, y, 60/2, 10)
	white2.fill = q.CL"DDDDDD"
	white2.anchorX=0

	local colorPoint = display.newRect( paramText.group, back.x-15, back.y, back.height-30, back.height-30 )
	colorPoint.anchorX = 1

	local Field = native.newTextField(-200, -200, 100, 110)
	paramText.group:insert(Field)
	Field.anchorX = 0
	Field.x, Field.y = label.x+label.width+20, label.y
	-- Field.y =  + 6
	Field.width = q.fullw-(Field.x+100/2) - 30 - colorPoint.width

	Field.hasBackground = false
	Field.font = native.newFont( "mp_r.ttf",45)

	Field.text = "FFFFFF"
	Field:resizeHeightToFitFont()
	Field:setTextColor(unpack(q.CL"dddddd"))
   
	Field.colorPoint = colorPoint

  Field.userInput = colorPreviewer
  Field:addEventListener( "userInput" )

	return Field
end

local options = {} -- СПИСОК ГРУПП, НАЗВАНИЙ, ЗНАЧЕНИЙ И ВСЕГО
local typesData = {} -- СПИСОК НАЗВАНИЙ ПАРАМЕТРОВ И ИХ ТИПОВ
local listGroups = {} -- НАЗВАНИЯ ГРУПП

local a = display.newGroup()
local sizeInfo, trash = createButton(-q.fullw,-q.fullh,{
	group = a,
	text="A",
	font="mp_r.ttf",
	fontSize=50,
	textColor={0,.7,0},
})
local heightBlock = sizeInfo.height
local spaceBlock = 25
local plusSpace = heightBlock+spaceBlock
display.remove(sizeInfo)
display.remove(trash)
display.remove(a)

local function createAllInGroup(groupName, y, mas)
	print("create",groupName,options[groupName])

	local thisGroupHeight = #mas*plusSpace

	local container = display.newContainer(q.fullw*2, thisGroupHeight+50)
	mainGroup:insert( container )

	container.anchorY = 0
	container:translate( 0, y )

	-- local a = display.newRect( container, q.cx, 0, 40, 1000000 )
	-- a.fill = {0,1,1}
	-- local a = display.newRect( container, 0, 0, 40, 40 )
	-- a.fill = {1,0,0}

	container:toBack()

	local group = display.newGroup()
	container:insert( group )

	options[groupName].group = group
	options[groupName].height = thisGroupHeight
	-- group.y = - 200

	options[groupName].options = {}
	for i=1, #mas do
		options[groupName].options[i] = {name = mas[i].name}
		-- print("")
		if mas[i].switch then
			local field, label = createSwitcher( q.cx, 120*i-thisGroupHeight*.5-25, mas[i].switch, 
			{
				group = group,
				text=mas[i].text,
				font="mp_r.ttf",
				fontSize=50,
				textColor={0,.7,0},
			} )
			options[groupName].options[i].field = field
			options[groupName].options[i].label = label
			typesData[groupName][mas[i].name] = mas[i].switch
			typesData[groupName][mas[i].name].pre = mas[i].text
		elseif mas[i].color then
			local field = createColorSelecter( q.cx, 120*i-thisGroupHeight*.5-25, -- сумашествие с Y для работы с контейнерами
			{
				group = group,
				text=mas[i].text,
				font="mp_r.ttf",
				fontSize=50,
				textColor={0,.7,0},
			} )
			options[groupName].options[i].field = field
			typesData[groupName][mas[i].name] = "color"
		else
			local field = createField( q.cx, 120*i-thisGroupHeight*.5-25, -- сумашествие с Y для работы с контейнерами
			{
				group = group,
				text=mas[i].text,
				font="mp_r.ttf",
				fontSize=50,
				textColor={0,.7,0},
			} )
			options[groupName].options[i].field = field
			typesData[groupName][mas[i].name] = "field"
		end
	end
	return container
end

local function fieldToText(field)
	local label = display.newText({
		text = field.text,
		x = field.x,
		y = field.y,
		font = field.font,
		fontSize = field.fontSize,
	})
	label.anchorX = field.anchorX
	label.anchorY = field.anchorY
	return label
end
local function groupFieldToText(groupName)
	local mas = options[groupName]
	for i=1, #mas.options do
		local field = mas.options[i].field
		if field.inputType then
			local label = fieldToText(field)
			mas.options[i].templabel = label
			label:setFillColor( unpack(q.CL"dddddd") )
			field.parent:insert( label )
			field.x = q.fullw*2
		end
	end
end

local function groupTextToLabel(groupName)
	local mas = options[groupName]
	for i=1, #mas.options do
		local field = mas.options[i].field
		local label = mas.options[i].templabel 
		if label then
			field.x = label.x
			display.remove(label)
		end
	end
end

local scrollView
local scrHeightAll = 0
local scrHeight = 0

local function hideGroup(e)
	if e.target.onGoing==true then return end
	e.target.onGoing = true
	timer.performWithDelay(1000, function()
		e.target.onGoing=false
	end)

	if e.target.openned then
		e.target.openned = false
		local minus = -options[e.target.groupName].height
		scrHeight = scrHeight + minus

		groupFieldToText(e.target.groupName)
		
		local group = options[e.target.groupName].group
		transition.to(group, {y=group.y+minus,time=1000})
		
		local j = 1
		for i=1, #listGroups do
			if listGroups[i]==e.target.groupName then
				j = i + 1
			end 
		end

		for i=j, #listGroups do
			local group = options[listGroups[i]].allGroup
			transition.to(group, {y=group.y+minus,time=1000})
		end
		transition.to(afterGroup, {y=afterGroup.y+minus,time=1000})
		
	else
		e.target.openned = true
		
		local plus = options[e.target.groupName].height
		scrHeight = scrHeight + plus

		local group = options[e.target.groupName].group
		transition.to(group, {y=group.y+plus,time=1000,
		onComplete = function()
			groupTextToLabel(e.target.groupName)
		end})

		local j = 1
		for i=1, #listGroups do
			if listGroups[i]==e.target.groupName then
				j = i + 1
			end
		end
		
		for i=j, #listGroups do
			local group = options[listGroups[i]].allGroup
			transition.to(group, {y=group.y+plus,time=1000})
		end
		transition.to(afterGroup, {y=afterGroup.y+plus,time=1000})
	end

	scrollView:setScrollHeight( scrHeight )
	
	local x, y = scrollView:getContentPosition()
	if -y+q.fullh>scrHeight then
		local toY = -scrHeight+q.fullh
		if toY>0 then toY = 0 end
		scrollView:scrollToPosition({y=toY,time=1000})
	end

end 

local function createGroup(num, text, groupName, optionsGroup)
	options[groupName] = {}
	typesData[groupName] = {}
	listGroups[#listGroups+1] = groupName
	local allGroup = display.newGroup()
	scrollGroup:insert(allGroup)

	local Header = createButton( q.cx, 160+plusSpace*num, 
	{
		group = allGroup,
		text=text,
		font="mp_r.ttf",
		fontSize=50,
		textColor={0,.7,0},
	} )
	Header.groupName = groupName
	Header.openned = true
	Header:addEventListener( "tap", hideGroup )

	local elements = createAllInGroup(groupName,Header.y,optionsGroup)
	allGroup:insert(elements)
	elements:toBack()

	options[groupName].allGroup = allGroup
end

local warning, blockSize, sunSize
local function showWarning(text,i)
	warning.text = text
	transition.to( warning, {alpha=1, time=200} )
	labels[i]:setTextColor(1)
	
	timer.performWithDelay( 1500, function()
		transition.to( warning, {alpha=0, time=700} )
		labels[i]:setTextColor(0,.7,0)
	end )
end

local function getAllParams()
	local totalOptions = {}
	for i=1, #listGroups do
		totalOptions[listGroups[i]] = {}
		local myGroup = totalOptions[listGroups[i]]
		local thisOptions = options[listGroups[i]].options
		for i=1, #thisOptions do
			myGroup[thisOptions[i].name] = thisOptions[i].field.text
		end
	end
	return totalOptions
end
local function AllParamsToUI(totalOptions)
	for groupName, v in pairs(totalOptions) do
		for name, v in pairs(totalOptions[groupName]) do
			local thisOption
			for i=1, #options[groupName].options do
				if options[groupName].options[i].name == name then
					thisOption = options[groupName].options[i]
					break
				end
			end
			if type(typesData[groupName][name])=="table" then -- switch
				thisOption.label.text = typesData[groupName][name].pre..": "..typesData[groupName][name][tonumber(v)][1]
				thisOption.field.text = v
			elseif typesData[groupName][name]=="field" then
				thisOption.field.text = v
			elseif typesData[groupName][name]=="color" then
				thisOption.field.text = v
				thisOption.field.colorPoint.fill = q.CL(v)
			end
		end
	end
end

function scene:create( event )
	composer.setVariable( "skip", "200")

	local sceneGroup = self.view

	backGroup = display.newGroup()
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)

	scrollView = widget.newScrollView(
    {
      top = 0,
      left = 0,
      width = q.fullw,
      height = q.fullh,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      hideBackground = true,
      listener = scrollListener,
    }
	)
	mainGroup:insert( scrollView )


	scrollGroup = display.newGroup()
	scrollView:insert( scrollGroup )

	afterGroup = display.newGroup()
	scrollGroup:insert(afterGroup)

	-- local a = display.newRect( afterGroup, q.cx,0, 1000, 50)
 	-- scrollGroup.y =  -120
	-- scrollGroup.y = -100

	uiGroup = display.newGroup()
	sceneGroup:insert(uiGroup)

	local backGround = display.newRect( backGroup, q.cx, q.cy, q.fullw, q.fullh)
	backGround.fill = q.CL"282836"

	local label = display.newText( {
		parent = scrollGroup,
		text = "СОЗДАНИЕ МИРА",
		x = q.cx, 
		y = 30,
		font = "mp_r.ttf",
		fontSize = 50, 
		})
	label.anchorY=0

	local _, labelPreset = createButton( q.cx, 160, 
	{
		group = scrollGroup,
		text="ПРЕСЕТ: СТАНДАРТ ВОДОЁМ",
		font="mp_r.ttf",
		fontSize=50,
		textColor={0,.7,0},
	} )

	local _, typeLabel = createButton( q.cx, 160+plusSpace, 
	{
		group = scrollGroup,
		text="ТИП МИРА: ВОДОЁМ",
		font="mp_r.ttf",
		fontSize=50,
		textColor={0,.7,0},
	} )

	createGroup(2, "МИР", "world", {
		{text="НАЗВАНИЕ",name="name"},
		{text="ШИРИНА",name="width"},
		{text="ВЫСОТА",name="height"},
		-- {text="ЛЕТО/ЗИМА",switch={
		-- 	{"НЕТ",false},
		-- 	{"ДА",true},
		-- },name="winter"},
		{text="МИН. СОЛНЦА",name="minsun"},
		{text="МАКС. СОЛНЦА",name="maxsun"},
		-- {text="МАКС. СОЛН ЗИМОЙ",name="maxsunwinter"},
		{text="ОТСТУП МИНЕРАЛОВ",name="mineralspace"},
		{text="ЭН. ЗА МИНИРАЛ",name="mineralenergy"},
		{text="СТЕНЫ",switch={
			{"НЕТ",1},
			{"ПО БОКАМ",2},
			{"СВЕРХУ+СНИЗУ",3},
			{"ВЕЗДЕ",4},
		},name="wallstype"},
	})

	createGroup(11, "БОТЫ", "bots", {
		{text="СТАРТ. ЭНЕРГИЯ",name="startenergy"},
		{text="МАКС. ЭНЕРГИЯ",name="maxenergy"},
		{text="ЭНЕРГИЯ В ТРУПЕ",name="diedenergy"},
		{text="ЦЕНА ЖИЗНИ",name="livecost"},
		{text="ЦЕНА ДВИЖЕНИЯ",name="movecost"},
		{text="ХП",name="hp"},
		{text="УРОН ПО БОТАМ",name="dmg"},
		{text="УРОН ЗА ТЕЛЕПОРТ",name="teleportdmg"},
		{text="ДЛИТ. ЖИЗНИ",name="maxlive"},
	})

	createGroup(21, "ЦВЕТА (HEX)", "colors", {
		{text="ЗАДНИЙ ФОН",color=true,name="backgroundcolor"},
		{text="СТЕНЫ",color=true,name="wallscolor"},
		{text="СОЛНЦЕ",color=true,name="suncolor"},
		{text="МИНЕРАЛЫ",color=true,name="mineralcolor"},
		{text="ГРАНИЦЫ",color=true,name="outlinecolor"},
		{text="ОСТАНТКИ",color=true,name="diedcolor"},
 	})

	options.world.options[1].field.inputType="default"
	options.world.options[1].field.text="НОВЫЙ МИР"

 	afterGroup.y = 160 + plusSpace*28 + 30
 	-- afterGroup.y = 160 + plusSpace*5 + 30

	local label = display.newText(afterGroup, "СОЗДАТЬ МИР", q.cx, 0, "mp_r.ttf", 50)
	label:setFillColor(unpack(q.CL"dddddd"))

	local backToPlay = display.newRect(afterGroup, q.fullw-50, 0, q.fullw-100 - 30, label.height+40 + 20)
	backToPlay.width = (backToPlay.width)*.8-30
	backToPlay.anchorX = 1
	backToPlay.fill = q.CL"5f5faf"
	backToPlay:toBack( )

	label.x = backToPlay.x - backToPlay.width*.5


	local backToMenu = display.newRect(afterGroup, 50, 0, q.fullw-100 - 30, label.height+40 + 20)
	backToMenu.width = q.fullw-(backToPlay.width+50+50) - 30
	backToMenu.anchorX = 0
	backToMenu.fill = q.CL"9a5671"

	local plusIcon = display.newImageRect( afterGroup, "images/plus.png", 80, 80)
	plusIcon.x, plusIcon.y = backToMenu.x + backToMenu.width*.5, backToMenu.y
	plusIcon.rotation = 45


	scrHeight = scrollGroup.height+50
	scrollView:setScrollHeight(scrHeight)
	scrHeightAll = scrHeight

	local mas = q.loadPresets()
	-- mas.world.width = "30"
	-- mas.colors.backgroundcolor = "AA2200"
	labelPreset.text = "ПРЕСЕТ: "..mas[1].dopInfo.name
	if mas[1].dopInfo=="sea" then
		typeLabel = "ТИП МИРА: ВОДОЁМ"
	else
		typeLabel = "ТИП МИРА: ЗОНЫ"
	end
	
	mas[1].dopInfo = nil
	print(q.printTable( mas[1] ) )
	AllParamsToUI(mas[1])

	backToPlay:addEventListener( "tap", function()
		
		local d = os.date("*t", os.time())
		
		local world = getAllParams()
		world.dopInfo = {
			i = 0,
      name = "test1",
      type = "sea",
      createDate={day={d.day,d.month,d.year}, time={d.sec,d.min,d.hour}},
      comm = "Первый мир для теста",
		}
		world.date = world.createDate 

		composer.setVariable( "loadedWolrd", world)
		composer.gotoScene( "game" )
		composer.removeScene( "create" )
	end )
	
	backToMenu:addEventListener( "tap", function()
		composer.gotoScene( "menu" )
		composer.removeScene( "create" )
	end )
		
	-- local back = display.newRect( uiGroup, q.cx, 200, q.fullw, 100 )
	-- back.fill = {0}
	-- back.alpha = .7
	-- showOldText = display.newText(uiGroup, "AAAAAAA", q.cx,200, "mp_r.ttf", 60)
	-- showOldText:setFillColor( 1,.3,.3 )
end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then

	elseif ( phase == "did" ) then

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

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
