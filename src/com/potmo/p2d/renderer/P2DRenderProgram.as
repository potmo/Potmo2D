package com.potmo.p2d.renderer
{
	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;

	public class P2DRenderProgram
	{

		private static const VERTEX_SHADER:Vector.<String> = new <String>[ "mov vt0.xyzw, va0.xyww\n", // copy postion (setVertexBufferAt(0...) )
																		   "m33 vt0.xyz, vt0, vc0\n", // multiply with contant matrix (setProgramContantFromVector)
																		   "mov op, vt0\n", // print out
																		   "mov v0, va1\n" ]; // pass uv to fragment shader (setVertexBufferAt(1...)

		/**
		 * Regular texture fragment shader that takes one texture only
		 */
		private static const FRAGMENT_SHADER:Vector.<String> = new <String>[ "tex oc, v0, fs0 <2d,linear,mipnone>\n" ]; // sample and output

		/**
		 * Regular one texture fragment shader that applies alpha
		 */
		private static const FRAGMENT_SHADER_ALPHA:Vector.<String> = new <String>[ "tex ft0, v0, fs0 <2d,linear,mipnone>\n", //sample
																				   "mul oc, ft0, fc0\n" ]; // multiply with alpha to output

		/**
		 * vertex shader to batch from multiple textures
		 */
		private static const VERTEX_SHADER_2_TEXTURE_BATCH:Vector.<String> = new <String>[ "mov vt0.xyzw, va0.xyww\n", // copy two first floats (setVertexBufferAt(0...)
																						   "m33 vt0.xyz, vt0, vc1\n", // multiply matrix (setProgramContantFromVector)
																						   "mov op, vt0\n", // print out
																						   "mov v0, va1\n", // pass uv to fragment shader (setVertexBufferAt(1...)
																						   "mov v1, va2\n", // pass textureIdMask to fragment shader (setVertexBufferAt(1...)
																						   "mov v2, vc0\n" ]; // pass colortransform to fragment shader 
		/**
		 * http://blog.flash-core.com/?p=493
		 */

		private static const FRAGMENT_SHADER_2_TEXTURE_BATCH:Vector.<String> = new <String>[ "tex ft0, v0, fs0 <2d,clamp,mipnone>\n", // sample texture 1
																							 "mul ft0, ft0, v1.xxxx\n", // multiply with mask 1
																							 "tex ft1, v0, fs1 <2d,clamp,mipnone>\n", // sample texture 2
																							 "mul ft1, ft1, v1.yyyy\n", // multiply with mask 2
																							 "add ft0, ft0, ft1\n", // add color 1 and color 2 
																							 "mul oc, ft0, v2" ]; // multiply with colortransform and copy to output

		private var _program:Program3D;


		public function P2DRenderProgram()
		{

		}


		private function getVertexShaderSource( numberOfTextures:uint ):String
		{
			switch ( numberOfTextures )
			{
				case 1:
				//return VERTEX_SHADER.join( "" );
				case 2:
					return VERTEX_SHADER_2_TEXTURE_BATCH.join( "" );
				default:
					throw new Error( "Texture batching vertex does not support " + numberOfTextures + " textures" );
			}
		}


		private function getFragmentShaderSource( numberOfTextures:uint ):String
		{
			switch ( numberOfTextures )
			{
				case 1:
				//return FRAGMENT_SHADER_ALPHA.join( "" );
				case 2:
					return FRAGMENT_SHADER_2_TEXTURE_BATCH.join( "" );
				default:
					throw new Error( "Texture batching fragment does not support " + numberOfTextures + " textures" );
			}
		}


		public function createProgram( context:Context3D, numberOfTextures:uint ):void
		{

			// Create program 3D instance for shader  
			_program = context.createProgram();

			// Assemble vertex shader from its code
			var vertexAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexAssembler.assemble( Context3DProgramType.VERTEX, getVertexShaderSource( numberOfTextures ) );

			// Assemble fragment shader from its code
			var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentAssembler.assemble( Context3DProgramType.FRAGMENT, getFragmentShaderSource( numberOfTextures ) );

			// Upload vertex/framgment shader to our program  
			_program.upload( vertexAssembler.agalcode, fragmentAssembler.agalcode );

		}


		public function setProgram( context:Context3D ):void
		{
			context.setProgram( _program );

		}
	}
}
