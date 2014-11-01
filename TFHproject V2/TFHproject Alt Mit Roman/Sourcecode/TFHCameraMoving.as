package {
	import flash.display.Sprite;
	
	
		public class TFHCameraMoving	{		private var camera:   TFHCamera;
		private var tfh:      TFH;
				private var isMoving: Boolean;		private var point:    TFHPoint3D;				private var steps:    Number;		private var stepsX:   Number;		private var stepsZ:   Number;		private var stepsYaw: Number;		private var stepsMax: Number = 50;		public function TFHCameraMoving(camera: TFHCamera, tfh: TFH) {			this.camera   = camera;
			this.tfh      = tfh;			this.isMoving = false;		}				public function setPoint(point: TFHPoint3D) {		//Setzt den Zielpunkt fest.			this.point = point;		}		public function play(): void {		//Gibt den Befehl zum Camera bewegen.			if( !this.isMoving ) {				
				var startYaw:Number = this.camera.getYaw();
				var diffX:   Number = Math.abs(this.point.x - this.camera.getXPos());
				var diffZ:   Number = Math.abs(this.point.z - this.camera.getZPos());
				var diffYaw: Number = Math.abs(this.point.yaw - startYaw);				this.steps    = 0;
				
				// Schritte auf der X-Achse berechnen:
				if( this.camera.getXPos() <= this.point.x ) { this.stepsX =   diffX / this.stepsMax ; } 
				else 										{ this.stepsX = -(diffX / this.stepsMax); }
				
				// Schritte auf der Y-Achse berechnen:
				if( this.camera.getZPos() <= this.point.z ) { this.stepsZ =   diffZ / this.stepsMax ; } 
				else 								  		{ this.stepsZ = -(diffZ / this.stepsMax); }
				
				// Schritte des Winkels berechnen:
				if( diffYaw > 180 ) { // Nehme den Weg über den Nullwinkel
					if( startYaw < this.point.yaw ) { this.stepsYaw = -((startYaw + (360-this.point.yaw)) / this.stepsMax ); }
					else 							{ this.stepsYaw =   ((360-startYaw) + this.point.yaw) / this.stepsMax  ; }
				} else {			  // Nehme den standart Weg
					if( startYaw > this.point.yaw ) { this.stepsYaw = -(diffYaw / this.stepsMax); }
					else							{ this.stepsYaw =  (diffYaw / this.stepsMax); }				}				
									this.isMoving = true;				isStarted     = true;			}		}		public function stop(): void {		//Stoppt die Bewegung im aktuellen Standpunkt.			this.isMoving = false;		}			public function move(): Boolean {		//Bewegt die Camera schrittweise zum Zielpunkt.			if( this.isMoving ) {				this.camera.setXPos( this.camera.getXPos() + this.stepsX ); // X-Verschiebung				this.camera.setZPos( this.camera.getZPos() + this.stepsZ ); // Z-Verschiebung
				this.camera.setYaw(  this.stepsYaw );						// Winkelverschiebung				this.steps++;								//Abbruchbedingung:
				//Schneellerer Abbruch möglich wenn Camera = gew. Position...				if( this.steps == this.stepsMax+1 ) { 					this.stop();
					this.tfh.addPopupmenu();
				}			}		}	}}