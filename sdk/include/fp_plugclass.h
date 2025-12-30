#ifndef FP_PLUGCLASS_H
#define FP_PLUGCLASS_H

#include <windows.h>

// FL Studio SDK Version
#define CurrentSDKVersion 1

// Plugin Flags
#define FPF_Generator       (1)
#define FPF_RenderVoice     (1 << 1)
#define FPF_UseSampler      (1 << 2)
#define FPF_GetChanCustomShape (1 << 3)
#define FPF_GetNoteInput    (1 << 4)
#define FPF_WantNewTick     (1 << 5)
#define FPF_NoProcess       (1 << 6)
#define FPF_NoWindow        (1 << 10)
#define FPF_Interfaceless   (1 << 11)
#define FPF_TimeWarp        (1 << 13)
#define FPF_MidiOut         (1 << 14)
#define FPF_DemoVersion     (1 << 15)
#define FPF_CanSend         (1 << 16)

// GetName section constants
#define FPN_Param           0
#define FPN_ParamValue      1
#define FPN_Semitone        2
#define FPN_Patch           3
#define FPN_VoiceLevel      4
#define FPN_VoiceColor      5
#define FPN_VoiceName       7
#define FPN_OutCtrl         8
#define FPN_VoiceSection    9
#define FPN_OutVoice        10
#define FPN_Preset          11

// Forward declarations
struct TFruityPlugHost;

// TFruityPlugInfo structure
typedef struct TFruityPlugInfo {
    int SDKVersion;
    char *LongName;
    char *ShortName;
    int Flags;
    int NumParams;
    int DefPoly;
    int NumOutCtrls;
    int Reserved[31];
} TFruityPlugInfo, *PFruityPlugInfo;

// TFruityPlug base class
class TFruityPlug {
public:
    // Host tag (set by CreatePlugInstance)
    int HostTag;
    
    // Plugin info
    TFruityPlugInfo *Info;
    
    // Editor window handle
    HWND EditorHandle;
    
    // Constructor
    TFruityPlug() : HostTag(0), Info(nullptr), EditorHandle(nullptr) {}
    
    // Virtual destructor
    virtual ~TFruityPlug() {}
    
    // Called when destroying the plugin
    virtual void DestroyObject() {}
    
    // Called when the plugin is idle
    virtual void Idle() {}
    
    // Called to save or load state
    virtual void SaveRestoreState(IStream *Stream, BOOL Save) {}
    
    // Get name of parameter or other text
    virtual void GetName(int Section, int Index, int Value, char *Name) {
        Name[0] = 0;
    }
    
    // Process MIDI input
    virtual int MIDIIn(int Msg) {
        return 0;
    }
    
    // General dispatcher for various messages
    virtual int Dispatcher(int ID, int Index, int Value) {
        return 0;
    }
    
    // Render audio (for effects)
    virtual void Render(void *SourceBuffer, void *DestBuffer, int Length) {}
    
    // Process a single parameter change
    virtual void ProcessParam(int Index, int Value, int RECFlags) {}
    
    // Trigger a voice (for generators)
    virtual void TriggerVoice(void *Params, int SetTag) {}
    
    // Release a voice (for generators)
    virtual void Voice_Release(int SetTag) {}
    
    // Kill a voice (for generators)
    virtual void Voice_Kill(int SetTag) {}
    
    // Render a voice (for generators)
    virtual void Voice_Render(int SetTag, void *DestBuffer, int Length) {}
    
    // Process event (for generators)
    virtual void Voice_ProcessEvent(int SetTag, int EventID, int EventValue) {}
    
    // Get internal controller value
    virtual int OutputVoice_GetValue(int VoiceNum, int OutNum) {
        return 0;
    }
};

#endif // FP_PLUGCLASS_H
