//================================================================================
// AutoPotionsWnd.
//================================================================================

class AutoPotionsWnd extends UICommonAPI;

const TIMER_CP_SMALL_POTION=10203;
const TIMER_CP_POTION=10200;
const TIMER_HP_POTION=10201;
const TIMER_MP_POTION=10202;
const TIMER_INSERT_ON_START=10210;

var WindowHandle m_hOptWnd;
var WindowHandle AutoPotionsWnd;
var ItemWindowHandle InventoryItem;

var ItemWindowHandle BoxSmallCP;
var ItemWindowHandle BoxCP;
var ItemWindowHandle BoxHP;
var ItemWindowHandle BoxMP;

var ItemInfo CP_SmallItem;
var ItemInfo CP_Item;
var ItemInfo HP_Item;
var ItemInfo MP_Item;

var bool UseSmallCPPot;
var bool UseCPPot;
var bool UseHPPot;
var bool UseMPPot;

var TextureHandle ToggleSmallCP;
var TextureHandle ToggleCP;
var TextureHandle ToggleHP;
var TextureHandle ToggleMP;

var TextBoxHandle CountSmallCP;
var TextBoxHandle CountCP;
var TextBoxHandle CountHP;
var TextBoxHandle CountMP;

var bool UseAutoPotionSmallCP;
var bool UseAutoPotionCP;
var bool UseAutoPotionHP;
var bool UseAutoPotionMP;

var bool PotionsEnabled;

// auto potion buff
const POTION_BUFF_TIMER = 4443;
const POTION_BUFF_DELAY = 1500;

var bool hasAcumen;
var bool hasHaste;
var bool hasWW;
var bool hasBlockBuffEffect;

var ItemInfo AcumenPot;
var ItemInfo HastePot;
var ItemInfo WindWalkPot;

function OnLoad ()
{
	OnRegisterEvent();
	Init();
	ToggleSmallCP.HideWindow();
	ToggleCP.HideWindow();
	ToggleHP.HideWindow();
	ToggleMP.HideWindow();
	
	CountSmallCP.HideWindow();
	CountCP.HideWindow();
	CountHP.HideWindow();
	CountMP.HideWindow();
}

function OnDefaultPosition ()
{
	class'UIAPI_WINDOW'.static.SetAnchor( "AutoPotionsWnd","ElfenMenu", "TopRight", "TopRight", -5, -100 );
}

function OnRegisterEvent ()
{
	RegisterEvent(EV_GamingStateEnter);
	RegisterEvent(EV_UpdateCP);
	RegisterEvent(EV_UpdateHP);
	RegisterEvent(EV_UpdateMP);
	RegisterEvent( EV_AbnormalStatusNormalItem );
}

function Init ()
{
	AutoPotionsWnd = GetHandle("AutoPotionsWnd");
	InventoryItem = ItemWindowHandle(GetHandle("InventoryWnd.InventoryItem"));
	
	BoxSmallCP = ItemWindowHandle(GetHandle("AutoPotionsWnd.BoxSmallCP"));
	BoxCP = ItemWindowHandle(GetHandle("AutoPotionsWnd.BoxCP"));
	BoxHP = ItemWindowHandle(GetHandle("AutoPotionsWnd.BoxHP"));
	BoxMP = ItemWindowHandle(GetHandle("AutoPotionsWnd.BoxMP"));
	
	ToggleSmallCP = TextureHandle(GetHandle("AutoPotionsWnd.ToggleSmallCP"));
	ToggleCP = TextureHandle(GetHandle("AutoPotionsWnd.ToggleCP"));
	ToggleHP = TextureHandle(GetHandle("AutoPotionsWnd.ToggleHP"));
	ToggleMP = TextureHandle(GetHandle("AutoPotionsWnd.ToggleMP"));
	
	CountSmallCP = TextBoxHandle(GetHandle("AutoPotionsWnd.CountSmallCP"));
	CountCP = TextBoxHandle(GetHandle("AutoPotionsWnd.CountCP"));
	CountHP = TextBoxHandle(GetHandle("AutoPotionsWnd.CountHP"));
	CountMP = TextBoxHandle(GetHandle("AutoPotionsWnd.CountMP"));
}

