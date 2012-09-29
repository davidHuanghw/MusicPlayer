package com.player.mvc.utils
{
	import flash.utils.ByteArray;
	/**
	 * 编码转换成UTF8 
	 * @author davidhuang
	 * 
	 */	
	public class UTF8Util
	{
		public static function encodeUtf8(str : String):String
		{
			var oriByteArr : ByteArray = new ByteArray();
			oriByteArr.writeUTFBytes (str);
			var tempByteArr : ByteArray = new ByteArray();
			
			for (var i:int = 0; i<oriByteArr.length; i++) {
			    if (oriByteArr[i] == 194) {
				    tempByteArr.writeByte(oriByteArr[i+1]);
				    i++;
				} else if (oriByteArr[i] == 195) {
				    tempByteArr.writeByte(oriByteArr[i+1] + 64);
				    i++;
				} 
			}
			tempByteArr.position = 0;
			if(tempByteArr.length == 0){
				return str;
			}else{
				return tempByteArr.readMultiByte(tempByteArr.bytesAvailable,"chinese");
			}
			
		}
	}
}