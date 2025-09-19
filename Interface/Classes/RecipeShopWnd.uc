class RecipeShopWnd extends UICommonAPI;

const RECIPESHOP_MAX_ITEM_SELL = 20;

var int		m_BookItemCount;
var int		m_ShopItemCount;
var array<int>	m_arrBookItem;
var array<int>	m_arrShopItem;

var int		m_BookType;
var ItemInfo	m_HandleItem;

function OnLoad()
{
	RegisterEvent( EV_RecipeShopShowWnd );
	RegisterEvent( EV_RecipeShopAddBookItem );
	RegisterEvent( EV_RecipeShopAddShopItem );
	RegisterEvent( EV_DialogOK );
}

function OnClickButton( string strID )
{
	switch( strID )
	{
	case "btnEnd":
		class'RecipeAPI'.static.RequestRecipeShopManageQuit();
		CloseWindow();
		break;
	case "btnMsg":
		DialogSetEditBoxMaxLength(29);
		DialogShow(DIALOG_OKCancelInput, GetSystemMessage(334));
		DialogSetID(0);
		DialogSetString(class'UIDATA_PLAYER'.static.GetRecipeShopMsg());
		break;
	case "btnStart":
		StartRecipeShop();
		CloseWindow();
		break;
	case "btnMoveUp":
		HandleMoveUpItem();
		break;
	case "btnMoveDown":
		HandleMoveDownItem();
		break;
	}
}

function OnEvent(int Event_ID, string param)
{
	local string strPrice;
	
	local int RecipeID;
	local int CanbeMade;
	local int MakingFee;
	local int Price;
	
	local InventoryWnd InventoryWnd;
	InventoryWnd = InventoryWnd( GetScript("InventoryWnd") );
	
	if (Event_ID == EV_RecipeShopShowWnd)
	{
		Clear();
		InventoryWnd.LoadItemOrder();
		//Show
		class'UIAPI_WINDOW'.static.ShowWindow("RecipeShopWnd");
		class'UIAPI_WINDOW'.static.SetFocus("RecipeShopWnd");
		
		//enum RecipeBookClass
		//{
		//	RBC_DWARF  = 0,	//������� �����Ǽ�
		//	RBC_NORMAL		//���� �����Ǽ�
		//};
		ParseInt(param, "Type", m_BookType);
		if (m_BookType == 1)
		{
			class'UIAPI_WINDOW'.static.SetWindowTitle("RecipeShopWnd", 1212);
		}
		else
		{
			class'UIAPI_WINDOW'.static.SetWindowTitle("RecipeShopWnd", 1213);
		}
	}
	else if (Event_ID == EV_RecipeShopAddBookItem)
	{
		ParseInt( param, "RecipeID", RecipeID );
		AddRecipeBookItem( RecipeID );
	}
	else if (Event_ID == EV_RecipeShopAddShopItem)
	{
		ParseInt( param, "RecipeID", RecipeID );
		ParseInt( param, "CanbeMade", CanbeMade );
		ParseInt( param, "MakingFee", MakingFee );
		AddRecipeShopItem( RecipeID, CanbeMade, MakingFee );
	}
	else if (Event_ID == EV_DialogOK)
	{
		if (DialogIsMine())
		{	
			//�޽��� �Է�
			if (DialogGetID() == 0 )
			{
				class'RecipeAPI'.static.RequestRecipeShopMessageSet(DialogGetString());
			}
			else if (DialogGetID() == 1 )
			{
				//������ "0"���̶�, ���� �Է��� �� �־�߸� �������� �߰�
				strPrice = DialogGetString();
				if (Len(strPrice)>0)
				{
					//�Է��� ������ 20���� ������ ���� �ʰ� ������ �ѷ��ش�.
					Price = int(strPrice);
					if( Price >= 2000000000 )
					{
						DialogSetID(2);
						DialogShow(DIALOG_Warning, GetSystemMessage(1369));
					}
					else
					{
						m_HandleItem.Price = Price;
						UpdateShopItem(m_HandleItem);
					}
				}
				ClearHandleItem();
			}
		}
	}
}

//Frame�� "X"�� ������ �� (���� ���带 ����� �ʿ䰡 ����)
function OnSendPacketWhenHiding()
{
	class'RecipeAPI'.static.RequestRecipeShopManageQuit();
	Clear();
}

//������ �ݱ�
function CloseWindow()
{
	Clear();
	class'UIAPI_WINDOW'.static.HideWindow("RecipeShopWnd");
	PlayConsoleSound(IFST_WINDOW_CLOSE);
}

