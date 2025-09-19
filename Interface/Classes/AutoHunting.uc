class AutoHunting extends UICommonAPI;

var WindowHandle Me;

var ButtonHandle btnAutoHunting;
var ButtonHandle btnConfig;
var ButtonHandle btnPetHelp;
var ButtonHandle btnRadius;
var ButtonHandle btnPartyLeader;
var ButtonHandle btnLimitZone;
var ButtonHandle btnSkills;

var TextureHandle m_Tex4;
var TextureHandle m_TexAntiKS;
var AnimTextureHandle m_Tex3;

var bool cycleON;

var int cur_Target;
var int cur_Rspct;
var int cur_PartyLeader;
var int cur_LimitZone;

var AutoSkillWnd script_skill;

function OnLoad()
{  
    Me = GetHandle("AutoHunting");
	
    m_Tex3 = AnimTextureHandle(GetHandle("AutoHunting.Tex3"));
    m_Tex4 = TextureHandle(GetHandle("AutoHunting.Tex4"));
	
    btnConfig = ButtonHandle(GetHandle("AutoHunting.btnConfig"));
    btnConfig.SetTooltipCustomType(SetTooltip("Open Config"));
	
    btnAutoHunting = ButtonHandle(GetHandle("AutoHunting.btnAutoHunting"));
    btnAutoHunting.SetTooltipCustomType(SetTooltip(GetSystemString(1560)));
	
    btnSkills = ButtonHandle(GetHandle("AutoHunting.btnSkills"));
    btnSkills.SetTooltipCustomType(SetTooltip(GetSystemString(1559)));
	
    btnRadius = ButtonHandle(GetHandle("AutoHunting.btnRadius"));
    btnPetHelp = ButtonHandle(GetHandle("AutoHunting.btnPetHelp"));
	
	btnPartyLeader = ButtonHandle(GetHandle("AutoHunting.btnPartyLeader"));
	
	btnLimitZone = ButtonHandle(GetHandle("AutoHunting.btnLimitZone"));
	
	script_skill = AutoSkillWnd(GetScript("AutoSkillWnd"));
	
	SetToDefault();
	SetTargetButtonTooltip();
    SetRespectButtonTooltip();
	SetPartyLeaderButtonTooltip();
	SetLimitZoneButtonTooltip();
}

function SetToDefault()
{
    cycleON = false;
    script_skill.cycleON = false; 
    cur_Target = 0;   
    cur_Rspct = 0;
    cur_PartyLeader = 0;  
    cur_LimitZone = 0;
    m_Tex4.SetTexture("Hunt_UI.AutoHunting.FightOFF");
    btnAutoHunting.SetTexture("Hunt_UI.AutoHunting.AutoPlaySlotOff_BG", "Hunt_UI.AutoHunting.AutoPlaySlotOff_BG_Over", "Hunt_UI.AutoHunting.AutoPlaySlotOff_BG_Over");
    StopAnim(m_Tex3);
}

function OnDefaultPosition ()
{
	class'UIAPI_WINDOW'.static.SetAnchor( "AutoHunting","", "TopCenter", "TopCenter", 0, -150 );
}

function OnTimer(int TimerID)
{
	
}

function OnClickButton(string strID)
{
    switch(strID)
    {
        case "btnAutoHunting":     
            if(cycleON)
            {
                StopAll(); 
            }   
            else
            {
                StartAll();
            }    
        break;
			
        case "btnPetHelp": 
            OnRespectButton();
        break;
			
        case "btnRadius":
            OnTargetButton();
        break;
			
        case "btnConfig":
            ExecuteCommand(".playmonster 1");
        break;
		
        case "btnPartyLeader":
			OnPartyLeaderButton();			
        break;
		
        case "btnLimitZone":
            OnLimitZoneButton();			
        break;
		
        case "btnDrawer":
            HandleDrawer();
        break;
		
        case "btnSkills":
			ToggleOpenAutoSkillWnd();
        break;
		
    }
}

function ToggleOpenAutoSkillWnd()
{
	if(IsShowWindow("AutoSkillWnd"))
	{
		HideWindow("AutoSkillWnd");
	}
	else
	{
		ShowWindowWithFocus("AutoSkillWnd");		
	}
}

