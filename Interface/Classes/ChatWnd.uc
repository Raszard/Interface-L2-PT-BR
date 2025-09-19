class ChatWnd extends UICommonAPI;

struct ChatFilterInfo
{
	var int bSystem;
	var int bChat;
	var int bDamage;
	var int bNormal;
	var int bShout;
	var int bClan;
	var int bParty;
	var int bTrade;
	var int bWhisper;
	var int bAlly;
	var int bUseitem;
	var int bHero;
	var int bUnion;
};

//Global Setting
var int	m_NoUnionCommanderMessage;

var array<ChatFilterInfo>	m_filterInfo;
var array<string>			m_sectionName;
var int						m_chatType;

const CHAT_WINDOW_NORMAL = 0;
const CHAT_WINDOW_TRADE = 1;
const CHAT_WINDOW_PARTY = 2;
const CHAT_WINDOW_CLAN = 3;
const CHAT_WINDOW_ALLY = 4;
const CHAT_WINDOW_COUNT = 5;
const CHAT_WINDOW_SYSTEM = 5;		// ��oA��o����AU �ˡ�������oAAo A��E

const CHAT_UNION_MAX = 35;			// AoEOA�ˢ��ϩ�I OnScreenMessage CNAU��?�ˢ� AO�ˡ�e����I ��ie��ui������I ��uo AO�ˡ�A ����UAU ��uo

//Handle List
var ChatWindowHandle NormalChat;
var ChatWindowHandle TradeChat;
var ChatWindowHandle PartyChat;
var ChatWindowHandle ClanChat;
var ChatWindowHandle AllyChat;
var ChatWindowHandle SystemMsg;
var TabHandle ChatTabCtrl;
var EditBoxHandle ChatEditBox;

function OnLoad()
{
	m_filterInfo.Length = CHAT_WINDOW_COUNT + 1;		// ��oCA|����I ��u�ϡ�AI�ˡ�A ����IA���� CHAT_WINDOW_COUNT �ˡ��ˡ�A����AIAo�ˡ��ˡ� CheckFilter�ˡ�| A��i �ˡ�o ������I����iCI����O A��I����aA����C���� CHAT_WINDOW_SYSTEM ��?e �ˡ�o��oI�ˡ�| CN�����ϩ� �ˡ�o CO�ˡ�cCN�ˡ�U.
	registerEvent( EV_ChatMessage );
	registerEvent( EV_IMEStatusChange );

	registerEvent( EV_ChatWndStatusChange );
	registerEvent( EV_ChatWndSetString );
	registerEvent( EV_ChatWndSetFocus );
	registerEvent( EV_ChatWndMsnStatus );
	registerEvent( EV_ChatWndMacroCommand );

	m_sectionName.Length = CHAT_WINDOW_COUNT;				// chatfilter.ini��?�ˢ硧u����AC C�����ˡ�n
	m_sectionName[CHAT_WINDOW_NORMAL] = "entire_tab";
	m_sectionName[CHAT_WINDOW_TRADE] = "pledge_tab";
	m_sectionName[CHAT_WINDOW_PARTY] = "party_tab";
	m_sectionName[CHAT_WINDOW_CLAN] = "market_tab";
	m_sectionName[CHAT_WINDOW_ALLY] = "ally_tab";
	
	// xml ��?�ˢ硧u���� GaimingState��?�ˢ� ��ii����IC���� AO����i ��?��I����a��u���� A�ϡ������ˢ碮��I OlympiadObserverState��?�ˢ��i��i ��ii����IC���� A�����ˡ�U.
	RegisterState( "ChatWnd", "OlympiadObserverState" );

	InitHandle();
	InitFilterInfo();
	InitGlobalSetting();
	InitScrollBarPosition();
}

//function OnExitState( name a_NextStateName )
//{
	//if (a_NextStateName == 'GamingState')
	//{
	//	ShowWindow("ChatWnd");
	//}
	//else if ( a_NextStateName == 'OlympiadObserverState')
	//{
	//	ShowWindow("ChatWnd");
	//}
	//else
	//{
	//HideWindow("ChatWnd");
	//}
//}

function OnDefaultPosition()
{
	ChatTabCtrl.MergeTab(CHAT_WINDOW_TRADE);
	ChatTabCtrl.MergeTab(CHAT_WINDOW_PARTY);
	ChatTabCtrl.MergeTab(CHAT_WINDOW_CLAN);
	ChatTabCtrl.MergeTab(CHAT_WINDOW_ALLY);
	ChatTabCtrl.SetTopOrder(0, true);
	
	class'UIAPI_WINDOW'.static.SetAnchor("ChatWnd", "", "BottomLeft", "BottomLeft", 0, 0 );
	HandleTabClick("ChatTabCtrl0");
}

function InitGlobalSetting()
{
	class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxCommand", bool(m_NoUnionCommanderMessage) );
}

