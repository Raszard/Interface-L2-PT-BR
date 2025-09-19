class AutoSkillWnd extends UICommonAPI;

const TIMER_ID = 6500;
const TIMER_SPOIL = 6501;
const MAX_SKILLS = 6;

var WindowHandle Me;
var ItemWindowHandle iSkill[6];
var ItemInfo infItem[6];
var bool cycleON;
var int skillNum;
var int lastSubClassID;

function OnLoad()
{
    local int i;

    RegisterEvent(968);
    RegisterEvent(980);
	RegisterEvent(650);
    RegisterEvent(40);
    Me = GetHandle("AutoSkillWnd");
    i = 0;
    J0x3F:
    if(i < 6)
    {
        iSkill[i] = ItemWindowHandle(GetHandle("AutoSkillWnd." $ string(i)));
        ++i;
        goto J0x3F;
    }
    ClearAll();
}

function OnEnterState(name a_PreStateName)
{
    LoadSkillConfig();
}

function OnEvent(int a_EventID, string a_Param)
{
    switch(a_EventID)
    {
        case 968:
            ClearOnChangeSub();
        break;
			
        break;
			
        case 40:
            ClearAll();
        break;			
			
        case 650:
            ClearAll();
        break;
		
        default:
        break;
    }
}
    
function OnTimer(int TimerID)
{

}

function OnRClickItemWithHandle(ItemWindowHandle a_hItemWindow, int Index)
{
    local int i;
    local ItemInfo Clear;

    a_hItemWindow.Clear();
	
    i = 0;
    J0x16:
    if(i < 6)
    {
        if(iSkill[i].GetItemNum() != 1)
        {
			RequestBypassToServer("farm rskill " $ string(infItem[i].ClassID));
			infItem[i] = Clear;
        }
        ++i;
        goto J0x16;
    }
    SaveSkillConfig();
}

function OnDropItem(string a_WindowID, ItemInfo a_ItemInfo, int X, int Y)
{
    OnDropSkill(a_WindowID, a_ItemInfo);
    SaveSkillConfig();
}

function OnDropSkill(string a_WindowID, ItemInfo a_ItemInfo)
{
    local int i;

    i = int(a_WindowID);
    if((a_ItemInfo.Level > 0) || (a_ItemInfo.ItemSubType == 3) && isValidAction(a_ItemInfo.ClassID))
    {
        AddSkill(i, a_ItemInfo);
    }
}

function bool isValidAction(int ClassID)
{
    switch(ClassID)
    {
        case 1:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        case 12:
        case 13:
        case 14:
        case 24:
        case 25:
        case 26:
        case 28:
        case 29:
        case 30:
        case 31:
        case 33:
        case 34:
        case 35:
        case 40:
        case 50:
        case 51:
        case 55:
        case 56:
        case 57:
        case 58:
        case 59:
        case 60:
        case 21:
        case 23:
        case 52:
        case 53:
            return false;
        break;
		
        default:
            return true;
        break;
    }
}

function AddSkill(int i, ItemInfo a_ItemInfo)
{
    RequestBypassToServer("farm skill " $ string(a_ItemInfo.ClassID));

	if(infItem[i].ClassID != 0)
	{
		RequestBypassToServer("farm rskill " $ string(infItem[i].ClassID));
	}

    iSkill[i].Clear();
    iSkill[i].AddItem(a_ItemInfo);
	infItem[i] = a_ItemInfo;
}

function SkillStart()
{
    Me.KillTimer(6500);
    Me.SetTimer(6500, 500);
}

function SkillStop()
{
    Me.KillTimer(6500);
}

function ClearOnChangeSub()
{
    ClearAll();
    skillNum = 0;
    SaveSkillConfig();
}

function int GetMyClassID()
{
    local UserInfo Info;

    GetPlayerInfo(Info);
    
    return Info.nSubClass;
}

function ClearAll()
{
    local int i;
    local ItemInfo clsInfo;

    i = 0;
    J0x07:
    if(i < 6)
    {
        iSkill[i].Clear();
        infItem[i] = clsInfo;
        ++i;
        goto J0x07;
    }
    skillNum = 0;
    return;
}

function LoadSkillConfig()
{
    local int i;
    local ItemInfo SkillInfo;
    local UserInfo UserInfo;
    local string param;

    if(!GetPlayerInfo(UserInfo))
    {
        return;
    }
    ClearAll();
    i = 0;
    J0x1F:
    if(i < 6)
    {
        SkillInfo.ClassID = 0;
        SkillInfo.Name = "";
        SkillInfo.Level = 1;
        param = GetOptionString("AutoSkill_" $ UserInfo.Name, "Skill_" $ string(i));
        ParseInt(param, "ID", SkillInfo.ClassID);
        if(ParseString(param, "icon", SkillInfo.IconName))
        {
            SkillInfo.Name = "Action";
            SkillInfo.ItemSubType = 3;            
        }
        else
        {
            SkillInfo.ItemSubType = 2;
            SkillInfo.IconName = Class'UIDATA_SKILL'.static.GetIconName(SkillInfo.ClassID, 1);
        }
        if(SkillInfo.ClassID <= 0)
        {
            goto J0x13A;
        }
        OnDropSkill(string(i), SkillInfo);
        J0x13A:
        i++;
        goto J0x1F;
    }
}

function SaveSkillConfig()
{
    local int i;
    local UserInfo UserInfo;

    if(!GetPlayerInfo(UserInfo))
    {
        return;
    }
    i = 0;
    J0x19:
    if(i < 6)
    {
        if(infItem[i].ItemSubType == 3)
        {
            SetINIString("AutoSkill_" $ UserInfo.Name, "Skill_" $ string(i), (("ID=" $ string(infItem[i].ClassID)) $ " icon=") $ infItem[i].IconName, "Option");
            goto J0xFD;
        }
        SetINIString("AutoSkill_" $ UserInfo.Name, "Skill_" $ string(i), "ID=" $ string(infItem[i].ClassID), "Option");
        J0xFD:
        ++i;
        goto J0x19;
    }
    RefreshINI("Option.ini");
}

function CustomTooltip SetTooltip(string Text)
{
    local CustomTooltip ToolTip;
    local DrawItemInfo Info;

    ToolTip.DrawList.Length = 1;
    Info.eType = DIT_TEXT;
    Info.t_strText = Text;
    ToolTip.DrawList[0] = Info;
    return ToolTip;
}
defaultproperties
{
}