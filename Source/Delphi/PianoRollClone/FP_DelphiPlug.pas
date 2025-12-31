unit FP_DelphiPlug;

interface

uses
  Windows, Classes, SyncObjs, Forms, FP_Def, FP_PlugClass;

type
  TDelphiFruityPlug = class(TFruityPlug)
  public
    PlugHost: TFruityPlugHost;
    EditorForm: TForm;
    SmpRate: integer;
    PitchMul: single;
    CriticalSection: TCriticalSection;

    constructor Create(SetTag: integer; Host: TFruityPlugHost);
    destructor Destroy; override;

    // Helper functions
    function GetStep_Cents(Pitch: integer): integer;
    function GetStep_Cents_S(Pitch: single): integer;
    function GetStep_Freq(Freq: integer): integer;
    procedure ProcessAllParams;
    procedure SkipRendering(SourceBuffer, DestBuffer: pointer; Length: integer);
    procedure ShowHintMsg(const Msg: string);
    procedure ShowHintMsg_Direct(const Msg: string);
    procedure ShowHintMsg_Percent(Value, Max: integer);
    procedure ShowHintMsg_Pitch(Value, PitchType: integer);
    procedure ShowHintMsg_Gauge(const Msg: string; Value, Max: integer);
    procedure Lock;
    procedure Unlock;

    // Default implementations
    procedure Idle; override;
    function ProcessEvent(EventID, EventValue, Flags: integer): integer; override;
    procedure MsgIn(ID, Index, Value: integer); override;
    procedure MIDITick; override;
    procedure MIDIOut(var Msg: TMIDIOutMsg); override;
    procedure Eff_Render(SourceBuffer, DestBuffer: PWAV32FS; var Length: integer); override;
    procedure Voice_Render(Handle: TVoiceHandle; DestBuffer: PWAV32FS; var Length: integer); override;
  end;

implementation

uses
  SysUtils;

constructor TDelphiFruityPlug.Create(SetTag: integer; Host: TFruityPlugHost);
begin
  inherited Create;
  PlugHost := Host;
  PlugHost.Tag := SetTag;
  SmpRate := 44100;
  PitchMul := MiddleCMul / SmpRate;
  CriticalSection := TCriticalSection.Create;
  EditorForm := nil;
end;

destructor TDelphiFruityPlug.Destroy;
begin
  if Assigned(EditorForm) then
    EditorForm.Free;
  CriticalSection.Free;
  inherited;
end;

function TDelphiFruityPlug.GetStep_Cents(Pitch: integer): integer;
var
  Cents: single;
begin
  Cents := Pitch / 100.0;
  Result := Round(Power(2, Cents / 12.0) * PitchMul);
end;

function TDelphiFruityPlug.GetStep_Cents_S(Pitch: single): integer;
var
  Cents: single;
begin
  Cents := Pitch / 100.0;
  Result := Round(Power(2, Cents / 12.0) * PitchMul);
end;

function TDelphiFruityPlug.GetStep_Freq(Freq: integer): integer;
begin
  Result := Round(Freq * (1 shl WaveT_Shift) / SmpRate);
end;

procedure TDelphiFruityPlug.ProcessAllParams;
var
  i: integer;
begin
  if Assigned(Info) then
    for i := 0 to Info^.NumParams - 1 do
      ProcessParam(i, 0, REC_UpdateValue or REC_UpdateControl);
end;

procedure TDelphiFruityPlug.SkipRendering(SourceBuffer, DestBuffer: pointer; Length: integer);
begin
  if SourceBuffer <> DestBuffer then
    Move(SourceBuffer^, DestBuffer^, Length * SizeOf(TWAV32FS));
end;

procedure TDelphiFruityPlug.ShowHintMsg(const Msg: string);
begin
  if Assigned(PlugHost) then
    PlugHost.OnHint(0, PChar(Msg));
end;

procedure TDelphiFruityPlug.ShowHintMsg_Direct(const Msg: string);
begin
  ShowHintMsg(Msg);
end;

procedure TDelphiFruityPlug.ShowHintMsg_Percent(Value, Max: integer);
var
  Percent: integer;
begin
  if Max > 0 then
    Percent := (Value * 100) div Max
  else
    Percent := 0;
  ShowHintMsg(IntToStr(Percent) + '%');
end;

procedure TDelphiFruityPlug.ShowHintMsg_Pitch(Value, PitchType: integer);
begin
  ShowHintMsg(IntToStr(Value));
end;

procedure TDelphiFruityPlug.ShowHintMsg_Gauge(const Msg: string; Value, Max: integer);
var
  Percent: integer;
begin
  if Max > 0 then
    Percent := (Value * 100) div Max
  else
    Percent := 0;
  ShowHintMsg(Msg + ' ' + IntToStr(Percent) + '%');
end;

procedure TDelphiFruityPlug.Lock;
begin
  CriticalSection.Enter;
end;

procedure TDelphiFruityPlug.Unlock;
begin
  CriticalSection.Leave;
end;

// Default implementations
procedure TDelphiFruityPlug.Idle;
begin
  // Default: do nothing
end;

function TDelphiFruityPlug.ProcessEvent(EventID, EventValue, Flags: integer): integer;
begin
  Result := 0;
end;

procedure TDelphiFruityPlug.MsgIn(ID, Index, Value: integer);
begin
  // Default: do nothing
end;

procedure TDelphiFruityPlug.MIDITick;
begin
  // Default: do nothing
end;

procedure TDelphiFruityPlug.MIDIOut(var Msg: TMIDIOutMsg);
begin
  // Default: do nothing
end;

procedure TDelphiFruityPlug.Eff_Render(SourceBuffer, DestBuffer: PWAV32FS; var Length: integer);
begin
  SkipRendering(SourceBuffer, DestBuffer, Length);
end;

procedure TDelphiFruityPlug.Voice_Render(Handle: TVoiceHandle; DestBuffer: PWAV32FS; var Length: integer);
begin
  // Default: do nothing
end;

end.
