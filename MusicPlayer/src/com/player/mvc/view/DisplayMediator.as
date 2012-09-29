package com.player.mvc.view
{
	import com.player.mvc.model.ConstData;
	import com.player.mvc.model.MusicManagerProxy;
	import com.player.mvc.view.ui.DisplayPanel;
	import com.player.mvc.vo.Music;
	import com.player.mvc.vo.Status;
	
	import flash.display.Sprite;
	
	import mx.containers.Canvas;
	import mx.controls.DataGrid;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.primitives.Graphic;

	public class DisplayMediator extends Mediator implements IMediator {
		public static const NAME:String = "DisplayMediator";
		private var mask:UIComponent;
		public function DisplayMediator(viewComponent:Object=null) {
			super(NAME, viewComponent);
			initView();
		}
		
		private function initView():void {
			displayPanel.visualization.audioswitch(Status.PLAY);
			displayPanel.addEventListener(DragEvent.DRAG_DROP,onDragDrop);
			displayPanel.addEventListener(DragEvent.DRAG_ENTER,onDragEnter);
			displayPanel.addEventListener(DragEvent.DRAG_EXIT,onDragExit);
			displayPanel.addEventListener(DragEvent.DRAG_OVER,onDragOver);
		}
				
		public function get displayPanel():DisplayPanel {
			return viewComponent as DisplayPanel;
		}
				
		override public function listNotificationInterests():Array {
			return [
				ConstData.MUSIC_CONTROL,
				ConstData.UPDATA_MUSIC_ID3,
				ConstData.DISPLAY_ONE_LRC
			];
		}
		
		override public function handleNotification(notification:INotification):void {
			switch( notification.getName() ) {
				case ConstData.MUSIC_CONTROL:
					var flag:String = notification.getBody().flag;
					switch( flag ){
						case Status.SELECT:
							selectMusicHandler( notification.getBody().value as Music );
							break;
						case Status.PAUSE:
							pauseMusicHandler();
							break;
						case Status.STOP:
							stopMusicHandler();
							break;
						case Status.PLAY:
							playMusicHandler();
							break;
					}
				break;
				case ConstData.UPDATA_MUSIC_ID3:
					upDataMusicID3Handler( notification.getBody() as Music );
				break;
				case ConstData.DISPLAY_ONE_LRC:
					displayPanel.lrcLabel.htmlText = notification.getBody() as String;
				break;
			}
		}	
		/**
		 * 选择歌曲
		 * @param music
		 * 
		 */		
		private function selectMusicHandler( music:Music ):void {
			if( !music ) return;
			displayPanel.songNameLabel.text = music.label;
			displayPanel.artistLabel.text = "";
		}
		/**
		 * 更新id3 
		 * @param music
		 * 
		 */		
		private function upDataMusicID3Handler( music:Music ):void {
			if( !music ) return;
			displayPanel.songNameLabel.text = music.id3.songName;
			displayPanel.artistLabel.text 	= music.id3.artist;
		}
		
		/**
		 * stop
		 * 
		 */		
		private function stopMusicHandler():void
		{
			displayPanel.songNameLabel.text = "";
			displayPanel.artistLabel.text = "";
			displayPanel.lrcLabel.text = "";
			displayPanel.visualization.audioswitch(Status.STOP);
		}
		
		private function pauseMusicHandler():void
		{
			displayPanel.visualization.audioswitch(Status.PAUSE);
		}
		
		private function playMusicHandler():void
		{
			displayPanel.visualization.audioswitch(Status.PLAY);
		}
		
		private function onDragDrop(evt:DragEvent):void
		{
			if(mask)
				clearMask();
			var music:Music;
			music = (evt.dragInitiator as DataGrid).selectedItem as Music;
			facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:"select", value:music  } );
		}
		private function onDragEnter(evt:DragEvent):void
		{	
			if(!mask)
				addMask();
			var ui:DisplayPanel = DisplayPanel(evt.currentTarget);
			DragManager.acceptDragDrop(ui);
		}
		private function onDragExit(evt:DragEvent):void
		{
			clearMask();
		}
		private function onDragOver(evt:DragEvent):void
		{
			addMask();
		}
		private function addMask():void{
			if(mask) return;
			mask = new UIComponent();
			mask.graphics.clear();
			mask.graphics.beginFill(0xFF0000,.2);
			mask.graphics.drawRect(0,0,displayPanel.width,displayPanel.height);
			mask.graphics.endFill();
			displayPanel.addChild(mask);
		}
		private function clearMask():void
		{
			if(mask){
				mask.graphics.clear();
				displayPanel.removeChild(mask);
				mask = null;
			}	
		}
	}
}