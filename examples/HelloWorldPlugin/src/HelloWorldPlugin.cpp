#include "HelloWorldPlugin.h"
#include <juce_events/juce_events.h>
#include <cstdint>

// Global plugin host pointer
TFruityPlugHost *PlugHost = nullptr;

// Shared JUCE initialization counter for reference counting
static int g_juceRefCount = 0;

// Plugin info (static)
TFruityPlugInfo HelloWorldPlugin::s_PluginInfo = {
    CurrentSDKVersion,              // SDKVersion
    (char*)"HelloWorld",            // LongName
    (char*)"Hello",                 // ShortName
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

HelloWorldPlugin::HelloWorldPlugin(int Tag)
{
    // Set the host tag (required)
    HostTag = Tag;
    
    // Set plugin info pointer
    Info = &s_PluginInfo;
    
    // Initialize JUCE with reference counting (thread-safe)
    if (g_juceRefCount == 0)
    {
        juce::initialiseJuce_GUI();
    }
    g_juceRefCount++;
}

HelloWorldPlugin::~HelloWorldPlugin()
{
    HideEditor();
    
    // Shutdown JUCE with reference counting
    g_juceRefCount--;
    if (g_juceRefCount == 0)
    {
        juce::shutdownJuce_GUI();
    }
}

void HelloWorldPlugin::DestroyObject()
{
    // Clean up before destruction
    HideEditor();
}

void HelloWorldPlugin::Idle()
{
    // Called periodically when idle
    // Process JUCE message queue to keep the GUI responsive
    if (m_editor)
    {
        juce::MessageManager::getInstance()->runDispatchLoopUntil(1);
    }
}

void HelloWorldPlugin::SaveRestoreState(IStream *Stream, BOOL Save)
{
    // Since we have no parameters, we don't need to save/load anything
    // In a real plugin, you would save/load your plugin state here
}

void HelloWorldPlugin::GetName(int Section, int Index, int Value, char *Name)
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

int HelloWorldPlugin::Dispatcher(int ID, int Index, int Value)
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

void HelloWorldPlugin::ShowEditor(HWND ParentWindow)
{
    if (m_editor != nullptr)
        return; // Already showing
        
    // Create the JUCE editor component
    m_editor = std::make_unique<HelloWorldEditor>();
    
    // Create a window to hold our editor
    // We'll embed this in the FL Studio window
    if (ParentWindow != nullptr)
    {
        // For FL Studio integration, add the JUCE component to the parent window
        // Use addToDesktop with the parent window as the native handle
        m_editor->addToDesktop(0, ParentWindow);
        m_editor->setVisible(true);
        
        // Get the JUCE window handle
        EditorHandle = (HWND)m_editor->getWindowHandle();
    }
    else
    {
        // Create a standalone window if no parent provided
        m_editorWindow = std::make_unique<juce::DocumentWindow>(
            "Hello World FL Studio Plugin",
            juce::Colours::lightgrey,
            juce::DocumentWindow::closeButton
        );
        
        m_editorWindow->setContentNonOwned(m_editor.get(), true);
        m_editorWindow->centreWithSize(m_editor->getWidth(), m_editor->getHeight());
        m_editorWindow->setVisible(true);
        
        EditorHandle = (HWND)m_editorWindow->getWindowHandle();
    }
}

void HelloWorldPlugin::HideEditor()
{
    if (m_editor)
    {
        m_editor->setVisible(false);
        m_editor->removeFromDesktop();
        m_editor.reset();
    }
    
    if (m_editorWindow)
    {
        m_editorWindow->setVisible(false);
        m_editorWindow.reset();
    }
    
    EditorHandle = nullptr;
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
    return new HelloWorldPlugin(Tag);
}
