class InventoryWnd extends UICommonAPI;

const DIALOG_USE_RECIPE				= 1111;				// ╳５使o“oACC﹌／| ╳ic﹌?eCO ╳芋IAIAo﹌／| 使o╳芋A╳i ﹌O╳▼
const DIALOG_POPUP					= 2222;				// “u“╳AIAU╳ic﹌?e “oA AoA﹌╞﹠iE “╳E“u╳A﹌／“〝“oAAo﹌／| ﹌Oc﹌?i ﹌O╳▼
const DIALOG_DROPITEM				= 3333;				// “u“╳AIAUA╳i 使oU﹌﹠U﹌?﹌Ｙ 使oo﹌／╳取 ﹌O╳▼(CN╳芋使帚)
const DIALOG_DROPITEM_ASKCOUNT		= 4444;				// “u“╳AIAUA╳i 使oU﹌﹠U﹌?﹌Ｙ 使oo﹌／╳取 ﹌O╳▼(﹌?“I╳５?╳芋使帚, ╳芋使帚“uo﹌／| 使o╳芋“ui“／╳i﹌﹠U)
const DIALOG_DROPITEM_ALL			= 5555;				// “u“╳AIAUA╳i 使oU﹌﹠U﹌?﹌Ｙ 使oo﹌／╳取 ﹌O╳▼(MoveAll ╳ioAAAI ﹌O╳▼)
const DIALOG_DESTROYITEM			= 6666;				// “u“╳AIAUA╳i E“〝AoAe﹌?﹌Ｙ 使oo﹌／╳取 ﹌O╳▼(CN╳芋使帚)
const DIALOG_DESTROYITEM_ALL		= 7777;				// “u“╳AIAUA╳i E“〝AoAe﹌?﹌Ｙ 使oo﹌／╳取 ﹌O╳▼(MoveAll ╳ioAAAI ﹌O╳▼)
const DIALOG_DESTROYITEM_ASKCOUNT	= 8888;				// “u“╳AIAUA╳i E“〝AoAe﹌?﹌Ｙ 使oo﹌／╳取 ﹌O╳▼(﹌?“I╳５?╳芋使帚, ╳芋使帚“uo﹌／| 使o╳芋“ui“／╳i﹌﹠U)
const DIALOG_CRYSTALLIZE			= 9999;				// “u“╳AIAUA╳i ╳芋aA﹌╞E╳使 CO﹌O╳▼
const DIALOG_DROPITEM_PETASKCOUNT	= 10000;			// “╳eAI“／╳I﹌?﹌Ｙ“u╳使 “u“╳AIAUAI ﹠ia╳５O﹠iC“uuA╳i ﹌O╳▼

const EQUIPITEM_Underwear = 0;
const EQUIPITEM_Head = 1;
const EQUIPITEM_Hair = 2;
const EQUIPITEM_Hair2 = 3;
const EQUIPITEM_Neck = 4;
const EQUIPITEM_RHand = 5;
const EQUIPITEM_Chest = 6;
const EQUIPITEM_LHand = 7;
const EQUIPITEM_REar = 8;
const EQUIPITEM_LEar = 9;
const EQUIPITEM_Gloves = 10;
const EQUIPITEM_Legs = 11;
const EQUIPITEM_Feet = 12;
const EQUIPITEM_RFinger = 13;
const EQUIPITEM_LFinger = 14;
const EQUIPITEM_Max = 15;

var	String				m_WindowName;
var	ItemWindowHandle	m_invenItem;
var	ItemWindowHandle	m_questItem;
var	ItemWindowHandle	m_equipItem[ EQUIPITEM_Max ];
var	ItemWindowHandle	m_hHennaItemWindow;
var	TextBoxHandle		m_hAdenaTextBox;

var	array<int>			m_itemOrder;				// AI“／╳IAa﹌／﹌c “u“╳AIAUAC “u使見“u╳使﹌／| ╳５IAA﹌?﹌Ｙ AuAaCN﹌﹠U.
var	Vector				m_clickLocation;			// “u“╳AIAU ﹠ia╳５OCO﹌O╳▼ “ui﹠i使﹟﹌?﹌Ｙ ﹠ia╳５OCO Ao﹌／| AuAaCI╳芋i AO﹌﹠A﹌﹠U.

var Array<ItemInfo>		m_EarItemList;
var Array<ItemInfo>		m_FingerItemLIst;

function OnLoad()
{
	registerEvent(EV_InventoryClear);
	registerEvent(EV_InventoryOpenWindow);
	registerEvent(EV_InventoryHideWindow);
	registerEvent(EV_InventoryAddItem);
	registerEvent(EV_InventoryUpdateItem);
	registerEvent(EV_InventoryItemListEnd);
	registerEvent(EV_InventoryAddHennaInfo);
	registerEvent(EV_InventoryToggleWindow);
	registerEvent(EV_UpdateHennaInfo);
	registerEvent(EV_UpdateUserInfo);
	registerEvent(EV_DialogOK);

	InitHandle();
}

function InitHandle()
{
	m_invenItem	= ItemWindowHandle(GetHandle(m_WindowName $ ".InventoryItem"));
	m_questItem	= ItemWindowHandle(GetHandle(m_WindowName $ ".QuestItem"));
	m_hAdenaTextBox = TextBoxHandle( GetHandle(m_WindowName $ ".AdenaText") );

	m_equipItem[ EQUIPITEM_Underwear ] = ItemWindowHandle( GetHandle( "EquipItem_Underwear" ) );
	m_equipItem[ EQUIPITEM_Head ] = ItemWindowHandle( GetHandle( "EquipItem_Head" ) );
	m_equipItem[ EQUIPITEM_Hair ] = ItemWindowHandle( GetHandle( "EquipItem_Hair" ) );
	m_equipItem[ EQUIPITEM_Hair2 ] = ItemWindowHandle( GetHandle( "EquipItem_Hair2" ) );
	m_equipItem[ EQUIPITEM_Neck ] = ItemWindowHandle( GetHandle( "EquipItem_Neck" ) );
	m_equipItem[ EQUIPITEM_RHand ] = ItemWindowHandle( GetHandle( "EquipItem_RHand" ) );
	m_equipItem[ EQUIPITEM_Chest ] = ItemWindowHandle( GetHandle( "EquipItem_Chest" ) );
	m_equipItem[ EQUIPITEM_LHand ] = ItemWindowHandle( GetHandle( "EquipItem_LHand" ) );
	m_equipItem[ EQUIPITEM_REar ] = ItemWindowHandle( GetHandle( "EquipItem_REar" ) );
	m_equipItem[ EQUIPITEM_LEar ] = ItemWindowHandle( GetHandle( "EquipItem_LEar" ) );
	m_equipItem[ EQUIPITEM_Gloves ] = ItemWindowHandle( GetHandle( "EquipItem_Gloves" ) );
	m_equipItem[ EQUIPITEM_Legs ] = ItemWindowHandle( GetHandle( "EquipItem_Legs" ) );
	m_equipItem[ EQUIPITEM_Feet ] = ItemWindowHandle( GetHandle( "EquipItem_Feet" ) );
	m_equipItem[ EQUIPITEM_RFinger ] = ItemWindowHandle( GetHandle( "EquipItem_RFinger" ) );
	m_equipItem[ EQUIPITEM_LFinger ] = ItemWindowHandle( GetHandle( "EquipItem_LFinger" ) );
	m_equipItem[ EQUIPITEM_LHand ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Head ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Gloves ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Legs ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Feet ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );
	m_equipItem[ EQUIPITEM_Hair2 ].SetDisableTex( "L2UI.InventoryWnd.Icon_dualcap" );

	m_hHennaItemWindow = ItemWindowHandle( GetHandle( "HennaItem" ) );
}