//ItemWindow���� Ŭ�� ó��
function OnDBClickItem( string strID, int index )
{
	local int Max;
	local int i;
	local ItemInfo infItem;
	local ItemInfo DeleteItem;
	
	ClearHandleItem();
	
	if (strID == "BookItemWnd" && m_BookItemCount>index)
	{
		class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.BookItemWnd", index, infItem);
			
		// �̹� �Ʒ��� �����ϴ� �������̶�� ��������� �Ѵ�. 
		Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
		for (i=0; i<Max; i++)
		{
			if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, DeleteItem))
			{
				if (DeleteItem.ClassID == infItem.ClassID)
				{
					DeleteShopItem(infItem);	// �ش�������� �����ϰ� �����Ѵ�. 
					return;
				}
			}
		}
			
		//������ ���ϵ��� �ʰ� �Ѿ�Դٸ�, ������ �Է��ϴ� â���� �̵�.		
		class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.BookItemWnd", index, infItem);
		ShowShopItemAddDialog(infItem);
	}
	//Shop���� ����Ŭ���� �ϸ� ���̾�αװ� ��Ÿ���� ������ �Է�������, �����δ� �ƹ��� �۵��� �����ʴ´�.(���� �̷���)
	//���� �̷��� �ƴѰ����ϴ�. TTP�� ����Գ׿�. �Ʒ��κп��� ����Ŭ���ϸ� �������� �����մϴ�. -innowind
	else if (strID == "ShopItemWnd" && m_ShopItemCount>index)
	{
		class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", index, infItem);
		DeleteShopItem(infItem);	// �ش�������� �����Ѵ�. 
		//ShowShopItemAddDialog(infItem);
	}
}

/*
	Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
	for (i=0; i<Max; i++)
	{
		if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, infItem))
		{
			if (DeleteItem.ClassID == infItem.ClassID)
			{
				class'UIAPI_ITEMWINDOW'.static.DeleteItem( "RecipeShopWnd.ShopItemWnd", i);
				m_ShopItemCount--;
				UpdateShopItemCount(m_ShopItemCount);
				break;
			}
		}
	}
*/


//������ ��� ó��
function OnDropItem( string strID, ItemInfo infItem, int x, int y)
{
	if (strID == "BookItemWnd")
	{
		if (infItem.DragSrcName == "ShopItemWnd")
		{
			//Shop���� Book���� ����� ���, Shop�� �������� �����Ѵ�.
			DeleteShopItem(infItem);
		}
	}
	else if (strID == "ShopItemWnd")
	{
		if (infItem.DragSrcName == "BookItemWnd")
		{
			//Book���� Shop���� ����� ���, Shop�� �������� �߰��Ѵ�.
			ShowShopItemAddDialog(infItem);
		}
	}
}

//�ʱ�ȭ
function Clear()
{
	ClearHandleItem();	
	m_BookItemCount = 0;
	m_ShopItemCount = 0;
	UpdateShopItemCount(0);
	m_arrBookItem.Remove(0, m_arrBookItem.Length);
	m_arrShopItem.Remove(0, m_arrShopItem.Length);
	
	class'UIAPI_ITEMWINDOW'.static.Clear("RecipeShopWnd.BookItemWnd");
	class'UIAPI_ITEMWINDOW'.static.Clear("RecipeShopWnd.ShopItemWnd");
}

//Handle������ Ŭ����
function ClearHandleItem()
{
	local ItemInfo ItemClear;
	m_HandleItem = ItemClear;
}

//�����Ǽ� ������ �߰�
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
	
	infItem.Name = class'UIDATA_ITEM'.static.GetItemName(infItem.ClassID);
	infItem.Description = class'UIDATA_ITEM'.static.GetItemDescription(infItem.ClassID);
	infItem.Weight = class'UIDATA_ITEM'.static.GetItemWeight(infItem.ClassID);

	//���깰����
	infItem.IconName = class'UIDATA_ITEM'.static.GetItemTextureName(ProductID);
	infItem.CrystalType = class'UIDATA_RECIPE'.static.GetRecipeCrystalType(RecipeID);
	
	//ItemWnd�� �߰�
	class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeShopWnd.BookItemWnd", infItem);
	
	//ItemArray�� �߰�
	m_arrBookItem.Insert(m_arrBookItem.Length, 1);
	m_arrBookItem[m_arrBookItem.Length-1] = Index;
	
	m_BookItemCount++;
}

