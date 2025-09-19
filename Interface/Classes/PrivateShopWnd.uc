class PrivateShopWnd extends UICommonAPI;

const DIALOG_TOP_TO_BOTTOM = 111;
const DIALOG_BOTTOM_TO_TOP = 222;
const DIALOG_ASK_PRICE	= 333;
const DIALOG_CONFIRM_PRICE = 444;
const DIALOG_EDIT_SHOP_MESSAGE = 555;			// �޽��� ����
const DIALOG_CONFIRM_PRICE_FINAL = 666;			// Ȯ�� ��ư �������� ������ Ȯ��
//const DIALOG_OVER_PRICE = 777;				// ���� ������ 20���� ������� ���� �޼���	//Ư���� ���̵� �Ҵ��� �ʿ�� ����δ�. 

enum PrivateShopType
{
	PT_None,			// dummy
	PT_Buy,				// �ٸ� ����� ���� �������� ������ ������ ��
	PT_Sell,			// �ٸ� ����� ���� �������� ������ �Ǹ��� ��
	PT_BuyList,			// �ڽ��� ���� ���� ���� ����Ʈ
	PT_SellList,		// �ڽ��� ���� ���� �Ǹ� ����Ʈ
};

var int				m_merchantID;
var PrivateShopType m_type;
var int				m_buyMaxCount;
var int				m_sellMaxCount;
var bool			m_bBulk;			// �ϰ� �������� ��Ÿ��. PT_Buy�� ��쿡�� �ǹ̰� �ִ�.
var bool			m_bBuffMode;           // se true, a janela esta em modo de vender buffs (skills)
var array<int>		AllowedBuffIDs;

function OnLoad()
{
	registerEvent( EV_PrivateShopOpenWindow );
	registerEvent( EV_PrivateShopAddItem );
	registerEvent( EV_SetMaxCount );
	registerEvent( EV_DialogOK );
	registerEvent( EV_SkillListStart );
	registerEvent( EV_SkillList );

	m_merchantID = 0;
	m_buyMaxCount = 0;
	m_sellMaxCount = 0;
}

function OnSendPacketWhenHiding()
{
	RequestQuit();
}

function OnHide()
{
	local DialogBox DialogBox;
	DialogBox = DialogBox(GetScript("DialogBox"));
	if (class'UIAPI_WINDOW'.static.IsShowWindow("DialogBox"))
	{
		DialogBox.HandleCancel();
	}
	Clear();
}

function OnEvent(int Event_ID,string param)
{
	//debug("PrivateShopWnd OnEvent " $ param);
	switch( Event_ID )
	{
	case EV_PrivateShopOpenWindow:
		HandleOpenWindow(param);
		break;
	case EV_PrivateShopAddItem:
		HandleAddItem(param);
		break;
	case EV_SetMaxCount:
		HandleSetMaxCount(param);
		break;
	case EV_DialogOK:
		HandleDialogOK();
		break;
	case EV_SkillListStart:
		if (m_bBuffMode)
		{
			HandleSkillListStart();
		}
		break;
	case EV_SkillList:
		if (m_bBuffMode)
		{
			HandleSkillList(param);
		}
		break;
	default:
		break;
	}
}

function OnClickButton( string ControlName )
{
	local int index;
	//debug("OnClickButton " $ ControlName );
	if( ControlName == "UpButton" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.GetSelectedNum( "PrivateShopWnd.BottomList" );
		MoveItemBottomToTop( index, false );
	}
	else if( ControlName == "DownButton" )
	{
		index = class'UIAPI_ITEMWINDOW'.static.GetSelectedNum( "PrivateShopWnd.TopList" );
		MoveItemTopToBottom( index, false );
	}
	else if( ControlName == "OKButton" )
	{
		HandleOKButton( true );
	}
	else if( ControlName == "StopButton" )
	{
		RequestQuit();
		HideWindow("PrivateShopWnd");
	}
	else if( ControlName == "MessageButton" )
	{
		DialogSetEditBoxMaxLength(29);	//���� 25�� ����! ���� 25�� �����̾��µ� ������ �����Ͽ� 29�ڷ� �ø�
		DialogSetID( DIALOG_EDIT_SHOP_MESSAGE  );
		if( m_type == PT_SellList )
			DialogSetString( GetPrivateShopMessage("sell") );
		else if( m_type == PT_BuyList )
			DialogSetString( GetPrivateShopMessage("buy") );

		DialogSetDefaultOK();	
		DialogShow( DIALOG_OKCancelInput, GetSystemMessage( 334 ) );
	}
	else if( ControlName == "BuffButton" )
	{
		ToggleBuff();
		if(m_bBuffMode == true)
		{
			EnterBuffMode();   // entra no modo de vender skills
		}
		else
		{
			EnterItemMode();
		}
	}
}

function EnterItemMode()
{
	Clear();
	DoAction(10);
}

function ToggleBuff()
{
	if(m_bBuffMode == true)
	{
		m_bBuffMode = false;
	}
	else
	{
		m_bBuffMode = true;
	}
}

function EnterBuffMode()
{
	// habilita modo buff e usa o fluxo de PT_SellList (vender lista com preco)
	m_bBuffMode = true;
	m_type = PT_SellList;

	// limpa as listas
	class'UIAPI_ITEMWINDOW'.static.Clear("PrivateShopWnd.TopList");
	class'UIAPI_ITEMWINDOW'.static.Clear("PrivateShopWnd.BottomList");

	// tooltips e textos (pode ajustar para outro idioma/strings do system)
	class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.TopList", "Inventory" );
	class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.BottomList", "InventoryPrice1" );

	class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.TopText", "Habilidades" );
	class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.BottomText", "Buffs a venda" );
	class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.PriceConstText", GetSystemString(143) );
	class'UIAPI_BUTTON'.static.SetButtonName( "PrivateShopWnd.OKButton", 428 ); // "OK"

	// elementos visuais
	ShowWindow( "PrivateShopWnd.OKButton" );
	ShowWindow( "PrivateShopWnd.BottomCountText" );
	ShowWindow( "PrivateShopWnd.StopButton" );
	ShowWindow( "PrivateShopWnd.MessageButton" );
	HideWindow( "PrivateShopWnd.CheckBulk" );

	class'UIAPI_WINDOW'.static.SetWindowTitleByText( "PrivateShopWnd", "Loja Particular (Buffs)" );

	// pede ao servidor a lista de skills (ele respondera com EV_SkillListStart/EV_SkillList)
	RequestSkillList();
}

function HandleSkillListStart()
{
	if( m_bBuffMode )
	{
		class'UIAPI_ITEMWINDOW'.static.Clear("PrivateShopWnd.TopList"); // vai encher com as skills
	}
}

function HandleSkillList(string param)
{
	local int Tmp, SkillID, SkillLevel, Lock;
	local string strIconName, strSkillName, strDescription, strEnchantName, strCommand;
	local ItemInfo infItem;
	local ESkillCategory Type;

	if( !m_bBuffMode )
		return;

	ParseInt(param, "Type", Tmp);
	ParseInt(param, "ClassID", SkillID);
	ParseInt(param, "Level", SkillLevel);
	ParseInt(param, "Lock", Lock);
	ParseString(param, "Name", strSkillName);
	ParseString(param, "IconName", strIconName);
	ParseString(param, "Description", strDescription);
	ParseString(param, "EnchantName", strEnchantName);
	ParseString(param, "Command", strCommand);

	// monta ItemInfo como skill (igual ao MagicSkillWnd)
	infItem.ClassID = SkillID;
	infItem.Level = SkillLevel;
	infItem.Name = strSkillName;
	infItem.AdditionalName = strEnchantName;
	infItem.IconName = strIconName;
	infItem.Description = strDescription;
	infItem.ItemSubType = int(EShortCutItemType.SCIT_SKILL);
	infItem.MacroCommand = strCommand;
	infItem.ItemNum = 1; // nao e empilhavel
	infItem.bIsLock = (Lock > 0);
	infItem.ItemType = 5;

	Type = ESkillCategory(Tmp);
	
	// Mostramos apenas skills ativas para buff (evita passivas)
	
	if( IsAllowedBuff(SkillID) )
	{
		class'UIAPI_ITEMWINDOW'.static.AddItem("PrivateShopWnd.TopList", infItem);
	}
}

