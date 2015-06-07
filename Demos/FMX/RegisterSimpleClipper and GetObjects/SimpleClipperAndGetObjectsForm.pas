unit SimpleClipperAndGetObjectsForm;
{
  Simple demo of RegisterSimpleClipper, ClippableObject.Assign and GetObjects
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo, FMX.Layouts;

type
  TfrmSimpleClipperAndGetObjectsDemo = class(TForm)
    Memo1: TMemo;
    btnCopyFromMemoLines: TButton;
    btnPasteToMemoLines: TButton;
    btnGetObjects: TButton;
    btnCopyFromMemoLinesAndStringList: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCopyFromMemoLinesClick(Sender: TObject);
    procedure btnPasteToMemoLinesClick(Sender: TObject);
    procedure btnGetObjectsClick(Sender: TObject);
    procedure btnCopyFromMemoLinesAndStringListClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSimpleClipperAndGetObjectsDemo: TfrmSimpleClipperAndGetObjectsDemo;

implementation

{$R *.fmx}

uses
  CCR.Clipboard;

const
  mbOKOnly = [TMsgDlgBtn.mbOK];
  mtInformation = TMsgDlgType.mtInformation;
  mtWarning = TMsgDlgType.mtWarning;

procedure TfrmSimpleClipperAndGetObjectsDemo.FormCreate(Sender: TObject);
begin
  TClipboard.RegisterSimpleClipper<TStrings>;
end;

procedure TfrmSimpleClipperAndGetObjectsDemo.btnCopyFromMemoLinesClick(Sender: TObject);
begin
  Clipboard.Assign(Memo1.Lines);
end;

procedure TfrmSimpleClipperAndGetObjectsDemo.btnCopyFromMemoLinesAndStringListClick(Sender: TObject);
var
  StringList: TStringList;
begin
  if not TClipboard.SupportsMultipleFormatSets then
    MessageDlg('Platform does not support multiple format sets, so only one TStrings ' +
      'object will actually get copied.', mtWarning, mbOKOnly, 0);
  Clipboard.Open;
  try
    Clipboard.Assign(Memo1.Lines);
    StringList := TStringList.Create;
    try
      StringList.CommaText := '"First line","Second line","Third line"';
      Clipboard.Assign(StringList);
    finally
      StringList.Free;
    end;
  finally
    Clipboard.Close;
  end;
end;

procedure TfrmSimpleClipperAndGetObjectsDemo.btnPasteToMemoLinesClick(Sender: TObject);
begin
  { per traditional Delphi behaviour the following will raise an exception if
    a TStrings isn't on the clipboard... }
  Memo1.Lines.Assign(Clipboard);
end;

procedure TfrmSimpleClipperAndGetObjectsDemo.btnGetObjectsClick(Sender: TObject);
var
  I: Integer;
  Items: TObjectList<TStringList>;
  Msg: TStringBuilder;
begin
  { ...in contrast, if a TStrings isn't available on calling GetObjects<TStrings>
    then no exception will be raised }
  Items := TObjectList<TStringList>.Create;
  try
    Clipboard.GetObjects<TStrings>(
      procedure (const AssignTo: TProc<TStrings>; var LookForMore: Boolean)
      var
        Inst: TStringList;
      begin
        Inst := TStringList.Create;
        Items.Add(Inst);
        AssignTo(Inst);
      end);
    if Items.Count = 0 then
    begin
      MessageDlg('No TStrings objects can be read from the clipboard.', mtInformation, mbOKOnly, 0);
      Exit;
    end;
    Msg := TStringBuilder.Create;
    try
      for I := 0 to Items.Count - 1 do
      begin
        if I > 0 then Msg.AppendLine;
        Msg.AppendLine('Item ' + IntToStr(Succ(I)) + ':');
        Msg.AppendLine(Items[I].CommaText);
      end;
      MessageDlg(Msg.ToString, mtInformation, mbOKOnly, 0);
    finally
      Msg.Free;
    end;
  finally
    Items.Free;
  end;
end;

end.
