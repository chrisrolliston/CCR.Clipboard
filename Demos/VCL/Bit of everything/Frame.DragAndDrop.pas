unit Frame.DragAndDrop;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Frame.ImageToDrag;

type
  TfraDragAndDrop = class(TFrame)
    panBottomHalf: TPanel;
    grpText: TGroupBox;
    panWantPlainText: TPanel;
    RichEdit1: TRichEdit;
    Panel1: TPanel;
    lblPlainText: TLabel;
    lblRTF: TLabel;
    cboBehaviour: TComboBox;
    grpInfo: TGroupBox;
    memInfo: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    panImages: TPanel;
    fraImageToDrag1: TfraImageToDrag;
    Splitter3: TSplitter;
    fraImageToDrag2: TfraImageToDrag;
    procedure memInfoDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure memInfoDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lblPlainTextMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure panWantPlainTextDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure panWantPlainTextDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lblRTFMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  CCR.Clipboard, CCR.Clipboard.Win, CCR.Clipboard.VCL;

{$R *.dfm}

constructor TfraDragAndDrop.Create(AOwner: TComponent);
begin
  inherited;
  TClipboard.RegisterDropTargets([panWantPlainText, memInfo])
end;

procedure TfraDragAndDrop.lblPlainTextMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TClipboard.BeginDrag(lblPlainText,
    procedure (Clipboard: TClipboard)
    var
      Text: string;
    begin
      Text := 'This is a test, generated at ' + DateTimeToStr(Now);
      { while defining one would be harmless, no need to use a Open/Close block
        because this callback is implicitly wrapped in one }
      if cboBehaviour.ItemIndex in [0, 2] then
        Clipboard.AssignText(Text);
      if cboBehaviour.ItemIndex in [1, 2] then
        Clipboard.AssignVirtualFile('Demo.txt', Text);
    end);
end;

procedure TfraDragAndDrop.lblRTFMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  TClipboard.BeginDrag(lblRTF,
    procedure (Clipboard: TClipboard)
    var
      RTF: string;
    begin
      RTF :=
        '{\rtf1\ansi\deff0' + sLineBreak +
        '{\colortbl;\red0\green0\blue0;\red255\green0\blue0;}' + sLineBreak +
        'This is a test:\line' + sLineBreak +
        '\cf2' + sLineBreak + 'Oh yes it is\line}';
      if cboBehaviour.ItemIndex in [0, 2] then
        Clipboard.AssignRTF(RTF);
      if cboBehaviour.ItemIndex in [1, 2] then
        Clipboard.AssignVirtualFile('Demo.rtf', RTF, TEncoding.UTF8, [tfNeverOutputBOM]);
    end);
end;

procedure TfraDragAndDrop.memInfoDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Clipboard: TClipboard;
  ClipFormat: TClipboardFormat;
  Details: TStringList;
  S: string;
begin
  Clipboard := Source as TClipboard;
  Details := nil;
  memInfo.Lines.BeginUpdate;
  try
    memInfo.Lines.Clear;
    Details := TStringList.Create;
    for ClipFormat in Clipboard do
    begin
      S := Format('$%s - %s', [ClipFormat.ToHexString, ClipFormat.Name]);
      if ClipFormat = cfHDROP then
        Clipboard.GetFileNames(Details)
      else if ClipFormat = cfVirtualFileDescriptor then
        Clipboard.GetVirtualFileDescriptors(Details)
      else if ClipFormat = cfUnicodeText then
        Details.Text := Clipboard.AsText
      else
        Details.Clear;
      if Details.Count <> 0 then
        S := S + ' (' + Details.CommaText + ')';
      memInfo.Lines.Add(S);
    end;
  finally
    memInfo.Lines.EndUpdate;
    Details.Free;
  end;
end;

procedure TfraDragAndDrop.memInfoDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source is TClipboard);
end;

procedure TfraDragAndDrop.panWantPlainTextDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  panWantPlainText.Caption := (Source as TClipboard).AsText;
end;

procedure TfraDragAndDrop.panWantPlainTextDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source as TClipboard).HasText;
end;

end.
