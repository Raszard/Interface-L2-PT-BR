class ShopWnd extends UICommonAPI;

const DIALOG_TOP_TO_BOTTOM = 111;
const DIALOG_BOTTOM_TO_TOP = 222;
const DIALOG_PREVIEW	= 333;

enum ShopType		// ���� ���� �ִ� â�� ����â���� ����â���� ��Ÿ����
{
	ShopNone,		// Invalid type
	ShopBuy,
	ShopSell,
	ShopPreview,
};

var String m_WindowName;		// ��ӿ� ����Ϸ��� ������ �̸� �߰� - lancelot 2006. 11. 27.

var ShopType m_shopType;
var int		m_merchantID;
var int		m_npcID;	// only for shoppreveiw
var INT64	m_currentPrice;		// ����/�Ǹ� ��Ͽ� �÷����� �������� ������ �ջ��� ��

function OnLoad()
{
	registerEvent( EV_ShopOpenWindow );
	registerEvent( EV_ShopAddItem );
	registerEvent( EV_DialogOK );

}

function Clear()
{
	m_shopType = ShopNone;
	m_merchantID = -1;
	m_npcID = -1;
	m_currentPrice = Int2Int64(0);

	class'UIAPI_ITEMWINDOW'.static.Clear(m_WindowName$".TopList");
	class'UIAPI_ITEMWINDOW'.static.Clear(m_WindowName$".BottomList");

	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".PriceText", "0");
	class'UIAPI_TEXTBOX'.static.SetTooltipString(m_WindowName$".PriceText", "");

	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".AdenaText", "0");
	class'UIAPI_TEXTBOX'.static.SetTooltipString(m_WindowName$".AdenaText", "");

	class'UIAPI_INVENWEIGHT'.static.ZeroWeight(m_WindowName$".InvenWeight");
}

function OnEvent(int Event_ID,string param)
{
	switch( Event_ID )
	{
	case EV_ShopOpenWindow:
		HandleOpenWindow(param);
		break;
	case EV_ShopAddItem:
		HandleAddItem(param);
		break;
	case EV_DialogOK:
		HandleDialogOK();
		break;
	default:
		break;
	}
}

function OnClickButton( string ControlName )
{
	local int index;
	if( ControlName == "UpButton" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.GetSelectedNum( m_WindowName$".BottomList" );
		MoveItemBottomToTop( index, false );
	}
	else if( ControlName == "DownButton" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.GetSelectedNum( m_WindowName$".TopList" );
		MoveItemTopToBottom( index, false );
	}
	else if( ControlName == "OKButton" )
	{
		HandleOKButton();
	}
	else if( ControlName == "CancelButton" )
	{
		Clear();
		HideWindow(m_WindowName);
	}
}

function OnDBClickItem( string ControlName, int index )
{
	if(ControlName == "TopList")
	{
		MoveItemTopToBottom( index, false );
	}
	else if(ControlName == "BottomList")
	{
		MoveItemBottomToTop( index, false );
	}

}

function OnDropItem( string strID, ItemInfo info, int x, int y)
{
	local int index;
	//debug("OnDropItem strID " $ strID $ ", src=" $ info.DragSrcName);
	if( strID == "TopList" && info.DragSrcName == "BottomList" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( m_WindowName$".BottomList", info.ClassID );
		if( index >= 0 )
			MoveItemBottomToTop( index, info.AllItemCount > 0 );
	}
	else if( strID == "BottomList" && info.DragSrcName == "TopList" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( m_WindowName$".TopList", info.ClassID );
		if( index >= 0 )
			MoveItemTopToBottom( index, info.AllItemCount > 0 );
	}
}

