# FL Studio SDK - Delphi Source Files

This directory contains the **complete** FL Studio plugin SDK source files for Delphi development.

## Core Files

### Essential SDK Files
- **FP_PlugClass.pas** - Core plugin and host class definitions, all SDK constants
- **FP_DelphiPlug.pas** - Delphi helper class with utility functions and state management
- **FP_Def.pas** - Basic type definitions (audio buffers, MIDI structures, wavetables)
- **FP_Extra.pas** - Utility functions and mathematical helpers
- **GenericTransport.pas** - Transport control message definitions

## File Dependencies

```
Your Plugin Project
    ├── uses FP_DelphiPlug
    │   ├── uses FP_PlugClass
    │   │   ├── uses FP_Def
    │   │   └── uses GenericTransport
    │   └── uses FP_Extra
```

**Minimum required units in your plugin:**
```pascal
uses
  Windows, Forms, Classes, ActiveX,
  FP_DelphiPlug, FP_PlugClass, FP_Def, FP_Extra;
```

## Quick Start

### 1. Create Your Plugin Class

```pascal
unit MyPlugin;

interface

uses
  Windows, Classes, Forms, ActiveX,
  FP_DelphiPlug, FP_PlugClass, FP_Def, FP_Extra;

const
  NumParams = 2;

var
  PlugInfo: TFruityPlugInfo = (
    SDKVersion: CurrentSDKVersion;
    LongName: 'My Plugin';
    ShortName: 'MyPlug';
    Flags: FPF_Type_Effect;  // or FPF_Type_FullGen for generator
    NumParams: NumParams;
    DefPoly: 0;  // 0 for effects
    NumOutCtrls: 0;
    NumOutVoices: 0
  );

type
  TMyPlugin = class(TDelphiFruityPlug)
  public
    constructor Create(SetHostTag: Integer; SetPlugHost: TFruityPlugHost); override;
    procedure DestroyObject; override;
    
    function Dispatcher(ID, Index, Value: IntPtr): IntPtr; override;
    procedure SaveRestoreState(const Stream: IStream; Save: LongBool); override;
    procedure GetName(Section, Index, Value: Integer; Name: PAnsiChar); override;
    function ProcessEvent(EventID, EventValue, Flags: Integer): Integer; override;
    function ProcessParam(Index, Value, RECFlags: Integer): Integer; override;
    
    // For effects:
    procedure Eff_Render(SourceBuffer, DestBuffer: PWAV32FS; Length: Integer); override;
    
    // For generators (comment out Eff_Render and use this instead):
    // procedure Gen_Render(DestBuffer: PWAV32FS; var Length: Integer); override;
  end;

implementation

constructor TMyPlugin.Create(SetHostTag: Integer; SetPlugHost: TFruityPlugHost);
begin
  inherited Create(SetHostTag, SetPlugHost);
  Info := @PlugInfo;
  // Initialize your plugin here
end;

procedure TMyPlugin.DestroyObject;
begin
  // Cleanup here
  inherited;
end;

function TMyPlugin.Dispatcher(ID, Index, Value: IntPtr): IntPtr;
begin
  Result := 0;
  case ID of
    FPD_ShowEditor: begin
      // Handle editor show/hide
      // Value contains parent window handle when showing
    end;
    FPD_SetSampleRate: begin
      SmpRate := Value;
      PitchMul := MiddleCMul / SmpRate;
    end;
  end;
end;

procedure TMyPlugin.SaveRestoreState(const Stream: IStream; Save: LongBool);
begin
  // Save/load your plugin state here
  if Save then begin
    // Stream.Write(...)
  end else begin
    // Stream.Read(...)
  end;
end;

procedure TMyPlugin.GetName(Section, Index, Value: Integer; Name: PAnsiChar);
begin
  case Section of
    FPN_Param: begin
      case Index of
        0: StrCopy(Name, 'Parameter 1');
        1: StrCopy(Name, 'Parameter 2');
      end;
    end;
    FPN_ParamValue: begin
      // Format parameter value as string
      StrCopy(Name, PAnsiChar(AnsiString(IntToStr(Value))));
    end;
  end;
end;

function TMyPlugin.ProcessEvent(EventID, EventValue, Flags: Integer): Integer;
begin
  Result := 0;
  // Handle events like tempo changes, etc.
end;

function TMyPlugin.ProcessParam(Index, Value, RECFlags: Integer): Integer;
begin
  Result := Value;
  // Handle parameter changes
  if (RECFlags and REC_UpdateValue) <> 0 then begin
    // Update parameter value
  end;
  if (RECFlags and REC_ShowHint) <> 0 then begin
    // Show hint for parameter
  end;
end;

procedure TMyPlugin.Eff_Render(SourceBuffer, DestBuffer: PWAV32FS; Length: Integer);
var
  i: Integer;
begin
  // Process audio here
  for i := 0 to Length - 1 do begin
    DestBuffer[i][0] := SourceBuffer[i][0];  // Left channel
    DestBuffer[i][1] := SourceBuffer[i][1];  // Right channel
  end;
end;

end.
```