function bool IsAllowedBuff(int SkillID)
{
	local int i;
	
    for (i = 0; i < AllowedBuffIDs.Length; ++i)
    {
        if (AllowedBuffIDs[i] == SkillID)
            return true;
    }
    return false;
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

// �������� Ŭ���Ͽ��� ��� (����Ŭ�� �ƴ�)
function OnClickItem( string ControlName, int index )
{
	local WindowHandle m_dialogWnd;
	m_dialogWnd = GetHandle( "DialogBox" );		
	if(ControlName == "TopList")
	{
		if( DialogIsMine() && m_dialogWnd.IsShowWindow())
		{
			DialogHide();
			m_dialogWnd.HideWindow();
		}		
	}
}

function OnDropItem( string strID, ItemInfo info, int x, int y)
{
	local int index;
	//debug("OnDropItem strID " $ strID $ ", src=" $ info.DragSrcName);
	index = -1;
	if( strID == "TopList" && info.DragSrcName == "BottomList" )
	{
		if( (m_type == PT_Buy && !m_bBuffMode) || (m_type == PT_SellList && !m_bBuffMode) )
			index = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.BottomList", info.ServerID );
		else
			index = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.BottomList", info.ClassID );
		if( index >= 0 )
			MoveItemBottomToTop( index, info.AllItemCount > 0 );
	}
	else if( strID == "BottomList" && info.DragSrcName == "TopList" )
	{
		if( (m_type == PT_Buy && !m_bBuffMode) || (m_type == PT_SellList && !m_bBuffMode) )
			index = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.TopList", info.ServerID );
		else
			index = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.TopList", info.ClassID );
		if( index >= 0 )
			MoveItemTopToBottom( index, info.AllItemCount > 0 );
	}
}

function Clear()
{
	m_type = PT_None;
	m_merchantID = -1;
	m_bBulk = false;
	m_bBuffMode = false;

	class'UIAPI_ITEMWINDOW'.static.Clear("PrivateShopWnd.TopList");
	class'UIAPI_ITEMWINDOW'.static.Clear("PrivateShopWnd.BottomList");

	class'UIAPI_TEXTBOX'.static.SetText("PrivateShopWnd.PriceText", "0");
	class'UIAPI_TEXTBOX'.static.SetTooltipString("PrivateShopWnd.PriceText", "");

	class'UIAPI_TEXTBOX'.static.SetText("PrivateShopWnd.AdenaText", "0");
	class'UIAPI_TEXTBOX'.static.SetTooltipString("PrivateShopWnd.AdenaText", "");
}

function RequestQuit()
{
	if( m_type == PT_BuyList )
	{
		RequestQuitPrivateShop("buy");
	}
	else if( m_type == PT_SellList )
	{
		RequestQuitPrivateShop("sell");
	}
}

function MoveItemTopToBottom( int index, bool bAllItem )
{
	local ItemInfo info, bottomInfo;
	local int		num, i, bottomIndex;

	if( class'UIAPI_ITEMWINDOW'.static.GetItem("PrivateShopWnd.TopList", index, info) )
	{
		//debug( "MoveItemTopToBottom index:" $ index $ ", m_type: " $ m_type $ ", classID:" $ info.ClassID $ ", count:" $info.ItemNum );

		if( m_type == PT_SellList )
		{
			// Ask price
			DialogSetID( DIALOG_ASK_PRICE );

			// No modo Buff usamos ClassID (skillID); no modo item usamos ServerID
			if( m_bBuffMode )
				DialogSetReservedInt( info.ClassID );
			else
				DialogSetReservedInt( info.ServerID );

			DialogSetReservedInt3( int(bAllItem) );
			DialogSetEditType("number");
			DialogSetParamInt( -1 );
			DialogSetDefaultOK();
			DialogShow( DIALOG_NumberPad, GetSystemMessage(322) );
		}
		else if( m_type == PT_BuyList )
		{
			// Ask price
			DialogSetID( DIALOG_ASK_PRICE );
			DialogSetReservedInt( info.ClassID );
			//if(IsStackableItem( info.ConsumeType ))
				//DialogSetReservedInt3( int(bAllItem) );			// ��ü�̵��̸� ���� ���� �ܰ踦 �����Ѵ�
			DialogSetEditType("number");
			DialogSetParamInt( -1 );
			DialogSetDefaultOK();	
			DialogShow( DIALOG_NumberPad, GetSystemMessage(585) );
		}
		else if( m_type == PT_Sell || m_type == PT_Buy )
		{
			if( m_type == PT_Sell && info.bDisabled )			// ������ ���� �����̰� �� ������ ���� �� �׳� ����
				return;

			if( m_type == PT_Buy && m_bBulk && !m_bBuffMode )					// ������ �ϰ� ���� �� ���. ��� �������� �̵����Ѿ� �Ѵ�.
			{
				num = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "PrivateShopWnd.TopList" );
				for( i=0 ; i<num ; ++i )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem("PrivateShopWnd.TopList", i, info); 
					class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", info );
				}
				class'UIAPI_ITEMWINDOW'.static.Clear( "PrivateShopWnd.TopList" );
		
				AdjustPrice();
				AdjustCount();
			}
			else
			{
				if( !bAllItem && IsStackableItem( info.ConsumeType ) && info.ItemNum > 1 )		// ���� �����
				{
					DialogSetID( DIALOG_TOP_TO_BOTTOM );
					if( m_type == PT_Sell )
						DialogSetReservedInt( info.ClassID );
					else if( m_type == PT_Buy )
						DialogSetReservedInt( info.ServerID );
					DialogSetParamInt( info.ItemNum );
					DialogSetDefaultOK();	
					DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), info.Name, "" ) );
				}
				else
				{
					if( m_type == PT_Buy )
					{
						if (m_bBuffMode)
							bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.BottomList", info.ClassID );
						else
							bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.BottomList", info.ServerID );
					}
					else if( m_type == PT_Sell )
					{
						bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.BottomList", info.ClassID );
					}

					if( bottomIndex >= 0 && IsStackableItem( info.ConsumeType ) )			// �Ʒ��ʿ� �̹� �ִ� �������̰� ������ �������̶�� ������ �����ش�.
					{
						class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
						bottomInfo.ItemNum += info.ItemNum;
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
					}
					else
					{
						class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", info );
					}
					class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.TopList", index );

					AdjustPrice();
					AdjustCount();
				}
			}

			if( m_type == PT_Buy )
				AdjustWeight();
		}
	}
}