function OnEvent(int Event_ID, string param)
{
	switch( Event_ID )
	{
	case EV_InventoryClear:
		HandleClear();
		break;
	case EV_InventoryOpenWindow:
		HandleOpenWindow();
		break;
	case EV_InventoryHideWindow:
		HandleHideWindow();
		break;
	case EV_InventoryAddItem:
		HandleAddItem(param);
		break;
	case EV_InventoryUpdateItem:
		HandleUpdateItem(param);
		break;
	case EV_InventoryItemListEnd:
		HandleItemListEnd();
		break;
	case EV_InventoryAddHennaInfo:
		HandleAddHennaInfo(param);
		break;
	case EV_UpdateHennaInfo:
		HandleUpdateHennaInfo(param);
		break;
	case EV_InventoryToggleWindow:
		HandleToggleWindow();
		break;
	case EV_DialogOK:
		HandleDialogOK();
		break;
	case EV_UpdateUserInfo:
		HandleUpdateUserInfo();
		break;
	default:
		break;
	};
}

function OnShow()
{
	if( class'UIDATA_PLAYER'.static.HasCrystallizeAbility() )
	{
		ShowWindow(m_WindowName $ ".CrystallizeButton");
	}
	else
	{
		HideWindow(m_WindowName $ ".CrystallizeButton");
	}
	SetAdenaText();
	SetItemCount();

	UpdateHennaInfo();
}

function OnHide()
{
	SaveItemOrder();
}

// ItemWindow Event
function OnDBClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	UseItem( a_hItemWindow, index );
}

function OnRClickItemWithHandle( ItemWindowHandle a_hItemWindow, int index )
{
	//debug("OnRClickItem");
	UseItem( a_hItemWindow, index );
}

function OnSelectItemWithHandle( ItemWindowHandle a_hItemWindow, int a_Index )
{
	local int i;
	local ItemInfo	info;

    // Shift+Click simples tambem linka
    if (IsShiftDown() && a_hItemWindow.GetItem(a_Index, info))
    {
        PasteItemLinkToChat(info);
        return;
    }

	if( a_hItemWindow == m_invenItem )
		return;

	if( a_hItemWindow == m_questItem )
		return;

	for( i = 0; i < EQUIPITEM_MAX; ++i )
	{
		if( a_hItemWindow != m_equipItem[ i ] )
			m_equipItem[ i ].ClearSelect();
	}
}

