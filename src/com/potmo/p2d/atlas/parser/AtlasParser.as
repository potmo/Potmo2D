package com.potmo.p2d.atlas.parser
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public interface AtlasParser
	{
		function parse( descriptor:XML, spriteSizes:Vector.<Point>, regpointsInSprites:Vector.<Point>, textureInSpriteOffsets:Vector.<Point>, textureSourceRects:Vector.<Rectangle>, sequenceFrames:Vector.<int>, names:Vector.<String>, labels:Vector.<String> ):void;
	}
}
