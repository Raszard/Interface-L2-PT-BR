/******************************************************************************
//                                                ��Ƽâ  �ɼ� ���� UI ��ũ��Ʈ                                                                    //
******************************************************************************/
class PartyWndOption extends UIScript;

// �������� ����
var bool	m_OptionShow;	// ���� �ɼ�â�� �������� �ִ��� üũ�ϴ� �Լ�.
					// true�̸� ����. false  �̸� ������ ����.

// �̺�Ʈ �ڵ� ����
var WindowHandle	m_PartyOption;
var WindowHandle 	m_PartyWndBig;
var WindowHandle	m_PartyWndSmall;

// ������ ������ �ε�Ǵ� �Լ�
function OnLoad()
{
	m_OptionShow = false;	// ����Ʈ�� false 
	m_PartyOption = GetHandle("PartyWndOption");
	m_PartyWndBig = GetHandle("PartyWnd");;
	m_PartyWndSmall = GetHandle("PartyWndCompact");;
}
       
// �����찡 ������������ ȣ��Ǵ� �Լ�
function OnShow()
{	
	class'UIAPI_CHECKBOX'.static.SetCheck("ShowSmallPartyWndCheck", GetOptionBool( "Game", "SmallPartyWnd" ));
	class'UIAPI_WINDOW'.static.SetFocus("PartyWndOption");
	m_OptionShow = true;
}

// üũ�ڽ��� Ŭ���Ͽ��� ��� �̺�Ʈ
function OnClickCheckBox( string CheckBoxID)
{
	switch( CheckBoxID )
	{
	case "ShowSmallPartyWndCheck":
		//debug("Clicked  2");

		break;
	}
}

// Ȯ��� ��Ƽâ�� ��ҵ� ��Ƽâ�� ��ȯ
function SwapBigandSmall()
{
	local  PartyWnd script1;			// Ȯ��� ��Ƽâ�� Ŭ����
	local PartyWndCompact script2;	// ��ҵ� ��Ƽâ�� Ŭ����
	
	script1 = PartyWnd( GetScript("PartyWnd") );
	script2 = PartyWndCompact( GetScript("PartyWndCompact") );
	
	class'UIAPI_WINDOW'.static.SetAnchor("PartyWndCompact", "PartyWnd", "TopLeft", "TopLeft", 0, 0 );	// �̰��ϳ��� ���� â�� ��ũ��. ��!
	
	// �� ��ũ��Ʈ�� ResizeWnd()�� �ɼ��� Ȱ��ȭ�� ���� �ڽ��� �����츦 HIDE���� Ȱ��ȭ���� �����Ѵ�. 
	script1.ResizeWnd();
	script2.ResizeWnd();
}

// ��ư�� ������ ��� ����
function OnClickButton( string strID )
{
	//local PartyWnd script1;
	//local PartyWndCompact script2;
	//script1 = PartyWnd( GetScript("PartyWnd") );
	//script2 = PartyWndCompact( GetScript("PartyWndCompact") );
	
	switch( strID )
	{
	case "okbtn":	// OK ��ư�� ������
		
		switch (class'UIAPI_CHECKBOX'.static.IsChecked("ShowSmallPartyWndCheck"))
		{ 
		case true:
			//SetOptionBool("Game", ... ) �� ������ Option ->�����׸񿡼� ����Ҽ� �ִ� bool ������ ����� �� �ִ�.	
			//������ ��ϵ��� ���� ������ ����ϸ� �ڵ����� Ŭ���̾�Ʈ���� �˾Ƽ� ������.
			// ���� ���� ������ ���� Documentation �� �ʿ�!
			// GetOptionBool�� ���.
			SetOptionBool( "Game", "SmallPartyWnd", true );											
			break;
		case false:
			SetOptionBool( "Game", "SmallPartyWnd", false);
			break;
		}
		SwapBigandSmall();		// ��Ȳ�� ���� ��Ƽâ�� ũ�⸦ �������ش�.
		m_PartyOption.HideWindow();	// ������ �����츦 �����
		//script1.m_OptionShow = false;
		//script2.m_OptionShow = false;
		m_OptionShow = false;
		break;
	}
}

// PartyWnd�� PartyWndCompact ���� ȣ���ϴ� �Լ�.
function ShowPartyWndOption()
{
	// ���������� ����
	if (m_OptionShow == false)
	{ 
		m_PartyOption.ShowWindow();
		m_OptionShow = true;
	}
	else	// ���������� �ݴ´�. 
	{
		m_PartyOption.HideWindow();
		m_OptionShow = false;
	}
}
defaultproperties
{
}