function InitHandle()
{
	NormalChat = ChatWindowHandle( GetHandle("ChatWnd.NormalChat") );
	TradeChat = ChatWindowHandle( GetHandle("ChatWnd.TradeChat") );
	PartyChat = ChatWindowHandle( GetHandle("ChatWnd.PartyChat") );
	ClanChat = ChatWindowHandle( GetHandle("ChatWnd.ClanChat") );
	AllyChat = ChatWindowHandle( GetHandle("ChatWnd.AllyChat") );
	SystemMsg = ChatWindowHandle( GetHandle("SystemMsgWnd.SystemMsgList") );
	ChatTabCtrl = TabHandle( GetHandle("ChatWnd.ChatTabCtrl") );
	ChatEditBox = EditBoxHandle( GetHandle("ChatWnd.ChatEditBox") );
}

function InitScrollBarPosition()
{
	NormalChat.SetScrollBarPosition( 5, 10, -25 );
	TradeChat.SetScrollBarPosition( 5, 10, -25 );
	PartyChat.SetScrollBarPosition( 5, 10, -25 );
	ClanChat.SetScrollBarPosition( 5, 10, -25 );
	AllyChat.SetScrollBarPosition( 5, 10, -25 );
}

function OnCompleteEditBox( String strID )
{
	local String strInput;
	local EChatType Type;
	
	if( strID == "ChatEditBox" )
	{
		strInput = ChatEditBox.GetString();
		if ( Len( strInput ) < 1 )
			return;
			
		// >>> INTERCEPTA /inspect local
        if (Left(strInput, 9) == "/inspect ")
        {
            HandleInspectCommand( Mid(strInput, 9) );
            ChatEditBox.SetString("");
            return;
        }
		
		ProcessChatMessage( strInput, m_chatType );
		ChatEditBox.SetString( "" );
		
		//A�ˢ�����A����aE��I
		if( GetOptionBool( "Game", "OldChatting" ) == true)
		{
			Type = GetChatTypeByTabIndex( m_chatType );
			
			//AI��oYACAI ��u�����ˡ�N �����Ϣ���?i, Prefix�ˡ�| ����U��?��IA�����ˡ�U.
			if ( m_chatType != CHAT_WINDOW_NORMAL )
				ChatEditBox.AddString( GetChatPrefix( Type ) );
		}
		
		//��?��IAIA�ˢ�����A
		if( GetOptionBool( "Game", "EnterChatting" ) == true)
		{
			ChatEditBox.ReleaseFocus();
		}
	}
}

function Clear()
{
	ChatEditBox.Clear();
	NormalChat.Clear();
	PartyChat.Clear();
	ClanChat.Clear();
	TradeChat.Clear();
	AllyChat.Clear();
	SystemMsg.Clear();
}

function OnShow()
{
	if( GetOptionBool("Game", "SystemMsgWnd") )
	{
		ShowWindow("SystemMsgWnd");
	}
	else
	{
		HideWindow("SystemMsgWnd");
	}

	HandleIMEStatusChange();
}

function OnClickButton( String strID )
{
	local PartyMatchWnd script;
	script = PartyMatchWnd( GetScript( "PartyMatchWnd" ) );
	switch( strID )
	{
	case "ChatTabCtrl0":
	case "ChatTabCtrl1":
	case "ChatTabCtrl2":
	case "ChatTabCtrl3":
	case "ChatTabCtrl4":
		HandleTabClick(strID);
		break;
	case "ChatFilterBtn":
		if (class'UIAPI_WINDOW'.static.IsShowWindow( "ChatFilterWnd" ))
		{
			class'UIAPI_WINDOW'.static.HideWindow( "ChatFilterWnd" );
		}
		else
		{
			SetChatFilterButton();
			class'UIAPI_WINDOW'.static.ShowWindow( "ChatFilterWnd" );
		}
		break;
	case "MessengerBtn":
		ToggleMsnWindow();
		break;
	case "PartyMatchingBtn":
		if (class'UIAPI_WINDOW'.static.IsShowWindow( "PartyMatchWnd" ) == true)
		{
			class'UIAPI_WINDOW'.static.HideWindow( "PartyMatchWnd" );
			script.OnSendPacketWhenHiding();
		}
		else
		{
			class'PartyMatchAPI'.static.RequestOpenPartyMatch();
		}
		break;
	default:
		break;
	};
}

function OnTabSplit( string sTabButton )
{
	local ChatWindowHandle handle;
	
	switch( sTabButton )
	{
	case "ChatTabCtrl0":
		handle = NormalChat;
		HandleTabClick(sTabButton);
		break;
	case "ChatTabCtrl1":
		handle = TradeChat;
		HandleTabClick(sTabButton);
		break;
	case "ChatTabCtrl2":
		handle = PartyChat;
		HandleTabClick(sTabButton);
		break;
	case "ChatTabCtrl3":
		handle = ClanChat;
		HandleTabClick(sTabButton);
		break;
	case "ChatTabCtrl4":
		handle = AllyChat;
		HandleTabClick(sTabButton);
		break;
	default:
		break;
	};
	if (handle!=None)
	{
		handle.SetWindowSizeRel( -1.0f, -1.0f, 0, 0 );	//RelativeSizeC����A|
		handle.SetSettledWnd( true );
		handle.EnableTexture( true );
	}
}