### 2. Create DLL Project File

```pascal
library MyPlugin;

uses
  MyPlugin in 'MyPlugin.pas',
  FP_DelphiPlug in '..\SDK\Delphi\FP_DelphiPlug.pas',
  FP_PlugClass in '..\SDK\Delphi\FP_PlugClass.pas',
  FP_Def in '..\SDK\Delphi\FP_Def.pas',
  FP_Extra in '..\SDK\Delphi\FP_Extra.pas',
  GenericTransport in '..\SDK\Delphi\GenericTransport.pas';

{$R *.res}

function CreatePlugInstance(Host: TFruityPlugHost; Tag: Integer): TFruityPlug; stdcall;
begin
  Result := TMyPlugin.Create(Tag, Host);
end;

exports
  CreatePlugInstance;

begin
end.
```

### 3. Compile and Install

1. **Compile** in Delphi as a 32-bit DLL
2. **Copy** `MyPlugin.dll` to `FL Studio\Plugins\Fruity\Effects\MyPlugin\` (or `Generators` for generators)
3. **Restart** FL Studio
4. Find your plugin in the effects/generators menu

## Plugin Types Reference

### Effect Plugin
```pascal
Flags := FPF_Type_Effect;  // Value: 0
DefPoly := 0;
// Implement: Eff_Render
```

### Full Generator (Synthesizer)
```pascal
Flags := FPF_Type_FullGen;  // Includes note input
DefPoly := 16;  // Max polyphony
// Implement: Gen_Render, TriggerVoice, Voice_Release, Voice_Kill
```

### Hybrid Generator (Uses FL Sampler)
```pascal
Flags := FPF_Type_HybridGen;
DefPoly := 16;
// Implement: Voice_Render
```

### Visual Plugin (No Audio)
```pascal
Flags := FPF_Type_Visual;
// Implement: Dispatcher only
```

## Important SDK Constants

### Plugin Flags (combine with `or`)
- `FPF_Generator` - Plugin is a generator
- `FPF_GetNoteInput` - Receives MIDI notes
- `FPF_NewVoiceParams` - **REQUIRED** - Use new voice param format
- `FPF_UseSampler` - Hybrid generator
- `FPF_NoWindow` - Show in channel settings (not floating window)
- `FPF_WantNewTick` - Called before each tick (for controllers)
- `FPF_CanSend` - Has access to send tracks
- `FPF_IsDelphi` - **Recommended** - Tell host it's Delphi

### Dispatcher Messages
- `FPD_ShowEditor` - Show/hide editor (Value = parent handle or 0)
- `FPD_SetSampleRate` - Sample rate changed (Value = new rate)
- `FPD_SetBlockSize` - Buffer size changed
- `FPD_Flush` - Clear buffers (continuity broken)

### Host Dispatcher Messages
- `FHD_AddNotesToPR` - Add notes to Piano Roll
- `FHD_NamesChanged` - Notify names changed
- `FHD_EditorResized` - Notify editor resized
- `FHD_WantIdle` - Enable/disable idle calls
- `FHD_SetNumParams` - Override parameter count

### ProcessParam Flags
- `REC_UpdateValue` - Update parameter value
- `REC_GetValue` - Retrieve current value
- `REC_ShowHint` - Update hint display
- `REC_UpdateControl` - Update UI control
- `REC_FromMIDI` - Value is 0-65536 from MIDI

## Key Types

### Audio Buffers
```pascal
PWAV32FS  // Stereo float buffer: Array[0..Length-1, 0..1] of Single
PWAV32FM  // Mono float buffer: Array[0..Length-1] of Single
PWaveT    // Wavetable: Array[0..16383] of Single
```

### Note Data
```pascal
TNoteParams = Packed Record
  Position, Length: Integer;  // in PPQ
  Pan: Integer;               // -64..64
  Vol: Single;                // 0..1
  Note: SmallInt;             // 0-127 MIDI note
  Color: SmallInt;            // 0-15 (MIDI channel)
  Pitch: Integer;             // cents
  FCut, FRes: Single;         // filter cutoff/resonance 0..1
