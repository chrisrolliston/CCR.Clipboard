{
  Very simple demo of the NewFormatSet and EnumFormatSets methods; will only
  work on OS X or iOS due to a lack of multi-item support on Windows.
}
unit FormatSetsForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo, FMX.Layouts;

type
  TfrmFormatSets = class(TForm)
    btnCopyNormal: TButton;
    btnEnumItems: TButton;
    btnCopyWithExplicitFormatSets: TButton;
    memOutput: TMemo;
    procedure btnCopyNormalClick(Sender: TObject);
    procedure btnCopyWithExplicitFormatSetsClick(Sender: TObject);
    procedure btnEnumItemsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  frmFormatSets: TfrmFormatSets;

implementation

{$R *.fmx}

uses
  CCR.Clipboard;

var
  cfCustomFormat: TClipboardFormat;

procedure TfrmFormatSets.FormCreate(Sender: TObject);
begin
  cfCustomFormat := TClipboard.RegisterFormat('com.ccr.dummy');
end;

procedure TfrmFormatSets.btnCopyNormalClick(Sender: TObject);
begin
  Clipboard.Open;
  try
    Clipboard.AssignText('Hello');
    Clipboard.Assign(cfCustomFormat, BytesOf('Test'));
    Clipboard.AssignText('World');
  finally
    Clipboard.Close;
  end;
end;

procedure TfrmFormatSets.btnCopyWithExplicitFormatSetsClick(Sender: TObject);
begin
  Clipboard.Open;
  try
    Clipboard.AssignText('Hello');
    { Calling NewFormatSet forces the next assignment to the clipboard to be for
      a new item. }
    Clipboard.NewFormatSet;
    Clipboard.Assign(cfCustomFormat, BytesOf('Test'));
    Clipboard.AssignText('World');
  finally
    Clipboard.Close;
  end;
end;

procedure TfrmFormatSets.btnEnumItemsClick(Sender: TObject);
var
  ClipFormat: TClipboardFormat;
  FormatsPerItem: TList<TArray<TClipboardFormat>>;
  I: Integer;
begin
  FormatsPerItem := TList<TArray<TClipboardFormat>>.Create;
  try
    Clipboard.EnumFormatSets(
      procedure (const Formats: TArray<TClipboardFormat>;
        const GetFormatBytes: TFunc<TClipboardFormat, TBytes>; var LookForMore: Boolean)
      begin
        FormatsPerItem.Add(Formats);
      end);
    if FormatsPerItem.Count = 0 then
      memOutput.Text := 'Clipboard is empty!'
    else
    begin
      memOutput.Text := Format('Clipboard contains %d item(s):', [FormatsPerItem.Count]);
      for I := 0 to FormatsPerItem.Count - 1 do
      begin
        memOutput.Lines.Add('');
        memOutput.Lines.Add(Format('Item %d has %d format(s) -',
          [Succ(I), Length(FormatsPerItem[I])]));
        for ClipFormat in FormatsPerItem[I] do
          memOutput.Lines.Add(ClipFormat.Name);
      end;
    end;
  finally
    FormatsPerItem.Free;
  end;
end;

end.
