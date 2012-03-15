package com.potmo.p2d.atlas.parser
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public interface AtlasParser
	{
		function parse( descriptor:XML, sizes:Vector.<Point>, offsets:Vector.<Point>, frames:Vector.<Rectangle>, names:Vector.<String> ):void;
	}
}