function OnDropItem( String strTarget, ItemInfo info, int x, int y )
{
	local int toIndex, fromIndex;

	// AI“／╳IAa﹌／﹌c﹌?﹌Ｙ“u╳使 ﹌?A ╳芋IAI “u“╳﹌﹠I﹌／e A使帚﹌／﹌cCIAo “uE﹌﹠A﹌﹠U.
	if( !(info.DragSrcName == "InventoryItem" || info. DragSrcName == "QuestItem" || -1 != InStr( info.DragSrcName, "EquipItem" ) || info.DragSrcName == "PetInvenWnd") )
		return;

	//debug("Inventory OnDropItem dest " $ strTarget $ ", source " $ info.DragSrcName $ " x:" $ x $ ", y:" $ y);
	if( strTarget == "InventoryItem" )
	{
		if( info.DragSrcName == "InventoryItem" )			// Change Item position
		{
			toIndex = m_invenItem.GetIndexAt( x, y, 1, 1 );
			if( toIndex >= 0 )			// Exchange with another item
			{
				fromIndex = m_invenItem.FindItemWithServerID(info.ServerID);
				if( toIndex != fromIndex )
				{
					// ﹠iI╳芋使帚AC while 使o﹌c A使／﹌?﹌Ｙ “uiA╳ACC CN╳芋使帚﹌?﹌Ｙ﹌／﹌／ ﹠ie“ui╳芋╳I﹌﹠U.
					while( fromIndex < toIndex )		// “uOA﹌／╳５I ﹌O?╳取a╳取a
					{
						m_invenItem.SwapItems( fromIndex, fromIndex + 1 );
						++fromIndex;
					}

					while( toIndex < fromIndex )		// ﹠iU╳５I 使o“﹌“ui使帚╳i╳取a
					{
						m_invenItem.SwapItems( fromIndex, fromIndex - 1 );
						--fromIndex;
					}
				}
			}
			else						// move this item to last
			{
				fromIndex = m_invenItem.GetItemNum();
				while( toIndex < fromIndex - 1 )
				{
					m_invenItem.SwapItems( toIndex, toIndex + 1 );
					++toIndex;
				};
			}
		}
		else if( -1 != InStr( info.DragSrcName, "EquipItem" ) )			// Unequip thie item
		{
			RequestUnequipItem(info.ServerID, info.SlotBitType);
		}
		else if( info.DragSrcName == "PetInvenWnd" )		// Pet -> Inventory
		{
			if( IsStackableItem(info.ConsumeType) && info.ItemNum > 1 )			// Multiple item?
			{
				if( info.AllItemCount > 0 )					// Au“／I ﹌?A╳取使╳ ╳芋IAI╳芋﹌Ｙ
				{
					if ( CheckItemLimit( info.ClassID, info.AllItemCount ) )
					{
						class'PetAPI'.static.RequestGetItemFromPet( info.ServerID, info.AllItemCount, false);
					}
				}
				else
				{
					DialogSetID(DIALOG_DROPITEM_PETASKCOUNT);
					DialogSetReservedInt(info.ServerID);
					DialogSetParamInt(info.ItemNum);
					DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name ) );
				}
			}
			else																// Single item?
			{
				class'PetAPI'.static.RequestGetItemFromPet( info.ServerID, 1, false);
			}
		}
	}
	else if( strTarget == "QuestItem" )
	{
		if( info.DragSrcName == "QuestItem" )			// Change Item position
		{
			toIndex = m_questItem.GetIndexAt( x, y, 1, 1 );
			if( toIndex >= 0 )			// Exchange with another item
			{
				fromIndex = m_questItem.FindItemWithServerID(info.ServerID);
				if( toIndex != fromIndex )
				{
					// ﹠iI╳芋使帚AC while 使o﹌c A使／﹌?﹌Ｙ “uiA╳ACC CN╳芋使帚﹌?﹌Ｙ﹌／﹌／ ﹠ie“ui╳芋╳I﹌﹠U.
					while( fromIndex < toIndex )		// “uOA﹌／╳５I ﹌O?╳取a╳取a
					{
						m_questItem.SwapItems( fromIndex, fromIndex + 1 );
						++fromIndex;
					}

					while( toIndex < fromIndex )		// ﹠iU╳５I 使o“﹌“ui使帚╳i╳取a
					{
						m_questItem.SwapItems( fromIndex, fromIndex - 1 );
						--fromIndex;
					}
				}
			}
			else						// move this item to last
			{
				fromIndex = m_invenItem.GetItemNum();
				while( toIndex < fromIndex - 1 )
				{
					m_invenItem.SwapItems( toIndex, toIndex + 1 );
					++toIndex;
				};
			}
		}
	}
	else if( -1 != InStr( strTarget, "EquipItem" ) )		// Equip the item
	{
		if( info.DragSrcName == "PetInvenWnd" )				// Pet -> Equip
		{
			class'PetAPI'.static.RequestGetItemFromPet( info.ServerID, 1, true );
		}
		else if( -1 != InStr( info.DragSrcName, "EquipItem" ) )	//“u“╳使o╳i╳芋I﹠i﹠i CIAo “uE﹌﹠A﹌﹠U. 
		{
		}
		else if( EItemType(info.ItemType) != ITEM_ETCITEM )
		{
			RequestUseItem(info.ServerID);
		}
	}
	else if( strTarget == "TrashButton" )					// Destroy item( after confirmation )
	{
		if( IsStackableItem(info.ConsumeType) && info.ItemNum > 1 )			// Multiple item?
		{
			//“uo╳５﹌c“u“／ “u“╳AIAUA╳i Au“／I ╳ieA|CI﹌﹠A╳芋IA“／ ╳取╳０使帚E E“〝AoAe﹌?﹌Ｙ 使㊣使見╳芋i╳芋﹌Ｙ﹌﹠A ╳芋I╳芋u ╳芋╳芋A“／ ╳取a﹌﹠E.
			if( info.AllItemCount > 0 )				// Au“／I 使oo﹌／╳取 ╳芋IAI╳芋﹌Ｙ
			{				
				DialogSetID(DIALOG_DESTROYITEM_ALL);
				DialogSetReservedInt(info.ServerID);
				DialogSetReservedInt2(info.AllItemCount);
				DialogShow(DIALOG_Warning, MakeFullSystemMsg(GetSystemMessage(74), info.Name, ""));
			}
			else
			{
				DialogSetID(DIALOG_DESTROYITEM_ASKCOUNT);
				DialogSetReservedInt(info.ServerID);
				DialogSetParamInt(info.ItemNum);
				DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(73), info.Name ) );
			}
		}
		else																// Single item?
		{
			DialogSetID(DIALOG_DESTROYITEM);
			DialogSetReservedInt(info.ServerID);
			DialogShow( DIALOG_Warning, MakeFullSystemMsg( GetSystemMessage(74), info.Name ) );
		}
	}
	else if( strTarget == "CrystallizeButton" )
	{
		if( info.DragSrcName == "InventoryItem" || ( -1 != InStr( info.DragSrcName, "EquipItem" ) ) )
		{
			if( class'UIDATA_PLAYER'.static.HasCrystallizeAbility() && class'UIDATA_ITEM'.static.IsCrystallizable(info.ClassID) )			// Show Dialog asking confirmation
			{
				DialogSetID(DIALOG_CRYSTALLIZE);
				DialogSetReservedInt(info.ServerID);
				DialogShow(DIALOG_Warning, MakeFullSystemMsg( GetSystemMessage(336), info.Name ) );
			}
		}
	}
}

// ╳芋╳芋A“／ “u“╳AIAU A╳E﹌?﹌Ｙ“u╳使 “u“╳AIAUA╳i ﹌?A╳取a﹌﹠A ╳芋IA“／ OnDropItem ﹌?﹌Ｙ“u╳使 C“見╳芋aCI﹠i﹠i╳５I CI╳芋i ﹌?“I╳取a“u╳使﹌﹠A 使oU﹌﹠U﹌?﹌Ｙ 使oo﹌／﹌c﹌﹠A ╳ioE使㊣﹌／﹌／ A使帚﹌／﹌cCN﹌﹠U.
function OnDropItemSource( String strTarget, ItemInfo info )
{
	if( strTarget == "Console" )
	{
		if( info.DragSrcName == "InventoryItem" || info.DragSrcName == "QuestItem"
			|| ( -1 != InStr( info.DragSrcName, "EquipItem" ) ) )
		{
			m_clickLocation = GetClickLocation();
			if( IsStackableItem(info.ConsumeType) && info.ItemNum > 1 )		// “uo╳５﹌cAI AO﹌﹠A “u“╳AIAU
			{
				if( info.AllItemCount > 0 )				// Au“／I 使oo﹌／╳取 ╳芋IAI╳芋﹌Ｙ
				{
					DialogHide();
					DialogSetID( DIALOG_DROPITEM_ALL );
					DialogSetReservedInt(info.ServerID);
					DialogSetReservedInt2(info.AllItemCount);
					DialogShow(DIALOG_Warning, MakeFullSystemMsg(GetSystemMessage(1833), info.Name, ""));
				}
				else												// “uyAU﹌／| 使o╳芋“ui“／“u ╳芋IAI╳芋﹌Ｙ
				{
					DialogHide();
					DialogSetID( DIALOG_DROPITEM_ASKCOUNT );
					DialogSetReservedInt(info.ServerID);
					DialogSetParamInt(info.ItemNum);
					DialogShow(DIALOG_NumberPad, MakeFullSystemMsg(GetSystemMessage(71), info.Name, ""));
				}
			}
			else
			{
				DialogHide();
				DialogSetID( DIALOG_DROPITEM );
				DialogSetReservedInt(info.ServerID);
				DialogShow(DIALOG_Warning, MakeFullSystemMsg(GetSystemMessage(400), info.Name, ""));
			}
		}
	}
}

function bool IsEquipItem( out ItemInfo info )
{
	return info.bEquipped;
}

