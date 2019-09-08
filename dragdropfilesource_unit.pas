{ Datei Drag&Drop Quelle
  für Drag&Drop zum Explorer

  aktueller Stand:
  - kann eine einzelne Datei
  - kann mehrere Dateien aus einem Ordner
  - hat Probleme in Verbindung mit Stringgrid/Listbox

  onmousedown
  dragdropquellform.ObjMouseDown_simple(Button, x, y, datei);

  onmousemove
  dragdropfilequellform.ObjMouseMove(x,y, [objekt].ControlState);

  08/2012 XE2 kompatibel
  02/2016 XE10 x64 Test
  xx/xxxx FPC Ubuntu

  --------------------------------------------------------------------
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY

  Last maintainer: Peter Lorenz
  Is that code useful for you? Donate!
  Paypal webmaster@peter-ebe.de
  --------------------------------------------------------------------

}

{$I ..\share_settings.inc}

unit dragdropfilesource_unit;

interface

{$IFNDEF UNIX}

uses
  Windows, ActiveX, ShlObj, ComObj,
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Types;

type
  PDragDropEvent = procedure(flag: boolean) of object;

type
  RDragdropfiles = record
    verzeichnis: string;
    dateinamen: array of string;
  end;

type
  TDragDropSource = class(TInterfacedObject, IDropSource)
  private
    Fdragdropfiles: RDragdropfiles;

    // Fdragdropaktiv:boolean;

    FonDragDropBegin: PDragDropEvent;
    FonDragDropEnd: PDragDropEvent;

    function GetFileListDataObject: IDataObject;

    // Interface Implementierung IDropSource
{$IFDEF FPC}
    function QueryContinueDrag(fEscapePressed: BOOL; grfKeyState: DWORD)
      : HResult; StdCall;
    function GiveFeedback(dwEffect: DWORD): HResult; StdCall;
{$ELSE}
    function QueryContinueDrag(fEscapePressed: BOOL; grfKeyState: Longint)
      : HResult; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; stdcall;
{$ENDIF}
  public
    constructor create;

    { ========== Funktionen für ext. Aufruf ========== }
    procedure KillFiles;
    procedure LoadFile(const filename: string);
    procedure LoadFiles(const filenames: RDragdropfiles);
    function CheckFiles: boolean;

    procedure StartDragDrop(Sender: TControl; At: TPoint);

    // property DragDropAktive : Boolean read Fdragdropaktiv;

    property onDragDropBegin: PDragDropEvent read FonDragDropBegin
      write FonDragDropBegin;
    property onDragDropEnd: PDragDropEvent read FonDragDropEnd
      write FonDragDropEnd;

    { ================================================ }
  end;

{$ENDIF}

implementation

{$IFNDEF UNIX}

constructor TDragDropSource.create;
begin
  inherited;

  Fdragdropfiles.verzeichnis := '';
  setlength(Fdragdropfiles.dateinamen, 0);

  // Fdragdropaktiv:= false;

  FonDragDropBegin := nil;
  FonDragDropEnd := nil;
end;

{ ---------------------------------------------------------------------------- }

{$IFDEF FPC}

function TDragDropQuelle.QueryContinueDrag(fEscapePressed: BOOL;
  grfKeyState: DWORD): HResult; StdCall;
{$ELSE}

function TDragDropSource.QueryContinueDrag(fEscapePressed: BOOL;
  grfKeyState: Longint): HResult; stdcall;
{$ENDIF}
begin
  { DragDrop fortsetzen }
  if (fEscapePressed = true) or ((grfKeyState and MK_RBUTTON) = MK_RBUTTON) then
  begin
    { Abrechen }
    Result := DRAGDROP_S_CANCEL;
    // Fdragdropaktiv:= false;
    if Assigned(FonDragDropEnd) then
      FonDragDropEnd(true);
  end
  else
  begin
    { Fortsetzen/Abschließen }
    if grfKeyState and MK_LBUTTON = 0 then
    begin
      Result := DRAGDROP_S_DROP;
      // Fdragdropaktiv:= false;
      if Assigned(FonDragDropEnd) then
        FonDragDropEnd(true);
    end
    else
    begin
      Result := S_OK;
    end;
  end;
end;

{$IFDEF FPC}

function TDragDropQuelle.GiveFeedback(dwEffect: DWORD): HResult; StdCall;
{$ELSE}

function TDragDropSource.GiveFeedback(dwEffect: Longint): HResult; stdcall;
{$ENDIF}
begin
  { Rückgabe }
  Result := DRAGDROP_S_USEDEFAULTCURSORS;
end;

{ ---------------------------------------------------------------------------- }

function TDragDropSource.CheckFiles: boolean;
var
  alleok: boolean;
  i: integer;
begin
  Result := false;
  if (length(Fdragdropfiles.verzeichnis) > 0) and
    (high(Fdragdropfiles.dateinamen) > -1) then
  begin
    alleok := true;
    for i := low(Fdragdropfiles.dateinamen)
      to high(Fdragdropfiles.dateinamen) do
      if fileexists(Fdragdropfiles.verzeichnis + Fdragdropfiles.dateinamen[i]) = false
      then
        alleok := false;
    if alleok = true then
      Result := true;
  end;
