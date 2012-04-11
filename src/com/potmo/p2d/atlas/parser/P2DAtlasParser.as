package com.potmo.p2d.atlas.parser
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Takes a xml that looks like this
	 *
	   <atlas>
	   <metadata>
	   </metadata>
	   <frames>
	   <frame>
	   <name>{_name}</name>
	   <number>{_frame}</number>
	   <label>{_label}</label>
	   <regpointx>{_regpoint.x}</regpointx>
	   <regpointy>{_regpoint.y}</regpointy>
	   <texturex>{_textureSourceRect.x}</texturex>
	   <texturey>{_textureSourceRect.y}</texturey>
	   <texturewidth>{_textureSourceRect.width}</texturewidth>
	   <textureheight>{_textureSourceRect.height}</textureheight>
	   <offsetx>{_textureInSpriteOffset.x}</offsetx>
	   <offsety>{_textureInSpriteOffset.y}</offsety>
	   <spritewidth>{_spriteBounds.width}</spritewidth>
	   <spriteheight>{_spriteBounds.height}</spriteheight>
	   <isalias>{_alias}</isalias>
	   </frame>
	   </frames>
	   </atlas>

	 *
	 */
	public class P2DAtlasParser implements AtlasParser
	{
		public function P2DAtlasParser()
		{

		}


		public function parse( descriptor:XML, spriteSizes:Vector.<Point>, regpointsInSprites:Vector.<Point>, textureInSpriteOffsets:Vector.<Point>, textureSourceRects:Vector.<Rectangle>, sequenceid:Vector.<int>, names:Vector.<String>, labels:Vector.<String> ):void
		{
			var frames:Vector.<P2DAtlasParserFrame> = getParserFrames( descriptor );

			//sort the frames
			frames.sort( parserFrameSortCompartor );

			for each ( var frame:P2DAtlasParserFrame in frames )
			{

				textureInSpriteOffsets.push( new Point( frame.offsetx, frame.offsety ) );
				spriteSizes.push( new Point( frame.spritewidth, frame.spriteheight ) );
				textureSourceRects.push( new Rectangle( frame.texturex, frame.texturey, frame.texturewidth, frame.textureheight ) );
				names.push( frame.name );
				labels.push( frame.label );
				sequenceid.push( frame.number );
				regpointsInSprites.push( new Point( frame.regpointx, frame.regpointy ) );
			}

		}


		private function padWithZeros( maxLength:int, num:int ):String
		{
			var out:String = num.toString();

			while ( out.length < maxLength )
			{
				out = "0" + out;
			}
			return out;
		}


		private function parserFrameSortCompartor( a:P2DAtlasParserFrame, b:P2DAtlasParserFrame ):int
		{
			var stringComp:int = a.name.localeCompare( b.name );

			if ( stringComp == 0 )
			{
				if ( a.number == b.number )
				{
					return 0;
				}
				else
				{
					return a.number < b.number ? -1 : +1;
				}
			}
			else
			{
				return stringComp;
			}

		}


		private function getParserFrames( descriptor:XML ):Vector.<P2DAtlasParserFrame>
		{
			var atlas:XML = descriptor[ "frames" ][ 0 ];
			var frames:XMLList = atlas.child( "frame" );

			var parserFrames:Vector.<P2DAtlasParserFrame> = new Vector.<P2DAtlasParserFrame>();

			for each ( var frame:XML in frames )
			{
				var parserFrame:P2DAtlasParserFrame = new P2DAtlasParserFrame();
				parserFrame.name = frame[ "name" ];
				parserFrame.number = parseInt( frame[ "number" ] );
				parserFrame.label = frame[ "label" ];
				parserFrame.regpointx = parseFloat( frame[ "regpointx" ] );
				parserFrame.regpointy = parseFloat( frame[ "regpointy" ] );
				parserFrame.texturex = parseFloat( frame[ "texturex" ] );
				parserFrame.texturey = parseFloat( frame[ "texturey" ] );
				parserFrame.texturewidth = parseFloat( frame[ "texturewidth" ] );
				parserFrame.textureheight = parseFloat( frame[ "textureheight" ] );
				parserFrame.offsetx = parseFloat( frame[ "offsetx" ] );
				parserFrame.offsety = parseFloat( frame[ "offsety" ] );
				parserFrame.spritewidth = parseFloat( frame[ "spritewidth" ] );
				parserFrame.spriteheight = parseFloat( frame[ "spriteheight" ] );
				parserFrame.isalias = ( ( frame[ "isalias" ] == "true" ) ? true : false );
				parserFrames.push( parserFrame );

			}

			return parserFrames;

		}

	}
}

internal class P2DAtlasParserFrame
{
	public var name:String;
	public var number:int;
	public var label:String;
	public var regpointx:Number;
	public var regpointy:Number;
	public var texturex:Number;
	public var texturey:Number;
	public var texturewidth:Number;
	public var textureheight:Number;
	public var spritewidth:Number;
	public var spriteheight:Number;
	public var offsetx:Number;
	public var offsety:Number;
	public var isalias:Boolean;


	public function P2DAtlasParserFrame()
	{

	}


	public function toString():String
	{
		return "{name: " + name + " number: " + number + "}"
	}
}