function MoveItemTopToBottom( int index, bool bAllItem )
{
	local int bottomIndex;
	local ItemInfo info, bottomInfo;
	if( class'UIAPI_ITEMWINDOW'.static.GetItem(m_WindowName$".TopList", index, info) )
	{
		// 1�ϰ�� ������ �Է��ϴ� ���̾�α״� ������� �ʴ´�.
//		debug("info.ConsumeType:"$info.ConsumeType$", ����:"$info.ItemNum);
		if( !bAllItem && IsStackableItem( info.ConsumeType ) && (info.ItemNum!=1) )		// stackable?
		{
			DialogSetID( DIALOG_TOP_TO_BOTTOM );
			DialogSetReservedInt( info.ClassID );
			DialogSetDefaultOK();
			if( m_shopType == ShopSell )
				DialogSetParamInt( info.ItemNum );
			else
				DialogSetParamInt(-1);
			
			DialogSetDefaultOK();	
			DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name, "" ) );
		}
		else
		{
			info.bShowCount = false;

			if( m_shopType == ShopSell )
			{
				bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( m_WindowName$".BottomList", info.ClassID );
				if( bottomIndex >= 0 && IsStackableItem( info.ConsumeType ) )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".BottomList", bottomIndex, bottomInfo );
					bottomInfo.ItemNum += info.ItemNum;
					class'UIAPI_ITEMWINDOW'.static.SetItem( m_WindowName$".BottomList", bottomIndex, bottomInfo);
				}
				else
				{
					class'UIAPI_ITEMWINDOW'.static.AddItem( m_WindowName$".BottomList", info );
				}
				class'UIAPI_ITEMWINDOW'.static.DeleteItem( m_WindowName$".TopList", index );		// ������ �� ��� �ڽ��� �κ��丮 ��Ͽ��� �������� ����
			}
			else if( m_shopType == ShopBuy )												// ���� �ٿ� �߰��Ǵ� ���Ը�ŭ ���� �ش�.
			{
				info.ItemNum = 1;				// ���� ������ ��� ItemNum�� ���� �Ǿ� ���� ���� ��찡 �ֱ� ������ �Ϻη� 1�� �� ����Ѵ�.
				class'UIAPI_ITEMWINDOW'.static.AddItem( m_WindowName$".BottomList", info );
				class'UIAPI_INVENWEIGHT'.static.AddWeight( m_WindowName$".InvenWeight", info.Weight * info.ItemNum );
			}
			else if( m_shopType == ShopPreview)	//�̸�����
			{
				bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( m_WindowName$".BottomList", info.ClassID );
				info.ItemNum = 1;
				class'UIAPI_ITEMWINDOW'.static.AddItem( m_WindowName$".BottomList", info );				
			}
			AddPrice(Int64Mul(info.Price, info.ItemNum));

		}
	}
}

function MoveItemBottomToTop( int index, bool bAllItem )
{
	local ItemInfo info, info2;
	local int bottomIndex;
	if( class'UIAPI_ITEMWINDOW'.static.GetItem(m_WindowName$".BottomList", index, info) )
	{
		if( !bAllItem && IsStackableItem( info.ConsumeType ) )		// stackable?
		{
			DialogSetID( DIALOG_BOTTOM_TO_TOP );
			DialogSetDefaultOK();
			DialogSetReservedInt( info.ClassID );
			DialogSetParamInt( info.ItemNum );
			DialogSetDefaultOK();	
			DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name, "" ) );
		}
		else
		{
			class'UIAPI_ITEMWINDOW'.static.DeleteItem( m_WindowName$".BottomList", index );
			if( m_shopType == ShopSell )
			{
				bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( m_WindowName$".TopList", info.ServerID );
				if( bottomIndex == -1 )
				{
					class'UIAPI_ITEMWINDOW'.static.AddItem( m_WindowName$".TopList", info );			// ������ �Ǹ��ϴ� ��� �ٽ� �ڽ��� �κ��丮 �������
				}
				else
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem(m_WindowName$".TopList", bottomIndex, info2);
					info2.ItemNum += info.ItemNum;
					class'UIAPI_ITEMWINDOW'.static.SetItem(m_WindowName$".TopList", bottomIndex, info2);
				}
			}
			else if( m_shopType == ShopBuy )												// ���� �ٿ� �߰��Ǵ� ���Ը�ŭ �� �ش�.
			{
				class'UIAPI_INVENWEIGHT'.static.ReduceWeight( m_WindowName$".InvenWeight", info.Weight * info.ItemNum );
			}
			AddPrice(Int64Mul(-info.Price, info.ItemNum));
		}
	}
}

