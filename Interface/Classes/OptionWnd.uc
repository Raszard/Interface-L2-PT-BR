class OptionWnd extends UIScript;

/* �ɼ� ��Ʈ�� �̸�

[�����ɼ�]

�ػ�		ResBox
�ֻ���		RefreshRateBox
������		GammaBox
�ؽ��ĵ�����	TextureBox
�𵨸�������	ModelBox
��ǵ�����	AnimBox
�þ�-����	TerrainBox
�þ�-ĳ����	CharBox
ĳ����ǥ������	PawnBox
�ּ�����������	FrameBox - checkbox
�ݻ�ȿ��		ReflectBox
��Ƽ�˸��ƽ�	AABox
�׸���		ShadowBox - checkbox
���ȿ��		DecoBox - checkbox
�ؽ������͸�	TriBox -checkbox
��ũ���� ǰ��	CaptureBox
ȭ���������̴�	HDRBox

///////////////////////////////////////////
// Added on 2006/03/21 by NeverDie

���ȿ�� - WeatherEffectComboBox
GPU�ִϸ��̼� -	GPUAnimationCheckBox

[������ɼ�]

ȿ��������	EffectBox
���Ǻ���		MusicBox
�ý�������	SystemBox
Ʃ�丮������	TutorialBox

[���ӿɼ�]

�������̽��ʱ�ȭ��ư	WindowInitBtn
����ȭ			OpacityBox
����			LanguageBox - combobox
�ڽ��̸�			NameBox0
�����̸�		NameBox1
�ٸ�PC�̸�		NameBox2
�����̸�			NameBox3
��Ƽ�̸�			NameBox4
�Ϲ��̸�			NameBox5
����ü��			EnterChatBox
ä�ñ�ȣ			OldChatBox
Ű���庸��		KeyboardBox
�����е�			JoypadBox
ī�޶�����		CameraBox
�׷���Ŀ��		CursorBox
3Dȭ��ǥ		ArrowBox
������ǥ��		ZoneNameBox
�ý��۸޽�������â	SystemMsgBox
������			DamageBox
�Ҹ𼺾����ۻ��		ItemBox
��Ƽ����			LootingBox - combobox

*/

var int nPixelShaderVersion;
var int nVertexShaderVersion;
var float gSoundVolume;
var float gMusicVolume;
var float gWavVoiceVolume;
var float gOggVoiceVolume;
var Array<ResolutionInfo> ResolutionList;
var Array<int> RefreshRateList;
var bool bShow;

// ��� �ϸ� �ǵ����� ���ؼ� ���� ���� ����ϰ� ���� ���� - lancelot 2006. 6. 13.
var int m_iPrevSoundTick;
var int m_iPrevMusicTick;
var int m_iPrevSystemTick;
var int m_iPrevTutorialTick;

// ��Ƽ��Ī�濡 ������ �����ΰ�?	2006.10.19 ttmayrin
var bool m_bPartyMatchRoomState;

function ResetRefreshRate( optional int a_nWidth, optional int a_nHeight )
{
	local int i;

	GetRefreshRateList( RefreshRateList, a_nWidth, a_nHeight );
	//debug( "RefreshRateList.Length " $ RefreshRateList.Length );
	class'UIAPI_COMBOBOX'.static.Clear( "OptionWnd.RefreshRateBox" );
	for( i = 0; i < RefreshRateList.Length; ++i )
	{
		debug( "RefreshRateList[ i ] " $ RefreshRateList[ i ] );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.RefreshRateBox", RefreshRateList[ i ] $ "Hz" );
	}
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.RefreshRateBox", i - 1 );
}

function OnLoad()
{
	local int i;
	local int nMultiSample;
	local bool bEnableEngSelection;
	local ELanguageType Language;
	local string strResolution;

	RegisterEvent( EV_MinFrameRateChanged );
	RegisterEvent( EV_PartyMemberChanged );
	RegisterEvent( EV_PartyMatchRoomStart );
	RegisterEvent( EV_PartyMatchRoomClose );

	// 2006/03/26 - added register state by NeverDie. multi-registering states can only be placed in uc...
	RegisterState( "OptionWnd", "GamingState" );
	RegisterState( "OptionWnd", "LoginState" );

	// Shader version
	GetShaderVersion( nPixelShaderVersion, nVertexShaderVersion );

	GetResolutionList( ResolutionList );
	
	SetOptionBool( "Game", "HideDropItem", false );
	
	for( i = 0; i < ResolutionList.Length; ++i )
	{
		strResolution = "" $ ResolutionList[ i ].nWidth $ "*" $ ResolutionList[ i ].nHeight $ " " $ ResolutionList[ i ].nColorBit $ "bit";
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.ResBox", strResolution );
	}

	ResetRefreshRate();
	/*
	GetRefreshRateList( RefreshRateList );
	class'UIAPI_COMBOBOX'.static.Clear( "OptionWnd.RefreshRateBox" );
	for( i = 0; i < RefreshRateList.Length; ++i )
	{
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.RefreshRateBox", RefreshRateList[ i ] $ "Hz" );
	}
	*/

	nMultiSample = GetMultiSample();
	if( 0 == nMultiSample )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 869 );
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.AABox" );
	}
	else if( 1 == nMultiSample )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 869 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 870 );
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.AABox" );
	}
	else if( 2 == nMultiSample )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 869 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 870 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.AABox", 871 );
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.AABox" );
	}

	bEnableEngSelection = IsEnableEngSelection();
	Language = GetLanguage();
	switch( Language )
	{
	case LANG_None:
		break;
	case LANG_Korean:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Korean" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_English:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		break;
	case LANG_Japanese:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Japanese" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_Taiwan:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Chinese(Taiwan)" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_Chinese:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "China" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_Thai:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "Thai" );
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		if( bEnableEngSelection )
			class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.LanguageBox" );
		else
			class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.LanguageBox" );
		break;
	case LANG_Philippine:
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.LanguageBox", "English" );
		break;
	default:
		break;
	}

	if( CanUseHDR() )
	{
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.HDRBox", 1230 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.HDRBox", 1231 );
		class'UIAPI_COMBOBOX'.static.SYS_AddString( "OptionWnd.HDRBox", 1232 );
	}

	InitVideoOption();
	InitAudioOption();
	InitGameOption();

	bShow = false;
}

