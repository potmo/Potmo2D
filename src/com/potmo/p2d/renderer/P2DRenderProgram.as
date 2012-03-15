package com.potmo.p2d.renderer
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;

	public class P2DRenderProgram
	{

		private static const VERTEX_SHADER:Vector.<String> = new <String>[ "mov vt0.xyzw, va0.xyww\n",
																		   "m33 vt0.xyz, vt0, vc0\n",
																		   "mov op, vt0\n",
																		   "mov v0, va1\n" ];

		private static const FRAGMENT_SHADER:Vector.<String> = new <String>[ "tex oc, v0, fs0 <2d,linear,mipnone>\n" ];

		private static const FRAGMENT_SHADER_ALPHA:Vector.<String> = new <String>[ "tex ft0, v0, fs0 <2d,linear,mipnone>\n",
																				   "mul oc, ft0, fc0\n" ];

		private var _program:Program3D;

		private var program:Program3D;


		public function P2DRenderProgram()
		{

		}


		public function createProgram( context:Context3D ):void
		{

			// Create program 3D instance for shader  
			program = context.createProgram();

			// Assemble vertex shader from its code
			var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexAssembler.assemble( Context3DProgramType.VERTEX, VERTEX_SHADER.join( "" ) );

			// Assemble fragment shader from its code
			var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentAssembler.assemble( Context3DProgramType.FRAGMENT, FRAGMENT_SHADER_ALPHA.join( "" ) );

			// Upload vertex/framgment shader to our program  
			program.upload( vertexAssembler.agalcode, fragmentAssembler.agalcode );

		}


		public function setProgram( context:Context3D ):void
		{
			context.setProgram( program );

		}
	}
}