function OnTabMerge( string sTabButton )
{
	local ChatWindowHandle handle;
	local int width, height;
	local Rect rectWnd;
	
	switch( sTabButton )
	{
	case "ChatTabCtrl0":
		handle = NormalChat;
		break;
	case "ChatTabCtrl1":
		handle = TradeChat;
		break;
	case "ChatTabCtrl2":
		handle = PartyChat;
		break;
	case "ChatTabCtrl3":
		handle = ClanChat;
		break;
	case "ChatTabCtrl4":
		handle = AllyChat;
		break;
	default:
		break;
	};
	if (handle!=None)
	{
		rectWnd = NormalChat.GetRect();
		NormalChat.GetWindowSize( width, height );
		
		handle.SetSettledWnd( false );
		handle.MoveTo( rectWnd.nX, rectWnd.nY );
		handle.SetWindowSize( width, height - 46 );
		handle.SetWindowSizeRel( 1.0f, 1.0f, 0, -46 );
		handle.EnableTexture( false );
	}
}

function HandleTabClick( string strID )
{
	local string strInput;
	local string strPrefix;
	local int strLen;
	
	m_chatType = ChatTabCtrl.GetTopIndex();
	SetChatFilterButton();
	
	//A�ˢ�����A����aE��I
	if( GetOptionBool( "Game", "OldChatting" ) == true)
	{
		strInput = ChatEditBox.GetString();
		strLen = Len(strInput);
		
		//Prefix�����ˢ� AOA�ˡ��ˡ�e, A|����A(AI�ˡ�U �����Ϣ�AI�ˡ�A 1����I �����ˢ�A�ˢ�CN�ˡ�U)
		strPrefix = Left( strInput, 1 );
		if ( IsSameChatPrefix(CHAT_MARKET, strPrefix)
			|| IsSameChatPrefix(CHAT_PARTY, strPrefix)
			|| IsSameChatPrefix(CHAT_CLAN, strPrefix)
			|| IsSameChatPrefix(CHAT_ALLIANCE, strPrefix) )
		{
			strInput = Right( strInput, strLen-1 );
		}
		
		//AI��oYACAI ��u�����ˡ�N �����Ϣ���?i, ����?�����Ϣ���iE Prefix�ˡ�| ����U��?��IA�����ˡ�U.
		if ( m_chatType != CHAT_WINDOW_NORMAL )
		{
			strPrefix = GetChatPrefix(GetChatTypeByTabIndex(m_chatType));
			strInput = strPrefix $ strInput;
		}
		
		ChatEditBox.SetString(strInput);
	}
}

function OnEnterState( name a_PrevStateName )
{
	if( a_PrevStateName == 'LoadingState' )			// ����OAO A�ϡ���?�ˢ� �ˡ�U�ˡ���I ��o����A����AI������c(��o��������a��uEA��i�ˡ�������Oo ��ii)A�ˡ�����I ���������ˡ�U�����ˢ� �ˡ�U��oA ��ie��ui��?A�ˡ�A �����Ϣ���?i�ˡ�A Clear()�ˡ�| ����O����?AO�ˡ�e ��uE��iC����a��O������o��c��?�ˢ�
	{
		Clear();
	}
}

function OnEvent(int Event_ID, String param)
{
	switch( Event_ID )
	{
	case EV_ChatMessage:
		HandleChatMessage( param );
	case EV_IMEStatusChange:
		HandleIMEStatusChange();
		break;
	case EV_ChatWndStatusChange:
		HandleChatWndStatusChange();
		break;
	case EV_ChatWndSetFocus:
		HandleSetFocus();
		break;
	case EV_ChatWndSetString:
		HandleSetString( param );
		break;
	case EV_ChatWndMsnStatus:
		HandleMsnStatus(param);
		break;
	case EV_ChatWndMacroCommand:
		HandleChatWndMacroCommand( param );
		break;
	default:
		break;
	}
}

//�ˡ�AA��I����IA��?�ˡ�C��iaAC ��oCCa, UCAC ChatType��?�ˢ� �ˡ�A����O ��oCCa��iC��ui��u�ϡ�CN�ˡ�U.
function HandleChatWndMacroCommand( string param )
{
	local string Command;
	
	if (!ParseString(param, "Command", Command))
		return;
		
	ProcessChatMessage( Command, m_chatType );
}

