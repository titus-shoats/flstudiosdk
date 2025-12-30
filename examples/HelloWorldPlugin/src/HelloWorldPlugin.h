#ifndef HELLOWORLDPLUGIN_H
#define HELLOWORLDPLUGIN_H

#include "fp_plugclass.h"
#include "fp_plughost.h"
#include "HelloWorldEditor.h"
#include <juce_gui_basics/juce_gui_basics.h>
#include <memory>

// Global plugin host pointer (set by CreatePlugInstance)
extern TFruityPlugHost *PlugHost;

// HelloWorld FL Studio Plugin
class HelloWorldPlugin : public TFruityPlug
{
public:
    HelloWorldPlugin(int Tag);
    ~HelloWorldPlugin() override;

    // TFruityPlug overrides
    void DestroyObject() override;
    void Idle() override;
    void SaveRestoreState(IStream *Stream, BOOL Save) override;
    void GetName(int Section, int Index, int Value, char *Name) override;
    int Dispatcher(int ID, int Index, int Value) override;

private:
    // Plugin info
    static TFruityPlugInfo s_PluginInfo;
    
    // JUCE editor window
    std::unique_ptr<HelloWorldEditor> m_editor;
    
    // JUCE window wrapper for embedding in FL Studio
    std::unique_ptr<juce::DocumentWindow> m_editorWindow;
    
    // Create and show the editor window
    void ShowEditor(HWND ParentWindow);
    
    // Hide and destroy the editor window  
    void HideEditor();
};

#endif // HELLOWORLDPLUGIN_H
