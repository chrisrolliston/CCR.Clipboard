unit Frame.Info;
{
  Demonstrates a simple clipboard viewer. Some notable details:
  - Use of TClipboardFormat.ConformsTo instead of a simple equality test to test for
    the existence of a suitable viewer class. While on Windows there would be no
    difference, on OS X (and iOS) one clipboard format may 'conform to' another, a
    form of inheritance.
  - Registering (and receiving) clipboard change notifications.
  - Viewing each of the distinct system clipboards on OS X - try selecting 'Find
    pasteboard' then searching for a word on a webpage in Safari.
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Generics.Collections, System.Generics.Defaults,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.ListBox, FMX.Layouts, FMX.Memo, FMX.Grid,
  CCR.Clipboard, AppIntf, FormatViewers;

type
  TfraInfo = class(TFrame, IClipboardListener)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Rectangle1: TRectangle;
    txtSupportsCustomFormats: TText;
    Rectangle2: TRectangle;
    txtSupportsFormatSets: TText;
    Rectangle3: TRectangle;
    txtSupportsVirtualFiles: TText;
    Line1: TLine;
    Label4: TLabel;
    lsbFormats: TListBox;
    ListBoxGroupHeader1: TListBoxGroupHeader;
    Label5: TLabel;
    Rectangle4: TRectangle;
    txtSupportsDragAndDrop: TText;
    panPreview: TPanel;
    txtPreview: TText;
    imgPreview: TImage;
    memPreview: TMemo;
    lyoPreview: TLayout;
    lyoItemStatus: TLayout;
    lyoItemButtons: TLayout;
    btnPrevItem: TButton;
    btnNextItem: TButton;
    lblItem: TLabel;
    cboClipboardShown: TComboBox;
    lblClipboardShown: TLabel;
    lbiGeneralClipboard: TListBoxItem;
    lbiFindClipboard: TListBoxItem;
    lbiDragClipboard: TListBoxItem;
    lbiFontClipboard: TListBoxItem;
    lbiRulerClipboard: TListBoxItem;
    procedure lsbFormatsChange(Sender: TObject);
    procedure btnPrevItemClick(Sender: TObject);
    procedure btnNextItemClick(Sender: TObject);
    procedure cboClipboardShownChange(Sender: TObject);
  strict private
    FClipboard: TClipboard;
    FCurrentViewer: TFormatViewer;
    FItemIndex: Integer;
    FLastChangeCount: TClipboardChangeCount;
    FViewers: TFormatViewerManager;
    procedure SetItemIndex(NewIndex: Integer);
  protected
    procedure CMCancelClipboardSelection(var MessageID: Word); message CM_CANCELCLIPBOARDSELECTION;
    procedure ClipboardChanged(const Clipboard: TClipboard);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Clipboard: TClipboard read FClipboard;
  end;

  TLBIClipboardFormat = class(TListBoxItem)
  public
    Format: TClipboardFormat;
  end;

implementation

{$R *.fmx}

uses
  CCR.Clipboard.FMX, CCR.Clipboard.Apple;

resourcestring
  SNoViewerAvailable = 'No viewer available';
  SSelectFormatToPreview = 'Select a format to preview';
  SFormatNoLongerOnClipboard = 'Format no longer on clipboard';

constructor TfraInfo.Create(AOwner: TComponent);

  procedure DoSupportsText(Control: TText; Supports: Boolean);
  const
    Colors: array[Boolean] of TAlphaColor = (TAlphaColors.Red, TAlphaColors.Green);
    Text: array[Boolean] of string = ('No', 'Yes');
  begin
    (Control.Parent as TRectangle).Fill.Color := Colors[Supports];
    Control.Text := Text[Supports];
  end;

begin
  inherited;
  DoSupportsText(txtSupportsCustomFormats, TClipboard.SupportsCustomFormats);
  DoSupportsText(txtSupportsFormatSets, TClipboard.SupportsMultipleFormatSets);
  DoSupportsText(txtSupportsVirtualFiles, TClipboard.SupportsVirtualFiles);
  DoSupportsText(txtSupportsDragAndDrop, TClipboard.SupportsDragAndDrop);
  lbiGeneralClipboard.TagObject := CCR.Clipboard.Clipboard;
  {$IFDEF MACOS}
  lbiFindClipboard.TagObject := FindClipboard;
  lbiDragClipboard.TagObject := DragClipboard;
  lbiFindClipboard.TagObject := FindClipboard;
  lbiFontClipboard.TagObject := FontClipboard;
  lbiRulerClipboard.TagObject := RulerClipboard;
  {$ELSE}
  lblClipboardShown.Visible := False;
  cboClipboardShown.Visible := False;
  {$ENDIF}
  FViewers := TFormatViewerManager.Create([memPreview, imgPreview]);
  cboClipboardShownChange(nil);
  SetItemIndex(0);
end;

destructor TfraInfo.Destroy;
begin
  FViewers.Free;
  inherited;
end;

procedure TfraInfo.CMCancelClipboardSelection(var MessageID: Word);
begin
  if Clipboard.IsSystemClipboard then
  begin
    lsbFormats.ClearSelection;
    lsbFormatsChange(nil);
  end;
end;

procedure TfraInfo.ClipboardChanged(const Clipboard: TClipboard);
var
  Format, FormatToReselect: TClipboardFormat;
  HasFormatToReselect: Boolean;
  I: Integer;
  Item: TLBIClipboardFormat;
begin
  Item := (lsbFormats.Selected as TLBIClipboardFormat);
  HasFormatToReselect := (Item <> nil);
  if HasFormatToReselect then FormatToReselect := Item.Format;
  lsbFormats.BeginUpdate;
  try
    for I := lsbFormats.Count - 1 downto 1 do
      lsbFormats.ListItems[I].DisposeOf;
    FLastChangeCount := Clipboard.ChangeCount;
    for Format in Clipboard.GetFormats do
    begin
      Item := TLBIClipboardFormat.Create(nil);
      Item.Format := Format;
      Item.Text := Format.Name;
      lsbFormats.AddObject(Item);
      if HasFormatToReselect and (Format = FormatToReselect) then
      begin
        HasFormatToReselect := False;
        Item.IsSelected := True;
      end;
    end;
  finally
    lsbFormats.EndUpdate;
  end;
end;

procedure TfraInfo.btnNextItemClick(Sender: TObject);
begin
  SetItemIndex(FItemIndex + 1);
end;

procedure TfraInfo.btnPrevItemClick(Sender: TObject);
begin
  SetItemIndex(FItemIndex - 1);
end;

procedure TfraInfo.lsbFormatsChange(Sender: TObject);
var
  Control: TControl;
  Format: TClipboardFormat;
begin
  FCurrentViewer := nil;
  for Control in panPreview.Controls do
    if (Control <> txtPreview) and Control.Stored then
      Control.Visible := False;
  if lsbFormats.ItemIndex < 0 then
    txtPreview.Text := SSelectFormatToPreview
  else
  begin
    Format := (lsbFormats.Selected as TLBIClipboardFormat).Format;
    if not Clipboard.HasFormat(Format) then
    begin
      txtPreview.Text := SFormatNoLongerOnClipboard;
      Exit;
    end
    else if FViewers.FindViewer(Format, FCurrentViewer) then
    begin
      txtPreview.Text := '';
      FCurrentViewer.Initialize(Clipboard, Format);
      FCurrentViewer.Output.Visible := True;
    end
    else
      txtPreview.Text := SNoViewerAvailable;
  end;
  SetItemIndex(0);
end;

procedure TfraInfo.SetItemIndex(NewIndex: Integer);
var
  DispTotal: Integer;
begin
  FItemIndex := NewIndex;
  if FCurrentViewer <> nil then
    DispTotal := FCurrentViewer.ItemCount
  else
    DispTotal := 1;
  lblItem.Text := Format('%d of %d', [NewIndex + 1, DispTotal]);
  btnPrevItem.Enabled := (NewIndex > 0);
  btnNextItem.Enabled := (NewIndex < Pred(DispTotal));
  if FCurrentViewer <> nil then FCurrentViewer.LoadItem(NewIndex);
end;

procedure TfraInfo.cboClipboardShownChange(Sender: TObject);
begin
  if FClipboard <> nil then FClipboard.UnregisterChangeListener(Self);
  FClipboard := cboClipboardShown.Selected.TagObject as TClipboard;
  if FClipboard.SupportsChangeListeners then
    FClipboard.RegisterChangeListener(Self);
  ClipboardChanged(Clipboard);
end;

end.
