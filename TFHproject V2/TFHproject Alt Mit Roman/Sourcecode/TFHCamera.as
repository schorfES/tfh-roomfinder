package {
	
	import org.papervision3d.cameras.*;
	
	public class TFHCamera extends FreeCamera3D {
		
		private var radius         : Number;
		private var winkelPitch    : Number;
		
		private var winkelOrgYaw   : Number;
		private var winkelOrgPitch : Number;
		private var startPunkt     : TFHPoint3D;
		
		public function TFHCamera(radius: Number) {
			this.focus          = 100;
			this.radius         = radius;
			this.winkelPitch    = 0;
			
			this.winkelOrgYaw   = 0;
			this.winkelOrgPitch = 0;
			this.startPunkt     = new TFHPoint3D(0,0,0,0,0);
		}
				
		//Steuerung--------------------------------------------------------
		public function moveDepth(depth: Number): void {
		//Bewegt die Kamera in der Tiefe
			this.pitch( this.winkelPitch * (-1) );
			this.moveBackward( depth );
			this.pitch( this.winkelPitch );
		}
		public function moveHeight(height: Number): void {
		//Hebt die Kamera in der Höhe
			this.pitch( this.winkelPitch * (-1) );
			this.y = this.y + height;
			this.pitch( this.winkelPitch );
		}
		public function surroundXZ(angle: Number): void {
		//Dreht die Kamera um den Radius auf der XZ-Ebene		
				this.pitch( this.winkelPitch * (-1) );
				
				this.moveForward( radius );
				this.yaw( angle );
				this.moveBackward( radius );
				
				this.pitch( this.winkelPitch );
				
				//zum speichern der Bewegung;
				this.winkelOrgYaw = this.winkelOrgYaw + angle;
		}
		public function surroundXY(angle: Number): void {
		// Dreht die Kamera um den Radius auf der XY-Ebene
				this.moveForward( radius );
				this.pitch( angle );
				this.moveBackward( radius );
				
				this.winkelPitch = this.winkelPitch + angle;
				resetWinkelPitch();
				
				//zum speichern der Bewegung;
				this.winkelOrgPitch = this.winkelOrgPitch + angle;
		}
	
		//Funktionalität--------------------------------------------------
		private function resetWinkelPitch(): void {		
		//Resetet den winkelPitch, wenn dieser +/-180° überschreitet.
			while( this.winkelPitch >= 180 ) {
				this.winkelPitch = this.winkelPitch - 180;
			}
			
			while( this.winkelPitch <= -180 ) {
				this.winkelPitch = this.winkelPitch + 180;
			}
		}	
		public function resetCamera(): void {
		//Setzt die Camera auf den Startpunkt zurück.
			trace("Reset The Camera.");			
								
			this.yaw(   this.winkelOrgYaw   * (-1) );
			this.pitch( this.winkelOrgPitch * (-1) );
			this.x = this.startPunkt.x;
			this.y = this.startPunkt.y;
			this.z = this.startPunkt.z;
			
			this.winkelOrgPitch = 0;
			this.winkelOrgYaw   = 0;
		}	
		
		public function start(): void {
			this.moveRight( -1143 );
			this.moveDepth( 3238 );
			this.y  =  1625;
			this.surroundXZ( 30 );
			this.surroundXY( 10 );
		}	
		
		//Setters & Getters-----------------------------------------------
		public function setRadius(radius: Number): void {
			this.radius = radius;
		}
		
		public function getXPos(): Number { return this.x; }
		public function getYPos(): Number { return this.y; }
		public function getZPos(): Number { return this.z; }
		public function getYaw() : Number { 
			while( this.winkelOrgYaw > 360 ) { this.winkelOrgYaw = this.winkelOrgYaw - 360; trace("get--"); }
			while( this.winkelOrgYaw < 0   ) { this.winkelOrgYaw = this.winkelOrgYaw + 360; trace("get++"); }
			return this.winkelOrgYaw; 
		}
		
		public function setXPos(xPos: Number): void { this.x = xPos; this.x = xPos; }
		public function setYPos(yPos: Number): void { this.y = yPos; this.y = yPos; } 
		public function setZPos(zPos: Number): void { this.z = zPos; this.z = zPos; }
		public function setYaw(yaw:   Number): void { 
			this.pitch( this.winkelPitch * (-1) );
			this.yaw( yaw );
			this.pitch( this.winkelPitch);
			
			this.winkelOrgYaw = this.winkelOrgYaw + yaw;
		}
		
	}
}
