package com.potmo.p2d.atlas.animation
{
	import flash.geom.Point;

	public class P2DSpriteAtlas implements SpriteAtlas
	{

		private var _sequences:Vector.<P2DSpriteAtlasSequence>;
		private var _sequenceCount:uint;
		private var _atlasId:int;


		public function P2DSpriteAtlas( atlasId:int, names:Vector.<String>, frameSizes:Vector.<Point> )
		{

			_sequences = new Vector.<P2DSpriteAtlasSequence>();
			_sequenceCount = 0;

			createSequences( atlasId, names, frameSizes );
			_atlasId = atlasId;

		}


		/**
		 * @returns a entry or null
		 */
		public function getSequenceByName( name:String ):SpriteAtlasSequence
		{

			var sequence:P2DSpriteAtlasSequence = getP2DSequenceByName( name );

			if ( !sequence )
			{
				throw new Error( "No sequence founds called: " + name + " in atlasId: " + _atlasId );
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


		private function createSequences( atlasId:uint, names:Vector.<String>, frameSizes:Vector.<Point> ):void
		{
			var length:int = names.length;

			for ( var i:int = 0; i < length; i++ )
			{
				var name:String = names[ i ];

				// a frame name should be formatted as
				// spritename/00001_label.png

				var spriteFrameSplit:int = name.indexOf( "/" );

				if ( spriteFrameSplit == -1 )
				{
					throw new Error( "can not parse name: " + name + " it does not contain slash" );
				}

				var frameLabelSplit:int = name.indexOf( "_" );

				if ( frameLabelSplit == -1 )
				{
					throw new Error( "can not parse name " + name + " it does not contain underscore" );
				}

				var frameLabelEnd:int = name.lastIndexOf( "." );

				if ( frameLabelEnd == -1 )
				{
					frameLabelEnd = int.MAX_VALUE;
				}

				var sequenceName:String = name.substring( 0, spriteFrameSplit );
				var sequenceFrame:int = parseInt( name.substring( spriteFrameSplit + 1, frameLabelSplit ) );
				var label:String = name.substring( frameLabelSplit + 1, frameLabelEnd );

				var sequence:P2DSpriteAtlasSequence = getP2DSequenceByName( sequenceName );

				if ( !sequence )
				{
					sequence = createSequence( atlasId, sequenceName );
				}
				var frameSize:Point = frameSizes[ i ];

				sequence.addFrame( sequenceFrame, i, label, frameSize );

			}
		}


		private function createSequence( atlas:int, name:String ):P2DSpriteAtlasSequence
		{
			var sequence:P2DSpriteAtlasSequence = new P2DSpriteAtlasSequence( atlas, name );
			_sequences.push( sequence );
			_sequenceCount++;
			return sequence;
		}

	}
}
