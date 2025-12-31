unit PianoRollEditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, FP_PlugClass, FP_DelphiPlug;

const
  PIANO_KEY_WIDTH = 50;
  NOTE_HEIGHT = 12;
  GRID_WIDTH = 24;
  GRID_STEPS_PER_BEAT = 4;
  
  // FL Studio Dark Theme Colors
  COLOR_BACKGROUND = $242424;
  COLOR_GRID_LINE = $282828;
  COLOR_BEAT_LINE = $404040;
  COLOR_PIANO_WHITE = $606060;
  COLOR_PIANO_BLACK = $404040;
  COLOR_PIANO_BORDER = $202020;
  COLOR_NOTE_BORDER = $101010;
  COLOR_NOTE_SELECTED = $FF8040;
  COLOR_VELOCITY_BAR = $FF4040;

type
  TToolMode = (tmDraw, tmSelect, tmErase);

  TPianoRollEditorForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
  private
    FBackBuffer: TBitmap;
    FToolMode: TToolMode;
    FScrollX: Integer;
    FScrollY: Integer;
    FZoomX: Single;
    FZoomY: Single;
    FDragging: Boolean;
    FDragStartX: Integer;
    FDragStartY: Integer;
    FDragNoteIndex: Integer;
    FResizing: Boolean;
    FPlayheadPos: Integer;
    
    procedure CreateBackBuffer;
    procedure DrawPianoKeys(Canvas: TCanvas);
    procedure DrawGrid(Canvas: TCanvas);
    procedure DrawNotes(Canvas: TCanvas);
    procedure DrawPlayhead(Canvas: TCanvas);
    function SnapToGrid(Value: Integer): Integer;
    function PixelToNote(Y: Integer): Integer;
    function NoteToPixel(Note: Integer): Integer;
    function PixelToTime(X: Integer): Integer;
    function TimeToPixel(Time: Integer): Integer;
    function GetNoteAt(X, Y: Integer): Integer;
    function IsBlackKey(Note: Integer): Boolean;
    procedure UpdateScrollbars;
  public
    FruityPlug: TDelphiFruityPlug;
    procedure RedrawEditor;
  end;

var
  PianoRollEditorForm: TPianoRollEditorForm;

implementation

uses
  PianoRollPlugin, Math;

{$R *.dfm}

procedure TPianoRollEditorForm.FormCreate(Sender: TObject);
begin
  FBackBuffer := nil;
  FToolMode := tmDraw;
  FScrollX := 0;
  FScrollY := 60 * NOTE_HEIGHT;  // Center around middle C
  FZoomX := 1.0;
  FZoomY := 1.0;
  FDragging := False;
  FResizing := False;
  FDragNoteIndex := -1;
  FPlayheadPos := 0;
  
  // Form settings
  Width := 800;
  Height := 600;
  Caption := 'Piano Roll Clone';
  Color := COLOR_BACKGROUND;
  DoubleBuffered := True;
  KeyPreview := True;
  
  CreateBackBuffer;
end;

procedure TPianoRollEditorForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FBackBuffer) then
    FBackBuffer.Free;
end;

procedure TPianoRollEditorForm.CreateBackBuffer;
begin
  if Assigned(FBackBuffer) then
    FBackBuffer.Free;
    
  FBackBuffer := TBitmap.Create;
  FBackBuffer.Width := ClientWidth;
  FBackBuffer.Height := ClientHeight;
  FBackBuffer.PixelFormat := pf24bit;
end;

procedure TPianoRollEditorForm.FormResize(Sender: TObject);
begin
  CreateBackBuffer;
  Invalidate;
end;

