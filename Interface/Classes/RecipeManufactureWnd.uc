class RecipeManufactureWnd extends UIScript;

//////////////////////////////////////////////////////////////////////////////
// RECIPE CONST
//////////////////////////////////////////////////////////////////////////////
const RECIPEWND_MAX_MP_WIDTH = 165.0f;

var int		m_RecipeID;		//RecipeID
var int		m_SuccessRate;		//������
var int		m_RecipeBookClass;	//�����? �Ϲ�? ����
var int		m_MaxMP;
var int		m_PlayerID;

function OnLoad()
{
	RegisterEvent( EV_RecipeItemMakeInfo );
	RegisterEvent( EV_UpdateMP );
	
	RegisterEvent( EV_InventoryAddItem );
	RegisterEvent( EV_InventoryUpdateItem );
}

function OnEvent(int Event_ID, string param)
{
	local Rect 	rectWnd;
	local int		ServerID;
	local int		MPValue;

	// 2006/07/10 NeverDie
	local int		RecipeID;
	local int		CurrentMP;
	local int		MaxMP;
	local int		MakingResult;
	local int		Type;
	
	if (Event_ID == EV_RecipeItemMakeInfo)
	{
		class'UIAPI_WINDOW'.static.HideWindow("RecipeBookWnd");
		
		Clear();
		
		//�������� ��ġ�� RecipeBookWnd�� ����
		rectWnd = class'UIAPI_WINDOW'.static.GetRect("RecipeBookWnd");
		class'UIAPI_WINDOW'.static.MoveTo("RecipeManufactureWnd", rectWnd.nX, rectWnd.nY);
		
		//Show
		class'UIAPI_WINDOW'.static.ShowWindow("RecipeManufactureWnd");
		class'UIAPI_WINDOW'.static.SetFocus("RecipeManufactureWnd");
		
		ParseInt( param, "RecipeID", RecipeID );
		ParseInt( param, "CurrentMP", CurrentMP );
		ParseInt( param, "MaxMP", MaxMP );
		ParseInt( param, "MakingResult", MakingResult );
		ParseInt( param, "Type", Type );
		ReceiveRecipeItemMakeInfo(RecipeID, CurrentMP, MaxMP, MakingResult, Type);
	}
	else if (Event_ID == EV_UpdateMP)
	{
		ParseInt(param, "ServerID", ServerID);
		ParseInt(param, "CurrentMP", MPValue);
		if (m_PlayerID==ServerID && m_PlayerID>0)
		{
			SetMPBar(MPValue);
		}
	}
	else if( Event_ID == EV_InventoryAddItem || Event_ID == EV_InventoryUpdateItem )
	{
		HandleInventoryItem(param);
	}
}

function OnClickButton( string strID )
{
	local string param;
	
	switch( strID )
	{
	case "btnClose":
		CloseWindow();
		break;
	case "btnPrev":
		//RecipeBookWnd�� ���ư�
		class'RecipeAPI'.static.RequestRecipeBookOpen(m_RecipeBookClass);
		
		CloseWindow();
		break;
	case "btnRecipeTree":
		if (class'UIAPI_WINDOW'.static.IsShowWindow("RecipeTreeWnd"))
		{
			class'UIAPI_WINDOW'.static.HideWindow("RecipeTreeWnd");	
		}
		else
		{
			ParamAdd(param, "RecipeID", string(m_RecipeID));
			ParamAdd(param, "SuccessRate", string(m_SuccessRate));
			ExecuteEvent( EV_RecipeShowRecipeTreeWnd, param);
		}
		break;
	case "btnManufacture":
		class'RecipeAPI'.static.RequestRecipeItemMakeSelf(m_RecipeID);
		break;
	}
}

//������ �ݱ�
function CloseWindow()
{
	Clear();
	class'UIAPI_WINDOW'.static.HideWindow("RecipeManufactureWnd");
	PlayConsoleSound(IFST_WINDOW_CLOSE);
}

//�ʱ�ȭ
function Clear()
{
	m_RecipeID = 0;
	m_SuccessRate = 0;
	m_RecipeBookClass = 0;
	m_MaxMP = 0;
	m_PlayerID = 0;
	class'UIAPI_ITEMWINDOW'.static.Clear("RecipeManufactureWnd.ItemWnd");
}

