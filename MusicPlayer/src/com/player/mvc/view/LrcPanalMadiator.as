package com.player.mvc.view
{
	import com.player.mvc.model.ConstData;
	import com.player.mvc.view.ui.LrcPanel;
	import com.player.mvc.vo.Music;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class LrcPanalMadiator extends Mediator implements IMediator {
		public static const NAME:String = "LrcPanalMadiator";		
		private static const FIND_LRC_ADRESS:String = "http://www.jpwy.net/gc/search.php";
		private static const LANG_ERROR_FIND_LRC:String = "未找到歌词";
		private static const LANG_WAITING_FIND_LRC:String = "正在搜索歌词...";
		
		private var loadLRCRequest:URLRequest;
		private var loadLRCLoader:URLLoader = new URLLoader();
		
		private var displayLRC:String;
		private var currentLRC:String;
		private var loadedLRC:Boolean;
		private var LRCarray:Array=new Array();
		
		public function LrcPanalMadiator(viewComponent:Object=null) {
			super(NAME, viewComponent);
			initView();
		}
		
		private function initView():void {
			
		}
		
		public function get lrcPanel():LrcPanel {
			return viewComponent as LrcPanel;
		}
		
		override public function listNotificationInterests():Array {
			return [
				ConstData.MUSIC_CONTROL,
				ConstData.LOAD_LRC_COMPLETE,
				ConstData.CONTROL_PROGRESS_MUSIC
			];
		}
		
		override public function handleNotification(notification:INotification):void {
			switch ( notification.getName() ) {
				case ConstData.MUSIC_CONTROL:
					findLrc( notification.getBody() );
				break;
				case ConstData.LOAD_LRC_COMPLETE:
					lrcLoadComplete( notification.getBody() );
				break;
				case ConstData.CONTROL_PROGRESS_MUSIC:
					runLrcHandler( notification.getBody() );
				break;
			}
		}
		
		private function findLrc( obj:Object ):void {
			trace("findLrc = ", obj.flag);
			switch ( obj.flag ) {
				case "select" :
					loadLrc( obj.value );
				break;
			}
		}		
		
		private function loadLrc( value:Music ):void {
			if(!value) return;
			var reg:RegExp = new RegExp(".mp3");
			var lrcPath:String = value.path.replace( reg, ".lrc" );
			displayLrc(LANG_WAITING_FIND_LRC);
			facade.sendNotification( ConstData.LOADLRC, lrcPath );
		}
		/**
		 * 是否显示lrc 
		 * @param obj
		 * 
		 */		
		private function lrcLoadComplete( obj:Object ):void {
			if( obj.label ) {
				trace( "lrcTxt = ", obj.value );
				dealLrcHandler( obj.value );
			} else {
				currentLRC = "";
				lrcPanel.lrcText.htmlText = "";		
				loadedLRC  = false;
				displayLRC = "";
				displayLrc(LANG_ERROR_FIND_LRC);
			}
		}
		
		private function displayLrc( info:String ):void {
			lrcPanel.lrcText.text = info;
		}
		/**
		 * 处理lrc显示 
		 * @param lrcTxt
		 * 
		 */		
		private function dealLrcHandler( lrcTxt:String ):void {
			currentLRC = lrcTxt;
			LRCarray = new Array();
			loadedLRC = true;
			var listarray : Array = currentLRC.split ("\n");
			var reg : RegExp =/\[[0-5][0-9]:[0-5][0-9].[0-9][0-9]\]/g;
			for (var i:int = 0; i < listarray.length; i ++) {
				var info : String = listarray [i];
				var len : int = info.match (reg).length;
				var timeAry : Array = info.match (reg);
				var lyric : String = info.substr (len * 10);
				for (var k : int = 0; k < timeAry.length; k ++) {
					var obj : Object = new Object ();
					var ctime : String = timeAry [k];
					var ntime : Number = Number (ctime.substr (1, 2)) * 60 + Number (ctime.substr (4, 5));
					obj.timer = ntime * 1000;
					obj.lyric = lyric 
					LRCarray.push (obj);
					//trace("obj.timer="+obj.timer+"|obj.lyric="+obj.lyric)
				}
			}
			LRCarray.sort (compare);
			displayLRCInPanel(LRCarray);
		}
		
		private function compare (paraA : Object, paraB : Object) : int {
			if (paraA.timer > paraB.timer) {
				return 1;
			}
			if (paraA.timer < paraB.timer) {
				return - 1;
			}
			return 0;
		}
		/**
		 * 格式化lrc 
		 * @param lrcArray
		 * 
		 */		
		private function displayLRCInPanel(lrcArray:Array):void {
			lrcPanel.lrcText.htmlText = "";
			for (var i:int = 0; i < lrcArray.length; i ++) {
				lrcPanel.lrcText.htmlText += '<font color="#000000">' + lrcArray[i].lyric + '</font>';
			}
		}
		/**
		 * 显示歌词 
		 * @param obj
		 * 
		 */		
		private function runLrcHandler( obj:Object ):void {			
			if(!loadedLRC)return;			
			var timeObject:Object = obj;
			var now : Number = timeObject.position;			
			var currentLRCItem:Object = new Object();	
			var tmpLrcCarray:Array	  = deepCopy(LRCarray);
			lrcPanel.lrcText.htmlText = "";		
			for (var i:int = 1; i < LRCarray.length; i ++)	{
				if (now < LRCarray[i].timer && now > LRCarray[i-1].timer) {
					currentLRCItem = LRCarray [i - 1];
					tmpLrcCarray[i-1].lyric = '<font color="#ff0000">' + LRCarray[i-1].lyric + '</font>';
					break;
				}
			}
			for (var j:int = 0; j < tmpLrcCarray.length; j ++) {
				lrcPanel.lrcText.htmlText += tmpLrcCarray[j].lyric;
			}
			if( currentLRCItem.lyric != displayLRC ) {
				displayLRC = currentLRCItem.lyric;
				trace(" displayLRC = ", displayLRC )
				facade.sendNotification( ConstData.DISPLAY_ONE_LRC, displayLRC );
			}			
		}
		
		private function deepCopy(LRCarray:Array):Array {
			var ba:ByteArray = new ByteArray();
			ba.writeObject( LRCarray );
			ba.position = 0;
			var tmpArr:Array = ba.readObject() as Array;
			return tmpArr;
		}
	}
}