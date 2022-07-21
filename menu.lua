local widget = require( "widget" )
local composer = require( "composer" )

local scene = composer.newScene()

local backGroup, mainGroup, scrollView

local q = require"base"
q.checkBots()

local world
local function loadWorld(event)
	local world = world[event.target.i]
	print("loading world#"..event.target.i)
	print("population",world.dopInfo.population)
	world.dopInfo.i = event.target.i
	composer.setVariable( "loadedWolrd", world )
	composer.gotoScene( "game" )
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
      top = 120,
      left = 0,
      width = q.fullw,
      height = q.fullh-170-120,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      hideBackground = true,
      listener = scrollListener,
    }
	)
	mainGroup:insert( scrollView )

	scrollGroup = display.newGroup()
	scrollView:insert(scrollGroup)

	local backGround = display.newRect( backGroup, q.cx, q.cy, q.fullw, q.fullh)
	backGround.fill = q.CL"282836"

	local label = display.newText( {
		parent = mainGroup,
		text = "СОХРАННЁНЫЕ МИРЫ",
		x = q.cx, 
		y = 30,
		font = "mp_r.ttf",
		fontSize = 50, 
	})
	label.anchorY=0



	world = q.loadWorlds()
	world = world.worlds
	print(world,"hui")
	for i=1, #world do
		local back = display.newRect(scrollGroup, q.cx, 0+(i-1)*400, q.fullw-100, 350)
		back.anchorY = 0
		back.fill = q.CL"363b51"
		back.i = i
		back:addEventListener( "tap", loadWorld )
		
		local x = back.x - back.width*.5
		local w = back.height - x*2 - 40
		local preView = display.newImageRect(scrollGroup,"world"..tostring(i)..".png", system.DocumentsDirectory, w, w )
		preView.x, preView.y = x*2, back.y+back.height*.5 + 25
		preView.anchorX = 0

		local nameWorld = display.newText(scrollGroup, world[i].world.name, preView.x+preView.width*.5, preView.y-preView.width*.5 - 18, "mp_r.ttf", 40 )
		nameWorld.anchorY = 1

		-- local a = display.newRect( scrollGroup, nameWorld.x, nameWorld.y, w+30, 10 )
		if nameWorld.width>w+30 then 
			local a = nameWorld.width
			local i = 1
			while a>w+30 do
				a = a*.9
				i = i*.9
			end
			nameWorld.xScale=i 
		end

		local infoLabel = display.newText( {
			parent = scrollGroup,
			text = "Популяция: "..world[i].dopInfo.population.."\nДней: "..world[i].dopInfo.step,
			x = x*2+w+40, 
			y = back.y+20,
			font = "mp_r.ttf",
			fontSize = 38, 
			align = "left", 
		})
		infoLabel.anchorX=0 
		infoLabel.anchorY=0 

		local microInfo = display.newText( {
			parent = scrollGroup,
			text = "Тип мира: "..(world[i].dopInfo.type=="sea" and "водоём" or "зоны").."\nСохраннёные виды: ",
			x = x*2+w+40, 
			y = infoLabel.y+infoLabel.height+20,
			font = "mp_r.ttf",
			fontSize = 32, 
			align = "left", 
		})
		microInfo.anchorX=0 
		microInfo.anchorY=0 
	end
	scrollView:setScrollHeight( scrollGroup.height )

	-- if world then
	-- 	world.i = 1
	-- 	label:setFillColor( 0,.7,0 )
	-- 	loadGame:addEventListener( "tap", 
	-- 	function() 
	-- 		composer.setVariable( "loadedWolrd", world)
	-- 		composer.gotoScene( "game" )
	-- 	end )
	-- end



	local createWorld = display.newRect( mainGroup, q.cx, q.fullh-25, 350, 120)
	createWorld.fill = q.CL"5f5faf"
	createWorld.anchorY = 1

	local plusIcon = display.newImageRect( mainGroup, "images/plus.png", 80, 80)
	plusIcon.x, plusIcon.y = q.cx, createWorld.y-createWorld.height*.5

	createWorld:addEventListener( "tap", 
	function()
		composer.gotoScene("create")
	end )	
end


local isDevice = (system.getInfo("environment") == "device")
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
