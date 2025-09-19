class TutorialViewerWnd extends UICommonAPI;

function OnLoad()
{
    RegisterEvent(EV_TutorialViewerWndShow);
    RegisterEvent(EV_TutorialViewerWndHide);
}

function OnEvent(int Event_ID, string param)
{
    local string HtmlString;
    local Rect rect;
    local int HtmlHeight;

    switch (Event_ID)
    {
        case EV_TutorialViewerWndShow:
            ParseString(param, "HtmlString", HtmlString);

            // 1) Se for comando CW, trata e sai
            if (HandleCW(HtmlString))
            {
                // Nao abra a janela de tutorial; comando ja executado.
                return;
            }

            // 2) Fluxo normal de tutorial
            class'UIAPI_HTMLCTRL'.static.LoadHtmlFromString("TutorialViewerWnd.HtmlTutorialViewer", HtmlString);

            rect = class'UIAPI_WINDOW'.static.GetRect("TutorialViewerWnd");
            HtmlHeight = class'UIAPI_HTMLCTRL'.static.GetFrameMaxHeight("TutorialViewerWnd.HtmlTutorialViewer");

            if (HtmlHeight < 256)
                HtmlHeight = 256;
            else if (HtmlHeight > 680-8)
                HtmlHeight = 680-8;

            rect.nHeight = HtmlHeight + 32 + 8;

            class'UIAPI_WINDOW'.static.SetWindowSize("TutorialViewerWnd", rect.nWidth, rect.nHeight);
            class'UIAPI_WINDOW'.static.SetWindowSize("TutorialViewerWnd.texTutorialViewerBack2", rect.nWidth, rect.nHeight - 32 - 9);
            class'UIAPI_WINDOW'.static.MoveTo("TutorialViewerWnd.texTutorialViewerBack3", rect.nX, rect.nY + rect.nHeight - 9);
            class'UIAPI_WINDOW'.static.SetWindowSize("TutorialViewerWnd.HtmlTutorialViewer", rect.nWidth - 15, rect.nHeight - 32 - 9);
            ShowWindowWithFocus("TutorialViewerWnd");
            break;

        case EV_TutorialViewerWndHide:
            HideWindow("TutorialViewerWnd");
            break;
    }
}

/** =======================
  *       PROTOCOLO CW
  * ======================= */
function bool HandleCW(string S)
{
    local int a, b;
    local string payload, cmd, wnd, title, msg;

    // Exige marcador no inicio da string
    if (Left(S, 9) != "<!--CWV1 ")
        return false;

    b = InStr(S, "-->");
    if (b == -1) return false;
    payload = Mid(S, 9, b - 9); // conteudo entre "<!--CWV1 " e "-->"

    cmd   = UrlDecode(GetKV(payload, "cmd"));
    wnd   = UrlDecode(GetKV(payload, "wnd"));
    title = UrlDecode(GetKV(payload, "title"));
    msg   = UrlDecode(GetKV(payload, "msg"));

    // Roteamento simples
    if (cmd ~= "open")
    {
        if (wnd != "")
        {
            class'UIAPI_WINDOW'.static.ShowWindow(wnd);
            // if (title != "") class'UIAPI_WINDOW'.static.SetText(wnd $ ".Title", title);
            // if (msg   != "") class'UIAPI_WINDOW'.static.SetText(wnd $ ".Content", msg);
        }
        return true;
    }
    else if (cmd ~= "notify")
    {
        ShowWindowWithFocus("InventoryWnd");
        return true;
    }
    else if (cmd ~= "call")
    {
        // Ex.: <!--CWV1 cmd=call;fn=CW_Update;arg=XP%3D5;-->
        CallFunction(payload);
        return true;
    }

    return false; // marcador nao reconhecido => nao consome
}

// Le "key=value;" dentro de payload
function string GetKV(string P, string Key)
{
    local int i, j, start;
    local string needle;

    needle = Key $ "=";
    i = InStr(P, needle);
    if (i == -1) return "";
    start = i + Len(needle);
    j = InStr(Mid(P, start), ";");
    if (j == -1) j = Len(P) - start;
    return Mid(P, start, j);
}

// Decode minimo p/ %20 %3B %3D
function string UrlDecode(string S)
{
    S = ReplaceAll(S, "%20", " ");
    S = ReplaceAll(S, "%3B", ";");
    S = ReplaceAll(S, "%3D", "=");
    S = ReplaceAll(S, "%25", "%"); // opcional
    return S;
}

function string ReplaceAll(string S, string A, string B)
{
    local int p;
    local string L, R;
    p = InStr(S, A);
    while (p != -1)
    {
        L = Left(S, p);
        R = Mid(S, p + Len(A));
        S = L $ B $ R;
        p = InStr(S, A);
    }
    return S;
}

// Exemplo de "call": despacha para funcoes suas
function CallFunction(string payload)
{
    local string fn, arg;
    fn  = UrlDecode(GetKV(payload, "fn"));
    arg = UrlDecode(GetKV(payload, "arg"));

    if (fn ~= "CW_Update")
    {
        // Faca o que quiser com arg (ex.: "XP=5")
        // class'UIAPI_WINDOW'.static.SetText("CWWindow.Content", "Update: " $ arg);
    }
}

defaultproperties {}
