#include "HelloWorldWin32Plugin.h"
#include <cstdint>
#include <wingdi.h>

// Global plugin host pointer
TFruityPlugHost *PlugHost = nullptr;

// Plugin info (static)
TFruityPlugInfo HelloWorldWin32Plugin::s_PluginInfo = {
    CurrentSDKVersion,              // SDKVersion
    (char*)"HelloWorldWin32",       // LongName
    (char*)"HelloW32",              // ShortName
    FPF_Generator,                  // Flags - it's a generator plugin
    0,                              // NumParams
    0,                              // DefPoly
    0,                              // NumOutCtrls
    {0}                             // Reserved
};

// Dispatcher message IDs (common ones from FL Studio SDK)
#define FPD_ShowEditor      0
#define FPD_ProcessParam    1
#define FPD_SetEnabled      2
#define FPD_SetBlockSize    3
#define FPD_SetSampleRate   4
#define FPD_WindowMinMax    5

// Window class name
static const char* WINDOW_CLASS_NAME = "HelloWorldWin32PluginWindow";
static bool g_classRegistered = false;

HelloWorldWin32Plugin::HelloWorldWin32Plugin(int Tag)
{
    // Set the host tag (required)
    HostTag = Tag;
    
    // Set plugin info pointer
    Info = &s_PluginInfo;
    
    // Register window class (once)
    if (!g_classRegistered)
    {
        WNDCLASSEXA wc = {};
        wc.cbSize = sizeof(WNDCLASSEXA);
        wc.style = CS_OWNDC; // No CS_HREDRAW/CS_VREDRAW to prevent full redraws
        wc.lpfnWndProc = WindowProc;
        wc.hInstance = GetModuleHandleA(nullptr);
        wc.hCursor = LoadCursorA(nullptr, IDC_ARROW);
        wc.lpszClassName = WINDOW_CLASS_NAME;
        
        if (RegisterClassExA(&wc))
        {
            g_classRegistered = true;
        }
    }
}

HelloWorldWin32Plugin::~HelloWorldWin32Plugin()
{
    HideEditor();
    
    // Clean up resources
    if (m_font)
    {
        DeleteObject(m_font);
        m_font = nullptr;
    }
    
    if (m_backgroundBrush)
    {
        DeleteObject(m_backgroundBrush);
        m_backgroundBrush = nullptr;
    }
}

void HelloWorldWin32Plugin::DestroyObject()
{
    // Clean up before destruction
    HideEditor();
}

void HelloWorldWin32Plugin::Idle()
{
    // Called periodically when idle
    // Win32 handles messages automatically - no manual processing needed
}

void HelloWorldWin32Plugin::SaveRestoreState(IStream *Stream, BOOL Save)
{
    // Since we have no parameters, we don't need to save/load anything
    // In a real plugin, you would save/load your plugin state here
}

void HelloWorldWin32Plugin::GetName(int Section, int Index, int Value, char *Name)
{
    // Return names for various sections
    switch (Section)
    {
        case FPN_Param:
            // Parameter names (we have none)
            Name[0] = 0;
            break;
            
        case FPN_Patch:
            // Preset name
            strcpy_s(Name, 256, "Default");
            break;
            
        default:
            Name[0] = 0;
            break;
    }
}

int HelloWorldWin32Plugin::Dispatcher(int ID, int Index, int Value)
{
    switch (ID)
    {
        case FPD_ShowEditor:
            if (Value == 0)
            {
                // Hide editor
                HideEditor();
            }
            else
            {
                // Show editor
                ShowEditor(reinterpret_cast<HWND>(static_cast<intptr_t>(Index)));
            }
            return 0;
            
        case FPD_ProcessParam:
            // Process parameter change (we have no parameters)
            return 0;
            
        default:
            return 0;
    }
}

void HelloWorldWin32Plugin::ShowEditor(HWND ParentWindow)
{
    if (m_hwnd != nullptr)
        return; // Already showing
    
    m_parentHwnd = ParentWindow;
    
    // Create the window with WS_CLIPCHILDREN to prevent parent from painting over it
    m_hwnd = CreateWindowExA(
        0,                              // dwExStyle
        WINDOW_CLASS_NAME,              // lpClassName
        "Hello World",                  // lpWindowName
        WS_CHILD | WS_VISIBLE | WS_CLIPCHILDREN, // dwStyle
        0, 0,                           // x, y
        400, 300,                       // width, height
        ParentWindow,                   // hWndParent
        nullptr,                        // hMenu
        GetModuleHandleA(nullptr),      // hInstance
        this                            // lpParam - pass 'this' pointer
    );
    
    if (m_hwnd)
    {
        // Create font for text rendering
        m_font = CreateFontA(
            48,                         // Height
            0,                          // Width (auto)
            0,                          // Escapement
            0,                          // Orientation
            FW_BOLD,                    // Weight
            FALSE,                      // Italic
            FALSE,                      // Underline
            FALSE,                      // StrikeOut
            DEFAULT_CHARSET,            // CharSet
            OUT_DEFAULT_PRECIS,         // OutputPrecision
            CLIP_DEFAULT_PRECIS,        // ClipPrecision
            CLEARTYPE_QUALITY,          // Quality
            DEFAULT_PITCH | FF_DONTCARE, // PitchAndFamily
            "Arial"                     // FaceName
        );
        
        // Create gradient brush for background
        m_backgroundBrush = CreateSolidBrush(RGB(30, 100, 200));
        
        // Set the editor handle for FL Studio
        EditorHandle = m_hwnd;
        
        // Force initial paint
        InvalidateRect(m_hwnd, nullptr, TRUE);
    }
}

