/******************************************************************************
//                                             ��ҵ� ��Ƽâ UI ���� ��ũ��Ʈ                                                                    //
******************************************************************************/
class PartyWndCompact extends UICommonAPI;

// ��� ����.
const NSTATUSICON_MAXCOL = 12;		//status icon�� �ִ� ����.
const NPARTYSTATUS_HEIGHT = 26;		//status ����â�� ���α���.	// Ȯ��â�� 46
const NPARTYSTATUS_MAXCOUNT = 8;		//�� ��Ƽâ�� ���� �ִ� �ִ� ��Ƽ���� ��.

var bool	m_bCompact;
var bool	m_bBuff;
var bool	m_partyleader;
var int	m_arrID[NPARTYSTATUS_MAXCOUNT];	// �ε����� �ش��ϴ� ��Ƽ���� ���� ID.
var int	m_CurCount;
var int 	m_CurBf;
var int m_MasterID;

//Handle	����
var WindowHandle	m_wndTop;			// ���� ������
var WindowHandle	m_PartyOption;		// �ɼ� ������
var WindowHandle	m_PartyStatus[NPARTYSTATUS_MAXCOUNT];	// ĳ���ͺ� ������ (ĳ���� ����ŭ �������ش�)
var TextureHandle	m_ClassIcon[NPARTYSTATUS_MAXCOUNT];		//Ŭ���� ������ �ؽ���.
var StatusIconHandle	m_StatusIconBuff[NPARTYSTATUS_MAXCOUNT];	//���������� �ڵ�
var StatusIconHandle	m_StatusIconDeBuff[NPARTYSTATUS_MAXCOUNT];	//����������� �ڵ�
var BarHandle		m_BarCP[NPARTYSTATUS_MAXCOUNT];
var BarHandle		m_BarHP[NPARTYSTATUS_MAXCOUNT];
var BarHandle		m_BarMP[NPARTYSTATUS_MAXCOUNT];
var ButtonHandle	btnBuff;

// �����찡 �����ɶ� �Ҹ��� �Լ�.
function OnLoad()
{
	local int idx;
	
	// �̺�Ʈ (���� Ȥ�� Ŭ���̾�Ʈ���� ����) �ڵ� ���.
	RegisterEvent( EV_ShowBuffIcon );
	
	RegisterEvent( EV_PartyAddParty);
	RegisterEvent( EV_PartyUpdateParty );
	RegisterEvent( EV_PartyDeleteParty );
	RegisterEvent( EV_PartyDeleteAllParty );
	RegisterEvent( EV_PartySpelledList );
	
	RegisterEvent( EV_Restart );
	
	m_bCompact = false;
	m_bBuff = false;
	m_CurBf = 0;
	m_MasterID = 0;
	
	//Init Handle
	m_wndTop = GetHandle( "PartyWndCompact" );
	m_PartyOption = GetHandle("PartyWndOption");		// �ɼ�â�� �ڵ� �ʱ�ȭ.
	for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)		// �ִ���Ƽ�� �� ��ŭ �� �����͸� �ʱ�ȭ����.
	{
		m_PartyStatus[idx] = GetHandle( "PartyWndCompact.PartyStatusWnd" $ idx );
		m_ClassIcon[idx] = TextureHandle( GetHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".ClassIcon" ) );
		m_StatusIconBuff[idx] = StatusIconHandle( GetHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".StatusIconBuff" ) );
		m_StatusIconDeBuff[idx] = StatusIconHandle( GetHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".StatusIconDebuff" ) );
		m_BarCP[idx] = BarHandle( GetHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barCP" ) );
		m_BarHP[idx] = BarHandle( GetHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barHP" ) );
		m_BarMP[idx] = BarHandle( GetHandle( "PartyWndCompact.PartyStatusWnd" $ idx $ ".barMP" ) );
	}
	btnBuff = ButtonHandle( GetHandle( "PartyWndCompact.btnBuff" ) );
	
	//Reset Anchor	// ������ ������� PartyWndCompact�� anchor point�� �����Ѵ�.
	for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
	{
		m_StatusIconBuff[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 1, 3);
		m_StatusIconDeBuff[idx].SetAnchor("PartyWndCompact.PartyStatusWnd" $ idx, "TopRight", "TopLeft", 1, 3);
	}
	
	//Set ClassIcon0 Position
	m_ClassIcon[0].Move(0, 7);
	
	
	m_PartyOption.HideWindow();
}

function OnShow()
{
	SetBuffButtonTooltip();
}