function MoveItemBottomToTop( int index, bool bAllItem )
{
	local ItemInfo info, topInfo;
	local int		stringIndex, num, i, topIndex;
	if( class'UIAPI_ITEMWINDOW'.static.GetItem("PrivateShopWnd.BottomList", index, info) )
	{
		if( m_type == PT_Buy && m_bBulk && !m_bBuffMode )		// ������ �ϰ� ���� �� ���. ��� �������� �̵����Ѿ� �Ѵ�.
		{
			num = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "PrivateShopWnd.BottomList" );
			for( i=0 ; i<num ; ++i )
			{
				class'UIAPI_ITEMWINDOW'.static.GetItem("PrivateShopWnd.BottomList", i, info); 
				class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.TopList", info );
			}
			class'UIAPI_ITEMWINDOW'.static.Clear( "PrivateShopWnd.BottomList" );

			AdjustPrice();
			AdjustCount();
		}
		else	// ���� ���Ÿ� ���� ����� ��� �ٸ� ó���� �ʿ��� �� �Ͽ�
		{
			if( !bAllItem && IsStackableItem( info.ConsumeType ) && info.ItemNum > 1 )		// � �ű���� �����
			{
				//debug("MoveItemBottomToTop m_type " $ m_type );
				DialogSetID( DIALOG_BOTTOM_TO_TOP );
				if( m_type == PT_Buy )
				{
					if( m_bBuffMode )
						DialogSetReservedInt( info.ClassID );
					else
						DialogSetReservedInt( info.ServerID );
				}
				else if( m_type == PT_SellList )
				{
					// No modo Buff usamos ClassID; caso contrario, ServerID
					if( m_bBuffMode )
						DialogSetReservedInt( info.ClassID );
					else
						DialogSetReservedInt( info.ServerID );
				}
				else if( m_type == PT_Sell || m_type == PT_BuyList )
				{
					DialogSetReservedInt( info.ClassID );
				}

				DialogSetParamInt( info.ItemNum );
				switch( m_type )
				{
				case PT_SellList:
					stringIndex = 72;
					break;
				case PT_BuyList:
					stringIndex = 571;
					break;
				case PT_Sell:
					stringIndex = 72;
					break;
				case PT_Buy:
					stringIndex = 72;
					break;
				default:
					break;
				}
				DialogSetDefaultOK();	
				DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(stringIndex), info.Name, "" ) );
			}
			else
			{
				class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.BottomList", index );
				if( m_type != PT_BuyList )
				{
					if( m_type == PT_Buy || m_type == PT_SellList )
						topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.TopList", info.ServerID );
					else if( m_type == PT_Sell )
						topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.TopList", info.ClassID );

					if( topIndex >=0 && IsStackableItem( info.ConsumeType ) )		// ������ �������̸� ������ ������Ʈ
					{
						class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
						topInfo.ItemNum += info.ItemNum;
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					}
					else
					{
						class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.TopList", info );
					}
				}
				AdjustPrice();
				AdjustCount();
			}
		}
		if( m_type == PT_Buy )
			AdjustWeight();
	}
}