procedure TPianoRollEditorForm.FormPaint(Sender: TObject);
begin
  if not Assigned(FBackBuffer) then
    CreateBackBuffer;
    
  // Clear background
  FBackBuffer.Canvas.Brush.Color := COLOR_BACKGROUND;
  FBackBuffer.Canvas.FillRect(Rect(0, 0, FBackBuffer.Width, FBackBuffer.Height));
  
  // Draw components
  DrawGrid(FBackBuffer.Canvas);
  DrawPianoKeys(FBackBuffer.Canvas);
  DrawNotes(FBackBuffer.Canvas);
  DrawPlayhead(FBackBuffer.Canvas);
  
  // Copy to form
  Canvas.Draw(0, 0, FBackBuffer);
end;

procedure TPianoRollEditorForm.DrawPianoKeys(Canvas: TCanvas);
var
  i, Y: Integer;
  KeyRect: TRect;
  IsBlack: Boolean;
begin
  Canvas.Pen.Color := COLOR_PIANO_BORDER;
  
  // Draw 88 keys (MIDI 21-108)
  for i := 0 to 127 do
  begin
    Y := NoteToPixel(i);
    
    if (Y + NOTE_HEIGHT < 0) or (Y > ClientHeight) then
      Continue;
      
    IsBlack := IsBlackKey(i);
    
    KeyRect := Rect(0, Y, PIANO_KEY_WIDTH, Y + NOTE_HEIGHT);
    
    if IsBlack then
      Canvas.Brush.Color := COLOR_PIANO_BLACK
    else
      Canvas.Brush.Color := COLOR_PIANO_WHITE;
      
    Canvas.Rectangle(KeyRect);
    
    // Highlight C keys
    if (i mod 12) = 0 then
    begin
      Canvas.Pen.Color := clWhite;
      Canvas.MoveTo(0, Y);
      Canvas.LineTo(PIANO_KEY_WIDTH, Y);
      Canvas.Pen.Color := COLOR_PIANO_BORDER;
    end;
  end;
end;

procedure TPianoRollEditorForm.DrawGrid(Canvas: TCanvas);
var
  X, Y: Integer;
  GridX: Integer;
  MaxX, MaxY: Integer;
  IsBeatLine: Boolean;
begin
  MaxX := ClientWidth;
  MaxY := ClientHeight;
  
  // Draw vertical grid lines
  X := PIANO_KEY_WIDTH;
  GridX := 0;
  while X < MaxX do
  begin
    IsBeatLine := (GridX mod GRID_STEPS_PER_BEAT) = 0;
    
    if IsBeatLine then
      Canvas.Pen.Color := COLOR_BEAT_LINE
    else
      Canvas.Pen.Color := COLOR_GRID_LINE;
      
    Canvas.MoveTo(X, 0);
    Canvas.LineTo(X, MaxY);
    
    Inc(GridX);
    X := PIANO_KEY_WIDTH + Round(GridX * GRID_WIDTH * FZoomX) - FScrollX;
  end;
  
  // Draw horizontal grid lines (for each note)
  for Y := 0 to 127 do
  begin
    GridX := NoteToPixel(Y);
    
    if (GridX < 0) or (GridX > MaxY) then
      Continue;
      
    Canvas.Pen.Color := COLOR_GRID_LINE;
    Canvas.MoveTo(PIANO_KEY_WIDTH, GridX);
    Canvas.LineTo(MaxX, GridX);
  end;
end;

procedure TPianoRollEditorForm.DrawNotes(Canvas: TCanvas);
var
  i: Integer;
  Plugin: TPianoRollPlugin;
  Note: PPianoNote;
  NoteRect: TRect;
  X, Y, W: Integer;
  VelocityColor: TColor;
  VelFactor: Single;
