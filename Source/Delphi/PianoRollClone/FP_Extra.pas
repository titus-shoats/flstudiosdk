unit FP_Extra;

interface

uses
  Windows, FP_Def;

// Extra helper functions and utilities

function MakeLong(Lo, Hi: Word): LongInt;
function LoWord(L: LongInt): Word;
function HiWord(L: LongInt): Word;

implementation

function MakeLong(Lo, Hi: Word): LongInt;
begin
  Result := (Hi shl 16) or Lo;
end;

function LoWord(L: LongInt): Word;
begin
  Result := Word(L and $FFFF);
end;

function HiWord(L: LongInt): Word;
begin
  Result := Word((L shr 16) and $FFFF);
end;

end.