function HandleDialogOK()
{
	local int id, inputNum, itemID, bottomIndex, topIndex, i, allItem;
	local ItemInfo bottomInfo, topInfo;

	if( DialogIsMine() )
	{
		id = DialogGetID();
	
		inputNum = int( DialogGetString() );
		itemID = DialogGetReservedInt();
		//debug("PrivateShopWnd DialogOK id:" $ id $ ", string:" $ inputNum $ ", reservedInt:" $ classID $ ", reservedInt2:" $ DialogGetReservedInt2() );

		// ���̾�α״� ���ʴ�� ���� ����(DIALOG_ASK_PRICE)->������ �⺻ ���ݰ� ���̰� �� ��� ���� Ȯ��(DIALOG_CONFIRM_PRICE)->�������̵�(DIALOG_TOP_TO_BOTTOM)�� ������� ���ȴ�
		// PT_SellList�� PT_BuyList�� �⺻������ �����ϴ�.
		if( m_type == PT_SellList )
		{
			if( id == DIALOG_TOP_TO_BOTTOM && inputNum > 0 )					// ������� �������� �ű��.
			{
				topIndex = FindTopIndexByCurrentMode( itemID );
				if( topIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.BottomList", itemID );
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
					if( bottomIndex >= 0 && IsStackableItem( bottomInfo.ConsumeType ) )			// �Ʒ��ʿ� �̹� �ִ� �������̰� ������ �������̶�� ������ ����� ������ �����ش�.
					{
						bottomInfo.Price = DialogGetReservedInt2();
						bottomInfo.ItemNum += Min( inputNum, topInfo.ItemNum );
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
					}
					else					// ���ο� �������� �ִ´�
					{
						bottomInfo = topInfo;
						bottomInfo.ItemNum = Min( inputNum, topInfo.ItemNum );
						bottomInfo.Price = DialogGetReservedInt2();
						class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", bottomInfo );
					}

					// ���� �������� ó��
					topInfo.ItemNum -= inputNum;
					if( topInfo.ItemNum <= 0 )
						class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.TopList", topIndex );
					else
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
				}
				AdjustPrice();
				AdjustCount();
			}
			else if( id == DIALOG_BOTTOM_TO_TOP && inputNum > 0 )		// �Ʒ��� ���� ���� ���� �Ű��ش�.
			{
				bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.BottomList", itemID );
				//debug("DIALOG_BOTTOM_TO_TOP bottomIndex " $ bottomIndex $ ", itemID " $ itemID );
				if( bottomIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );

					topIndex = FindTopIndexByCurrentMode( itemID );
					if( topIndex >=0 && IsStackableItem( bottomInfo.ConsumeType ) )
					{
						class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
						topInfo.ItemNum += Min( inputNum, bottomInfo.ItemNum );
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					}
					else
					{
						topInfo = bottomInfo;
						topInfo.ItemNum = Min( inputNum, bottomInfo.ItemNum );
						class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.TopList", topInfo );
					}

					bottomInfo.ItemNum -= inputNum;
					if( bottomInfo.ItemNum > 0 )
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
					else 
						class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.BottomList", bottomIndex );
				}
				AdjustPrice();
				AdjustCount();
			}
			else if( ID == DIALOG_CONFIRM_PRICE )
			{
				topIndex = FindTopIndexByCurrentMode( itemID );
				if( topIndex >= 0 )
				{
					allItem = DialogGetReservedInt3();

					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					if( allItem == 0 && IsStackableItem( topInfo.ConsumeType ) && topInfo.ItemNum != 1)		// stackable?	1���϶��� ������ ���� �ʽ��ϴ�. -innowind
					{
						DialogSetID( DIALOG_TOP_TO_BOTTOM );
						//DialogSetReservedInt( topInfo.ClassID );
						//DialogSetReservedInt2( inputNum );				// price
						if(topInfo.ItemNum  == 0) topInfo.ItemNum  = 1;	//������ �Է����� �ʾҴٸ� 1�� �������ش�. 
						DialogSetParamInt( topInfo.ItemNum );
						DialogSetDefaultOK();	
						DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), topInfo.Name, "" ) );
					}
					else
					{
						if( allItem == 0 )
							topInfo.ItemNum = 1;
						topInfo.Price = DialogGetReservedInt2();
						if(m_bBuffMode)
							bottomIndex = FindBottomIndexByCurrentMode( topInfo.ClassID );
						else
							bottomIndex = FindBottomIndexByCurrentMode( topInfo.ServerID );
						if( bottomIndex >= 0 && IsStackableItem( topInfo.ConsumeType ) )
						{
							class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );		// ��ü!-_-
							topInfo.ItemNum += bottomInfo.ItemNum;
							class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, topInfo );
						}
						else
						{
							class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", topInfo );
						}
						class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.TopList", topIndex );

						AdjustPrice();
						AdjustCount();
					}
				}
			}
			else if( id == DIALOG_ASK_PRICE && inputNum > 0 )
			{
				topIndex = FindTopIndexByCurrentMode( itemID );
				if( topIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					//debug("DIALOG_ASK_PRICE defaultPrice : " $ topInfo.DefaultPrice $ ", entered price: " $ inputNum );
					// if specified price is unconventional, ask confirm
					if( inputNum >= 2000000000 )	//20���� ������ ���� �ʰ� ������ �ѷ��ش�. 
					{
						//DialogSetID( DIALOG_OVER_PRICE );
						DialogShow( DIALOG_Notice, GetSystemMessage(1369) );					
					}
					else if( !IsProperPrice( topInfo, inputNum ) )
					{
						//debug("strange price warning");
						DialogSetID( DIALOG_CONFIRM_PRICE );
						DialogSetReservedInt( topInfo.ServerID );
						DialogSetReservedInt2( inputNum );				// price
						DialogSetDefaultOK();	
						DialogShow( DIALOG_Warning, GetSystemMessage(569) );
					}
					else
					{
						allItem = DialogGetReservedInt3();

						if( allItem == 0 && IsStackableItem( topInfo.ConsumeType ) )		// stackable?
						{
							//debug("stackable item");
							DialogSetID( DIALOG_TOP_TO_BOTTOM );
							DialogSetReservedInt( topInfo.ServerID );
							DialogSetReservedInt2( inputNum );				// price
							DialogSetReservedInt3( allItem );
							DialogSetParamInt( topInfo.ItemNum );
							DialogSetDefaultOK();	
							DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(72), topInfo.Name, "" ) );
						}
						else
						{
							//debug("nonstackable item");
							if( allItem == 0 )
								topInfo.ItemNum = 1;
							topInfo.Price = inputNum;
							if(m_bBuffMode)
								bottomIndex = FindBottomIndexByCurrentMode( topInfo.ClassID );
							else
								bottomIndex = FindBottomIndexByCurrentMode( topInfo.ServerID );
							if( bottomIndex >= 0 && IsStackableItem( topInfo.ConsumeType ) )
							{
								class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );		// ��ü!-_-
								topInfo.ItemNum += bottomInfo.ItemNum;
								class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, topInfo );
							}
							else
							{
								class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", topInfo );
							}
							class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.TopList", topIndex );

							AdjustPrice();
							AdjustCount();
						}
					}
				}
			}
			else if( id == DIALOG_EDIT_SHOP_MESSAGE )
			{
				SetPrivateShopMessage( "sell", DialogGetString() );
			}
		}
		// PT_BuyList
		else if( m_type == PT_BuyList )
		{
			if( id == DIALOG_TOP_TO_BOTTOM && inputNum > 0 )					// ������� �������� �ű��.
			{
				topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.TopList", itemID );
				if( topIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.BottomList", itemID );
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
					if( bottomIndex >= 0 && IsStackableItem( bottomInfo.ConsumeType ) )			// �Ʒ��ʿ� �̹� �ִ� �������̰� ������ �������̶�� ������ ����� ������ �����ش�.
					{
						//debug("BuyList StackableItem addnum:" $ inputNum $ ", set price to : " $ DialogGetReservedInt2());
						bottomInfo.Price = DialogGetReservedInt2();
						bottomInfo.ItemNum += inputNum;
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );

						return;		// �̰ɷ� ��.
					}

					if( bottomIndex >= 0 )					
					{	// �ߺ��Ǵ� �������� ��� �����.
						i = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "PrivateShopWnd.BottomList" );
						//debug("BuyList Removing Items");
						while( i >= 0 )
						{
							class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", i, bottomInfo );
							if( bottomInfo.ClassID == itemID )
								class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.BottomList", i );
							--i;
						};
					}

					if( IsStackableItem( topInfo.ConsumeType ) )
					{
						//debug("BuyList Add stackable Item");
						bottomInfo = topInfo;
						bottomInfo.ItemNum = inputNum;
						bottomInfo.Price = DialogGetReservedInt2();
						class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", bottomInfo );
					}
					else
					{
						//debug("BuyList Add non-stackable Item");
						// ���ο� �������� ������ŭ �ִ´�
						bottomInfo = topInfo;
						bottomInfo.ItemNum = 1;
						bottomInfo.Price = DialogGetReservedInt2();
						for( i=0 ; i < inputNum ; ++i )
						{
							class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", bottomInfo );
						}
					}
				}
				AdjustPrice();
				AdjustCount();
			}
			else if( id == DIALOG_BOTTOM_TO_TOP && inputNum > 0 )		// �Ʒ��� ���� ��������.
			{
				bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.BottomList", itemID );
				if( bottomIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
					bottomInfo.ItemNum -= inputNum;
					if( bottomInfo.ItemNum > 0 )
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
					else 
						class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.BottomList", bottomIndex );
				}
			}
			else if( ID == DIALOG_CONFIRM_PRICE )			// � ������ ������ ���´�.
			{
				topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.TopList", itemID );
				if( topIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );

					DialogSetID( DIALOG_TOP_TO_BOTTOM );
					DialogSetReservedInt( topInfo.ClassID );
					//DialogSetReservedInt2( inputNum );				// price
					DialogSetParamInt( topInfo.ItemNum );
					DialogSetDefaultOK();	
					DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(570), topInfo.Name, "" ) );
				}
				AdjustPrice();
				AdjustCount();
				
				
				//���α��ſ��� �����Ǹſ� �ִ°��� �ܾ�Ի�ɴϴ�. -_-;;
				/*
				topIndex = FindTopIndexByCurrentMode( itemID );
				if( topIndex >= 0 )
				{
					allItem = DialogGetReservedInt3();

					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					if( allItem == 0 && IsStackableItem( topInfo.ConsumeType ) )		// stackable?
					{
						DialogSetID( DIALOG_TOP_TO_BOTTOM );
						if(topInfo.ItemNum  == 0) topInfo.ItemNum  = 1;	//������ �Է����� �ʾҴٸ� 1�� �������ش�. 
						DialogSetParamInt( topInfo.ItemNum );
						DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(570), topInfo.Name, "" ) );
					}
					else
					{
						if( allItem == 0 )
							topInfo.ItemNum = 1;
						topInfo.Price = DialogGetReservedInt2();
						if(m_bBuffMode)
							bottomIndex = FindBottomIndexByCurrentMode( topInfo.ClassID );
						else
							bottomIndex = FindBottomIndexByCurrentMode( topInfo.ServerID );
						if( bottomIndex >= 0 && IsStackableItem( topInfo.ConsumeType ) )
						{
							class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );		// ��ü!-_-
							topInfo.ItemNum += bottomInfo.ItemNum;
							class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, topInfo );
						}
						else
						{
							class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", topInfo );
						}
						//class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.TopList", topIndex ); //���ſ����� �������� ������ �ʿ䰡 ����. 

						AdjustPrice();
						AdjustCount();
					}
				}
				*/
			}
			else if( id == DIALOG_ASK_PRICE && inputNum > 0 )
			{
				topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.TopList", itemID );
				if( topIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					// if specified price is unconventional, ask confirm
					if( inputNum >= 2000000000 )	//20���� ������ ���� �ʰ� ������ �ѷ��ش�. 
					{
						//DialogSetID( DIALOG_OVER_PRICE );
						DialogShow( DIALOG_Notice, GetSystemMessage(1369) );					
					}
					else if( !IsProperPrice( topInfo, inputNum ) )
					{
						DialogSetID( DIALOG_CONFIRM_PRICE );
						DialogSetReservedInt( topInfo.ClassID );
						DialogSetReservedInt2( inputNum );				// price
						DialogSetDefaultOK();	
						DialogShow( DIALOG_Warning, GetSystemMessage(569) );
					}
					else
					{
						DialogSetID( DIALOG_TOP_TO_BOTTOM );
						DialogSetReservedInt( topInfo.ClassID );
						DialogSetReservedInt2( inputNum );				// price
						DialogSetParamInt( topInfo.ItemNum );
						DialogSetDefaultOK();	
						DialogShow( DIALOG_NumberPad, MakeFullSystemMsg( GetSystemMessage(570), topInfo.Name, "" ) );
					}
				}
			}
			else if( id == DIALOG_EDIT_SHOP_MESSAGE )
			{
				SetPrivateShopMessage( "buy", DialogGetString() );
			}
		}
		// PT_Buy and PT_Buy
		else if( m_type == PT_Buy || m_type == PT_Sell )
		{
			if( id == DIALOG_TOP_TO_BOTTOM && inputNum > 0 )		// �� ���̾�αװ� �ҷȴٴ� ���� ������ �������̶�� ���� �ǹ��Ѵ�.(�ƴϾ����� MoveItemTopToBottom() �Լ����� �̹� ������ �̵��� ó������ ���̴�)
			{
				topIndex = -1;
				if( m_type == PT_Buy )
					topIndex = FindTopIndexByCurrentMode( itemID );
				else if( m_type == PT_Sell )
					topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.TopList", itemID );

				if( topIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					
					if(m_type == PT_Sell  && topInfo.Reserved < inputNum)	//����� �纸�� �Է��� ���� ���ٸ� �˾��� ���� ����. 
					{
						DialogShow( DIALOG_Notice, GetSystemMessage(1036) );
					}
					else
					{
						if( m_type == PT_Buy )
							bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.BottomList", itemID );
						else if( m_type == PT_Sell )
							bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.BottomList", itemID );

						class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
						if( bottomIndex >= 0  )			// ������ ������ �ߺ�
						{
							bottomInfo.ItemNum += Min( inputNum, topInfo.ItemNum );		// ������ �����ش�
							class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
						}
						else					// ���ο� �������� �ִ´�
						{
							bottomInfo = topInfo;
							bottomInfo.ItemNum = Min( inputNum, topInfo.ItemNum );
							class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", bottomInfo );
						}
	
						// ���� �������� ó��
						topInfo.ItemNum -= inputNum;
						if( topInfo.ItemNum <= 0 )
							class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.TopList", topIndex );
						else
							class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					}
				}
				AdjustPrice();
				AdjustCount();
			}
			else if( id == DIALOG_BOTTOM_TO_TOP && inputNum > 0 )		// �Ʒ��� ���� ���� ���� �Ű��ش�. ���������� �� ���̾�αװ� �ҷȴٴ� ���� ������ ���������� �ǹ�.
			{
				bottomIndex = -1;
				if( m_type == PT_Buy )
					bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.BottomList", itemID );
				else if( m_type == PT_Sell )
					bottomIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.BottomList", itemID );

				if( bottomIndex >= 0 )
				{
					class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );

					topIndex = -1;
					// ���ʿ� �������� ����
					if( m_type == PT_Buy )
						topIndex = FindTopIndexByCurrentMode( itemID );
					else if( m_type == PT_Sell )
						topIndex = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.TopList", itemID );

					if( topIndex >=0 )
					{
						class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
						topInfo.ItemNum += Min( inputNum, bottomInfo.ItemNum );
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.TopList", topIndex, topInfo );
					}
					else
					{
						topInfo = bottomInfo;
						topInfo.ItemNum = Min( inputNum, bottomInfo.ItemNum );
						class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.TopList", topInfo );
					}

					// �Ʒ����� ������ ������ �ش�.
					bottomInfo.ItemNum -= inputNum;
					if( bottomInfo.ItemNum > 0 )
						class'UIAPI_ITEMWINDOW'.static.SetItem( "PrivateShopWnd.BottomList", bottomIndex, bottomInfo );
					else 
						class'UIAPI_ITEMWINDOW'.static.DeleteItem( "PrivateShopWnd.BottomList", bottomIndex );
				}
				AdjustPrice();
				AdjustCount();
			}
			else if( id == DIALOG_CONFIRM_PRICE_FINAL)
			{
				HandleOKButton( false );
			}

			if( m_type == PT_Buy )
				AdjustWeight();
		}
	}
}
//
function HandleOpenWindow( string param )
{
	local string type;
	local int adena,bulk;
	local string adenaString;
	local UserInfo	user;
	local WindowHandle m_inventoryWnd;
	
	m_inventoryWnd = GetHandle( "InventoryWnd" );	//�κ��丮�� ������ �ڵ��� ���´�.

	Clear();

	ParseString( param, "type", type );
	ParseInt( param, "adena", adena );
	ParseInt( param, "userID", m_merchantID );
	ParseInt( param, "bulk", bulk );			// �ϰ� �Ǹ�(����)?
	if( bulk > 0 )
		m_bBulk = true;
	else
		m_bBulk = false;
	
	switch( type )
	{
	case "buy":
		m_type = PT_Buy;
		//class'UIAPI_WINDOW'.static.SetWindowTitle("PrivateShopWnd", 1216);
		break;
	case "sell":
		m_type = PT_Sell;
		//class'UIAPI_WINDOW'.static.SetWindowTitle("PrivateShopWnd", 1217);
		break;
	case "buyList":
		m_type = PT_BuyList;
		//class'UIAPI_WINDOW'.static.SetWindowTitle("PrivateShopWnd", 1218);
		break;
	case "sellList":
		m_type = PT_SellList;
		//class'UIAPI_WINDOW'.static.SetWindowTitle("PrivateShopWnd", 131);
		break;
	default:
		break;
	};

	adenaString = MakeCostString( string(adena) );
	class'UIAPI_TEXTBOX'.static.SetText("PrivateShopWnd.AdenaText", adenaString);
	class'UIAPI_TEXTBOX'.static.SetTooltipString("PrivateShopWnd.AdenaText", ConvertNumToText(string(adena)) );

	if( m_inventoryWnd.IsShowWindow() )			//�κ��丮 â�� ���������� �ݾ��ش�. 
	{
		m_inventoryWnd.HideWindow();
	}
	ShowWindow( "PrivateShopWnd" );
	class'UIAPI_WINDOW'.static.SetFocus("PrivateShopWnd");

	if( m_type == PT_BuyList )
	{
		// set tooltip
		class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.TopList", "Inventory" );
		class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.BottomList", "InventoryPrice1" );

		// Set strings
		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.TopText", GetSystemString(1) );
		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.BottomText", GetSystemString(502) );
		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.PriceConstText", GetSystemString(142) );
		class'UIAPI_BUTTON'.static.SetButtonName( "PrivateShopWnd.OKButton", 428 );

		ShowWindow( "PrivateShopWnd.BottomCountText" );
		ShowWindow( "PrivateShopWnd.StopButton" );
		Showwindow( "PrivateShopWnd.MessageButton" );
		ShowWindow( "PrivateShopWnd.OKButton" );
		HideWindow( "PrivateShopWnd.CheckBulk" );
		HideWindow( "PrivateShopWnd.BuffButton" );
		HideWindow( "PrivateShopWnd.BuffText" );

		class'UIAPI_WINDOW'.static.SetWindowTitleByText( "PrivateShopWnd", GetSystemString(498) $ "(" $ GetSystemString(1434) $ ")" );
	}
	else if( m_type == PT_SellList )
	{
		// set tooltip
		class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.TopList", "Inventory" );
		class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.BottomList", "InventoryPrice1" );

		if( bulk > 0 )
			class'UIAPI_CHECKBOX'.static.SetCheck( "PrivateShopWnd.CheckBulk", true );
		else
			class'UIAPI_CHECKBOX'.static.SetCheck( "PrivateShopWnd.CheckBulk", false );

		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.TopText", GetSystemString(1) );
		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.BottomText", GetSystemString(137) );
		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.PriceConstText", GetSystemString(143) );
		class'UIAPI_BUTTON'.static.SetButtonName( "PrivateShopWnd.OKButton", 428 );

		ShowWindow( "PrivateShopWnd.BottomCountText" );
		ShowWindow( "PrivateShopWnd.StopButton" );
		Showwindow( "PrivateShopWnd.MessageButton" );
		ShowWindow( "PrivateShopWnd.OKButton" );
		ShowWindow( "PrivateShopWnd.CheckBulk" );
		ShowWindow( "PrivateShopWnd.BuffText" );
		ShowWindow( "PrivateShopWnd.BuffButton" );

		class'UIAPI_WINDOW'.static.SetWindowTitleByText( "PrivateShopWnd", GetSystemString(498) $ "(" $ GetSystemString(1157) $ ")" );
	}
	else if( m_type == PT_Buy )
	{
		if (bulk == 2)   // ou ParseString(param, "mode", mode) == "buff"
		{
			m_bBuffMode = true;
			EnterBuffBuyMode(); // funcao nova (abaixo)
		}
		else
		{
			m_bBuffMode = false;
			
			// set tooltip
			class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.TopList", "InventoryPrice1" );
			class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.BottomList", "Inventory" );

			class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.TopText", GetSystemString(137) );
			class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.BottomText", GetSystemString(139) );
			class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.PriceConstText", GetSystemString(142) );
			class'UIAPI_BUTTON'.static.SetButtonName( "PrivateShopWnd.OKButton", 140 );

			HideWindow( "PrivateShopWnd.BottomCountText" );
			HideWindow( "PrivateShopWnd.StopButton" );
			HideWindow( "PrivateShopWnd.MessageButton" );
			ShowWindow( "PrivateShopWnd.OKButton" );
			HideWindow( "PrivateShopWnd.CheckBulk" );
			HideWindow( "PrivateShopWnd.BuffText" );
			HideWindow( "PrivateShopWnd.BuffButton" );

			GetUserInfo( m_merchantID, user );
			if( bulk > 0 )
				class'UIAPI_WINDOW'.static.SetWindowTitleByText( "PrivateShopWnd", GetSystemString(498) $ "(" $ GetSystemString(1198) $ ") - " $ user.Name );
			else
				class'UIAPI_WINDOW'.static.SetWindowTitleByText( "PrivateShopWnd", GetSystemString(498) $ "(" $ GetSystemString(1157) $ ") - " $ user.Name );
			}
	}
	else if( m_type == PT_Sell )
	{
		// set tooltip
		class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.TopList", "InventoryPrice2PrivateShop" );	// TTS_INVENTORY|TTS_PRIVATE_BUY(2050),TTES_SHOW_PRICE2(8)
		class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.BottomList", "Inventory" );

		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.TopText", GetSystemString(503) );
		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.BottomText", GetSystemString(137) );
		class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.PriceConstText", GetSystemString(143) );
		class'UIAPI_BUTTON'.static.SetButtonName( "PrivateShopWnd.OKButton", 140 );

		HideWindow( "PrivateShopWnd.BottomCountText" );
		HideWindow( "PrivateShopWnd.StopButton" );
		HideWindow( "PrivateShopWnd.MessageButton" );
		ShowWindow( "PrivateShopWnd.OKButton" );
		HideWindow( "PrivateShopWnd.CheckBulk" );
		HideWindow( "PrivateShopWnd.BuffText" );
		HideWindow( "PrivateShopWnd.BuffButton" );

		GetUserInfo( m_merchantID, user );
		class'UIAPI_WINDOW'.static.SetWindowTitleByText( "PrivateShopWnd", GetSystemString(498) $ "(" $ GetSystemString(1434) $ ") - " $ user.Name );
	}
}