function HandleDrawer()
{
    if(IsShowWindow("AutoHunting.DrawerButtons"))
    {
        ButtonHandle(GetHandle("AutoHunting.btnDrawer")).SetTexture("Hunt_UI.AutoHunting.WinExpandButton", "Hunt_UI.AutoHunting.WinExpandButton_down", "Hunt_UI.AutoHunting.WinExpandButton_over");
        HideWindow("AutoHunting.DrawerButtons");    
        HideWindow("AutoSkillWnd");		
    }
    else
    {
        ButtonHandle(GetHandle("AutoHunting.btnDrawer")).SetTexture("Hunt_UI.AutoHunting.WinMinButton", "Hunt_UI.AutoHunting.WinMinButton_down", "Hunt_UI.AutoHunting.WinMinButton_over");
        ShowWindow("AutoHunting.DrawerButtons");
    }
}

function StartAll()
{
    RequestBypassToServer("farm on"); 
    StartAnim(m_Tex3);
    cycleON = true;
    script_skill.cycleON = true;
	script_skill.SkillStart();	
    m_Tex4.SetTexture("Hunt_UI.AutoHunting.FightON");
    btnAutoHunting.SetTexture("Hunt_UI.AutoHunting.AutoPlaySlotOn_BG", "Hunt_UI.AutoHunting.AutoPlaySlotOn_BG_Over", "Hunt_UI.AutoHunting.AutoPlaySlotOn_BG_Over");
}

function StopAll()
{  
    RequestBypassToServer("farm off"); 
    StopAnim(m_Tex3);
    cycleON = false;
    script_skill.cycleON = false;
	script_skill.SkillStop();	
    m_Tex4.SetTexture("Hunt_UI.AutoHunting.FightOFF");
    btnAutoHunting.SetTexture("Hunt_UI.AutoHunting.AutoPlaySlotOff_BG", "Hunt_UI.AutoHunting.AutoPlaySlotOff_BG_Over", "Hunt_UI.AutoHunting.AutoPlaySlotOff_BG_Over");
}

function StartAnim(AnimTextureHandle Handle)
{
    Handle.ShowWindow();
    Handle.Stop();
    Handle.SetLoopCount(-1);
    Handle.Play();
}

function StopAnim(AnimTextureHandle Handle)
{
    Handle.HideWindow();
    Handle.Stop();
}

function OnTargetButton()
{
    cur_Target = cur_Target + 1;
    if(cur_Target > 1)
    {
        cur_Target = 0;
    }
    SetTargetButtonTooltip();
    UpdateTarget();
}

function SetTargetButtonTooltip()
{  
	switch (cur_Target)
	{
        case 0:
            TooltipTarget();
        break;
            
        case 1:
            TooltipTarget();
        break;
	}
}

function UpdateTarget()
{
    if(cur_Target == 1)
    {
        TargetRangeLong();
    }
    else if(cur_Target == 0)
    {
        TargetRangeShort();
    }
}

function TargetRangeLong()
{ 
	RequestBypassToServer("farm inc_radius");
    Class'UIAPI_TEXTLISTBOX'.static.AddString("SystemMsgWnd.SystemMsgList", GetSystemString(1557), GetColor(176, 155, 121, 255));
}

function TargetRangeShort()
{
	RequestBypassToServer("farm dec_radius");
    Class'UIAPI_TEXTLISTBOX'.static.AddString("SystemMsgWnd.SystemMsgList", GetSystemString(1558), GetColor(176, 155, 121, 255));
}
    
