#ifndef FP_PLUGHOST_H
#define FP_PLUGHOST_H

#include <windows.h>

// Forward declarations
struct TFruityPlug;

// TFruityPlugHost - interface to communicate with FL Studio host
struct TFruityPlugHost {
    // Host tag
    int HostTag;
    
    // Get version of FL Studio
    virtual int GetVersion() = 0;
    
    // Get window handle of the host
    virtual HWND GetMainWindow() = 0;
    
    // Call the host dispatcher
    virtual int Dispatcher(TFruityPlug *Plug, int ID, int Index, int Value) = 0;
    
    // Send MIDI out
    virtual void MIDIOut(TFruityPlug *Plug, int Msg) = 0;
    
    // Send MIDI out (extended)
    virtual void MIDIOut_Ext(TFruityPlug *Plug, void *MidiMsg) = 0;
    
    // Get pointer to a published wavetable
    virtual void *GetWaveTable(int Index) = 0;
    
    // Get sample rate
    virtual int GetSampleRate() = 0;
    
    // Get tempo in BPM
    virtual float GetTempo() = 0;
    
    // Get position in song
    virtual int GetSongPos() = 0;
    
    // Get position in pattern
    virtual int GetPatternPos() = 0;
    
    // Get current pattern number
    virtual int GetCurrentPattern() = 0;
    
    // Get position in step
    virtual int GetStepPos() = 0;
    
    // Is playing?
    virtual BOOL IsPlaying() = 0;
    
    // Is rendering?
    virtual BOOL IsRendering() = 0;
    
    // Get buffer length in samples
    virtual int GetBufferLen() = 0;
    
    // Lock (for thread safety)
    virtual void Lock(TFruityPlug *Plug) = 0;
    
    // Unlock (for thread safety)
    virtual void Unlock(TFruityPlug *Plug) = 0;
};

typedef TFruityPlugHost *PFruityPlugHost;

#endif // FP_PLUGHOST_H
