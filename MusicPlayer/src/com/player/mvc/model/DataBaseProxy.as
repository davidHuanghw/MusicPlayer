package com.player.mvc.model
{
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class DataBaseProxy extends Proxy {
		public static const NAME:String = "DataBaseProxy";
		
		public function DataBaseProxy(data:Object=null) {
			super(NAME, data);
		}
		
	}
}