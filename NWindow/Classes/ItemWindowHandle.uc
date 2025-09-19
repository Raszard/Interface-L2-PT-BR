class ItemWindowHandle extends WindowHandle ;

native static function int GetSelectedNum();
native static function int GetItemNum();
native static function ClearSelect();
native static function AddItem(ItemInfo info);
native static function bool SetItem(int index, ItemInfo info);
native static function DeleteItem(int index);
native static function bool GetSelectedItem(out ItemInfo info);
native static function bool GetItem(int index, out ItemInfo info);
native static function INT	GetSelectedItemID();
native static function Clear();
native static function int FindItemWithServerID( int serverID );
native static function int FindItemWithClassID( int classID );
native static function SetFaded( bool bOn );
native static function ShowScrollBar(bool bShow);
native static function SwapItems(int index1, int index2);
native static function int	GetIndexAt( int x, int y, int offsetX, int offsetY );
native static function SetDisableTex( String a_DisableTex );
native static function SetRow( int a_Row );
native static function SetCol( int a_Col );
defaultproperties
{
}
