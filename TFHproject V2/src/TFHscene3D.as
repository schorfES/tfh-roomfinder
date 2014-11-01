package
{
import flash.display.*;
import flash.events.*;
import flash.system.System;
import org.papervision3d.cameras.*;
import org.papervision3d.core.*;
import org.papervision3d.materials.*;
import org.papervision3d.objects.*;
import org.papervision3d.scenes.*;

public class TFHscene3D extends Sprite
{
	var inputHandler		:TFHinputManager;
	
	protected var container :Sprite;
	protected var scene     :InteractiveScene3D;
	protected var camera    :FreeCamera3D;
	
	var houseNames			:Array;
	protected var textNames	:Array;
	protected var grashof	:TFHhouse;
	protected var bauwesen	:TFHhouse;
	protected var beuth		:TFHhouse;
	protected var gauss		:TFHhouse;
	
//	var goneTime	:Number = 0;
	
	var lookAt				:DisplayObject3D;
	var currentTarget		:TFHhouse;
	var targetHouseName		:String;
	var moveFrom			:TFHpoint3D;
	var moveTo				:TFHpoint3D;
	var moveSpan			:Number;
	var shiftCount			:uint = 0;
	
	private var moveDistanceWheel:int = 0;
	private var moveDistanceX:int = 0;
	private var moveDistanceY:int = 0;
	private var lastMouseX 	:int = 0;
	private var lastMouseY 	:int = 0;
	private var lastFocus	:uint = 0;
	
	var controlsActive:Boolean;
	var processing:Boolean;
	var somethingChanged:Boolean;

	function TFHscene3D( handler:TFHinputManager )
	{
		inputHandler = handler;
	}
	
	function initScene()
	{
		container = new Sprite();
		addChild( container );

		container.x = inputHandler.stage.stageHeight*0.85;
		container.y = inputHandler.stage.stageWidth*0.4;
	
		scene  = new InteractiveScene3D( container );
		camera = new FreeCamera3D( 2, 100, null );
		camera.x = 0;
		camera.y = 0;
		camera.z = 0;
		
		houseNames = new Array( "grashof", "bauwesen", "beuth", "gauss");
		textNames = new Array( 	"upNdown_JPG_001",
							   	"frontNback_JPG",
							   	"leftNright_JPG_002" );
		
		var floorsGrashof:Array = new Array( "../Buildings/Grashof/Etagen/etageV1.1No1.dae",
											 "../Buildings/Grashof/Etagen/etageV1.1No2.dae",
											 "../Buildings/Grashof/Etagen/etageV1.1No3.dae",
											 "../Buildings/Grashof/Etagen/etageV1.1No4.dae");
		var floorsBauwesen:Array = new Array(  );
		var floorsBeuth:Array = new Array(  );
		var floorsGauss:Array = new Array(  );
		
		grashof	 = new TFHhouse ( 	houseNames[0], 
							 	"../Buildings/Grashof/grashof1.7.dae", 
							 	floorsGrashof, textNames, 0.1, this );
		bauwesen = new TFHhouse (  houseNames[1],
								"../Buildings/Bauwesen/bauwesen1.7.dae", 
								floorsBauwesen, textNames, 0.1, this );
		beuth	 = new TFHhouse (  houseNames[2],
								"../Buildings/Beuth/beuth1.7.dae", 
								floorsBeuth, textNames,0.1, this );
		gauss = new TFHhouse (  houseNames[3],
								"../Buildings/Gauss/gauss1.7.dae", 
								floorsGauss, textNames, 0.1, this );
		grashof.moveForward(5000);
		bauwesen.moveForward(5000);
		beuth.moveForward(5400);
		gauss.moveForward(5000);
		
		grashof.moveRight(3000);
		bauwesen.moveRight(3500);
		beuth.moveRight(3000);
		gauss.moveRight(3000);
		
		gauss.moveLeft(600); 
		
		grashof.moveDown(3000);
		bauwesen.moveDown(3000);
		beuth.moveDown(3000);
		gauss.moveDown(3000);

		scene.addChild( grashof );
		scene.addChild( bauwesen );
		scene.addChild( beuth );
		scene.addChild( gauss );

		lookAt = new DisplayObject3D();
		moveFrom = new TFHpoint3D( 0,0,0 );
		moveTo = new TFHpoint3D( 0,0,0 );
		scene.addChild( lookAt );

		camera.focus = 1200;
		currentTarget = TFHhouse(scene.getChildByName( "grashof" ));
		camera.lookAt( currentTarget );
		somethingChanged = false;
		
		inputHandler.addEventListener( Event.ENTER_FRAME, loop );

		trace( "=-=-= SceneInited" );
	}
	// 	=========================
	//	======AFTER INIT=========
	// 	=========================
	
	function resetAllHouses() :void
	{
		grashof.resetHouse();
		bauwesen.resetHouse();
		beuth.resetHouse();
		gauss.resetHouse();
	}
	
	function switchToHouse( to:String ) :void
	{
		processing = true;
		targetHouseName = to;
		deactivateControls();
		
		currentTarget.openAtFloor( 20 );
		
		moveFrom.x = currentTarget.x ;
		moveFrom.y = currentTarget.y ;
		moveFrom.z = currentTarget.z ;
		moveTo.x = getHouseByName( to ).x;
		moveTo.y = getHouseByName( to ).y;
		moveTo.z = getHouseByName( to ).z;
		lookAt.x = moveFrom.x;
		lookAt.y = moveFrom.y;
		lookAt.z = moveFrom.z;
		
		moveSpan = 0;
		lastFocus = camera.focus;
		addEventListener( Event.ENTER_FRAME, moveToTarget );
	}

	function moveToTarget( event:Event ) :void
	{
		if( moveSpan >= 1 )
		{
			removeEventListener( Event.ENTER_FRAME, moveToTarget );
			currentTarget = getHouseByName( targetHouseName );
			camera.focus = lastFocus;
			camera.lookAt( currentTarget );
			activateControls();
			processing = false;
			somethingChanged = true;
			inputHandler.dispatchEvent( new Event( "targetReached" ) );
			return;
		}
		lookAt.x = (1-moveSpan) * lookAt.x + moveSpan * moveTo.x;
		lookAt.y = (1-moveSpan) * lookAt.y + moveSpan * moveTo.y;
		lookAt.z = (1-moveSpan) * lookAt.z + moveSpan * moveTo.z;
		
		camera.lookAt( lookAt );
		camera.focus = camera.focus * (1-moveSpan) 
					 - 50 	 		* Math.abs(1-(moveSpan-(1-moveSpan)))
					 + lastFocus 	* (moveSpan);//camera.focus * (2+moveCount) + moveCount * 300;//0.1*lastFocus*moveCount;
		
		moveSpan += 0.05;
		somethingChanged = true;
	}
	
	function pressMouse( event:MouseEvent ) : void
	{
		trace( "firstPosition: "+this.stage.mouseX+", "+this.stage.mouseY )
		inputHandler.hitSceneField.addEventListener( MouseEvent.MOUSE_MOVE, mouseMoving );
		lastMouseY = inputHandler.hitSceneField.mouseY; //this.stage.mouseY;
		lastMouseX = inputHandler.hitSceneField.mouseX; //this.stage.mouseX;
		trace( " !!! "+System.totalMemory );
	}
	
	function releaseMouse( event:MouseEvent ) : void
	{
		trace( "lastPosition: "+this.stage.mouseX+", "+this.stage.mouseY );
		inputHandler.hitSceneField.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoving );
		lastMouseY = inputHandler.hitSceneField.mouseY; //this.stage.mouseY;
		lastMouseX = inputHandler.hitSceneField.mouseX; //this.stage.mouseX;
	}
	
	function mouseMoving( event:MouseEvent ):void 
	{
		moveDistanceX = 7*(inputHandler.hitSceneField.mouseX-lastMouseX);
		moveDistanceY = 7*(inputHandler.hitSceneField.mouseY-lastMouseY);
		lastMouseY = inputHandler.hitSceneField.mouseY;
		lastMouseX = inputHandler.hitSceneField.mouseX;
		moveScene();
		camera.lookAt( currentTarget );
//		inputHandler.myMenu.searchInput.text = "DDDD";
	}
	
	function mouseWheel( event:MouseEvent )
	{
		moveDistanceWheel = camera.focus + 32*event.delta;
		trace ("mouse wheel dist: "+event.delta);
		
		if( moveDistanceWheel < 1000 )
		{
			camera.focus = 1000;
			return;
		}
		else if( moveDistanceWheel > 5000 )
		{
			camera.focus = 5000;
			return;
		}
		camera.focus += 32*event.delta;
		somethingChanged = true;
	}
	
	function moveScene()
	{
		grashof.moveRight( moveDistanceX );
		grashof.moveDown( moveDistanceY );
		bauwesen.moveRight( moveDistanceX );
		bauwesen.moveDown( moveDistanceY );
		beuth.moveRight( moveDistanceX );
		beuth.moveDown( moveDistanceY );
		gauss.moveRight( moveDistanceX );
		gauss.moveDown( moveDistanceY );
		somethingChanged = true;
	}
	
	function activateControls() :void
	{
		inputHandler.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyInputs );
		inputHandler.stage.addEventListener( MouseEvent.MOUSE_UP, releaseMouse );
		inputHandler.stage.addEventListener( MouseEvent.MOUSE_DOWN, pressMouse );
		inputHandler.hitSceneField.addEventListener( MouseEvent.MOUSE_WHEEL, mouseWheel );
		controlsActive = true;
	}
	function deactivateControls() :void
	{
		inputHandler.stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyInputs );
		inputHandler.stage.removeEventListener( MouseEvent.MOUSE_UP, releaseMouse );
		inputHandler.stage.removeEventListener( MouseEvent.MOUSE_DOWN, pressMouse );
		inputHandler.hitSceneField.removeEventListener( MouseEvent.MOUSE_WHEEL, mouseWheel );
		inputHandler.hitSceneField.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMoving );
		controlsActive = false;
	}
	function getHouseByName( name:String ) :TFHhouse
	{
		return TFHhouse(scene.getChildByName( name ));
	}
		
	function keyInputs( event:KeyboardEvent ): void 
	{
		if( event.keyCode == 37 ) // 'arrowLeft'
			currentTarget.moveLeft(100);
		if( event.keyCode == 38 ) // 'arrowUp'
			currentTarget.moveForward(100); 	
		if( event.keyCode == 39 ) // 'arrowRight'
			currentTarget.moveRight(100); 	
		if( event.keyCode == 40 ) // 'arrowDown'
			currentTarget.moveBackward(100);	
			
		if( event.keyCode == 48 ) // '0'
			currentTarget.closeHouse();
		if( event.keyCode == 49 ) // '1'
			currentTarget.openAtFloor( 1 );
		if( event.keyCode == 50 ) // '2'
			currentTarget.openAtFloor( 2 );
		if( event.keyCode == 51 ) // '3'
			currentTarget.openAtFloor( 3 );
		if( event.keyCode == 52 ) // '4'
			currentTarget.openAtFloor( 4 );
		if( event.keyCode == 53 ) // '5'
			currentTarget.openHouse( 1 );
		if( event.keyCode == 54 ) // '6'
			currentTarget.openHouse( 2 );
		if( event.keyCode == 55 ) // '7'
			currentTarget.openHouse( 3 );
		if( event.keyCode == 56 ) // '8'
			currentTarget.openHouse( 4 );
		if( event.keyCode == 57 ) // '8'
			currentTarget.closeHouse(  );
			
		if( event.shiftKey )	  // shift
		{
			switchToHouse( houseNames[(shiftCount+1)%4] );
			shiftCount++;
		}
			
		if( event.keyCode == 32 ){} // space
		if( event.keyCode == 87 ){} // 'W'
		if( event.keyCode == 68 ){} // 'D'
		
		trace("Tastennummer:"+ event.keyCode );
	}
	
	function loop( event:Event ):void 
	{
		if( somethingChanged )
			scene.renderCamera( camera );
		somethingChanged = false;
	}
}
}