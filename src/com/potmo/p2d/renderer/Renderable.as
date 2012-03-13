package com.potmo.p2d.renderer
{

	public interface Renderable
	{
		/**
		 * Telling object that it is allowed to render to the canvas
		 */
		function render( renderer:Renderer ):void;
	}
}