begin
  if not Assigned(FruityPlug) then
    Exit;
    
  Plugin := TPianoRollPlugin(FruityPlug);
  
  for i := 0 to Plugin.GetNoteCount - 1 do
  begin
    Note := Plugin.GetNote(i);
    if not Assigned(Note) then
      Continue;
      
    X := TimeToPixel(Note^.Position);
    Y := NoteToPixel(Note^.Note);
    W := Round(Note^.Length * GRID_WIDTH * FZoomX / PPQ);
    
    // Skip if outside visible area
    if (X + W < PIANO_KEY_WIDTH) or (X > ClientWidth) or
       (Y + NOTE_HEIGHT < 0) or (Y > ClientHeight) then
      Continue;
      
    NoteRect := Rect(X, Y, X + W, Y + NOTE_HEIGHT);
    
    // Calculate velocity-based color (blue gradient)
    VelFactor := Note^.Velocity / 127.0;
    if Note^.Selected then
      VelocityColor := COLOR_NOTE_SELECTED
    else
    begin
      // Blue gradient: darker blue at low velocity, brighter at high
      VelocityColor := RGB(
        Round(30 + VelFactor * 80),   // Red
        Round(60 + VelFactor * 120),  // Green
        Round(120 + VelFactor * 135)  // Blue
      );
    end;
    
    // Draw note background
    Canvas.Brush.Color := VelocityColor;
    Canvas.Pen.Color := COLOR_NOTE_BORDER;
    Canvas.Rectangle(NoteRect);
    
    // Draw velocity bar on left edge
    Canvas.Brush.Color := RGB(
      Min(255, (VelocityColor and $FF) + 40),
      Min(255, ((VelocityColor shr 8) and $FF) + 40),
      Min(255, ((VelocityColor shr 16) and $FF) + 40)
    );
    Canvas.FillRect(Rect(X, Y, X + 3, Y + NOTE_HEIGHT));
  end;
end;

procedure TPianoRollEditorForm.DrawPlayhead(Canvas: TCanvas);
var
  X: Integer;
begin
  X := TimeToPixel(FPlayheadPos);
  
  if (X >= PIANO_KEY_WIDTH) and (X < ClientWidth) then
  begin
    Canvas.Pen.Color := clYellow;
    Canvas.Pen.Width := 2;
    Canvas.MoveTo(X, 0);
    Canvas.LineTo(X, ClientHeight);
    Canvas.Pen.Width := 1;
  end;
end;

procedure TPianoRollEditorForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Plugin: TPianoRollPlugin;
  NoteIndex: Integer;
  Time, Note: Integer;
begin
  if not Assigned(FruityPlug) then
    Exit;
    
  Plugin := TPianoRollPlugin(FruityPlug);
  
  if Button = mbLeft then
  begin
    case FToolMode of
      tmDraw:
        begin
          // Check if clicking on existing note
          NoteIndex := GetNoteAt(X, Y);
          
          if NoteIndex >= 0 then
          begin
            // Start dragging
            FDragging := True;
            FDragNoteIndex := NoteIndex;
            FDragStartX := X;
            FDragStartY := Y;
          end
          else if X > PIANO_KEY_WIDTH then
          begin
            // Add new note
            Time := SnapToGrid(PixelToTime(X));
            Note := PixelToNote(Y);
            Plugin.AddNote(Time, PPQ, Note, 100, 0);  // Default velocity 100
            Invalidate;
          end;
        end;
        
      tmSelect:
        begin
          NoteIndex := GetNoteAt(X, Y);
          if NoteIndex >= 0 then
          begin
            // Toggle selection
            with Plugin.GetNote(NoteIndex)^ do
              Selected := not Selected;
            Invalidate;
          end;
        end;
        
      tmErase:
        begin
          NoteIndex := GetNoteAt(X, Y);
          if NoteIndex >= 0 then
          begin
            Plugin.RemoveNote(NoteIndex);
            Invalidate;
          end;
        end;
    end;
  end
  else if Button = mbRight then
  begin
    // Delete note on right-click
    NoteIndex := GetNoteAt(X, Y);
    if NoteIndex >= 0 then
    begin
      Plugin.RemoveNote(NoteIndex);
      Invalidate;
    end;
  end;
end;

procedure TPianoRollEditorForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FDragging and (FDragNoteIndex >= 0) then
  begin
    // TODO: Implement note dragging
    // This would require modifying the note's position
  end;
