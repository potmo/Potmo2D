package com.potmo.p2d.renderer
{
	import com.potmo.p2d.atlas.P2DTextureAtlas;
	import com.potmo.p2d.atlas.animation.P2DSpriteAtlasSequence;

	import flash.display.BlendMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class P2DRenderer implements Renderer
	{

		private var _viewPort:Rectangle;
		private var _antialias:uint;
		private var _context:Context3D;
		private var _program:P2DRenderProgram;
		private var _atlas:P2DTextureAtlas;

		private var _matrix:Matrix;
		private var _matrixVector:Vector.<Number>;
		private var _transformVector:Vector.<Number>;

		private var _backBufferWidth:Number;
		private var _backBufferHeight:Number;
		private var _backBufferWidthInv:Number;
		private var _backBufferHeightInv:Number;

		private var _camera:P2DCamera;


		public function P2DRenderer( viewPort:Rectangle, antialias:uint, atlas:P2DTextureAtlas, camera:P2DCamera )
		{
			_matrix = new Matrix();
			_viewPort = viewPort;
			_atlas = atlas;
			_antialias = antialias;
			_program = new P2DRenderProgram();
			_matrixVector = new Vector.<Number>( 12, true );
			_backBufferWidth = _viewPort.width;
			_backBufferHeight = _viewPort.height;
			_backBufferWidthInv = 1.0 / _backBufferWidth;
			_backBufferHeightInv = 1.0 / _backBufferHeight;
			_camera = camera;

			for ( var c:uint = 0; c < 12; c++ )
			{
				_matrixVector[ c ] = 0.0;
			}
			_matrixVector[ 3 ] = 1.0;
			_matrixVector[ 7 ] = 1.0;
			_matrixVector[ 11 ] = 1.0;

			_transformVector = new Vector.<Number>();

		}


		public function handleContextCreated( context:Context3D ):void
		{
			this._context = context;
			context.configureBackBuffer( _viewPort.width, _viewPort.height, _antialias, true );

			_atlas.handleContextCreated( context );
			_program.createProgram( context, _atlas.getTextureCount() );

		}


		private function clear( r:Number = 0, g:Number = 0, b:Number = 0, a:Number = 0 ):void
		{
			_context.clear( r, g, b, a );
		}


		private function prepareRender():void
		{
			_program.setProgram( _context );

			var vertexBuffer:VertexBuffer3D;

			for ( var i:int = 0; i < _atlas.getTextureCount(); i++ )
			{
				_context.setTextureAt( i, _atlas.getTexure( i ) );
			}

			vertexBuffer = _atlas.getVertexBuffer();
			_context.setVertexBufferAt( 0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 );
			_context.setVertexBufferAt( 1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2 );
			_context.setVertexBufferAt( 2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_2 );

		}


		public function draw( frame:uint, x:Number, y:Number, rotation:Number, scaleX:Number, scaleY:Number, alphaMultiplyer:Number, redMultiplyer:Number, greenMultiplyer:Number, blueMultiplyer:Number ):void
		{
			_matrix.createBox( scaleX, scaleY, rotation, ( x - _camera.getCameraX() ) * 2 - _backBufferWidth, _backBufferHeight - ( y + _camera.getCameraY() ) * 2 );

			// TODO: this should be in shader instead. Also camera translation
			_matrix.scale( _backBufferWidthInv, _backBufferHeightInv );

			//check nd2d's Sprite2sBatch and Sprite2dBatchmaterial

			//TODO: Append to one matrix vector for later execution (This should be pushed to ProgramConstants and then pulled in vertext shader)
			// same for the fragmen shader
			// we must also upload a new vertex buffer containing the ids that point to the constants for each vertex

			//TODO: Do not draw stuff that is fully outside the screen

			//this matrix vector has a length of 12 
			_matrixVector[ 0 ] = _matrix.a;
			_matrixVector[ 1 ] = _matrix.c;
			_matrixVector[ 2 ] = _matrix.tx;
			_matrixVector[ 4 ] = _matrix.b;
			_matrixVector[ 5 ] = _matrix.d;
			_matrixVector[ 6 ] = _matrix.ty;

			//TODO: Append to one big transform vector for later execution
			_transformVector[ 0 ] = redMultiplyer;
			_transformVector[ 1 ] = greenMultiplyer;
			_transformVector[ 2 ] = blueMultiplyer;
			_transformVector[ 3 ] = alphaMultiplyer;

			_context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 0, _transformVector, 1 ); // this is the colortransform but we dont care about it now
			_context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 1, _matrixVector, 3 );

			//var indexBuffer:IndexBuffer3D = _atlases.getIndexBuffer();
			var indexBuffer:IndexBuffer3D = _atlas.getIndexBuffer();
			_context.drawTriangles( indexBuffer, frame * 6, 2 );
		}


		public function render( displayRoot:Renderable ):void
		{
			this.clear( 0.5, 0.5, 0.5, 1 );
			this.prepareRender();

			//TODO: Set batch num to 0
			displayRoot.render( this );
			//TODO: Set program constants from vector and draw the full batch
			// remember that we might have to do this more often if the batch is full

			this.present();

		}


		private function present():void
		{
			_context.present();
		}


		public function handleContentLost():void
		{
			throw new Error( "Not handling content lost yet" );
		}

	}
}