function EnterBuffBuyMode()
{
    // tooltips (preco em cima; inventario em baixo)
    class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.TopList", "InventoryPrice1" );
    class'UIAPI_WINDOW'.static.SetTooltipType( "PrivateShopWnd.BottomList", "Inventory" );

    class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.TopText",     "Buffs a venda" );
    class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.BottomText",  "Selecionados" );
    class'UIAPI_TEXTBOX'.static.SetText( "PrivateShopWnd.PriceConstText", GetSystemString(142) );
    class'UIAPI_BUTTON'.static.SetButtonName( "PrivateShopWnd.OKButton", 140 ); // "OK/Comprar"

    HideWindow( "PrivateShopWnd.BottomCountText" );
    HideWindow( "PrivateShopWnd.StopButton" );
    HideWindow( "PrivateShopWnd.MessageButton" );
    ShowWindow( "PrivateShopWnd.OKButton" );
    HideWindow( "PrivateShopWnd.CheckBulk" );
	HideWindow( "PrivateShopWnd.BuffText" );
	HideWindow( "PrivateShopWnd.BuffButton" );

    class'UIAPI_WINDOW'.static.SetWindowTitleByText(
        "PrivateShopWnd", "Loja Particular (Buffs)"
    );
}


function HandleAddItem( string param )
{
    local ItemInfo info;
    local string target;

    ParseString( param, "target", target );
    ParamToItemInfo( param, info );

    if (m_bBuffMode && m_type == PT_Buy)  // visitante vendo loja de buffs
    {
		info.Name = class'UIDATA_SKILL'.static.GetName(info.ClassID, info.Enchanted);
		info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ClassID, info.Enchanted);;
		info.Description = class'UIDATA_SKILL'.static.GetDescription(info.ClassID, info.Enchanted);
		info.AdditionalName = "" $info.Enchanted;
		info.ItemSubType = 2;
		info.ItemType = 5;
		info.ItemNum = 1;
		info.Weight = 0;
		info.ConsumeType = 0;
    }

    if( target == "topList" )
    {
        if( m_type == PT_Sell && info.ItemNum == 0 )
            info.bDisabled = true;
        class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.TopList", info );
    }
    else if( target == "bottomList" )
    {
        class'UIAPI_ITEMWINDOW'.static.AddItem( "PrivateShopWnd.BottomList", info );
    }
    AdjustPrice();
    AdjustCount();
}

