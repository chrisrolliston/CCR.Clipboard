unit Frame.Viewer;
{
  Along with FormatViewers.pas, demonstrates a simple clipboard viewer. Details to note:
  - Registering for clipboard change notifications.
  - Allowing for multiple instances of any given format being on the clipboard, which is
    possible on Apple platforms.
  - Use of TClipboardFormat.ConformsTo instead of a simple equality test to test for
    the existence of a suitable viewer - on iOS (and OS X) one clipboard format may
    'conform to' another, a form of inheritance.
  Keep in mind retrieving by format is *not* intended to be the 'main' way of getting
  data from the clipboard - instead, test for a type (text, URL, file name, TBitmap,
  etc.), like the code in Frame.Pasting.pas does.
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FMX.Layouts, FMX.Memo, FMX.Objects,
  FMX.Controls.Presentation, FMX.ListView, CCR.Clipboard, FormatViewers,
  FMX.ScrollBox;

type
  TfraViewer = class(TFrame, IClipboardListener)
    lsvFormats: TListView;
    lyoPreview: TLayout;
    panPreview: TPanel;
    txtPreview: TText;
    imgPreview: TImage;
    memPreview: TMemo;
    lyoItemStatus: TLayout;
    lyoItemButtons: TLayout;
    btnPrevItem: TButton;
    btnNextItem: TButton;
    lblItem: TLabel;
    Splitter1: TSplitter;
    procedure lsvFormatsChange(Sender: TObject);
    procedure btnPrevItemClick(Sender: TObject);
    procedure btnNextItemClick(Sender: TObject);
  private
    FCurrentViewer: TFormatViewer;
    FFormats: TArray<TClipboardFormat>;
    FItemIndex: Integer;
    FViewers: TFormatViewerManager;
    procedure SetItemIndex(NewIndex: Integer);
  protected
    procedure ClipboardChanged(const Clipboard: TClipboard);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

resourcestring
  SNoViewerAvailable = 'No viewer available';
  SSelectFormatToPreview = 'Tap a format to preview';
  SFormatNoLongerOnClipboard = 'Format no longer on clipboard';

constructor TfraViewer.Create(AOwner: TComponent);
begin
  inherited;
  FViewers := TFormatViewerManager.Create([memPreview, imgPreview]);
  ClipboardChanged(Clipboard);
  Clipboard.RegisterChangeListener(Self);
end;

destructor TfraViewer.Destroy;
begin
  FViewers.Free;
  inherited;
end;

procedure TfraViewer.btnNextItemClick(Sender: TObject);
begin
  SetItemIndex(FItemIndex + 1);
end;

procedure TfraViewer.btnPrevItemClick(Sender: TObject);
begin
  SetItemIndex(FItemIndex - 1);
end;

procedure TfraViewer.ClipboardChanged(const Clipboard: TClipboard);
var
  Format, FormatToReselect: TClipboardFormat;
  HasFormatToReselect: Boolean;
  Item: TListViewItem;
begin
  HasFormatToReselect := (lsvFormats.ItemIndex >= 0);
  if HasFormatToReselect then FormatToReselect := FFormats[lsvFormats.ItemIndex];
  lsvFormats.BeginUpdate;
  try
    lsvFormats.Items.Clear;
    FFormats := Clipboard.GetFormats;
    for Format in FFormats do
    begin
      Item := lsvFormats.Items.Add;
      Item.Text := Format.Name;
      if HasFormatToReselect and (Format = FormatToReselect) then
      begin
        HasFormatToReselect := False;
        lsvFormats.ItemIndex := Item.Index;
      end;
    end;
  finally
    lsvFormats.EndUpdate;
  end;
  lsvFormatsChange(nil);
end;

procedure TfraViewer.SetItemIndex(NewIndex: Integer);
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

procedure TfraViewer.lsvFormatsChange(Sender: TObject);
var
  Control: TControl;
  Format: TClipboardFormat;
  Index: Integer;
begin
  FCurrentViewer := nil;
  for Control in panPreview.Controls do
    if (Control <> txtPreview) and Control.Stored then
      Control.Visible := False;
  Index := lsvFormats.ItemIndex;
  if Index < 0 then
    txtPreview.Text := SSelectFormatToPreview
  else
  begin
    Format := FFormats[Index];
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

end.