function HandleChatmessage( String param )
{
	local int				nTmp;
	local EChatType		type;
	local ESystemMsgType	systemType;
	local string			text;
	local Color			color;

	ParseInt(param, "Type", nTmp);
	type = EChatType(nTmp);
	
	ParseString(param, "Msg", text);
	ParseInt(param, "ColorR", nTmp);
	Color.R = nTmp;
	ParseInt(param, "ColorG", nTmp);
	Color.G = nTmp;
	ParseInt(param, "ColorB", nTmp);
	Color.B = nTmp;
	color.A = 255;
	
	if( type == CHAT_SYSTEM )
	{
		ParseInt(param, "SysType", nTmp);	
		systemType = ESystemMsgType(nTmp);
	}
	else 
	{
		systemType = SYSTEM_NONE;
	}
		
	if( CheckFilter( type, CHAT_WINDOW_NORMAL, systemType ) )
		NormalChat.AddString( text, color );
	if( CheckFilter( type, CHAT_WINDOW_PARTY, systemType ) )
		PartyChat.AddString( text, color );
	if( CheckFilter( type, CHAT_WINDOW_CLAN, systemType ) )
		ClanChat.AddString( text, color );
	if( CheckFilter( type, CHAT_WINDOW_TRADE, systemType ) )
		TradeChat.AddString( text, color );
	if( CheckFilter( type, CHAT_WINDOW_ALLY, systemType) )
		AllyChat.AddString( text, color );

	if( CheckFilter( type, CHAT_WINDOW_SYSTEM, systemType ) )
		SystemMsg.AddString( text, color );
		
	//Union Commander Message
	if ( type == CHAT_COMMANDER_CHAT && m_NoUnionCommanderMessage == 0 )
	{
		ShowUnionCommanderMessgage( text );
	}
}


function ShowUnionCommanderMessgage(string Msg)
{
	local string	strParam;
	local string MsgTemp;
	local string MsgTemp2;
	local int maxlength;
	
	maxlength = Len(Msg);
	
	
	if (maxlength > CHAT_UNION_MAX)
	{
		
		MsgTemp = Left(Msg, CHAT_UNION_MAX);
		MsgTemp2 = Right(Msg, maxlength - CHAT_UNION_MAX);
		Msg = MsgTemp $"#"$ MsgTemp2 ;
		
		
	}


	debug (Msg);

	if (Len(Msg)>0)
	{
		
		ParamAdd(strParam, "MsgType", String(1));
		ParamAdd(strParam, "WindowType", String(8));
		ParamAdd(strParam, "FontType", String(0));
		ParamAdd(strParam, "BackgroundType",String(0));
		ParamAdd(strParam, "LifeTime", String(5000));
		ParamAdd(strParam, "AnimationType", String(1));
		ParamAdd(strParam, "Msg", Msg);
		ParamAdd(strParam, "MsgColorR", String(255));
		ParamAdd(strParam, "MsgColorG", String(150));
		ParamAdd(strParam, "MsgColorB", String(149));
		ExecuteEvent(EV_ShowScreenMessage, strParam);
	}
}

function HandleIMEStatusChange()
{
	local string texture;
	local EIMEType imeType;
	imeType = GetCurrentIMELang();
	switch( imeType )
	{
	case IME_KOR:
		texture = "L2UI.ChatWnd.IME_kr";
		break;
	case IME_ENG:
		texture = "L2UI.ChatWnd.IME_en";
		break;
	case IME_JPN:
		texture = "L2UI.ChatWnd.IME_jp";
		break;
	case IME_CHN:
		texture = "L2UI.ChatWnd.IME_jp";
		break;
	case IME_TAIWAN_CHANGJIE:
		texture = "L2UI.ChatWnd.IME_tw2";
		break;
	case IME_TAIWAN_DAYI:
		texture = "L2UI.ChatWnd.IME_tw3";
		break;
	case IME_TAIWAN_NEWPHONETIC:
		texture = "L2UI.ChatWnd.IME_tw1";
		break;
	case IME_CHN_MS:
		texture = "L2UI.ChatWnd.IME_cn1";
		break;
	case IME_CHN_JB:
		texture = "L2UI.ChatWnd.IME_cn2";
		break;
	case IME_CHN_ABC:
		texture = "L2UI.ChatWnd.IME_cn3";
		break;
	case IME_CHN_WUBI:
		texture = "L2UI.ChatWnd.IME_cn4";
		break;
	case IME_CHN_WUBI2:
		texture = "L2UI.ChatWnd.IME_cn4";
		break;
	case IME_THAI:
		texture = "L2UI.ChatWnd.IME_th";
		break;
	default:
		texture = "Default.BlackTexture";
		break;
	};

	class'UIAPI_TEXTURECTRL'.static.SetTexture("ChatWnd.LanguageTexture", texture);
}

