package com.potmo.p2d.atlas.animation
{
	import flash.geom.Point;

	public interface SpriteAtlasSequence
	{
		function getFrameOfLabel( label:String ):int;
		function getNthFrame( n:uint ):uint;
		function getFrameCount():int;
		function getName():String;
		function getNextFrame( currentFrame:uint, loop:Boolean, followLabelPointers:Boolean ):uint;
		function getSizeOfFrame( atlasFrame:uint ):Point;
	}
}
