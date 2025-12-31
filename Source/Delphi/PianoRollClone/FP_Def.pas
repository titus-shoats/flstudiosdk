unit FP_Def;

interface

uses
  Windows;

const
  // General constants
  CurrentSDKVersion = 1;
  WaveT_Size = 16384;
  WaveT_Shift = 18;
  MIDIMsg_PortMask = $FFFFFF;
  MIDIMsg_Null = $FFFFFFFF;
  MiddleCMul = 261.6255653 * (1 shl WaveT_Shift);

  // Plugin Flags
  FPF_Generator = 1;
  FPF_RenderVoice = 1 shl 1;
  FPF_UseSampler = 1 shl 2;
  FPF_GetChanCustomShape = 1 shl 3;
  FPF_GetNoteInput = 1 shl 4;
  FPF_WantNewTick = 1 shl 5;
  FPF_NoProcess = 1 shl 6;
  FPF_NoWindow = 1 shl 10;
  FPF_Interfaceless = 1 shl 11;
  FPF_TimeWarp = 1 shl 13;
  FPF_MidiOut = 1 shl 14;
  FPF_DemoVersion = 1 shl 15;
  FPF_CanSend = 1 shl 16;
  
  // Combined plugin types
  FPF_Type_Effect = 0;
  FPF_Type_FullGen = FPF_Generator;
  FPF_Type_HybridGen = FPF_Generator or FPF_UseSampler;

  // Messages from plugin to host
  FHD_PlugMenu_SetName = 0;
  FHD_GetParamMenuEntry = 1;
  FHD_ParamMenu_PopUp = 2;
  FHD_ParamMenu_SetItemName = 3;
  FHD_PanelResized = 4;
  FHD_WantMIDIInput = 5;
  FHD_SetNumParams = 6;
  FHD_GetMIDIInput = 7;
  FHD_MIDIControlDialog = 8;
  FHD_ShowSettings = 9;
  FHD_SetNewColor = 10;
  FHD_GetInstance = 11;
  FHD_EditSample = 12;
  FHD_MIDIIn_SetFocus = 13;
  FHD_KillIntWheelEvent = 14;
  FHD_Popup_Add = 15;
  FHD_NamesChanged = 16;
  FHD_AddNotesToPR = 17;
  FHD_SetDirty = 18;

  // Messages from host to plugin
  FPD_SetEnabled = 0;
  FPD_SetPlaying = 1;
  FPD_ShowEditor = 2;
  FPD_ProcessMode = 3;
  FPD_Flush = 4;
  FPD_SetBlockSize = 5;
  FPD_SetSampleRate = 6;
  FPD_KillVoice = 7;
  FPD_SetProgram = 8;

  // Parameter flags
  REC_UpdateValue = 1;
  REC_UpdateControl = 1 shl 1;
  REC_ShowHint = 1 shl 2;
  REC_UpdatePlugLabel = 1 shl 3;
  REC_ShowInternalCtrlHint = 1 shl 4;
  REC_InternalCtrl = 1 shl 5;
  REC_PlugReserved = 1 shl 6;
  REC_FromMIDI = 1 shl 7;
  REC_StoreValue = 1 shl 8;
  REC_Smoothed = 1 shl 9;
  
  // TNotesParams flags
  NPF_EmptyFirst = 1;
  
  // GetName sections
  FPN_Param = 0;
  FPN_ParamValue = 1;
  FPN_Semitone = 2;
  FPN_Patch = 3;
  FPN_VoiceLevel = 4;
  FPN_VoiceColor = 5;

type
  // Voice handle type
  TVoiceHandle = integer;

  // Wavetable types
  TWaveT = array[0..WaveT_Size-1] of single;
  PWaveT = ^TWaveT;

  // Stereo buffer types
  TWAV32FS = array[0..0, 0..1] of single;
  PWAV32FS = ^TWAV32FS;

  TWAV32FM = array[0..0] of single;
  PWAV32FM = ^TWAV32FM;

  // MIDI message structure
  TMIDIOutMsg = packed record
    Status: Byte;
    Data1: Byte;
    Data2: Byte;
    Port: Byte;
  end;
  PMIDIOutMsg = ^TMIDIOutMsg;

  // Time structure
  TFPTime = record
    AbsPos: integer;      // absolute position in samples
    BarPos: integer;      // position in ticks from bar start
    LoopPos: integer;     // loop position
    Clock: integer;       // clock
    Tempo: integer;       // tempo in 0.1 bpm (beats per minute * 10)
    BarLength: integer;   // bar length in ticks
    PPQ: integer;         // pulses per quarter note
    Flags: integer;       // flags
  end;
  PFPTime = ^TFPTime;

implementation

end.
