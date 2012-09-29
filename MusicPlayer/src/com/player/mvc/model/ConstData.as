package com.player.mvc.model
{
	public class ConstData
	{		
		//------------Command------------
		public static const STARTUP:String 						= "startup";
		public static const MUSIC_CONTROL:String				= "musicControl";
		public static const LOADLRC:String						= "loadLrc";
		
		//-------------Proxy-------------
		public static const MUSIC_START_PLAY:String				= "musicStartPlay";
		public static const UPDATA_MUSIC_ID3:String				= "upData_Music_id3";
		
		//------------Mediator-----------
		public static const ADD_MUSIC_FROM_FILE_LIST:String 	= "addMusicFromFileList";
		public static const REMOVE_MUSIC_FROM_FILE_LIST:String 	= "removeMusicFromFileList";
		public static const OPEN_MUSIC_FROM_FILE_LIST:String 	= "openMusicFromFileList";
		public static const CONTROL_NEXT_MUSIC:String			= "nextMusic";
		public static const CONTROL_PREV_MUSIC:String			= "prevMusic";
		public static const CONTROL_PROGRESS_MUSIC:String		= "controlProgressMusic";	
		public static const LOAD_LRC_COMPLETE:String			= "loadLrcComplete";
		public static const DISPLAY_ONE_LRC:String				= "displayOneLrc";
		public static const CLEAR_MUSIC_ID3:String			= "clearMusicId3";
	}
}