package com.potmo.p2d.renderer
{
	import com.potmo.p2d.atlas.animation.P2DSpriteAtlasSequence;

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
		 * @param alphaMultiplyer value between 0.0 and 1.0
		 * @param redMultiplyer value between 0.0 and 1.0
		 * @param greenMultiplyer value between 0.0 and 1.0
		 * @paramblueMultiplyer value between 0.0 and 1.0
		 *
		 */
		function draw( frame:uint, x:Number, y:Number, rotation:Number, scaleX:Number, scaleY:Number, alphaMultiplyer:Number, redMultiplyer:Number, greenMultiplyer:Number, blueMultiplyer:Number ):void;

	}
}