function bool CheckFilter( EChatType type, int windowType, ESystemMsgType systemType )		// systemTypeA���� CHAT_SYSTEMAI �����Ϣ���?i�ˡ��ˡ� �ϩ�N����UAO�ˡ�e��iE�ˡ�U
{
	if( !( windowType >= 0 && windowType < CHAT_WINDOW_COUNT ) && windowType != CHAT_WINDOW_SYSTEM )
	{
		debug("ChatWnd: Error invalid windowType " $ windowType );
		return false;
	}

	if( type == CHAT_MARKET && m_filterInfo[windowtype].bTrade != 0)
	{
		return true;
	}
	else if( type == CHAT_NORMAL && m_filterInfo[windowType].bNormal != 0 )
	{
		return true;
	}
	else if( type == CHAT_CLAN && m_filterInfo[windowType].bClan != 0 )
	{
		return true;
	}
	else if( type == CHAT_PARTY && m_filterInfo[windowType].bParty != 0 )
	{
		return true;
	}
	else if( type == CHAT_SHOUT && m_filterInfo[windowType].bShout != 0 )
	{
		return true;
	}
	else if( type == CHAT_TELL && m_filterInfo[windowType].bWhisper != 0 )
	{
		return true;
	}
	else if( type == CHAT_ALLIANCE && m_filterInfo[windowType].bAlly != 0 )
	{
		return true;
	}
	else if( type == CHAT_HERO && m_filterInfo[windowType].bHero != 0 )
	{
		return true;
	}
	else if( type == CHAT_ANNOUNCE || type == CHAT_CRITICAL_ANNOUNCE || type == CHAT_USER_PET || type == CHAT_GM_PET )
	{
		return true;
	}
	else if( ( type == CHAT_INTER_PARTYMASTER_CHAT || type == CHAT_COMMANDER_CHAT ) && m_filterInfo[windowType].bUnion != 0 )
	{
		return true;
	}
	else if( type == CHAT_SYSTEM )
	{
		if( systemType == SYSTEM_SERVER || systemType == SYSTEM_PETITION )
			return true;
		else if( windowType == CHAT_WINDOW_SYSTEM )			// ��oA��o����AU �ˡ�������oAAo A��EAI�ˡ�e ��?E��uCA��i �����ˡ�����i
		{
			if( systemType == SYSTEM_DAMAGE )
			{
				if( GetOptionBool("Game", "SystemMsgWndDamage") )
					return true;
				else 
					return false;
			}
			else if( systemType == SYSTEM_USEITEMS )
			{
				if( GetOptionBool("Game", "SystemMsgWndExpendableItem" ) )
					return true;
				else 
					return false;
			}
			else if( systemType == SYSTEM_BATTLE || systemType == SYSTEM_NONE  )
				return true;

			return false;
		}
		else if( m_filterInfo[windowType].bSystem != 0 )
		{
			if( systemType == SYSTEM_DAMAGE )
			{
				if( m_filterInfo[windowType].bDamage != 0 )
					return true;
				else 
					return false;
			}
			else if( systemType == SYSTEM_USEITEMS )
			{
				if( m_filterInfo[windowType].bUseItem != 0 )
					return true;
				else 
					return false;
			}
			return true;
		}
		return false;
	}

	return false;
}

