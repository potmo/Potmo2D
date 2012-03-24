package com.potmo.p2d.atlas
{
	import com.potmo.p2d.atlas.animation.P2DSpriteAtlas;
	import com.potmo.p2d.atlas.animation.P2DSpriteAtlasSequence;
	import com.potmo.p2d.atlas.animation.SpriteAtlasSequence;
	import com.potmo.p2d.atlas.parser.AtlasParser;

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
		private var _textureBitmaps:Vector.<BitmapData>;
		private var _names:Vector.<String>;

		// the textures
		private var _textures:Vector.<Texture>;
		private var _textureCount:int;
		// the frame offsets. That is the second element will be equal to the nuber of frames of the first texture
		private var _textureFrameOffsets:Vector.<uint>;


		public function P2DTextureAtlas()
		{
			_sizes = new Vector.<Point>();
			_offsets = new Vector.<Point>();
			_frames = new Vector.<Rectangle>();
			_names = new Vector.<String>();
			_textureFrameOffsets = new Vector.<uint>();
			_textureBitmaps = new Vector.<BitmapData>();
			_textureCount = 0;
		}


		public function addTexture( xmlDescriptor:XML, textureBitmap:BitmapData, parser:AtlasParser ):void
		{
			// Push the number of frames that we had before adding a new texture
			_textureFrameOffsets.push( _frames.length - 1 );

			// parse the xml and get the vectors populated
			var sizes:Vector.<Point> = new Vector.<Point>();
			var offsets:Vector.<Point> = new Vector.<Point>();
			var frames:Vector.<Rectangle> = new Vector.<Rectangle>();
			var names:Vector.<String> = new Vector.<String>();
			parser.parse( xmlDescriptor, sizes, offsets, frames, names );

			//add the populated vectors to our full list
			_sizes = _sizes.concat( sizes );
			_offsets = _offsets.concat( offsets );
			_frames = _frames.concat( frames );
			_names = _names.concat( names );

			_textureBitmaps.push( textureBitmap );
			_textureCount++;
		}


		public function handleContextCreated( context:Context3D ):void
		{
			createVertices( context, "lefttop", _sizes, _offsets, _frames, _textureBitmaps, _textureFrameOffsets );

			uploadTextures( context );

		}


		private function uploadTextures( context:Context3D ):void
		{
			_textures = new Vector.<Texture>();
			var textureCount:int = _textureBitmaps.length;

			for ( var i:int = 0; i < textureCount; i++ )
			{
				var texture:Texture = uploadTexture( context, _textureBitmaps[ i ] );
				_textures.push( texture );
			}
			_textureCount = _textures.length;

		}


		private function uploadTexture( context:Context3D, textureBitmap:BitmapData ):Texture
		{
			var textureWidth:int = getNextPowerOfTwo( textureBitmap.width );
			var textureHeight:int = getNextPowerOfTwo( textureBitmap.height );
			var texture:Texture = context.createTexture( textureWidth, textureHeight, Context3DTextureFormat.BGRA, false );
			//_texture.uploadFromBitmapData( textureBitmap, 0 );
			uploadBitmapData( texture, textureBitmap, textureWidth, textureHeight, false );
			return texture;
		}


		private function getNextPowerOfTwo( n:Number ):Number
		{
			var out:Number = 2.0;

			while ( out < n )
			{
				// pow 2
				out <<= 1;
			}

			return out;
		}


		private function uploadBitmapData( texture:Texture, bitmapData:BitmapData, textureWidth:Number, textureHeight:Number, generateMipmaps:Boolean ):void
		{
			texture.uploadFromBitmapData( bitmapData );

			if ( generateMipmaps )
			{
				var currentWidth:int = textureWidth >> 1;
				var currentHeight:int = textureHeight >> 1;
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


		private function createVertices( context:Context3D, registrationPoint:String, sizes:Vector.<Point>, offsets:Vector.<Point>, frames:Vector.<Rectangle>, textureBitmaps:Vector.<BitmapData>, textureFrameOffsets:Vector.<uint> ):void
		{

			// get the frame offset and the next frame offset
			var currentTexture:int = -1;
			var currentTextureLastFrame:int = -1;
			var currentTextureWidth:uint;
			var currentTextureHeight:uint;

			var v:uint = 0;
			var i:uint = 0;
			var numFrames:uint = frames.length;

			var vd:Vector.<Number> = new Vector.<Number>( numFrames * 24, true );
			var id:Vector.<uint> = new Vector.<uint>( numFrames * 6, true );

			for ( var c:uint = 0; c < numFrames; c++ )
			{

				// swap to the next texture
				if ( c >= currentTextureLastFrame )
				{
					currentTexture++;

					if ( currentTexture + 1 < textureFrameOffsets.length )
					{
						currentTextureLastFrame = textureFrameOffsets[ currentTexture + 1 ];
					}
					else
					{
						currentTextureLastFrame = numFrames;
					}

					currentTextureWidth = getNextPowerOfTwo( textureBitmaps[ currentTexture ].width );
					currentTextureHeight = getNextPowerOfTwo( textureBitmaps[ currentTexture ].height );
				}

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

				var u0:Number = ( x ) / currentTextureWidth;
				var v0:Number = ( y ) / currentTextureHeight;
				var u1:Number = ( x + w ) / currentTextureWidth;
				var v1:Number = ( y + h ) / currentTextureHeight;

				// frame sizes and uv (2 * FLOAT_2)
				vd[ v++ ] = x0;
				vd[ v++ ] = y0;
				vd[ v++ ] = u0;
				vd[ v++ ] = v0;
				vd[ v++ ] = currentTexture == 0 ? 1 : 0; //x
				vd[ v++ ] = currentTexture == 1 ? 1 : 0; //x

				vd[ v++ ] = x1;
				vd[ v++ ] = y0;
				vd[ v++ ] = u1;
				vd[ v++ ] = v0;
				vd[ v++ ] = currentTexture == 0 ? 1 : 0; //y
				vd[ v++ ] = currentTexture == 1 ? 1 : 0; //y

				vd[ v++ ] = x1;
				vd[ v++ ] = y1;
				vd[ v++ ] = u1;
				vd[ v++ ] = v1;
				vd[ v++ ] = currentTexture == 0 ? 1 : 0; //z
				vd[ v++ ] = currentTexture == 1 ? 1 : 0; //z

				vd[ v++ ] = x0;
				vd[ v++ ] = y1;
				vd[ v++ ] = u0;
				vd[ v++ ] = v1;
				vd[ v++ ] = currentTexture == 0 ? 1 : 0; //w
				vd[ v++ ] = currentTexture == 1 ? 1 : 0; //w

				// indices (two triangles times 3 vertices)
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

			_vertexBuffer = context.createVertexBuffer( vd.length / 6, 6 ); // FLOAT_2 + FLOAT_2 + FLOAT_2 = 6 floats of 4 components each
			_vertexBuffer.uploadFromVector( vd, 0, vd.length / 6 );

		}


		public function getTexure( id:uint ):Texture
		{
			return _textures[ id ];
		}


		public function getFrameNames():Vector.<String>
		{
			// clone
			return _names.concat();
		}


		public function getFrameSizes():Vector.<Point>
		{
			// clone
			return _sizes.concat();
		}


		public function getVertexBuffer():VertexBuffer3D
		{
			return _vertexBuffer;
		}


		public function getIndexBuffer():IndexBuffer3D
		{
			return _indexBuffer;
		}


		public function getTextureCount():int
		{
			return _textureCount;
		}

	}
}
