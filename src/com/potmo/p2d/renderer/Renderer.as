package com.potmo.p2d.renderer
{

	public interface Renderer
	{

		/**
		 * Render a frame to the canvas
		 *
		 * @param frame the frame in the atlas to be rendered
		 * @param x position to render
		 * @param y position to render
		 * @param rotation rotation to render frame
		 * @param scaleX scale to render frame
		 * @param scaleY scale to render frame
		 *
		 */
		function draw( frame:uint, x:Number, y:Number, rotation:Number, scaleX:Number, scaleY:Number ):void;
	}
}