function bool IsQuestItem( out ItemInfo info )
{
	return EItemtype(info.ItemType) == ITEM_QUESTITEM;
}

function HandleClear()
{
	EquipItemClear();
	m_invenItem.Clear();
	m_questItem.Clear();
	m_EarItemList.Length = 0;
	m_FingerItemLIst.Length = 0;
}

function int EquipItemGetItemNum()
{
	local int i;
	local int ItemNum;

	for( i = 0; i < EQUIPITEM_Max; ++i )
	{
		if(m_equipItem[ i ].IsEnableWindow())	// “u“u“╳﹌c“u“╳AIAUA“／ CI使帚“﹟﹌／﹌／ “u“u﹌﹠U. 
		{
			ItemNum = ItemNum + m_equipItem[ i ].GetItemNum();
		}
	}

	return ItemNum;
}

function EquipItemClear()
{
	local int i;

	for( i = 0; i < EQUIPITEM_Max; ++i )
		m_equipItem[ i ].Clear();
}

function bool EquipItemFind( int a_ServerID )
{
	local int i;
	local int Index;

	for( i = 0; i < EQUIPITEM_Max; ++i )
	{
		Index = m_equipItem[ i ].FindItemWithServerID( a_ServerID );
		if( -1 != Index )
			return true;
	}

	return false;
}

function EquipItemDelete( int a_serverID )
{
	local int i;
	local int Index;
	local ItemInfo TheItemInfo;

	for( i = 0; i < EQUIPITEM_Max; ++i )
	{
		Index = m_equipItem[ i ].FindItemWithServerID( a_ServerID );
		if( -1 != Index )
		{
			m_equipItem[ i ].Clear();

			// E╳使╳iiA╳i 使oo﹌／﹌c﹌﹠A ╳芋使╳﹌?i, “／oAU﹌／﹌c﹌?﹌Ｙ E╳芋 ﹌／使﹟“ucAI C╳I“oA﹠iC“ui“u使／CN﹌﹠U.
			if( i == EQUIPITEM_LHand )
			{
				if( m_equipItem[ EQUIPITEM_RHand ].GetItem( 0, TheItemInfo ) )
				{
					if( TheItemInfo.SlotBitType == 16384 )
					{
						m_equipItem[ EQUIPITEM_LHand ].Clear();
						m_equipItem[ EQUIPITEM_LHand ].AddItem( TheItemInfo );
						m_equipItem[ EQUIPITEM_LHand ].DisableWindow();
					}
				}
			}
		}
	}
}

function EarItemUpdate()
{
	local int i;
	local int LEarIndex, REarIndex;

	LEarIndex = -1;
	REarIndex = -1;

	for( i = 0; i < m_EarItemList.Length; ++i )
	{
		switch( IsLOrREar( m_EarItemList[i].ServerID ) )
		{
		case -1:
			LEarIndex = i;
			break;
		case 0:
			m_EarItemList.Remove( i, 1 );
			break;
		case 1:
			REarIndex = i;
			break;
		}
	}

	if( -1 != LEarIndex )
	{
		m_equipItem[ EQUIPITEM_LEar ].Clear();
		m_equipItem[ EQUIPITEM_LEar ].AddItem( m_EarItemList[ LEarIndex ] );
	}

	if( -1 != REarIndex )
	{
		m_equipItem[ EQUIPITEM_REar ].Clear();
		m_equipItem[ EQUIPITEM_REar ].AddItem( m_EarItemList[ REarIndex ] );
	}
}

function FingerItemUpdate()
{
	local int i;
	local int LFingerIndex, RFingerIndex;

	LFingerIndex = -1;
	RFingerIndex = -1;

	for( i = 0; i < m_FingerItemList.Length; ++i )
	{
		switch( IsLOrRFinger( m_FingerItemList[i].ServerID ) )
		{
		case -1:
			LFingerIndex = i;
			break;
		case 0:
			m_FingerItemList.Remove( i, 1 );
			break;
		case 1:
			RFingerIndex = i;
			break;
		}
	}

	if( -1 != LFingerIndex )
	{
		m_equipItem[ EQUIPITEM_LFinger ].Clear();
		m_equipItem[ EQUIPITEM_LFinger ].AddItem( m_FingerItemList[ LFingerIndex ] );
	}

	if( -1 != RFingerIndex )
	{
		m_equipItem[ EQUIPITEM_RFinger ].Clear();
		m_equipItem[ EQUIPITEM_RFinger ].AddItem( m_FingerItemList[ RFingerIndex ] );
	}
}

