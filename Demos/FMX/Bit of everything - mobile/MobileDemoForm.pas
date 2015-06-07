unit MobileDemoForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Layouts, FMX.MultiView, FMX.Objects, FMX.StdCtrls, FMX.TabControl,
  FMX.Controls.Presentation;

type
  TfrmMobileDemo = class(TForm)
    MultiView: TMultiView;
    lsbFrames: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    lyoSupportsCustomFormats: TLayout;
    lblSupportsCustomFormats: TLabel;
    Rectangle1: TRectangle;
    txtSupportsCustomFormats: TText;
    lyoSupportsDragAndDrop: TLayout;
    lblSupportsDragAndDrop: TLabel;
    Rectangle4: TRectangle;
    txtSupportsDragAndDrop: TText;
    lyoSupportsMultipleFormatSets: TLayout;
    lblSupportsMultipleFormatSets: TLabel;
    Rectangle2: TRectangle;
    txtSupportsFormatSets: TText;
    lyoSupportsVirtualFiles: TLayout;
    lblSupportsVirtualFiles: TLabel;
    Rectangle3: TRectangle;
    txtSupportsVirtualFiles: TText;
    tbcFrames: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    procedure FormCreate(Sender: TObject);
    procedure lsbFramesChange(Sender: TObject);
  private
    FVisibleFrame: TControl;
  end;

var
  frmMobileDemo: TfrmMobileDemo;

implementation

{$R *.fmx}

uses
  CCR.Clipboard, CCR.Clipboard.FMX, Frame.Viewer, Frame.Copying, Frame.Pasting;

procedure TfrmMobileDemo.FormCreate(Sender: TObject);
  procedure DoSupportsText(Control: TText; Supports: Boolean);
  const
    Colors: array[Boolean] of TAlphaColor = ($33FF0000, $33008000);
    Text: array[Boolean] of string = ('No', 'Yes');
  begin
    (Control.Parent as TRectangle).Fill.Color := Colors[Supports];
    Control.Text := Text[Supports];
  end;
begin
  DoSupportsText(txtSupportsCustomFormats, TClipboard.SupportsCustomFormats);
  DoSupportsText(txtSupportsFormatSets, TClipboard.SupportsMultipleFormatSets);
  DoSupportsText(txtSupportsVirtualFiles, TClipboard.SupportsVirtualFiles);
  DoSupportsText(txtSupportsDragAndDrop, TClipboard.SupportsDragAndDrop);
  lsbFrames.ItemIndex := 0;
end;

procedure TfrmMobileDemo.lsbFramesChange(Sender: TObject);
var
  Frame: TFrame;
  Index: Integer;
begin
  Index := lsbFrames.ItemIndex;
  if Index < 0 then Exit;
  Frame := tbcFrames.Tabs[Index].TagObject as TFrame;
  if Frame <> nil then
    Frame.Visible := True
  else
  begin
    case Index of
      0: Frame := TfraViewer.Create(nil);
      1: Frame := TfraCopying.Create(nil);
      2: Frame := TfraPasting.Create(nil);
    end;
    Frame.Align := TAlignLayout.Client;
    Frame.Parent := tbcFrames.Tabs[Index];
    tbcFrames.Tabs[Index].TagObject := Frame;
  end;
  tbcFrames.TabIndex := Index;
  if (FVisibleFrame <> Frame) and (FVisibleFrame <> nil) then
    FVisibleFrame.Visible := False;
  FVisibleFrame := Frame;
  MultiView.HideMaster;
end;

end.
