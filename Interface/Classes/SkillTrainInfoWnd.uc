class SkillTrainInfoWnd extends UICommonAPI;

//////////////////////////////////////////////////////////////////////////////
// CONSTc
//////////////////////////////////////////////////////////////////////////////
const NORMAL_SKILL=0;		// �Ϲݽ�ų
const FISHING_SKILL=1;		// ���� ��ų
const CLAN_SKILL=2;		// ���ͽ�ų
const ENCHANT_SKILL=3;

const OFFSET_X_ICON_TEXTURE=0;
const OFFSET_Y_ICON_TEXTURE=4;
const OFFSET_Y_SECONDLINE = -14;

const OFFSET_Y_MPCONSUME=3;
const OFFSET_Y_CASTRANGE=0;
const OFFSET_Y_SP=120;

var int m_iType;
var int m_iID;
var int m_iLevel;

function OnLoad()
{
	RegisterEvent( EV_SkillTrainInfoWndShow );
	RegisterEvent( EV_SkillTrainInfoWndHide );
	RegisterEvent( EV_SkillTrainInfoWndAddExtendInfo );
}

function OnClickButton( string strBtnID )
{
	switch(strBtnID)
	{
	case "btnLearn" :
		OnLearn();
		break;
	case "btnGoBackList" :
		HideWindow("SkillTrainInfoWnd");
		ShowWindowWithFocus("SkillTrainListWnd");
		break;
	}
}

function OnLearn()
{
	switch(m_iType)
	{
	case NORMAL_SKILL :
	case FISHING_SKILL :
	case CLAN_SKILL :
		RequestAcquireSkill(m_iID, m_iLevel, m_iType);
		break;
	case ENCHANT_SKILL :
		RequestExEnchantSkill(m_iID, m_iLevel);
		break;
	}
}


function OnEvent(int Event_ID, string param)
{
	local int iType;

	local string strIconName;
	local string strName;
	local int iID;
	local int iLevel;
	local int iSPConsume;
	local INT64 iEXPConsume;

	local string strDescription;
	local string strOperateType;

	local int iMPConsume;
	local int iCastRange;
	local int iNumOfItem;

	local string strEnchantName;
	local string strEnchantDesc;

	local int iPercent;


	switch(Event_ID)
	{
	case EV_SkillTrainInfoWndShow :
		ParseInt(param, "Type", iType);
		ParseString(param, "strIconName", strIconName); 
		ParseString(param, "strName", strName);
		ParseInt(param, "iID", iID);
		ParseInt(param, "iLevel", iLevel);
		ParseString(param, "strOperateType", strOperateType);
		ParseInt(param, "iMPConsume", iMPConsume);
		ParseInt(param, "iCastRange", iCastRange);
		ParseInt(param, "iSPConsume", iSPConsume);
		ParseString(param, "strDescription", strDescription);
		ParseInt64(param, "iEXPConsume", iEXPConsume);
		ParseString(param, "strEnchantName", strEnchantName);
		ParseString(param, "strEnchantDesc", strEnchantDesc);
		ParseInt(param, "iPercent", iPercent);

		m_iType=iType;
		m_iID=iID;
		m_iLevel=iLevel;

		ShowSkillTrainInfoWnd();
		AddSkillTrainInfo(strIconName, strName, iID, iLevel, strOperateType, iMPConsume, iCastRange, strDescription, iSPConsume, iEXPConsume, strEnchantName, strEnchantDesc, iPercent);
		break;

	case EV_SkillTrainInfoWndAddExtendInfo :
		ParseString(param, "strIconName", strIconName); 
		ParseString(param, "strName", strName);
		ParseInt(param, "iNumOfItem", iNumOfItem);
		
		AddSkillTrainInfoExtend(strIconName, strName, iNumOfItem);
		ShowNeedItems();
		break;

	case EV_SkillTrainInfoWndHide :
		if(IsShowWindow("SkillTrainInfoWnd"))
			HideWindow("SkillTrainInfoWnd");
		break;
	}
}



