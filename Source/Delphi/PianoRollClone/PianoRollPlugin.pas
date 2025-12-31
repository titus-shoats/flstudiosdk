unit PianoRollPlugin;

interface

uses
  Windows, Classes, ActiveX, SysUtils, FP_PlugClass, FP_DelphiPlug, FP_Def, FP_Extra;

const
  NumParamsConst = 5;  // Grid snap, Zoom X, Zoom Y, Volume, Pan
  PPQ = 96;            // Pulses Per Quarter note

var
  PlugInfo: TFruityPlugInfo = (
    SDKVersion: CurrentSDKVersion;
    LongName: 'Piano Roll Clone';
    ShortName: 'PRClone';
    Flags: FPF_Type_FullGen;
    NumParams: NumParamsConst;
    DefPoly: 0  // infinite polyphony
  );

type
  // Note structure for internal storage
  TPianoNote = record
    Position: Integer;    // in PPQ
    Length: Integer;      // in PPQ
    Note: Integer;        // 0-127 MIDI note
    Velocity: Integer;    // 0-127
    Pan: Integer;         // -64 to +64
    Selected: Boolean;
  end;
  PPianoNote = ^TPianoNote;

  // Voice structure
  PVoice = ^TVoice;
  TVoice = record
    Params: PVoiceParams;
    HostTag: TVoiceHandle;
    Gated: Boolean;
    CurrentPitch: Integer;
    Position: Integer;
    Speed: Integer;
    LastLVol: Single;
    LastRVol: Single;
    NoteNum: Integer;     // MIDI note number
  end;

  // Main plugin class
  TPianoRollPlugin = class(TDelphiFruityPlug)
  public
    ParamValue: array[0..NumParamsConst-1] of Integer;
    VoiceList: TList;
    NoteList: TList;      // List of TPianoNote records
    CurrentTime: Integer; // Current playback position in PPQ

    constructor Create(SetTag: Integer; Host: TFruityPlugHost);
    procedure DestroyObject; override;
    function Dispatcher(ID, Index, Value: Integer): Integer; override;
    procedure SaveRestoreState(Stream: pointer; Save: LongBool); override;
    procedure GetName(Section, Index, Value: Integer; Name: PChar); override;
    function ProcessParam(ThisIndex, ThisValue, RECFlags: Integer): Integer; override;
    procedure Gen_Render(DestBuffer: PWAV32FS; var Length: Integer); override;
    function TriggerVoice(VoiceParams: PVoiceParams; SetTag: Integer): TVoiceHandle; override;
    procedure Voice_Release(Handle: TVoiceHandle); override;
    procedure Voice_Kill(Handle: TVoiceHandle); override;
    function Voice_ProcessEvent(Handle: TVoiceHandle; EventID, EventValue, Flags: Integer): Integer; override;
    procedure MIDIIn(var Msg: Integer); override;

    // Note management
    procedure AddNote(APosition, ALength, ANote, AVelocity, APan: Integer);
    procedure RemoveNote(NoteIndex: Integer);
    procedure ClearNotes;
    function GetNoteCount: Integer;
    function GetNote(Index: Integer): PPianoNote;
    procedure SendNotesToHost;
  end;

// Export function
function CreatePlugInstance(Host: TFruityPlugHost; Tag: Integer): TFruityPlug; stdcall;

implementation

uses
  PianoRollEditor, Controls, Math;

// Create plugin instance
function CreatePlugInstance(Host: TFruityPlugHost; Tag: Integer): TFruityPlug;
begin
  Result := TPianoRollPlugin.Create(Tag, Host);
end;

// Constructor
constructor TPianoRollPlugin.Create(SetTag: Integer; Host: TFruityPlugHost);
var
  i: Integer;
begin
  inherited Create(SetTag, Host);
  
  Info := @PlugInfo;
  VoiceList := TList.Create;
  NoteList := TList.Create;
  CurrentTime := 0;

  // Initialize parameters
  ParamValue[0] := 16;   // Grid snap (1/16)
  ParamValue[1] := 100;  // Zoom X (100%)
  ParamValue[2] := 100;  // Zoom Y (100%)
  ParamValue[3] := 80;   // Volume (80%)
  ParamValue[4] := 0;    // Pan (center)

  // Create editor form
  EditorForm := TPianoRollEditorForm.Create(nil);
  with TPianoRollEditorForm(EditorForm) do
  begin
    FruityPlug := Self;
  end;
