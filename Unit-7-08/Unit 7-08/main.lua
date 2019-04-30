-----------------------------------------------------------------------------------------
--
-- Created by: Matsuru Hoshi
-- Created on: Apr 24, 2016
--
-- This file contains a game.
-----------------------------------------------------------------------------------------

local physics = require( "physics")

physics.start()
physics.setGravity( 0, 2)
--physics.setDrawMode("hybrid")

local playerBullets = {} -- Table that holds the players Bullets

local background = display.setDefault( "background", 222/255, 100/255, 205/255)

local music = audio.loadSound( "Bomberman.mp3")

--audio.play( music )

local ground = display.newRect( display.contentCenterX, 555, 500, 60)
ground.id = "ground"
physics.addBody( ground, "static", {
	friction = 0.1,
	bounce = 0.3
	})

local leftWall = display.newRect( -50, display.contentCenterY, 100, 560)
leftWall.id = "left wall"
physics.addBody( leftWall, "static", {
	friction = 0.5,
	bounce = 0.1
	})

local rightWall = display.newRect( 390, display.contentCenterY, 100, 560)
rightWall.id = "rightleft wall"
physics.addBody( rightWall, "static", {
	friction = 0.5,
	bounce = 0.1
	})

local startButton = display.newRoundedRect( display.contentCenterX, 200, 200, 60, 30) 

local startText = display.newText( "Start", display.contentCenterX, 200, "Phosphate", 50)
startText:setFillColor( 161/255, 209/255, 177/255)
startText.align = "center"

local instructBox = display.newRoundedRect( display.contentCenterX, 380, 220, 190, 30)
instructBox:setFillColor( 1, 1, 1)

local instructText = [[Drag your ball from left to right to avoid obstacles]]

local options = {
	text = instructText,
	x = display.contentCenterX,
	y = 380,
	width = 180,
	height = 100,
	font = "Phosphate",
	fontSize = 20,
	align = "center"
}

local instructTextOut = display.newText( options )
instructTextOut:setFillColor( 161/255, 209/255, 177/255)

local function createBall()
	local function gameOver()
		local blank = display.newRect( 
			display.contentCenterX, display.contentCenterY,
			display.actualContentWidth, display.actualContentHeight)
		blank:setFillColor( 119/255, 26/255, 26/255)

		local gameOverText = display.newText( "Game Over!", display.contentCenterX, display.contentCenterY, "Phosphate", 50)
		gameOverText:setFillColor( 0, 0, 0)
	end

	local function whiteBallCollision(self, event)
		if ( event.phase == "began" ) then
			if (event.other.id == "ground" or event.other.id == "bullet") then
				display.remove(self)
			elseif (event.other.id == "player") then
				gameOver()
			end
			print("Whiteball is "..self.y.." with "..event.other.id)
		end
	end

	local x = math.random(100, display.contentWidth)
	local y = math.random(-5000, -100)
	local ball = display.newCircle( x, y, 37)
	ball.id = "ball"
	ball.collision = whiteBallCollision
	ball:addEventListener( "collision")
	physics.addBody( ball, "dynamic", {
		friction = 0.5,
		bounce = 0.2
	})
end