// ��ų Ʈ���̴� ������ �ʱ�ȭ ��Ŵ
function ShowSkillTrainInfoWnd()
{
	local int iWindowTitle;
	local int iSPIdx;

	local UserInfo infoPlayer;
	local int iPlayerSP;
	local INT64 iPlayerEXP;
	local INT64 iLevelEXP;
	local INT64 iResultEXP;
	local string strEXP;

	GetPlayerInfo(infoPlayer);

	switch(m_iType)
	{
	case NORMAL_SKILL :
	case FISHING_SKILL :
	case ENCHANT_SKILL :
		iWindowTitle=477;
		iSPIdx=92;
		iPlayerSP=infoPlayer.nSP;
		iPlayerEXP=infoPlayer.nCurExp;
		break;
	case CLAN_SKILL :
		iWindowTitle=1436;
		iSPIdx=1372;
		iPlayerSP=GetClanNameValue(infoPlayer.nClanID);
		break;
	}

	class'UIAPI_WINDOW'.static.SetWindowTitle("SkillTrainInfoWnd", iWindowTitle);					// ���� Ÿ��Ʋ ����
	if(m_iType==ENCHANT_SKILL)
	{
		// ��� �ؽ��� �ٲ��ش�
		SetBackTex("L2UI_CH3.SkillTrainWnd.skillenchant_back");

		iLevelEXP=GetExpByPlayerLevel(infoPlayer.nLevel);
		iResultEXP=Int64SubtractBfromA(iPlayerEXP, iLevelEXP);
		strEXP=Int64ToString(iResultEXP);
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndEnchant.txtEXP", strEXP);	// EXP ��ġ
	}
	else
	{
		SetBackTex("L2UI_CH3.SkillTrainWnd.SkillTrain2");
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndNormal.txtSPString", GetSystemString(iSPIdx));	// SP or ���͸�ġ �۾�
	}
	class'UIAPI_TEXTBOX'.static.SetInt("SkillTrainInfoWnd.txtSP", iPlayerSP);						// SP or ���͸�ġ

	ShowWindowWithFocus("SkillTrainInfoWnd");
}

function AddSkillTrainInfo(string strIconName, string strName, int iID, int iLevel, string strOperateType, int iMPConsume, int iCastRange, string strDescription, int iSPConsume, INT64 iEXPConsume, string strEnchantName, string strEnchantDesc, int iPercent)
{
	local string strEXPConsume;

	// ������ ������
	class'UIAPI_TEXTURECTRL'.static.SetTexture("SkillTrainInfoWnd.texIcon", strIconName);
	// ��ų�̸�
	class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.txtName", strName);

	if(m_iType==ENCHANT_SKILL)
	{
		// ��æƮ �̸�
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndEnchant.txtEnchantName", strEnchantName);
		// ��æƮ ����
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndEnchant.txtDescription", strEnchantDesc);
		// ����Ȯ�� ����
		class'UIAPI_TEXTBOX'.static.Setint("SkillTrainInfoWnd.SubWndEnchant.txtProbabilityOfSuccess", iPercent); 
		// �ʿ�EXP ����
		strEXPConsume=Int64ToString(iEXPConsume);
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndEnchant.txtNeedEXP", strEXPConsume);
		// �ʿ�SP ����
		class'UIAPI_TEXTBOX'.static.SetInt("SkillTrainInfoWnd.SubWndEnchant.txtNeedSP", iSPConsume);

	}
	else
	{
		// level ����
		class'UIAPI_TEXTBOX'.static.SetInt("SkillTrainInfoWnd.txtLevel", iLevel);
		// �۵�Ÿ��
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.txtOperateType", strOperateType);
		// �Ҹ�MP
		class'UIAPI_TEXTBOX'.static.SetInt("SkillTrainInfoWnd.txtMP", iMPConsume);
		// ��ų���� 
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndNormal.txtDescription", strDescription);

		switch(m_iType)
		{
		case NORMAL_SKILL :			// �׳��� �ʿ�SP
		case FISHING_SKILL :
			class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndNormal.txtNeedSPString", GetSystemString(365));
			break;
		case CLAN_SKILL :			// ���ͽ�ų�϶��� �ʿ� ���͸�ġ
			class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndNormal.txtNeedSPString", GetSystemString(1437));
			break;
		}
		// �ʿ�SP ����
		class'UIAPI_TEXTBOX'.static.SetInt("SkillTrainInfoWnd.SubWndNormal.txtNeedSP", iSPConsume);
	}
	
	if(iCastRange>=0)
	{
		// �����ְ�
		ShowWindow("SkillTrainInfoWnd.txtCastRangeString");
		ShowWindow("SkillTrainInfoWnd.txtColoneCastRange");
		class'UIAPI_TEXTBOX'.static.SetInt("SkillTrainInfoWnd.txtCastRange", iCastRange);
	}
	else
	{
		// �����ش�
		HideWindow("SkillTrainInfoWnd.txtCastRangeString");
		HideWindow("SkillTrainInfoWnd.txtColoneCastRange");
		HideWindow("SkillTrainInfoWnd.txtCastRange");
	}
}

