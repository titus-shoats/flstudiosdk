unit FP_PlugClass;

interface

uses
  Windows, FP_Def;

type
  // Forward declarations
  TFruityPlug = class;
  TFruityPlugHost = class;

  // Plugin info structure
  TFruityPlugInfo = record
    SDKVersion: integer;
    LongName: string[31];
    ShortName: string[15];
    Flags: integer;
    NumParams: integer;
    DefPoly: integer;
  end;
  PFruityPlugInfo = ^TFruityPlugInfo;

  // Voice parameter structure
  TVoiceParams = record
    InitLevels: record
      Pan: integer;
      Vol: single;
      Pitch: integer;
      FCut: single;
      FRes: single;
    end;
    FinalLevels: record
      Pan: integer;
      Vol: single;
      Pitch: integer;
      FCut: single;
      FRes: single;
    end;
  end;
  PVoiceParams = ^TVoiceParams;

  // Note parameters for piano roll
  TNoteParams = record
    Position: integer;    // in PPQ
    Length: integer;      // in PPQ
    Pan: integer;         // default=0
    Vol: single;          // default=100/128
    Note: integer;        // default=60
    Pitch: integer;       // default=0
    FCut: single;         // default=0
    FRes: single;         // default=0
  end;
  PNoteParams = ^TNoteParams;

  // Notes parameters structure
  TNotesParams = record
    Target: integer;      // 0=step seq (not supported yet), 1=piano roll
    Flags: integer;       // see NPF_EmptyFirst
    PatNum: integer;      // -1 for current
    ChanNum: integer;     // -1 for plugin's channel
    Count: integer;       // the # of notes in the structure
    NoteParams: array[0..0] of TNoteParams;  // array of notes
  end;
  PNotesParams = ^TNotesParams;

  // Main plugin class
  TFruityPlug = class
  public
    Info: PFruityPlugInfo;

    // Virtual methods to be overridden
    procedure DestroyObject; virtual; abstract;
    function Dispatcher(ID, Index, Value: integer): integer; virtual; abstract;
    procedure Idle; virtual; abstract;
    procedure SaveRestoreState(Stream: pointer; Save: LongBool); virtual; abstract;
    function ProcessParam(Index, Value, RECFlags: integer): integer; virtual; abstract;
    function ProcessEvent(EventID, EventValue, Flags: integer): integer; virtual; abstract;
    procedure GetName(Section, Index, Value: integer; Name: PChar); virtual; abstract;
    procedure MIDIIn(var Msg: integer); virtual; abstract;
    procedure MsgIn(ID, Index, Value: integer); virtual; abstract;
    procedure MIDITick; virtual; abstract;
    procedure MIDIOut(var Msg: TMIDIOutMsg); virtual; abstract;
    procedure Eff_Render(SourceBuffer, DestBuffer: PWAV32FS; var Length: integer); virtual; abstract;
    procedure Gen_Render(DestBuffer: PWAV32FS; var Length: integer); virtual; abstract;
    function TriggerVoice(VoiceParams: PVoiceParams; SetTag: integer): TVoiceHandle; virtual; abstract;
    procedure Voice_Release(Handle: TVoiceHandle); virtual; abstract;
    procedure Voice_Kill(Handle: TVoiceHandle); virtual; abstract;
    function Voice_ProcessEvent(Handle: TVoiceHandle; EventID, EventValue, Flags: integer): integer; virtual; abstract;
    procedure Voice_Render(Handle: TVoiceHandle; DestBuffer: PWAV32FS; var Length: integer); virtual; abstract;
  end;

  // Host callback class
  TFruityPlugHost = class
  public
    Tag: integer;
    Wavetables: array[0..5] of PWaveT;
    TempBuffers: array[0..1] of PWAV32FS;

    // Host methods
    function Dispatcher(ID, Index, Value: integer; Ptr: pointer): integer; virtual; abstract;
    procedure OnParamChanged(Index, Value: integer); virtual; abstract;
    procedure OnHint(Index: integer; Name: PChar); virtual; abstract;
    procedure Voice_Kill(Handle: TVoiceHandle; KillInternal: LongBool); virtual; abstract;
    procedure ComputeLRVol(var LVol, RVol: single; Pan, Vol: single); virtual; abstract;
    procedure AddWave_32FM_32FS_Ramp(SrcBuf: PWAV32FM; DestBuf: PWAV32FS; Length: integer; 
      DestLVol, DestRVol: single; var SrcLVol, SrcRVol: single); virtual; abstract;
  end;

implementation

end.
