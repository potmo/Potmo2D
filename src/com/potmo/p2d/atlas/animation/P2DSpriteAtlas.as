package com.potmo.p2d.atlas.animation
{
	import flash.geom.Point;

	public class P2DSpriteAtlas implements SpriteAtlas
	{

		private var _sequences:Vector.<P2DSpriteAtlasSequence>;
		private var _sequenceCount:uint;


		public function P2DSpriteAtlas( sequenceFrames:Vector.<int>, names:Vector.<String>, labels:Vector.<String>, frameSizes:Vector.<Point> )
		{

			_sequences = new Vector.<P2DSpriteAtlasSequence>();
			_sequenceCount = 0;

			createSequences( sequenceFrames, names, labels, frameSizes );

		}


		/**
		 * @returns a entry or null
		 */
		public function getSequenceByName( name:String ):SpriteAtlasSequence
		{

			var sequence:P2DSpriteAtlasSequence = getP2DSequenceByName( name );

			if ( !sequence )
			{
				throw new Error( "No sequence founds called: " + name );
			}

			return sequence;
		}


		private function getP2DSequenceByName( name:String ):P2DSpriteAtlasSequence
		{

			for ( var i:int = 0; i < _sequenceCount; i++ )
			{
				var sequence:P2DSpriteAtlasSequence = _sequences[ i ];

				if ( sequence.getName() == name )
				{
					return sequence;
				}
			}

			return null;
		}


		private function createSequences( sequenceFrames:Vector.<int>, names:Vector.<String>, labels:Vector.<String>, frameSizes:Vector.<Point> ):void
		{
			var length:int = names.length;

			for ( var i:int = 0; i < length; i++ )
			{

				var sequenceName:String = names[ i ];
				var sequenceFrame:int = sequenceFrames[ i ]
				var label:String = labels[ i ];

				var sequence:P2DSpriteAtlasSequence = getP2DSequenceByName( sequenceName );

				if ( !sequence )
				{
					sequence = createSequence( sequenceName );
				}
				var frameSize:Point = frameSizes[ i ];

				sequence.addFrame( sequenceFrame, i, label, frameSize );

			}
		}


		private function createSequence( name:String ):P2DSpriteAtlasSequence
		{
			var sequence:P2DSpriteAtlasSequence = new P2DSpriteAtlasSequence( name );
			_sequences.push( sequence );
			_sequenceCount++;
			return sequence;
		}

	}
}