function TooltipTarget()
{
  local CustomTooltip TooltipInfo;

    if(cur_Target == 0)
    {
        TooltipInfo.DrawList.Length = 4;
        TooltipInfo.DrawList[0].eType = DIT_TEXT;
        TooltipInfo.DrawList[0].nOffSetX = 1;
        TooltipInfo.DrawList[0].t_bDrawOneLine = true;
        TooltipInfo.DrawList[0].t_color.R = 128;
        TooltipInfo.DrawList[0].t_color.G = 128;
        TooltipInfo.DrawList[0].t_color.B = 128;
        TooltipInfo.DrawList[0].t_color.A = byte(255);
        TooltipInfo.DrawList[0].t_strText = GetSystemString(1557);
        TooltipInfo.DrawList[1].eType = DIT_TEXT;
        TooltipInfo.DrawList[1].nOffSetY = 2;
        TooltipInfo.DrawList[1].nOffSetX = 1;
        TooltipInfo.DrawList[1].t_bDrawOneLine = true;
        TooltipInfo.DrawList[1].t_color.R = byte(255);
        TooltipInfo.DrawList[1].t_color.G = 200;
        TooltipInfo.DrawList[1].t_color.B = 0;
        TooltipInfo.DrawList[1].t_color.A = byte(255);
        TooltipInfo.DrawList[1].t_strText = GetSystemString(1558);
        TooltipInfo.DrawList[1].bLineBreak = true;
        btnRadius.SetTexture("Hunt_UI.AutoHuntingWnd.TargetBTN_ShotD_Normal", "Hunt_UI.AutoHuntingWnd.TargetBTN_ShotD_Normal", "Hunt_UI.AutoHuntingWnd.TargetBTN_ShotD_Over");
        btnRadius.SetTooltipCustomType(TooltipInfo);
    }
    else
    {
        TooltipInfo.DrawList.Length = 4;
        TooltipInfo.DrawList[0].eType = DIT_TEXT;
        TooltipInfo.DrawList[0].nOffSetX = 1;
        TooltipInfo.DrawList[0].t_bDrawOneLine = true;
        TooltipInfo.DrawList[0].t_color.R = byte(255);
        TooltipInfo.DrawList[0].t_color.G = 200;
        TooltipInfo.DrawList[0].t_color.B = 0;
        TooltipInfo.DrawList[0].t_color.A = byte(255);
        TooltipInfo.DrawList[0].t_strText = GetSystemString(1557);
        TooltipInfo.DrawList[1].eType = DIT_TEXT;
        TooltipInfo.DrawList[1].nOffSetY = 2;
        TooltipInfo.DrawList[1].nOffSetX = 1;
        TooltipInfo.DrawList[1].t_bDrawOneLine = true;
        TooltipInfo.DrawList[1].t_color.R = 128;
        TooltipInfo.DrawList[1].t_color.G = 128;
        TooltipInfo.DrawList[1].t_color.B = 128;
        TooltipInfo.DrawList[1].t_color.A = byte(255);
        TooltipInfo.DrawList[1].t_strText = GetSystemString(1558);
        TooltipInfo.DrawList[1].bLineBreak = true;
        btnRadius.SetTexture("Hunt_UI.AutoHuntingWnd.TargetBTN_LongD_Normal", "Hunt_UI.AutoHuntingWnd.TargetBTN_LongD_Normal", "Hunt_UI.AutoHuntingWnd.TargetBTN_LongD_Over");
        btnRadius.SetTooltipCustomType(TooltipInfo);
    }
}

function OnRespectButton()
{
    cur_Rspct = cur_Rspct + 1;
    if(cur_Rspct > 1)
    {
        cur_Rspct = 0;
    }
    SetRespectButtonTooltip();
    UpdateRespect();
}

function SetRespectButtonTooltip()
{  
	switch (cur_Rspct)
	{
        case 0:
            TooltipRespect();
        break;
            
        case 1:
            TooltipRespect();
        break;
	}
}

function UpdateRespect()
{
    if(cur_Rspct == 1)
    {
        KSModeON();
    }
    else if(cur_Rspct == 0)
    {
        KSModeOFF();
    }
}

function KSModeON()
{ 
    RequestBypassToServer("farm respect"); 
    Class'UIAPI_TEXTLISTBOX'.static.AddString("SystemMsgWnd.SystemMsgList", GetSystemString(1553), GetColor(176, 155, 121, 255));
}

function KSModeOFF()
{
    RequestBypassToServer("farm desrespect");    
    Class'UIAPI_TEXTLISTBOX'.static.AddString("SystemMsgWnd.SystemMsgList", GetSystemString(1554), GetColor(176, 155, 121, 255));
}

