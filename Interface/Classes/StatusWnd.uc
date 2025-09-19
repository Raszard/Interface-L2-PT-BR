class StatusWnd extends UIScript;

var int m_UserID;
var bool m_bReceivedUserInfo;

//�̺�Ʈ ���
function OnLoad()
{
	RegisterEvent( EV_RegenStatus );
	
	//Level�� Exp�� UserInfo��Ŷ���� ó���Ѵ�.
	RegisterEvent( EV_UpdateUserInfo );
	
	RegisterEvent( EV_UpdateHP );
	RegisterEvent( EV_UpdateMaxHP );
	RegisterEvent( EV_UpdateMP );
	RegisterEvent( EV_UpdateMaxMP );
	RegisterEvent( EV_UpdateCP );
	RegisterEvent( EV_UpdateMaxCP );
}

function OnEnterState( name a_PreStateName )
{
	m_bReceivedUserInfo = false;
	UpdateUserInfo();
}

function UpdateUserInfo()
{
	local UserInfo userinfo;

	if( GetPlayerInfo( userinfo ) )
	{
		m_bReceivedUserInfo = true;
		m_UserID = userinfo.nID;
		
		class'UIAPI_STATUSBARCTRL'.static.SetPoint("StatusWnd.CPBar",userinfo.nCurCP,userinfo.nMaxCP);
		class'UIAPI_STATUSBARCTRL'.static.SetPoint("StatusWnd.HPBar",userinfo.nCurHP,userinfo.nMaxHP);
		class'UIAPI_STATUSBARCTRL'.static.SetPoint("StatusWnd.MPBar",userinfo.nCurMP,userinfo.nMaxMP);
		class'UIAPI_STATUSBARCTRL'.static.SetPointExp("StatusWnd.EXPBar",userinfo.nCurExp,userinfo.nLevel);
		class'UIAPI_NAMECTRL'.static.SetName("StatusWnd.UserName",userinfo.Name,NCT_Normal,TA_Left);
		class'UIAPI_TEXTBOX'.static.SetInt("StatusWnd.StatusWnd_LevelTextBox",userinfo.nLevel);
	}
}

//â Ŭ�������� Ÿ�ٵǱ�
function OnLButtonDown(WindowHandle a_WindowHandle, int X,int Y)
{
	local Rect rectWnd;
	
	rectWnd = class'UIAPI_WINDOW'.static.GetRect("StatusWnd");
	if (X > rectWnd.nX + 13 && X < rectWnd.nX + rectWnd.nWidth -10)
	{
		RequestSelfTarget();
	}
}

function OnEvent( int a_EventID, string a_Param )
{
	switch( a_EventID )
	{
	case EV_UpdateUserInfo:
		UpdateUserInfo();
		break;
	case EV_UpdateMaxHP:
		HandleUpdateInfo(a_Param);
		break;
	case EV_UpdateMP:
		HandleUpdateInfo(a_Param);
		break;
	case EV_UpdateMaxMP:
		HandleUpdateInfo(a_Param);
		break;
	case EV_UpdateCP:
		HandleUpdateInfo(a_Param);
		break;
	case EV_UpdateMaxCP:
		HandleUpdateInfo(a_Param);
		break;
	case EV_RegenStatus:
		HandleRegenStatus( a_Param );
		break;
	default:
		break;
	}
}

function HandleUpdateInfo(string param)
{
	local int ServerID;
	ParseInt( param, "ServerID", ServerID );
	
	//���� User�� ���� ������ �������ߴٸ�, ������ Update�� �ǽ��Ѵ�.
	if (m_UserID == ServerID || !m_bReceivedUserInfo)
	{
		UpdateUserInfo();
	}
}

function HandleRegenStatus( String a_Param )
{
	local int type;
	local int duration;
	local int ticks;
	local float amount;

	ParseInt( a_Param, "Type", type );

	//type�� 1�� ��� : HP �������¸� ������ =>���� 1�� �������� ������
	if( type==1 )
	{
		ParseInt( a_Param, "Duration", duration );
		ParseInt( a_Param, "Ticks", ticks );
		ParseFloat( a_Param, "Amount", amount );
		class'UIAPI_STATUSBARCTRL'.static.SetRegenInfo("StatusWnd.HPBar",duration,ticks,amount);
	}
}

defaultproperties
{
}
