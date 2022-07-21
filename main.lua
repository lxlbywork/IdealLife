local isDevice = (system.getInfo("environment") == "device")
-- local q = require"base"
-- q.debag()

local start = function()
	local composer = require( "composer" )
	display.setStatusBar( display.HiddenStatusBar )
	math.randomseed( os.time() )
	-- composer.gotoScene( "menu" )
	composer.gotoScene( "menu" )
end

if isDevice then start()
else
	timer.performWithDelay( 300, start )
end

