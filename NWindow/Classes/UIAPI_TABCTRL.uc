class UIAPI_TABCTRL extends UIAPI_WINDOW
	;
//tab ��Ʈ�� �ʱ�ȭ onshow���� ȣ�� ������Ѵ�.
native static function InitTabCtrl(string ControlName);
native static function SetTopOrder(string ControlName, int index, bool bSendMessage);
native static function int GetTopIndex(string ControlName);
native static function SetDisable( string ControlName, int index, bool bDisable );
defaultproperties
{
}
