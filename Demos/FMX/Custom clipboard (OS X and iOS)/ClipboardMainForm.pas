unit ClipboardMainForm;
{
  Demo of a system-managed custom clipboard (OS X an iOS only)
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.ListBox, FMX.Layouts, FMX.Edit;

type
  TfrmMain = class(TForm)
    lblClipboardName: TLabel;
    edtClipboardName: TEdit;
    Label1: TLabel;
    edtTextToWrite: TEdit;
    Label2: TLabel;
    lsbImages: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    ToolBar1: TToolBar;
    btnWriteToClipboard: TSpeedButton;
    btnReadFromClipboard: TSpeedButton;
    Text1: TText;
    Text2: TText;
    procedure btnWriteToClipboardClick(Sender: TObject);
    procedure btnReadFromClipboardClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  strict private
    function GetCustomName: string;
    function GetSelectedBitmap: TBitmap;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  CCR.Clipboard, CCR.Clipboard.FMX.Mac, CCR.Clipboard.FMX.iOS,
  ClipboardContentsForm;

{$R *.fmx}

function TfrmMain.GetCustomName: string;
begin
  Result := edtClipboardName.Text.Trim;
  if Result = '' then raise EArgumentException.Create('Please enter a clipboard name!');
end;

function TfrmMain.GetSelectedBitmap: TBitmap;
var
  Child: TControl;
begin
  for Child in lsbImages.Selected.Controls do
    if Child is TImage then Exit(TImage(Child).Bitmap);
  raise EArgumentNilException.Create('No image is selected!');
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  edtClipboardName.Text := ExtractFileName(GetModuleName(0)) + 'Data';
end;

procedure TfrmMain.btnReadFromClipboardClick(Sender: TObject);
var
  Clipboard: TClipboard;
  Form: TfrmClipboardContents;
begin
  Form := TfrmClipboardContents.Create(nil);
  Clipboard := TClipboard.CreateForPasteboard(GetCustomName);
  try
    if Clipboard.HasText then
      Form.Memo.Text := Clipboard.AsText;
    if Clipboard.HasFormatFor(TBitmap) then
      Form.ImageViewer.Bitmap.Assign(Clipboard);
  finally
    Clipboard.Free;
  end;
  Form.ShowModal;
  Form.Free;
end;

procedure TfrmMain.btnWriteToClipboardClick(Sender: TObject);
var
  Clipboard: TClipboard;
begin
  Clipboard := TClipboard.CreateForPasteboard(GetCustomName);
  try
    Clipboard.Open;
    try
      Clipboard.AssignText(edtTextToWrite.Text);
      Clipboard.Assign(GetSelectedBitmap);
    finally
      Clipboard.Close;
    end;
  finally
    Clipboard.Free;
  end;
end;

end.
