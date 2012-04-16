package com.potmo.p2d.atlas.animation
{
	import flash.geom.Point;

	/**
	 * This is a subset of frames from the atlas.
	 * It is possible to get a the frame of a label.
	 *
	 * All frames are in atlas frames not to be confused with the frame of the subsetted sequence
	 *
	 */
	public class P2DSpriteAtlasSequence implements SpriteAtlasSequence
	{
		private var _name:String;
		private var _sequenceFrameCount:int;
		private var _labels:Vector.<String>;
		private var _atlasFrames:Vector.<uint>;
		private var _sequenceOffsetInAtlas:uint;
		private var _frameSizes:Vector.<Point>;
		private var _regPoints:Vector.<Point>;


		public function P2DSpriteAtlasSequence( name:String )
		{
			_name = name;
			_labels = new Vector.<String>();
			_atlasFrames = new Vector.<uint>();
			_frameSizes = new Vector.<Point>();
			_regPoints = new Vector.<Point>();
			_sequenceFrameCount = 0;
		}


		/**
		 * Go to the next frame in the sequence
		 * @param currentFrame the current frame
		 * @param loop if next frame is the first frame when currentFrame is the last frame
		 * @param followLabelPointers if label pointers are enabled.
		 * A label begining with GOTO_ will make the next frame the frame after the GOTO_
		 * A label begining with LOOP_ will make the next frame be the same frame as the currentFrame
		 *
		 * @return the next frame in the sequence
		 *
		 */
		public function getNextFrame( currentFrame:uint, loop:Boolean, followLabelPointers:Boolean ):uint
		{
			//TODO: Check next frame for overflow nad pointers and so on

			if ( followLabelPointers )
			{
				var label:String = getLabelOfFrame( currentFrame );
				var labelParts:Vector.<String> = Vector.<String>( label.split( "_" ) );

				if ( labelParts.length >= 2 )
				{
					// get and remove comand
					var command:String = labelParts.shift();

					// check the command
					switch ( command )
					{
						case "GOTO":
						{
							// find label to jump to
							var jumpToLabel:String = labelParts.join( "_" );
							var jumpToFrame:int = getFrameOfLabel( jumpToLabel );
							return jumpToFrame;
						}
						case "LOOP":
						{
							return currentFrame;
						}
					}
				}

			}

			// check if current frame is the last frame
			if ( getSequenceFrameFromAtlasFrame( currentFrame ) == _sequenceFrameCount - 1 )
			{
				if ( loop )
				{
					return getNthFrame( 0 );
				}
				else
				{
					return currentFrame;
				}
			}

			// just continue
			return currentFrame + 1;
		}


		public function addFrame( sequenceFrame:int, atlasFrame:uint, label:String, frameSize:Point, regPoint:Point ):void
		{
			while ( sequenceFrame >= _sequenceFrameCount )
			{
				_labels.push( null );
				_atlasFrames.push( -1 );
				_frameSizes.push( null );
				_regPoints.push( null );
				_sequenceFrameCount++;
			}

			_labels[ sequenceFrame ] = label;
			_atlasFrames[ sequenceFrame ] = atlasFrame;
			_frameSizes[ sequenceFrame ] = frameSize;
			_regPoints[ sequenceFrame ] = regPoint;

		}


		/**
		 * Returns the atlas frame of a label
		 */
		public function getFrameOfLabel( label:String ):int
		{
			for ( var i:int = 0; i < _sequenceFrameCount; i++ )
			{
				if ( _labels[ i ] == label )
				{
					return _atlasFrames[ i ];
				}
			}

			return -1;
		}


		private function getLabelOfFrame( atlasFrame:int ):String
		{
			var sequenceFrame:int = getSequenceFrameFromAtlasFrame( atlasFrame );
			return _labels[ sequenceFrame ];
		}


		public function getNthFrame( n:uint ):uint
		{
			return _atlasFrames[ n ];
		}


		public function getFrameCount():int
		{
			return _sequenceFrameCount;
		}


		public function getName():String
		{
			return _name;
		}


		private function getSequenceFrameFromAtlasFrame( atlasFrame:int ):int
		{
			var index:int = _atlasFrames.indexOf( atlasFrame );

			if ( index == -1 )
			{
				throw new Error( "No sequence frame frame found for atlasframe: " + atlasFrame );
			}
			return index;
		}


		public function getSizeOfFrame( atlasFrame:uint ):Point
		{
			var sequenceFrame:int = getSequenceFrameFromAtlasFrame( atlasFrame );
			return _frameSizes[ sequenceFrame ];
		}


		public function getRegpointOfFrame( atlasFrame:uint ):Point
		{
			var sequenceFrame:int = getSequenceFrameFromAtlasFrame( atlasFrame );
			return _regPoints[ sequenceFrame ];
		}

	}
}
