class Tooltip extends UICommonAPI;

const TOOLTIP_MINIMUM_WIDTH = 144;
const TOOLTIP_SETITEM_MAX = 3;

var CustomTooltip m_Tooltip;
var DrawItemInfo m_Info;

function OnLoad()
{
	RegisterEvent( EV_RequestTooltipInfo );
}

function OnEvent(int Event_ID, string param)
{
	switch( Event_ID )
	{
	case EV_RequestTooltipInfo:
		HandleRequestTooltipInfo(param);
		break;
	}
}

function HandleRequestTooltipInfo(string param)
{
	local String TooltipType;
	local int SourceType;
	local ETooltipSourceType eSourceType;
	
	ClearTooltip();
	
	if (!ParseString(param, "TooltipType", TooltipType))
		return;
		
	if (!ParseInt(param, "SourceType", SourceType))
		return;
	
	eSourceType = ETooltipSourceType(SourceType);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////// Normal Tooltip /////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	if (TooltipType == "Text")
	{
		ReturnTooltip_NTT_TEXT(param, eSourceType, false);
	}
	else if (TooltipType == "Description")
	{
		ReturnTooltip_NTT_TEXT(param, eSourceType, true);
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////// ItemWnd Tooltip ////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	else if (TooltipType == "Action")
	{
		ReturnTooltip_NTT_ACTION(param, eSourceType);
	}
	else if (TooltipType == "Skill")
	{
		ReturnTooltip_NTT_SKILL(param, eSourceType);
	}
	else if (TooltipType == "NormalItem")
	{
		ReturnTooltip_NTT_NORMALITEM(param, eSourceType);
	}
	else if (TooltipType == "Shortcut")
	{
		ReturnTooltip_NTT_SHORTCUT(param, eSourceType);
	}
	else if (TooltipType == "AbnormalStatus")
	{
		ReturnTooltip_NTT_ABNORMALSTATUS(param, eSourceType);
	}
	else if (TooltipType == "RecipeManufacture")
	{
		ReturnTooltip_NTT_RECIPE_MANUFACTURE(param, eSourceType);
	}
	else if (TooltipType == "Recipe")
	{
		ReturnTooltip_NTT_RECIPE(param, eSourceType, false);
	}
	else if (TooltipType == "RecipePrice")
	{
		ReturnTooltip_NTT_RECIPE(param, eSourceType, true);
	}
	else if (TooltipType == "Inventory"
			|| TooltipType == "InventoryPrice1"
			|| TooltipType == "InventoryPrice2"
			|| TooltipType == "InventoryPrice1HideEnchant"
			|| TooltipType == "InventoryPrice1HideEnchantStackable"
			|| TooltipType == "InventoryPrice2PrivateShop")
	{
		ReturnTooltip_NTT_ITEM(param, TooltipType, eSourceType);
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////// ListCtrl Tooltip ///////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	else if (TooltipType == "PartyMatch")
	{
		ReturnTooltip_NTT_PARTYMATCH(param, eSourceType);
	}
	else if (TooltipType == "QuestInfo")
	{
		ReturnTooltip_NTT_QUESTINFO(param, eSourceType);
	}
	else if (TooltipType == "QuestList")
	{
		ReturnTooltip_NTT_QUESTLIST(param, eSourceType);
	}
	else if (TooltipType == "RaidList")
	{
		ReturnTooltip_NTT_RAIDLIST(param, eSourceType);
	}
	else if (TooltipType == "ClanInfo")
	{
		ReturnTooltip_NTT_CLANINFO(param, eSourceType);
	}
	/////////////////////////////////////////////////////
	// MANOR
	else if (TooltipType == "ManorSeedInfo"
			|| TooltipType == "ManorCropInfo"
			|| TooltipType == "ManorSeedSetting"
			|| TooltipType == "ManorCropSetting"
			|| TooltipType == "ManorDefaultInfo"
			|| TooltipType == "ManorCropSell")
	{
		ReturnTooltip_NTT_MANOR(param, TooltipType, eSourceType);
	}
}

function bool IsEnchantableItem(EItemParamType Type)
{
	return (Type == ITEMP_WEAPON || Type == ITEMP_ARMOR || Type == ITEMP_ACCESSARY || Type == ITEMP_SHIELD);
}

function ClearTooltip()
{
	m_Tooltip.SimpleLineCount = 0;
	m_Tooltip.MinimumWidth = 0;
	m_Tooltip.DrawList.Remove(0, m_Tooltip.DrawList.Length);
}

function StartItem()
{
	local DrawItemInfo infoClear;
	m_Info = infoClear;
}

function EndItem()
{
	m_Tooltip.DrawList.Length = m_Tooltip.DrawList.Length + 1;
	m_Tooltip.DrawList[m_Tooltip.DrawList.Length-1] = m_Info;
}

/////////////////////////////////////////////////////////////////////////////////
// TEXT
function ReturnTooltip_NTT_TEXT(string param, ETooltipSourceType eSourceType, bool bDesc)
{
	local string strText;
	local int ID;
	
	if (eSourceType == NTST_TEXT)
	{
		if (ParseString( param, "Text", strText))
		{
			if (TryTooltipFromItemLink(strText))
                return;
			if (Len(strText)>0)
			{
				if (bDesc)
				{
					m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
					
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.t_color.R = 178;
					m_Info.t_color.G = 190;
					m_Info.t_color.B = 207;
					m_Info.t_color.A = 255;
					m_Info.t_strText = strText;
					EndItem();
				}
				else
				{
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.t_bDrawOneLine = true;
					m_Info.t_strText = strText;
					EndItem();	
				}
			}
		}
		else if (ParseInt( param, "ID", ID))
		{
			if (ID>0)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_ID = ID;
				EndItem();
			}
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// INVENTORY Etc
function ReturnTooltip_NTT_ITEM(string param, String TooltipType, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	local EItemType eItemType;
	local EEtcItemType eEtcItemType;
	
	local bool bLargeWidth;
	local string SlotString;
	local string strTmp;
	local int nTmp;
	local int idx;
	
	//A|╳５AE﹌?╳芋u
	local string ItemName;
	local int Quality;
	local int ColorR;
	local int ColorG;
	local int ColorB;
	local string strDesc1;
	local string strDesc2;
	local string strDesc3;
	
	//“uA“╳﹌c“u“╳AIAU
	local array<int> arrID;
	local int SetID;
	local int ClassID;
	
	//“u“╳﹠i╳I使帚“﹟A“﹌“uiAO╳取a
	local string strAdena;
	local string strAdenaComma;
	local color	 AdenaColor;
	
	if (eSourceType == NTST_ITEM)
	{
		ParamToItemInfo(param, Item);
		
		eItemType = EItemType(Item.ItemType);
		eEtcItemType = EEtcItemType(Item.ItemSubType);
		
		//“u“╳AIAU AI﹌／╳▼ Ae﹠i使╳
		ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );
		
		//AIA“u“╳﹌c ex) "+10"
		if (TooltipType != "InventoryPrice1HideEnchant"
			&& TooltipType != "InventoryPrice1HideEnchantStackable")
			AddTooltipItemEnchant(Item);
		
		//“u“╳AIAU AI﹌／╳▼
		AddTooltipItemName(ItemName, Item);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//“u“╳AIAU ╳芋使o“uo
		if (TooltipType != "InventoryPrice1HideEnchantStackable")
			AddTooltipItemCount(Item);
			
		//“u“╳AIAUAI “u“╳﹠i╳I使帚“﹟﹌／e, A“﹌“uiAO╳取a “o“／“╳﹌c﹌／﹠i
		if (Item.ClassID==57)
		{
			//SimpleTooltipA╳i A“﹌“uiAO╳取a“o“／“╳﹌c﹌／﹠i╳取iAo “／﹌／﹌?“IA“見﹌﹠U.
			m_Tooltip.SimpleLineCount = 2;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = "(" $ ConvertNumToText(String(Item.ItemNum)) $ ")";
			EndItem();
		}
		
		//InventoryPrice1 A﹌／AO
		if (TooltipType == "InventoryPrice1"
			|| TooltipType == "InventoryPrice1HideEnchant"
			|| TooltipType == "InventoryPrice1HideEnchantStackable")
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//╳芋﹌Ｙ╳芋Y : xxx,xxx,xxx
			AddTooltipItemOption(322, strAdenaComma $ " ", true, true, false);
			SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"“u“╳﹠i╳I使帚“﹟"
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color = AdenaColor;
			m_Info.t_ID= 469;
			EndItem();
			
			//SimpleTooltipA╳i ╳芋﹌Ｙ╳芋Y╳取iAo “／﹌／﹌?“IA“見﹌﹠U.
			m_Tooltip.SimpleLineCount = 2;
			
			//A“﹌“uiAO╳取a “o“／“╳﹌c﹌／﹠i
			if (Item.Price>0)
			{
				m_Tooltip.SimpleLineCount = 3;
				AddTooltipItemOption(0, "(" $ ConvertNumToText(strAdena) $ ")", false, true, false);
				SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			}
		}
		
		//InventoryPrice2 A﹌／AO
		if (TooltipType == "InventoryPrice2"
			|| TooltipType == "InventoryPrice2PrivateShop")
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//╳芋﹌Ｙ╳芋Y : 1╳芋使帚﹌﹠c
			AddTooltipItemOption2(322, 468, true, true, false);
			SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"xxx,xxx,xxx "
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color = AdenaColor;
			m_Info.t_strText = " " $ strAdenaComma $ " ";
			EndItem();
			
			//"“u“╳﹠i╳I使帚“﹟"
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color = AdenaColor;
			m_Info.t_ID= 469;
			EndItem();
			
			//SimpleTooltipA╳i ╳芋﹌Ｙ╳芋Y╳取iAo “／﹌／﹌?“IA“見﹌﹠U.
			m_Tooltip.SimpleLineCount = 2;
			
			//A“﹌“uiAO╳取a “o“／“╳﹌c﹌／﹠i
			if (Item.Price>0)
			{
				m_Tooltip.SimpleLineCount = 3;
				
				//"("
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = 6;
				m_Info.bLineBreak = true;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color = AdenaColor;
				m_Info.t_strText = "(";
				EndItem();
				
				//"1╳芋使帚﹌﹠c"
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = 6;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color = AdenaColor;
				m_Info.t_ID = 468;
				EndItem();
				
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = 6;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color = AdenaColor;
				m_Info.t_strText = " " $ ConvertNumToText(strAdena) $ ")";
				EndItem();
			}
		}
		
		//InventoryPrice2PrivateShop A﹌／AO
		if (TooltipType == "InventoryPrice2PrivateShop")
			if (IsStackableItem(Item.ConsumeType) && Item.Reserved > 0)
			{
				//"╳取﹌／﹌／A╳芋使帚“uo : xx"
				AddTooltipItemOption(808, String(Item.Reserved), true, true, false);
			}
		
		/////////////////////////////////////////////////////////////////////////////////////////
		// “u“╳AIAU﹌?﹌Ｙ ﹠iu﹌／╳I ╳芋╳EA“u A﹌╞“／﹌／
		
		SlotString = GetSlotTypeString(Item.ItemType, Item.SlotBitType, Item.ArmorType);
		
		switch (eItemType)
		{
			
		// 1. WEAPON
		case ITEM_WEAPON:
			bLargeWidth = true;
			
			//Slot Type
			strTmp = GetWeaponTypeString(Item.WeaponType);
			if (Len(strTmp)>0)
			{
				AddTooltipItemOption(0, strTmp $ " / " $ SlotString, false, true, false);
			}
			
			//“／o╳芋使見╳芋╳I
			AddTooltipItemBlank(12);
			
			//"[使o╳i╳取a A|﹌?使見]"
			AddTooltipItemOption(1489, "", true, false, false);
			SetTooltipItemColor(255, 255, 255, 0);
			
			//Physical Damage
			AddTooltipItemOption(94, String(GetPhysicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.PhysicalDamage)), true, true, false);
			
			//Masical Damage
			AddTooltipItemOption(98, String(GetMagicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.MagicalDamage)), true, true, false);
			
			//Attack Speed
			AddTooltipItemOption(111, GetAttackSpeedString(Item.AttackSpeed), true, true, false);
			
			//SoulShot Count
			if (Item.SoulshotCount>0)
			{
				AddTooltipItemOption(404, "X " $ Item.SoulshotCount, true, true, false);
			}
			
			//SpiritShot Count
			if (Item.SpiritShotCount>0)
			{
				AddTooltipItemOption(496, "X " $ Item.SpiritshotCount, true, true, false);
			}
			
			//Weight
			AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			
			//MP Consume
			if (Item.MpConsume != 0)
			{
				AddTooltipItemOption(320, String(Item.MpConsume), true, true, false);
			}
			
			//A|╳５AE﹌?╳芋u
			if (Item.RefineryOp1 != 0 || Item.RefineryOp2 != 0)
			{
				//“／o╳芋使見╳芋╳I
				AddTooltipItemBlank(12);
				
				//"[A|╳５AE﹌?╳芋u]"
				AddTooltipItemOption(1490, "", true, false, false);
				SetTooltipItemColor(255, 255, 255, 0);
				
				//AA╳５?╳芋“﹟ Ae﹠i使╳
				if (Item.RefineryOp2 != 0)
				{
					Quality = class'UIDATA_REFINERYOPTION'.static.GetQuality( Item.RefineryOp2 );
					GetRefineryColor(Quality, ColorR, ColorG, ColorB);
				}
				
				if (Item.RefineryOp1 != 0)
				{
					strDesc1 = "";
					strDesc2 = "";
					strDesc3 = "";
					if (class'UIDATA_REFINERYOPTION'.static.GetOptionDescription( Item.RefineryOp1, strDesc1, strDesc2, strDesc3 ))
					{	
						if (Len(strDesc1)>0)
						{
							AddTooltipItemOption(0, strDesc1, false, true, false);
							SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
						}
						if (Len(strDesc2)>0)
						{
							AddTooltipItemOption(0, strDesc2, false, true, false);
							SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
						}
						if (Len(strDesc3)>0)
						{
							AddTooltipItemOption(0, strDesc3, false, true, false);
							SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
						}
					}
				}	
				
				if (Item.RefineryOp2 != 0)
				{
					strDesc1 = "";
					strDesc2 = "";
					strDesc3 = "";
					if (class'UIDATA_REFINERYOPTION'.static.GetOptionDescription( Item.RefineryOp2, strDesc1, strDesc2, strDesc3 ))
					{
						if (Len(strDesc1)>0)
						{
							AddTooltipItemOption(0, strDesc1, false, true, false);
							SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
							
						}
						if (Len(strDesc2)>0)
						{
							AddTooltipItemOption(0, strDesc2, false, true, false);
							SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
						}
						if (Len(strDesc3)>0)
						{
							AddTooltipItemOption(0, strDesc3, false, true, false);
							SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
						}
					}
				}
				
				//"╳取使帚E?/﹠ia╳５O “／O╳芋﹌Ｙ"
				AddTooltipItemOption(1491, "", true, false, false);
				SetTooltipItemColor(ColorR, ColorG, ColorB, 0);
				
				//“／o╳芋使見╳芋╳I
				if (Len(Item.Description)>0)
				{
					AddTooltipItemBlank(12);
				}
			}
		break;
		
		// 2. ARMOR
		case ITEM_ARMOR:
			bLargeWidth = true;
			
			// Sheild
			if (Item.SlotBitType == 256 || Item.SlotBitType == 128)	//SBT_LHAND or SBT_RHAND
			{
				//Shield Defense
				AddTooltipItemOption(95, String(GetShieldDefense(Item.CrystalType, Item.Enchanted, Item.ShieldDefense)), true, true, false);
				
				//Shield Defense Rate
				AddTooltipItemOption(317, String(Item.ShieldDefenseRate), true, true, false);
				
				//Avoid Modify
				AddTooltipItemOption(97, String(Item.AvoidModify), true, true, false);
				
				//Weight
				AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}
			
			// Magical Armor
			else if (IsMagicalArmor(Item.ClassID))
			{
				//Slot Type
				if (Len(SlotString)>0)
					AddTooltipItemOption(0, SlotString, false, true, false);
				
				//MP Bonus
				AddTooltipItemOption(388, String(Item.MpBonus), true, true, false);
				
				//Physical Defense
				AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.PhysicalDefense)), true, true, false);
				
				//Weight
				AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}
			
			// Physical Armor
			else
			{
				//Slot Type
				if (Len(SlotString)>0)
					AddTooltipItemOption(0, SlotString, false, true, false);
				
				//Physical Defense
				AddTooltipItemOption(95, String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.PhysicalDefense)), true, true, false);	
				
				//Weight
				AddTooltipItemOption(52, String(Item.Weight), true, true, false);
			}
			
		break;
		
		// 3. ACCESSARY
		case ITEM_ACCESSARY:
			bLargeWidth = true;
			
			//Slot Type
			if (Len(SlotString)>0)
				AddTooltipItemOption(0, SlotString, false, true, false);
			
			//Masical Defense
			AddTooltipItemOption(99, String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.MagicalDefense)), true, true, false);
			
			//Weight
			AddTooltipItemOption(52, String(Item.Weight), true, true, false);
		break;
		
		// 4. QUEST
		case ITEM_QUESTITEM:
			bLargeWidth = true;
			
			//Slot Type
			if (Len(SlotString)>0)
				AddTooltipItemOption(0, SlotString, false, true, false);
		break;
		
		// 5. ETC
		case ITEM_ETCITEM:
			bLargeWidth = true;
			
			if (eEtcItemType == ITEME_PET_COLLAR)
			{
				//Pet Name
				if (Item.Damaged == 0)
					nTmp = 971;
				else
					nTmp = 970;
				AddTooltipItemOption2(969, nTmp, true, true, false);
				
				//Pet Level
				AddTooltipItemOption(88, String(Item.Enchanted), true, true, false);
			}
			else if (eEtcItemType == ITEME_TICKET_OF_LORD)
			{
				AddTooltipItemOption(972, String(Item.Enchanted), true, true, false);
			}
			else if (eEtcItemType == ITEME_LOTTO)
			{
				//Time
				AddTooltipItemOption(670, String(Item.Blessed), true, true, false);
				
				//Lotto Num
				AddTooltipItemOption(671, GetLottoString(Item.Enchanted, Item.Damaged), true, true, false);
			}
			else if (eEtcItemType == ITEME_RACE_TICKET)
			{
				//Time
				AddTooltipItemOption(670, String(Item.Enchanted), true, true, false);
				
				//Race Ticket Num
				AddTooltipItemOption(671, GetRaceTicketString(Item.Blessed), true, true, false);
				
				//Money
				AddTooltipItemOption(744, String(Item.Damaged*100), true, true, false);
			}
			//Weight
			AddTooltipItemOption(52, String(Item.Weight), true, true, false);
		break;
		
		}
		/////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////////////////////////////////
		
		//使帚╳i╳取﹌／﹠i﹠i “u“╳AIAU
		if (Item.CurrentDurability >= 0 && Item.Durability > 0)
		{
			bLargeWidth = true;
			
			//“／o╳芋使見╳芋╳I
			AddTooltipItemBlank(12);
			
			//<Ao﹌?﹠i “／﹌﹠╳取a A﹌╞“／﹌／>
			AddTooltipItemOption(1492, "", true, false, false);
			SetTooltipItemColor(255, 255, 255, 0);
			
			//╳ic﹌?e╳芋﹌Ｙ﹌﹠E “oA╳芋╳I
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_ID = 1493;
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			if (Item.CurrentDurability+1 <= 5)
			{
				m_Info.t_color.R = 255;
				m_Info.t_color.G = 0;
				m_Info.t_color.B = 0;
			}
			else
			{
				m_Info.t_color.R = 176;
				m_Info.t_color.G = 155;
				m_Info.t_color.B = 121;
			}
			m_Info.t_color.A = 255;
			m_Info.t_strText = " " $ Item.CurrentDurability $ "/" $ Item.Durability;
			EndItem();
			
			//"╳取使帚E?/﹠ia╳５O “／O╳芋﹌Ｙ"
			AddTooltipItemOption(1491, "", true, false, false);
			
			//“／o╳芋使見╳芋╳I
			if (Len(Item.Description)>0)
			{
				AddTooltipItemBlank(12);
			}
		}
		
		//“u使帚﹌／i
		if (Len(Item.Description)>0)
		{
			bLargeWidth = true;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////
		// “uA“╳﹌c “u“╳AIAU A﹌╞“／﹌／
		if (Item.ClassID>0)
		{
			for (idx=0; idx<TOOLTIP_SETITEM_MAX; idx++)
			{
				//“uA“╳﹌c“u“╳AIAU ﹌／﹌c“o“／“╳﹌c
				class'UIDATA_ITEM'.static.GetSetItemIDList(Item.ClassID, idx, arrID);
				for (SetID=0; SetID<arrID.Length; SetID++)
				{
					bLargeWidth = true;
					ClassID = arrID[SetID];
					if (Item.ClassID != ClassID)
					{
						strTmp = class'UIDATA_ITEM'.static.GetItemName(ClassID);
						if (Len(strTmp)>0)
						{
							StartItem();
							m_Info.eType = DIT_TEXT;
							m_Info.nOffSetY = 6;
							m_Info.bLineBreak = true;
							m_Info.t_bDrawOneLine = true;
							m_Info.t_color.R = 112;
							m_Info.t_color.G = 115;
							m_Info.t_color.B = 123;
							m_Info.t_color.A = 255;
							m_Info.t_strText = strTmp;
							ParamAdd(m_Info.Condition, "Type", "Equip");
							ParamAdd(m_Info.Condition, "ServerID", String(Item.ServerID));
							ParamAdd(m_Info.Condition, "EquipID", String(ClassID));
							ParamAdd(m_Info.Condition, "NormalColor", "112,115,123");
							ParamAdd(m_Info.Condition, "EnableColor", "176,185,205");
							EndItem();
						}
					}
				}
				//“uA“╳﹌cE﹌?╳芋u
				strTmp = class'UIDATA_ITEM'.static.GetSetItemEffectDescription(Item.ClassID, idx);
				if (Len(strTmp)>0)
				{
					bLargeWidth = true;
					
					StartItem();
					m_Info.eType = DIT_TEXT;
					m_Info.nOffSetY = 6;
					m_Info.bLineBreak = true;
					m_Info.t_color.R = 128;
					m_Info.t_color.G = 127;
					m_Info.t_color.B = 103;
					m_Info.t_color.A = 255;
					m_Info.t_strText = strTmp;
					ParamAdd(m_Info.Condition, "Type", "SetEffect");
					ParamAdd(m_Info.Condition, "ServerID", String(Item.ServerID));
					ParamAdd(m_Info.Condition, "ClassID", String(Item.ClassID));
					ParamAdd(m_Info.Condition, "EffectID", String(idx));
					ParamAdd(m_Info.Condition, "NormalColor", "128,127,103");
					ParamAdd(m_Info.Condition, "EnableColor", "183,178,122");
					EndItem();	
				}
			}
			//AIA“u“╳﹌c “uA“╳﹌cE﹌?╳芋u
			strTmp = class'UIDATA_ITEM'.static.GetSetItemEnchantEffectDescription(Item.ClassID);
			if (Len(strTmp)>0)
			{
				bLargeWidth = true;
				
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetY = 6;
				m_Info.bLineBreak = true;
				m_Info.t_color.R = 74;
				m_Info.t_color.G = 92;
				m_Info.t_color.B = 104;
				m_Info.t_color.A = 255;
				m_Info.t_strText = strTmp;
				ParamAdd(m_Info.Condition, "Type", "EnchantEffect");
				ParamAdd(m_Info.Condition, "ServerID", String(Item.ServerID));
				ParamAdd(m_Info.Condition, "ClassID", String(Item.ClassID));
				ParamAdd(m_Info.Condition, "NormalColor", "74,92,104");
				ParamAdd(m_Info.Condition, "EnableColor", "111,146,169");
				EndItem();
			}
		}
	}
	else
	{
		return;
	}
	
	if (bLargeWidth)
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// ACTION
function ReturnTooltip_NTT_ACTION(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "Description", Item.Description);
		
		//“u╳０“uC AI﹌／╳▼
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = Item.Name;
		EndItem();
		
		//“u╳０“uC “u使帚﹌／i
		if (Len(Item.Description)>0)
		{
			m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = false;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// SKILL
function ReturnTooltip_NTT_SKILL(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	local EItemParamType eItemParamType;
	local EShortCutItemType eShortCutType;
	local int nTmp;
	local int SkillLevel;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseString( param, "Description", Item.Description);
		ParseInt( param, "ClassID", Item.ClassID);
		ParseInt( param, "Level", Item.Level);
		
		eShortCutType = EShortCutItemType(Item.ItemSubType);
		eItemParamType = EItemParamType(Item.ItemType);
		SkillLevel = Item.Level;
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//“u“╳AIAU AI﹌／╳▼
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = Item.Name;
		EndItem();
		
		if (Len(Item.AdditionalName)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetX = 5;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 255;
			m_Info.t_color.G = 217;
			m_Info.t_color.B = 105;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.AdditionalName;
			EndItem();
			
			SkillLevel = class'UIDATA_SKILL'.static.GetEnchantSkillLevel( Item.ClassID, Item.Level );
		}
		
		//ex) " Lv "
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = " ";
		EndItem();
		
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_ID = 88;
		EndItem();
		
		//“o“／A使帚 ╳５使o“／o
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		m_Info.t_strText = " " $ SkillLevel;
		EndItem();
		
		//Operate Type
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.nOffSetY = 6;
		m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		m_Info.t_strText = class'UIDATA_SKILL'.static.GetOperateType( Item.ClassID, Item.Level );
		EndItem();
		
		//“uO﹌／使﹟HP
		nTmp = class'UIDATA_SKILL'.static.GetHpConsume( Item.ClassID, Item.Level );
		if (nTmp>0)
		{
			AddTooltipItemOption(1195, String(nTmp), true, true, false);
		}
		
		//“uO﹌／使﹟MP
		nTmp = class'UIDATA_SKILL'.static.GetMpConsume( Item.ClassID, Item.Level );
		if (nTmp>0)
		{
			AddTooltipItemOption(320, String(nTmp), true, true, false);
		}
		
		//A?E﹌?╳芋A﹌／﹌c
		nTmp = class'UIDATA_SKILL'.static.GetCastRange( Item.ClassID, Item.Level );
		if (nTmp>=0)
		{
			AddTooltipItemOption(321, String(nTmp), true, true, false);
		}
		
		//“u使帚﹌／i
		if (Len(Item.Description)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// ABNORMALSTATUS
function ReturnTooltip_NTT_ABNORMALSTATUS(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	local EItemParamType eItemParamType;
	local EShortCutItemType eShortCutType;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseString( param, "Description", Item.Description);
		ParseInt( param, "ClassID", Item.ClassID);
		ParseInt( param, "Level", Item.Level);
		ParseInt( param, "Reserved", Item.Reserved);
		
		eShortCutType = EShortCutItemType(Item.ItemSubType);
		eItemParamType = EItemParamType(Item.ItemType);
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//“u“╳AIAU AI﹌／╳▼
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = Item.Name;
		EndItem();
		
		if (Len(Item.AdditionalName)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetX = 5;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 255;
			m_Info.t_color.G = 217;
			m_Info.t_color.B = 105;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.AdditionalName;
			EndItem();
			
			Item.Level = class'UIDATA_SKILL'.static.GetEnchantSkillLevel( Item.ClassID, Item.Level );
		}
		
		//ex) " Lv "
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = " ";
		EndItem();
		
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_ID = 88;
		EndItem();
		
		//“o“／A使帚 ╳５使o“／o
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		m_Info.t_strText = " " $ Item.Level;
		EndItem();
		
		//使帚使㊣A“／“oA╳芋╳I
		if (!IsDeBuff(Item.ClassID, Item.Level) && Item.Reserved>=0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_ID = 1199;
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " : ";
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 176;
			m_Info.t_color.G = 155;
			m_Info.t_color.B = 121;
			m_Info.t_color.A = 255;
			m_Info.t_strText = MakeBuffTimeStr(Item.Reserved);
			ParamAdd(m_Info.Condition, "Type", "RemainTime");
			EndItem();
		}
		
		//“u使帚﹌／i
		if (Len(Item.Description)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// NORMALITEM
function ReturnTooltip_NTT_NORMALITEM(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "Description", Item.Description);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseInt( param, "CrystalType", Item.CrystalType);
		
		//“u“╳AIAU AI﹌／╳▼
		AddTooltipItemName(Item.Name, Item);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//“u使帚﹌／i
		if (Len(Item.Description)>0)
		{
			m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// RECIPE
function ReturnTooltip_NTT_RECIPE(string param, ETooltipSourceType eSourceType, bool bShowPrice)
{
	local ItemInfo Item;
	
	local string strAdena;
	local string strAdenaComma;
	local color	 AdenaColor;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "Description", Item.Description);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseInt( param, "CrystalType", Item.CrystalType);
		ParseInt( param, "Weight", Item.Weight);
		ParseInt( param, "Price", Item.Price);
		
		//“u“╳AIAU AI﹌／╳▼
		AddTooltipItemName(Item.Name, Item);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//╳芋﹌Ｙ╳芋Y
		if (bShowPrice)
		{
			strAdena = String(Item.Price);
			strAdenaComma = MakeCostString(strAdena);
			AdenaColor = GetNumericColor(strAdenaComma);
			
			//╳芋﹌Ｙ╳芋Y : xxx,xxx,xxx
			AddTooltipItemOption(641, strAdenaComma $ " ", true, true, false);
			SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
			
			//"“u“╳﹠i╳I使帚“﹟"
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color = AdenaColor;
			m_Info.t_ID= 469;
			EndItem();
			
			//A“﹌“uiAO╳取a “o“／“╳﹌c﹌／﹠i
			AddTooltipItemOption(0, "(" $ ConvertNumToText(strAdena) $ ")", false, true, false);
			SetTooltipItemColor(AdenaColor.R, AdenaColor.G, AdenaColor.B, 0);
		}
		
		//Weight
		AddTooltipItemOption(52, String(Item.Weight), true, true, false);
		
		//“u使帚﹌／i
		if (Len(Item.Description)>0)
		{
			m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}		
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// SHORTCUT
function ReturnTooltip_NTT_SHORTCUT(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	local EItemParamType eItemParamType;
	local EShortCutItemType eShortCutType;
	local string ItemName;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseInt( param, "ClassID", Item.ClassID);
		ParseInt( param, "Level", Item.Level);
		ParseInt( param, "Reserved", Item.Reserved);
		ParseInt( param, "Enchanted", Item.Enchanted);
		ParseInt( param, "ItemType", Item.ItemType);
		ParseInt( param, "ItemSubType", Item.ItemSubType);
		ParseInt( param, "CrystalType", Item.CrystalType);
		ParseInt( param, "ConsumeType", Item.ConsumeType);
		ParseInt( param, "RefineryOp1", Item.RefineryOp1);
		ParseInt( param, "RefineryOp2", Item.RefineryOp2);
		ParseInt( param, "ItemNum", Item.ItemNum);
		ParseInt( param, "MpConsume", Item.MpConsume);
		
		eShortCutType = EShortCutItemType(Item.ItemSubType);
		eItemParamType = EItemParamType(Item.ItemType);
		
		//“u“╳AIAU AI﹌／╳▼ Ae﹠i使╳
		ItemName = class'UIDATA_ITEM'.static.GetRefineryItemName( Item.Name, Item.RefineryOp1, Item.RefineryOp2 );
		
		switch (eShortCutType)
		{
		case SCIT_ITEM:
			//AIA“u“╳﹌c ex) "+10"
			AddTooltipItemEnchant(Item);
			
			//“u“╳AIAU AI﹌／╳▼
			AddTooltipItemName(ItemName, Item);
			
			//Grade Mark
			AddTooltipItemGrade(Item);
			
			//“u“╳AIAU ╳芋使o“uo
			AddTooltipItemCount(Item);
		break;
		case SCIT_SKILL:
			//“u“╳AIAU AI﹌／╳▼
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = ItemName;
			EndItem();
			
			if (Len(Item.AdditionalName)>0)
			{
				StartItem();
				m_Info.eType = DIT_TEXT;
				m_Info.nOffSetX = 5;
				m_Info.t_bDrawOneLine = true;
				m_Info.t_color.R = 255;
				m_Info.t_color.G = 217;
				m_Info.t_color.B = 105;
				m_Info.t_color.A = 255;
				m_Info.t_strText = Item.AdditionalName;
				EndItem();
				
				Item.Level = class'UIDATA_SKILL'.static.GetEnchantSkillLevel( Item.ClassID, Item.Level );
			}
			
			//ex) " Lv "
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = " ";
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_ID = 88;
			EndItem();
			
			//“o“／A使帚 ╳５使o“／o
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 176;
			m_Info.t_color.G = 155;
			m_Info.t_color.B = 121;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " " $ Item.Level;
			EndItem();
			
			//MP“uO﹌／使﹟╳５﹌c
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = " (";
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_ID = 91;
			EndItem();
			
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = ":" $ Item.MpConsume $ ")";
			EndItem();
		break;
		
		case SCIT_ACTION:
		case SCIT_MACRO:
		case SCIT_RECIPE:
			//“u“╳AIAU AI﹌／╳▼
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_strText = ItemName;
			EndItem();
		break;
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// RECIPE_MANUFACTURE
function ReturnTooltip_NTT_RECIPE_MANUFACTURE(string param, ETooltipSourceType eSourceType)
{
	local ItemInfo Item;
	
	if (eSourceType == NTST_ITEM)
	{
		ParseString( param, "Name", Item.Name);
		ParseString( param, "Description", Item.Description);
		ParseString( param, "AdditionalName", Item.AdditionalName);
		ParseInt( param, "Reserved", Item.Reserved);
		ParseInt( param, "CrystalType", Item.CrystalType);
		ParseInt( param, "ItemNum", Item.ItemNum);
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//“u“╳AIAU AI﹌／╳▼
		AddTooltipItemName(Item.Name, Item);
		
		//Grade Mark
		AddTooltipItemGrade(Item);
		
		//ex) "CE﹌?a“uo : 2"
		AddTooltipItemOption(736, String(Item.Reserved), true, true, false);
		
		//ex) "“／﹌／A?“uo : 0"
		AddTooltipItemOption(737, String(Item.ItemNum), true, true, false);
		
		//“u使帚﹌／i
		if (Len(Item.Description)>0)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			m_Info.nOffSetY = 6;
			m_Info.bLineBreak = true;
			m_Info.t_color.R = 178;
			m_Info.t_color.G = 190;
			m_Info.t_color.B = 207;
			m_Info.t_color.A = 255;
			m_Info.t_strText = Item.Description;
			EndItem();	
		}
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// PLEDGEINFO
function ReturnTooltip_NTT_CLANINFO(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//ex) "A╳A“u╳A : ﹌?﹌╞“／i﹌／“〝AIAo"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[2].szData)), true, true, true);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// PARTYMATCH
function ReturnTooltip_NTT_PARTYMATCH(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//ex) "A╳A“u╳A : ﹌?﹌╞“／i﹌／“〝AIAo"
		AddTooltipItemOption(391, GetClassType(int(record.LVDataList[1].szData)), true, true, true);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// QUESTLIST
function ReturnTooltip_NTT_QUESTLIST(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	local int nTmp;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//Au“o“／“╳﹌c AI﹌／╳▼
		AddTooltipItemOption(1200, record.LVDataList[0].szData, true, true, true);
		
		//使oY“／使o“u“／
		switch(record.LVDataList[3].nReserved1)
		{
		case 0:
		case 2:
			nTmp = 861;
			break;
		case 1:
		case 3:
			nTmp = 862;
			break;
		}
		AddTooltipItemOption2(1202, nTmp, true, true, false);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// RAIDLIST
function ReturnTooltip_NTT_RAIDLIST(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		if (Len(record.szReserved)<1)
			return;
		
		m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;
		
		//╳５使oAI﹠ia “u使帚﹌／i
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = false;
		m_Info.t_color.R = 178;
		m_Info.t_color.G = 190;
		m_Info.t_color.B = 207;
		m_Info.t_color.A = 255;
		m_Info.t_strText = record.szReserved;
		EndItem();
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// QUESTINFO
function ReturnTooltip_NTT_QUESTINFO(string param, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	local int nTmp;
	local int Width1;
	local int Width2;
	local int Height;
		
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		//Au“o“／“╳﹌c AI﹌／╳▼
		AddTooltipItemOption(1200, record.LVDataList[0].szData, true, true, true);
		
		//“uoCaA﹌O╳芋C
		AddTooltipItemOption(1201, record.LVDataList[1].szData, true, true, false);
		
		//Width╳芋aA﹌╞!
		GetTextSize(GetSystemString(1200) $ " : " $ record.LVDataList[0].szData, Width1, Height);
		GetTextSize(GetSystemString(1201) $ " : " $ record.LVDataList[1].szData, Width2, Height);
		if (Width2>Width1)
			Width1 = Width2;
		if (TOOLTIP_MINIMUM_WIDTH>Width1)
			Width1 = TOOLTIP_MINIMUM_WIDTH;
		m_Tooltip.MinimumWidth = Width1 + 30;
		
		//A使／A﹠i╳５使o“／╳▼
		AddTooltipItemOption(922, record.LVDataList[2].szData, true, true, false);
		
		//使oY“／使o“u“／
		switch(record.LVDataList[3].nReserved1)
		{
		case 0:
		case 2:
			nTmp = 861;
			break;
		case 1:
		case 3:
			nTmp = 862;
			break;
		}
		AddTooltipItemOption2(1202, nTmp, true, true, false);
		
		//Au“o“／“╳﹌c“u使帚﹌／i
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.nOffSetY = 6;
		m_Info.t_bDrawOneLine = false;
		m_Info.bLineBreak = true;
		m_Info.t_color.R = 178;
		m_Info.t_color.G = 190;
		m_Info.t_color.B = 207;
		m_Info.t_color.A = 255;
		m_Info.t_strText = record.szReserved;
		EndItem();
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

/////////////////////////////////////////////////////////////////////////////////
// MANOR
function ReturnTooltip_NTT_MANOR(string param, string TooltipType, ETooltipSourceType eSourceType)
{
	local LVDataRecord record;
	
	local int idx1;
	local int idx2;
	local int idx3;
	
	if (eSourceType == NTST_LIST)
	{
		ParamToRecord( param, record );
		
		if (TooltipType == "ManorSeedInfo")
		{
			idx1 = 4;
			idx2 = 5;
			idx3 = 6;
		}
		else if (TooltipType == "ManorCropInfo")
		{
			idx1 = 5;
			idx2 = 6;
			idx3 = 7;
		}
		else if (TooltipType == "ManorSeedSetting")
		{
			idx1 = 7;
			idx2 = 8;
			idx3 = 9;
		}
		else if (TooltipType == "ManorCropSetting")
		{
			idx1 = 9;
			idx2 = 10;
			idx3 = 11;
		}
		else if (TooltipType == "ManorDefaultInfo")
		{
			idx1 = 1;
			idx2 = 4;
			idx3 = 5;
		}
		else if (TooltipType == "ManorCropSell")
		{
			idx1 = 7;
			idx2 = 8;
			idx3 = 9;
		}
		
		// “u“u“uN or AU使o╳芋 AI﹌／╳▼
		AddTooltipItemOption(0, record.LVDataList[0].szData, false, true, true);
		
		// ╳５使o“／╳▼
		AddTooltipItemOption(537, record.LVDataList[idx1].szData, true, true, false);

		// “／﹌／╳io A﹌／AO1
		AddTooltipItemOption(1134, record.LVDataList[idx2].szData, true, true, false);
		
		// “／﹌／╳io A﹌／AO2
		AddTooltipItemOption(1135, record.LVDataList[idx3].szData, true, true, false);
	}
	else
	{
		return;
	}
		
	ReturnTooltipInfo(m_Tooltip);
}

//"XXX : YYYY" CuAAAC TooltipItemA╳i “╳iCI╳芋O A使／╳芋﹌ＹC“見 A“見﹌﹠U.
function AddTooltipItemOption(int TitleID, string Content, bool bTitle, bool bContent, bool IamFirst)
{
	if (bTitle)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!IamFirst)
			m_Info.nOffSetY = 6;
		m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_ID = TitleID;
		EndItem();
	}
	
	if (bContent)
	{
		if (bTitle)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			if (!IamFirst)
				m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " : ";
			EndItem();
		}
		
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!IamFirst)
			m_Info.nOffSetY = 6;
		if (!bTitle)
			m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		m_Info.t_strText = Content;
		EndItem();
	}
}

//"XXX : YYYY" CuAAAC TooltipItemA╳i “╳iCI╳芋O A使／╳芋﹌ＹC“見 A“見﹌﹠U.
//SYSSTRING : SYSSTRING
function AddTooltipItemOption2(int TitleID, int ContentID, bool bTitle, bool bContent, bool IamFirst)
{
	if (bTitle)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!IamFirst)
			m_Info.nOffSetY = 6;
		m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 163;
		m_Info.t_color.G = 163;
		m_Info.t_color.B = 163;
		m_Info.t_color.A = 255;
		m_Info.t_ID = TitleID;
		EndItem();
	}
	
	if (bContent)
	{
		if (bTitle)
		{
			StartItem();
			m_Info.eType = DIT_TEXT;
			if (!IamFirst)
				m_Info.nOffSetY = 6;
			m_Info.t_bDrawOneLine = true;
			m_Info.t_color.R = 163;
			m_Info.t_color.G = 163;
			m_Info.t_color.B = 163;
			m_Info.t_color.A = 255;
			m_Info.t_strText = " : ";
			EndItem();
		}		
		
		StartItem();
		m_Info.eType = DIT_TEXT;
		if (!IamFirst)
			m_Info.nOffSetY = 6;
		if (!bTitle)
			m_Info.bLineBreak = true;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		m_Info.t_ID = ContentID;
		EndItem();
	}
}

//“u“╳AIAUAC ╳io╳ioA╳i ﹌﹠U“oA “u使帚A﹌╞C“見A“見﹌﹠U.
function SetTooltipItemColor(int R, int G, int B, int Offset)
{
	local int idx;
	idx = m_Tooltip.DrawList.Length-1-Offset;
	m_Tooltip.DrawList[idx].t_color.R = R;
	m_Tooltip.DrawList[idx].t_color.G = G;
	m_Tooltip.DrawList[idx].t_color.B = B;
	m_Tooltip.DrawList[idx].t_color.A = 255;
}

//“／o╳芋使見╳芋╳IAC TooltipItemA╳i A使／╳芋﹌ＹCN﹌﹠U.
function AddTooltipItemBlank(int Height)
{
	StartItem();
	m_Info.eType = DIT_BLANK;
	m_Info.b_nHeight = Height;
	EndItem();
}

//AIA“u“╳﹌c
function AddTooltipItemEnchant(ItemInfo Item)
{
	local EItemParamType eItemParamType;
	
	eItemParamType = EItemParamType(Item.ItemType);
	if (Item.Enchanted>0 && IsEnchantableItem(eItemParamType))
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 176;
		m_Info.t_color.G = 155;
		m_Info.t_color.B = 121;
		m_Info.t_color.A = 255;
		m_Info.t_strText = "+" $ Item.Enchanted $ " ";
		EndItem();
	}	
}

//“u“╳AIAU AI﹌／╳▼ + AdditionalName
function AddTooltipItemName(string Name, ItemInfo Item)
{
	StartItem();
	m_Info.eType = DIT_TEXT;
	m_Info.t_bDrawOneLine = true;
	m_Info.t_strText = Name;
	EndItem();
	
	//Additional Name
	if (Len(Item.AdditionalName)>0)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_color.R = 255;
		m_Info.t_color.G = 217;
		m_Info.t_color.B = 105;
		m_Info.t_color.A = 255;
		m_Info.t_strText = " " $ Item.AdditionalName;
		EndItem();
	}
}

//Grade Mark
function AddTooltipItemGrade(ItemInfo Item)
{
	local string strTmp;
	
	strTmp = GetItemGradeString(Item.CrystalType);
	if (Len(strTmp)>0)
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = " ";
		EndItem();
		
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = "`" $ strTmp $ "`";
		EndItem();
	}
}

//Stackable Count
function AddTooltipItemCount(ItemInfo Item)
{
	if (IsStackableItem(Item.ConsumeType))
	{
		StartItem();
		m_Info.eType = DIT_TEXT;
		m_Info.t_bDrawOneLine = true;
		m_Info.t_strText = " (" $ MakeCostString(String(Item.ItemNum)) $ ")";
		EndItem();
	}	
}

//A|╳５A ╳io╳io
function GetRefineryColor(int Quality, out int R, out int G, out int B)
{
	switch (Quality)
	{
	case 1:
		R = 187;
		G = 181;
		B = 138;
	break;
	case 2:
		R = 132;
		G = 174;
		B = 216;
	break;
	case 3:
		R = 193;
		G = 112;
		B = 202;
	break;
	case 4:
		R = 225;
		G = 109;
		B = 109;
	break;
	default:
		R = 187;
		G = 181;
		B = 138;
	break;
	}
}

function int FromBase36(string s)
{
    local string digs; local int i, v, idx;
    digs = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"; v = 0;
    for (i = 0; i < Len(s); ++i) { idx = InStr(digs, Mid(s, i, 1)); if (idx >= 0) v = v*36 + idx; }
    return v;
}

// Constroi um ItemInfo basico a partir de ClassID + opcionalmente enchant/refinery
function bool BuildItemInfoFromClass(out ItemInfo Item, int ClassID, int Ench, int Op1, int Op2)
{
    Item.ClassID     = ClassID;
    Item.Enchanted   = Ench;
    Item.RefineryOp1 = Op1;
    Item.RefineryOp2 = Op2;
	
	Item.Name			= class'UIDATA_ITEM'.static.GetItemName(ClassID);
	Item.Description	= class'UIDATA_ITEM'.static.GetItemDescription(ClassID);
	Item.IconName		= class'UIDATA_ITEM'.static.GetItemTextureName(ClassID);
    Item.CrystalType    = class'UIDATA_ITEM'.static.GetItemCrystalType(ClassID);
    Item.ItemType       = class'UIDATA_ITEM'.static.GetItemDataType(ClassID);
    Item.Weight         = class'UIDATA_ITEM'.static.GetItemWeight(ClassID);
    return true;
}

// Le [[I:<cid>:<en>:<op1>:<op2>]]? do texto e retorna o tooltip do item
function bool TryTooltipFromItemLink(string text)
{
    local int p1, p2;
    local string payload;
    local array<string> parts;
    local ItemInfo Item;
    local string refName;
	local int sep; local string piece;
	local int cid, ench, op1, op2;

    p1 = InStr(text, "[[I:");
    if (p1 == -1) return false;
    p2 = InStr(text, "]]?");
    if (p2 == -1 || p2 <= p1+4) return false;

    payload = Mid(text, p1+4, p2 - (p1+4));  // conteudo apos "I:"
    // split by ':'
    parts.Remove(0, parts.Length);
    while (true)
    {
        sep = InStr(payload, ":");
        if (sep == -1) { parts[parts.Length] = payload; break; }
        piece = Left(payload, sep);
        parts[parts.Length] = piece;
        payload = Mid(payload, sep+1);
    }

    if (parts.Length < 1) return false;

	cid  = FromBase36(parts[0]);
	ench = 0; op1 = 0; op2 = 0;

	if (parts.Length > 1) ench = FromBase36(parts[1]);
	if (parts.Length > 2) op1  = FromBase36(parts[2]);
	if (parts.Length > 3) op2  = FromBase36(parts[3]);

	if (!BuildItemInfoFromClass(Item, cid, ench, op1, op2))
	{
		return false;
	}

    // Desenha tooltip "normal" de item (reusa helpers que seu Tooltip ja tem)
    m_Tooltip.MinimumWidth = TOOLTIP_MINIMUM_WIDTH;

    // +10, nome (com refinery), grade
    AddTooltipItemEnchant(Item);
    refName = class'UIDATA_ITEM'.static.GetRefineryItemName(Item.Name, Item.RefineryOp1, Item.RefineryOp2);
    AddTooltipItemName(refName, Item);
    AddTooltipItemGrade(Item);

    // Pequenino sumario: slot + stats essenciais conforme tipo
    AddTooltipItemBlank(6);

    switch (EItemType(Item.ItemType))
    {
        case ITEM_WEAPON:
            AddTooltipItemOption(0, GetWeaponTypeString(Item.WeaponType) $ " / " $ GetSlotTypeString(Item.ItemType, Item.SlotBitType, Item.ArmorType), false, true, true);
            AddTooltipItemOption(94,  String(GetPhysicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.PhysicalDamage)), true, true, false);
            AddTooltipItemOption(98,  String(GetMagicalDamage(Item.WeaponType, Item.SlotBitType, Item.CrystalType, Item.Enchanted, Item.MagicalDamage)), true, true, false);
            if (Item.MpConsume != 0)
                AddTooltipItemOption(320, String(Item.MpConsume), true, true, false);
            AddTooltipItemOption(52,  String(Item.Weight), true, true, false);
            break;

        case ITEM_ARMOR:
            AddTooltipItemOption(0, GetSlotTypeString(Item.ItemType, Item.SlotBitType, Item.ArmorType), false, true, true);
            if (Item.SlotBitType == 256 || Item.SlotBitType == 128) // Shield
            {
                AddTooltipItemOption(95,  String(GetShieldDefense(Item.CrystalType, Item.Enchanted, Item.ShieldDefense)), true, true, false);
                AddTooltipItemOption(317, String(Item.ShieldDefenseRate), true, true, false);
            }
            else
            {
                AddTooltipItemOption(95,  String(GetPhysicalDefense(Item.CrystalType, Item.Enchanted, Item.PhysicalDefense)), true, true, false);
            }
            AddTooltipItemOption(52,  String(Item.Weight), true, true, false);
            break;

        case ITEM_ACCESSARY:
            AddTooltipItemOption(0, GetSlotTypeString(Item.ItemType, Item.SlotBitType, Item.ArmorType), false, true, true);
            AddTooltipItemOption(99, String(GetMagicalDefense(Item.CrystalType, Item.Enchanted, Item.MagicalDefense)), true, true, false);
            AddTooltipItemOption(52, String(Item.Weight), true, true, false);
            break;
    }

    if (Len(Item.Description) > 0)
    {
        AddTooltipItemBlank(12);
        StartItem(); m_Info.eType = DIT_TEXT; m_Info.nOffSetY = 6; m_Info.bLineBreak = true;
        m_Info.t_color.R = 178; m_Info.t_color.G = 190; m_Info.t_color.B = 207; m_Info.t_color.A = 255;
        m_Info.t_strText = Item.Description; EndItem();
    }

    ReturnTooltipInfo(m_Tooltip);
    return true;
}

defaultproperties
{
}