End;
```

### Voice Parameters
```pascal
TLevelParams = Record
  Pan: Single;         // -1..1 (NOT Integer!)
  Vol: Single;         // 0..1
  Pitch: Single;       // in cents
  FCut, FRes: Single;  // 0..1
End;
```

## Thread Safety

### For Audio Rendering
```pascal
// Lock before accessing shared data:
LockMix_Shared;
try
  // Modify shared data
finally
  UnlockMix_Shared;
end;
```

### For Internal Operations
```pascal
{$DEFINE UseCriticalSection}  // In FP_DelphiPlug.pas

Lock;
try
  // Thread-safe operation
finally
  Unlock;
end;
```

## Utility Functions Available

From `FP_Extra.pas`:
- `MulShift16(a, b)` - Fast multiply and shift
- `MulDiv64(a, b, c)` - Fast MulDiv
- `MinOf(a, b)`, `MaxOf(a, b)` - Min/max values
- `Zeros(value, nZeros)` - Format with leading zeros
- `VolumeToVelocity(Volume)` - FL volume to 0..1
- `VolumeToMIDIVelocity(Volume)` - FL volume to 0..127

From `TDelphiFruityPlug`:
- `ShowHintMsg(Msg)` - Display hint text
- `ShowHintMsg_Percent(Value, Max)` - Show percentage
- `ShowHintMsg_Pitch(Value, PitchType)` - Show pitch value
- `ShowHintMsg_Pan(Value)` - Show pan position
- `Stream_StoreString(Stream, s)` - Save string to state
- `Stream_ReadString(Stream, s)` - Load string from state

## SDK Version

Current SDK Version: **1**

Always set: `SDKVersion := CurrentSDKVersion;`

## License

FL Studio SDK files - refer to Image-Line's SDK license terms for distribution and usage rights.

## Examples

See `/examples/` directory for complete working examples of different plugin types.

## Troubleshooting

### "Undeclared identifier" errors
- Make sure all 5 SDK units are in your uses clause and library path
- Check unit search path in Project Options

### Plugin doesn't appear in FL Studio
- Ensure DLL is 32-bit (even on 64-bit Windows)
- Check it's in correct folder structure
- Verify `CreatePlugInstance` is exported
- Check FL Studio's plugin manager for errors

### Access violations
- Always call `inherited Create(SetHostTag, SetPlugHost)`
- Set `Info := @PlugInfo` in constructor
- Don't forget thread synchronization for shared data