end;

// Destructor
procedure TPianoRollPlugin.DestroyObject;
var
  i: Integer;
begin
  // Free all notes
  ClearNotes;
  NoteList.Free;
  VoiceList.Free;
  inherited;
end;

// Dispatcher - handles messages from host
function TPianoRollPlugin.Dispatcher(ID, Index, Value: Integer): Integer;
begin
  Result := 0;

  case ID of
    FPD_ShowEditor:
      begin
        if Assigned(EditorForm) then
        begin
          if Value = 0 then
            EditorForm.Hide
          else
          begin
            EditorForm.Show;
            EditorForm.BringToFront;
          end;
        end;
      end;

    FPD_SetSampleRate:
      begin
        SmpRate := Value;
        PitchMul := MiddleCMul / SmpRate;
      end;

    FPD_SetPlaying:
      begin
        if Value = 0 then
          CurrentTime := 0;
      end;
  end;
end;

// Save/restore state
procedure TPianoRollPlugin.SaveRestoreState(Stream: pointer; Save: LongBool);
var
  IStream: IStream;
  BytesWritten: LongInt;
  i: Integer;
  NoteCount: Integer;
  Note: PPianoNote;
begin
  IStream := IStream(Stream);
  
  if Save then
  begin
    // Save parameters
    IStream.Write(@ParamValue, SizeOf(ParamValue), @BytesWritten);
    
    // Save note count
    NoteCount := NoteList.Count;
    IStream.Write(@NoteCount, SizeOf(NoteCount), @BytesWritten);
    
    // Save notes
    for i := 0 to NoteList.Count - 1 do
    begin
      Note := PPianoNote(NoteList[i]);
      IStream.Write(Note, SizeOf(TPianoNote), @BytesWritten);
    end;
  end
  else
  begin
    // Load parameters
    IStream.Read(@ParamValue, SizeOf(ParamValue), @BytesWritten);
    
    // Clear existing notes
    ClearNotes;
    
    // Load note count
    IStream.Read(@NoteCount, SizeOf(NoteCount), @BytesWritten);
    
    // Load notes
    for i := 0 to NoteCount - 1 do
    begin
      New(Note);
      IStream.Read(Note, SizeOf(TPianoNote), @BytesWritten);
      NoteList.Add(Note);
    end;
    
    // Update editor if visible
    if Assigned(EditorForm) and EditorForm.Visible then
      TPianoRollEditorForm(EditorForm).Invalidate;
  end;
end;

// Get parameter names
procedure TPianoRollPlugin.GetName(Section, Index, Value: Integer; Name: PChar);
var
  TempStr: string;
begin
  TempStr := '';
  
  case Section of
    FPN_Param:
      begin
        case Index of
          0: TempStr := 'Grid Snap';
          1: TempStr := 'Zoom X';
          2: TempStr := 'Zoom Y';
          3: TempStr := 'Volume';
          4: TempStr := 'Pan';
        end;
      end;
      
    FPN_ParamValue:
      begin
        case Index of
          0: TempStr := '1/' + IntToStr(ParamValue[0]);
          1: TempStr := IntToStr(ParamValue[1]) + '%';
          2: TempStr := IntToStr(ParamValue[2]) + '%';
          3: TempStr := IntToStr(ParamValue[3]) + '%';
          4: TempStr := IntToStr(ParamValue[4]);
        end;
      end;
  end;
  
  StrPCopy(Name, TempStr);
end;