function EquipItemUpdate( ItemInfo a_info )
{
	local ItemWindowHandle hItemWnd;
	local ItemInfo TheItemInfo;
	local bool ClearLHand;
	local ItemInfo RHand;
	local ItemInfo LHand;
	local ItemInfo Legs;
	local ItemInfo Gloves;
	local ItemInfo Feet;
	local ItemInfo Hair2;
	local int i;

	switch( a_Info.SlotBitType )
	{
	case 1:		// SBT_UNDERWEAR
		hItemWnd = m_equipItem[ EQUIPITEM_Underwear ];
		break;
	case 2:		// SBT_REAR
	case 4:		// SBT_LEAR
	case 6:		// SBT_RLEAR
		for( i = 0; i < m_EarItemList.Length; ++i )
		{
			if( m_EarItemList[ i ].ServerID == a_Info.ServerID )
				break;
		}

		// ﹌／使見 A╳I“uOA╳i ﹌O╳▼﹌／﹌／ A使／╳芋﹌Ｙ
		if( i == m_EarItemList.Length )
		{
			m_EarItemList.Length = m_EarItemList.Length + 1;
			m_EarItemList[m_EarItemList.Length-1] = a_Info;
		}

		hItemWnd = None;
		EarItemUpdate();
		break;
	case 8:		// SBT_NECK
		hItemWnd = m_equipItem[ EQUIPITEM_Neck ];
		break;
	case 16:	// SBT_RFINGER
	case 32:	// SBT_LFINGER
	case 48:	// SBT_RLFINGER
		for( i = 0; i < m_FingerItemList.Length; ++i )
		{
			if( m_FingerItemList[ i ].ServerID == a_Info.ServerID )
				break;
		}

		// ﹌／使見 A╳I“uOA╳i ﹌O╳▼﹌／﹌／ A使／╳芋﹌Ｙ
		if( i == m_FingerItemList.Length )
		{
			m_FingerItemList.Length = m_FingerItemList.Length + 1;
			m_FingerItemList[m_FingerItemList.Length-1] = a_Info;
		}

		hItemWnd = None;
		FingerItemUpdate();
		break;
	case 64:	// SBT_HEAD
		hItemWnd = m_equipItem[ EQUIPITEM_Head ];
		hItemWnd.EnableWindow();
		break;
	case 128:	// SBT_RHAND
		hItemWnd = m_equipItem[ EQUIPITEM_RHand ];
		break;
	case 256:	// SBT_LHAND
		hItemWnd = m_equipItem[ EQUIPITEM_LHand ];
		hItemWnd.EnableWindow();
		break;
	case 512:	// SBT_GLOVES
		hItemWnd = m_equipItem[ EQUIPITEM_Gloves ];
		hItemWnd.EnableWindow();
		break;
	case 1024:	// SBT_CHEST
		hItemWnd = m_equipItem[ EQUIPITEM_Chest ];
		break;
	case 2048:	// SBT_LEGS
		hItemWnd = m_equipItem[ EQUIPITEM_Legs ];
		hItemWnd.EnableWindow();
		break;
	case 4096:	// SBT_FEET
		hItemWnd = m_equipItem[ EQUIPITEM_Feet ];
		hItemWnd.EnableWindow();
		break;
	case 8192:	// SBT_BACK
		hItemWnd = m_equipItem[ EQUIPITEM_Underwear ];
		break;
	case 16384:	// SBT_RLHAND
		hItemWnd = m_equipItem[ EQUIPITEM_RHand ];
		ClearLHand = true;

		// RHand﹌?﹌Ｙ Bow╳芋﹌Ｙ ﹠ie“ui﹌?O﹌﹠A﹠i╳I, LHand﹌?﹌Ｙ E╳使╳iiAI AO﹌﹠A ╳芋使╳﹌?i E╳使╳iiA╳i ╳取╳０﹌﹠e╳５I “／﹌／﹌?“IA“見﹌﹠U - NeverDie
		if( IsBowOrFishingRod( a_Info ) )
		{
			if( m_equipItem[ EQUIPITEM_LHand ].GetItem( 0, TheItemInfo ) )
			{
				if( IsArrow( TheItemInfo ) )
					ClearLHand = false;
			}
		}

		if( ClearLHand )	//LRHAND ╳芋使╳﹌?i﹌?﹌Ｙ﹠i﹠i ex1 , ex2 ╳芋﹌Ｙ AO﹌﹠A╳芋O AO╳芋i “u使見﹌﹠A╳芋O AO“ui“u╳使 ﹠iu╳５I A使帚﹌／﹌c╳芋﹌Ｙ CE﹌?aCO﹌﹠I﹌﹠U. ;; -innowind
		{
			if(Len(a_Info.IconNameEx1) !=0)
			{
				RHand = a_info;
				LHand = a_info;				
				RHand.IconIndex = 1;
				LHand.IconIndex = 2;
				//RHand.IconName = a_Info.IconNameEx1;
				//LHand.IconName = a_Info.IconNameEx2;
				m_equipItem[ EQUIPITEM_RHand ].Clear();
				m_equipItem[ EQUIPITEM_RHand ].AddItem( RHand );	
				//m_equipItem[ EQUIPITEM_RHand ].DisableWindow();
				m_equipItem[ EQUIPITEM_LHand ].Clear();
				m_equipItem[ EQUIPITEM_LHand ].AddItem( LHand );
				m_equipItem[ EQUIPITEM_LHand ].DisableWindow();
				hItemWnd = None;	// “u“╳AIAU AI使oIAo╳芋﹌Ｙ “／﹌／AIAo “uE﹠i﹠i╳５I ╳取a“／╳i “u使帚A﹌╞A╳i “u使見“uOA“見﹌﹠U.
			}
			else	// E╳芋AI使帚“﹟ A╳E╳芋╳芋AI “u“╳AIAUAI使oIAo﹌Ou ﹌OE╳芋╳芋A“／ ╳芋使╳﹌?i.
			{
				m_equipItem[ EQUIPITEM_LHand ].Clear();
				m_equipItem[ EQUIPITEM_LHand ].AddItem( a_Info );
				m_equipItem[ EQUIPITEM_LHand ].DisableWindow();				
			}
			
		}
		break;
	case 32768:	// SBT_ONEPIECE
		hItemWnd = m_equipItem[ EQUIPITEM_Chest ];
		Legs = a_Info;
		Legs.IconName = a_Info.IconNameEX2;	//CIAC “u“╳AIAUA╳i ╳取╳０╳５AA“見﹌﹠U. 
		m_equipItem[ EQUIPITEM_Legs ].Clear();		
		m_equipItem[ EQUIPITEM_Legs ].AddItem( Legs );
		m_equipItem[ EQUIPITEM_Legs ].DisableWindow();	
		break;
	case 65536:	// SBT_HAIR
		hItemWnd = m_equipItem[ EQUIPITEM_Hair ];
		break;
	case 131072:	// SBT_ALLDRESS
		hItemWnd = m_equipItem[ EQUIPITEM_Chest ];
		Hair2 = a_info;	//﹌?使見╳５﹌Ｙ﹌﹠A head╳芋﹌Ｙ ﹠iu╳５IAO“ui“u使／ CIAo﹌／﹌／ ﹌／“〝﹌／使﹟﹌／﹌c Ay“uaA╳A﹌?使見﹌?﹌Ｙ“u╳使 hair2﹌?﹌Ｙ 使帚O“oA﹌﹠I﹌﹠U. - innowind
		Gloves = a_info;
		Legs = a_info;
		Feet = a_info;
		Hair2.IconName = a_Info.IconNameEx1;
		Gloves.IconName = a_Info.IconNameEx2;
		Legs.IconName = a_Info.IconNameEx3;
		Feet.IconName = a_Info.IconNameEx4;
		m_equipItem[ EQUIPITEM_Head ].Clear();
		m_equipItem[ EQUIPITEM_Head ].AddItem( Hair2 );
		m_equipItem[ EQUIPITEM_Head ].DisableWindow();
		m_equipItem[ EQUIPITEM_Gloves ].Clear();
		m_equipItem[ EQUIPITEM_Gloves ].AddItem( Gloves );
		m_equipItem[ EQUIPITEM_Gloves ].DisableWindow();
		m_equipItem[ EQUIPITEM_Legs ].Clear();
		m_equipItem[ EQUIPITEM_Legs ].AddItem( Legs );
		m_equipItem[ EQUIPITEM_Legs ].DisableWindow();
		m_equipItem[ EQUIPITEM_Feet ].Clear();
		m_equipItem[ EQUIPITEM_Feet ].AddItem( Feet );
		m_equipItem[ EQUIPITEM_Feet ].DisableWindow();
		break;
	case 262144:	// SBT_HAIR2
		hItemWnd = m_equipItem[ EQUIPITEM_Hair2 ];
		hItemWnd.EnableWindow();
		break;
	case 524288:	// SBT_HAIRALL
		hItemWnd = m_equipItem[ EQUIPITEM_Hair ];
		//Hair2 = a_info;
		//Hair2.IconName = a_Info.IconNameEx2;
		m_equipItem[ EQUIPITEM_Hair2 ].Clear();
		m_equipItem[ EQUIPITEM_Hair2 ].AddItem( a_info );
		m_equipItem[ EQUIPITEM_Hair2 ].DisableWindow();
		break;
	}

	if( None != hItemWnd )
	{
		hItemWnd.Clear();
		hItemWnd.AddItem( a_Info );
	}
}

