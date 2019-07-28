unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, dragdropfilesource_unit;

type
  TfrmMain = class(TForm)
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private-Deklarationen }
    Fdragdropsource: Tdragdropsource;
  public
    { Public-Deklarationen }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(Fdragdropsource);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Fdragdropsource := Tdragdropsource.Create;
  StringGrid1.cells[0, 0] := application.ExeName;
end;

procedure TfrmMain.StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not assigned(Fdragdropsource) then
    exit;

  Fdragdropsource.KillFiles;
  Fdragdropsource.LoadFile(StringGrid1.cells[0, 0]);

  Fdragdropsource.StartDragDrop(Sender as TControl, Point(X, Y));
end;


end.
