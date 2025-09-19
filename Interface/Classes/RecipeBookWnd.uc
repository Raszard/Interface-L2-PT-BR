class RecipeBookWnd extends UICommonAPI;

var int		m_ItemCount;
var array<int>	m_arrItem;

var int		m_BookType;
var int		m_ItemMaxCount_Dwarf;
var int		m_ItemMaxCount_Normal;
var int		m_DeleteItemID;

function OnLoad()
{
	RegisterEvent( EV_RecipeShowBookWnd );
	RegisterEvent( EV_RecipeAddBookItem );
	RegisterEvent( EV_SetMaxCount );
	RegisterEvent( EV_DialogOK );
}

function OnEvent(int Event_ID, string param)
{
	local Rect 	rectWnd;

	// 2006/07/10 NeverDie
	local int RecipeAddBookItem;
	
	if (Event_ID == EV_RecipeShowBookWnd)
	{
		Clear();
		
		//�������� ��ġ�� RecipeManufactureWnd�� ����
		rectWnd = class'UIAPI_WINDOW'.static.GetRect("RecipeManufactureWnd");
		class'UIAPI_WINDOW'.static.MoveTo("RecipeBookWnd", rectWnd.nX, rectWnd.nY);
		
		//Show
		class'UIAPI_WINDOW'.static.ShowWindow("RecipeBookWnd");
		class'UIAPI_WINDOW'.static.SetFocus("RecipeBookWnd");
		
		//�����?�Ϲ�? ����
		//enum RecipeBookClass
		//{
		//	RBC_DWARF  = 0,	//������� �����Ǻ� - Max ��ġ ǥ��
		//	RBC_NORMAL	//���� �����Ǻ� - Max ��ġ ǥ��
		//};
		ParseInt(param, "Type", m_BookType);
		if (m_BookType == 1)
		{
			class'UIAPI_WINDOW'.static.SetWindowTitle("RecipeBookWnd", 1214);
		}
		else
		{
			class'UIAPI_WINDOW'.static.SetWindowTitle("RecipeBookWnd", 1215);
		}
	}
	else if (Event_ID == EV_RecipeAddBookItem)
	{
		ParseInt( param, "RecipeID", RecipeAddBookItem );
		AddRecipeBookItem( RecipeAddBookItem );
	}
	else if (Event_ID == EV_SetMaxCount)
	{
		ParseInt(param, "recipe", m_ItemMaxCount_Normal);
		ParseInt(param, "dwarvenRecipe", m_ItemMaxCount_Dwarf);
		SetItemCount(m_ItemCount);
	}
	else if (Event_ID == EV_DialogOK)
	{
		if (DialogIsMine())
		{
			class'RecipeAPI'.static.RequestRecipeItemDelete(m_DeleteItemID);
		}
	}
}

//RecipeManufactureWnd�� ȣ��
function OnDBClickItem( string strID, int index )
{
	if (strID == "RecipeItem" && m_ItemCount>index)
	{
		class'RecipeAPI'.static.RequestRecipeItemMakeInfo(m_arrItem[index]);
	}
}

//Trash������������ DropITem
function OnDropItem( string strID, ItemInfo infItem, int x, int y)
{
	if (strID == "btnTrash")
	{
		DeleteItem(infItem);
	}
}

function OnClickButton( string strID )
{
	local ItemInfo infItem;
	
	switch( strID )
	{
	case "btnTrash":
		if (class'UIAPI_ITEMWINDOW'.static.GetSelectedItem("RecipeBookWnd.RecipeItem", infItem))
		{
			DeleteItem(infItem);	
		}
		break;
	}
}

//�ʱ�ȭ
function Clear()
{
	SetItemCount(0);
	m_arrItem.Remove(0, m_arrItem.Length);
	
	class'UIAPI_ITEMWINDOW'.static.Clear("RecipeBookWnd.RecipeItem");
}

//������ ������ �߰�
function AddRecipeBookItem(int RecipeID)
{
	local ItemInfo	infItem;
	local int		ProductID;
	local int		Index;
	
	//Product ID
	ProductID = class'UIDATA_RECIPE'.static.GetRecipeProductID(RecipeID);
	
	//Index(ServerID)
	Index = class'UIDATA_RECIPE'.static.GetRecipeIndex(RecipeID);
	
	//����������
	infItem.ClassID = class'UIDATA_RECIPE'.static.GetRecipeClassID(RecipeID);
	infItem.Level = class'UIDATA_RECIPE'.static.GetRecipeLevel(RecipeID);
	infItem.ServerID = class'UIDATA_RECIPE'.static.GetRecipeIndex(RecipeID);
	infItem.ItemSubType = int(EShortCutItemType.SCIT_RECIPE);
	
	infItem.Name = class'UIDATA_ITEM'.static.GetItemName(infItem.ClassID);
	infItem.Description = class'UIDATA_ITEM'.static.GetItemDescription(infItem.ClassID);
	infItem.Weight = class'UIDATA_ITEM'.static.GetItemWeight(infItem.ClassID);

	//���깰����
	infItem.IconName = class'UIDATA_ITEM'.static.GetItemTextureName(ProductID);
	infItem.CrystalType = class'UIDATA_RECIPE'.static.GetRecipeCrystalType(RecipeID);
	
	//RecipeItem�� �߰�
	class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeBookWnd.RecipeItem", infItem);
	
	//ItemArray�� �߰�
	m_arrItem.Insert(m_arrItem.Length, 1);
	m_arrItem[m_arrItem.Length-1] = Index;
	
	m_ItemCount++;
	SetItemCount(m_ItemCount);
}

//������ ���� ǥ��
function SetItemCount(int MaxCount)
{
	local int		nTmp;
	
	m_ItemCount = MaxCount;
	
	//�����ǰ��� ǥ��
	if (m_BookType==1)
	{
		nTmp = m_ItemMaxCount_Normal;
	}
	else
	{
		nTmp = m_ItemMaxCount_Dwarf;
	}
	class'UIAPI_TEXTBOX'.static.SetText("RecipeBookWnd.txtCount", "(" $ m_ItemCount $ "/" $ nTmp $ ")");	
}

//Delete Item
function DeleteItem(ItemInfo infItem)
{
	local string strMsg;
	
	strMsg = MakeFullSystemMsg(GetSystemMessage(74), infItem.Name, "");
	m_DeleteItemID = infItem.ServerID;
	DialogShow(DIALOG_Warning, strMsg);
}
defaultproperties
{
}
