package com.player.mvc.controls
{
	import com.player.mvc.model.DataBaseProxy;
	import com.player.mvc.model.DataProxy;
	import com.player.mvc.model.MusicLoopProxy;
	import com.player.mvc.model.MusicManagerProxy;
	import com.player.mvc.view.ControlPanelMediator;
	import com.player.mvc.view.DisplayMediator;
	import com.player.mvc.view.LrcPanalMadiator;
	import com.player.mvc.view.SongListPanelMediator;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class StartUpCommand extends SimpleCommand implements ICommand
	{
		public function StartUpCommand() {
			trace("StartUpCommand");
			super();
		}
		
		override public function execute(notification:INotification):void {
			trace("execute");
			var app:MusicPlayer = notification.getBody() as MusicPlayer;
			/*注册proxy代理*/
			facade.registerProxy( new DataProxy() );
			facade.registerProxy( new DataBaseProxy() );
			facade.registerProxy( new MusicManagerProxy() );
			facade.registerProxy( new MusicLoopProxy() );
			/*注册mediator*/
			facade.registerMediator( new ControlPanelMediator( app.controlPanel ) );
			facade.registerMediator( new DisplayMediator( app.controlPanel.displayPanel ) );
			facade.registerMediator( new LrcPanalMadiator( app.lrcPanel ) );
			facade.registerMediator( new SongListPanelMediator( app.songListPanel ) );
		}	
	}
}