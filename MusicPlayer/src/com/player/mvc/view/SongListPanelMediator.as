package com.player.mvc.view
{
	import com.player.mvc.controls.FileCommand;
	import com.player.mvc.model.ConstData;
	import com.player.mvc.model.DataProxy;
	import com.player.mvc.model.MusicManagerProxy;
	import com.player.mvc.utils.ObjectTranslator;
	import com.player.mvc.view.ui.SongListPanel;
	import com.player.mvc.vo.Music;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.utils.ObjectUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class SongListPanelMediator extends Mediator implements IMediator {
		public static const NAME:String = "SongListPanelMediator";
		
		private var _dataProxy:DataProxy;
		private var _listCount:int;
		private var _curSelected:int = -1;//默认-1会有问题的。
		private var _musicManager:MusicManagerProxy;
		private var so:SharedObject = SharedObject.getLocal("MusicPlayer");;
		public function SongListPanelMediator(viewComponent:Object=null) {
			super(NAME, viewComponent);
			_dataProxy 		= facade.retrieveProxy( DataProxy.NAME ) as DataProxy;
			_musicManager	= facade.retrieveProxy( MusicManagerProxy.NAME ) as MusicManagerProxy;
			addListener();
			init();
		}
				
		private function get songListPanel():SongListPanel {
			return viewComponent as SongListPanel;
		}
		
		private function addListener():void {
			songListPanel.songList.addEventListener( NativeDragEvent.NATIVE_DRAG_ENTER, onDragIn );
			songListPanel.songList.addEventListener( NativeDragEvent.NATIVE_DRAG_DROP, onDragDrop );//从桌面拖放
			songListPanel.songList.addEventListener( ListEvent.ITEM_DOUBLE_CLICK, clickListItem );
			songListPanel.songList.addEventListener(MouseEvent.RIGHT_CLICK,onRightClick);
		}
		/**
		 * 初始化列表 
		 * @param evt
		 * 
		 */		
		private function init():void
		{
			so = SharedObject.getLocal("MusicPlayer");
			if(!so.data.musicList) return;
			var musicList:ArrayCollection = so.data.musicList;//共享对象中保存的列表
			for(var i:int=0;i<musicList.length;i++){
				var music:Music = ObjectTranslator.objectToInstance(musicList.getItemAt(i),Music) as Music;
				_dataProxy.musicList.addItem(music);
			}
			songListPanel.songList.dataProvider = _dataProxy.musicList;
		}
		/**
		 * 右键菜单 
		 * @param evt
		 * 
		 */		
		private function onRightClick(evt:MouseEvent):void
		{
			var item:Object = (evt.currentTarget as DataGrid).selectedItem;
			var _menuArr:Array = [];
			if(item){
				_menuArr = [{label:"添加", fun:addMusic},
					{label:"删除", fun:delMusic,data:item},
					{label:"清空列表", fun:cleanList}];
			}else{
				_menuArr = [{label:"添加", fun:addMusic},
					{label:"清空列表", fun:cleanList}];
			}
			
			createContextMenu(_menuArr);
		}
		/**
		 * 创建右键菜单 
		 * @param menuArray
		 * 
		 */		
		private function createContextMenu(menuArray:Array):void
		{		
			var len:int = menuArray.length;
			var menu:ContextMenu = new ContextMenu();
			for(var i:int=0;i<len;i++)
			{
				var menuItem:ContextMenuItem = new ContextMenuItem(menuArray[i].label);
				menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,menuArray[i].fun);				
				menu.items.push(menuItem);
			}
			songListPanel.songList.contextMenu = menu;
		}
		/**
		 * 右键添加音乐 
		 * 
		 */		
		private function addMusic(evt:ContextMenuEvent):void
		{
			var fileCom:FileCommand = new FileCommand();
			var array:Array = fileCom.addSelect(true,_dataProxy,callBackFunc);
		}
		private function callBackFunc(array:Array):void
		{
			if(array.length>0){
				facade.sendNotification( ConstData.ADD_MUSIC_FROM_FILE_LIST, array );
			}
		}
		/**
		 * 右键删除音乐 
		 * @param array
		 * 
		 */		
		private function delMusic(evt:ContextMenuEvent):void
		{
			var musics:ArrayCollection = new ArrayCollection(songListPanel.songList.selectedItems);
			if(musics){
				facade.sendNotification( ConstData.REMOVE_MUSIC_FROM_FILE_LIST, musics );
			}
		}
		/**
		 * 右键清空列表 
		 * 
		 */		
		private function cleanList(evt:ContextMenuEvent):void
		{
			var array:ArrayCollection = _dataProxy.musicList;
			if(!array)	return;
			facade.sendNotification( ConstData.REMOVE_MUSIC_FROM_FILE_LIST, array );
		}
		/**
		 * 拖到列表上 检查文件
		 * @param e
		 * 
		 */		
		private function onDragIn(e:NativeDragEvent):void {
			var filesInClip:Clipboard = e.clipboard;
			if(!filesInClip) return;
			if(filesInClip.hasFormat( ClipboardFormats.FILE_LIST_FORMAT)) {
				NativeDragManager.acceptDragDrop(e.target as InteractiveObject);
				NativeDragManager.dropAction = NativeDragActions.MOVE; 
			}
		}
		/**
		 * 添加拖放文件 
		 * @param e
		 * 
		 */			
		private function onDragDrop(e:NativeDragEvent):void {
			var filesArray:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;//获取拖动的文件
			if(!filesArray) return;
			var mp3Array:Array = [];
			var musicID:int;
			//计算musicID。若列表为空则=1，否则为当前文件数量加1
			if(_dataProxy.musicList.length==0){
				musicID = 1;
			}else{
				musicID = _dataProxy.musicList.length + 1;
			}
			for(var i:Object in filesArray) {
				var file:File = filesArray[i];
				if(file.extension == "mp3")	{
					var mp3File:Music = new Music( musicID, file.nativePath, file.name, "00:00");
					mp3Array.push(mp3File);
					musicID ++;
				}
			}
			facade.sendNotification( ConstData.ADD_MUSIC_FROM_FILE_LIST,mp3Array );//添加到播放列表
			//发送播放消息
			//facade.sendNotification( ConstData.OPEN_MUSIC_FROM_FILE_LIST, mp3Array );
		}
		/**
		 * 双击文件
		 * @param event
		 * 
		 */		
		private function clickListItem( event:ListEvent ):void {
			if(_musicManager.currentMusic == songListPanel.songList.selectedItem as Music)
				return;
			//_curSelected = songListPanel.songList.selectedIndex;
			facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:"select", value:songListPanel.songList.selectedItem  } );
		}
		/**
		 * 观察消息 
		 * @return array
		 * 
		 */		
		override public function listNotificationInterests():Array {
			return [
				ConstData.ADD_MUSIC_FROM_FILE_LIST,
				ConstData.OPEN_MUSIC_FROM_FILE_LIST,
				ConstData.REMOVE_MUSIC_FROM_FILE_LIST,
				ConstData.CONTROL_NEXT_MUSIC,
				ConstData.CONTROL_PREV_MUSIC
			];
		}
		/**
		 * 处理消息 
		 * @param notification
		 * 
		 */		
		override public function handleNotification(notification:INotification):void {
			switch( notification.getName() ) {
				case ConstData.ADD_MUSIC_FROM_FILE_LIST:
					addToListData( notification.getBody() as Array );
				break;
				case ConstData.OPEN_MUSIC_FROM_FILE_LIST:
					addToListData( notification.getBody() as Array );
				break;
				case ConstData.CONTROL_NEXT_MUSIC:
					nextMusicHandler();
				break;
				case ConstData.CONTROL_PREV_MUSIC:
					prevMusicHandler();
				break;
				case ConstData.REMOVE_MUSIC_FROM_FILE_LIST:
					removeMusicFromList( notification.getBody() as ArrayCollection );
				break;
			}
		}
		/**
		 * 加入列表 
		 * @param list
		 * 
		 */		
		private function addToListData( list:Array ):void {
			/*检查是否已经存在同名文件*/
			if(list.length == 0) return;
			for( var i:int=0;i<_dataProxy.musicList.length;i++ )
			{
				var music:Music =  _dataProxy.musicList[i] as Music;
				if(music)
				{
					for ( var p:int=0;p<list.length;p++ ){
						if(!(list[p] is Music))		
							return;
						if(	music.label == (list[p] as Music).label )	//同名文件 
						{
							list.splice(p,1);
							p --;
						}	
					}
				}
			}
			/*添加到列表中*/
			_dataProxy.musicList.source = _dataProxy.musicList.source.concat( list );
			//保存到共享对象
			so = SharedObject.getLocal("MusicPlayer");
			so.data.musicList = _dataProxy.musicList;
			_listCount				+= list.length;
			songListPanel.songList.dataProvider = _dataProxy.musicList;
			updateMusicIndex();
		}
		/**
		 * 添加选择的文件 
		 * @param list
		 * 
		 */		
	/*	private function setListData( list:Array ):void {
			if(!list) return;
			_dataProxy.musicList.concat( list );
			_listCount				+= list.length;
				(songListPanel.songList.dataProvider ;
			}
		}*/
		/**
		 * 播放下首歌曲 
		 * 
		 */		
		private function nextMusicHandler():void {
			if(songListPanel.songList.selectedIndex == _listCount - 1) {
				songListPanel.songList.selectedIndex = _listCount - 1;
			} else {
				songListPanel.songList.selectedIndex ++;
			}
			
			if( songListPanel.songList.selectedIndex > songListPanel.songList.rowCount ) {
				songListPanel.songList.scrollToIndex( songListPanel.songList.selectedIndex - songListPanel.songList.rowCount + 1 );
			}
			facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:"select", value:songListPanel.songList.selectedItem} );
		}
		
		private function prevMusicHandler():void {	
			if( songListPanel.songList.selectedIndex == 0 ) {
				songListPanel.songList.selectedIndex = 0;
			} else {
				songListPanel.songList.selectedIndex --;
			}
			songListPanel.songList.scrollToIndex( songListPanel.songList.selectedIndex );
			facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:"select", value:songListPanel.songList.selectedItem} );
		}
		/**
		 * 从列表中移除文件
		 * @param removeMusic
		 * 
		 */		
		private function removeMusicFromList( removeMusics:ArrayCollection ):void {
			if( !removeMusics )	return;
			for( var i:int=0;i<_dataProxy.musicList.length;i++ ) {
				var music:Music = _dataProxy.musicList[i];
				for( var c:int=0;c<removeMusics.length;c++ ){
					if( music.label == (removeMusics[c] as Music).label) {	//根据同名文件名删除
						//以下在循环中删除数组元素会导致不能完全遍历数组元素。必须重置i=0
						//_dataProxy.musicList.splice(i,1);
						_dataProxy.musicList.removeItemAt(i);
						removeMusics.removeItemAt(c);
						c --;
						i --
						break;
					}
				}
			}
			updateMusicIndex();
			//保存到共享对象
			so = SharedObject.getLocal("MusicPlayer");
			so.data.musicList = _dataProxy.musicList;
			songListPanel.songList.dataProvider = _dataProxy.musicList;
			/*if( _dataProxy.musicList.length != 0 ) {
				facade.sendNotification( ConstData.CONTROL_NEXT_MUSIC );//显示下首歌曲信息
			} else {
				_musicManager.currentMusic = null;
				facade.sendNotification( ConstData.MUSIC_CONTROL, {flag:"remove", value:null} );
			}*/
		}
		
		private function updateMusicIndex():void
		{
			var i:int=1;
			for each(var music:Music in _dataProxy.musicList)
			{
				music.index = i;
				i++;
			}	
		}
		public function getSelectedItem():Music
		{
			if(songListPanel.songList.selectedItem!=null){
				var music:Music = songListPanel.songList.selectedItem as Music;
				return music;
			}
			return null;
		}
		public function getSelectedItems():Array
		{
			if(songListPanel.songList.selectedItem!=null){
				var musics:Array = songListPanel.songList.selectedItems as Array;
				return musics;
			}
			return null;
		}
	}
}