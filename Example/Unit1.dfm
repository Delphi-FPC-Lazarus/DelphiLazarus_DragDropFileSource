object frmMain: TfrmMain
  Left = 0
  Top = 0
  ClientHeight = 299
  ClientWidth = 781
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 0
    Top = 0
    Width = 781
    Height = 299
    Align = alClient
    ColCount = 1
    DefaultColWidth = 1000
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    TabOrder = 0
    OnMouseDown = StringGrid1MouseDown
    RowHeights = (
      24)
  end
end