function OnEnterState( name a_PreStateName )
{
	m_bCompact = false;
	m_bBuff = false;
	m_CurBf = 0;
	ResizeWnd();
}

// �̺�Ʈ �ڵ� ó��.
function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_PartyAddParty)	//��Ƽ���� �߰��ϴ� �̺�Ʈ.
	{
		HandlePartyAddParty(param);
	}
	else if (Event_ID == EV_PartyUpdateParty)	//��Ƽ ������Ʈ. ���� HP �� ���¸� ó���ϱ� ����.
	{
		HandlePartyUpdateParty(param);
	}
	else if (Event_ID == EV_PartyDeleteParty)	//��Ƽ�� ����.
	{
		HandlePartyDeleteParty(param);
	}
	else if (Event_ID == EV_PartyDeleteAllParty)	//��� ��Ƽ�� ����. ��Ƽ�� �����ų� �ǰ���.
	{
		HandlePartyDeleteAllParty();
	}
	else if (Event_ID == EV_PartySpelledList)	// ���� Ȥ�� ����� ó��.
	{
		HandlePartySpelledList(param);
	}
	else if (Event_ID == EV_ShowBuffIcon)		// ����, �����, ����/����� ���̱� ��带 ��ȯ.
	{
		HandleShowBuffIcon(param);
	}
	else if (Event_ID == EV_Restart)
	{
		HandleRestart();
	}
}

//����ŸƮ�� �ϸ� ��Ŭ����
function HandleRestart()
{
	Clear();
}

//�ʱ�ȭ
function Clear()
{
	local int idx;
	for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
	{
		ClearStatus(idx);
	}
	m_CurCount = 0;
	ResizeWnd();
}

//����â�� �ʱ�ȭ
function ClearStatus(int idx)
{
	m_StatusIconBuff[idx].Clear();
	m_StatusIconDeBuff[idx].Clear();
	m_ClassIcon[idx].SetTexture("");
	UpdateCPBar(idx, 0, 0);
	UpdateHPBar(idx, 0, 0);
	UpdateMPBar(idx, 0, 0);
	m_arrID[idx] = 0;
}

//��Ƽâ�� ���� (������ �Ǵ� ��Ƽâ�� �ε���, ������ ��Ƽâ�� �ε���)
function CopyStatus(int DesIndex, int SrcIndex)
{
	local int		MaxValue;
	local int		CurValue;
	
	local int		Row;
	local int		Col;
	local int		MaxRow;
	local int		MaxCol;
	
	local StatusIconInfo info;
	
	//Custom Tooltip
	local CustomTooltip TooltipInfo;
	local CustomTooltip TooltipInfo2;
	
	//ServerID
	m_arrID[DesIndex] = m_arrID[SrcIndex];
	
	//Window Tooltip
	m_PartyStatus[SrcIndex].GetTooltipCustomType(TooltipInfo);
	m_PartyStatus[DesIndex].SetTooltipCustomType(TooltipInfo);
	
	//Class Texture
	m_ClassIcon[DesIndex].SetTexture(m_ClassIcon[SrcIndex].GetTextureName());
	//Class Tooltip
	m_ClassIcon[SrcIndex].GetTooltipCustomType(TooltipInfo2);	
	m_ClassIcon[DesIndex].SetTooltipCustomType(TooltipInfo2);
	
	//CP,HP,MP
	m_BarCP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarCP[DesIndex].SetValue(MaxValue, CurValue);
	m_BarHP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarHP[DesIndex].SetValue(MaxValue, CurValue);
	m_BarMP[SrcIndex].GetValue(MaxValue, CurValue);
	m_BarMP[DesIndex].SetValue(MaxValue, CurValue);
	
	//BuffStatus
	m_StatusIconBuff[DesIndex].Clear();
	MaxRow = m_StatusIconBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconBuff[DesIndex].AddRow();
		MaxCol = m_StatusIconBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_StatusIconBuff[SrcIndex].GetItem(Row, Col, info);
			m_StatusIconBuff[DesIndex].AddCol(Row, info);
		}
	}
	
	//DeBuffStatus
	m_StatusIconDeBuff[DesIndex].Clear();
	MaxRow = m_StatusIconDeBuff[SrcIndex].GetRowCount();
	for (Row=0; Row<MaxRow; Row++)
	{
		m_StatusIconDeBuff[DesIndex].AddRow();
		MaxCol = m_StatusIconDeBuff[SrcIndex].GetColCount(Row);
		for (Col=0; Col<MaxCol; Col++)
		{
			m_StatusIconDeBuff[SrcIndex].GetItem(Row, Col, info);
			m_StatusIconDeBuff[DesIndex].AddCol(Row, info);
		}
	}
}

