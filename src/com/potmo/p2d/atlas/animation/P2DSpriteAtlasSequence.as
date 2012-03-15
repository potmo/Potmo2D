package com.potmo.p2d.atlas.animation
{

	public class P2DSpriteAtlasSequence
	{
		private var _name:String;
		private var _atlas:int;
		private var _sequenceFrameCount:int;
		private var _labels:Vector.<String>;
		private var _atlasFrames:Vector.<uint>;


		public function P2DSpriteAtlasSequence( atlas:int, name:String )
		{
			_atlas = atlas;
			_name = name;
			_labels = new Vector.<String>();
			_atlasFrames = new Vector.<uint>();
			_sequenceFrameCount = 0;
		}


		public function addFrame( sequenceFrame:int, atlasFrame:uint, label:String ):void
		{
			while ( sequenceFrame >= _sequenceFrameCount )
			{
				_labels.push( null );
				_atlasFrames.push( -1 );
				_sequenceFrameCount++;
			}

			_labels[ sequenceFrame ] = label;
			_atlasFrames[ sequenceFrame ] = atlasFrame;

		}


		/**
		 * Returns the sequence frame of the label
		 */
		public function getSequenceFrameOfLabel( label:String ):int
		{
			for ( var i:int = 0; i < _sequenceFrameCount; i++ )
			{
				if ( _labels[ i ] == label )
				{
					return i;
				}
			}

			return -1;
		}


		public function getAtlasFrameOfSequenceFrame( sequenceFrame:int ):int
		{
			return _atlasFrames[ sequenceFrame ];
		}


		public function getFrameCount():int
		{
			return _sequenceFrameCount;
		}


		public function getName():String
		{
			return _name;
		}
	}
}
