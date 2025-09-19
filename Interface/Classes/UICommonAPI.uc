class UICommonAPI extends UIScript;

// Dialog API
enum EDialogType
{
	DIALOG_OKCancel,
	DIALOG_OK,
	DIALOG_OKCancelInput,
	DIALOG_OKInput,
	DIALOG_Warning,
	DIALOG_Notice,
	DIALOG_NumberPad,
	DIALOG_Progress,
};

enum DialogDefaultAction
{
	EDefaultNone,
	EDefaultOK,
	EDefaultCancel,
};

// ���̾�α׸� �����ش�. strMessage : �Բ� ������ ��Ʈ��( ������� "������ �Է��� �ּ���" )
// ��ô ������ ���̾�αװ� �ƴ� �̻� DialogSetID() ���� �ҷ���� �Ѵ�.
function DialogShow( EDialogType dialogType, string strMessage )
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.ShowDialog( dialogType, strMessage, string(Self) );
}

// ���̾�α׸� �����. ���̾�αװ� �� �ִ� ��Ȳ���� �ٸ� ���̾�α׸� �����ַ��� DialogHide() �� ���� ȣ���ؾ��Ѵ�.
function DialogHide()
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.HideDialog();
}

// ���� Ű�� ������ ��� ���̾�αװ� � ������ �������� �����ϴ� �Լ��̴�.
// �� �Լ��� �θ��� ������ ����Ű�� ������ Cancel ��ư�� ���� �Ͱ� ���� ������ �Ѵ�.
// �ѹ� ���ǰ��� �ʱ�ȭ �ǹǷ� ����Ʈ �׼��� OK�� �ϰ������ �Ź� ���̾�α� ��� �� ���� �ҷ�����Ѵ�.
function DialogSetDefaultOK()
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetDefaultAction( EDefaultOK );
}

// EV_DialogOK ���� ���̾�α� �̺�Ʈ�� ���� ��, �� ���̾�αװ� �ڽ��� ��� ���̾�α� ������ �Ǻ��� �� ���δ�. ���� ��� ���̾�α׶�� �Ű澵 �ʿ䰡 ����~
function bool DialogIsMine()
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	if( script.GetTarget() == string(Self) )
		return true;
	return false;
}

// �Ѱ��� uc���� ���̾�α׸� �ѹ��� ���ٸ� �� �ʿ䰡 ��������, ���̾�α׸� ���� ��Ȳ���� ���ٸ�, ���� ��� ����.uc����  �������̵� ���µ��� ����
// ���� ȣĪ�� �Է� �޴� ���� ����Ѵٸ�, ���̾�α� �̺�Ʈ�� ������ �ڽ��� � ���̾�α׸� ��������� �� �ʿ䰡 �ִ�.
// �̷� ��� ���̾�α׸� ��� �� �����ϰ� �ƹ� ���ڳ� DialogSetID() �� �ְ� �̺�Ʈ ó�� �κп��� DialogGetID()�� �ؼ� �׿� �°� �ڵ带 ¥��ȴ�.
function DialogSetID( int id )
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetID( id );
}

// ���̾�α��� ����Ʈ �ڽ��� �Է� Ÿ���� ������ �� �� �ִ�. �Ϲ� ���ڿ�, ����, �н����� ��, XML �������� ���� ����.
function DialogSetEditType( string strType )
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEditType( strType );
}

// ���̾�α��� ����Ʈ�ڽ��� �Էµ� ��Ʈ���� �޾ƿ´�
function string DialogGetString()
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetEditMessage();
}

// ���̾�α��� ����Ʈ�ڽ��� ��Ʈ���� �Է��Ѵ�
function DialogSetString(string strInput)
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEditMessage(strInput);
}

function int DialogGetID()
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetID();
}

// ParamInt�� ���̾�α��� ���۰� ���õ� ������� ������ �ִµ� ���δ�. Progress�� timeup �ð�, NumberPad���� max�� ��.
function DialogSetParamInt( int param )
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetParamInt( param );
}

// ReservedXXX ������ ���̾�α׿� �־���ٰ� �ٽ� ���� �� �� �ִٴ� ������ ParamXXX�ʹ� �ٸ���.
function DialogSetReservedInt( int value )
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetReservedInt( value );
}

function DialogSetReservedInt2( int value )
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetReservedInt2( value );
}

function DialogSetReservedInt3( int value )
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetReservedInt3( value );
}

function int DialogGetReservedInt()
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetReservedInt();
}

function int DialogGetReservedInt2()
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetReservedInt2();
}

function int DialogGetReservedInt3()
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	return script.GetReservedInt3();
}

function DialogSetEditBoxMaxLength(int maxLength)
{
	local DialogBox	script;
	script = DialogBox(GetScript("DialogBox"));
	script.SetEditBoxMaxLength(maxLength);
}

function int Split( string strInput, string delim, out array<string> arrToken )
{
	local int arrSize;
	
	while ( InStr(strInput, delim)>0 )
	{
		arrToken.Insert(arrToken.Length, 1);
		arrToken[arrToken.Length-1] = Left(strInput, InStr(strInput, delim));
		strInput = Mid(strInput, InStr(strInput, delim)+1);
		arrSize = arrSize + 1;
	}
	arrToken.Insert(arrToken.Length, 1);
	arrToken[arrToken.Length-1] = strInput;
	arrSize = arrSize + 1;
	
	return arrSize;
}