function TooltipRespect()
{
  local CustomTooltip TooltipInfo;

    if(cur_Rspct == 0)
    {
        TooltipInfo.DrawList.Length = 4;
        TooltipInfo.DrawList[0].eType = DIT_TEXT;
        TooltipInfo.DrawList[0].nOffSetX = 1;
        TooltipInfo.DrawList[0].t_bDrawOneLine = true;
        TooltipInfo.DrawList[0].t_color.R = 128;
        TooltipInfo.DrawList[0].t_color.G = 128;
        TooltipInfo.DrawList[0].t_color.B = 128;
        TooltipInfo.DrawList[0].t_color.A = byte(255);
        TooltipInfo.DrawList[0].t_strText = GetSystemString(1553);
        TooltipInfo.DrawList[1].eType = DIT_TEXT;
        TooltipInfo.DrawList[1].nOffSetY = 2;
        TooltipInfo.DrawList[1].nOffSetX = 1;
        TooltipInfo.DrawList[1].t_bDrawOneLine = true;
        TooltipInfo.DrawList[1].t_color.R = byte(255);
        TooltipInfo.DrawList[1].t_color.G = 200;
        TooltipInfo.DrawList[1].t_color.B = 0;
        TooltipInfo.DrawList[1].t_color.A = byte(255);
        TooltipInfo.DrawList[1].t_strText = GetSystemString(1554);
        TooltipInfo.DrawList[1].bLineBreak = true;
        btnPetHelp.SetTexture("Hunt_UI.AutoHunting.MannerBTNOFF_Normal", "Hunt_UI.AutoHunting.MannerBTNOFF_Normal", "Hunt_UI.AutoHunting.MannerBTNOFF_Over");
        btnPetHelp.SetTooltipCustomType(TooltipInfo);    
    }
    else
    {
        TooltipInfo.DrawList.Length = 4;
        TooltipInfo.DrawList[0].eType = DIT_TEXT;
        TooltipInfo.DrawList[0].nOffSetX = 1;
        TooltipInfo.DrawList[0].t_bDrawOneLine = true;
        TooltipInfo.DrawList[0].t_color.R = byte(255);
        TooltipInfo.DrawList[0].t_color.G = 200;
        TooltipInfo.DrawList[0].t_color.B = 0;
        TooltipInfo.DrawList[0].t_color.A = byte(255);
        TooltipInfo.DrawList[0].t_strText = GetSystemString(1553);
        TooltipInfo.DrawList[1].eType = DIT_TEXT;
        TooltipInfo.DrawList[1].nOffSetY = 2;
        TooltipInfo.DrawList[1].nOffSetX = 1;
        TooltipInfo.DrawList[1].t_bDrawOneLine = true;
        TooltipInfo.DrawList[1].t_color.R = 128;
        TooltipInfo.DrawList[1].t_color.G = 128;
        TooltipInfo.DrawList[1].t_color.B = 128;
        TooltipInfo.DrawList[1].t_color.A = byte(255);
        TooltipInfo.DrawList[1].t_strText = GetSystemString(1554);
        TooltipInfo.DrawList[1].bLineBreak = true;
        btnPetHelp.SetTexture("Hunt_UI.AutoHunting.MannerBTNON_Normal", "Hunt_UI.AutoHunting.MannerBTNON_Normal", "Hunt_UI.AutoHunting.MannerBTNON_Over");
        btnPetHelp.SetTooltipCustomType(TooltipInfo);
    }
}  
function OnPartyLeaderButton()
{
    cur_PartyLeader = cur_PartyLeader + 1;
    if(cur_PartyLeader > 1)
    {
        cur_PartyLeader = 0;
    }
    SetPartyLeaderButtonTooltip();
    UpdatePartyLeader();
}

function SetPartyLeaderButtonTooltip()
{  
	switch (cur_PartyLeader)
	{
        case 0:
            TooltipPartyLeader();
        break;
            
        case 1:
            TooltipPartyLeader();
        break;
	}
}

function UpdatePartyLeader()
{
    if(cur_PartyLeader == 1)
    {
        PartyLeaderON();
    }
    else if(cur_PartyLeader == 0)
    {
        PartyLeaderOFF();
    }
}

function PartyLeaderON()
{ 
    RequestBypassToServer("farm assist"); 
    Class'UIAPI_TEXTLISTBOX'.static.AddString("SystemMsgWnd.SystemMsgList", GetSystemString(1555), GetColor(176, 155, 121, 255));
}

function PartyLeaderOFF()
{
    RequestBypassToServer("farm deassist");    
    Class'UIAPI_TEXTLISTBOX'.static.AddString("SystemMsgWnd.SystemMsgList", GetSystemString(1556), GetColor(176, 155, 121, 255));
}