//
function AdjustPrice()
{
	local string adena;
	local int count;
	//local int addPrice;
	local int64 price;		//�����÷ο�� �������� �����ֱ� ���� �����Ͽ����ϴ�. - innowind
	local int64 addPrice64;		
	local ItemInfo info;

	count = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "PrivateShopWnd.BottomList" );
	price = Int2Int64(0);	
	addPrice64 = Int2Int64(0);	
	
	while( count > 0 )
	{		// �Ʒ��ʿ� �ִ� ���ǵ��� ������ �� �����ش�.
		class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", count - 1, info );
		//addPrice = info.Price * info.ItemNum;	//���⼭ �����÷ο찡 ���� ����������. ���ϴ� �Լ� ��
		addPrice64 = Int64Mul(info.Price, info.ItemNum );
		price = Int64Add( price , addPrice64 );	// Int64Add( price ,  Int64Add( price , addPrice64 ));  �ٷ� ��������� �ɰ��� ������ ;;
		//price += info.Price * info.ItemNum;

		--count;
	}
	
	if(price.nLeft <0 || price.nRight <0)	//�⺻������ ������ �� ���� ���⶧����, ������ �Ǹ� �� 0�� �ѷ��ݴϴ�.
	{
		price = Int2Int64(0);	
	}
	adena = MakeCostStringInt64( price );
	class'UIAPI_TEXTBOX'.static.SetText("PrivateShopWnd.PriceText", adena);
	class'UIAPI_TEXTBOX'.static.SetTooltipString("PrivateShopWnd.PriceText", ConvertNumToText(MakeCostStringInt64( price )) );
}

function AdjustCount()
{
	local int num, maxNum;

	if( m_type == PT_SellList )
	{
		maxNum = m_sellMaxCount;
		num = class'UIAPI_ITEMWINDOW'.static.GetItemNum("PrivateShopWnd.BottomList");
		class'UIAPI_TEXTBOX'.static.SetText("PrivateShopWnd.BottomCountText", "(" $ string(num) $ "/" $ string(maxNum) $ ")");
		//debug("AdjustCount SellList num " $ num $ ", maxCount " $ maxNum );
	}
	else if( m_type == PT_BuyList )
	{
		maxNum = m_buyMaxCount;
		num = class'UIAPI_ITEMWINDOW'.static.GetItemNum("PrivateShopWnd.BottomList");
		class'UIAPI_TEXTBOX'.static.SetText("PrivateShopWnd.BottomCountText", "(" $ string(num) $ "/" $ string(maxNum) $ ")");
		//debug("AdjustCount BuyList num " $ num $ ", maxCount " $ maxNum );
	}
}