local function run()

	local playerBall = display.newCircle( display.contentCenterX, 450, 37)
	playerBall:setFillColor( 0, 0, 0)
	playerBall.id = "player"
	physics.addBody( playerBall, "dynamic", {
		friction = 0.5,
		bounce = 0.2
		})

	for i = 0, 20, 1 do
		createBall()
	end

	local rigthShootButton = display.newRoundedRect( 50, 350, 60, 40, 20)

	local leftShootButton = display.newRoundedRect( 265, 350, 60, 40, 20)

	local function playerCollision( self, event )
	 
	    if ( event.phase == "began" ) then
	        print( self.id .. ": collision began with " .. event.other.id )
	 
	    elseif ( event.phase == "ended" ) then
	        print( self.id .. ": collision ended with " .. event.other.id )
	    end
	end 

	local function shootBall()
		local aSingleBullet = display.newCircle( 0, 0, 10 )
		aSingleBullet.x = playerBall.x 
		aSingleBullet.y = playerBall.y
		physics.addBody( aSingleBullet, 'dynamic' )
		-- Make the object a "bullet" type object
    	aSingleBullet.isBullet = true
		aSingleBullet.gravityScale = (-5)
		aSingleBullet.id = "bullet"
		aSingleBullet:setLinearVelocity( 0, 1000 )

		table.insert(playerBullets,aSingleBullet)
		print("# of bullet: " .. tostring(#playerBullets))

		local function bulletCollision(self, event)
			if ( event.phase == "began" ) then
				if (event.other.id == "ball") then
					display.remove(self)
				end
				print("bullet is "..self.y.." with "..event.other.id)
			end
		end

		local function onCollision( event )
 
		    if ( event.phase == "began" ) then
		 
		        local obj1 = event.object1
		        local obj2 = event.object2
		        local whereCollisonOccurredX = obj1.x
		        local whereCollisonOccurredY = obj1.y

		        if ( ( obj1.id == "ball" and obj2.id == "bullet" ) or
		             ( obj1.id == "bullet" and obj2.id == "ball" ) ) then
		            -- Remove both the laser and asteroid
		            --display.remove( obj1 )
		            --display.remove( obj2 )
		 			
		 			-- remove the bullet
		 			local bulletCounter = nil
		 			
		            for bulletCounter = #playerBullets, 1, -1 do
		                if ( playerBullets[bulletCounter] == obj1 or playerBullets[bulletCounter] == obj2 ) then
		                    playerBullets[bulletCounter]:removeSelf()
		                    playerBullets[bulletCounter] = nil
		                    table.remove( playerBullets, bulletCounter )
		                    break
		                end
		            end

		            --remove character
		            display.remove(ball)
		            

		            -- Increase score
		            print ("you could increase a score here.")

		            -- make an explosion sound effect
		            local explosionSound = audio.loadStream( "explosion.wav" )
		            local explosionChannel = audio.play( explosionSound )
		            local explosionImage = display.newImageRect( "assets/fire.png", 200, 200)
		            explosionImage.x = whereCollisonOccurredX
		            explosionImage.y = whereCollisonOccurredY


		        end
		    end
		end

		Runtime:addEventListener( "collision", onCollision )


	end

	function playerBall:touch( event )
		local playerBallTouched = event.target

	    if ( event.phase == "began" ) then
	        print( "Touch event began on: " .. self.id )
	 
	        -- Set touch focus
	        display.getCurrentStage():setFocus( self )
	        self.markX = self.x
	        self.markY = self.y
	        self.isFocus = true
	     
	    elseif ( self.isFocus ) then
	        if ( event.phase == "moved" ) then
	            print( "Moved phase of touch event detected." )
	            self.x = event.x - event.xStart + self.markX

	        elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
	 
	            -- Reset touch focus
	            display.getCurrentStage():setFocus( nil )
	            self.isFocus = nil
	            print( "Touch event ended on: " .. self.id )
	    
	       end
	    end

	    return true
	end

	

	function leftShootButton:touch( event )
	    if ( event.phase == "began" ) then
	        shootBall()
	    end
	end

    function rigthShootButton:touch( event )
	    if ( event.phase == "began" ) then
	        shootBall()
	    end
	end

    function checkPlayerBulletsOutOfBounds()
	-- check if any bullets have gone off the screen
		local bulletCounter

	    if #playerBullets > 0 then
	    	for bulletCounter = #playerBullets, 1 ,-1 do
	        	if playerBullets[bulletCounter].y > display.contentHeight + 100 then
	           		playerBullets[bulletCounter]:removeSelf()
	           	 	playerBullets[bulletCounter] = nil
	           	 	table.remove(playerBullets, bulletCounter)
	             	print("remove bullet")
	          	 end
	      	 end
	  	end
	    return true
	end

	playerBall:addEventListener( "touch", playerBall )
	leftShootButton:addEventListener( "touch", leftShootButton )
	rigthShootButton:addEventListener( "touch", rigthShootButton)
	

end

local function start( event )

	display.remove(startText)
	display.remove(startButton)
	display.remove(instructBox)
	display.remove(instructTextOut)

	print( 'hi')
	run()
end

startButton:addEventListener( "touch", start)