function AddSkillTrainInfoExtend(string strIconName, string strName, int iNumOfItem)
{
	if(m_iType==ENCHANT_SKILL)
	{
		// ������ ������
		class'UIAPI_TEXTURECTRL'.static.SetTexture("SkillTrainInfoWnd.SubWndEnchant.texNeedItemIcon", strIconName);
		// ��ų�̸�
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndEnchant.txtNeedItemName", strName$" X "$iNUmOfItem);
	}
	else
	{
		// ������ ������
		class'UIAPI_TEXTURECTRL'.static.SetTexture("SkillTrainInfoWnd.SubWndNormal.texNeedItemIcon", strIconName);
		// ��ų�̸�
		class'UIAPI_TEXTBOX'.static.SetText("SkillTrainInfoWnd.SubWndNormal.txtNeedItemName", strName$" X "$iNUmOfItem);
	}
}

function OnShow()
{
	switch(m_iType)
	{
	case NORMAL_SKILL :
	case FISHING_SKILL :
	case CLAN_SKILL :
		HideWindow("SkillTrainInfoWnd.SubWndEnchant");
		ShowWindow("SkillTrainInfoWnd.SubWndNormal");
		// �ʿ��� ������ ���� �����ش�
		HideWindow("SkillTrainInfoWnd.SubWndNormal.texNeedItemIcon");
		HideWindow("SkillTrainInfoWnd.SubWndNormal.txtNeedItemName");
		break;

	case ENCHANT_SKILL :
		HideWindow("SkillTrainInfoWnd.SubWndNormal");
		ShowWindow("SkillTrainInfoWnd.SubWndEnchant");
		// �ʿ��� ������ ���� �����ش�
		HideWindow("SkillTrainInfoWnd.SubWndEnchant.texNeedItemIcon");
		HideWindow("SkillTrainInfoWnd.SubWndEnchant.txtNeedItemName");
		break;
	}
}

function ShowNeedItems()
{
	// �����۾����ܰ� �̸�
	if(m_iType==ENCHANT_SKILL)
	{
		ShowWindow("SkillTrainInfoWnd.SubWndEnchant.texNeedItemIcon");
		ShowWindow("SkillTrainInfoWnd.SubWndEnchant.txtNeedItemName");
	}
	else
	{
		ShowWindow("SkillTrainInfoWnd.SubWndNormal.texNeedItemIcon");
		ShowWindow("SkillTrainInfoWnd.SubWndNormal.txtNeedItemName");
	}
}

function SetBackTex(string strFile)
{
	class'UIAPI_TEXTURECTRL'.static.SetTexture("SkillTrainInfoWnd.texBack", strFile);
}
defaultproperties
{
}