function ShowWindow( string a_ControlID )
{
	class'UIAPI_WINDOW'.static.ShowWindow( a_ControlID );
}

function ShowWindowWithFocus( string a_ControlID )
{
	class'UIAPI_WINDOW'.static.ShowWindow( a_ControlID );
	class'UIAPI_WINDOW'.static.SetFocus( a_ControlID );
}


function HideWindow( string a_ControlID )
{
	class'UIAPI_WINDOW'.static.HideWindow( a_ControlID );
}

function bool IsShowWindow( string a_ControlID )
{
	return class'UIAPI_WINDOW'.static.IsShowWindow( a_ControlID );
}

function ParamToItemInfo( string param, out ItemInfo info )
{
	local int tmpInt;
	ParseInt( param, "classID", info.ClassID );
	ParseInt( param, "level", info.Level);
	ParseString( param, "name", info.Name);
	ParseString( param, "additionalName", info.AdditionalName);
	ParseString( param, "iconName", info.IconName);
	ParseString( param, "description", info.Description);
	ParseInt( param, "itemType", info.ItemType);
	ParseInt( param, "serverID", info.ServerID );
	ParseInt( param, "itemNum", info.ItemNum);
	ParseInt( param, "slotBitType", info.SlotBitType);
	ParseInt( param, "enchanted", info.Enchanted);
	ParseInt( param, "blessed", info.Blessed);
	ParseInt( param, "damaged", info.Damaged);
	if( ParseInt( param, "equipped", tmpInt ) )
		info.bEquipped = bool(tmpInt);
	ParseInt( param, "price", info.Price );
	ParseInt( param, "reserved", info.Reserved );
	ParseInt( param, "defaultPrice", info.DefaultPrice );
	ParseInt( param, "refineryOp1", info.RefineryOp1 );
	ParseInt( param, "refineryOp2", info.RefineryOp2 );
	ParseInt( param, "currentDurability", info.CurrentDurability );

	ParseInt( param, "weight", info.Weight );
	ParseInt( param, "materialType", info.MaterialType);
	ParseInt( param, "weaponType", info.WeaponType);
	ParseInt( param, "physicalDamage", info.PhysicalDamage);
	ParseInt( param, "magicalDamage", info.MagicalDamage);
	ParseInt( param, "shieldDefense", info.ShieldDefense);
	ParseInt( param, "shieldDefenseRate", info.ShieldDefenseRate);
	ParseInt( param, "durability", info.Durability);
	ParseInt( param, "crystalType", info.CrystalType);
	ParseInt( param, "randomDamage", info.RandomDamage);
	ParseInt( param, "critical", info.Critical);
	ParseInt( param, "hitModify", info.HitModify);
	ParseInt( param, "attackSpeed", info.AttackSpeed);
	ParseInt( param, "mpConsume", info.MpConsume);
	ParseInt( param, "avoidModify", info.AvoidModify);
	ParseInt( param, "soulshotCount", info.SoulshotCount);
	ParseInt( param, "spiritshotCount", info.SpiritshotCount);
		
	ParseInt( param, "armorType", info.ArmorType);
	ParseInt( param, "physicalDefense", info.PhysicalDefense);
	ParseInt( param, "magicalDefense", info.MagicalDefense);
	ParseInt( param, "mpBonus", info.MpBonus);

	ParseInt( param, "consumeType", info.ConsumeType);
	ParseInt( param, "ItemSubType", info.ItemSubType );
	ParseString( param, "iconNameEx1", info.IconNameEx1 );
	ParseString( param, "iconNameEx2", info.IconNameEx2 );
	ParseString( param, "iconNameEx3", info.IconNameEx3 );
	ParseString( param, "iconNameEx4", info.IconNameEx4 );
	if( ParseInt( param, "arrow", tmpInt ) )
		info.bArrow = bool(tmpInt);
	if( ParseInt( param, "recipe", tmpInt ) )
		info.bRecipe = bool(tmpInt);
	//ParseInt( param, "etcItemType", info.EtcItemType);
}

function ParamToRecord( string param, out LVDataRecord record )
{
	local int idx;
	local int MaxColumn;
	
	ParseString( param, "szReserved", record.szReserved );
	ParseInt( param, "nReserved1", record.nReserved1 );
	ParseInt( param, "nReserved2", record.nReserved2 );
	ParseInt( param, "nReserved3", record.nReserved3 );

	ParseInt( param, "MaxColumn", MaxColumn );
	record.LVDataList.Length = MaxColumn;
	for (idx=0; idx<MaxColumn; idx++)
	{
		ParseString( param, "szData_" $ idx, record.LVDataList[idx].szData );
		ParseString( param, "szReserved_" $ idx, record.LVDataList[idx].szReserved );
		ParseInt( param, "nReserved1_" $ idx, record.LVDataList[idx].nReserved1 );
		ParseInt( param, "nReserved2_" $ idx, record.LVDataList[idx].nReserved2 );
		ParseInt( param, "nReserved3_" $ idx, record.LVDataList[idx].nReserved3 );
	}
}

function CustomTooltip MakeTooltipSimpleText(string Text)
{
	local CustomTooltip Tooltip;
	local DrawItemInfo info;
	
	Tooltip.DrawList.Length = 1;
	info.eType = DIT_TEXT;
	info.t_bDrawOneLine = true;
	info.t_strText = Text;
	Tooltip.DrawList[0] = info;

	return Tooltip;
}
defaultproperties
{
}
