package com.player.mvc.model
{
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class MusicLoopProxy extends Proxy {
		public static const NAME:String = "MusicLoopProxy";
		
		public static const LOOP_MUSIC:int = 1;
		public static const LOOP_LIST:int = 2;
		public static const LOOP_NONE:int = 3;
		
		public static const LANG_LOOP_MUSIC:String = "单曲循环";
		public static const LANG_LOOP_LIST:String = "顺序循环";
		public static const LANG_LOOP_NONE:String = "无循环";
		
		private var _type:int = LOOP_LIST;
		
		private var _isLoop:Boolean = false;
		
		public function MusicLoopProxy(data:Object=null) {
			super(NAME, data);
		}
		
		public function get type():int {
			return _type;
		}
		
		public function set type(ptype:int):void {
			if(ptype >= 0)_type = ptype;
		}
		
		public function get isLoop():Boolean {
			return _isLoop;
		}
		
		public function set isLoop(pisLoop:Boolean):void {
			if(pisLoop != _isLoop)_isLoop = pisLoop;
		}
		
		public function get label():String {
			var loopLang:String
			switch(_type)
			{
				case LOOP_MUSIC:
					loopLang = LANG_LOOP_MUSIC;
					break;
				case LOOP_LIST:
					loopLang = LANG_LOOP_LIST;	
					break;
				case LOOP_NONE:
					loopLang = LANG_LOOP_NONE;	
					break;
			}
			return LANG_LOOP_NONE;	
		}
		
	}
}