end;

procedure TDragDropSource.KillFiles;
begin
  Fdragdropfiles.verzeichnis := '';
  setlength(Fdragdropfiles.dateinamen, 0);
end;

procedure TDragDropSource.LoadFile(const filename: string);
begin
  { DragDrop vorbereiten }
  if (length(filename) > 0) then { Quelldatei übergeben }
  begin
    { Dateie merken }
    Fdragdropfiles.verzeichnis := extractfilepath(filename);
    if length(Fdragdropfiles.verzeichnis) > 0 then
      Fdragdropfiles.verzeichnis := IncludeTrailingPathDelimiter
        (Fdragdropfiles.verzeichnis);

    setlength(Fdragdropfiles.dateinamen, 1);
    Fdragdropfiles.dateinamen[0] := extractfilename(filename);
  end;
end;

procedure TDragDropSource.LoadFiles(const filenames: RDragdropfiles);
begin
  { DragDrop vorbereiten }
  if (length(filenames.verzeichnis) > 0) and { Quellverzeichnis übergeben }
    (high(filenames.dateinamen) > -1) then { Dateien übergeben }
  begin
    { Dateien merken }
    Fdragdropfiles := filenames;

    if length(Fdragdropfiles.verzeichnis) > 0 then
      Fdragdropfiles.verzeichnis := IncludeTrailingPathDelimiter
        (Fdragdropfiles.verzeichnis);
  end;
end;

function TDragDropSource.GetFileListDataObject: IDataObject;
type
  PArrayOfPItemIDList = ^TArrayOfPItemIDList;
  TArrayOfPItemIDList = array [0 .. 0] of PItemIDList;
var
  Malloc: IMalloc;
  Root: IShellFolder;
  FolderPidl: PItemIDList;
  Folder: IShellFolder;
  p: PArrayOfPItemIDList;
  chEaten: ULONG;
  dwAttributes: ULONG;
  FileCount: integer;
  i: integer;
begin
  { IData Object aus Dateiliste erzeugen }
  Result := nil;
  if length(Fdragdropfiles.verzeichnis) < 1 then
    exit;
  if high(Fdragdropfiles.dateinamen) < 0 then
    exit;
  OleCheck(SHGetMalloc(Malloc));
  OleCheck(SHGetDesktopFolder(Root));
  OleCheck(Root.ParseDisplayName(0, nil,
    PWideChar(WideString(Fdragdropfiles.verzeichnis)), chEaten, FolderPidl,
    dwAttributes));

  try
    OleCheck(Root.BindToObject(FolderPidl, nil, IShellFolder, Pointer(Folder)));
    FileCount := high(Fdragdropfiles.dateinamen) + 1;
    p := AllocMem(SizeOf(PItemIDList) * FileCount);
    try
      for i := 0 to FileCount - 1 do
      begin
        OleCheck(Folder.ParseDisplayName(0, nil,
          PWideChar(WideString(Fdragdropfiles.dateinamen[i])), chEaten, p^[i],
          dwAttributes));
      end;
      OleCheck(Folder.GetUIObjectOf(0, FileCount, p^[0], IDataObject, nil,
        Pointer(Result)));
    finally
      for i := 0 to FileCount - 1 do
      begin
        if p^[i] <> nil then
          Malloc.Free(p^[i]);
      end;
      FreeMem(p);
    end;
  finally
    Malloc.Free(FolderPidl);
  end;
end;

procedure TDragDropSource.StartDragDrop(Sender: TControl; At: TPoint);
var
  DataObject: IDataObject;
  Effect: {$IFDEF FPC}DWORD{$ELSE}integer{$ENDIF};
  ddres: {$IFDEF FPC}DWORD{$ELSE}integer{$ENDIF};
begin
{$IFNDEF FPC}
  if Mouse.IsPanning then
    Mouse.PanningWindow := nil;
  if Assigned(Sender) then
  begin
    if csLButtonDown in Sender.ControlState then
    begin
      Sender.Perform(WM_LBUTTONUP, 0, PointToLParam(At));
    end;
  end;
{$ENDIF}
  if // not Fdragdropaktiv and
    CheckFiles then
  begin
    // Fdragdropaktiv:= true;
    if Assigned(FonDragDropBegin) then
      FonDragDropBegin(false);

    { Perform(WM_LBUTTONUP, 0, MakeLong(X, Y)); }
    DataObject := GetFileListDataObject;
    Effect := DROPEFFECT_NONE;
    ddres := DoDragDrop(DataObject, Self, DROPEFFECT_COPY,
{$IFDEF FPC}@Effect{$ELSE}Effect{$ENDIF});

  end
  else
  begin
    { Drag Drop nicht aktiv }
  end;
end;

{ ---------------------------------------------------------------------------- }

initialization

OleInitialize(nil);

finalization

OleUninitialize;

{ ---------------------------------------------------------------------------- }

{$ENDIF}

end.