function TooltipPartyLeader()
{
  local CustomTooltip TooltipInfo;

    if(cur_PartyLeader == 0)
    {
        TooltipInfo.DrawList.Length = 4;
        TooltipInfo.DrawList[0].eType = DIT_TEXT;
        TooltipInfo.DrawList[0].nOffSetX = 1;
        TooltipInfo.DrawList[0].t_bDrawOneLine = true;
        TooltipInfo.DrawList[0].t_color.R = 128;
        TooltipInfo.DrawList[0].t_color.G = 128;
        TooltipInfo.DrawList[0].t_color.B = 128;
        TooltipInfo.DrawList[0].t_color.A = byte(255);
        TooltipInfo.DrawList[0].t_strText = GetSystemString(1555);
        TooltipInfo.DrawList[1].eType = DIT_TEXT;
        TooltipInfo.DrawList[1].nOffSetY = 2;
        TooltipInfo.DrawList[1].nOffSetX = 1;
        TooltipInfo.DrawList[1].t_bDrawOneLine = true;
        TooltipInfo.DrawList[1].t_color.R = byte(255);
        TooltipInfo.DrawList[1].t_color.G = 200;
        TooltipInfo.DrawList[1].t_color.B = 0;
        TooltipInfo.DrawList[1].t_color.A = byte(255);
        TooltipInfo.DrawList[1].t_strText = GetSystemString(1556);
        TooltipInfo.DrawList[1].bLineBreak = true;

        btnPartyLeader.SetTexture("Hunt_UI.AutoHunting.AreaBTNOFF_Normal", "Hunt_UI.AutoHunting.AreaBTNOFF_Normal", "Hunt_UI.AutoHunting.AreaBTNOFF_Normal");
        btnPartyLeader.SetTooltipCustomType(TooltipInfo);    
    }
    else
    {
        TooltipInfo.DrawList.Length = 4;
        TooltipInfo.DrawList[0].eType = DIT_TEXT;
        TooltipInfo.DrawList[0].nOffSetX = 1;
        TooltipInfo.DrawList[0].t_bDrawOneLine = true;
        TooltipInfo.DrawList[0].t_color.R = byte(255);
        TooltipInfo.DrawList[0].t_color.G = 200;
        TooltipInfo.DrawList[0].t_color.B = 0;
        TooltipInfo.DrawList[0].t_color.A = byte(255);
        TooltipInfo.DrawList[0].t_strText = GetSystemString(1555);
        TooltipInfo.DrawList[1].eType = DIT_TEXT;
        TooltipInfo.DrawList[1].nOffSetY = 2;
        TooltipInfo.DrawList[1].nOffSetX = 1;
        TooltipInfo.DrawList[1].t_bDrawOneLine = true;
        TooltipInfo.DrawList[1].t_color.R = 128;
        TooltipInfo.DrawList[1].t_color.G = 128;
        TooltipInfo.DrawList[1].t_color.B = 128;
        TooltipInfo.DrawList[1].t_color.A = byte(255);
        TooltipInfo.DrawList[1].t_strText = GetSystemString(1556);
        TooltipInfo.DrawList[1].bLineBreak = true;

        btnPartyLeader.SetTexture("Hunt_UI.AutoHunting.AreaBTNON_Normal", "Hunt_UI.AutoHunting.AreaBTNON_Normal", "Hunt_UI.AutoHunting.AreaBTNON_Normal");
        btnPartyLeader.SetTooltipCustomType(TooltipInfo);
    }
}  
function OnLimitZoneButton()
{
    cur_LimitZone = cur_LimitZone + 1;
    if(cur_LimitZone > 1)
    {
        cur_LimitZone = 0;
    }
    SetLimitZoneButtonTooltip();
    UpdateLimitZone();
}

function SetLimitZoneButtonTooltip()
{  
	switch (cur_LimitZone)
	{
        case 0:
            TooltipLimitZone();
        break;
            
        case 1:
            TooltipLimitZone();
        break;
	}
}

function UpdateLimitZone()
{
    if(cur_LimitZone == 1)
    {
        LimitZoneON();
    }
    else if(cur_LimitZone == 0)
    {
        LimitZoneOFF();
    }
}