//�⺻���� ����
function ReceiveRecipeItemMakeInfo(int RecipeID,int CurrentMP,int MaxMP,int MakingResult,int Type)
{
	local int			i;
	
	local string		strTmp;
	local int			nTmp;
	
	local int			ProductID;
	local int			ProductNum;
	local string		ItemName;
	
	local ParamStack		param;
	local ItemInfo		infItem;
	
	//�������� ����
	m_RecipeID = RecipeID;
	m_SuccessRate = class'UIDATA_RECIPE'.static.GetRecipeSuccessRate(RecipeID);
	m_RecipeBookClass = Type;
	m_MaxMP = MaxMP;
	m_PlayerID = class'UIDATA_PLAYER'.static.GetPlayerID();

	//Product ID
	ProductID = class'UIDATA_RECIPE'.static.GetRecipeProductID(RecipeID);
	
	//(������)�ؽ���
	strTmp = class'UIDATA_ITEM'.static.GetItemTextureName(ProductID);
	class'UIAPI_TEXTURECTRL'.static.SetTexture("RecipeManufactureWnd.texItem", strTmp);
	
	//������ �̸�
	ItemName = MakeFullItemName(ProductID);
	
	//Crystal Type(Grade Emoticon���)
	nTmp = class'UIDATA_RECIPE'.static.GetRecipeCrystalType(RecipeID);
	strTmp = GetItemGradeString(nTmp);
	if (Len(strTmp)>0)
	{
		strTmp = "`" $ strTmp $ "`";
		
	}
	
	class'UIAPI_TEXTBOX'.static.SetText("RecipeManufactureWnd.txtName", ItemName $ " " $ strTmp);
	
	//MP�Һ�
	nTmp = class'UIDATA_RECIPE'.static.GetRecipeMpConsume(RecipeID);
	class'UIAPI_TEXTBOX'.static.SetText("RecipeManufactureWnd.txtMPConsume", "" $ nTmp);
	
	//����Ȯ��
	class'UIAPI_TEXTBOX'.static.SetText("RecipeManufactureWnd.txtSuccessRate", m_SuccessRate $ "%");
	
	//�������
	ProductNum = class'UIDATA_RECIPE'.static.GetRecipeProductNum(RecipeID);
	class'UIAPI_TEXTBOX'.static.SetText("RecipeManufactureWnd.txtResultValue", "" $ ProductNum);
	
	//MP�� ǥ��
	SetMPBar(CurrentMP);
	
	//��������
	class'UIAPI_TEXTBOX'.static.SetText("RecipeManufactureWnd.txtCountValue", "" $ GetInventoryItemCount(ProductID));
	
	//���۰��
	strTmp = "";
	if (MakingResult == 0)
	{
		strTmp = MakeFullSystemMsg(GetSystemMessage(960), ItemName, "");
	}
	else if (MakingResult == 1)
	{
		strTmp = MakeFullSystemMsg(GetSystemMessage(959), ItemName, "" $ ProductNum);
	}
	class'UIAPI_TEXTBOX'.static.SetText("RecipeManufactureWnd.txtMsg", strTmp);
	
	//ItemWnd�� �߰�
	param = class'UIDATA_RECIPE'.static.GetRecipeMaterialItem(RecipeID);
	nTmp = param.GetInt();
	for (i=0; i<nTmp; i++)
	{
		infItem.ClassID = param.GetInt();	//ID
		infItem.Reserved = param.GetInt();	//NeedNum
		infItem.Name = class'UIDATA_ITEM'.static.GetItemName(infItem.ClassID);
		infItem.AdditionalName = class'UIDATA_ITEM'.static.GetItemAdditionalName(infItem.ClassID);
		infItem.IconName = class'UIDATA_ITEM'.static.GetItemTextureName(infItem.ClassID);
		infItem.Description = class'UIDATA_ITEM'.static.GetItemDescription(infItem.ClassID);
		infItem.ItemNum = GetInventoryItemCount(infItem.ClassID);
		if (infItem.Reserved>infItem.ItemNum)
		{
			infItem.bDisabled = true;
		}
		else 
		{
			infItem.bDisabled = false;
		}
		class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeManufactureWnd.ItemWnd", infItem);
	}
}

//MP Bar
function SetMPBar(int CurrentMP)
{
	local int	nTmp;
	local int	nMPWidth;
	
	nTmp = RECIPEWND_MAX_MP_WIDTH * CurrentMP;
	nMPWidth = nTmp / m_MaxMP;
	if (nMPWidth>RECIPEWND_MAX_MP_WIDTH)
	{
		nMPWidth = RECIPEWND_MAX_MP_WIDTH;
	}
	class'UIAPI_WINDOW'.static.SetWindowSize("RecipeManufactureWnd.texMPBar", nMPWidth, 12);
}

//�κ��������� ������Ʈ�Ǹ� �������� ���纸������ �ٲ��ش�
function HandleInventoryItem(string param)
{
	local int ClassID;
	local int idx;
	local ItemInfo infItem;
	
	if (ParseInt( param, "classID", ClassID ))
	{
		idx = class'UIAPI_ITEMWINDOW'.static.FindItemWithClassID( "RecipeManufactureWnd.ItemWnd", ClassID);
		if (idx>-1)
		{
			class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeManufactureWnd.ItemWnd", idx, infItem);
			infItem.ItemNum = GetInventoryItemCount(infItem.ClassID);
			if (infItem.Reserved>infItem.ItemNum)
				infItem.bDisabled = true;
			else
				infItem.bDisabled = false;
			class'UIAPI_ITEMWINDOW'.static.SetItem( "RecipeManufactureWnd.ItemWnd", idx, infItem);
		}
	}
}
defaultproperties
{
}
