
----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------
MOAISim.openWindow ( "test", 640, 960 )




screenWidthX = 640--MOAIEnvironment.screenWidth
screenWidthY = 960--MOAIEnvironment.screenHeight
viewport = MOAIViewport.new ()
viewport:setSize ( screenWidthX, screenWidthY )
viewport:setScale ( 640, 960 )

layer = MOAILayer2D.new ()
GUIlayer = MOAILayer2D.new ()
MOAISim.pushRenderPass ( layer )

layer:setViewport ( viewport )
GUIlayer:setViewport (viewport)



gfxQuad = MOAIGfxQuad2D.new ()
gfxQuad:setTexture ( "moai.png" )
gfxQuad:setRect ( -64, -64, 64, 64 )





--font stuff

charcodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'


font = MOAIFont.new ()
font:loadFromTTF ( 'arial-rounded.TTF', charcodes, 7.5, 163 )



-- This makes the touch input on the iphone register as clicks. This DOES not allow for multi touch.


--var

play = 1
ebatspeed = 10
mouseX=0
textbox1 = nil
gravity = 0
impulse = -200
score = 0
maxVelocityBall = 10

function pointerCallback ( x, y )
	
	local oldX = mouseX
	local oldY = mouseY
	
	mouseX, mouseY = layer:wndToWorld ( x, y )
	
	if pick then
		pick:addLoc ( mouseX - oldX, mouseY - oldY )
	end
end


function clickCallback (down)

	if down  then

	StartGame()

	end
end
		

if MOAIInputMgr.device.pointer then
	
	-- mouse input
	MOAIInputMgr.device.pointer:setCallback ( pointerCallback )
	MOAIInputMgr.device.mouseLeft:setCallback ( clickCallback )
else

	-- touch input
	MOAIInputMgr.device.touch:setCallback ( 
	
		function ( eventType, idx, x, y, tapCount )

			pointerCallback ( x, y )		

			if eventType == MOAITouchSensor.TOUCH_DOWN then
				clickCallback (true)
			elseif eventType == MOAITouchSensor.TOUCH_UP then
				clickCallback (false)
			end
		end
	)
end



--collision handler

function onCollide (event, fixtureA, fixtureB, arbiter)

	if event == MOAIBox2DArbiter.BEGIN then
	end

	if event == MOAIBox2DArbiter.END then
		print( fixtureA.userdata.."collided with " .. fixtureB.userdata)
		if fixtureA.userdata and fixtureB.userdata then
			if fixtureA.userdata==-1 and fixtureB.userdata>3 then

				--world:setGravity ( 0, gravity)
				Ball:applyLinearImpulse (0, impulse)

			end
			if fixtureA.userdata==-1 and fixtureB.userdata>4 then

				--world:setGravity ( 0, gravity)
				Ball:applyLinearImpulse (0, impulse * -1)

			end
		end
	end

	if event == MOAIBox2DArbiter.PRE_SOLVE then
	end

	if event == MOAIBox2DArbiter.POST_SOLVE then
	end
end

function MakeButton (x, y, x2, y2, xloc, yloc, text2)
	buttonGFX = MOAIGfxQuad2D.new()
	buttonGFX:setRect (x,y,x2,y2)
	buttonGFX:setTexture ("button.png")
	button = MOAIProp2D.new()
	button:setDeck (buttonGFX)
	button:setLoc (xloc,yloc)
	layer:insertProp (button)
	buttontext = addTextbox ( 0, 200, MOAITextBox.CENTER_JUSTIFY, true, 'replay?' )
	userdata = 6
	return button
end


function addTextbox ( top, height, alignment, yflip, textinput)

	textbox = MOAITextBox.new ()
	textbox:setString ( textinput )
	textbox:setFont ( font )
	textbox:setTextSize ( 12, 326 )
	textbox:setRect ( -280, top - height, 280, top )
	textbox:setAlignment ( alignment )
	textbox:setYFlip ( true )
	layer:insertProp ( textbox )
	return textbox
end

scoretext = addTextbox ( 450, 450, MOAITextBox.LEFT_JUSTIFY, true, tostring(score) )

-- set up the world and start its simulation
world = MOAIBox2DWorld.new ()
world:setGravity ( 0, 0 )
world:setUnitsToMeters ( 1/30 )
world:start ()
layer:setBox2DWorld ( world )
--world:setDebugDrawEnabled (0)

--ball setup