//�������� ������ ����
function ResizeWnd()
{
	local int idx;
	local Rect rectWnd;
	local bool bOption;
	
	// SetOptionBool�� ���. �� ������ PartyWndOption ���� �����
	bOption = GetOptionBool( "Game", "SmallPartyWnd" );
	
	if (m_CurCount>0)
	{
		//������ ������ ����
		rectWnd = m_wndTop.GetRect();
		
		m_wndTop.SetWindowSize(rectWnd.nWidth, NPARTYSTATUS_HEIGHT*m_CurCount);
		m_wndTop.SetResizeFrameSize(10, NPARTYSTATUS_HEIGHT*m_CurCount);
		if (bOption)	// �ɼ�â�� üũ�� �Ǿ������� ���� (Compact) �����츦 Ȱ��ȭ
			m_wndTop.ShowWindow();
		else
			m_wndTop.HideWindow();
		
		for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
		{
			if (idx<=m_CurCount-1)
			{
				m_PartyStatus[idx].ShowWindow();
			}
			else
			{
				m_PartyStatus[idx].HideWindow();
			}
		}
	}
	else	// ��Ƽ���� �������� ������ �� ������� ������ �ʴ´�.
	{
		m_wndTop.HideWindow();
	}
}

//ID�� ���° ǥ�õǴ� ��Ƽ������ ���Ѵ�
function int FindPartyID(int ID)
{
	local int idx;
	for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
	{
		if (m_arrID[idx] == ID)
		{
			return idx;
		}
	}
	return -1;
}

//ADD	��Ƽ�� �߰�
function HandlePartyAddParty(string param)
{
	local int		ID;
	
	ParseInt(param, "ID", ID);
	if (ID>0)
	{
		m_CurCount++;
		ResizeWnd();
		
		m_arrID[m_CurCount-1] = ID;
		UpdateStatus(m_CurCount-1, param);
	}
}

//UPDATE	Ư�� ��Ƽ�� ������Ʈ.
function HandlePartyUpdateParty(string param)
{
	local int	ID;
	local int	idx;
	
	ParseInt(param, "ID", ID);
	if (ID>0)
	{
		idx = FindPartyID(ID);
		UpdateStatus(idx, param);	// �ش� �ε����� ��Ƽ�� ������ ����
	}
}

//DELETE	Ư�� ��Ƽ���� ����.
function HandlePartyDeleteParty(string param)
{
	local int	ID;
	local int	idx;
	local int	i;
	
	ParseInt(param, "ID", ID);
	if (ID>0)
	{
		idx = FindPartyID(ID);
		if (idx>-1)
		{	
			for (i=idx; i<m_CurCount-1; i++)	// �����Ϸ��� ��Ƽ�� �Ʒ��� ��Ƽ������ �����ش�. 
			{
				CopyStatus(i, i+1);
			}
			ClearStatus(m_CurCount);
			m_CurCount--;
			ResizeWnd();	// ���� ��Ƽ���� �ڽŹۿ� ���ٸ� �˾Ƽ� ��Ƽ������� �����.
		}
	}
}

//DELETE ALL	���� ��� �����..
function HandlePartyDeleteAllParty()
{
	Clear();
}

