class AbnormalStatusWnd extends UIScript;

const NSTATUSICON_FRAMESIZE = 12;
const NSTATUSICON_MAXCOL = 12;

var int m_NormalStatusRow;
var int m_EtcStatusRow;
var int m_ShortStatusRow;

var bool m_bOnCurState;

var WindowHandle		Me;
var StatusIconHandle	StatusIcon;

function OnLoad()
{
	RegisterEvent( EV_AbnormalStatusNormalItem );
	RegisterEvent( EV_AbnormalStatusEtcItem );
	RegisterEvent( EV_AbnormalStatusShortItem );
	
	RegisterEvent( EV_Restart );
	RegisterEvent( EV_Die );
	RegisterEvent( EV_ShowReplayQuitDialogBox );
	RegisterEvent( EV_LanguageChanged );
	
	m_NormalStatusRow = -1;
	m_EtcStatusRow = -1;
	m_ShortStatusRow = -1;
	
	m_bOnCurState = false;
	
	InitHandle();
}

function InitHandle()
{
	Me = GetHandle( "AbnormalStatusWnd" );
	StatusIcon = StatusIconHandle( GetHandle( "AbnormalStatusWnd.StatusIcon" ) );
}

function OnEnterState( name a_PreStateName )
{
	m_bOnCurState = true;
	UpdateWindowSize();
}

function OnExitState( name a_NextStateName )
{
	m_bOnCurState = false;
}

function OnEvent(int Event_ID, string param)
{
	if (Event_ID == EV_AbnormalStatusNormalItem)
	{
		HandleAddNormalStatus(param);
	}
	else if (Event_ID == EV_AbnormalStatusEtcItem)
	{
		HandleAddEtcStatus(param);
	}
	else if (Event_ID == EV_AbnormalStatusShortItem)
	{
		HandleAddShortStatus(param);
	}
	else if (Event_ID == EV_Restart)
	{
		HandleRestart();
	}
	else if (Event_ID == EV_Die)
	{
		HandleDie();
	}
	else if (Event_ID == EV_ShowReplayQuitDialogBox)
	{
		HandleShowReplayQuitDialogBox();
	}
	else if (Event_ID == EV_LanguageChanged)
	{
		HandleLanguageChanged();
	}
}

//����ŸƮ�� �ϸ� ��Ŭ����
function HandleRestart()
{
	ClearAll();
}

//�׾�����, Normal/Short�� Ŭ����
function HandleDie()
{
	ClearStatus(false, false);
	ClearStatus(false, true);
}

function HandleShowReplayQuitDialogBox()
{
	Me.HideWindow();
}

//������ UI�� ������ ��, �������� �������� ���� ���´�
function OnShow()
{
	local int RowCount;
	RowCount = StatusIcon.GetRowCount();
	if (RowCount<1)
	{
		Me.HideWindow();
	}
}

//Ư���� Status���� �ʱ�ȭ�Ѵ�.
function ClearStatus(bool bEtcItem, bool bShortItem)
{
	local int i;
	local int j;
	local int RowCount;
	local int RowCountTmp;
	local int ColCount;
	local StatusIconInfo info;
	
	//Normal�������� �ʱ�ȭ�ϴ� �����, Normal�������� �������� �ʱ�ȭ�Ѵ�.
	if (bEtcItem==false && bShortItem==false)
	{
		m_NormalStatusRow = -1;
	}
	//Etc�������� �ʱ�ȭ�ϴ� �����, Etc�������� �������� �ʱ�ȭ�Ѵ�.
	if (bEtcItem==true && bShortItem==false)
	{
		m_EtcStatusRow = -1;
	}
	//Short�������� �ʱ�ȭ�ϴ� �����, Short�������� �������� �ʱ�ȭ�Ѵ�.
	if (bEtcItem==false && bShortItem==true)
	{
		m_ShortStatusRow = -1;
	}
	
	RowCount = StatusIcon.GetRowCount();
	for (i=0; i<RowCount; i++)
	{
		ColCount = StatusIcon.GetColCount(i);
		for (j=0; j<ColCount; j++)
		{
			StatusIcon.GetItem(i, j, info);
			
			//����� �������� ���Դٸ�
			if (info.ClassID>0)
			{
				if (info.bEtcItem==bEtcItem && info.bShortItem==bShortItem)
				{
					StatusIcon.DelItem(i, j);
					j--;
					ColCount--;
					
					RowCountTmp = StatusIcon.GetRowCount();
					if (RowCountTmp != RowCount)
					{
						i--;
						RowCount--;
					}
				}
			}
		}
	}
}

function ClearAll()
{
	ClearStatus(false, false);
	ClearStatus(true, false);
	ClearStatus(false, true);
}

//Normal Status �߰�
function HandleAddNormalStatus(string param)
{
	local int i;
	local int Max;
	local int BuffCnt;
	local StatusIconInfo info;
	
	//NormalStatus �ʱ�ȭ
	ClearStatus(false, false);
	
	//info �ʱ�ȭ
	info.Size = 24;
	info.BackTex = "L2UI.EtcWndBack.AbnormalBack";
	info.bShow = true;
	info.bEtcItem = false;
	info.bShortItem = false;

	BuffCnt = 0;
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseInt(param, "SkillID_" $ i, info.ClassID);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);
		
		if (info.ClassID>0)
		{
			//���ٿ� NSTATUSICON_MAXCOL��ŭ ǥ���Ѵ�.
			if (BuffCnt%NSTATUSICON_MAXCOL == 0)
			{
				m_NormalStatusRow++;
				StatusIcon.InsertRow(m_NormalStatusRow);
			}
			
			StatusIcon.AddCol(m_NormalStatusRow, info);	
			
			BuffCnt++;
		}
	}
	
	//���� Etc, Short�������� ǥ�õǰ� �ִ� ���̶��, ���� ����/���� �Ǿ��� ��찡 �ֱ� ������
	if (m_EtcStatusRow>-1)
	{
		m_EtcStatusRow = m_NormalStatusRow + 1;
	}
	if (m_ShortStatusRow>-1)
	{
		m_ShortStatusRow = m_NormalStatusRow + 1;
	}
	
	UpdateWindowSize();
}