function HandleDialogOK()
{
	local int id, num, classID, index, topIndex;
	local ItemInfo info, topInfo;
	local string param;

	if( DialogIsMine() )
	{
		id = DialogGetID();
		num = int( DialogGetString() );
		classID = DialogGetReservedInt();
		if( id == DIALOG_TOP_TO_BOTTOM && num > 0 )
		{
			topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( m_WindowName$".TopList", classID );
			if( topIndex >= 0 )
			{
				class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".TopList", topIndex, topInfo );
				if( m_shopType == ShopSell )
					num = Min(num, topInfo.ItemNum);			// ���̾�α׿��� ������ ���� �Է��ϴ� �� ����.
				index = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( m_WindowName$".BottomList", classID );
				if( index >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".BottomList", index, info );
					info.ItemNum += num;
					class'UIAPI_ITEMWINDOW'.static.SetItem( m_WindowName$".BottomList", index, info );
					AddPrice( Int64Mul(num, info.Price) );
				}
				else
				{
					info = topInfo;
					info.ItemNum = num;
					info.bShowCount = false;
					class'UIAPI_ITEMWINDOW'.static.AddItem( m_WindowName$".BottomList", info );
					AddPrice( Int64Mul(num, info.Price) );
				}

				if( m_shopType == ShopSell )		// �Ǹ��� ��� �ڽ��� �κ��丮 ����� ������ ������ �ش�(������ ��� ������ ���� ������ ���ڴ� �ǹ̰� ����)
				{
					topInfo.ItemNum -= num;
					if( topInfo.ItemNum <= 0 )
						class'UIAPI_ITEMWINDOW'.static.DeleteItem( m_WindowName$".TopList", topIndex );
					else
						class'UIAPI_ITEMWINDOW'.static.SetItem( m_WindowName$".TopList", topIndex, topInfo );
				}
				else if( m_shopType == ShopBuy )												// ���� �ٿ� �߰��Ǵ� ���Ը�ŭ ���� �ش�.
				{
					class'UIAPI_INVENWEIGHT'.static.AddWeight( m_WindowName$".InvenWeight", info.Weight * num );
				}
			}
		}
		else if( id == DIALOG_BOTTOM_TO_TOP && num > 0 )
		{
			index = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( m_WindowName$".BottomList", classID );
			if( index >= 0 )
			{
				class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".BottomList", index, info );
				info.ItemNum -= num;
				if( info.ItemNum > 0 )
					class'UIAPI_ITEMWINDOW'.static.SetItem( m_WindowName$".BottomList", index, info );
				else 
					class'UIAPI_ITEMWINDOW'.static.DeleteItem( m_WindowName$".BottomList", index );

				if( m_shopType == ShopSell )
				{
					topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( m_WindowName$".TopList", classID );
					if( topIndex >=0 && IsStackableItem( info.ConsumeType ) )
					{
						class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".TopList", topIndex, topInfo );
						topInfo.ItemNum += num;
						class'UIAPI_ITEMWINDOW'.static.SetItem( m_WindowName$".TopList", topIndex, topInfo );
					}
					else
					{
						info.ItemNum = num;
						class'UIAPI_ITEMWINDOW'.static.AddItem( m_WindowName$".TopList", info );
					}
				}
				else if( m_shopType == ShopBuy )												// ���� �ٿ� �߰��Ǵ� ���Ը�ŭ �� �ش�.
				{
					class'UIAPI_INVENWEIGHT'.static.ReduceWeight( m_WindowName$".InvenWeight", info.Weight * num );
				}
				
				if( info.ItemNum <= 0 )	// ������ ������ �Ǵ� ���� �����ϱ� ����
					num = info.ItemNum + num;

				AddPrice( Int64Mul(-num, info.Price) );
			}
		}
		else if( id == DIALOG_PREVIEW )
		{
			num = class'UIAPI_ITEMWINDOW'.static.GetItemNum( m_WindowName$".BottomList" );

			if( num > 0 )
			{
				// pack every item in BottomList
				ParamAdd( param, "merchant", string(m_merchantID) );
				ParamAdd( param, "npc", string(m_npcID) );
				ParamAdd( param, "num", string(num) );
				for( index=0 ; index < num; ++index )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".BottomList", index, info);
					ParamAdd( param, "classID" $ index, string(info.ClassID) );
				}

				RequestPreviewItem( param );
			}
		}
	}
}