function InsertPotionsOnStart ()
{	

	GetItemInfo(5592,CP_Item);
	if (CP_Item.ItemNum >= 1)
	{
		InsertCPPotion(CP_Item);
	} else {
		GetItemInfo(5591,CP_SmallItem);
		if (CP_SmallItem.ItemNum >= 1)
		{
			InsertSmallCPPotion(CP_SmallItem);
		} else {
			UseAutoPotionCP = False;
			BoxCP.Clear();
		}
	}
	
	GetItemInfo(1539,HP_Item);
	if (HP_Item.ItemNum >= 1)
	{
		InsertHPPotion(HP_Item);
	} else {
		GetItemInfo(1060,HP_Item);
		if (HP_Item.ItemNum >= 1)
		{
			InsertHPPotion(HP_Item);
		} else {
			GetItemInfo(1061,HP_Item);
			if (HP_Item.ItemNum >= 1)
			{
				InsertMPPotion(HP_Item);
			} else {
				UseAutoPotionHP = False;
				BoxHP.Clear();
			}
		}
	}

	GetItemInfo(9352,MP_Item);
	if (MP_Item.ItemNum >= 1)
	{
		InsertMPPotion(MP_Item);
	} else {
		GetItemInfo(728,MP_Item);
		if (MP_Item.ItemNum >= 1)
		{
			InsertMPPotion(MP_Item);
		} else {
			GetItemInfo(9353,MP_Item);
			if (MP_Item.ItemNum >= 1)
			{
				InsertMPPotion(MP_Item);
			} else {
				GetItemInfo(9351,MP_Item);
				if (MP_Item.ItemNum >= 1)
				{
					InsertMPPotion(MP_Item);
				} else {
					UseAutoPotionMP = False;
					BoxMP.Clear();
				}
			}
		}
	}
}

function GetItemInfo(int id, out ItemInfo Info)
{
	local int Index;
	local ItemInfo Item;

	Index = InventoryItem.FindItemWithClassID(id);
	InventoryItem.GetItem(Index,Item);
	
	if (Index > -1)
	{
		Info = 	Item;
	} else
	{
		Info.ItemNum = 0;
	}
}

function OnClickButton (string strID)
{
	switch (strID)
	{
		case "BtnSetting":
		if ( PotionsEnabled )
		{
			if (BoxCP.GetItemNum() > 0)
			{
				DisablePotions(BoxCP);
			}
			if (BoxSmallCP.GetItemNum() > 0)
			{
				DisablePotions(BoxSmallCP);
			}
			if (BoxHP.GetItemNum() > 0)
			{
				DisablePotions(BoxHP);
			}
			if (BoxMP.GetItemNum() > 0)
			{
				DisablePotions(BoxMP);
			}
			PotionsEnabled = False;
		} else {
			if (BoxSmallCP.GetItemNum() > 0)
			{
				EnablePotions(BoxSmallCP);
			}
			if (BoxCP.GetItemNum() > 0)
			{
				EnablePotions(BoxCP);
			}
			if (BoxHP.GetItemNum() > 0)
			{	
				EnablePotions(BoxHP);
			}
			if (BoxMP.GetItemNum() > 0)
			{
				EnablePotions(BoxMP);
			}
			PotionsEnabled = True;
		}
		default:
	}
}

function OnTimer (int TimerID)
{
	if (TimerID == TIMER_CP_SMALL_POTION)
	{		
		AutoPotionsWnd.KillTimer(TIMER_CP_SMALL_POTION);
		SetPotionsCount(CountSmallCP,BoxSmallCP,CP_SmallItem.ClassID);
		Handle_CP_HP_MP_Update(EV_UpdateCP+12312344);
	}
	
	if (TimerID == TIMER_CP_POTION)
	{		
		AutoPotionsWnd.KillTimer(TIMER_CP_POTION);
		SetPotionsCount(CountCP,BoxCP,CP_Item.ClassID);
		Handle_CP_HP_MP_Update(EV_UpdateCP);
	}
	if (TimerID == TIMER_HP_POTION)
	{	
		AutoPotionsWnd.KillTimer(TIMER_HP_POTION);
		SetPotionsCount(CountHP,BoxHP,HP_Item.ClassID);
		Handle_CP_HP_MP_Update(EV_UpdateHP);
	}
	if (TimerID == TIMER_MP_POTION)
	{
		AutoPotionsWnd.KillTimer(TIMER_MP_POTION);
		SetPotionsCount(CountMP,BoxMP,MP_Item.ClassID);
		Handle_CP_HP_MP_Update(EV_UpdateMP);
	}
	if (TimerID == TIMER_INSERT_ON_START)
	{
		AutoPotionsWnd.KillTimer(TIMER_INSERT_ON_START);
		InsertPotionsOnStart();
	}
	if (TimerID == POTION_BUFF_TIMER)
	{
		TryUsePotions();
	}
}

