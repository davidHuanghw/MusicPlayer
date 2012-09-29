package com.player.mvc.controls
{
	import com.player.mvc.model.ConstData;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class LoadLrcCommand extends SimpleCommand {
		private var urlLoad:URLLoader = new URLLoader();
		
		public function LoadLrcCommand() {
			super();
		}
		
		override public function execute(notification:INotification):void {
			var urlPath:String = notification.getBody() as String;
			//urlLoad.dataFormat = URLLoaderDataFormat.TEXT;
			System.useCodePage = true;
			urlLoad.addEventListener(IOErrorEvent.IO_ERROR, io_errorHandler);
			urlLoad.addEventListener(Event.COMPLETE, onCompleteHandler);
			urlLoad.load( new URLRequest( urlPath ) );
		}		
		
		private function io_errorHandler( event:IOErrorEvent ):void {
			trace("message = ", event.text);
			facade.sendNotification( ConstData.LOAD_LRC_COMPLETE, {label:false, value:null} );
		}
		
		private function onCompleteHandler( event:Event ):void {
			trace("onCompleteHandler");
			facade.sendNotification( ConstData.LOAD_LRC_COMPLETE, {label:true, value:event.target.data } );
		}	
	}
}