//Etc Status �߰�
function HandleAddEtcStatus(string param)
{
	local int i;
	local int Max;
	local int BuffCnt;
	local int CurRow;
	local bool bNewRow;
	local StatusIconInfo info;
	
	//EtcStatus �ʱ�ȭ
	ClearStatus(true, false);
	
	//info �ʱ�ȭ
	info.Size = 24;
	info.BackTex = "L2UI.EtcWndBack.AbnormalBack";
	info.bShow = true;
	info.bEtcItem = true;
	info.bShortItem = false;
	
	//�߰� ������(Normal������ ������, Short������ ���� ���� �߰��Ѵ�)
	if (m_ShortStatusRow>-1)
	{
		bNewRow = false;
		CurRow = m_ShortStatusRow;
	}
	else
	{
		bNewRow = true;
		CurRow = m_NormalStatusRow;
	}
	
	BuffCnt = 0;
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseInt(param, "SkillID_" $ i, info.ClassID);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);
		
		if (info.ClassID>0)
		{
			//Etc�������� �ִ� �� �࿡�� ǥ���Ѵ�.(Short������ �ڿ�...)
			if (bNewRow)
			{
				bNewRow = !bNewRow;
				CurRow++;
				StatusIcon.InsertRow(CurRow);
			}
			StatusIcon.AddCol(CurRow, info);
			
			m_EtcStatusRow = CurRow;
			
			BuffCnt++;
		}
	}
	
	UpdateWindowSize();
}

//Short Status �߰�
function HandleAddShortStatus(string param)
{
	local int i;
	local int Max;
	local int BuffCnt;
	local int CurRow;
	local int CurCol;
	local bool bNewRow;
	local StatusIconInfo info;
	
	//ShortStatus �ʱ�ȭ
	ClearStatus(false, true);
	
	//info �ʱ�ȭ
	info.Size = 24;
	info.BackTex = "L2UI.EtcWndBack.AbnormalBack";
	info.bShow = true;
	info.bEtcItem = false;
	info.bShortItem = true;
	
	//�߰� ������(Normal������ ������, Etc������ ���� �߰��Ѵ�)
	CurCol = -1;
	if (m_EtcStatusRow>-1)
	{
		bNewRow = false;
		CurRow = m_EtcStatusRow;
	}
	else
	{
		bNewRow = true;
		CurRow = m_NormalStatusRow;
	}
	
	BuffCnt = 0;
	ParseInt(param, "Max", Max);
	for (i=0; i<Max; i++)
	{
		ParseInt(param, "SkillID_" $ i, info.ClassID);
		ParseInt(param, "SkillLevel_" $ i, info.Level);
		ParseInt(param, "RemainTime_" $ i, info.RemainTime);
		ParseString(param, "Name_" $ i, info.Name);
		ParseString(param, "IconName_" $ i, info.IconName);
		ParseString(param, "Description_" $ i, info.Description);
			
		if (info.ClassID>0)
		{
			//Short�������� �ִ� �� �࿡�� ǥ���Ѵ�.(Etc�����۰� �Բ�..)
			if (bNewRow)
			{
				bNewRow = !bNewRow;
				CurRow++;
				StatusIcon.InsertRow(CurRow);
			}
			CurCol++;
			StatusIcon.InsertCol(CurRow, CurCol, info);
			
			m_ShortStatusRow = CurRow;
			
			BuffCnt++;
		}
	}
	
	UpdateWindowSize();
}

//������ ������ ����
function UpdateWindowSize()
{
	local int RowCount;
	local Rect rectWnd;
	
	RowCount = StatusIcon.GetRowCount();
	if (RowCount>0)
	{
		//���� GameState�� �ƴϸ� �����츦 ������ �ʴ´�.
		if (m_bOnCurState)
		{
			Me.ShowWindow();
		}
		else
		{
			Me.HideWindow();
		}
		
		//������ ������ ����
		rectWnd = StatusIcon.GetRect();
		Me.SetWindowSize(rectWnd.nWidth + NSTATUSICON_FRAMESIZE, rectWnd.nHeight);
		
		//���� ������ ������ ����
		Me.SetFrameSize(NSTATUSICON_FRAMESIZE, rectWnd.nHeight);	
	}
	else
	{
		Me.HideWindow();
	}
}

//��� ���� ó��
function HandleLanguageChanged()
{
	local int i;
	local int j;
	local int RowCount;
	local int ColCount;
	local StatusIconInfo info;
	
	RowCount = StatusIcon.GetRowCount();
	for (i=0; i<RowCount; i++)
	{
		ColCount = StatusIcon.GetColCount(i);
		for (j=0; j<ColCount; j++)
		{
			StatusIcon.GetItem(i, j, info);
			if (info.ClassID>0)
			{
				info.Name = class'UIDATA_SKILL'.static.GetName( info.ClassID, info.Level );
				info.Description = class'UIDATA_SKILL'.static.GetDescription( info.ClassID, info.Level );
				StatusIcon.SetItem(i, j, info);
			}
		}
	}
}
defaultproperties
{
}