// Process parameter changes
function TPianoRollPlugin.ProcessParam(ThisIndex, ThisValue, RECFlags: Integer): Integer;
begin
  Result := 0;
  
  if (RECFlags and REC_UpdateValue) <> 0 then
    ParamValue[ThisIndex] := ThisValue;

  if (RECFlags and REC_ShowHint) <> 0 then
  begin
    case ThisIndex of
      0: ShowHintMsg('Grid: 1/' + IntToStr(ParamValue[0]));
      1: ShowHintMsg('Zoom X: ' + IntToStr(ParamValue[1]) + '%');
      2: ShowHintMsg('Zoom Y: ' + IntToStr(ParamValue[2]) + '%');
      3: ShowHintMsg('Volume: ' + IntToStr(ParamValue[3]) + '%');
      4: ShowHintMsg('Pan: ' + IntToStr(ParamValue[4]));
    end;
  end;

  // Update editor if visible
  if Assigned(EditorForm) and EditorForm.Visible then
    TPianoRollEditorForm(EditorForm).Invalidate;
end;

// Render audio
procedure TPianoRollPlugin.Gen_Render(DestBuffer: PWAV32FS; var Length: Integer);
var
  i, j: Integer;
  Voice: PVoice;
  LVol, RVol: Single;
  Level: Single;
  Buffer: PWAV32FM;
  Sample: Single;
begin
  Buffer := pointer(PlugHost.TempBuffers[0]);
  Level := ParamValue[3] * 0.01 * 0.5;  // Volume parameter

  // Render each voice
  for i := 0 to VoiceList.Count - 1 do
  begin
    Voice := VoiceList[i];

    // Calculate volumes
    if Voice^.Gated then
    begin
      LVol := 0;
      RVol := 0;
    end
    else
      PlugHost.ComputeLRVol(LVol, RVol, Voice^.Params^.FinalLevels.Pan, 
                            Voice^.Params^.FinalLevels.Vol);

    // Handle pitch changes (for slides)
    if Voice^.Params^.FinalLevels.Pitch <> Voice^.CurrentPitch then
    begin
      Voice^.CurrentPitch := Voice^.Params^.FinalLevels.Pitch;
      Voice^.Speed := GetStep_Cents(Voice^.CurrentPitch);
    end;

    // Generate samples using sine wave from wavetable
    for j := 0 to Length - 1 do
    begin
      Sample := PlugHost.Wavetables[0]^[Voice^.Position shr WaveT_Shift];
      Buffer^[j] := Sample * Level;
      
      {$Q-} // Disable overflow checking for position increment
      Inc(Voice^.Position, Voice^.Speed);
      {$Q+}
    end;

    // Add to output with ramping
    PlugHost.AddWave_32FM_32FS_Ramp(Buffer, DestBuffer, Length, LVol, RVol,
                                     Voice^.LastLVol, Voice^.LastRVol);
  end;

  // Kill gated voices
  for i := VoiceList.Count - 1 downto 0 do
  begin
    Voice := VoiceList[i];
    if Voice^.Gated then
      PlugHost.Voice_Kill(Voice^.HostTag, True);
  end;
end;

// Trigger voice
function TPianoRollPlugin.TriggerVoice(VoiceParams: PVoiceParams; SetTag: Integer): TVoiceHandle;
var
  Voice: PVoice;
begin
  New(Voice);
  with Voice^ do
  begin
    HostTag := SetTag;
    Params := VoiceParams;
    Gated := False;
    Position := 0;
    CurrentPitch := VoiceParams^.FinalLevels.Pitch;
    Speed := GetStep_Cents(CurrentPitch);
    LastLVol := 0;
    LastRVol := 0;
    NoteNum := 60;  // Default middle C
  end;

  VoiceList.Add(Voice);
  Result := TVoiceHandle(Voice);
end;

// Release voice
procedure TPianoRollPlugin.Voice_Release(Handle: TVoiceHandle);
begin
  PVoice(Handle)^.Gated := True;
end;

// Kill voice
procedure TPianoRollPlugin.Voice_Kill(Handle: TVoiceHandle);
begin
  VoiceList.Remove(Pointer(Handle));
  Dispose(PVoice(Handle));
end;

// Process voice event
function TPianoRollPlugin.Voice_ProcessEvent(Handle: TVoiceHandle; EventID, EventValue, Flags: Integer): Integer;
begin
  Result := 0;
end;

// Handle MIDI input
procedure TPianoRollPlugin.MIDIIn(var Msg: Integer);
var
  Status, Data1, Data2: Byte;
