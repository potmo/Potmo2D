package com.potmo.p2d.renderer
{

	public class P2DCamera
	{
		private var _x:Number = 0;
		private var _y:Number = 0;


		public function P2DCamera()
		{
		}


		public function setCameraX( value:Number ):void
		{
			_x = value;
		}


		public function setCameraY( value:Number ):void
		{
			_y = value;
		}


		public function getCameraX():Number
		{
			return _x;
		}


		public function getCameraY():Number
		{
			return _y;
		}
	}
}
