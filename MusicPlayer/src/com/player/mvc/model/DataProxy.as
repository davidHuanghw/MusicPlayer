package com.player.mvc.model
{
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class DataProxy extends Proxy {
		public static const NAME:String = "DataProxy";
		
		private var _musicList:ArrayCollection = new ArrayCollection();
		
		public function DataProxy(data:Object=null) {
			super(NAME, data);
		}
		
		[Bindable]
		public function get musicList():ArrayCollection {
			return _musicList;
		} 
		
		public function set musicList( v:ArrayCollection ):void {
			_musicList = v;
		}
	}
}