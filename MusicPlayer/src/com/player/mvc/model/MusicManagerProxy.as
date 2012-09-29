package com.player.mvc.model
{
	import com.player.mvc.utils.*;
	import com.player.mvc.vo.Music;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.ID3Info;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class MusicManagerProxy extends Proxy {
		
		public static const NAME:String = "MusicManagerProxy";
		
		private var _musicLoopProxy:MusicLoopProxy;
		private var _soundChannel:SoundChannel;
		private var _soundRequest:URLRequest;
		private var _sound:Sound;
		private var _isPlaying:Boolean;
		private var _soundTransForm:SoundTransform;
		private var _currentVolume:Number = .8;
		private var _timer:Timer;
		private var _stopFlag:Boolean = false;
		
		public var currentMusic:Music;//当前正在播放的music
		
		public function MusicManagerProxy(data:Object=null) {
			super(NAME, data);
			_timer			= new Timer( 10, 0 );
		}
		
		public function loadMusic( music:Music ):void {
			if( _isPlaying ) {
				stopMusic();
			}	
			currentMusic = music;
			_sound		  = new Sound();
			_soundRequest = new URLRequest( music.path );
			addLoadEvent();
			_sound.load( _soundRequest );
			_isPlaying = true;
		}	
		
		private function addLoadEvent():void {
			_sound.addEventListener(Event.COMPLETE,loadSoundCompelte);
			_sound.addEventListener(Event.ID3,updateID3Info);
		}
		
		private function loadSoundCompelte( event:Event ):void {
			_stopFlag 	  = true;
			_soundChannel = _sound.play();
			setVolume( _currentVolume );
			_soundChannel.addEventListener(Event.SOUND_COMPLETE, playSoundComplete);
			facade.sendNotification( ConstData.MUSIC_START_PLAY, _sound );
			_timer.addEventListener( TimerEvent.TIMER, timerHandler);
			_timer.start();
		}
		
		private function playSoundComplete( event:Event ):void {
			_musicLoopProxy = facade.retrieveProxy( MusicLoopProxy.NAME ) as MusicLoopProxy;
			if( _musicLoopProxy.isLoop == false ) {
				facade.sendNotification( ConstData.CONTROL_NEXT_MUSIC );
			}
		}	
		
		public function playMusic( value:Number ):void {
			if(!_sound.length)	
				return;
			_soundChannel = _sound.play( _sound.length * value );
			if( _soundTransForm != null ) {
				_soundChannel.soundTransform = _soundTransForm;
			}
			_soundChannel.addEventListener(Event.SOUND_COMPLETE,playSoundComplete);
			_timer.start();
		}
		
		public function pauseMusic():void {
			_soundChannel.stop();
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE,playSoundComplete);
			_timer.stop();
		}
		
		private function timerHandler( event:TimerEvent=null ):void {
			var timeObject:Object = new Object;
			timeObject.position = _soundChannel.position;
			timeObject.length = _sound.length;
			facade.sendNotification( ConstData.CONTROL_PROGRESS_MUSIC, timeObject );
		}
		
		public function setVolume(value:Number):void {
			_currentVolume 					= value;
			_soundTransForm 				= _soundChannel.soundTransform;
			_soundTransForm.volume 			= _currentVolume;
			_soundChannel.soundTransform 	= _soundTransForm;
		}
		
		private function updateID3Info( event:Event ):void {
			if(_sound.id3 == null || _sound.length < 10000) {
				return;
			}
			currentMusic.id3 = _sound.id3;

			var currentMusicID3:ID3Info = currentMusic.id3;
			var artist:String = currentMusicID3.artist;
			var songName:String = currentMusicID3.songName;
			if(artist == null || songName == null) {
				return;
			}
			artist = UTF8Util.encodeUtf8(currentMusicID3.artist);
			songName = UTF8Util.encodeUtf8(currentMusicID3.songName);
			
			currentMusic.id3.artist = artist;
			currentMusic.id3.songName = songName;
			
			artist = artist == ""? "未知歌手" : artist;
			songName = songName == ""? "未知歌曲" : songName;
			currentMusic.label = artist + " - " + songName;
			currentMusic.timeLabel = Util.lengthToString( _sound.length );
			
			facade.sendNotification( ConstData.UPDATA_MUSIC_ID3, currentMusic );
		}
		
		public function stopMusic():void {
			_isPlaying = false;			
			if( _stopFlag ) {	
				_soundChannel.removeEventListener(Event.SOUND_COMPLETE,playSoundComplete);
				_sound.removeEventListener(Event.COMPLETE,loadSoundCompelte);
				_sound.removeEventListener(Event.ID3,updateID3Info);		
				_soundChannel.stop();
				_soundChannel = new SoundChannel();
				timerHandler( null );
				_timer.stop();	
			}
		}

		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		public function set isPlaying(value:Boolean):void
		{
			_isPlaying = value;
		}

			
	}
}