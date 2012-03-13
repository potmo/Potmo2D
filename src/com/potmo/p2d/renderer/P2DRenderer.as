package com.potmo.p2d.renderer
{
	import com.potmo.p2d.atlas.P2DTextureAtlas;

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

		private var _backBufferWidth:Number;
		private var _backBufferHeight:Number;
		private var _backBufferWidthInv:Number;
		private var _backBufferHeightInv:Number;


		public function P2DRenderer( viewPort:Rectangle, antialias:uint, atlas:P2DTextureAtlas )
		{
			_matrix = new Matrix();
			_viewPort = viewPort;
			_antialias = antialias;
			_atlas = atlas;
			_program = new P2DRenderProgram();
			_matrixVector = new Vector.<Number>( 12, true );
			_backBufferWidth = _viewPort.width;
			_backBufferHeight = _viewPort.height;
			_backBufferWidthInv = 1.0 / _backBufferWidth;
			_backBufferHeightInv = 1.0 / _backBufferHeight;

			for ( var c:uint = 0; c < 12; c++ )
			{
				_matrixVector[ c ] = 0.0;
			}
			_matrixVector[ 3 ] = 1.0;
			_matrixVector[ 7 ] = 1.0;
			_matrixVector[ 11 ] = 1.0;

		}


		public function handleContextCreated( context:Context3D ):void
		{
			this._context = context;
			context.configureBackBuffer( _viewPort.width, _viewPort.height, _antialias, true );

			_program.createProgram( context );

			_atlas.handleContextCreated( context );

		}


		public function clear( r:Number = 0, g:Number = 0, b:Number = 0, a:Number = 0 ):void
		{
			_context.clear( r, g, b, a );
		}


		public function prepareRender():void
		{
			_program.setProgram( _context );
			_context.setTextureAt( 0, _atlas.getTexure() );

			var vertexBuffer:VertexBuffer3D = _atlas.getVertexBuffer();
			_context.setVertexBufferAt( 0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2 );
			_context.setVertexBufferAt( 1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2 );

		}


		public function draw( frame:uint, x:Number, y:Number, rotation:Number, scaleX:Number, scaleY:Number ):void
		{
			_matrix.createBox( scaleX, scaleY, rotation, x - _backBufferWidth, _backBufferHeight - y );
			_matrix.scale( _backBufferWidthInv, _backBufferHeightInv );
			_matrixVector[ 0 ] = _matrix.a;
			_matrixVector[ 1 ] = _matrix.c;
			_matrixVector[ 2 ] = _matrix.tx;
			_matrixVector[ 4 ] = _matrix.b;
			_matrixVector[ 5 ] = _matrix.d;
			_matrixVector[ 6 ] = _matrix.ty;
			_context.setProgramConstantsFromVector( Context3DProgramType.VERTEX, 0, _matrixVector, 3 );

			var indexBuffer:IndexBuffer3D = _atlas.getIndexBuffer();
			_context.drawTriangles( indexBuffer, frame * 6, 2 );
		}


		public function render( displayRoot:Renderable ):void
		{
			displayRoot.render( this );

		}


		public function present():void
		{
			_context.present();
		}
	}
}
