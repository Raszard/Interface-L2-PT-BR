class OlympiadTargetWnd extends UIScript;

var int		m_PlayerNum;

var int		m_ID;
var string		m_Name;
var int		m_ClassID;
var int		m_MaxHP;
var int		m_CurHP;
var int		m_MaxCP;
var int		m_CurCP;

function OnLoad()
{
	RegisterEvent( EV_OlympiadTargetShow );
	RegisterEvent( EV_OlympiadUserInfo );
	RegisterEvent( EV_OlympiadMatchEnd );
}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_OlympiadTargetShow)
	{
		Clear();
		
		//�÷��̾�NUM
		Parseint(param, "PlayerNum", m_PlayerNum);
		
		//Show
		class'UIAPI_WINDOW'.static.ShowWindow("OlympiadTargetWnd");
	}
	else if (Event_ID == EV_OlympiadUserInfo)
	{
		HandleUserInfo(param);
		UpdateStatus();
	}
	else if (Event_ID == EV_OlympiadMatchEnd)
	{
		Clear();
	}
}

function OnEnterState( name a_PreStateName )
{
	Clear();
}

//�ʱ�ȭ
function Clear()
{
	m_PlayerNum = 0;
	
	m_ID = 0;
	m_Name = "";
	m_ClassID = 0;
	m_MaxHP = 0;
	m_CurHP = 0;
	m_MaxCP = 0;
	m_CurCP = 0;
	
	UpdateStatus();
}

//UserInfo����
function HandleUserInfo(string param)
{
	local int IsPlayer;
	local int PlayerNum;
	
	//Observer��忡���� �÷��̾� ���� ��Ŷ�̸� �н�
	ParseInt(param, "IsPlayer", IsPlayer);
	if (IsPlayer != 0)
	{
		return;
	}
	
	//ǥ���ϰ��� �ϴ� Ÿ���� PlayerNum�� �ƴϸ� �н�
	ParseInt(param, "PlayerNum", PlayerNum);
	if (m_PlayerNum != PlayerNum || PlayerNum<1)
	{
		return;
	}
	
	ParseInt(param, "ID", m_ID);
	ParseString(param, "Name", m_Name);
	ParseInt(param, "ClassID", m_ClassID);
	ParseInt(param, "MaxHP", m_MaxHP);
	ParseInt(param, "CurHP", m_CurHP);
	ParseInt(param, "MaxCP", m_MaxCP);
	ParseInt(param, "CurCP", m_CurCP);
}

//Update Info
function UpdateStatus()
{
	//�̸�
	class'UIAPI_TEXTBOX'.static.SetText( "OlympiadTargetWnd.txtName", m_Name);
	
	//CP
	if (m_MaxCP>0)
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "OlympiadTargetWnd.texCP", 150 * m_CurCP / m_MaxCP, 6);
	}
	else
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "OlympiadTargetWnd.texCP", 0, 6);
	}
	
	//HP
	if (m_MaxHP>0)
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "OlympiadTargetWnd.texHP", 150 * m_CurHP / m_MaxHP, 6);
	}
	else
	{
		class'UIAPI_WINDOW'.static.SetWindowSize( "OlympiadTargetWnd.texHP", 0, 6);
	}
}
defaultproperties
{
}
