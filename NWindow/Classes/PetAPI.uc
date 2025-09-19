class PetAPI extends Object
	;

native static function RequestPetInventoryItemList();
native static function RequestPetUseItem(int ServerID);
native static function RequestGiveItemToPet(int ServerID, int Num);
native static function RequestGetItemFromPet(int ServerID, int Num, bool IsEquipItem);
defaultproperties
{
}