//�̹� �����  ������ �߰�
function AddRecipeShopItem(int RecipeID, int CanbeMade, int MakingFee)
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
	infItem.Price = MakingFee;
	infItem.Reserved = CanbeMade;
	
	infItem.Name = class'UIDATA_ITEM'.static.GetItemName(infItem.ClassID);
	infItem.Description = class'UIDATA_ITEM'.static.GetItemDescription(infItem.ClassID);
	infItem.Weight = class'UIDATA_ITEM'.static.GetItemWeight(infItem.ClassID);

	//���깰����
	infItem.IconName = class'UIDATA_ITEM'.static.GetItemTextureName(ProductID);
	infItem.CrystalType = class'UIDATA_RECIPE'.static.GetRecipeCrystalType(RecipeID);
	
	//ItemWnd�� �߰�
	class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeShopWnd.ShopItemWnd", infItem);
	
	//ItemArray�� �߰�
	m_arrShopItem.Insert(m_arrShopItem.Length, 1);
	m_arrShopItem[m_arrShopItem.Length-1] = Index;
	
	m_ShopItemCount++;
	UpdateShopItemCount(m_ShopItemCount);
}

//�����Ǽ��� ������ �߰� ���̾�α� �ڽ� ǥ��
function ShowShopItemAddDialog(ItemInfo AddItem)
{
	m_HandleItem = AddItem;
	DialogSetID(1);
	DialogSetParamInt(-1);
	DialogSetDefaultOK();	
	DialogShow(DIALOG_NumberPad, GetSystemMessage(963));
}

//�����Ǽ��� ������ �߰�
function UpdateShopItem(ItemInfo AddItem)
{
	local int		i;
	local int		Max;
	local ItemInfo	infItem;
	local bool		bDuplicated;
	
	bDuplicated = false;
	
	Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
	for (i=0; i<Max; i++)
	{
		if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, infItem))
		{
			if (AddItem.ClassID == infItem.ClassID)
			{
				bDuplicated = true;
				break;
			}
		}
	}
	if (!bDuplicated)
	{
		class'UIAPI_ITEMWINDOW'.static.AddItem( "RecipeShopWnd.ShopItemWnd", AddItem);
		m_ShopItemCount++;
		UpdateShopItemCount(m_ShopItemCount);
	}
}

//�����Ǽ��� ������ ����
function DeleteShopItem(ItemInfo DeleteItem)
{
	local int		i;
	local int		Max;
	local ItemInfo	infItem;
	
	Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
	for (i=0; i<Max; i++)
	{
		if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, infItem))
		{
			if (DeleteItem.ClassID == infItem.ClassID)
			{
				class'UIAPI_ITEMWINDOW'.static.DeleteItem( "RecipeShopWnd.ShopItemWnd", i);
				m_ShopItemCount--;
				UpdateShopItemCount(m_ShopItemCount);
				break;
			}
		}
	}
}

//��ϵ� ������ ���� ����
function UpdateShopItemCount(int Count)
{
	class'UIAPI_TEXTBOX'.static.SetText("RecipeShopWnd.txtCount", "(" $ Count $ "/" $ RECIPESHOP_MAX_ITEM_SELL $ ")");	
}

//�����Ǽ� ����
function StartRecipeShop()
{
	local int		i;
	local int		Max;
	local ItemInfo	infItem;
	
	local string	param;
	local int		ServerID;
	local int		Price;
	
	Max = class'UIAPI_ITEMWINDOW'.static.GetItemNum( "RecipeShopWnd.ShopItemWnd");
	ParamAdd(param, "Max", string(Max));
	
	for (i=0; i<Max; i++)
	{
		ServerID = 0;
		Price = 0;
		if (class'UIAPI_ITEMWINDOW'.static.GetItem( "RecipeShopWnd.ShopItemWnd", i, infItem))
		{
			ServerID = infItem.ServerID;
			Price = infItem.Price;
		}
		ParamAdd(param, "ServerID_" $ i, string(ServerID));
		ParamAdd(param, "Price_" $ i, string(Price));
	}
	class'RecipeAPI'.static.RequestRecipeShopListSet( param );
}

//������ ��
function HandleMoveUpItem()
{
	local ItemInfo infItem;
	
	if (class'UIAPI_ITEMWINDOW'.static.GetSelectedItem( "RecipeShopWnd.ShopItemWnd", infItem))
	{
		DeleteShopItem(infItem);
	}
}

//������ �ٿ�
function HandleMoveDownItem()
{
	local ItemInfo infItem;
	
	if (class'UIAPI_ITEMWINDOW'.static.GetSelectedItem( "RecipeShopWnd.BookItemWnd", infItem))
	{
		ShowShopItemAddDialog(infItem);
	}
}
defaultproperties
{
}
