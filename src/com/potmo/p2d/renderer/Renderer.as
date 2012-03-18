package com.potmo.p2d.renderer
{
	import com.potmo.p2d.atlas.animation.P2DSpriteAtlasSequence;

	public interface Renderer
	{

		/**
		 * Render a frame to the canvas
		 *
		 * @param the atlas to get images from
		 * @param frame the frame in the atlas to be rendered
		 * @param x position to render
		 * @param y position to render
		 * @param rotation rotation to render frame
		 * @param scaleX scale to render frame
		 * @param scaleY scale to render frame
		 *
		 */
		function draw( atlasId:int, frame:uint, x:Number, y:Number, rotation:Number, scaleX:Number, scaleY:Number ):void;

	}
}