function Reset ()
{
	AutoPotionsWnd.KillTimer(TIMER_CP_POTION);
	AutoPotionsWnd.KillTimer(TIMER_CP_SMALL_POTION);
	AutoPotionsWnd.KillTimer(TIMER_HP_POTION);
	AutoPotionsWnd.KillTimer(TIMER_MP_POTION);
	UseAutoPotionSmallCP = false;
	UseAutoPotionCP = False;
	UseAutoPotionHP = False;
	UseAutoPotionMP = False;
}

function OnEvent (int a_EventID, string a_Param)
{
	switch (a_EventID)
	{
		case EV_GamingStateEnter:
		HandleGamingStateEnter();
		break;
		case EV_Die:
		Reset();
		break;
		case EV_UpdateCP:
		if ( UseCPPot )
		{
			if (!UseAutoPotionCP)
			{
				Handle_CP_HP_MP_Update(a_EventID);
			}
		}
		if ( UseSmallCPPot )
		{
			if (!UseAutoPotionSmallCP)
			{
				Handle_CP_HP_MP_Update(EV_UpdateCP+12312344);
			}
		}
		break;
		case EV_UpdateHP:
		if ( UseHPPot )
		{
			if (!UseAutoPotionHP)
			{
				Handle_CP_HP_MP_Update(a_EventID);
			}
		}
		break;
		case EV_UpdateMP:
		if ( UseMPPot )
		{
			if (!UseAutoPotionMP)
			{
				Handle_CP_HP_MP_Update(a_EventID);
			}
		}
		break;
		case EV_AbnormalStatusNormalItem:
			HandleBuffs(a_Param);
			break;
		default:
	}
}

function HandleGamingStateEnter ()
{
	Reset();
	AutoPotionsWnd.SetTimer(TIMER_INSERT_ON_START,2000);
}

