#pragma once

#include "../../sdk/include/fp_plugclass.h"
#include <Windows.h>
#include <memory>

// Hello World FL Studio Plugin - Win32 Implementation
// Demonstrates native FL Studio plugin with Win32 GUI (no JUCE)
class HelloWorldWin32Plugin : public TFruityPlug
{
public:
    explicit HelloWorldWin32Plugin(int Tag);
    ~HelloWorldWin32Plugin() override;

    // TFruityPlug interface
    void DestroyObject() override;
    void Idle() override;
    void SaveRestoreState(IStream *Stream, BOOL Save) override;
    void GetName(int Section, int Index, int Value, char *Name) override;
    int Dispatcher(int ID, int Index, int Value) override;

    // Plugin info
    static TFruityPlugInfo s_PluginInfo;

private:
    void ShowEditor(HWND ParentWindow);
    void HideEditor();
    
    // Window procedure
    static LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
    
    // Custom painting
    void OnPaint(HDC hdc);
    
    HWND m_hwnd = nullptr;
    HWND m_parentHwnd = nullptr;
    HFONT m_font = nullptr;
    HBRUSH m_backgroundBrush = nullptr;
};