void HelloWorldWin32Plugin::HideEditor()
{
    if (m_hwnd)
    {
        DestroyWindow(m_hwnd);
        m_hwnd = nullptr;
        EditorHandle = nullptr;
    }
    
    m_parentHwnd = nullptr;
}

LRESULT CALLBACK HelloWorldWin32Plugin::WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    // Get the plugin instance pointer
    HelloWorldWin32Plugin* plugin = nullptr;
    
    if (uMsg == WM_CREATE)
    {
        // Store the plugin pointer in window user data
        CREATESTRUCTA* cs = reinterpret_cast<CREATESTRUCTA*>(lParam);
        plugin = static_cast<HelloWorldWin32Plugin*>(cs->lpCreateParams);
        SetWindowLongPtrA(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(plugin));
    }
    else
    {
        // Retrieve the plugin pointer
        plugin = reinterpret_cast<HelloWorldWin32Plugin*>(GetWindowLongPtrA(hwnd, GWLP_USERDATA));
    }
    
    switch (uMsg)
    {
        case WM_PAINT:
        {
            if (plugin)
            {
                PAINTSTRUCT ps;
                HDC hdc = BeginPaint(hwnd, &ps);
                
                // Use double buffering to prevent flicker
                RECT rect;
                GetClientRect(hwnd, &rect);
                
                // Create memory DC for double buffering
                HDC memDC = CreateCompatibleDC(hdc);
                HBITMAP memBitmap = CreateCompatibleBitmap(hdc, rect.right, rect.left);
                HBITMAP oldBitmap = (HBITMAP)SelectObject(memDC, memBitmap);
                
                // Paint to memory DC
                plugin->OnPaint(memDC);
                
                // Copy to screen
                BitBlt(hdc, 0, 0, rect.right, rect.bottom, memDC, 0, 0, SRCCOPY);
                
                // Cleanup
                SelectObject(memDC, oldBitmap);
                DeleteObject(memBitmap);
                DeleteDC(memDC);
                
                EndPaint(hwnd, &ps);
            }
            return 0;
        }
        
        case WM_ERASEBKGND:
            // Return 1 to prevent default erase (we handle it in WM_PAINT)
            return 1;
        
        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;
    }
    
    return DefWindowProcA(hwnd, uMsg, wParam, lParam);
}

void HelloWorldWin32Plugin::OnPaint(HDC hdc)
{
    RECT rect;
    GetClientRect(m_hwnd, &rect);
    
    // Create gradient background (blue gradient)
    int height = rect.bottom - rect.top;
    for (int y = 0; y < height; y++)
    {
        // Gradient from light blue (top) to dark blue (bottom)
        int r = 30 + (100 - 30) * (height - y) / height;
        int g = 100 + (150 - 100) * (height - y) / height;
        int b = 200 + (50 - 200) * (height - y) / height;
        
        HBRUSH brush = CreateSolidBrush(RGB(r, g, b));
        RECT lineRect = {rect.left, y, rect.right, y + 1};
        FillRect(hdc, &lineRect, brush);
        DeleteObject(brush);
    }
    
    // Set up text rendering
    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, RGB(255, 255, 255)); // White text
    
    // Draw "Hello World" text
    if (m_font)
    {
        HFONT oldFont = (HFONT)SelectObject(hdc, m_font);
        
        const char* mainText = "Hello World";
        SIZE textSize;
        GetTextExtentPoint32A(hdc, mainText, (int)strlen(mainText), &textSize);
        
        int x = (rect.right - textSize.cx) / 2;
        int y = (rect.bottom - textSize.cy) / 2 - 20;
        
        TextOutA(hdc, x, y, mainText, (int)strlen(mainText));
        
        // Draw subtitle
        HFONT subtitleFont = CreateFontA(
            16, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
            DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
            CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, "Arial"
        );
        
        SelectObject(hdc, subtitleFont);
        
        const char* subtitle = "FL Studio Native Plugin with Win32 GUI";
        GetTextExtentPoint32A(hdc, subtitle, (int)strlen(subtitle), &textSize);
        
        x = (rect.right - textSize.cx) / 2;
        y = (rect.bottom - textSize.cy) / 2 + 40;
        
        TextOutA(hdc, x, y, subtitle, (int)strlen(subtitle));
        
        // Cleanup
        SelectObject(hdc, oldFont);
        DeleteObject(subtitleFont);
    }
}

// DLL Export: CreatePlugInstance
// This is the entry point that FL Studio calls to create an instance of the plugin
extern "C" __declspec(dllexport) TFruityPlug* _stdcall CreatePlugInstance(
    TFruityPlugHost *Host,
    int Tag
)
{
    // Set the global plugin host pointer
    PlugHost = Host;
    
    // Create and return a new plugin instance
    return new HelloWorldWin32Plugin(Tag);
}
