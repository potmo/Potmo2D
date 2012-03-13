package com.potmo.p2d.atlas
{
	import com.potmo.p2d.atlas.parser.P2DAtlasParser;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class P2DTextureAtlas
	{
		private var _sizes:Vector.<Point>;
		private var _offsets:Vector.<Point>;
		private var _frames:Vector.<Rectangle>;
		private var _frameCount:uint;
		private var _indexBuffer:IndexBuffer3D;
		private var _vertexBuffer:VertexBuffer3D;
		private var _textureBitmap:BitmapData;

		private var _texture:Texture;


		public function P2DTextureAtlas( xmlDescriptor:XML, textureBitmap:BitmapData, parser:P2DAtlasParser )
		{
			_sizes = new Vector.<Point>();
			_offsets = new Vector.<Point>();
			_frames = new Vector.<Rectangle>();
			parser.parse( xmlDescriptor, _sizes, _offsets, _frames );
			_textureBitmap = textureBitmap;

		}


		public function handleContextCreated( context:Context3D ):void
		{
			createVertices( context, "lefttop", _sizes, _offsets, _frames, _textureBitmap.width, _textureBitmap.height );
			createTexture( context, _textureBitmap );
		}


		private function createTexture( context:Context3D, textureBitmap:BitmapData ):void
		{
			_texture = context.createTexture( textureBitmap.width, textureBitmap.height, Context3DTextureFormat.BGRA, false );
			//_texture.uploadFromBitmapData( textureBitmap, 0 );
			uploadBitmapData( _texture, textureBitmap, true );
		}


		private function uploadBitmapData( texture:Texture, bitmapData:BitmapData, generateMipmaps:Boolean ):void
		{
			texture.uploadFromBitmapData( bitmapData );

			if ( generateMipmaps )
			{
				var currentWidth:int = bitmapData.width >> 1;
				var currentHeight:int = bitmapData.height >> 1;
				var level:int = 1;
				var canvas:BitmapData = new BitmapData( currentWidth, currentHeight, true, 0 );
				var transform:Matrix = new Matrix( .5, 0, 0, .5 );
				var bounds:Rectangle = new Rectangle();

				while ( currentWidth >= 1 || currentHeight >= 1 )
				{
					bounds.width = currentWidth;
					bounds.height = currentHeight;
					canvas.fillRect( bounds, 0 );
					canvas.draw( bitmapData, transform, null, null, null, true );
					texture.uploadFromBitmapData( canvas, level++ );
					transform.scale( 0.5, 0.5 );
					currentWidth = currentWidth >> 1;
					currentHeight = currentHeight >> 1;
				}

				canvas.dispose();
			}
		}


		private function createVertices( context:Context3D, registrationPoint:String, sizes:Vector.<Point>, offsets:Vector.<Point>, frames:Vector.<Rectangle>, textureWidth:uint, textureHeight:uint ):void
		{
			var v:uint = 0;
			var i:uint = 0;

			var vd:Vector.<Number> = new Vector.<Number>( frames.length * 16 );
			var id:Vector.<uint> = new Vector.<uint>( frames.length * 6 );

			for ( var c:uint = 0; c < frames.length; c++ )
			{

				var x:Number = frames[ c ].x;
				var y:Number = frames[ c ].y;
				var w:Number = frames[ c ].width;
				var h:Number = frames[ c ].height;

				var x0:Number = -w;
				var y0:Number = +h;
				var x1:Number = +w;
				var y1:Number = -h;

				if ( offsets.length > 0 )
				{
					var ox:Number = offsets[ c ].x;
					var oy:Number = offsets[ c ].y;
					x0 += ox * 2;
					y0 += oy * 2;
					x1 += ox * 2;
					y1 += oy * 2;
				}

				if ( registrationPoint != "center" )
				{
					var sx:Number;
					var sy:Number;

					if ( sizes.length > 0 )
					{
						sx = sizes[ c ].x;
						sy = sizes[ c ].y;
					}
					else
					{
						sx = frames[ 0 ].width;
						sy = frames[ 0 ].height;
					}

					switch ( registrationPoint )
					{
						case "lefttop":
						{
							x0 += sx;
							y0 -= sy;
							x1 += sx;
							y1 -= sy;
						}
							break;
						case "righttop":
						{
							x0 -= sx;
							y0 -= sy;
							x1 -= sx;
							y1 -= sy;
						}
							break;
						case "leftbottom":
						{
							x0 += sx;
							y0 += sy;
							x1 += sx;
							y1 += sy;
						}
							break;
						case "rightbottom":
						{
							x0 -= sx;
							y0 += sy;
							x1 -= sx;
							y1 += sy;
						}
							break;
					}
				}

				var u0:Number = ( x ) / textureWidth;
				var v0:Number = ( y ) / textureHeight;
				var u1:Number = ( x + w ) / textureWidth;
				var v1:Number = ( y + h ) / textureHeight;

				vd[ v++ ] = x0;
				vd[ v++ ] = y0;
				vd[ v++ ] = u0;
				vd[ v++ ] = v0;
				vd[ v++ ] = x1;
				vd[ v++ ] = y0;
				vd[ v++ ] = u1;
				vd[ v++ ] = v0;
				vd[ v++ ] = x1;
				vd[ v++ ] = y1;
				vd[ v++ ] = u1;
				vd[ v++ ] = v1;
				vd[ v++ ] = x0;
				vd[ v++ ] = y1;
				vd[ v++ ] = u0;
				vd[ v++ ] = v1;

				id[ i++ ] = ( c * 4 + 0 );
				id[ i++ ] = ( c * 4 + 1 );
				id[ i++ ] = ( c * 4 + 3 );
				id[ i++ ] = ( c * 4 + 1 );
				id[ i++ ] = ( c * 4 + 2 );
				id[ i++ ] = ( c * 4 + 3 );

			}

			_frameCount = frames.length;
			_indexBuffer = context.createIndexBuffer( id.length );
			_indexBuffer.uploadFromVector( id, 0, id.length );
			_vertexBuffer = context.createVertexBuffer( vd.length / 4, 4 );
			_vertexBuffer.uploadFromVector( vd, 0, vd.length / 4 );

		}


		public function getTexure():Texture
		{
			return _texture;
		}


		public function getVertexBuffer():VertexBuffer3D
		{
			return _vertexBuffer;
		}


		public function getIndexBuffer():IndexBuffer3D
		{
			return _indexBuffer;
		}
	}
}
