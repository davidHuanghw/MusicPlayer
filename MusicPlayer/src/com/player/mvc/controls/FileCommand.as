package com.player.mvc.controls
{
	import com.player.mvc.model.ConstData;
	import com.player.mvc.model.DataProxy;
	import com.player.mvc.model.MusicManagerProxy;
	import com.player.mvc.vo.Music;
	
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import org.puremvc.as3.patterns.facade.Facade;

	public class FileCommand
	{
		private var fileToOpen:File;
		private var _dataProxy:DataProxy;
		private var _musicManager:MusicManagerProxy;
		private var array:Array = [];
		private var callBackFunc:Function;
		/**
		 * 选择文件 
		 * @param isAdd
		 * 
		 */		
		public function addSelect( isAdd:Boolean,dataProxy:DataProxy,callBack:Function):Array {
			fileToOpen = new File();
			var textFileFilter:FileFilter = new FileFilter("音乐文件(*.mp3,*.wma)","*.mp3;*.wma");//过滤文件
			_dataProxy = dataProxy;
			fileToOpen.browseForOpenMultiple("添加音乐",[textFileFilter]);
			if( isAdd ) {
				fileToOpen.addEventListener(FileListEvent.SELECT_MULTIPLE,addMusic);
			} else {
				fileToOpen.addEventListener(FileListEvent.SELECT_MULTIPLE,fileSelected);
			}
			callBackFunc = callBack;
			return array;
		}
		
		private function addMusic( event:FileListEvent ):void {
			var fileListArray:Array = event.files;
			var newMusicArray:Array	= [];
			var currentLen:int		= _dataProxy.musicList.length;
			for(var i:Object in fileListArray) {
				var file:File = fileListArray[i];
				var music:Music = new Music(int(i) + currentLen + 1, file.nativePath, file.name, "00:00");
				newMusicArray.push( music );
			}
			array = newMusicArray;
			callBackFunc(array);
		}
		
		private function fileSelected( event:FileListEvent ):void {
			var fileListArray:Array = event.files;		
			var n:int = _dataProxy.musicList.length;
			var newMusicArray:Array = [];			
			for(var i:Object in fileListArray) {
				var file:File = fileListArray[i];
				var music:Music = new Music(int(i) + n + 1,file.nativePath,file.name,"00:00");
				newMusicArray.push(music);
			}
			array = newMusicArray;
			callBackFunc(array);
		}
	}
}