class HennaAPI extends Object
	;

native static function int GetHennaInfoCount();
native static function bool GetHennaInfo( int a_Index, out int a_HennaID, out int a_IsActive );
defaultproperties
{
}
