class HtmlHandle extends WindowHandle
	;

native static function LoadHtml( string FileName );
native static function LoadHtmlFromString( string HtmlString );
native static function Clear();
native static function int GetFrameMaxHeight();
native static function EControlReturnType ControllerExecution( string strBypass );

//BBS����
native static function SetHtmlBuffData( string strData);
native static function SetPageLock( bool bLock);
native static function bool IsPageLock();
defaultproperties
{
}