// �Ʒ� ����Ʈ�� �ִ� ���ǵ��� ���Ը� ��� ���ؼ� InvenWeight �� �����ش�
function AdjustWeight()
{
	local int count, weight;
	local ItemInfo info;
	class'UIAPI_INVENWEIGHT'.static.ZeroWeight( "PrivateShopWnd.InvenWeight" );

	count = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "PrivateShopWnd.BottomList" );
	weight = 0;
	while( count > 0 )
	{		// �Ʒ��ʿ� �ִ� ���ǵ��� ���Ը� �� �����ش�.
		class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", count - 1, info );
		weight += info.Weight * info.ItemNum;

		--count;
	}

	class'UIAPI_INVENWEIGHT'.static.AddWeight( "PrivateShopWnd.InvenWeight", weight );
}

function HandleOKButton( bool bPriceCheck )		// bPriceCheck :check abnormal price before sending packet if bPriceCheck is true.
{
	local string	param;
	local int		itemCount, itemIndex;
	local ItemInfo	itemInfo;

	//debug("HandleOKButton m_type : " $ m_type );
	itemCount = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "PrivateShopWnd.BottomList" );
	if( m_type == PT_SellList )
	{
		// push bulk? (irrelevante para buff, mas manter para compatibilidade visual)
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "PrivateShopWnd.CheckBulk" ) )
			ParamAdd( param, "bulk", "1" );
		else if ( m_bBuffMode )
			ParamAdd( param, "bulk", "2" );
		else 
			ParamAdd( param, "bulk", "0" );

		itemCount = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "PrivateShopWnd.BottomList" );
		ParamAdd( param, "num", string(itemCount) );

		if( m_bBuffMode )
		{
			// === MODO BUFF: empacota skills ===
			for( itemIndex = 0; itemIndex < itemCount; ++itemIndex )
			{
				class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", itemIndex, itemInfo );
				ParamAdd( param, "serverID" $ itemIndex, string(itemInfo.ClassID) );
				ParamAdd( param, "count"   $ itemIndex, string(itemInfo.Level) );
				ParamAdd( param, "price"   $ itemIndex, string(itemInfo.Price) ); // preco por uso
			}

			// Envia com um "tipo" novo para o servidor tratar como loja de buffs
			SendPrivateShopList("sellList", param);
		}
		else
		{
			// === MODO ITEM NORMAL (original) ===
			for( itemIndex=0 ; itemIndex < itemCount; ++itemIndex )
			{
				class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", itemIndex, itemInfo );
				ParamAdd( param, "serverID" $ itemIndex, string(itemInfo.ServerID) );
				ParamAdd( param, "count"    $ itemIndex, string(itemInfo.ItemNum) );
				ParamAdd( param, "price"    $ itemIndex, string(itemInfo.Price) );
			}

			SendPrivateShopList("sellList", param);
		}
	}
	else if( m_type == PT_Buy )
	{
	
	    itemCount = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "PrivateShopWnd.BottomList" );

		if (m_bBuffMode)
		{
			// Compra de buffs: enviar classID/level/price por linha
			ParamAdd( param, "merchantID", string(m_merchantID) );
			ParamAdd( param, "num", string(itemCount) );
			for (itemIndex = 0; itemIndex < itemCount; ++itemIndex)
			{
				class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", itemIndex, itemInfo );

				ParamAdd( param, "serverID" $ itemIndex, string(itemInfo.ClassID) ); // skillId
				ParamAdd( param, "count"   $ itemIndex, string(itemInfo.Level) );   // level do buff
				ParamAdd( param, "price"   $ itemIndex, string(itemInfo.Price) );   // preco por buff
			}
			SendPrivateShopList("buy", param);
			HideWindow("PrivateShopWnd");
			Clear();
			return;
		}
	
		// push merchantID(other user)
		ParamAdd( param, "merchantID", string(m_merchantID) );

		// pack every item in BottomList
		ParamAdd( param, "num", string(itemCount) );
		for( itemIndex=0 ; itemIndex < itemCount; ++itemIndex )
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", itemIndex, itemInfo );
			if( bPriceCheck && !IsProperPrice( itemInfo, itemInfo.Price ) )
				break;
			ParamAdd( param, "serverID" $ itemIndex, string(itemInfo.ServerID) );
			ParamAdd( param, "count" $ itemIndex, string(itemInfo.ItemNum) );
			ParamAdd( param, "price" $ itemIndex, string(itemInfo.Price) );
		}

		if( bPriceCheck && ( itemIndex < itemCount ) )		// there's some problem about price...
		{
			DialogSetID( DIALOG_CONFIRM_PRICE_FINAL );
			DialogShow( DIALOG_Warning, GetSystemMessage(569) );
			return;
		}
		else					// send packet
		{
			SendPrivateShopList("buy", param);
		}
	}
	else if( m_type == PT_BuyList )
	{
		// pack every item in BottomList
		ParamAdd( param, "num", string(itemCount) );
		for( itemIndex=0 ; itemIndex < itemCount; ++itemIndex )
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", itemIndex, itemInfo );
			ParamAdd( param, "classID" $ itemIndex, string(itemInfo.ClassID) );
			ParamAdd( param, "enchanted" $ itemIndex, string(itemInfo.Enchanted) );
			ParamAdd( param, "damaged" $ itemIndex, string(itemInfo.Damaged) );
			ParamAdd( param, "count" $ itemIndex, string(itemInfo.ItemNum) );
			ParamAdd( param, "price" $ itemIndex, string(itemInfo.Price) );
		}

		// Send packet
		SendPrivateShopList("buyList", param);
	}
	else if( m_type == PT_Sell )
	{
		// pack every item in BottomList
		ParamAdd( param, "merchantID", string(m_merchantID) );
		ParamAdd( param, "num", string(itemCount) );
		for( itemIndex=0 ; itemIndex < itemCount; ++itemIndex )
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( "PrivateShopWnd.BottomList", itemIndex, itemInfo );
			if( bPriceCheck && !IsProperPrice( itemInfo, itemInfo.Price ) )
				break;
			ParamAdd( param, "serverID" $ itemIndex, string(itemInfo.ServerID) );
			ParamAdd( param, "classID" $ itemIndex, string(itemInfo.ClassID) );
			ParamAdd( param, "enchanted" $ itemIndex, string(itemInfo.Enchanted) );
			ParamAdd( param, "damaged" $ itemIndex, string(itemInfo.Damaged) );
			ParamAdd( param, "count" $ itemIndex, string(itemInfo.ItemNum) );
			ParamAdd( param, "price" $ itemIndex, string(itemInfo.Price) );
		}

		if( bPriceCheck && ( itemIndex < itemCount ) )		// there's some problem about price...
		{
			DialogSetID( DIALOG_CONFIRM_PRICE_FINAL );
			DialogShow( DIALOG_Warning, GetSystemMessage(569) );
			return;
		}
		else					// send packet
		{
			SendPrivateShopList("sell", param);
		}
	}

	HideWindow("PrivateShopWnd");
	Clear();
}

function HandleSetMaxCount( string param )
{
	ParseInt( param, "privateShopSell", m_sellMaxCount );
	ParseInt( param, "privateShopBuy", m_buyMaxCount );
}

function bool IsProperPrice( out ItemInfo info, int price )
{
	if( info.DefaultPrice > 0 && ( price <= info.DefaultPrice / 5 || price >= info.DefaultPrice * 5 )  )
		return false;

	return true;
}

function int FindTopIndexByCurrentMode( int itemKey )
{
	if( m_bBuffMode )
		return class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.TopList", itemKey );
	else
		return class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.TopList", itemKey );
}

function int FindBottomIndexByCurrentMode( int itemKey )
{
	if( m_bBuffMode )
		return class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "PrivateShopWnd.BottomList", itemKey );
	else
		return class'UIAPI_ITEMWINDOW'.static.FindItemWithServerID( "PrivateShopWnd.BottomList", itemKey );
}

