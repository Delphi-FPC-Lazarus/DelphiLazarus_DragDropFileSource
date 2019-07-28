program Test_units_dragdrop;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {frmMain},
  dragdropfilesource_unit in '..\dragdropfilesource_unit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
