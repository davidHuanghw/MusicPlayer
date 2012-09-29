/**
 * $Id: SysTrayMgr.as 3589 2011-04-18 06:20:53Z davidhuang $
 * */
package com.player.mvc.utils
{
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Loader;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.core.WindowedApplication;
	
	/**
	 * 最小化至托盤區功能類
	 * @author kenhu
	 * 
	 */	
	public final class SysTrayMgr
	{
		/**托盤區對象**/
		private static var viewComponent:WindowedApplication;
		/**圖標**/
		private static const trayIconUri:String = "/style/icon/appIcon16.png";
		/**標題**/
		private static const trayTitle:String = "MP3播放器";
		
		/**
		 * 最小化至托盤
		 * @param p_component
		 * 
		 */		
		public static function minimize(p_component:WindowedApplication):void
		{
			viewComponent = p_component;
			if(viewComponent){
				//創建托盤區圖標
				createTrayIcon();
				//隱藏窗口
				viewComponent.stage.nativeWindow.visible = false;
			}
		}
		
		/**
		 * 還原窗口
		 * @param evt
		 * 
		 */			
		private static function restore(evt:Event):void
		{
			evt.currentTarget.removeEventListener(evt.type, restore);
			//還原窗口並置前
			if(!viewComponent.stage.nativeWindow.visible){
				NativeApplication.nativeApplication.icon.bitmaps = [];
				viewComponent.stage.nativeWindow.visible = true;   
				viewComponent.stage.nativeWindow.restore();
				viewComponent.stage.nativeWindow.orderToFront();//窗口置顶
			}
		}
		
		/**
		 * 關閉窗口
		 * @param evt
		 * 
		 */			
		private static function close(evt:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * 創建托盤區圖標
		 * 
		 */		
		private static function createTrayIcon():void
		{
			var icon:Loader = new Loader();
			icon.contentLoaderInfo.addEventListener(Event.COMPLETE, iconLoadComplete); 
			icon.load(new URLRequest(trayIconUri));
			
			// windows 托盤圖標			
			if (NativeApplication.supportsSystemTrayIcon) {
				var systray:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon; 
				systray.tooltip = trayTitle;
				systray.menu = iconMenu;
				systray.addEventListener(MouseEvent.CLICK, restore); 
			} 
			
			// MAC 狀態欄圖標			
			if (NativeApplication.supportsDockIcon){
				var dock:DockIcon = NativeApplication.nativeApplication.icon as DockIcon; 
				dock.menu = iconMenu;
				dock.addEventListener(MouseEvent.CLICK, restore);
			}
		}
		
		/**
		 * 圖標加載完成回調函數
		 * @param evt
		 * 
		 */		
		private static function iconLoadComplete(evt:Event):void
		{
			evt.currentTarget.removeEventListener(Event.COMPLETE, iconLoadComplete);
			NativeApplication.nativeApplication.icon.bitmaps = [evt.target.content.bitmapData];
		}
		
		/**
		 * 生成右鍵菜單
		 * @return 
		 * 
		 */		
		private static function get iconMenu():NativeMenu
		{
			var iconMenu:NativeMenu = new NativeMenu(); 
			var restoreCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("显示主界面")); 
			restoreCommand.addEventListener(Event.SELECT, restore);
			var exitCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("关闭"));
			exitCommand.addEventListener(Event.SELECT, close);
			return iconMenu;
		}
	}
}