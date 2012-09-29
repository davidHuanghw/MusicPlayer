package com.player.mvc.vo
{
	import flash.media.ID3Info;
	
	[Bindable]
	public class Music {
		
		private var _path:String;
		private var _id3:ID3Info;//mp3的id3信息 包括演唱者 发行信息等
		private var _label:String;
		private var _index:int;
		private var _timeLabel:String;
		
		public function Music(fileIndex:int=0,filePath:String=null,fileLabel:String=null,fileTimeLabel:String=null,fileID3:ID3Info=null) {
			index = fileIndex;
			path = filePath;
			label = fileLabel;
			id3 = fileID3;
			timeLabel = fileTimeLabel;
		}
		
		public function set path(filePath:String):void {
			if(filePath != null) {
				_path = filePath;
			}
		}
		
		public function get path():String {
			return _path;
		}
		
		public function set id3(fileID3:ID3Info):void {
			if(fileID3 != null) {
				_id3 = fileID3;
			}
		}
		
		public function get id3():ID3Info {
			return _id3;
		}
		
		public function set index(pIndex:int):void {
			if(pIndex >= 0) {
				_index = pIndex;
			}
		}
		
		public function get index():int	{
			return _index;
		}
		
		public function set label(fileLabel:String):void {
			if(fileLabel != null) {
				_label = fileLabel;
			}
		}
		
		public function get label():String {
			return _label;
		}
		
		public function set timeLabel(fileTimeLabel:String):void {
			if(fileTimeLabel != null) {
				_timeLabel = fileTimeLabel;
			}
		}
		
		public function get timeLabel():String {
			return _timeLabel;
		}
	}
}