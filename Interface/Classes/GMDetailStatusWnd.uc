class GMDetailStatusWnd extends DetailStatusWnd;

var bool bShow;	// GM창에서 버튼을 한번 더 누르면 사라지게 하기 위한 변수
var UserInfo m_ObservingUserInfo;

function OnLoad()
{
	RegisterEvent( EV_GMObservingUserInfoUpdate );
	RegisterEvent( EV_GMUpdateHennaInfo );
	
	bShow = false;	//초기화	
}

function OnShow()
{
}

function OnHide()
{
}

function ShowStatus( String a_Param )
{
	if( a_Param == "" )
		return;

	if(bShow)	//창이 떠있으면 지워준다.
	{
		m_hOwnerWnd.HideWindow();
		bShow = false;
	}
	else	
	{
		class'GMAPI'.static.RequestGMCommand( GMCOMMAND_StatusInfo, a_Param );
		bShow = true;
	}
}

function OnEvent( int a_EventID, String a_Param )
{
	switch( a_EventID )
	{
	case EV_GMObservingUserInfoUpdate:
		if( HandleGMObservingUserInfoUpdate() )
		{
			m_hOwnerWnd.ShowWindow();
			m_hOwnerWnd.SetFocus();
		}
		break;
	case EV_GMUpdateHennaInfo:
		HandleGMUpdateHennaInfo( a_Param );
		break;
	}
}

function bool HandleGMObservingUserInfoUpdate()
{
	local UserInfo ObservingUserInfo;

	if( class'GMAPI'.static.GetObservingUserInfo( ObservingUserInfo ) )
	{
		HandleUpdateUserInfo();
		return true;
	}
	else
		return false;
}

function HandleGMUpdateHennaInfo( String a_Param )
{
	HandleUpdateHennaInfo( a_Param );
	HandleGMObservingUserInfoUpdate();
}

function bool GetMyUserInfo( out UserInfo a_MyUserInfo )
{
	local bool Result;

	Result = class'GMAPI'.static.GetObservingUserInfo( m_ObservingUserInfo );

	if( Result )
	{
		a_MyUserInfo = m_ObservingUserInfo;
		return true;
	}
	else
		return false;
}

function String GetMovingSpeed( UserInfo a_UserInfo )
{
	local int MovingSpeed;
	local EMoveType	MoveType;
	local EEnvType	EnvType;

	// Moving Speed
	MoveType			= class'UIDATA_PLAYER'.static.GetPlayerMoveType();
	EnvType				= class'UIDATA_PLAYER'.static.GetPlayerEnvironment();

	if (MoveType == MVT_FAST)
	{
		MovingSpeed = a_UserInfo.nGroundMaxSpeed * a_UserInfo.fNonAttackSpeedModifier;
		switch (EnvType)
		{
		case ET_UNDERWATER:
			MovingSpeed = a_UserInfo.nWaterMaxSpeed * a_UserInfo.fNonAttackSpeedModifier;
			break;
		case ET_AIR:
			MovingSpeed = a_UserInfo.nAirMaxSpeed * a_UserInfo.fNonAttackSpeedModifier;
			break;
		}
	}
	else if (MoveType == MVT_SLOW)
	{
		MovingSpeed = a_UserInfo.nGroundMinSpeed * a_UserInfo.fNonAttackSpeedModifier;
		switch (EnvType)
		{
		case ET_UNDERWATER:
			MovingSpeed = a_UserInfo.nWaterMinSpeed * a_UserInfo.fNonAttackSpeedModifier;
			break;
		case ET_AIR:
			MovingSpeed = a_UserInfo.nAirMinSpeed * a_UserInfo.fNonAttackSpeedModifier;
			break;
		}
	}

	return String( MovingSpeed );
}

function float GetMyExpRate()
{
	return GetExpRate( m_ObservingUserInfo.nCurExp, m_ObservingUserInfo.nLevel ) * 100.f;
}

defaultproperties
{
    m_WindowName="GMDetailStatusWnd.InnerWnd"
}