end;

procedure TPianoRollEditorForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDragging := False;
  FResizing := False;
  FDragNoteIndex := -1;
end;

procedure TPianoRollEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Plugin: TPianoRollPlugin;
begin
  if not Assigned(FruityPlug) then
    Exit;
    
  Plugin := TPianoRollPlugin(FruityPlug);
  
  case Key of
    VK_DELETE:
      begin
        // Delete selected notes
        // TODO: Implement deletion of selected notes
      end;
      
    Ord('C'):
      begin
        if ssCtrl in Shift then
        begin
          // Copy selected notes
          // TODO: Implement copy
        end;
      end;
      
    Ord('V'):
      begin
        if ssCtrl in Shift then
        begin
          // Paste notes
          // TODO: Implement paste
        end;
      end;
      
    Ord('A'):
      begin
        if ssCtrl in Shift then
        begin
          // Select all
          // TODO: Implement select all
        end;
      end;
  end;
end;

function TPianoRollEditorForm.SnapToGrid(Value: Integer): Integer;
var
  GridSize: Integer;
  Plugin: TPianoRollPlugin;
begin
  if Assigned(FruityPlug) then
  begin
    Plugin := TPianoRollPlugin(FruityPlug);
    GridSize := PPQ div Plugin.ParamValue[0];  // Grid snap parameter
    Result := (Value div GridSize) * GridSize;
  end
  else
    Result := Value;
end;

function TPianoRollEditorForm.PixelToNote(Y: Integer): Integer;
begin
  Result := 127 - ((Y + FScrollY) div NOTE_HEIGHT);
  if Result < 0 then Result := 0;
  if Result > 127 then Result := 127;
end;

function TPianoRollEditorForm.NoteToPixel(Note: Integer): Integer;
begin
  Result := (127 - Note) * NOTE_HEIGHT - FScrollY;
end;

function TPianoRollEditorForm.PixelToTime(X: Integer): Integer;
begin
  Result := Round(((X - PIANO_KEY_WIDTH + FScrollX) / (GRID_WIDTH * FZoomX)) * PPQ);
  if Result < 0 then Result := 0;
end;

function TPianoRollEditorForm.TimeToPixel(Time: Integer): Integer;
begin
  Result := PIANO_KEY_WIDTH + Round((Time * GRID_WIDTH * FZoomX) / PPQ) - FScrollX;
end;

function TPianoRollEditorForm.GetNoteAt(X, Y: Integer): Integer;
var
  i: Integer;
  Plugin: TPianoRollPlugin;
  Note: PPianoNote;
  NoteX, NoteY, NoteW: Integer;
begin
  Result := -1;
  
  if not Assigned(FruityPlug) then
    Exit;
    
  Plugin := TPianoRollPlugin(FruityPlug);
  
  for i := Plugin.GetNoteCount - 1 downto 0 do
  begin
    Note := Plugin.GetNote(i);
    if not Assigned(Note) then
      Continue;
      
    NoteX := TimeToPixel(Note^.Position);
    NoteY := NoteToPixel(Note^.Note);
    NoteW := Round(Note^.Length * GRID_WIDTH * FZoomX / PPQ);
    
    if (X >= NoteX) and (X < NoteX + NoteW) and
       (Y >= NoteY) and (Y < NoteY + NOTE_HEIGHT) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TPianoRollEditorForm.IsBlackKey(Note: Integer): Boolean;
var
  Key: Integer;
begin
  Key := Note mod 12;
  Result := (Key = 1) or (Key = 3) or (Key = 6) or (Key = 8) or (Key = 10);
end;

procedure TPianoRollEditorForm.UpdateScrollbars;
begin
  // TODO: Implement scrollbar logic if needed
end;

procedure TPianoRollEditorForm.RedrawEditor;
begin
  Invalidate;
end;

end.