function createBall ()
	Ball = world:addBody ( MOAIBox2DBody.DYNAMIC)
	FixtureBall = Ball:addCircle( 0, 0, 20)

	FixtureBall:setDensity ( 0.01 )
	FixtureBall:setFriction ( 0 )
	FixtureBall:setRestitution (1)
	FixtureBall.userdata = -1
	FixtureBall:setFilter ( 0x01) 
	FixtureBall:setCollisionHandler (onCollide, MOAIBox2DArbiter.BEGIN + MOAIBox2DArbiter.END , 0x01)
	--initial ball velocity
	Ball:applyLinearImpulse (200, 200)
	Ball:setAngularVelocity (200)
end

createBall ()
--side walls setup

leftwall = world:addBody (MOAIBox2DBody.STATIC)
FixtureLeftWall = leftwall:addRect ( -315, 480, -330, -480 )
FixtureLeftWall.userdata = 0
FixtureLeftWall:setFriction ( 0 )

rightwall = world:addBody (MOAIBox2DBody.STATIC)
FixtureRightWall = rightwall:addRect ( 315, 480, 330, -480 )
FixtureRightWall.userdata = 0
FixtureRightWall:setFriction ( 0 )

--player bat setup
Pbat = world:addBody ( MOAIBox2DBody.KINEMATIC)
FixBat = Pbat:addRect( -60, 35, 60,-35)

FixBatcircleleft = Pbat:addCircle(-60,0,35)
FixBatcircleRight = Pbat:addCircle(60,0,35)
FixBat.userdata = 3
FixBat:setFriction ( 0 )
FixBatcircleleft.userdata = 3
FixBatcircleleft:setFriction ( 0 )
FixBatcircleRight.userdata = 3
FixBatcircleRight:setFriction ( 0 )
Pbat:setTransform ( 0, -435)
--enemy bat
EBat = world:addBody (MOAIBox2DBody.KINEMATIC)
FixEBat = EBat:addRect( -60, 35, 60,-35)

FixEBat.userdata = 4
FixEBat:setFriction ( 0 )
FixEBatcircleleft = EBat:addCircle(-60,0,35)
FixEBatcircleRight = EBat:addCircle(60,0,35)
FixEBatcircleleft.userdata = 3
FixEBatcircleleft:setFriction ( 0 )
FixEBatcircleRight.userdata = 3
FixEBatcircleRight:setFriction ( 0 )
EBat:setTransform ( 0, 435)

function StartGame ()
	--play = 1
	world:start()
	layer:removeProp (button)
	layer:removeProp (textboxg)
	layer:removeProp (buttontext)
end

function GameOver ( top, height, alignment )

	textboxg = MOAITextBox.new ()
	textboxg:setString ( 'GAME OVER' )
	textboxg:setFont ( font )
	textboxg:setTextSize ( 12, 326 )
	textboxg:setRect ( -100, top - height, 100, top )
	textboxg:setAlignment ( alignment )
	textboxg:setYFlip ( true )
	layer:insertProp ( textboxg )
	replaybut = MakeButton (-100, -100, 100, 100, 0, 0, 'yep')
end


--game loop
function main ()

	while play == 1 do
		coroutine.yield()
		scoretext:setString ( tostring(score) )


 		ballx,bally = Ball:getPosition ()
 		EBatx,EBaty = EBat:getPosition ()
 		PBatx,PBaty = Pbat:getPosition ()

 		ebatspeed = ballx - EBatx
 		pbatspeed =   mouseX - PBatx
    

 		--DIFFICULTY
 		if score > 0 or score == 0 then
 			difficulty = 1 + score * 2
 		elseif score < -1 then
 			difficulty = 1
 		end

		 EBat:setLinearVelocity(ebatspeed * difficulty ,0)

		 Pbat:setLinearVelocity(pbatspeed * 20 ,0)

		 --reset ball



 		if bally <-460 then
	 		score = score -1
 			Ball:destroy ()
			createBall ()
	 	end
 		if bally >460 then
 			score = score +1
 			Ball:destroy ()
			createBall ()
 		end





		if score > 4 or score <-4 then 
			score = 0
			--play = 0
			world:stop ()
			Pbat:setTransform (0,0)
			EBat:setTransform (0,0)
			GameOver ( 100, 100, MOAITextBox.CENTER_JUSTIFY , true)

		end
 	end
end

bally = 0
ballx = 0

--Begin the game loop
thread = MOAICoroutine.new()
thread:run( main )