function Color SetColor (string m_Color)
{
	local Color MsnColor;

	switch (m_Color)
	{
		case "Yellow":
		MsnColor.R = 255;
		MsnColor.G = 255;
		MsnColor.B = 0;
		break;
		case "System":
		MsnColor.R = 176;
		MsnColor.G = 155;
		MsnColor.B = 121;
		break;
		case "Amber":
		MsnColor.R = 218;
		MsnColor.G = 165;
		MsnColor.B = 32;
		break;
		case "White":
		MsnColor.R = 255;
		MsnColor.G = 255;
		MsnColor.B = 255;
		break;
		case "Dim":
		MsnColor.R = 177;
		MsnColor.G = 173;
		MsnColor.B = 172;
		break;
		case "Magenta":
		MsnColor.R = 255;
		MsnColor.G = 0;
		MsnColor.B = 255;
		break;
		default:
	}
	return MsnColor;
}

defaultproperties
{
    // ===== SONGS & DANCES (Interlude) =====
    AllowedBuffIDs(0)=264    // Song of Earth
    AllowedBuffIDs(1)=265    // Song of Life
    AllowedBuffIDs(2)=266    // Song of Water
    AllowedBuffIDs(3)=267    // Song of Warding
    AllowedBuffIDs(4)=268    // Song of Wind
    AllowedBuffIDs(5)=269    // Song of Hunter
    AllowedBuffIDs(6)=270    // Song of Invocation
    AllowedBuffIDs(7)=271    // Dance of the Warrior
    AllowedBuffIDs(8)=272    // Dance of Inspiration
    AllowedBuffIDs(9)=273    // Dance of the Mystic
    AllowedBuffIDs(10)=274   // Dance of Fire
    AllowedBuffIDs(11)=275   // Dance of Fury
    AllowedBuffIDs(12)=276   // Dance of Concentration
    AllowedBuffIDs(13)=277   // Dance of Light
    AllowedBuffIDs(14)=304   // Song of Vitality
    AllowedBuffIDs(15)=305   // Song of Vengeance
    AllowedBuffIDs(16)=306   // Song of Flame Guard
    AllowedBuffIDs(17)=307   // Dance of Aqua Guard
    AllowedBuffIDs(18)=308   // Song of Storm Guard
    AllowedBuffIDs(19)=309   // Dance of Earth Guard
    AllowedBuffIDs(20)=310   // Dance of the Vampire
    // (311 Dance of Protection e 349/363/364/365/366/530 sao pos-Interlude -> nao incluidos)

    // ===== PROPHET / ELDER (PP/SE/EE) =====
    AllowedBuffIDs(21)=1040  // Shield
    AllowedBuffIDs(22)=1068  // Might
    AllowedBuffIDs(23)=1204  // Wind Walk
    AllowedBuffIDs(24)=1077  // Focus
    AllowedBuffIDs(25)=1242  // Death Whisper
    AllowedBuffIDs(26)=1240  // Guidance
    AllowedBuffIDs(27)=1086  // Haste
    AllowedBuffIDs(28)=1087  // Agility
    AllowedBuffIDs(29)=1085  // Acumen
    AllowedBuffIDs(30)=1059  // Empower
    AllowedBuffIDs(31)=1036  // Magic Barrier
    AllowedBuffIDs(32)=1035  // Mental Shield
    AllowedBuffIDs(33)=1243  // Bless Shield
    AllowedBuffIDs(34)=1045  // Bless the Body
    AllowedBuffIDs(35)=1048  // Bless the Soul
    AllowedBuffIDs(36)=1078  // Concentration
    AllowedBuffIDs(37)=1259  // Resist Shock
    AllowedBuffIDs(38)=1303  // Wild Magic
    AllowedBuffIDs(39)=1268  // Vampiric Rage
    AllowedBuffIDs(40)=1062  // Berserker Spirit
    AllowedBuffIDs(41)=1311  // Body of Avatar
    AllowedBuffIDs(42)=1033  // Resist Poison
    AllowedBuffIDs(43)=1043  // Holy Weapon
    AllowedBuffIDs(44)=1182  // Resist Aqua
    AllowedBuffIDs(45)=1189  // Resist Wind
    AllowedBuffIDs(46)=1191  // Resist Fire
    AllowedBuffIDs(47)=1352  // Elemental Protection
    AllowedBuffIDs(48)=1353  // Divine Protection
    AllowedBuffIDs(49)=1354  // Arcane Protection
    AllowedBuffIDs(50)=1388  // Greater Might
    AllowedBuffIDs(51)=1389  // Greater Shield
    AllowedBuffIDs(52)=1392  // Holy Resistance
    AllowedBuffIDs(53)=1393  // Unholy Resistance
    AllowedBuffIDs(54)=1397  // Clarity
    AllowedBuffIDs(55)=1323  // Noblesse Blessing
    AllowedBuffIDs(56)=1073  // Kiss of Eva (situacional)
    AllowedBuffIDs(57)=1257  // Decrease Weight (opcional utilitario)

    // ===== WARCRYER / OVERLORD =====
    AllowedBuffIDs(58)=1002  // Flame Chant
    AllowedBuffIDs(59)=1003  // Pa'agrio's Gift
    AllowedBuffIDs(60)=1004  // Wisdom of Pa'agrio
    AllowedBuffIDs(61)=1005  // Blessings of Pa'agrio
    AllowedBuffIDs(62)=1006  // Chant of Fire
    AllowedBuffIDs(63)=1007  // Chant of Battle
    AllowedBuffIDs(64)=1008  // Glory of Pa'agrio
    AllowedBuffIDs(65)=1009  // Chant of Shielding
    AllowedBuffIDs(66)=1251  // Chant of Fury
    AllowedBuffIDs(67)=1252  // Chant of Evasion
    AllowedBuffIDs(68)=1253  // Chant of Rage
    AllowedBuffIDs(69)=1260  // Tact of Pa'agrio
    AllowedBuffIDs(70)=1261  // Rage of Pa'agrio
    AllowedBuffIDs(71)=1282  // Pa'agrio's Haste
    AllowedBuffIDs(72)=1284  // Chant of Revenge
    AllowedBuffIDs(73)=1308  // Chant of Predator
    AllowedBuffIDs(74)=1309  // Chant of Eagle
    AllowedBuffIDs(75)=1310  // Chant of Vampire
    AllowedBuffIDs(76)=1362  // Chant of Spirit
    AllowedBuffIDs(77)=1363  // Chant of Victory
    AllowedBuffIDs(78)=1364  // Eye of Pa'agrio
    AllowedBuffIDs(79)=1365  // Soul of Pa'agrio
    AllowedBuffIDs(80)=1390  // War Chant
    AllowedBuffIDs(81)=1391  // Earth Chant
    AllowedBuffIDs(82)=1414  // Victory of Pa'agrio
    AllowedBuffIDs(83)=1415  // Pa'agrio's Emblem
    AllowedBuffIDs(84)=1416  // Pa'agrio's Fist

    // ===== PROPHECIES / MAGNUS (lvl 78+) =====
    AllowedBuffIDs(85)=1355  // Prophecy of Water
    AllowedBuffIDs(86)=1356  // Prophecy of Fire
    AllowedBuffIDs(87)=1357  // Prophecy of Wind
    AllowedBuffIDs(88)=1413  // Magnus' Chant

    // ===== SUMMONERS (OPCIONAIS; requer pet adequado) =====
    AllowedBuffIDs(89)=4699  // Blessing of Queen
    AllowedBuffIDs(90)=4700  // Gift of Queen
    AllowedBuffIDs(91)=4702  // Blessing of Seraphim
    AllowedBuffIDs(92)=4703  // Gift of Seraphim
}