//Set Info	Ư�� �ε����� ��Ƽ���� ���� ����. ���� ���̵� ������ Ȯ���� ���� �ʿ��ϴ�.
function UpdateStatus(int idx, string param)
{
	local string	Name;
	local int		ID;
	local int		CP;
	local int		MaxCP;
	local int		HP;
	local int		MaxHP;
	local int		MP;
	local int		MaxMP;
	local int		ClassID;
	local int		MasterID;
	
	//Custom Tooltip
	local CustomTooltip TooltipInfo;
	local CustomTooltip TooltipInfo2;
		
	if (idx<0 || idx>=NPARTYSTATUS_MAXCOUNT)
		return;
	
	ParseString(param, "Name", Name);
	ParseInt(param, "ID", ID);
	ParseInt(param, "CurCP", CP);
	ParseInt(param, "MaxCP", MaxCP);
	ParseInt(param, "CurHP", HP);
	ParseInt(param, "MaxHP", MaxHP);
	ParseInt(param, "CurMP", MP);
	ParseInt(param, "MaxMP", MaxMP);
	ParseInt(param, "ClassID", ClassID);
	
	//������Ʈ�ϰ�쿡�� ��Ƽ�� ������ �ȳ���´�.
	if (ParseInt(param, "MasterID", MasterID))
		m_MasterID = MasterID;
	
	//Window Tooltip
	TooltipInfo.DrawList.length = 1;
	TooltipInfo.DrawList[0].eType = DIT_TEXT;
	TooltipInfo.DrawList[0].t_bDrawOneLine = true;
	if (m_MasterID >0 && m_MasterID==ID)
	{	
		TooltipInfo.DrawList[0].t_strText =  Name $ "(" $ GetSystemString(408) $ ")";
	}
	else
	{
		TooltipInfo.DrawList[0].t_strText = Name;
	}
	m_PartyStatus[idx].SetTooltipCustomType(TooltipInfo);
	
	//���� ������
	m_ClassIcon[idx].SetTexture(GetClassIconName(ClassID));
	
	//Custom Tooltip
	TooltipInfo2.DrawList.length = 2;
	TooltipInfo2.DrawList[0].eType = DIT_TEXT;
	TooltipInfo2.DrawList[0].t_bDrawOneLine = true;
	if (m_MasterID >0 && m_MasterID==ID)
	{	
		TooltipInfo2.DrawList[0].t_strText =  Name $ "(" $ GetSystemString(408) $ ")";
	}
	else
	{
		TooltipInfo2.DrawList[0].t_strText = Name;
	}
	
	TooltipInfo2.DrawList[1].eType = DIT_TEXT;
	TooltipInfo2.DrawList[1].nOffSetY = 2;
	TooltipInfo2.DrawList[1].t_bDrawOneLine = true;
	TooltipInfo2.DrawList[1].bLineBreak = true;
	
	TooltipInfo2.DrawList[1].t_strText = GetClassStr(ClassID) $ " - " $ GetClassType(ClassID);
	TooltipInfo2.DrawList[1].t_color.R = 128;
	TooltipInfo2.DrawList[1].t_color.G = 128;
	TooltipInfo2.DrawList[1].t_color.B = 128;
	TooltipInfo2.DrawList[1].t_color.A = 255;
	m_ClassIcon[idx].SetTooltipCustomType(TooltipInfo2);
	
	//���� ������
	UpdateCPBar(idx, CP, MaxCP);
	UpdateHPBar(idx, HP, MaxHP);
	UpdateMPBar(idx, MP, MaxMP);
}

//��������Ʈ����
function HandlePartySpelledList(string param)
{
	local int i;
	local int idx;
	local int ID;
	local int Max;
	
	local int BuffCnt;
	local int BuffCurRow;
	
	local int DeBuffCnt;
	local int DeBuffCurRow;
	
	local StatusIconInfo info;
	
	DeBuffCurRow = -1;
	BuffCurRow = -1;
	
	ParseInt(param, "ID", ID);
	if (ID<1)
	{
		return;
	}
	
	idx = FindPartyID(ID);
	if (idx<0)
	{
		return;
	}
	
	//���� �ʱ�ȭ
	m_StatusIconBuff[idx].Clear();
	m_StatusIconDeBuff[idx].Clear();
	
	//info �ʱ�ȭ
	info.Size = 10;
	info.bShow = true;
		
	ParseInt(param, "Max", Max);
	
	for (i=0; i<Max; i++)
	{
		ParseInt(param, "SkillID_" $ i, info.ClassID);
		ParseInt(param, "Level_" $ i, info.Level);
		
		if (info.ClassID>0)
		{
			info.IconName = class'UIDATA_SKILL'.static.GetIconName(info.ClassID, info.Level);
			
			if (IsDeBuff( info.ClassID, info.Level) == true )
			{
				if (DeBuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					DeBuffCurRow++;
					m_StatusIconDeBuff[idx].AddRow();
				}
				m_StatusIconDeBuff[idx].AddCol(DeBuffCurRow, info);	
				DeBuffCnt++;
			}
			else
			{
				if (BuffCnt%NSTATUSICON_MAXCOL == 0)
				{
					BuffCurRow++;
					m_StatusIconBuff[idx].AddRow();
				}
				m_StatusIconBuff[idx].AddCol(BuffCurRow, info);	
				BuffCnt++;
			}
		}
	}
	UpdateBuff();
}

//���������� ǥ��
function HandleShowBuffIcon(string param)
{
	local int nShow;
	ParseInt(param, "Show", nShow);
	
	m_CurBf = m_CurBf + 1;
	
	
	if (m_CurBf > 2)
	{
		m_CurBf = 0;
	}
	
	SetBuffButtonTooltip();
	
	switch (m_CurBf)
	{
		case 1:
		UpdateBuff();
		break;
		case 2:
		UpdateBuff();
		break;
		case 0:
		m_CurBf = 0;
		UpdateBuff();
	}
}

