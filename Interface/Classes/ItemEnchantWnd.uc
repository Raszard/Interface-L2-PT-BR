class ItemEnchantWnd extends UICommonAPI;

//Handle List
var WindowHandle		Me;
var ItemWindowHandle	ItemWnd;

function OnLoad()
{
	RegisterEvent( EV_EnchantShow );
	RegisterEvent( EV_EnchantHide );
	RegisterEvent( EV_EnchantItemList );
	RegisterEvent( EV_EnchantResult );
	
	//Init Handle
	Me = GetHandle( "ItemEnchantWnd" );
	ItemWnd = ItemWindowHandle( GetHandle( "ItemEnchantWnd.ItemWnd" ) );
}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_EnchantShow)
	{
		HandleEnchantShow(param);
	}
	else if (Event_ID == EV_EnchantHide)
	{
		HandleEnchantHide();
	}
	else if (Event_ID == EV_EnchantItemList)
	{
		HandleEnchantItemList(param);
	}
	else if (Event_ID == EV_EnchantResult)
	{
		HandleEnchantResult(param);
	}
}

function OnClickButton( string strID )
{
	switch( strID )
	{
	case "btnOK":
		OnOKClick();
		break;
	case "btnCancel":
		OnCancelClick();
		break;
	}
}

function OnOKClick()
{
	local ItemInfo infItem;
	
	ItemWnd.GetSelectedItem(infItem);
	if (infItem.ServerID>0)
		class'EnchantAPI'.static.RequestEnchantItem(infItem.ServerID);
}

function OnCancelClick()
{
	class'EnchantAPI'.static.RequestEnchantItem(-1);
	Me.HideWindow();
	Clear();
}

function Clear()
{
	ItemWnd.Clear();
}

function HandleEnchantShow(string param)
{
	local int ClassID;
	
	Clear();
	
	ParseInt(param, "ClassID", ClassID);
	Me.SetWindowTitle(GetSystemString(1220) $ "(" $ class'UIDATA_ITEM'.static.GetItemName(ClassID) $ ")");
	Me.ShowWindow();
	Me.SetFocus();
}

function HandleEnchantHide()
{
	Me.HideWindow();
	Clear();
}

function HandleEnchantItemList(string param)
{
	local ItemInfo infItem;
	ParamToItemInfo(param, infItem);
	ItemWnd.AddItem(infItem);
}

function HandleEnchantResult(string param)
{
	//결과에 상관없이 무조건 Hide
	Me.HideWindow();
	Clear();
}
defaultproperties
{
}
