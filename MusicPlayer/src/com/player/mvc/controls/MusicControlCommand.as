package com.player.mvc.controls
{
	import com.player.mvc.model.MusicManagerProxy;
	import com.player.mvc.vo.Music;
	import com.player.mvc.vo.Status;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class MusicControlCommand extends SimpleCommand implements ICommand {
		private var _musicManager:MusicManagerProxy;
		
		public function MusicControlCommand()
		{
			super();
		}
		
		override public function execute(notification:INotification):void {
			_musicManager = facade.retrieveProxy( MusicManagerProxy.NAME ) as MusicManagerProxy;
			var flag:String 	= notification.getBody().flag as String;
			var value:*			= notification.getBody().value;
			switch(flag) {
				case Status.SELECT:
					loadMusicAndPlay( value );
				break;
				case Status.PLAY:
					play( value );
				break;
				case Status.PAUSE:
					pause();
				break;
				case Status.STOP:
					stop();
				break;
				case Status.VOLUM:
					trace( "volume" );
					changeValume( value );
				break;
			}
		}	
		
		private function loadMusicAndPlay( value:Music ):void {
			if( value != null ) {
				_musicManager.loadMusic( value );
			}
		}	
		
		private function play( value:Number ):void {
			_musicManager.playMusic( value );
		}
		
		private function pause():void {
			_musicManager.pauseMusic();
		}
		
		private function changeValume( value:Number ):void {
			trace("setValue = ", value);
			_musicManager.setVolume( value );
		}
		
		private function stop():void {
			_musicManager.stopMusic();
		}
	}
}