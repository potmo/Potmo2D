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
		private var _texureInSpiteOffsets:Vector.<Point>;
		private var _textureSourceRects:Vector.<Rectangle>;
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
		private var _regpoints:Vector.<Point>;
		private var _spriteSizes:Vector.<Point>;
		private var _sequenceFrames:Vector.<int>;
		private var _labels:Vector.<String>;


		public function P2DTextureAtlas()
		{
			_texureInSpiteOffsets = new Vector.<Point>();
			_textureSourceRects = new Vector.<Rectangle>();
			_names = new Vector.<String>();
			_regpoints = new Vector.<Point>();
			_spriteSizes = new Vector.<Point>();
			_textureFrameOffsets = new Vector.<uint>();
			_textureBitmaps = new Vector.<BitmapData>();
			_sequenceFrames = new Vector.<int>();
			_labels = new Vector.<String>();
			_textureCount = 0;
		}


		public function addTexture( xmlDescriptor:XML, textureBitmap:BitmapData, parser:AtlasParser ):void
		{
			// Push the number of frames that we had before adding a new texture
			_textureFrameOffsets.push( _textureSourceRects.length - 1 );

			// parse the xml and get the vectors populated
			var texureInSpiteOffsets:Vector.<Point> = new Vector.<Point>();
			var textureSourceRects:Vector.<Rectangle> = new Vector.<Rectangle>();
			var names:Vector.<String> = new Vector.<String>();
			var regpoints:Vector.<Point> = new Vector.<Point>();
			var spriteSizes:Vector.<Point> = new Vector.<Point>();
			var labels:Vector.<String> = new Vector.<String>();
			var sequenceFrames:Vector.<int> = new Vector.<int>();
			parser.parse( xmlDescriptor, spriteSizes, regpoints, texureInSpiteOffsets, textureSourceRects, sequenceFrames, names, labels );

			//add the populated vectors to our full list
			_texureInSpiteOffsets = _texureInSpiteOffsets.concat( texureInSpiteOffsets );
			_textureSourceRects = _textureSourceRects.concat( textureSourceRects );
			_names = _names.concat( names );
			_regpoints = _regpoints.concat( regpoints );
			_spriteSizes = _regpoints.concat( spriteSizes );
			_sequenceFrames = _sequenceFrames.concat( sequenceFrames );
			_labels = _labels.concat( labels );

			_textureBitmaps.push( textureBitmap );
			_textureCount++;
		}


		public function handleContextCreated( context:Context3D ):void
		{
			createVertices( context, _texureInSpiteOffsets, _textureSourceRects, _textureBitmaps, _textureFrameOffsets, _regpoints );

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


		private function createVertices( context:Context3D, drawInSpriteOffset:Vector.<Point>, textureSourceFrames:Vector.<Rectangle>, textureBitmaps:Vector.<BitmapData>, textureFrameOffsets:Vector.<uint>, regPoints:Vector.<Point> ):void
		{

			// get the frame offset and the next frame offset
			var currentTexture:int = -1;
			var currentTextureLastFrame:int = -1;
			var currentTextureWidth:uint;
			var currentTextureHeight:uint;

			var v:uint = 0;
			var i:uint = 0;
			var numFrames:uint = textureSourceFrames.length;

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

				// the source coordinates in the texture bitmapdata
				var sourceX:Number = textureSourceFrames[ c ].x;
				var sourceY:Number = textureSourceFrames[ c ].y;
				var sourceWidth:Number = textureSourceFrames[ c ].width;
				var sourceHeight:Number = textureSourceFrames[ c ].height;

				// create the model in local coordinates. Aligned upper left
				// first vertex in bottom left corner and then counter clockwise
				var modelX0:Number = 0;
				var modelY0:Number = sourceHeight * 2;
				var modelX1:Number = sourceWidth * 2;
				var modelY1:Number = 0;

				// translate by texture offset in sprite frame
				var ox:Number = drawInSpriteOffset[ c ].x;
				var oy:Number = drawInSpriteOffset[ c ].y;
				modelX0 += ox;
				modelY0 += oy;
				modelX1 += ox;
				modelY1 += oy;

				// translate by regpoing (0,0 is upper left)
				var rx:Number = regPoints[ c ].x;
				var ry:Number = regPoints[ c ].y;
				modelX0 -= rx;
				modelY0 -= ry;
				modelX1 -= rx;
				modelY1 -= ry;

				// scale texture coordinates to UV coordinates (unit coordinates)
				var u0:Number = ( sourceX ) / currentTextureWidth;
				var v0:Number = ( sourceY ) / currentTextureHeight;
				var u1:Number = ( sourceX + sourceWidth ) / currentTextureWidth;
				var v1:Number = ( sourceY + sourceHeight ) / currentTextureHeight;

				// frame sizes and uv (2 * FLOAT_2)
				vd[ v++ ] = modelX0;
				vd[ v++ ] = modelY0;
				vd[ v++ ] = u0;
				vd[ v++ ] = v0;
				vd[ v++ ] = currentTexture == 0 ? 1 : 0; //x
				vd[ v++ ] = currentTexture == 1 ? 1 : 0; //x

				vd[ v++ ] = modelX1;
				vd[ v++ ] = modelY0;
				vd[ v++ ] = u1;
				vd[ v++ ] = v0;
				vd[ v++ ] = currentTexture == 0 ? 1 : 0; //y
				vd[ v++ ] = currentTexture == 1 ? 1 : 0; //y

				vd[ v++ ] = modelX1;
				vd[ v++ ] = modelY1;
				vd[ v++ ] = u1;
				vd[ v++ ] = v1;
				vd[ v++ ] = currentTexture == 0 ? 1 : 0; //z
				vd[ v++ ] = currentTexture == 1 ? 1 : 0; //z

				vd[ v++ ] = modelX0;
				vd[ v++ ] = modelY1;
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

			_frameCount = textureSourceFrames.length;
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

			return _names.concat(); // clone
		}


		public function getSequenceFrames():Vector.<int>
		{
			return _sequenceFrames.concat(); // clone
		}


		public function getFrameLabels():Vector.<String>
		{
			return _labels.concat(); //clone
		}


		public function getSpriteSizes():Vector.<Point>
		{
			return _spriteSizes.concat(); // clone
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
