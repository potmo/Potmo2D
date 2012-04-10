package com.potmo.p2d.atlas.parser
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public interface AtlasParser
	{
		function parse( descriptor:XML, textureInSpriteOffsets:Vector.<Point>, spriteSizes:Vector.<Point>, textureSourceRects:Vector.<Rectangle>, names:Vector.<String>, regpointsInSprites:Vector.<Point> ):void;
	}
}
