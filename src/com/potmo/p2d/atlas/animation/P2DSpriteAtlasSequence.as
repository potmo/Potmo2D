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
		private var _atlasId:int;
		private var _sequenceFrameCount:int;
		private var _labels:Vector.<String>;
		private var _atlasFrames:Vector.<uint>;
		private var _sequenceOffsetInAtlas:uint;
		private var _frameSize:Vector.<Point>;


		public function P2DSpriteAtlasSequence( atlas:int, name:String )
		{
			_atlasId = atlas;
			_name = name;
			_labels = new Vector.<String>();
			_atlasFrames = new Vector.<uint>();
			_frameSize = new Vector.<Point>();
			_sequenceFrameCount = 0;
		}


		/**
		 * Go to the next frame in the sequence
		 * @param currentFrame the current frame
		 * @param loop if next frame is the first frame when currentFrame is the last frame
		 * @param followLabelPointers if label pointers are enabled
		 * A label begining with GOTO_ will make the next frame the frame after the GOTO_
		 * A label begining with LOOP_ will make the next frame be the same frame as the currentFrame
		 *
		 * @return the next frame in the sequence
		 *
		 */
		public function getNextFrame( currentFrame:uint, loop:Boolean, followLabelPointers:Boolean ):uint
		{
			return currentFrame + 1;
		}


		public function addFrame( sequenceFrame:int, atlasFrame:uint, label:String, frameSize:Point ):void
		{
			while ( sequenceFrame >= _sequenceFrameCount )
			{
				_labels.push( null );
				_atlasFrames.push( -1 );
				_sequenceFrameCount++;
			}

			_labels[ sequenceFrame ] = label;
			_atlasFrames[ sequenceFrame ] = atlasFrame;
			_frameSize[ sequenceFrame ] = frameSize;

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


		public function getSizeOfFrame( frame:uint ):Point
		{
			//TODO: Convert frame to sequence frame
			return _frameSize[ frame ];
		}


		public function getAtlasId():uint
		{
			return _atlasId;
		}

	}
}