function HandleOpenWindow( string param )
{
	local string type;
	local int adena;
	local string adenaString;

	local WindowHandle m_inventoryWnd;	// �κ��丮 �ڵ� ����.
	
	m_inventoryWnd = GetHandle( "InventoryWnd" );	//�κ��丮�� ������ �ڵ��� ���´�.

	Clear();

	ParseString( param, "type", type );
	ParseInt( param, "merchant", m_merchantID ); 
	ParseInt( param, "adena", adena );

	if( type == "buy" )
		m_shopType = ShopBuy;
	else if( type == "sell" )
		m_shopType = ShopSell;
	else if( type == "preview" )
		m_shopType = ShopPreview;
	else
		m_shopType = ShopNone;

	adenaString = MakeCostString( string(adena) );
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".AdenaText", adenaString);
	class'UIAPI_TEXTBOX'.static.SetTooltipString(m_WindowName$".AdenaText", ConvertNumToText(string(adena)) );

	if( m_inventoryWnd.IsShowWindow() )			//�κ��丮 â�� ���������� �ݾ��ش�. 
	{
		m_inventoryWnd.HideWindow();
	}
	ShowWindow( m_WindowName );
	class'UIAPI_WINDOW'.static.SetFocus(m_WindowName);

	if( type == "buy" )
	{
		class'UIAPI_WINDOW'.static.SetTooltipType( m_WindowName$".TopList", "InventoryPrice1HideEnchantStackable" );
		class'UIAPI_WINDOW'.static.SetTooltipType( m_WindowName$".BottomList", "InventoryPrice1" );

		class'UIAPI_WINDOW'.static.SetWindowTitle(m_WindowName, 136);

		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".TopText", GetSystemString(137) );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".BottomText", GetSystemString(139) );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".PriceConstText", GetSystemString(142) );
	}
	else if( type == "sell" )
	{
		class'UIAPI_WINDOW'.static.SetTooltipType( m_WindowName$".TopList", "InventoryPrice2" );
		class'UIAPI_WINDOW'.static.SetTooltipType( m_WindowName$".BottomList", "InventoryPrice2" );

		class'UIAPI_WINDOW'.static.SetWindowTitle(m_WindowName, 136);

		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".TopText", GetSystemString(138) );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".BottomText", GetSystemString(137) );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".PriceConstText", GetSystemString(143) );
	}
	else if( type == "preview" )
	{
		ParseInt( param, "npc", m_npcID );

		class'UIAPI_WINDOW'.static.SetTooltipType( m_WindowName$".TopList", "InventoryPrice1HideEnchantStackable" );
		class'UIAPI_WINDOW'.static.SetTooltipType( m_WindowName$".BottomList", "InventoryPrice1" );

		class'UIAPI_WINDOW'.static.SetWindowTitle(m_WindowName, 847);

		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".TopText", GetSystemString(811) );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".BottomText", GetSystemString(812) );
		class'UIAPI_TEXTBOX'.static.SetText( m_WindowName$".PriceConstText", GetSystemString(813) );
	}
}

function HandleAddItem( string param )
{
	local ItemInfo info;
	
	ParamToItemInfo( param, info );
	if( m_shopType == ShopBuy && info.ItemNum > 0 )
		info.bShowCount = true;

	class'UIAPI_ITEMWINDOW'.static.AddItem( m_WindowName$".TopList", info );
}

