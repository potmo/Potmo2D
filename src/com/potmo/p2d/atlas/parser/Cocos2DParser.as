package com.potmo.p2d.atlas.parser
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Cocos2DParser implements AtlasParser
	{
		public function Cocos2DParser()
		{
		}


		public function parse( descriptor:XML, sizes:Vector.<Point>, offsets:Vector.<Point>, frames:Vector.<Rectangle>, names:Vector.<String> ):void
		{

			// Not very generic, only tested with TexturePacker

			var type:String;
			var data:String;
			var array:Array;

			var topKeys:XMLList = descriptor.dict.key;
			var topDicts:XMLList = descriptor.dict.dict;

			for ( var k:uint = 0; k < topKeys.length(); k++ )
			{
				switch ( topKeys[ k ].toString() )
				{
					case "frames":
					{
						var frameKeys:XMLList = topDicts[ k ].key;
						var frameDicts:XMLList = topDicts[ k ].dict;

						for ( var l:uint = 0; l < frameKeys.length(); l++ )
						{
							names.push( frameKeys[ l ].toString() );
							var propKeys:XMLList = frameDicts[ l ].key;
							var propAll:XMLList = frameDicts[ l ].*;

							for ( var m:uint = 0; m < propKeys.length(); m++ )
							{
								type = propAll[ propKeys[ m ].childIndex() + 1 ].name();
								data = propAll[ propKeys[ m ].childIndex() + 1 ];

								switch ( propKeys[ m ].toString() )
								{
									case "frame":
									{
										if ( type == "string" )
										{
											array = data.split( /[^0-9-]+/ );
											frames.push( new Rectangle( array[ 1 ], array[ 2 ], array[ 3 ], array[ 4 ] ) );
										}
										else
										{
											throw new Error( "Error parsing descriptor format" );
										}
										break;
									}
									case "offset":
									{
										if ( type == "string" )
										{
											array = data.split( /[^0-9-]+/ );
											offsets.push( new Point( array[ 1 ], array[ 2 ] ) );
										}
										else
										{
											throw new Error( "Error parsing descriptor format" );
										}
										break;
									}
									case "sourceSize":
									{
										if ( type == "string" )
										{
											array = data.split( /[^0-9-]+/ );
											sizes.push( new Point( array[ 1 ], array[ 2 ] ) );
										}
										else
										{
											throw new Error( "Error parsing descriptor format" );
										}
										break;
									}
									case "rotated":
									{
										if ( type != "false" )
										{
											throw new Error( "Rotated elements not supported (yet)" );
										}
										break;
									}
								}
							}
						}
						break;
					}
				}
			}

			if ( frames.length == 0 )
			{
				throw new Error( "Error parsing descriptor format" );
			}
		}
	}
}