function HandleOpenWindow()
{
	LoadItemOrder();

	ShowWindow(m_WindowName);
	class'UIAPI_WINDOW'.static.SetFocus(m_WindowName);
}

function HandleHideWindow()
{
	HideWindow(m_WindowName);
}

function HandleAddItem(string param)
{
	local ItemInfo	info;

	//debug("Inventory AddItem : "$param);
	ParamToItemInfo( param, info );

	if( IsEquipItem(info) )
		EquipItemUpdate( info );
	else if( IsQuestItem(info) )
		m_questItem.AddItem( info );
	else 
		m_invenItem.AddItem( info );
}

function HandleUpdateItem(string param)
{
	local string	type;
	local ItemInfo	info;
	local int		index;

	//debug("Inventory UpdateItem : " $ param);
	ParseString( param, "type", type );
	ParamToItemInfo( param, info );

	if( type == "add" )
	{
		if( IsEquipItem(info) )
			EquipItemUpdate( info );
		else if( IsQuestItem(info) )
		{
			m_questItem.AddItem(info);
			index = m_questItem.GetItemNum() - 1;
			while( index > 0 )						// A|AI “uOA﹌／╳５I!
			{
				m_questItem.SwapItems(index-1, index);
				--index;
			}
		}
		else
		{
			m_invenItem.AddItem(info);
			index = m_invenItem.GetItemNum() - 1;
			while( index > 0 )						// A|AI “uOA﹌／╳５I!
			{
				m_invenItem.SwapItems(index-1, index);
				--index;
			}
		}
	}
	else if( type == "update" )
	{
		if( IsEquipItem(info) )
		{
			if( EquipItemFind(info.ServerID) )		// match found
			{
				EquipItemUpdate( info );
			}
			else			// not found in equipItemList. In this case, move the item from InvenItemList to EquipItemList
			{
				index = m_invenItem.FindItemWithServerID(info.ServerID);
				if( index != -1 )
					m_invenItem.DeleteItem(index);
				EquipItemUpdate( info );
			}
		}
		else if( IsQuestItem(info) )
		{
			index = m_questItem.FindItemWithServerID(info.ServerID);
			if( index != -1 )
			{
				m_questItem.SetItem(index, info);
			}
			else		// In this case, Equipped item is being unequipped.
			{
				EquipItemDelete(info.ServerID);
				m_questItem.AddItem(info);
			}
		}
		else
		{
			index = m_invenItem.FindItemWithServerID(info.ServerID);
			if( index != -1 )
			{
				m_invenItem.SetItem( index, info );
			}
			else		// In this case, Equipped item is being unequipped.
			{
				EquipItemDelete(info.ServerID);
				m_invenItem.AddItem(info);
				index = m_invenItem.GetItemNum() - 1;
				while( index > 0 )						// A|AI “uOA﹌／╳５I!
				{
					m_invenItem.SwapItems(index-1, index);
					--index;
				}
			}
		}
	}
	else if( type == "delete" )
	{
		if( IsEquipItem(info) )
		{
			EquipItemDelete(info.ServerID);
		}
		else if( IsQuestItem(info) )
		{
			index = m_questItem.FindItemWithServerID(info.ServerID);
			m_questItem.DeleteItem(index);
		}
		else
		{
			index = m_invenItem.FindItemWithServerID(info.ServerID);
			m_invenItem.DeleteItem(index);
		}
	}

	SetAdenaText();
	SetItemCount();
}

function HandleItemListEnd()
{
	SetAdenaText();
	SetItemCount();
	OrderItem();
}

function HandleAddHennaInfo(string param)
{
	/*
	local int hennaID, isActive;

	ParseInt( param, "ID", hennaID );
	ParseInt( param, "bActive", isActive );
	*/
	UpdateHennaInfo();
}

function HandleUpdateHennaInfo(string param)
{
	UpdateHennaInfo();
}

function UpdateHennaInfo()
{
	local int i;
	local int HennaInfoCount;
	local int HennaID;
	local int IsActive;
	local ItemInfo HennaItemInfo;
	local UserInfo PlayerInfo;
	local int ClassStep;

	if( GetPlayerInfo( PlayerInfo ) )
	{
		ClassStep = GetClassStep( PlayerInfo.nSubClass );
		switch( ClassStep )
		{
		case 1:
		case 2:
		case 3:
			m_hHennaItemWindow.SetRow( ClassStep );
			break;
		default:
			m_hHennaItemWindow.SetRow( 0 );
			break;
		}
	}

	m_hHennaItemWindow.Clear();

	HennaInfoCount = class'HennaAPI'.static.GetHennaInfoCount();
	if( HennaInfoCount > ClassStep )
		HennaInfoCount = ClassStep;

	for( i = 0; i < HennaInfoCount; ++i )
	{
		if( class'HennaAPI'.static.GetHennaInfo( i, HennaID, IsActive ) )
		{
			if( !class'UIDATA_HENNA'.static.GetItemName( HennaID, HennaItemInfo.Name ) )
				break;
			if( !class'UIDATA_HENNA'.static.GetDescription( HennaID, HennaItemInfo.Description ) )
				break;
			if( !class'UIDATA_HENNA'.static.GetIconTex( HennaID, HennaItemInfo.IconName ) )
				break;

			if( 0 == IsActive )
				HennaItemInfo.bDisabled = true;
			else
				HennaItemInfo.bDisabled = false;

			m_hHennaItemWindow.AddItem( HennaItemInfo );			
		}
	}
}

function SetAdenaText()
{
	local string adenaString;
	
	adenaString = MakeCostString( string(GetAdena()) );

	m_hAdenaTextBox.SetText(adenaString);
	m_hAdenaTextBox.SetTooltipString( ConvertNumToText(string(GetAdena())) );
	//debug("SetAdenaText " $ adenaString );
}

