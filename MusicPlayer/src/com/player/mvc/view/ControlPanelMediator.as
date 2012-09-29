package com.player.mvc.view
{
	import com.player.mvc.controls.FileCommand;
	import com.player.mvc.model.ConstData;
	import com.player.mvc.model.DataProxy;
	import com.player.mvc.model.MusicLoopProxy;
	import com.player.mvc.model.MusicManagerProxy;
	import com.player.mvc.utils.Util;
	import com.player.mvc.view.ui.ControlPanel;
	import com.player.mvc.vo.Music;
	import com.player.mvc.vo.Status;
	
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.media.Sound;
	
	import mx.core.FlexGlobals;
	import mx.events.SliderEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ControlPanelMediator extends Mediator implements IMediator {
		
		public static const NAME:String = "ControlPanelMediator";
		public static const PLAY_BUTTON_STYLE_NAME:String = "playButton";
		public static const PAUSE_BUTTON_STYLE_NAME:String = "pauseButton";
	 		
		public var playButtonCurrentStyle:String = PLAY_BUTTON_STYLE_NAME;
		
		private var fileToOpen:File;
		private var _dataProxy:DataProxy;
		private var _musicManager:MusicManagerProxy;
		private var _loopManager:MusicLoopProxy;
		
		public function ControlPanelMediator(viewComponent:Object=null) {
			super(NAME, viewComponent);
			_dataProxy 		= facade.retrieveProxy( DataProxy.NAME ) as DataProxy;
			_musicManager	= facade.retrieveProxy( MusicManagerProxy.NAME ) as MusicManagerProxy;//获取当前的MusicManagerProxy
			_loopManager	= facade.retrieveProxy( MusicLoopProxy.NAME ) as MusicLoopProxy;
			addListener();
			initView();
		}
		
		private function initView():void {
			controlPanel.playButton.styleName = playButtonCurrentStyle;
		}
		
		private function get controlPanel():ControlPanel {
			return viewComponent as ControlPanel ;
		}
		
		private function addListener():void {
			controlPanel.addButton.addEventListener( MouseEvent.CLICK, onAddHandler);
			controlPanel.playButton.addEventListener( MouseEvent.CLICK, playHandler);
			controlPanel.progressBar.addEventListener( MouseEvent.MOUSE_DOWN, progressBarMouseDown);
			controlPanel.progressBar.addEventListener( MouseEvent.MOUSE_UP, progressBarMouseUp);
			controlPanel.volumeControl.addEventListener( SliderEvent.CHANGE, changeVolume );
			controlPanel.stopButton.addEventListener( MouseEvent.CLICK, stopHandler );
			controlPanel.openFileButton.addEventListener( MouseEvent.CLICK, openFileHandler);
			controlPanel.prevButton.addEventListener( MouseEvent.CLICK, pervHandler);
			controlPanel.nextButton.addEventListener( MouseEvent.CLICK, nextHandler);
			controlPanel.sounfOffButton.addEventListener( MouseEvent.CLICK, soundOffHandler);
			controlPanel.removeButton.addEventListener( MouseEvent.CLICK, removeMusicHandler);
			controlPanel.loopButton.addEventListener( MouseEvent.CLICK, loopMusicHandler);
			
		}
		
		private function onAddHandler( event:MouseEvent ):void {
			addMusic( true );
		}
		/**
		 * 选择文件 
		 * @param isAdd
		 * 
		 */		
		/**
		 * 添加音乐 
		 * 
		 */		
		private function addMusic(isAdd:Boolean):void
		{
			var fileCom:FileCommand = new FileCommand();
			var array:Array = fileCom.addSelect(isAdd,_dataProxy,callBackFunc);
		}
		private function callBackFunc(array:Array):void
		{
			if(array.length>0){
				facade.sendNotification( ConstData.ADD_MUSIC_FROM_FILE_LIST, array );
			}
		} 
		/*private function addSelect( isAdd:Boolean ):void {
			fileToOpen = new File();
			var textFileFilter:FileFilter = new FileFilter("音乐文件(*.mp3,*.wma)","*.mp3;*.wma");//过滤文件
			fileToOpen.browseForOpenMultiple("添加音乐",[textFileFilter]);
			if( isAdd ) {
				fileToOpen.addEventListener(FileListEvent.SELECT_MULTIPLE,addMusic);
			} else {
				fileToOpen.addEventListener(FileListEvent.SELECT_MULTIPLE,fileSelected);
			}
		}
		
		private function addMusic( event:FileListEvent ):void {
			var fileListArray:Array = event.files;
			var newMusicArray:Array	= new Array();
			var currentLen:int		= _dataProxy.musicList.length;
			for(var i:Object in fileListArray) {
				var file:File = fileListArray[i];
				var music:Music = new Music(int(i) + currentLen + 1, file.nativePath, file.name, "00:00");
				newMusicArray.push( music );
			}
			facade.sendNotification( ConstData.ADD_MUSIC_FROM_FILE_LIST, newMusicArray );
		}
		
		private function fileSelected( event:FileListEvent ):void {
			var fileListArray:Array = event.files;		
			var n:int = _dataProxy.musicList.length;
			var newMusicArray:Array = new Array();			
			for(var i:Object in fileListArray) {
				var file:File = fileListArray[i];
				var music:Music = new Music(int(i) + n + 1,file.nativePath,file.name,"00:00");
				newMusicArray.push(music);
			}
			facade.sendNotification( ConstData.OPEN_MUSIC_FROM_FILE_LIST, newMusicArray );	
		}*/
		
		private function playHandler( event:MouseEvent):void {
			trace("currentMusic = ",  _musicManager.currentMusic );
			if( _musicManager.currentMusic != null ) {
				if( playButtonCurrentStyle == PLAY_BUTTON_STYLE_NAME ) {
					playButtonCurrentStyle = PAUSE_BUTTON_STYLE_NAME;	
					controlPanel.playButton.styleName = PAUSE_BUTTON_STYLE_NAME;
					facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:Status.PLAY, value:controlPanel.progressBar.value} );
				} else {
					playButtonCurrentStyle = PLAY_BUTTON_STYLE_NAME;
					controlPanel.playButton.styleName = PLAY_BUTTON_STYLE_NAME;
					facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:Status.PAUSE, value:null} );
				}
			}else{
				var selectedItem:Music = (facade.retrieveMediator(SongListPanelMediator.NAME) as SongListPanelMediator).getSelectedItem();
				if(selectedItem!=null){	//列表选择了歌曲
					if( playButtonCurrentStyle == PLAY_BUTTON_STYLE_NAME ) {
						playButtonCurrentStyle = PAUSE_BUTTON_STYLE_NAME;	
						controlPanel.playButton.styleName = PAUSE_BUTTON_STYLE_NAME;
						facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:"select", value:selectedItem } );
					}
				}
			}
		}
		
		private function progressBarMouseDown( event:MouseEvent ):void {
			if( _musicManager.currentMusic != null ) {
				facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:Status.PAUSE, value:null} );
			}
		}
		
		private function progressBarMouseUp( event:MouseEvent ):void {
			if( _musicManager.currentMusic != null ) {				
				if(playButtonCurrentStyle == PAUSE_BUTTON_STYLE_NAME) {
					facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:Status.PLAY, value:controlPanel.progressBar.value} );
				}
			}
		}
		
		private function changeVolume( event:SliderEvent ):void {
			if( _musicManager.currentMusic != null ) {
				facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:Status.VOLUM, value:controlPanel.volumeControl.value} );	
			}
		}
		
		private function stopHandler( event:MouseEvent ):void {
			if( _musicManager.currentMusic != null ) {
				if( playButtonCurrentStyle == PAUSE_BUTTON_STYLE_NAME ) {
					playButtonCurrentStyle 				= PLAY_BUTTON_STYLE_NAME;
					controlPanel.playButton.styleName 	= PLAY_BUTTON_STYLE_NAME;
				}
				_musicManager.currentMusic = null;
				facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:Status.STOP, value:null} );
			}
		}
		
		private function openFileHandler( event:MouseEvent ):void {
			addMusic( false );
		}	
		
		private function pervHandler( event:MouseEvent ):void {
			if( _musicManager.currentMusic != null ) {
				facade.sendNotification( ConstData.CONTROL_PREV_MUSIC );
			}
		}	
		
		private function nextHandler( event:MouseEvent ):void {
			if( _musicManager.currentMusic != null ) {
				facade.sendNotification( ConstData.CONTROL_NEXT_MUSIC );
			}
		}	
		
		private function soundOffHandler( event:MouseEvent ):void {
			if( controlPanel.sounfOffButton.selected ) {
				controlPanel.volumeControl.value = 0;
			} else {
				controlPanel.volumeControl.value = .8;
			}
			changeVolume( null );
		}
		/**
		 * 移出音乐文件 
		 * @param event
		 * 
		 */		
		private function removeMusicHandler( event:MouseEvent ):void {
			var currentMusics:Array = (facade.retrieveMediator(SongListPanelMediator.NAME) as SongListPanelMediator).getSelectedItems();
			facade.sendNotification( ConstData.REMOVE_MUSIC_FROM_FILE_LIST, currentMusics );
		}
		/**
		 * 循环控制 
		 * @param event
		 * 
		 */		
		private function loopMusicHandler( event:MouseEvent ):void {
			if( controlPanel.loopButton.selected ) {
				_loopManager.isLoop = true;
				controlPanel.loopButton.toolTip = "单曲循环";
			} else {
				_loopManager.isLoop = false;
				controlPanel.loopButton.toolTip = "顺序循环";
			}
		}
		
		override public function listNotificationInterests():Array {
			return [
				ConstData.MUSIC_START_PLAY,
				ConstData.CONTROL_PROGRESS_MUSIC
			]
		}
		
		 override public function handleNotification(notification:INotification):void {
			switch( notification.getName() ) {
				case ConstData.MUSIC_START_PLAY:
					startPlay( notification.getBody() as Sound );	
				break;
				case ConstData.CONTROL_PROGRESS_MUSIC:
					controlProgressHandler( notification.getBody() );
				break;
			}
		}
		
		private function startPlay( _sound:Sound ):void {
			playButtonCurrentStyle = PAUSE_BUTTON_STYLE_NAME;	
			controlPanel.playButton.styleName = PAUSE_BUTTON_STYLE_NAME;	
		} 
		
		private function controlProgressHandler( obj:Object ):void {
			controlPanel.progressBar.value = obj.position/obj.length;
			controlPanel.timeLabel.text = Util.lengthToString(obj.position) + "/" + Util.lengthToString(obj.length);
		}	
	}
}