unit CustomClipperForm;
{
  Demo of a custom clipper for a record type (TRectF). The clipper code in itself
  is agnostic between FMX and the VCL, and implements support for both TRectF (as
  used in FMX) and TRect (as used in the VCL).

  Due to continually changing FMX interfaces the layout of this form is messed up
  in versions earlier than XE7 - sorry.
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Edit, {$IF NOT DECLARED(TSpinBox)}FMX.SpinBox,{$IFEND}
  CCR.Clipboard, CCR.Clipboard.FMX;

type
  TRectSpinBoxKind = (spLeft, spTop, spRight, spBottom);

  TfrmCustomClipperDemo = class(TForm)
    lyoFirstInstance: TLayout;
    lblFirstRect: TLabel;
    Layout1: TLayout;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    spbLeft1: TSpinBox;
    spbTop1: TSpinBox;
    spbRight1: TSpinBox;
    spbBottom1: TSpinBox;
    lyoSecondInstance: TLayout;
    Label2: TLabel;
    Layout2: TLayout;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    GridPanelLayout2: TGridPanelLayout;
    spbLeft2: TSpinBox;
    spbTop2: TSpinBox;
    spbRight2: TSpinBox;
    spbBottom2: TSpinBox;
    lyoFooter: TLayout;
    Label13: TLabel;
    Label14: TLabel;
    GridPanelLayout3: TGridPanelLayout;
    btnCopy: TButton;
    btnRandomize: TButton;
    btnPaste: TButton;
    procedure btnCopyClick(Sender: TObject);
    procedure btnRandomizeClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblBottomResize(Sender: TObject);
  private
    FSpinBoxes: array of array[TRectSpinBoxKind] of TSpinBox;
    function GetRectFromUI(Index: Integer): TRectF;
    procedure SetRectInUI(Index: Integer; const Value: TRectF);
  protected
    procedure UpdateActions; override;
  end;

var
  frmCustomClipperDemo: TfrmCustomClipperDemo;

implementation

uses
  System.Math, CustomRectClipper;

{$R *.fmx}

{ TfrmCustomClipperDemo }

procedure TfrmCustomClipperDemo.FormCreate(Sender: TObject);
var
  I: Integer;

  function FindSpinBox(const Ident: string): TSpinBox;
  begin
    Result := FindComponent('spb' + Ident + Succ(I).ToString) as TSpinBox
  end;
begin
  if TClipboard.SupportsMultipleFormatSets then
    SetLength(FSpinBoxes, 2)
  else
  begin
    SetLength(FSpinBoxes, 1);
    lblFirstRect.Visible := False;
    lyoSecondInstance.Visible := False;
    ClientHeight := Trunc(lyoFooter.Position.Y + lyoFooter.Height);
  end;
  for I := 0 to High(FSpinBoxes) do
  begin
    FSpinBoxes[I][spLeft] := FindSpinBox('Left');
    FSpinBoxes[I][spTop] := FindSpinBox('Top');
    FSpinBoxes[I][spRight] := FindSpinBox('Right');
    FSpinBoxes[I][spBottom] := FindSpinBox('Bottom');
  end;
end;

procedure TfrmCustomClipperDemo.lblBottomResize(Sender: TObject);
var
  Control: TControl;
begin
  Control := (Sender as TControl);
  Control.ParentControl.Height := Control.Position.Y + Control.Height;
end;

function TfrmCustomClipperDemo.GetRectFromUI(Index: Integer): TRectF;
begin
  Result.Left := FSpinBoxes[Index][spLeft].Value;
  Result.Top := FSpinBoxes[Index][spTop].Value;
  Result.Right := FSpinBoxes[Index][spRight].Value;
  Result.Bottom := FSpinBoxes[Index][spBottom].Value;
end;

procedure TfrmCustomClipperDemo.SetRectInUI(Index: Integer; const Value: TRectF);
begin
  FSpinBoxes[Index][spLeft].Value := Value.Left;
  FSpinBoxes[Index][spTop].Value := Value.Top;
  FSpinBoxes[Index][spRight].Value := Value.Right;
  FSpinBoxes[Index][spBottom].Value := Value.Bottom;
end;

procedure TfrmCustomClipperDemo.UpdateActions;
begin
  inherited;
  btnPaste.Enabled := Clipboard.HasFormatFor<TRectF>;
end;

procedure TfrmCustomClipperDemo.btnRandomizeClick(Sender: TObject);
var
  I: Integer;
  R: TRectF;
begin
  for I := 0 to High(FSpinBoxes) do
  begin
    R.Left := RandomRange(Trunc(spbLeft1.Min), Trunc(spbLeft1.Max));
    R.Top := RandomRange(Trunc(spbLeft1.Min), Trunc(spbLeft1.Max));
    R.Right := RandomRange(Trunc(R.Left), Trunc(spbLeft1.Max));
    R.Top := RandomRange(Trunc(R.Top), Trunc(spbLeft1.Max));
    SetRectInUI(I, R);
  end;
end;

procedure TfrmCustomClipperDemo.btnCopyClick(Sender: TObject);
var
  I: Integer;
begin
  Clipboard.Open;
  try
    for I := 0 to High(FSpinBoxes) do
      Clipboard.Assign(GetRectFromUI(I));
  finally
    Clipboard.Close;
  end;
end;

procedure TfrmCustomClipperDemo.btnPasteClick(Sender: TObject);
var
  Counter: Integer;
begin
  Counter := 0;
  Clipboard.GetValues<TRectF>(
    procedure (const Value: TRectF; var LookForMore: Boolean)
    begin
      SetRectInUI(Counter, Value);
      Inc(Counter);
      LookForMore := Counter < Length(FSpinBoxes);
    end);
  if Counter = 0 then
    ShowMessage('No TRectF instances were on the clipboard!');
end;

{ registering the custom clipper; note that CCR.Clipboard.FMX was included in the
  uses clause above to ensure initialization sections are executed in the intended
  order (in particular, the CCR.Clipboard.* ones before ours) - needed on iOS }
initialization
  TRectClipper.Register;
end.