function AddPrice( INT64 price )
{
	local string adena;
	m_currentPrice = Int64Add( m_currentprice, price );
	
	if(m_currentPrice.nLeft <0 || m_currentPrice.nRight <0)	//�⺻������ ������ �� ���� ���⶧����, ������ �Ǹ� �� 0�� �ѷ��ݴϴ�.
	{
		m_currentPrice = Int2Int64(0);	
	}
	
	adena = MakeCostStringInt64( m_currentPrice );
	class'UIAPI_TEXTBOX'.static.SetText(m_WindowName$".PriceText", adena);
	class'UIAPI_TEXTBOX'.static.SetTooltipString(m_WindowName$".PriceText", ConvertNumToText( Int64ToString(m_currentPrice)));
}

function HandleOKButton()
{
	local string	param;
	local int		topCount, bottomCount, topIndex, bottomIndex;
	local ItemInfo	topInfo, bottomInfo;
	local int		limitedItemCount;

	bottomCount = class'UIAPI_ITEMWINDOW'.static.GetItemNum( m_WindowName$".BottomList" );
//	debug("ShopWnd m_shopType:" $ m_shopType $ ", bottomCount:" $ bottomCount);
	if( m_shopType == ShopBuy )
	{
		// limited item check
		topCount = class'UIAPI_ITEMWINDOW'.static.GetItemNum( m_WindowName$".TopList" );
		for( topIndex=0 ; topIndex < topCount ; ++topIndex )
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".TopList", topIndex, topInfo );
			if(	topInfo.ItemNum > 0 )		// this item can be purchased only by limited number
			{
				limitedItemCount = 0;
				// search in BottomList for same classID
				bottomCount = class'UIAPI_ITEMWINDOW'.static.GetItemNum( m_WindowName$".BottomList" );
				for( bottomIndex=0; bottomIndex < bottomCount ; ++bottomIndex )		// match found, then check whether the number exceeds limited number
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".BottomList", bottomIndex, bottomInfo );
					if( bottomInfo.ClassID == topInfo.ClassID )
						limitedItemCount += bottomInfo.ItemNum;
				}

				//debug("limited Item count " $ limitedItemCount );
				if( limitedItemCount > topInfo.ItemNum )
				{
					// warning dialog
					DialogShow( DIALOG_WARNING, GetSystemMessage(1338) );
					return;
				}
			}
		}
		// pack every item in BottomList
		ParamAdd( param, "merchant", string(m_merchantID) );
		ParamAdd( param, "num", string(bottomCount) );
		for( bottomIndex=0 ; bottomIndex < bottomCount; ++bottomIndex )
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".BottomList", bottomIndex, bottomInfo );
			ParamAdd( param, "classID" $ bottomIndex, string(bottomInfo.ClassID) );
			ParamAdd( Param, "count" $ bottomIndex, string(bottomInfo.ItemNum) );
		}
		RequestBuyItem( param );
	}
	else if( m_shopType == ShopSell )
	{
		// pack every item in BottomList
		ParamAdd( param, "merchant", string(m_merchantID) );
		ParamAdd( param, "num", string(bottomCount) );
		for( bottomIndex=0 ; bottomIndex < bottomCount; ++bottomIndex )
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( m_WindowName$".BottomList", bottomIndex, bottomInfo );
			ParamAdd( param, "serverID" $ bottomIndex, string(bottomInfo.ServerID) );
			ParamAdd( param, "classID" $ bottomIndex, string(bottomInfo.ClassID) );
			ParamAdd( Param, "count" $ bottomIndex, string(bottomInfo.ItemNum) );
		}
		RequestSellItem( param );
	}
	else if( m_shopType == ShopPreview )
	{
		if( bottomCount > 0 )
		{
			DialogSetID( DIALOG_PREVIEW );
			DialogShow( DIALOG_Warning, GetSystemMessage(1157) );
		}
	}

	HideWindow(m_WindowName);
}

defaultproperties
{
    m_WindowName="ShopWnd"
}
