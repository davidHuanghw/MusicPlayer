package com.player.mvc.utils
{
	public class Util
	{
		/**
		 * 计算时间长度 
		 * @param length
		 * @return 
		 * 
		 */		
		public static function lengthToString(length:Number):String
		{
			//length = int(length);
			length = int(length/1000);//取到秒
			var lengthSec:int = length%60;
			var lengthMin:int = length/60;
			
			var lengthSecStr:String = lengthSec < 10 ? "0" + String(lengthSec) : String(lengthSec);
			var lengthMinStr:String = lengthMin < 10 ? "0" + String(lengthMin) : String(lengthMin);
			
			return lengthMinStr + ":" + lengthSecStr;
		}
	}
}