begin
  Status := Msg and $FF;
  Data1 := (Msg shr 8) and $FF;
  Data2 := (Msg shr 16) and $FF;

  // Handle note on/off messages
  if (Status and $F0) = $90 then  // Note On
  begin
    if Data2 > 0 then  // Velocity > 0
      AddNote(CurrentTime, PPQ, Data1, Data2, 0)
    else  // Velocity = 0 (Note Off)
      ; // Could remove note or mark as released
  end
  else if (Status and $F0) = $80 then  // Note Off
  begin
    // Could remove note or mark as released
  end;
end;

// Add note to list
procedure TPianoRollPlugin.AddNote(APosition, ALength, ANote, AVelocity, APan: Integer);
var
  Note: PPianoNote;
begin
  Lock;
  try
    New(Note);
    Note^.Position := APosition;
    Note^.Length := ALength;
    Note^.Note := ANote;
    Note^.Velocity := AVelocity;
    Note^.Pan := APan;
    Note^.Selected := False;
    NoteList.Add(Note);
  finally
    Unlock;
  end;
  
  // Update editor
  if Assigned(EditorForm) and EditorForm.Visible then
    TPianoRollEditorForm(EditorForm).Invalidate;
end;

// Remove note from list
procedure TPianoRollPlugin.RemoveNote(NoteIndex: Integer);
var
  Note: PPianoNote;
begin
  Lock;
  try
    if (NoteIndex >= 0) and (NoteIndex < NoteList.Count) then
    begin
      Note := PPianoNote(NoteList[NoteIndex]);
      Dispose(Note);
      NoteList.Delete(NoteIndex);
    end;
  finally
    Unlock;
  end;
  
  // Update editor
  if Assigned(EditorForm) and EditorForm.Visible then
    TPianoRollEditorForm(EditorForm).Invalidate;
end;

// Clear all notes
procedure TPianoRollPlugin.ClearNotes;
var
  i: Integer;
  Note: PPianoNote;
begin
  Lock;
  try
    for i := 0 to NoteList.Count - 1 do
    begin
      Note := PPianoNote(NoteList[i]);
      Dispose(Note);
    end;
    NoteList.Clear;
  finally
    Unlock;
  end;
end;

// Get note count
function TPianoRollPlugin.GetNoteCount: Integer;
begin
  Lock;
  try
    Result := NoteList.Count;
  finally
    Unlock;
  end;
end;

// Get note at index
function TPianoRollPlugin.GetNote(Index: Integer): PPianoNote;
begin
  Lock;
  try
    if (Index >= 0) and (Index < NoteList.Count) then
      Result := PPianoNote(NoteList[Index])
    else
      Result := nil;
  finally
    Unlock;
  end;
end;

// Send notes to FL Studio Piano Roll
procedure TPianoRollPlugin.SendNotesToHost;
var
  i: Integer;
  Note: PPianoNote;
  NotesParams: PNotesParams;
  DataSize: Integer;
begin
  if NoteList.Count = 0 then
    Exit;

  Lock;
  try
    // Allocate memory for notes structure
    DataSize := SizeOf(TNotesParams) + (NoteList.Count - 1) * SizeOf(TNoteParams);
    GetMem(NotesParams, DataSize);
    try
      // Fill header
      NotesParams^.Target := 1;  // Piano roll
      NotesParams^.Flags := NPF_EmptyFirst;
      NotesParams^.PatNum := -1;  // Current pattern
      NotesParams^.ChanNum := -1;  // Plugin's channel
      NotesParams^.Count := NoteList.Count;

      // Fill notes
      for i := 0 to NoteList.Count - 1 do
      begin
        Note := PPianoNote(NoteList[i]);
        with NotesParams^.NoteParams[i] do
        begin
          Position := Note^.Position;
          Length := Note^.Length;
          Note := Note^.Note;
          Vol := Note^.Velocity / 128.0;
          Pan := Note^.Pan;
          Pitch := 0;
          FCut := 0;
          FRes := 0;
        end;
      end;

      // Send to host
      PlugHost.Dispatcher(FHD_AddNotesToPR, 0, 0, NotesParams);
    finally
      FreeMem(NotesParams);
    end;
  finally
    Unlock;
  end;
end;

end.
