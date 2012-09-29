package com.player.mvc.core
{
	import com.player.mvc.controls.LoadLrcCommand;
	import com.player.mvc.controls.MusicControlCommand;
	import com.player.mvc.controls.StartUpCommand;
	import com.player.mvc.model.ConstData;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	/**
	 * facade注册类。 
	 * @author davidhuang
	 * 
	 */	
	public class AppFacade extends Facade implements IFacade {
		
		protected static var appInstance:AppFacade;
		
		public function AppFacade() {
			super();
		}
		
		public static function getInstance():AppFacade {
			if( appInstance == null ) {
				appInstance = new AppFacade();
			}
			return appInstance;
		}
		
		override protected function initializeController():void {
			super.initializeController();
			
			this.registerCommand( ConstData.STARTUP, 		StartUpCommand );
			this.registerCommand( ConstData.MUSIC_CONTROL,	MusicControlCommand );
			this.registerCommand( ConstData.LOADLRC, 		LoadLrcCommand);
 		}
				
		public function startup( app:MusicPlayer ):void {
			this.sendNotification( ConstData.STARTUP, app );
		}	
	}
}