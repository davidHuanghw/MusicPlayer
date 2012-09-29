package com.player.mvc.component
{
	import com.player.mvc.vo.Status;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	
	import mx.core.UIComponent;

	/**
	 * 绘制声谱波动线 
	 * @author davidhuang
	 * 
	 */	
	public class Visualization extends UIComponent {
		public function Visualization() {
			super();
		}
        private const CHANNEL_LEN:int = 256; 
		/**
		 * 声波线判断 
		 * @param b	stop，play，remove
		 * 
		 */ 		
        public function audioswitch(status:String):void  {
			switch( status ) {
				case Status.PLAY:
    	            addEventListener(Event.ENTER_FRAME, onEnterFrame);
					break;
				case Status.STOP:
					clean();
					removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					break;
				case Status.PAUSE:
					removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					break;
            }
        }
		/**
		 * 清除声波线 
		 * 
		 */		
  		private function clean():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			graphics.clear();
		}
		/**
		 * 绘制声波线 
		 * @param event
		 * 
		 */		
        private function onEnterFrame(event:Event):void {
            var len_step:Number = this.width/CHANNEL_LEN;
            var plot_height:Number = this.height/2;
 
            var bytes:ByteArray = new ByteArray();
            SoundMixer.computeSpectrum( bytes, false, 0 );
 
            var g:Graphics = this.graphics;
 
            g.clear();
            g.lineStyle(0, 0xB5F0FB);
            g.moveTo(0, plot_height);
 
            var n:Number = 0;
 
            for (var i:int = 0; i < CHANNEL_LEN; i++) {
                n = ( bytes.readFloat() * plot_height );
            	g.lineTo(i * len_step, plot_height - n);
            }
            g.lineTo(CHANNEL_LEN * len_step, plot_height);
            g.lineStyle(0, 0x53cbff);
            g.moveTo(CHANNEL_LEN * len_step, plot_height);
 
            for (i = CHANNEL_LEN; i > 0; i--) {
                n = (bytes.readFloat() * plot_height);
                g.lineTo(i * len_step, plot_height - n);
            }
            g.lineTo(0, plot_height);
        }

	}
}