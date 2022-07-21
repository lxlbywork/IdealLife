	-- local backRdc = display.newRect( uiGroup, q.cx, q.cy, q.fullw*.8, q.fullw*.8 )
	-- local centerPoint = display.newRect( uiGroup, q.cx, q.cy, 20, 20)
	-- centerPoint.fill={0,0,1}

	-- local selectPoint = display.newRect( uiGroup, q.cx, q.cy, 20, 20)
	-- selectPoint.fill={1,0,0}

	-- local move = {
	-- 	up = display.newRect( uiGroup, q.cx, q.cy+460-100, 80, 80),
	-- 	left = display.newRect( uiGroup, q.cx-100, q.cy+460, 80, 80),
	-- 	down = display.newRect( uiGroup, q.cx, q.cy+460, 80, 80),
	-- 	right = display.newRect( uiGroup, q.cx+100, q.cy+460, 80, 80),
	-- }


	-- local points = {}
	-- local addPoint = display.newRect( uiGroup, q.cx+150, q.cy+460-100, 180, 80)
	-- local createPol = display.newRect( uiGroup, q.cx-150, q.cy+460-100, 180, 80)

	-- move.up:addEventListener( "tap", 
	-- 	function() 
	-- 		selectPoint.y = selectPoint.y-50
	-- 	end
	-- )
	-- move.left:addEventListener( "tap", 
	-- 	function() 
	-- 		selectPoint.x = selectPoint.x-50
	-- 	end
	-- )
	-- move.right:addEventListener( "tap", 
	-- 	function() 
	-- 		selectPoint.x = selectPoint.x+50
	-- 	end
	-- )
	-- move.down:addEventListener( "tap", 
	-- 	function() 
	-- 		selectPoint.y = selectPoint.y+50
	-- 	end
	-- )

	-- addPoint:addEventListener( "tap", 
	-- 	function() 
	-- 		points[#points+1] = math.floor((selectPoint.x-q.cx)/50)
	-- 		points[#points+1] = math.floor((selectPoint.y-q.cy)/50)
	-- 		print(points[#points-1],points[#points])
	-- 		local newPoint = display.newRect( uiGroup, selectPoint.x, selectPoint.y, 20, 20)
	-- 		newPoint.fill={0,0,0}
	-- 	end
	-- )
	-- createPol:addEventListener( "tap", 
	-- 	function()
	-- 		local a = display.newPolygon( uiGroup, q.cx, 200, points )
	-- 		a.xScale=100
	-- 		a.yScale=100
	-- 		a.fill={1,0,0}
	-- 	end
	-- )






-- readMap{ 
-- 	first={1,5},
-- 	{1,2},
-- 	{2,3},
-- 	{3,1},
-- 	{3,2},
-- 	{3,3}
-- }
-- readMap{ 
-- 	first={15,5},
-- 	{1,2},
-- 	{2,3},
-- 	{3,1},
-- 	{3,2},
-- 	{3,3}
-- }
-- readMap{ 
-- 	first={15,15},
-- 	{1,2},
-- 	{2,3},
-- 	{3,1},
-- 	{3,2},
-- 	{3,3}
-- }

-- readMap{ 
-- 	first={2,2},
-- 	{1,2},
-- 	{2,3},
-- 	{3,1},
-- 	{3,2},
-- 	{3,3},
-- }
-- readMap{ 
-- 	first={20,5},
-- 	{2,-2},
-- 	{2,0},
-- 	{3,-2},
-- 	{3,-3},
-- 	{4,-2},
-- 	{4,-3},
-- 	{5,-2},
-- 	{5,0},

-- 	{1,1},
-- 	{1,2},
-- 	{2,1},
-- 	{2,2},

-- 	{5,1},
-- 	{5,2},
-- 	{6,1},
-- 	{6,2},

-- 	{3,1+2},
-- 	{3,2+2},
-- 	{4,1+2},
-- 	{4,2+2},

-- 	{2,4},
-- 	{2,5},
-- 	{2,6},

-- 	{5,4},
-- 	{5,5},
-- 	{5,6},
-- }
-- readMap{ 
-- 	first={49,49},
-- 	inf={{2,-2},
-- 	{2,0},
-- 	{3,-2},
-- 	{3,-3},
-- 	{4,-2},
-- 	{4,-3},
-- 	{5,-2},
-- 	{5,0},

-- 	{1,1},
-- 	{1,2},
-- 	{2,1},
-- 	{2,2},

-- 	{5,1},
-- 	{5,2},
-- 	{6,1},
-- 	{6,2},

-- 	{3,1+2},
-- 	{3,2+2},
-- 	{4,1+2},
-- 	{4,2+2},

-- 	-- {13+5,1+2},
-- 	-- {13+5,2+2},
-- 	-- {14+5,1+2},
-- 	-- {14+5,2+2},

-- 	{10,3},
-- 	{10,4},
-- 	{10,5},
-- 	{10,6},

-- 	{2,4},
-- 	{2,5},
-- 	{2,6},

-- 	{5,4},
-- 	{5,5},
-- 	{5,6}},
-- }

-- readMap{ 
-- 	first={15+9,15},
-- 	{1,2},
-- 	{2,2},
-- 	{1,1},
-- 	{1,3},
-- }
-- readMap{ 
-- 	first={15+10,15},
-- 	{1,2},
-- 	{2,2},
-- 	{1,1},
-- 	{1,3},
-- }
-- readMap{ 
-- 	first={15+9+10,15},
-- 	{1,2},
-- 	{2,2},
-- 	{1,1},
-- 	{1,3},
-- }

-- for i=1, #greed do
-- 	for j=1, #greed[i] do
-- 		if math.random(10)==1 then 
-- 			addCell(i,j)
-- 		end
-- 	end
-- end



--[[0..9 перейти к гену
10 вниз
11 влево
12 вверх
13 вправо
14 ничего
--]]