function LimitZoneON()
{ 
    RequestBypassToServer("farm inc_viewer"); 
    Class'UIAPI_TEXTLISTBOX'.static.AddString("SystemMsgWnd.SystemMsgList", GetSystemString(1561), GetColor(176, 155, 121, 255));
}

function LimitZoneOFF()
{
    RequestBypassToServer("farm dec_viewer");    
    Class'UIAPI_TEXTLISTBOX'.static.AddString("SystemMsgWnd.SystemMsgList", GetSystemString(1562), GetColor(176, 155, 121, 255));
}

function TooltipLimitZone()
{
  	local CustomTooltip TooltipInfo;

    if(cur_LimitZone == 0)
    {
        TooltipInfo.DrawList.Length = 4;
        TooltipInfo.DrawList[0].eType = DIT_TEXT;
        TooltipInfo.DrawList[0].nOffSetX = 1;
        TooltipInfo.DrawList[0].t_bDrawOneLine = true;
        TooltipInfo.DrawList[0].t_color.R = 128;
        TooltipInfo.DrawList[0].t_color.G = 128;
        TooltipInfo.DrawList[0].t_color.B = 128;
        TooltipInfo.DrawList[0].t_color.A = byte(255);
        TooltipInfo.DrawList[0].t_strText = GetSystemString(1561);
        TooltipInfo.DrawList[1].eType = DIT_TEXT;
        TooltipInfo.DrawList[1].nOffSetY = 2;
        TooltipInfo.DrawList[1].nOffSetX = 1;
        TooltipInfo.DrawList[1].t_bDrawOneLine = true;
        TooltipInfo.DrawList[1].t_color.R = byte(255);
        TooltipInfo.DrawList[1].t_color.G = 200;
        TooltipInfo.DrawList[1].t_color.B = 0;
        TooltipInfo.DrawList[1].t_color.A = byte(255);
        TooltipInfo.DrawList[1].t_strText = GetSystemString(1562);
        TooltipInfo.DrawList[1].bLineBreak = true;

        btnLimitZone.SetTexture("Hunt_UI.AutoHunting.fixedbtn_shotd_normaloff", "Hunt_UI.AutoHunting.fixedbtn_shotd_normaloff", "Hunt_UI.AutoHunting.fixedbtn_shotd_normaloff");
        btnLimitZone.SetTooltipCustomType(TooltipInfo);    
    }
    else
    {
        TooltipInfo.DrawList.Length = 4;
        TooltipInfo.DrawList[0].eType = DIT_TEXT;
        TooltipInfo.DrawList[0].nOffSetX = 1;
        TooltipInfo.DrawList[0].t_bDrawOneLine = true;
        TooltipInfo.DrawList[0].t_color.R = byte(255);
        TooltipInfo.DrawList[0].t_color.G = 200;
        TooltipInfo.DrawList[0].t_color.B = 0;
        TooltipInfo.DrawList[0].t_color.A = byte(255);
        TooltipInfo.DrawList[0].t_strText = GetSystemString(1561);
        TooltipInfo.DrawList[1].eType = DIT_TEXT;
        TooltipInfo.DrawList[1].nOffSetY = 2;
        TooltipInfo.DrawList[1].nOffSetX = 1;
        TooltipInfo.DrawList[1].t_bDrawOneLine = true;
        TooltipInfo.DrawList[1].t_color.R = 128;
        TooltipInfo.DrawList[1].t_color.G = 128;
        TooltipInfo.DrawList[1].t_color.B = 128;
        TooltipInfo.DrawList[1].t_color.A = byte(255);
        TooltipInfo.DrawList[1].t_strText = GetSystemString(1562);
        TooltipInfo.DrawList[1].bLineBreak = true;

        btnLimitZone.SetTexture("Hunt_UI.AutoHunting.fixedbtn_shotd_normalon", "Hunt_UI.AutoHunting.fixedbtn_shotd_normalon", "Hunt_UI.AutoHunting.fixedbtn_shotd_normalon");
        btnLimitZone.SetTooltipCustomType(TooltipInfo);
    }
}  

function Color GetColor(int R, int G, int B, int A)
{
	local Color tColor;

	tColor.R = R;
	tColor.G = G;
	tColor.B = B;
	tColor.A = A;
	return tColor;
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