// init with chatfilter.ini
function InitFilterInfo()
{
	local int i;
	local int tempVal;
	
	SetDefaultFilterValue();
	for( i=0; i < CHAT_WINDOW_COUNT ; ++i )
	{
		if( GetINIBool( m_sectionName[i], "system", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bSystem = tempVal;

		if( GetINIBool( m_sectionName[i], "chat", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bChat = tempVal;
		
		if( GetINIBool( m_sectionName[i], "normal", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bNormal = tempVal;
		
		if( GetINIBool( m_sectionName[i], "shout", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bShout = tempVal;
		
		if( GetINIBool( m_sectionName[i], "pledge", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bClan = tempVal;
		
		if( GetINIBool( m_sectionName[i], "party", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bParty = tempVal;
		
		if( GetINIBool( m_sectionName[i], "market", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bTrade = tempVal;
		
		if( GetINIBool( m_sectionName[i], "tell", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bWhisper = tempVal;
		
		if( GetINIBool( m_sectionName[i], "damage", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bDamage = tempVal;
		
		if( GetINIBool( m_sectionName[i], "ally", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bAlly = tempVal;
		
		if( GetINIBool( m_sectionName[i], "useitems", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bUseItem = tempVal;
		
		if( GetINIBool( m_sectionName[i], "hero", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bHero = tempVal;
			
		if( GetINIBool( m_sectionName[i], "union", tempVal, "chatfilter.ini" ) )
			m_filterInfo[i].bUnion = tempVal;
	}
	
	// ����aA�ˡ�AC A�ϡ��ˡ��Ϩ���iE INI�ˡ�| �����ˢ�A�Ϩ� A?Au��ieA��i A����C���� ����a������i ��������A��i C������io �ˡ���c��uACN�ˡ�U. 
	SetDefaultFilterOn();
	
	//Global Setting
	if( GetINIBool( "global", "command", tempVal, "chatfilter.ini" ) )
		m_NoUnionCommanderMessage = tempVal;
}


function SetDefaultFilterOn()
{
	m_filterInfo[ CHAT_WINDOW_TRADE ].bTrade = 1;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bParty = 1;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bClan = 1;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bAlly = 1;
}

function SetDefaultFilterValue()
{
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bSystem = 1;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bChat = 1;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bNormal = 1;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bShout = 1;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bClan = 1;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bParty = 1;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bTrade = 0;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bWhisper = 1;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bDamage = 1;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bAlly = 0;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bUseItem = 0;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bHero = 0;
	m_filterInfo[ CHAT_WINDOW_NORMAL ].bUnion = 1;
	
	m_filterInfo[ CHAT_WINDOW_TRADE ].bSystem = 1;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bChat = 1;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bNormal = 0;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bShout = 1;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bClan = 0;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bParty = 0;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bTrade = 1;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bWhisper = 1;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bDamage = 1;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bAlly = 0;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bUseItem = 0;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bHero = 0;
	m_filterInfo[ CHAT_WINDOW_TRADE ].bUnion = 0;
	
	m_filterInfo[ CHAT_WINDOW_PARTY ].bSystem = 1;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bChat = 1;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bNormal = 0;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bShout = 1;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bClan = 0;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bParty = 1;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bTrade = 0;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bWhisper = 1;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bDamage = 1;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bAlly = 0;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bUseItem = 0;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bHero = 0;
	m_filterInfo[ CHAT_WINDOW_PARTY ].bUnion = 0;
	
	m_filterInfo[ CHAT_WINDOW_CLAN ].bSystem = 1;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bChat = 1;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bNormal = 0;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bShout = 1;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bClan = 1;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bParty = 0;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bTrade = 0;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bWhisper = 1;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bDamage = 1;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bAlly = 0;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bUseItem = 0;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bHero = 0;
	m_filterInfo[ CHAT_WINDOW_CLAN ].bUnion = 0;
	
	m_filterInfo[ CHAT_WINDOW_ALLY ].bSystem = 1;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bChat = 1;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bNormal = 0;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bShout = 1;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bClan = 0;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bParty = 0;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bTrade = 0;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bWhisper = 1;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bDamage = 1;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bAlly = 1;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bUseItem = 0;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bHero = 0;
	m_filterInfo[ CHAT_WINDOW_ALLY ].bUnion = 0;
	
	//��oCA| ��ic��?e��iCAo�ˡ�A ��uE�ˡ�A �ˡ�o��oI �������̡�ie
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bSystem = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bChat = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bNormal = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bShout = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bClan = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bParty = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bTrade = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bWhisper = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bDamage = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bAlly = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bUseItem = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bHero = 0;
	m_filterInfo[ CHAT_WINDOW_SYSTEM ].bUnion = 0;
	
	//Global Setting
	m_NoUnionCommanderMessage = 0;
}

// A�ˢ�����A CEAI A��EAC A��uA��I��oU��o���� ��ieA��i m_filterInfo��?�ˢ��iu��Oo ��u��u����AC���� AO����i ��?E��uC����O��?�ˢ硧u���� ��oA��o����AU �ˡ�������oAAo Au��?eA��EAC A����A�ˢ�ˡ�| ����A��uCCN�ˡ�U.
function SetChatFilterButton()
{
	local bool bSystemMsgWnd;
	local bool bOption;
	
	// ��oA��o����AU �ˡ�������oAAo A��I��i��i��?i 
	bSystemMsgWnd = GetOptionBool( "Game", "SystemMsgWnd" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.SystemMsgBox", bSystemMsgWnd );
		
	// ��i��I��oIAo - DamageBox
	bOption = GetOptionBool( "Game", "SystemMsgWndDamage" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.DamageBox", bOption );

	// ��uO�ˡ��ϡ̡�u������u����AIAU��ic��?e - ItemBox
	bOption = GetOptionBool( "Game", "SystemMsgWndExpendableItem" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.ItemBox", bOption );
		
	//debug("SetChatFilterButton : chattype " $ m_chatType );
	if( m_chatType >= 0 && m_chatType < CHAT_WINDOW_COUNT )
	{
		//Print( m_chatType );
		
		switch (m_chatType)
		{
			//AuA��u 
			case 0:
				class'UIAPI_TEXTBOX'.static.SetText("ChatFilterWnd.CurrentText",MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(144) , "" ));
				break;
			//�ˡ�A�ˡ�A
			case 1:
				class'UIAPI_TEXTBOX'.static.SetText("ChatFilterWnd.CurrentText",MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(355) , "" ));
				break;
			//����A������u
			case 2:
				class'UIAPI_TEXTBOX'.static.SetText("ChatFilterWnd.CurrentText",MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(188) , "" ));
				break;
			//C��A�ˡ�I
			case 3:
				class'UIAPI_TEXTBOX'.static.SetText("ChatFilterWnd.CurrentText",MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(128) , "" ));
				break;
			//��i��?�ˡ�I
			case 4:
				class'UIAPI_TEXTBOX'.static.SetText("ChatFilterWnd.CurrentText",MakeFullSystemMsg( GetSystemMessage(1995), GetSystemString(559) , "" ));
				break;
		}
		
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxSystem", bool(m_filterInfo[m_chatType].bSystem ) );
		//class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxChat", bool(m_filterInfo[m_chatType].bChat ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxNormal", bool(m_filterInfo[m_chatType].bNormal ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxShout", bool(m_filterInfo[m_chatType].bShout ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxPledge", bool(m_filterInfo[m_chatType].bClan ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxParty", bool(m_filterInfo[m_chatType].bParty ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxTrade", bool(m_filterInfo[m_chatType].bTrade ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxWhisper", bool(m_filterInfo[m_chatType].bWhisper ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxDamage", bool(m_filterInfo[m_chatType].bDamage ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxAlly", bool(m_filterInfo[m_chatType].bAlly ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxItem", bool(m_filterInfo[m_chatType].bUseItem ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxHero", bool(m_filterInfo[m_chatType].bHero ) );
		class'UIAPI_CHECKBOX'.static.SetCheck( "ChatFilterWnd.CheckBoxUnion", bool(m_filterInfo[m_chatType].bUnion ) );

		//Print( m_chatType );
		// A��i A��iA��������i�ˡ���c�����ˢ� A��uA��I ��iC��uu�ˡ�AAo ��?��I����I��?�ˢ� ��iu��Oo AUA���� A��iA��������i�ˡ���cAC checkbox�ˡ�| E������u����/����nE������u���� CN�ˡ�U.
		if( !class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxSystem" ) )
		{
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxDamage", true );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxItem", true );
		}
		else
		{
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxDamage", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxItem", false );
		}

		// A��i A��iA��������i�ˡ���c�����ˢ� A��uA��I ��iC��uu�ˡ�AAo ��?��I����I��?�ˢ� ��iu��Oo AUA���� A��iA��������i�ˡ���cAC checkbox�ˡ�| E������u����/����nE������u���� CN�ˡ�U.
//		if( !class'UIAPI_CHECKBOX'.static.IsChecked( "ChatFilterWnd.CheckBoxChat" ) )
//		{
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxNormal", false );
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxShout", false );
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxPledge", false );
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxParty", false );
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxTrade", false );
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxWhisper", false );
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxAlly", false );
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxHero", false );
//			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxUnion", false );
//		}
//		else
		
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxNormal", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxShout", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxPledge", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxParty", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxTrade", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxWhisper", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxAlly", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxHero", false );
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxUnion", false );
		

		// E������u����E���� ��iE��uo ��u�Ϩ��ˡ�A A��uA��I��oU��o����(����a������iAuA�ˡ�����I A��uA��I��?��I����I�ˡ�| A?Au�����ˢ� ����aA�ˢ�CO ��uo ��u�Ϩ��ˡ�A ����I ��ie)
		switch( m_chatType )
		{
		case CHAT_WINDOW_TRADE:
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxTrade", true );
			break;
		case CHAT_WINDOW_PARTY:
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxParty", true );
			break;
		case CHAT_WINDOW_CLAN:
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxPledge", true );
			break;
		case CHAT_WINDOW_ALLY:
			class'UIAPI_CHECKBOX'.static.SetDisable( "ChatFilterWnd.CheckBoxAlly", true );
			break;
		default:
			break;
		}
	}
}

function HandleChatWndStatusChange()
{
	local UserInfo userInfo;

	GetPlayerInfo( userInfo );

	if( userInfo.nClanID > 0 )
		ChatTabCtrl.SetDisable(CHAT_WINDOW_CLAN, false);
	else
		ChatTabCtrl.SetDisable(CHAT_WINDOW_CLAN, true);

	if( userInfo.nAllianceID > 0 )
		ChatTabCtrl.SetDisable(CHAT_WINDOW_ALLY, false);
	else
		ChatTabCtrl.SetDisable(CHAT_WINDOW_ALLY, true);
}

function HandleSetString( String a_Param )
{
	local string tmpString;

	if( ParseString( a_Param, "String", tmpString ) )
		ChatEditBox.SetString(tmpString);
}

function HandleSetFocus()
{
	if( !ChatEditBox.IsFocused() )
		ChatEditBox.SetFocus();
}

function Print( int index )
{
	//debug( "Self=" $ Self $ " m_chatType=" $ m_chatType );
	debug( "Print type(" $ index $ "), system :"	$ m_filterInfo[ index ].bSystem $ ", chat:" $ m_filterInfo[ index ].bChat $ ",Normal:" $ m_filterInfo[ index ].bNormal $
		", shout:" $ m_filterInfo[ index ].bShout $ ",pledge:" $ m_filterInfo[ index ].bClan $ ", party:" $ m_filterInfo[ index ].bParty $ 
		", trade:" $ m_filterInfo[ index ].bTrade $ ", whisper:" $ m_filterInfo[ index ].bWhisper $ ", damage:" $ m_filterInfo[ index ].bDamage $
		", ally:" $ m_filterInfo[ index ].bAlly $ ",useitem:" $ m_filterInfo[ index ].bUseItem $ ", hero:" $ m_filterInfo[ index ].bHero );
}

function HandleMsnStatus( string param )
{
	local string status;
	local ButtonHandle handle;

	handle = ButtonHandle(GetHandle("Chatwnd.MessengerBtn"));

	ParseString( param, "status", status );
	if( status == "online" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn1", "L2UI_CH3.Msn.chatting_msn1_down", "");
	else if( status == "berightback" || status == "idle" || status == "away" || status == "lunch" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn2", "L2UI_CH3.Msn.chatting_msn2_down", "");
	else if( status == "busy" || status == "onthephone" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn3", "L2UI_CH3.Msn.chatting_msn3_down", "");
	else if( status == "offline" || status == "invisible" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn4", "L2UI_CH3.Msn.chatting_msn4_down", "");
	else if( status == "none" )
		handle.SetTexture("L2UI_CH3.Msn.chatting_msn5", "L2UI_CH3.Msn.chatting_msn5_down", "");
}

function EChatType GetChatTypeByTabIndex(int Index)
{
	local EChatType Type;
	Type = CHAT_NORMAL;
	
	switch( m_chatType )
	{
	case CHAT_WINDOW_NORMAL:
		Type = CHAT_NORMAL;
		break;
	case CHAT_WINDOW_TRADE:
		Type = CHAT_MARKET;
		break;
	case CHAT_WINDOW_PARTY:
		Type = CHAT_PARTY;
		break;
	case CHAT_WINDOW_CLAN:
		Type = CHAT_CLAN;
		break;
	case CHAT_WINDOW_ALLY:
		Type = CHAT_ALLIANCE;
		break;
	default:
		break;
	}
	return Type;
}

function int FromBase36(string s)
{
    local string digs; local int i, v, idx;
    digs = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"; v = 0;
    for (i = 0; i < Len(s); ++i)
    {
        idx = InStr(digs, Mid(s, i, 1));
        if (idx >= 0) v = v*36 + idx;
    }
    return v;
}

function bool BuildItemInfoFromClass(out ItemInfo Item, int ClassID, int Ench, int Op1, int Op2)
{
    // Carrega todos os campos nativos do item (nome, desc, tipos, stats, etc.)
    if ( !class'UIDATA_ITEM'.static.GetItemInfo(ClassID, Item) )
        return false;

    // Ajusta o que vem do link
    Item.Enchanted   = Ench;
    Item.RefineryOp1 = Op1;
    Item.RefineryOp2 = Op2;

    // Opcional: ja aplica o nome de refino no Name que sera exibido
    Item.Name = class'UIDATA_ITEM'.static.GetRefineryItemName(Item.Name, Item.RefineryOp1, Item.RefineryOp2);
    return true;
}

function bool ParseItemLinkToken(string token, out ItemInfo Item)
{
    local int p1, p2; local string core;
    local array<string> parts;
    local int cid, ench, op1, op2, pos;

    p1 = InStr(token, "[[I:");
    p2 = InStr(token, "]]");
    if (p1 == -1 || p2 == -1 || p2 <= p1+4) return false;

    core = Mid(token, p1+4, p2-(p1+4));

    while (true)
    {
        pos = InStr(core, ":");
        if (pos == -1) { parts[parts.Length] = core; break; }
        parts[parts.Length] = Left(core, pos);
        core = Mid(core, pos+1);
    }

    cid  = FromBase36(parts[0]);          // <-- todos INT
	if (parts.Length > 1) ench = FromBase36(parts[1]);
	if (parts.Length > 2) op1  = FromBase36(parts[2]);
	if (parts.Length > 3) op2  = FromBase36(parts[3]);

    return BuildItemInfoFromClass(Item, cid, ench, op1, op2);
}

function ShowItemPopup(ItemInfo I)
{
    local string msg, grade, ench;
    grade = GetItemGradeString(I.CrystalType);
    if (I.Enchanted > 0) ench = "+" $ string(I.Enchanted) $ " ";
    msg = ench $ class'UIDATA_ITEM'.static.GetRefineryItemName(I.Name, I.RefineryOp1, I.RefineryOp2);
    if (Len(grade) > 0) msg = msg $ " (" $ grade $ ")";

    ExecuteEvent(EV_ShowScreenMessage,
        "MsgType=1|WindowType=8|FontType=0|BackgroundType=0|LifeTime=5000|AnimationType=1|Msg=" $ msg $ "|MsgColorR=255|MsgColorG=217|MsgColorB=105");
}

function HandleInspectCommand(string token)
{
    local ItemInfo it;
    if (ParseItemLinkToken(token, it))
        ShowItemPopup(it);
}

defaultproperties
{
}