function RefreshLootingBox()
{
	if( GetPartyMemberCount() > 0 || m_bPartyMatchRoomState )
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.LootingBox" );
	else
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.LootingBox" );
}

function InitVideoOption()
{
	local int i;
	local int nResolutionIndex;
	local float fGamma;
	//local float fPawnClippingRange;
	//local float fTerrainClippingRange;
	local bool bRenderDeco;
	local int nPostProcessType;
	local bool bShadow;
	local int nTextureDetail;
	local int nModelDetail;
	local int nSkipAnim;
	local bool bWaterEffect;
	local int nWaterEffectType;
	local int nRenderActorLimit;
	local int nMultiSample;
	local int nOption;
	local bool bOption;

	// �ػ� - ResBox
	nResolutionIndex = GetResolutionIndex();
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ResBox", nResolutionIndex );

	// �ֻ��� - RefreshRateBox
	GetRefreshRateList( RefreshRateList );
	class'UIAPI_COMBOBOX'.static.Clear( "OptionWnd.RefreshRateBox" );
	for( i = 0; i < RefreshRateList.Length; ++i )
	{
		class'UIAPI_COMBOBOX'.static.AddString( "OptionWnd.RefreshRateBox", RefreshRateList[ i ] $ "Hz" );
	}
	nOption = GetOptionInt( "Video", "RefreshRate" );
	for( i = 0; i < RefreshRateList.Length; ++i )
	{
		debug( "RefreshRateList[ " $ i $ " ] = " $ RefreshRateList[ i ] );
		if( RefreshRateList[ i ] == nOption )
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.RefreshRateBox", i );
	}

	// ������ - GammaBox
	fGamma = GetOptionFloat( "Video", "Gamma" );
	if( 1.2f <= fGamma )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 0 );
	else if( 1.0f <= fGamma && fGamma < 1.2f )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 1 );
	else if( 0.8f <= fGamma && fGamma < 1.0f )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 2 );
	else if( 0.6f <= fGamma && fGamma < 0.8f )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 3 );
	else if( fGamma < 0.6f )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.GammaBox", 4 );

	// �þ�-ĳ���� - CharBox
	nOption = GetOptionInt( "Video", "PawnClippingRange" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.CharBox", nOption );

	// �þ�-���� - TerrainBox
	nOption = GetOptionInt( "Video", "TerrainClippingRange" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.TerrainBox", nOption );

	// ���ȿ�� - DecoBox
	bRenderDeco = GetOptionBool( "Video", "RenderDeco" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.DecoBox", bRenderDeco );

	// ȭ���������̴� - HDRBox
	nPostProcessType = GetOptionInt( "Video", "PostProc" );
	if( 0 <= nPostProcessType && nPostProcessType <= 5 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.HDRBox", nPostProcessType );
	else
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.HDRBox", 0 );

	// �׸��� - ShadowBox
	bShadow = GetOptionBool( "Video", "PawnShadow" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ShadowBox", bShadow );

	// �ؽ��ĵ����� - TextureBox
	nTextureDetail = GetOptionInt( "Video", "TextureDetail" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.TextureBox", Max( 0, Min( 2, nTextureDetail ) ) );

	// �𵨸������� - ModelBox
	nModelDetail = GetOptionInt( "Video", "ModelDetail" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ModelBox", nModelDetail );

	// ��ǵ����� - AnimBox
	nSkipAnim = GetOptionInt( "Video", "SkipAnim" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.AnimBox", nSkipAnim );

	// �ݻ�ȿ�� - ReflectBox
	if( nPixelShaderVersion < 12 )
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
	}
	else
	{
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );

		bWaterEffect = GetOptionBool( "L2WaterEffect", "IsUseEffect" );
		nWaterEffectType = GetOptionInt( "L2WaterEffect", "EffectType" );
		if( !bWaterEffect )
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
		else if( nWaterEffectType == 1 )
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 1 );
		else if ( nWaterEffectType == 2 )
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 2 );
		else
			class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
	}

	// �ؽ������͸� - TriBox
	bOption = GetOptionBool( "Video", "UseTrilinear" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.TriBox", bOption );

	// ĳ����ǥ������ - PawnBox
	nRenderActorLimit = GetOptionInt( "Video", "RenderActorLimited" );
	if( nRenderActorLimit >= 6 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.PawnBox", 0 );
	else if( nRenderActorLimit == 5 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.PawnBox", 1 );
	else if( nRenderActorLimit == 4 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.PawnBox", 2 );
	else if( nRenderActorLimit == 3 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.PawnBox", 3 );
	else if( nRenderActorLimit == 2 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.PawnBox", 4 );
	else if( nRenderActorLimit <= 1 )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.PawnBox", 5 );

	// ��Ƽ�˸��ƽ�	- AABox
	nMultiSample = GetMultiSample();
	if( nMultiSample > 0 && !( 3 <= nPostProcessType && nPostProcessType <= 5 ) ) 
	{
		nOption = GetOptionInt( "Video", "AntiAliasing" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.AABox", nOption );
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.AABox" );
	}
	else 
	{
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.AABox", 0 );
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.AABox" );
	}

	// �ּ����������� - FrameBox
	bOption = GetOptionBool( "Video", "IsKeepMinFrameRate" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.FrameBox", bOption );
	if( bOption ) 
		MinFrameRateOn();
	else
		MinFrameRateOff();

	// ��ũ���� ǰ�� - CaptureBox
	nOption = GetOptionInt( "Game", "ScreenShotQuality" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.CaptureBox", nOption );

	///////////////////////////////////////////
	// Added on 2006/03/21 by NeverDie

	// ���ȿ�� - WeatherEffectComboBox
	nOption = GetOptionInt( "Video", "WeatherEffect" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.WeatherEffectComboBox", nOption );

	// GPU�ִϸ��̼� - GPUAnimationCheckBox
	bOption = GetOptionBool( "Video", "GPUAnimation" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GPUAnimationCheckBox", bOption );
	if( nVertexShaderVersion < 20 )
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.GPUAnimationCheckBox" );
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GPUAnimationCheckBox", false );
	}
}

function InitAudioOption()
{
	local float fSoundVolume;
	local float fMusicVolume;
	local float fWavVoiceVolume;
	local float fOggVoiceVolume;

	// lancelot 2006. 6. 13.
	local int iSoundVolume;
	local int iMusicVolume;
	local int iSystemVolume;
	local int iTutorialVolume;

	if (GetOptionBool( "Audio", "AudioMuteOn" ) == true)
	{
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.mutecheckbox", true);

	}
	else
	{
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.mutecheckbox", false);
	}
		

	if( CanUseAudio() )
	{
		// ȿ�������� - EffectVolumeSliderCtrl
		fSoundVolume = GetOptionFloat( "Audio", "SoundVolume" );
		gSoundVolume = fSoundVolume;

		if( 0.0f <= fSoundVolume && fSoundVolume < 0.2f )
			iSoundVolume=0;
		else if( 0.2f <= fSoundVolume && fSoundVolume < 0.4f )
			iSoundVolume=1;
		else if( 0.4f <= fSoundVolume && fSoundVolume < 0.6f )
			iSoundVolume=2;
		else if( 0.6f <= fSoundVolume && fSoundVolume < 0.8f )
			iSoundVolume=3;
		else if( 0.8f <= fSoundVolume && fSoundVolume < 1.0f )
			iSoundVolume=4;
		else if( 1.0f <= fSoundVolume )
			iSoundVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.EffectVolumeSliderCtrl", iSoundVolume);


		// ���Ǻ���	- MusicVolumeSliderCtrl
		fMusicVolume = GetOptionFloat( "Audio", "MusicVolume" );
		gMusicVolume=fMusicVolume;

		if( 0.0f <= fMusicVolume && fMusicVolume < 0.2f )
			iMusicVolume=0;
		else if( 0.2f <= fMusicVolume && fMusicVolume < 0.4f )
			iMusicVolume=1;
		else if( 0.4f <= fMusicVolume && fMusicVolume < 0.6f )
			iMusicVolume=2;
		else if( 0.6f <= fMusicVolume && fMusicVolume < 0.8f )
			iMusicVolume=3;
		else if( 0.8f <= fMusicVolume && fMusicVolume < 1.0f )
			iMusicVolume=4;
		else if( 1.0f <= fMusicVolume )
			iMusicVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.MusicVolumeSliderCtrl", iMusicVolume);

		// �ý������� - SystemVolumeSliderCtrl
		fWavVoiceVolume = GetOptionFloat( "Audio", "WavVoiceVolume" );
		gWavVoiceVolume = fWavVoiceVolume;

		if( 0.0f <= fWavVoiceVolume && fWavVoiceVolume < 0.2f )
			iSystemVolume=0;
		else if( 0.2f <= fWavVoiceVolume && fWavVoiceVolume < 0.4f )
			iSystemVolume=1;
		else if( 0.4f <= fWavVoiceVolume && fWavVoiceVolume < 0.6f )
			iSystemVolume=2;
		else if( 0.6f <= fWavVoiceVolume && fWavVoiceVolume < 0.8f )
			iSystemVolume=3;
		else if( 0.8f <= fWavVoiceVolume && fWavVoiceVolume < 1.0f )
			iSystemVolume=4;
		else if( 1.0f <= fWavVoiceVolume )
			iSystemVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.SystemVolumeSliderCtrl", iSystemVolume);


		// Ʃ�丮������	- TutorialBox
		fOggVoiceVolume = GetOptionFloat( "Audio", "OggVoiceVolume" );
		gOggVoiceVolume = fOggVoiceVolume;
			
		if( 0.0f <= fOggVoiceVolume && fOggVoiceVolume < 0.2f )
			iTutorialVolume=0;
		else if( 0.2f <= fOggVoiceVolume && fOggVoiceVolume < 0.4f )
			iTutorialVolume=1;
		else if( 0.4f <= fOggVoiceVolume && fOggVoiceVolume < 0.6f )
			iTutorialVolume=2;
		else if( 0.6f <= fOggVoiceVolume && fOggVoiceVolume < 0.8f )
			iTutorialVolume=3;
		else if( 0.8f <= fOggVoiceVolume && fOggVoiceVolume < 1.0f )
			iTutorialVolume=4;
		else if( 1.0f <= fOggVoiceVolume )
			iTutorialVolume=5;

		class'UIAPI_SLIDERCTRL'.static.SetCurrentTick("OptionWnd.TutorialVolumeSliderCtrl", iTutorialVolume);
	
		m_iPrevSoundTick=iSoundVolume;
		m_iPrevMusicTick=iMusicVolume;
		m_iPrevSystemTick=iSystemVolume;
		m_iPrevTutorialTick=iTutorialVolume;
	}
	else
	{
		class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.EffectVolumeSliderCtrl");
		class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.MusicVolumeSliderCtrl");
		class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.SystemVolumeSliderCtrl");
		class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.TutorialVolumeSliderCtrl");
	}
	

	
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.mutecheckbox" ) )
		{
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.EffectVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.MusicVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.SystemVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.TutorialVolumeSliderCtrl");
				

//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.EffectBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.MusicBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.SystemBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.TutorialBox" );
			

			SetSoundVolume( 0.f );
			SetMusicVolume( 0.f );
			SetWavVoiceVolume( 0.f );
			SetOggVoiceVolume( 0.f );
			SetOptionBool("Audio", "AudioMuteOn", true);
			
		}
		else
		{
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.EffectBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.MusicBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.SystemBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.TutorialBox" );
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.EffectVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.MusicVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.SystemVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.TutorialVolumeSliderCtrl");
		}
	
}

function InitGameOption()
{
	local bool bShowOtherPCName;
	local int nOption;
	local bool bOption;

	// ����ȭ - OpacityBox
	bOption = GetOptionBool( "Game", "TransparencyMode" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.OpacityBox", bOption );

	// ���� - LanguageBox
	bOption = GetOptionBool( "Game", "IsNative" );
	if( bOption )
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.LanguageBox", 0 );
	else
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.LanguageBox", 1 );
	
	// �ڽ��̸� - NameBox0
	bOption = GetOptionBool( "Game", "MyName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox0", bOption );

	// �����̸� - NameBox1
	bOption = GetOptionBool( "Game", "NPCName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox1", bOption );

	// �ٸ�PC�̸� - NameBox2
	bShowOtherPCName = GetOptionBool( "Game", "GroupName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox2", bShowOtherPCName );

	// �����̸� - NameBox3
	bOption = GetOptionBool( "Game", "PledgeMemberName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox3", bOption );

	// ��Ƽ�̸�	- NameBox4
	bOption = GetOptionBool( "Game", "PartyMemberName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox4", bOption );

	// �Ϲ��̸�	- NameBox5
	bOption = GetOptionBool( "Game", "OtherPCName" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.NameBox5", bOption );

	if( bShowOtherPCName ) 
	{
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox3" );
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox4" );
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox5" );
	}
	else
	{
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox3" );
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox4" );
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox5" );
	}

	// ����ü��	- EnterChatBox
	bOption = GetOptionBool( "Game", "EnterChatting" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.EnterChatBox", bOption );

	// ä�ñ�ȣ	- OldChatBox
	bOption = GetOptionBool( "Game", "OldChatting" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.OldChatBox", bOption );

	// Ű���庸�� - KeyboardBox
	if( IsUseKeyCrypt() )
	{
		if( IsCheckKeyCrypt() )
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.KeyboardBox", true );
		else
			class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.KeyboardBox", false );

		if( IsEnableKeyCrypt() )
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.KeyboardBox" );
		else
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.KeyboardBox" );
	}
	else
	{
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.KeyboardBox", false );
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.KeyboardBox" );
	}

	// �����е�	- JoypadBox
	bOption = GetOptionBool( "Game", "UseJoystick" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.JoypadBox", bOption );
	if( CanUseJoystick() )
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.JoypadBox" );
	else
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.JoypadBox" );

	// ī�޶����� - CameraBox
	bOption = GetOptionBool( "Game", "AutoTrackingPawn" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.CameraBox", bOption );

	// �׷���Ŀ�� - CursorBox
	bOption = GetOptionBool( "Video", "UseColorCursor" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.CursorBox", bOption );

	// 3Dȭ��ǥ	- ArrowBox
	bOption = GetOptionBool( "Game", "ArrowMode" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ArrowBox", bOption );

	// ������ǥ�� - ZoneNameBox
	bOption = GetOptionBool( "Game", "ShowZoneTitle" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ZoneNameBox", bOption );

	// ������ ǥ�� - ShowGameTipMsg
	bOption = GetOptionBool( "Game", "ShowGameTipMsg" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.GametipBox", bOption );
		
	// ���� �ź� - DuelBox
	bOption = GetOptionBool( "Game", "IsRejectingDuel" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.DuelBox", bOption );
	
	// ��ӵ� ������ ǥ��
	bOption = GetOptionBool( "Game", "HideDropItem");
	class'UIAPI_CHECKBOX'.static.SetCheck("OptionWnd.DropItemBox", bOption);
	
	// �ý��۸޽�������â - SystemMsgBox
	/*
	bSystemMsgWnd = GetOptionBool( "Game", "SystemMsgWnd" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.SystemMsgBox", bSystemMsgWnd );
	
	// ������ - DamageBox
	bOption = GetOptionBool( "Game", "SystemMsgWndDamage" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.DamageBox", bOption );

	// �Ҹ𼺾����ۻ�� - ItemBox
	bOption = GetOptionBool( "Game", "SystemMsgWndExpendableItem" );
	class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.ItemBox", bOption );

	if( bSystemMsgWnd )
	{
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.DamageBox" );
		class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.ItemBox" );
	}
	else
	{
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.DamageBox" );
		class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.ItemBox" );
	}
	*/

	// ��Ƽ���� - LootingBox
	nOption = GetOptionInt( "Game", "PartyLooting" );
	class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.LootingBox", nOption );
	RefreshLootingBox();
}

function OnClickCheckBox( String strID )
{
	debug( strID );

	switch( strID )
	{
	case "NameBox2":
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox2" ) )
		{
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox3" );
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox4" );
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.NameBox5" );
		}
		else
		{
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox3" );
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox4" );
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.NameBox5" );
		}
		break;
	case "SystemMsgBox":
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.SystemMsgBox" ) )
		{
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.DamageBox" );
			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.ItemBox" );
		}
		else
		{
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.DamageBox" );
			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.ItemBox" );
		}
		break;
	case "FrameBox":
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.FrameBox" ) )
			MinFrameRateOn();
		else
			MinFrameRateOff();
		break;
	case "mutecheckbox":
		if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.mutecheckbox" ) )
		{
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.EffectVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.MusicVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.SystemVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.DisableWindow("OptionWnd.TutorialVolumeSliderCtrl");

//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.EffectBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.MusicBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.SystemBox" );
//			class'UIAPI_CHECKBOX'.static.DisableWindow( "OptionWnd.TutorialBox" );
		}
		else
		{
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.EffectBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.MusicBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.SystemBox" );
//			class'UIAPI_CHECKBOX'.static.EnableWindow( "OptionWnd.TutorialBox" );
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.EffectVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.MusicVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.SystemVolumeSliderCtrl");
			class'UIAPI_SLIDERCTRL'.static.EnableWindow("OptionWnd.TutorialVolumeSliderCtrl");
		}
		break;
	}
}

function OnShow()
{
	bShow = true;

	InitVideoOption();
	InitAudioOption();
	InitGameOption();

	/*
	if( GetUIState() == 'LoginState' )
		class'UIAPI_WINDOW'.static.SetAlwaysOnTop( "OptionWnd", true );
	else
		class'UIAPI_WINDOW'.static.SetAlwaysOnTop( "OptionWnd", false );
		*/
}

function OnHide()
{
	bShow = false;
}

function ApplyVideoOption()
{
	local bool bKeepMinFrameRate;
	local bool bTrilinear;
	local int nTextureDetail;
	local int nModelDetail;
	local int nMotionDetail;
	local int nTerrainClippingRange;
	local int nPawnClippingRange;
	local int nReflectionEffect;
	local int nHDR;
	local int nWeatherEffect;
	//local float fPawnClippingRange;
	//local float fStaticMeshClippingRange;
	//local float fActorClippingRange;
	//local float fTerrainClippingRange;
	//local float fStaticMeshLodClippingRange;
	local int nSelectedNum;
	local float fGamma;
	local bool bRenderDeco;
	local bool bShadow;
	local int nRenderActorLimit;
	local int nResolutionIndex;
	local int nRefreshRateIndex;
	local bool bIsChecked;

	// �ؽ������͸� - TriBox
	bTrilinear = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.TriBox" );
	SetOptionBool( "Video", "UseTrilinear", bTrilinear );

	// �ؽ��ĵ����� - TextureBox
	nTextureDetail = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.TextureBox" );
	SetOptionInt( "Video", "TextureDetail", nTextureDetail );

	// �𵨸������� - ModelBox
	nModelDetail = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.ModelBox" );
	SetOptionInt( "Video", "ModelDetail", nModelDetail );

	// ��ǵ����� - AnimBox
	nMotionDetail = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.AnimBox" );
	SetOptionInt( "Video", "SkipAnim", nMotionDetail );

	// �þ�-ĳ���� - CharBox
	nPawnClippingRange = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.CharBox" );
	SetOptionInt( "Video", "PawnClippingRange", nPawnClippingRange );

	// �þ�-���� - TerrainBox
	nTerrainClippingRange = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.TerrainBox" );
	SetOptionInt( "Video", "TerrainClippingRange", nTerrainClippingRange );

	// ������ - GammaBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.GammaBox" );
	switch( nSelectedNum )
	{
	case 0:
		fGamma = 1.2f;
		break;
	case 1:
		fGamma = 1.0f;
		break;
	case 2:
		fGamma = 0.8f;
		break;
	case 3:
		fGamma = 0.6f;
		break;
	case 4:
		fGamma = 0.4f;
		break;
	}
	SetOptionFloat( "Video", "Gamma", fGamma );

	// ȭ���������̴� - HDRBox
	nHDR = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.HDRBox" );
	SetOptionInt( "Video", "PostProc", nHDR );

	// ���ȿ�� - DecoBox
	bRenderDeco = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.DecoBox" );
	SetOptionBool( "Video", "RenderDeco", bRenderDeco );

	// �׸��� - ShadowBox
	bShadow = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.ShadowBox" );
	SetOptionBool( "Video", "PawnShadow", bShadow );

	// �ݻ�ȿ�� - ReflectBox
	nReflectionEffect = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.ReflectBox" );
	SetOptionInt( "L2WaterEffect", "EffectType", nReflectionEffect );
	if( 0 == nReflectionEffect )
		SetOptionBool( "L2WaterEffect", "IsUseEffect", false );
	else
		SetOptionBool( "L2WaterEffect", "IsUseEffect", true );

	// ĳ����ǥ������ - PawnBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.PawnBox" );
	switch( nSelectedNum )
	{
		case 5:
			nRenderActorLimit = 1;
			break;
		case 4:
			nRenderActorLimit = 2;
			break;
		case 3:
			nRenderActorLimit = 3;
			break;
		case 2:
			nRenderActorLimit = 4;
			break;
		case 1:
			nRenderActorLimit = 5;
			break;
		case 0:
			nRenderActorLimit = 6;
			break;
	}
	SetOptionInt( "Video", "RenderActorLimited", nRenderActorLimit );

	// ��Ƽ�˸��ƽ�	- AABox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.AABox" );
	SetOptionInt( "Video", "AntiAliasing", nSelectedNum );

	// ��ũ���� ǰ�� - CaptureBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.CaptureBox" );
	SetOptionInt( "Game", "ScreenShotQuality", nSelectedNum );

	// �ػ� - ResBox
	// �ֻ��� - RefreshRateBox
	nResolutionIndex = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.ResBox" );
	nRefreshRateIndex = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.RefreshRateBox" );
	SetResolution( nResolutionIndex, nRefreshRateIndex );

	///////////////////////////////////////////
	// Added on 2006/03/21 by NeverDie

	// ���ȿ�� - WeatherEffectComboBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.WeatherEffectComboBox" );
	switch( nSelectedNum )
	{
	case 0:
		nWeatherEffect = 0;
		break;
	case 1:
		nWeatherEffect = 1;
		break;
	case 2:
		nWeatherEffect = 2;
		break;
	case 3:
		nWeatherEffect = 3;
		break;
	}
	SetOptionInt( "Video", "WeatherEffect", nWeatherEffect );

	// GPU�ִϸ��̼� - GPUAnimationCheckBox
	bIsChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.GPUAnimationCheckBox" );
	SetOptionBool( "Video", "GPUAnimation", bIsChecked );

	// �ּ����������� - FrameBox
	bKeepMinFrameRate = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.FrameBox" );
	SetOptionBool( "Video", "IsKeepMinFrameRate", bKeepMinFrameRate );
	if( bKeepMinFrameRate )
	{
		debug( "KeepMinFrameRate" );
		SetTextureDetail( 2 );
		SetModelingDetail( 1 );
		SetMotionDetail( 1 );
		SetShadow( false );
		SetBackgroundEffect( false );
		SetTerrainClippingRange( 4 );
		SetPawnClippingRange( 4 );
		SetReflectionEffect( 0 );
		SetHDR( 0 );
		SetWeatherEffect( 0 );
	}
	else
	{
		debug( "Not KeepMinFrameRate nTextureDetail=" $ nTextureDetail );
		SetTextureDetail( nTextureDetail );
		SetModelingDetail( nModelDetail );
		SetMotionDetail( nMotionDetail );
		SetShadow( bShadow );
		SetBackgroundEffect( bRenderDeco );
		SetTerrainClippingRange( nTerrainClippingRange );
		SetPawnClippingRange( nPawnClippingRange );
		SetReflectionEffect( nReflectionEffect );
		SetHDR( nHDR );
		SetWeatherEffect( nWeatherEffect );
	}

	InitVideoOption();
}

function ApplyAudioOption()
{
	//local int nSelectedNum;
	local float fSoundVolume;
	local float fMusicVolume;
	local float fWavVoiceVolume;
	local float fOggVoiceVolume;


	local int iSoundTick;
	local int iMusicTick;
	local int iSystemTick;
	local int iTutorialTick;

	if( !CanUseAudio() )
		return;
	// code ���� - lancelot 2006. 6. 13.
	// ȿ�������� - EffectVolumeSliderCtrl
	iSoundTick=class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.EffectVolumeSliderCtrl");
	fSoundVolume=GetVolumeFromSliderTick(iSoundTick);
	SetOptionFloat("Audio", "SoundVolume", fSoundVolume);
	gSoundVolume=fSoundVolume;

	// ���Ǻ��� - MusicVolumeSliderCtrl
	iMusicTick=class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.MusicVolumeSliderCtrl");
	fMusicVolume=GetVolumeFromSliderTick(iMusicTick);
	SetOptionFloat("Audio", "MusicVolume", fMusicVolume);
	gMusicVolume=fMusicVolume;

	// �ý��ۺ��� - SystemVolumeSliderCtrl
	iSystemTick=class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.SystemVolumeSliderCtrl");
	fWavVoiceVolume=GetVolumeFromSliderTick(iSystemTick);
	SetOptionFloat("Audio", "WavVoiceVolume", fWavVoiceVolume);
	gWavVoiceVolume=fWavVoiceVolume;

	// ���Ǻ��� - MusicVolumeSliderCtrl
	iTutorialTick=class'UIAPI_SLIDERCTRL'.static.GetCurrentTick("OptionWnd.TutorialVolumeSliderCtrl");
	fOggVoiceVolume=GetVolumeFromSliderTick(iTutorialTick);
	SetOptionFloat("Audio", "OggVoiceVolume", fOggVoiceVolume);
	gOggVoiceVolume=fOggVoiceVolume;


	// �������ش�
	m_iPrevSoundTick=iSoundTick;
	m_iPrevMusicTick=iMusicTIck;
	m_iPrevSystemTick=iSystemTick;
	m_iPrevTutorialTick=iTutorialtick;

	if( class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.mutecheckbox" ) )
	{
		SetSoundVolume( 0.f );
		SetMusicVolume( 0.f );
		SetWavVoiceVolume( 0.f );
		SetOggVoiceVolume( 0.f );
		SetOptionBool("Audio", "AudioMuteOn", true);
	}
	else
	{
		SetOptionBool( "Audio", "AudioMuteOn", false);
	}

/*	��� �ɰŰ��Ƽ� ���� - lancelot 2006. 6. 13.
	else
	{
		SetSoundVolume( gSoundVolume );
		SetMusicVolume( gMusicVolume);
		SetWavVoiceVolume( gWavVoiceVolume);
		SetOggVoiceVolume( gOggVoiceVolume );
	}
*/

}

function ApplyGameOption()
{
	local int nSelectedNum;
	local bool bChecked;

	// ���� - LanguageBox
	nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.LanguageBox" );
	if( 0 == nSelectedNum )
		SetOptionBool( "Game", "IsNative", true );
	else if( 1 == nSelectedNum )
		SetOptionBool( "Game", "IsNative", false );

	// �ڽ��̸� - NameBox0
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox0" );
	SetOptionBool( "Game", "MyName", bChecked );

	// �����̸� - NameBox1
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox1" );
	SetOptionBool( "Game", "NPCName", bChecked );

	// �����̸� - NameBox3
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox3" );
	SetOptionBool( "Game", "PledgeMemberName", bChecked );

	// ��Ƽ�̸�	- NameBox4
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox4" );
	SetOptionBool( "Game", "PartyMemberName", bChecked );

	// �Ϲ��̸�	- NameBox5
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox5" );
	SetOptionBool( "Game", "OtherPCName", bChecked );

	// �ٸ�PC�̸� - NameBox2
	// �ٸ� �̸� ���� �ɼ��� ��� ����ǰ� ���� ������ �ϹǷ�, ���� ���߿� �ؾ��Ѵ�. - NeverDie
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.NameBox2" );
	SetOptionBool( "Game", "GroupName", bChecked );

	// ����ȭ - OpacityBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.OpacityBox" );
	SetOptionBool( "Game", "TransparencyMode", bChecked );

	// 3Dȭ��ǥ - ArrowBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.ArrowBox" );
	SetOptionBool( "Game", "ArrowMode", bChecked );

	// ī�޶����� - CameraBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.CameraBox" );
	SetOptionBool( "Game", "AutoTrackingPawn", bChecked );

	// ����ä�� - EnterChatBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.EnterChatBox" );
	SetOptionBool( "Game", "EnterChatting", bChecked );

	// ä�ñ�ȣ - OldChatBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.OldChatBox" );
	SetOptionBool( "Game", "OldChatting", bChecked );

	// ������ǥ�� - ZoneNameBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.ZoneNameBox" );
	SetOptionBool( "Game", "ShowZoneTitle", bChecked );
	
	// ������ǥ�� - GametipBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.GametipBox" );
	SetOptionBool( "Game", "ShowGameTipMsg", bChecked );
	
	// ���� �ź� - DuelBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.DuelBox" );
	SetOptionBool( "Game", "IsRejectingDuel", bChecked );

	// ��� ������ - DropItemBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.DropItemBox" );
	SetOptionBool( "Game", "HideDropItem", bChecked );

	// ��Ƽ���� - LootingBox
	if( class'UIAPI_WINDOW'.static.IsEnableWindow( "OptionWnd.LootingBox" ) )
	{
		nSelectedNum = class'UIAPI_COMBOBOX'.static.GetSelectedNum( "OptionWnd.LootingBox" );
		SetOptionInt( "Game", "PartyLooting", nSelectedNum );
	}

	// �׷���Ŀ�� - CursorBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.CursorBox" );
	SetOptionBool( "Video", "UseColorCursor", bChecked );

	// �ý��۸޽�������â - SystemMsgBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.SystemMsgBox" );
	SetOptionBool( "Game", "SystemMsgWnd", bChecked );

	// ������ - DamageBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.DamageBox" );
	SetOptionBool( "Game", "SystemMsgWndDamage", bChecked );

	// �Ҹ𼺾����ۻ�� - ItemBox
	bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.ItemBox" );
	SetOptionBool( "Game", "SystemMsgWndExpendableItem", bChecked );

	// �����е�	- JoypadBox
	if( CanUseJoystick() )
	{
		bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.JoypadBox" );
		SetOptionBool( "Game", "UseJoystick", bChecked );
	}

	// Ű���庸�� - KeyboardBox
	if( IsUseKeyCrypt() )
	{
		bChecked = class'UIAPI_CHECKBOX'.static.IsChecked( "OptionWnd.KeyboardBox" );
		SetKeyCrypt( bChecked );
	}
}

function OnClickButton( string strID )
{
	Debug( strID );

	switch( strID )
	{
	case "VideoCancelBtn":
	case "AudioCancelBtn":
	case "GameCancelBtn":
		SetOptionInt( "FirstRun", "FirstRun", 2 );

		// �ǵ����ش� - lancelot 2006. 6. 13.
		OnModifyCurrentTickSliderCtrl("EffectVolumeSliderCtrl", m_iPrevSoundTick);
		OnModifyCurrentTickSliderCtrl("MusicVolumeSliderCtrl", m_iPrevMusicTick);
		OnModifyCurrentTickSliderCtrl("SystemVolumeSliderCtrl", m_iPrevSystemTick);
		OnModifyCurrentTickSliderCtrl("TutorialVolumeSliderCtrl", m_iPrevTutorialTick);

		class'UIAPI_Window'.static.HideWindow( "OptionWnd" );
		break;
	case "VideoOKBtn":
	case "AudioOKBtn":
	case "GameOKBtn":
		ApplyVideoOption();
		ApplyAudioOption();
		ApplyGameOption();
		SetOptionInt( "FirstRun", "FirstRun", 2 );
		class'UIAPI_Window'.static.HideWindow( "OptionWnd" );
		break;
	case "VideoApplyBtn":
	case "AudioApplyBtn":
	case "GameApplyBtn":
		ApplyVideoOption();
		ApplyAudioOption();
		ApplyGameOption();
		break;
	case "WindowInitBtn":
		SetDefaultPosition();
		break;
	}
}

// Slider control�� tick ���κ��� volume�� float���� ���ϴ� �Լ�
function float GetVolumeFromSliderTick(int iTick)
{
	local float fReturnVolume;
	switch(iTick)
	{
	case 0 :
		fReturnVolume=0.0f;
		break;
	case 1 :
		fReturnVolume=0.2f;
		break;
	case 2 :
		fReturnVolume=0.4f;
		break;
	case 3 :
		fReturnVolume=0.6f;
		break;
	case 4 :
		fReturnVolume=0.8f;
		break;
	case 5 :
		fReturnVolume=1.0f;
		break;
	}

	return fReturnVolume;
}



function MinFrameRateOn()
{
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.TextureBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ModelBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.AnimBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ShadowBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.DecoBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.TerrainBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.CharBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.HDRBox" );

	///////////////////////////////////////////
	// Added on 2006/03/21 by NeverDie
	class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.WeatherEffectComboBox" );
}

function MinFrameRateOff()
{
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.TextureBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ModelBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.AnimBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ShadowBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.DecoBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.TerrainBox" );
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.CharBox" );

	///////////////////////////////////////////
	// Added on 2006/03/21 by NeverDie
	class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.WeatherEffectComboBox" );

	if( nPixelShaderVersion < 12 )
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.ReflectBox" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.ReflectBox", 0 );
	}
	else
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.ReflectBox" );

	if( nPixelShaderVersion >= 20 && nVertexShaderVersion >= 20 )
		class'UIAPI_WINDOW'.static.EnableWindow( "OptionWnd.HDRBox" );
	else
	{
		class'UIAPI_WINDOW'.static.DisableWindow( "OptionWnd.HDRBox" );
		class'UIAPI_COMBOBOX'.static.SetSelectedNum( "OptionWnd.HDRBox", 0 );
	}
}

function OnEvent( int a_EventID, String a_Param )
{
	local bool bMinFrameRate;

	switch( a_EventID )
	{
	case EV_MinFrameRateChanged:
		bMinFrameRate = GetOptionBool( "Video", "IsKeepMinFrameRate" );
		class'UIAPI_CHECKBOX'.static.SetCheck( "OptionWnd.FrameBox", bMinFrameRate );
		if( bMinFrameRate ) 
			MinFrameRateOn();
		else
			MinFrameRateOff();
		ApplyVideoOption();
		break;
	case EV_PartyMemberChanged:
		RefreshLootingBox();
		break;
	case EV_PartyMatchRoomStart:
		m_bPartyMatchRoomState = true;
		RefreshLootingBox();
		break;
	case EV_PartyMatchRoomClose:
		m_bPartyMatchRoomState = false;
		RefreshLootingBox();
		break;
	}
}

function OnComboBoxItemSelected( string sName, int index )
{
	debug( sName );
	switch( sName )
	{
	case "ResBox":
		ResetRefreshRate( ResolutionList[ index ].nWidth, ResolutionList[ index ].nHeight );
		break;
	}
}

// �����̴� ��Ʈ�� �ڵ鷯 - lancelot 2006. 6. 13.
function OnModifyCurrentTickSliderCtrl(string strID, int iCurrentTick)
{
	local float fVolume;

	fVolume=GetVolumeFromSliderTick(iCurrentTick);

	switch(strID)
	{
	case "EffectVolumeSliderCtrl" :
		SetOptionFloat("Audio", "SoundVolume", fVolume);
		break;
	case "MusicVolumeSliderCtrl" :
		if(fVolume==0.0f)	// �����̴� �ٸ� �����̴� ���߿��� ������ ������ �ʰ� �ϱ� ���ؼ�
			fVolume=0.005f;
		SetOptionFloat("Audio", "MusicVolume", fVolume);
		break;
	case "SystemVolumeSliderCtrl" :
		SetOptionFloat("Audio", "WavVoiceVolume", fVolume);
		break;
	case "TutorialVolumeSliderCtrl" :
		SetOptionFloat("Audio", "OggVoiceVolume", fVolume);
		break;
	}
}
defaultproperties
{
}
