unit CustomClipperForm;
{
  Demo of a custom clipper for a record type (TRect). Clipper code itself is
  agnostic between VCL and FMX, and implements TClipboard support for both
  TRect (as used by the VCL) and TRectF (as used by FMX).
}
interface

uses
  WinApi.Windows, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, SpinnerFrame;

type
  TfrmCustomClipper = class(TForm)
    Panel1: TPanel;
    lblLeft: TLabel;
    lblRight: TLabel;
    btnCopy: TButton;
    btnRandomize: TButton;
    btnPaste: TButton;
    Panel2: TPanel;
    lblTop: TLabel;
    GridPanel1: TGridPanel;
    fraSpinnerLeft: TfraSpinner;
    fraSpinnerTop: TfraSpinner;
    fraSpinnerRight: TfraSpinner;
    fraSpinnerBottom: TfraSpinner;
    lblBottom: TLabel;
    procedure btnCopyClick(Sender: TObject);
    procedure btnRandomizeClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
  protected
    procedure UpdateActions; override;
  end;

var
  frmCustomClipper: TfrmCustomClipper;

implementation

{$R *.dfm}

uses
  System.Math, CCR.Clipboard, CustomRectClipper;

{ TfrmCustomClipper }

procedure TfrmCustomClipper.btnCopyClick(Sender: TObject);
var
  R: TRect;
begin
  R.Left := fraSpinnerLeft.Value;
  R.Top := fraSpinnerTop.Value;
  R.Right := fraSpinnerRight.Value;
  R.Bottom := fraSpinnerBottom.Value;
  Clipboard.Assign(R);
end;

procedure TfrmCustomClipper.btnPasteClick(Sender: TObject);
var
  Values: TArray<TRect>;
begin
  Values := Clipboard.GetValues<TRect>;
  if Values = nil then
  begin
    Beep;
    Exit;
  end;
  fraSpinnerLeft.Value := Values[0].Left;
  fraSpinnerTop.Value := Values[0].Top;
  fraSpinnerRight.Value := Values[0].Right;
  fraSpinnerBottom.Value := Values[0].Bottom;
end;

procedure TfrmCustomClipper.btnRandomizeClick(Sender: TObject);
begin
  fraSpinnerLeft.Value := RandomRange(-100, 1000);
  fraSpinnerTop.Value := RandomRange(-100, 1000);
  fraSpinnerRight.Value := RandomRange(fraSpinnerLeft.Value, 9000);
  fraSpinnerBottom.Value := RandomRange(fraSpinnerTop.Value, 9000);
end;

procedure TfrmCustomClipper.UpdateActions;
begin
  inherited;
  btnPaste.Enabled := Clipboard.HasFormatFor<TRect>;
end;

initialization
  TRectClipper.Register;
end.
