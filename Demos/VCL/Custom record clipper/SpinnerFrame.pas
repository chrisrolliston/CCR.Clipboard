unit SpinnerFrame;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfraSpinner = class(TFrame)
    btnSmaller: TButton;
    btnBigger: TButton;
    edtInput: TEdit;
    procedure btnSmallerClick(Sender: TObject);
    procedure btnBiggerClick(Sender: TObject);
  strict private
    function GetValue: Integer;
    procedure SetValue(const Value: Integer);
  public
    property Value: Integer read GetValue write SetValue;
  end;

implementation

{$R *.dfm}

procedure TfraSpinner.btnBiggerClick(Sender: TObject);
begin
  Value := Succ(Value);
end;

procedure TfraSpinner.btnSmallerClick(Sender: TObject);
begin
  Value := Pred(Value);
end;

function TfraSpinner.GetValue: Integer;
begin
  Result := StrToIntDef(edtInput.Text, 0);
end;

procedure TfraSpinner.SetValue(const Value: Integer);
begin
  edtInput.Text := IntToStr(Value);
end;

end.
