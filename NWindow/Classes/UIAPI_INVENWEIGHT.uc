class UIAPI_INVENWEIGHT extends UIAPI_WINDOW
	;

native static function AddWeight(string ControlName, int weight);
native static function ReduceWeight(string ControlName, int weight);
native static function ZeroWeight(string ControlName);
defaultproperties
{
}