// ��ưŬ�� �̺�Ʈ
function OnClickButton( string strID )
{
	local PartyWnd script;
	script = PartyWnd( GetScript("PartyWnd") );
	switch( strID )
	{
	case "btnBuff":		//������ư Ŭ���� 
		OnBuffButton();
		script.OnBuffButton();
		break;
	case "btnOption":	// �ɼ� ��ư Ŭ����
		OnOpenPartyWndOption();
	}
}

// �ɼǹ�ư Ŭ���� �Ҹ��� �Լ�
function OnOpenPartyWndOption()
{
	local PartyWndOption script;
	script = PartyWndOption( GetScript("PartyWndOption") );
	script.ShowPartyWndOption();
	m_PartyOption.SetAnchor("PartyWndCompact.PartyStatusWnd0", "TopRight", "TopLeft", 5, 5);
}

// ������ �ʴ� �Լ��ε�.  PartyWnd, PartyWndCompact, PartyWndOption ���� ������� ����
//		function OnCompactButton()
//		{
//			local int idx;
//			local int Size;
//			
//			if (m_bCompact)
//			{
//				Size = 16;
//			}
//			else
//			{
//				Size = 10;
//			}
//			m_bCompact = !m_bCompact;
//			
//			for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
//			{
//				m_StatusIconBuff[idx].SetIconSize(Size);	
//				m_StatusIconDeBuff[idx].SetIconSize(Size);	
//			}
//		}

// ������ư�� ������ ��� ����Ǵ� �Լ�
function OnBuffButton()
{
	m_CurBf = m_CurBf + 1;
	
	//3���� ��尡 ��ȯ�ȴ�.
	if (m_CurBf > 2)
	{
		m_CurBf = 0;
	}
	
	// ����ǥ��
	SetBuffButtonTooltip();
	
	UpdateBuff();
}

// ����ǥ��, ����� ǥ��,  ���� 3������带 ��ȯ�Ѵ�.
function UpdateBuff()
{
	local int idx;
	if (m_CurBf == 1)
	{
		for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
		{
			m_StatusIconBuff[idx].ShowWindow();	
			m_StatusIconDeBuff[idx].HideWindow();	
			
		}
	}
	else if (m_CurBf == 2)
	{
		for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_StatusIconDeBuff[idx].ShowWindow();	
			
		}
	}
	else 
	{
		for (idx=0; idx<NPARTYSTATUS_MAXCOUNT; idx++)
		{
			m_StatusIconBuff[idx].HideWindow();	
			m_StatusIconDeBuff[idx].HideWindow();	
		}
	}
}

//CP�� ����
function UpdateCPBar(int idx, int Value, int MaxValue)
{
	m_BarCP[idx].SetValue(MaxValue, Value);
}

//HP�� ����
function UpdateHPBar(int idx, int Value, int MaxValue)
{
	m_BarHP[idx].SetValue(MaxValue, Value);
}

//MP�� ����
function UpdateMPBar(int idx, int Value, int MaxValue)
{
	m_BarMP[idx].SetValue(MaxValue, Value);
}

//��Ƽ�� Ŭ�� ������..
function OnLButtonDown( WindowHandle a_WindowHandle, int X, int Y )
{
	local Rect rectWnd;
	local int idx;
	
	rectWnd = m_wndTop.GetRect();
	if (X > rectWnd.nX + 30)
	{
		idx = (Y-rectWnd.nY) / NPARTYSTATUS_HEIGHT;
		RequestTargetUser(m_arrID[idx]);
	}
}

//��Ƽ���� ��ý�Ʈ
function OnRButtonUp( int X, int Y )
{
	local Rect rectWnd;
	local UserInfo userinfo;
	local int idx;
	
	rectWnd = m_wndTop.GetRect();
	if (X > rectWnd.nX + 30)
	{
		if (GetPlayerInfo(userinfo))
		{
			idx = (Y-rectWnd.nY) / NPARTYSTATUS_HEIGHT;
			RequestAssist(m_arrID[idx], userinfo.Loc);
		}
	}
}

// ���� ������ �����Ѵ�.
function SetBuffButtonTooltip()
{
	local int idx;
	switch (m_CurBf)
	{
		case 0:	idx = 1496;
		break;
		case 1:	idx = 1497;
		break;
		case 2:	idx = 1498;
		break;
	}
	btnBuff.SetTooltipCustomType(MakeTooltipSimpleText(GetSystemString(idx)));
}
defaultproperties
{
}