function OnDropItem (string a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{
	switch (a_WindowID)
	{
		case "BoxSmallCP":
		InsertSmallCPPotion(a_ItemInfo);
		break;
		case "BoxCP":
		InsertCPPotion(a_ItemInfo);
		break;
		case "BoxHP":
		InsertHPPotion(a_ItemInfo);
		break;
		case "BoxMP":
		InsertMPPotion(a_ItemInfo);
		break;
		default:
	}
}

function InsertCPPotion (ItemInfo a_ItemInfo)
{
	if ((a_ItemInfo.ClassID != 5592))
	{
		AddSystemMessage(SetText("Remain",CP_Item),SetColor("System"));
		return;
	}
	UseAutoPotionCP = False;
	BoxCP.Clear();
	CP_Item = a_ItemInfo;
	BoxCP.AddItem(a_ItemInfo);
	CountCP.ShowWindow();
	SetPotionsCount(CountCP,BoxCP,a_ItemInfo.ClassID);
}

function InsertSmallCPPotion (ItemInfo a_ItemInfo)
{
	if ((a_ItemInfo.ClassID != 5591) )
	{
		AddSystemMessage(SetText("Remain",CP_SmallItem),SetColor("System"));
		return;
	}
	UseAutoPotionSmallCP = False;
	BoxSmallCP.Clear();
	CP_SmallItem = a_ItemInfo;
	BoxSmallCP.AddItem(a_ItemInfo);
	CountSmallCP.ShowWindow();
	SetPotionsCount(CountSmallCP,BoxSmallCP,a_ItemInfo.ClassID);
}

function InsertHPPotion (ItemInfo a_ItemInfo)
{
	if ((a_ItemInfo.ClassID != 1539) && (a_ItemInfo.ClassID != 1060) && (a_ItemInfo.ClassID != 1061))
	{
		AddSystemMessage(SetText("Remain",HP_Item),SetColor("System"));
		return;
	}
	UseAutoPotionHP = False;
	BoxHP.Clear();
	HP_Item = a_ItemInfo;
	BoxHP.AddItem(a_ItemInfo);
	CountHP.ShowWindow();
	SetOptionInt("Potions","Type_HP",HP_Item.ClassID);
	SetPotionsCount(CountHP,BoxHP,HP_Item.ClassID);
}

function InsertMPPotion (ItemInfo a_ItemInfo)
{
	if ((a_ItemInfo.ClassID != 728) && (a_ItemInfo.ClassID != 9351) && (a_ItemInfo.ClassID != 9352) && (a_ItemInfo.ClassID != 9353))
	{
		AddSystemMessage(SetText("Remain",MP_Item),SetColor("System"));
		return;
	}
	UseAutoPotionMP = False;
	BoxMP.Clear();
	MP_Item = a_ItemInfo;
	BoxMP.AddItem(a_ItemInfo);
	CountMP.ShowWindow();
	SetPotionsCount(CountMP,BoxMP,a_ItemInfo.ClassID);
}

function SetPotionsCount (TextBoxHandle Text, ItemWindowHandle Item, int id)
{
	local int Index;
	local ItemInfo a_ItemInfo;

	Index = InventoryItem.FindItemWithClassID(id);
	InventoryItem.GetItem(Index,a_ItemInfo);
	if (Index > -1)
	{
		if (a_ItemInfo.ItemNum > 99)
		{
			Text.SetText("99+");
		} else {
			Text.SetText(string(a_ItemInfo.ItemNum));
		}
	} else {
		Text.SetText("");
		Item.Clear();
		DisablePotions(Item);
	}
}

function OnClickItem (string strID, int Index)
{
	local ItemInfo a_ItemInfo;
	
	InventoryItem.GetItem(Index,a_ItemInfo);
	
	if (strID == "BoxSmallCP" && Index > -1)
	{
		if (a_ItemInfo.ItemNum == 0)
		{
			UseAutoPotionCP = False;
			BoxCP.Clear();
			CountCP.SetText("");
			DisablePotions(BoxSmallCP);
		} else {
			if (!UseCPPot)
			{
				EnablePotions(BoxSmallCP);
			} else {
				DisablePotions(BoxSmallCP);
			}
		}
	}
	if (strID == "BoxCP" && Index > -1)
	{
		if (a_ItemInfo.ItemNum <= 0)
		{
			UseAutoPotionCP = False;
			BoxCP.Clear();
			CountCP.SetText("");
			DisablePotions(BoxCP);
		} else {
			if (!UseCPPot)
			{
				EnablePotions(BoxCP);
			} else {
				DisablePotions(BoxCP);
			}
		}
	}
	if (strID == "BoxHP" && Index > -1)
	{
		if (a_ItemInfo.ItemNum <= 0)
		{	
			UseAutoPotionHP = False;
			BoxHP.Clear();
			CountHP.SetText("");
			DisablePotions(BoxHP);
		} else {
			if (!UseHPPot)
			{
				EnablePotions(BoxHP);
			} else {
				DisablePotions(BoxHP);
			}
		}
	}
	if (strID == "BoxMP" && Index > -1)
	{
		if (a_ItemInfo.ItemNum == 0)
		{
			UseAutoPotionMP = False;
			BoxMP.Clear();
			CountMP.SetText("");
			DisablePotions(BoxMP);
		} else {
			if (!UseMPPot)
			{
				EnablePotions(BoxMP);
			} else {
				DisablePotions(BoxMP);
			}
		}
	}
}

function DisablePotions (ItemWindowHandle ItemWnd)
{
	switch (ItemWnd)
	{
		case BoxSmallCP:
			AutoPotionsWnd.KillTimer(TIMER_CP_SMALL_POTION);
			ToggleSmallCP.HideWindow();
			UseSmallCPPot = False;
			UseAutoPotionSmallCP = False;
			AddSystemMessage(SetText("Deactivate",CP_SmallItem),SetColor("System"));
			break;
		case BoxCP:
			AutoPotionsWnd.KillTimer(TIMER_CP_POTION);
			ToggleCP.HideWindow();
			UseCPPot = False;
			UseAutoPotionCP = False;
			AddSystemMessage(SetText("Deactivate",CP_Item),SetColor("System"));
			break;
		case BoxHP:
			AutoPotionsWnd.KillTimer(TIMER_HP_POTION);
			ToggleHP.HideWindow();
			UseHPPot = False;
			UseAutoPotionHP = False;
			AddSystemMessage(SetText("Deactivate",HP_Item),SetColor("System"));
			break;
		case BoxMP:
			AutoPotionsWnd.KillTimer(TIMER_MP_POTION);
			ToggleMP.HideWindow();
			UseMPPot = False;
			UseAutoPotionMP = False;
			AddSystemMessage(SetText("Deactivate",MP_Item),SetColor("System"));
			break;
			default:
	}
}

function EnablePotions (ItemWindowHandle ItemWnd)
{
	switch (ItemWnd)
	{
		case BoxSmallCP:
			ToggleSmallCP.ShowWindow();
			UseSmallCPPot = True;
			ExecuteEvent(EV_UpdateCP);
			AddSystemMessage(SetText("Activate",CP_Item),SetColor("System"));
			break;
		case BoxCP:
			ToggleCP.ShowWindow();
			UseCPPot = True;
			ExecuteEvent(EV_UpdateCP);
			AddSystemMessage(SetText("Activate",CP_Item),SetColor("System"));
			break;
		case BoxHP:
			ToggleHP.ShowWindow();
			UseHPPot = True;
			ExecuteEvent(EV_UpdateHP);
			AddSystemMessage(SetText("Activate",HP_Item),SetColor("System"));
			break;
		case BoxMP:
			ToggleMP.ShowWindow();
			UseMPPot = True;
			ExecuteEvent(EV_UpdateMP);
			AddSystemMessage(SetText("Activate",MP_Item),SetColor("System"));
			break;
			default:
	}
}

function string SetText (string param, ItemInfo a_ItemInfo)
{
	local string Text;

	switch (param)
	{
		case "Remain":
		Text = "slot para "@a_ItemInfo.Name;
		break;
		case "Activate":
		Text = MakeFullSystemMsg(GetSystemMessage(1433),a_ItemInfo.Name);
		break;
		case "Deactivate":
		Text = MakeFullSystemMsg(GetSystemMessage(1434),a_ItemInfo.Name);
		break;
		default:
	}
	return Text;
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

function Handle_CP_HP_MP_Update (int a_EventID)
{
	local UserInfo UserInfo;

	GetPlayerInfo(UserInfo);
	switch (a_EventID)
	{
		case EV_UpdateCP:
		if ( UseCPPot )
		{
			if (UserInfo.nCurCP < UserInfo.nMaxCP - 200 && UserInfo.nCurHP > 0)
			{
				UseAutoPotionCP = True;
				AutoPotionsWnd.SetTimer(TIMER_CP_POTION,100);
				RequestUseItem(CP_Item.ServerID);
			} else {
				UseAutoPotionCP = False;
			}
		}
		break;
		case EV_UpdateCP+12312344:
		if ( UseSmallCPPot )
		{
			if (UserInfo.nCurCP < UserInfo.nMaxCP - 200 && UserInfo.nCurHP > 0)
			{
				UseAutoPotionSmallCP = True;
				AutoPotionsWnd.SetTimer(TIMER_CP_SMALL_POTION,500);
				RequestUseItem(CP_SmallItem.ServerID);
			} else {
				UseAutoPotionSmallCP = False;
			}
		}
		break;
		case EV_UpdateHP:
		if ( UseHPPot )
		{
			if (UserInfo.nCurHP < int(UserInfo.nMaxHP * 0.70) && UserInfo.nCurHP > 0)
			{
				UseAutoPotionHP = True;
				AutoPotionsWnd.SetTimer(TIMER_HP_POTION,14000);
				RequestUseItem(HP_Item.ServerID);
			} else {
				UseAutoPotionHP = False;
			}
		}
		break;
		case EV_UpdateMP:
		if ( UseMPPot )
		{
			if (UserInfo.nCurMP < int(UserInfo.nMaxMP * 0.70) && UserInfo.nCurHP > 0)
			{
				UseAutoPotionMP = True;
				AutoPotionsWnd.SetTimer(TIMER_MP_POTION,14000);
				RequestUseItem(MP_Item.ServerID);
			} else {
				UseAutoPotionMP = False;
			}
		}
		break;
		default:
	}
}

function HandleBuffs(string param)
{
	local int i;
	local int Max;
	local StatusIconInfo info;
	
	hasAcumen = false;
	hasWW = false;
	hasHaste = false;
	hasBlockBuffEffect = false;
	ParseInt(param, "Max", Max);
	for (i=0; i< Max; i++)
	{
		ParseInt(param, "SkillID_" $ i, info.ClassID);
		if (AcumenBuff(info.ClassID))
			hasAcumen = true;
			
		if (WindWalkBuff(info.ClassID))
			hasWW = true;
			
		if (HasteBuff(info.ClassID))
			hasHaste = true;
		
		if (IsBlockBuffEffect(info.ClassID))
			hasBlockBuffEffect = true;		
	}
	AutoPotionsWnd.KillTimer(POTION_BUFF_TIMER);
	if (GetOptionBool("Custom","BuffPotions") == true)
	{
		if ((!hasAcumen && HavePotions("Acumen")) || (!hasHaste && HavePotions("Haste")) || (!hasWW && HavePotions("WindWalk")))
		{
			AutoPotionsWnd.SetTimer(POTION_BUFF_TIMER,POTION_BUFF_DELAY);
		}
	}
}

function TryUsePotions()
{
	local UserInfo userinfo;
	GetPlayerInfo(userinfo);
	
	if (userinfo.nCurHP > 0) 
	{	
		if (ImFighter() && hasWW && hasHaste)
		{
			AutoPotionsWnd.KillTimer(POTION_BUFF_TIMER);
		} else if (ImMage() && hasWW && hasAcumen)
		{
			AutoPotionsWnd.KillTimer(POTION_BUFF_TIMER);
		} else if (!hasBlockBuffEffect)
		{
			if (ImFighter())
			{
				if (HavePotions("WindWalk") && (!hasWW))
				{
					RequestUseItem(WindWalkPot.ServerID);
				}
				if (HavePotions("Haste") && (!hasHaste))
				{
					RequestUseItem(HastePot.ServerID);
				}
			} else if (ImMage())
			{
				if (HavePotions("WindWalk") && (!hasWW))
				{
					RequestUseItem(WindWalkPot.ServerID);
				}
				if (HavePotions("Acumen") && (!hasAcumen))
				{
					RequestUseItem(AcumenPot.ServerID);
				}
			}			
		}
	}
}

function bool HavePotions(string type)
{
	local bool ResultBool;
	
	ResultBool = false;
	if (type == "Acumen")
	{	
		GetItemInfo(6036,AcumenPot);
		if (AcumenPot.ItemNum >= 1)
		{
			ResultBool = true;
		}
	} 
	else if (type == "Haste")
	{
		GetItemInfo(1375,HastePot);
		if (HastePot.ItemNum >= 1)
		{
			ResultBool = true;
		}
	}
	else if (type == "WindWalk")
	{
		GetItemInfo(1374,WindWalkPot);
		if (WindWalkPot.ItemNum >= 1)
		{
			ResultBool = true;
		}
	}
	return ResultBool;
}

function bool WindWalkBuff (int id)
{
	local bool ResultBool;

	ResultBool = False;
	switch (id)
	{
		case 1204:
		case 1282:
		case 2034:
		ResultBool = True;
		break;
		default:
	}
	return ResultBool;
}

function bool HasteBuff(int id)
{
	local bool ResultBool;

	ResultBool = False;
	switch (id)
	{
		case 1086:
		case 1251:
		case 2035:
		ResultBool = True;
		break;
		default:
	}
	return ResultBool;
}

function bool AcumenBuff(int id)
{
	local bool ResultBool;

	ResultBool = False;
	switch (id)
	{
		case 1004:
		case 1085:
		case 2169:
		ResultBool = True;
		break;
		default:
	}
	return ResultBool;
}

function bool IsBlockBuffEffect (int id)
{
	local bool ResultBool;

	ResultBool = False;
	switch (id)
	{
		case 1418:
		case 1427:
		ResultBool = True;
		break;
		default:
	}
	return ResultBool;
}

function bool ImFighter()
{
	local bool ResultBool;
	local UserInfo info;
	GetPlayerInfo(info);
	
	ResultBool = false;
	switch (info.nSubclass)
	{
		case 0:
		case 1:
		case 2:
		case 88:
		case 3:
		case 89:
		case 4:
		case 5:
		case 90:
		case 6:
		case 91:
		case 7:
		case 8:
		case 93:
		case 9:
		case 92:
		case 18:
		case 19:
		case 20:
		case 99:
		case 21:
		case 100:
		case 22:
		case 23:
		case 101:
		case 24:
		case 102:
		case 31:
		case 32:
		case 33:
		case 106:
		case 34:
		case 107:
		case 35:
		case 108:
		case 36:
		case 37:
		case 109:
		case 44:
		case 45:
		case 46:
		case 113:
		case 47:
		case 48:
		case 114:
		case 53:
		case 54:
		case 55:
		case 117:
		case 56:
		case 57:
		case 118:
		ResultBool = True;
		break;
		default:
	}
	return ResultBool;
}

function bool ImMage()
{
	return !ImFighter();
}

defaultproperties
{
}