function UseItem( ItemWindowHandle a_hItemWindow, int index )
{
	local ItemInfo	info;

	if( a_hItemWindow.GetItem(index, info) )
	{
		if( info.bRecipe )					// A|A﹌O使oy(╳５使o“oACC)﹌／| ╳ic﹌?eCO ╳芋IAIAo 使o╳芋“ui“／╳i﹌﹠U
		{
			DialogSetReservedInt(info.ServerID);
			DialogSetID(DIALOG_USE_RECIPE);
			DialogShow(DIALOG_Warning, GetSystemMessage(798));
		}
		else if( info.PopMsgNum > 0 )			// “╳E“u╳A ﹌／“〝“oAAo﹌／| “／﹌／﹌?“IA“見﹌﹠U.
		{
			DialogSetID(DIALOG_POPUP);
			DialogSetReservedInt(info.ServerID);
			DialogShow(DIALOG_Warning, GetSystemMessage(info.PopMsgNum));
		}
		else
		{
			RequestUseItem(info.ServerID);
		}
	}
}

// Save item order to m_itemOrder and file
function SaveItemOrder()
{
	local ItemInfo info;
	local int i;
	//local int orderIndex;		// for debugging
	
	m_itemOrder.Length = m_invenItem.GetItemNum();
	for( i=0 ; i < m_itemOrder.Length ; ++i )
	{
		m_invenItem.GetItem( i, info );
		m_itemOrder[i] = info.ClassID;
	}

	// for debugging only
	//debug("SaveItemOrder");
	//for( orderIndex=0; orderIndex < m_itemOrder.Length ; ++orderIndex )
	//{
	//	debug("order " $ orderIndex $ " ClassID " $ m_itemOrder[orderIndex]);
	//}

	SaveInventoryOrder( m_itemOrder );
}

// Load item order from file
function LoadItemOrder()
{
	//local int orderIndex;		// for debugging
	LoadInventoryOrder( m_itemOrder );
	//// for debugging only
	//debug("LoadItemOrder");
	//for( orderIndex=0; orderIndex < m_itemOrder.Length ; ++orderIndex )
	//{
	//	debug("order " $ orderIndex $ " ClassID " $ m_itemOrder[orderIndex]);
	//}
}

// order m_invenItem according to m_itemOrder
function OrderItem()
{
	local int newItemIndex, itemNum, itemIndex, orderIndex;
	local ItemInfo info;
	local bool	matched;

	//// for debugging only
	//debug("OrderItem");
	//for( orderIndex=0; orderIndex < m_itemOrder.Length ; ++orderIndex )
	//{
	//	debug("order " $ orderIndex $ " ClassID " $ m_itemOrder[orderIndex]);
	//}

	// Move new items(which is not in orderList) to heade of ItemList
	newItemIndex = 0;
	itemNum = m_invenItem.GetItemNum();
	for( itemIndex=0 ; itemIndex < itemNum ; ++itemIndex )
	{
		m_invenItem.GetItem(itemIndex, info);
		matched = false;
		for( orderIndex=0 ; orderIndex < m_itemOrder.Length ; ++orderIndex )
		{
			if(info.ClassID == m_itemOrder[orderIndex])			// match found
			{
				matched = true;
				break;
			}
		}

		if( !matched )
		{
			m_invenItem.SwapItems(itemIndex, newItemIndex);		// If these index are equal, nothing happens in ItemWindow.
			//debug("OrderItem : new item(" $ info.Name $ "," $ info.ClassID $ ") index " $ itemIndex $ ", moved to " $ newItemIndex );
			++newItemIndex;
		}
	}
	
	// New items(which is not in orderList) are now head of the itemList

	for( orderIndex=0; orderIndex < m_itemOrder.Length ; ++orderIndex )
	{
		for( itemIndex=0; itemIndex < itemNum ; ++itemIndex )
		{
			m_invenItem.GetItem( itemIndex, info );
			if(info.ClassID == m_itemOrder[orderIndex])			// Match
			{		// Move this item to newItemIndex
				m_invenItem.SwapItems( itemIndex, newItemIndex );
				//debug("OrderItem : ordering item(" $ info.Name $ "," $info.ClassID $ ") index " $ itemIndex $ ", moved to " $ newItemIndex );
				++newItemIndex;
				break;
			}
		}
	}
}

function int GetMyInventoryLimit()
{
	return class'UIDATA_PLAYER'.static.GetInventoryLimit();
}

function SetItemCount()
{
	local int limit;
	local int count;
	local TextBoxHandle handle;

	count = m_invenItem.GetItemNum() + m_questItem.GetItemNum() + EquipItemGetItemNum();
	limit = GetMyInventoryLimit();

	handle = TextBoxHandle(GetHandle(m_WindowName $ ".ItemCount"));
	handle.SetText("(" $ count $ "/" $ limit $ ")");
	//debug("SetItemCount : count " $ count $ ", limit : " $ limit );
}

function HandleDialogOK()
{
	local int id, reserved, reserved2, number;
	if( DialogIsMine() )
	{
		id = DialogGetID();
		reserved = DialogGetReservedInt();			// ServerID
		reserved2 = DialogGetReservedInt2();
		number = int(DialogGetString());
		if( id == DIALOG_USE_RECIPE || id == DIALOG_POPUP )
		{
			RequestUseItem(reserved);							// reserved(serverID)
		}
		else if( id == DIALOG_DROPITEM )
		{
			RequestDropItem( reserved, 1, m_clickLocation );
		}
		else if( id == DIALOG_DROPITEM_ASKCOUNT )
		{
			if(number == 0) 
				number = 1;					// “u“╳使o╳i “uyAU﹠i﹠i AO╳５ACIAo “uEA﹌／﹌／e 1╳芋使帚 ﹠ia﹌O使見A﹌／╳５I A使帚﹌／﹌c
			RequestDropItem( reserved, number, m_clickLocation );
		}
		else if( id == DIALOG_DROPITEM_ALL )
		{
			RequestDropItem( reserved, reserved2, m_clickLocation );
		}
		else if( id == DIALOG_DESTROYITEM )
		{
			RequestDestroyItem(reserved, 1);
			PlayConsoleSound(IFST_TRASH_BASKET);
		}
		else if( id == DIALOG_DESTROYITEM_ASKCOUNT )
		{
			RequestDestroyItem(reserved, number);
			PlayConsoleSound(IFST_TRASH_BASKET);
		}
		else if( id == DIALOG_DESTROYITEM_ALL)
		{
			RequestDestroyItem(reserved, reserved2);
			PlayConsoleSound(IFST_TRASH_BASKET);
		}
		else if( id == DIALOG_CRYSTALLIZE )
		{
			RequestCrystallizeItem(reserved,1);
			PlayConsoleSound(IFST_TRASH_BASKET);
		}
		else if ( id == DIALOG_DROPITEM_PETASKCOUNT )
		{
			class'PetAPI'.static.RequestGetItemFromPet( reserved, number, false);
		}
	}
}

