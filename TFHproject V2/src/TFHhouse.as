package
{	
import org.papervision3d.scenes.*;
import org.papervision3d.objects.*;
import org.papervision3d.materials.*
import flash.events.*;

class TFHhouse extends DisplayObject3D
{
	var tfhScene:TFHscene3D;
	
	var wholeHouse:Collada;
	var floors:Array;
	var textures:MaterialsList;
	
	var openStepCount:uint;
	var floorsUpCount:uint;
	var houseOpened:Boolean;
	var houseClosed:Boolean;
	var processing:Boolean;
	
	var openPosition:Number;
	var closePosition:Number;
	var motionInterpolator:Number;
	
	var selectedFloor:uint;
	static var pointer:Collada;
	
	public function TFHhouse( name:String, pathWholeHouse:String, pathFloors:Array, 
							  pathTexture:Array, scale:Number, scene:TFHscene3D ) 
	{
		super( name, null, null );
		
		textures = createMaterials( pathTexture );
		wholeHouse = new Collada( pathWholeHouse, textures, scale, this );

		floors = initFloors( pathFloors, scale );
		tfhScene = scene;
		openStepCount = 0;
		houseOpened = false;
		houseClosed = true;
		processing = false;
		openPosition = y+100;
		closePosition = y;
		
		loadOutside();
	}
	
	public function loadInside() : void
	{
		removeChild( wholeHouse );
		for( var i:uint=0; i<floors.length; i++ )
			addChild( floors[i] );
		trace( "inside of "+this.name+" was loaded" );
	}
	
	public function loadOutside() : void
	{
		for( var i:uint=0; i<floors.length; i++ )
			removeChild( floors[i] );
		addChild( wholeHouse );
		trace( "outside of "+this.name+" was loaded" );
	}
	
	public function loadRoom() :void {}
	public function resetAllRooms() :void{}
	public function resetHouse() :void{}
	
	public function openAtFloor( floorNo:uint ) :void
	{
//		if( floorNo > floors.length )
//			return;
		if( processing )
			return;
		processing = true;
//		tfhScene.activateLoop3D();
		selectedFloor = floorNo;
		motionInterpolator = 0;
		loadInside();
		tfhScene.inputHandler.addEventListener( Event.ENTER_FRAME, switchFloors );
	}
	
	function switchFloors( event:Event ) :void
	{
		if( motionInterpolator >= 1 )
		{
			tfhScene.inputHandler.removeEventListener( Event.ENTER_FRAME, switchFloors );
			if( selectedFloor >= floors.length )
				loadOutside();
//			tfhScene.deactivateLoop3D();
			processing = false;
			return;
		}
		for( var i:uint=1; i<=floors.length; i++ )
		{
			if( i <= selectedFloor )
				moveFloorDown( i-1 );
			else
				moveFloorUp( i-1 );
		}
		motionInterpolator += 0.05;
	}
	
	function moveFloorUp( nr:uint ) :void
	{
		floors[nr].y = openPosition * motionInterpolator
					 + floors[nr].y * (1-motionInterpolator) + 2*nr;
		tfhScene.somethingChanged = true;
	}
	function moveFloorDown( nr:uint ) :void
	{
		floors[nr].y = floors[nr].y * (1-motionInterpolator)
					 + closePosition * motionInterpolator;
		tfhScene.somethingChanged = true;
	}
	
	public function openHouse( atFloor:uint ) :void
	{
		if( houseOpened || processing )
			return;
		if( atFloor >= floors.length )
			return;
		houseClosed = false;
		processing = true;
		loadInside();
		tfhScene.inputHandler.removeEventListener( Event.ENTER_FRAME, closeDown );
		selectedFloor = atFloor;
		floorsUpCount = floors.length-selectedFloor+1;
		tfhScene.inputHandler.addEventListener( Event.ENTER_FRAME, openUp );
	}
	private function openUp( event:Event ) :void
	{
		trace( " !! OPEN_UP !!" );
		if( openStepCount == 20 )
		{
			tfhScene.inputHandler.removeEventListener( Event.ENTER_FRAME, openUp );
			houseOpened = true;
			processing = false;
			return;
		}
		for( var i:uint=0; i<floors.length; i++ )
		{
			if( i >= selectedFloor && i >= floorsUpCount )
				floors[i].moveUp(15);
		}
		openStepCount++;
		if( openStepCount%2 == 0 && floorsUpCount > 0 )
			floorsUpCount --;
	}

	public function closeHouse() :void
	{
		if( houseClosed || processing )
			return;
		houseOpened = false;
		processing = true;
		tfhScene.inputHandler.removeEventListener( Event.ENTER_FRAME, openUp );
		floorsUpCount = floors.length-selectedFloor+1;
		tfhScene.inputHandler.addEventListener( Event.ENTER_FRAME, closeDown );
	}
	
	private function closeDown( event:Event ) :void
	{
		if( openStepCount == 0 )
		{
			tfhScene.inputHandler.removeEventListener( Event.ENTER_FRAME, closeDown );
			houseClosed = true;
			processing = false;
			loadOutside();
			return;
		}
		for( var i:uint=0; i<floors.length; i++ )
		{
			if( i >= selectedFloor && i >= floorsUpCount )
				floors[i].moveDown(15);
		}
		openStepCount--;
		if( openStepCount%2 == 0 && floorsUpCount > 0 )
			floorsUpCount --;
	}
	
	public function createMaterials( paths:Array ) :MaterialsList
	{
		var temp:MaterialsList = new MaterialsList(  );
		
		for( var i:uint=0; i < paths.length; i++ )
		{
			trace( "loading Material: "+i );
			temp.addMaterial( new BitmapFileMaterial( paths[i] ) );
		}
			
		return temp;
	}
	
	public function initFloors( names:Array , scale:Number) :Array
	{
		var temp:Collada;
		var floors:Array = new Array( names.length );

		trace( "==========MATERIAL COPING============" );
		for( var i:uint=0; i<names.length; i++ )
		{
			floors[i] = new Collada( ""+names[i], textures, scale, null );
		}
		trace( "==========MATERIAL COPING============" );
		return floors;
	}
}
}