function HandleUpdateUserInfo()
{
	if( m_hOwnerWnd.IsShowWindow() )
	{
		EarItemUpdate();
		FingerItemUpdate();
	}
}

function HandleToggleWindow()
{
	if( m_hOwnerWnd.IsShowWindow() )
	{
		m_hOwnerWnd.HideWindow();
		PlayConsoleSound(IFST_INVENWND_CLOSE);
	}
	else
	{
		if( IsShowInventoryWndUponEvent() )
		{
			RequestItemList();
			m_hOwnerWnd.ShowWindow();
			PlayConsoleSound(IFST_INVENWND_OPEN);
		}
	}
}

//╳芋使帚AIA╳E╳芋i, C╳A﹌／IA╳E╳芋i, E╳使使o╳芋A╳E╳芋i, ╳取使帚E?A╳E, ╳ioA﹌Ｙ╳取﹌／﹌／A, “╳C﹌／AA╳E, ╳芋使帚AI“╳C﹌／A, ╳芋使帚AI╳取﹌／﹌／A A╳EAI ﹌O╳芋AOA╳i ╳芋使╳﹌?i 使o╳i“oACI﹌﹠A ╳５c“╳“u
//﹌﹠U﹌／╳I╳ic﹌O╳AAC ╳芋使帚AI╳ioA﹌Ｙ A╳E﹌?﹌Ｙ“u╳使 使帚╳i╳芋﹌Ｙ ╳取﹌／﹌／ACO﹌O╳▼﹌﹠A ﹌?╳使╳５A“u使／CO --;; - innowind
function bool IsShowInventoryWndUponEvent()
{
	local WindowHandle m_warehouseWnd;
	local WindowHandle m_privateShopWnd;
	local WindowHandle m_tradeWnd;
	local WindowHandle m_shopWnd;
	local WindowHandle m_multiSellWnd;
	local WindowHandle m_deliverWnd;
	local PrivateShopWnd m_scriptPrivateShopWnd;
	
	m_warehouseWnd = GetHandle( "WarehouseWnd" );		//╳芋使帚AIA╳E╳芋i, C╳A﹌／IA╳E╳芋i, E╳使使o╳芋A╳E╳芋i
	m_privateShopWnd = GetHandle( "PrivateShopWnd" );	//╳芋使帚AI“╳C﹌／A, ╳芋使帚AI╳取﹌／﹌／A
	m_tradeWnd = GetHandle( "TradeWnd" );				//╳取使帚E?
	m_shopWnd = GetHandle( "ShopWnd" );				//╳ioA﹌Ｙ╳取﹌／﹌／A, “╳C﹌／A
	m_multiSellWnd = GetHandle( "MultiSellWnd" );				//╳ioA﹌Ｙ╳取﹌／﹌／A, “╳C﹌／A
	m_deliverWnd = GetHandle( "DeliverWnd" );				//E╳使使o╳芋“u╳使“／n“o“／
	m_scriptPrivateShopWnd = PrivateShopWnd( GetScript("PrivateShopWnd") );

	if( m_warehouseWnd.IsShowWindow() )
		return false;

	if( m_warehouseWnd.IsShowWindow() )
		return false;

	if( m_tradeWnd.IsShowWindow() )
		return false;
	
	if( m_shopWnd.IsShowWindow() )
		return false;
	
	if( m_multiSellWnd.IsShowWindow() )
		return false;
	
	if( m_deliverWnd.IsShowWindow() )
		return false;
	
	if( m_privateShopWnd.IsShowWindow() && m_scriptPrivateShopWnd.m_type == PT_Sell )
		return false;

	return true;
}

function int IsLOrREar( int a_ServerID )
{
	local int LEar;
	local int REar;
	local int LFinger;
	local int RFinger;

	GetAccessoryServerID( LEar, REar, LFinger, RFinger );

	if( a_ServerID == LEar )
		return -1;
	else if( a_ServerID == REar )
		return 1;
	else
		return 0;
}

function int IsLOrRFinger( int a_ServerID )
{
	local int LEar;
	local int REar;
	local int LFinger;
	local int RFinger;

	GetAccessoryServerID( LEar, REar, LFinger, RFinger );

	if( a_ServerID == LFinger )
		return -1;
	else if( a_ServerID == RFinger )
		return 1;
	else
		return 0;
}

function bool IsBowOrFishingRod( ItemInfo a_Info )
{
	if( 6 == a_Info.WeaponType || 10 == a_Info.WeaponType )
		return true;

	return false;
}

function bool IsArrow( ItemInfo a_Info )
{
	return a_Info.bArrow;
}

// ==== SHIFT detection (ajuste se seu build usar outra API) ====
function bool IsShiftDown()
{
    // Alguns builds usam UIAPI_WINDOW, outros tem constantes IK_LShift/IK_RShift.
    // Se necessario, troque 16 por IK_LShift/IK_RShift.
    return IsKeyDown(EInputKey(16)); // 16 = VK_SHIFT
}

// ==== Base36 para encurtar numeros no token ====
function string ToBase36(int v)
{
    local string digs, out; local int n, r;
    digs = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    if (v <= 0) return "0";
    n = v;
    while (n > 0) { r = n % 36; out = Mid(digs, r, 1) $ out; n = n / 36; }
    return out;
}
function int FromBase36(string s)
{
    local string digs; local int i, v, idx;
    digs = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"; v = 0;
    for (i = 0; i < Len(s); ++i) { idx = InStr(digs, Mid(s, i, 1)); if (idx >= 0) v = v*36 + idx; }
    return v;
}

// ==== Monta o token e insere no ChatEditBox ====
function string MakeItemLinkToken(ItemInfo info)
{
    // Formato compacto: [[I:<CID>:<EN>:<OP1>:<OP2>]]?   (Base36 para encurtar)
    return "[[I:" $ ToBase36(info.ClassID) $ ":" $ ToBase36(info.Enchanted)
        $ ":" $ ToBase36(info.RefineryOp1) $ ":" $ ToBase36(info.RefineryOp2) $ "]]?";
}

function PasteItemLinkToChat(ItemInfo info)
{
    local string token, cur;
    local ChatWnd CW;

    token = MakeItemLinkToken(info);
    CW = ChatWnd(GetScript("ChatWnd"));
    if (CW == None) return;

    cur = CW.ChatEditBox.GetString();
    if (Len(cur) > 0 && Right(cur,1) != " ")
        cur = cur $ " ";
    CW.ChatEditBox.SetString(cur $ token);
    CW.ChatEditBox.SetFocus();
    // opcional: som de feedback
    // PlayConsoleSound(IFST_ITEM_LINE);
}


defaultproperties
{
    m_WindowName="InventoryWnd"
}