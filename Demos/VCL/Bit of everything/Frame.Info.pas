unit Frame.Info;
{
  Implements a simple clipboard viewer. Unlike the FMX version, doesn't bother with
  the possibility of multiple instances of the same format because Windows does not
  support it.
}
interface

uses
  WinApi.Windows, WinApi.Messages, WinApi.ActiveX,
  System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  CCR.Clipboard, CCR.Clipboard.Win, CCR.Clipboard.VCL;

type
  TInitViewerProc = reference to procedure (Clipboard: TClipboard; Format: TClipboardFormat);

  TfraInfo = class(TFrame, IClipboardListener)
    Label1: TLabel;
    edtSupportsCustomFormats: TLabel;
    Label2: TLabel;
    edtSupportsFormatSets: TLabel;
    Label3: TLabel;
    edtSupportsVirtualFiles: TLabel;
    Bevel1: TBevel;
    Label4: TLabel;
    btnUpdateFormats: TButton;
    Label5: TLabel;
    panPreview: TPanel;
    imgPreview: TImage;
    rchPreview: TRichEdit;
    lsvFormats: TListView;
    procedure btnUpdateFormatsClick(Sender: TObject);
    procedure lsvFormatsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  strict private
    FFormats: TArray<TClipboardFormat>;
    FOEMEncoding: TEncoding;
    FViewerMap: TDictionary<TClipboardFormat, TInitViewerProc>;
    procedure InitComponentViewer(Clipboard: TClipboard; Format: TClipboardFormat);
    procedure InitDataObjectViewer(Clipboard: TClipboard; ClipFormat: TClipboardFormat);
    procedure InitFileGroupDescriptorViewer(Clipboard: TClipboard; ClipFormat: TClipboardFormat);
    procedure InitIntegerViewer(Clipboard: TClipboard; Format: TClipboardFormat);
    procedure InitRTFViewer(Clipboard: TClipboard; Format: TClipboardFormat);
    procedure InitHDROPViewer(Clipboard: TClipboard; Format: TClipboardFormat);
  protected
    procedure CMParentFontChanged(var Message: TCMParentFontChanged); message CM_PARENTFONTCHANGED;
    procedure ClipboardChanged(const Clipboard: TClipboard);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  System.Math, Vcl.Imaging.GifImg, Vcl.Imaging.Jpeg, Vcl.Imaging.PngImage;

{$R *.dfm}

resourcestring
  SNoViewerAvailable = 'No viewer available';
  SSelectFormatToPreview = 'Select a format to preview';
  SClipboardIsEmpty = 'Clipboard is empty';
  SFormatNoLongerOnClipboard = 'Format no longer on clipboard';

constructor TfraInfo.Create(AOwner: TComponent);

  function MakeGraphicViewerProc(const ClassType: TGraphicClass): TInitViewerProc;
  begin
    Result := procedure (Clipboard: TClipboard; Format: TClipboardFormat)
              var
                Graphic: TGraphic;
              begin
                Graphic := ClassType.Create;
                try
                  Graphic.Assign(Clipboard);
                  imgPreview.Picture.Assign(Graphic);
                finally
                  Graphic.Free;
                end;
                imgPreview.Visible := True;
              end;
  end;

  function MakePlainTextViewerProc(Encoding: TEncoding): TInitViewerProc;
  begin
    Result := procedure (Clipboard: TClipboard; Format: TClipboardFormat)
              begin
                rchPreview.Clear;
                rchPreview.PlainText := True;
                rchPreview.Text := Encoding.GetString(Clipboard.GetBytes(Format));
                rchPreview.Visible := True;
              end;
  end;

  procedure DoSupportsLabel(Control: TLabel; Supports: Boolean);
  const
    BkColors: array[Boolean] of TColor = (clRed, clGreen);
    Captions: array[Boolean] of string = ('No', 'Yes');
  begin
    Control.Caption := Captions[Supports];
    Control.Color := BkColors[Supports];
    Control.Font.Color := clWhite;
  end;
begin
  inherited;
  { set up the capability info }
  DoSupportsLabel(edtSupportsCustomFormats, TClipboard.SupportsCustomFormats);
  DoSupportsLabel(edtSupportsFormatSets, TClipboard.SupportsMultipleFormatSets);
  DoSupportsLabel(edtSupportsVirtualFiles, TClipboard.SupportsVirtualFiles);
  { set up the clipboard viewer }
  FViewerMap := TDictionary<TClipboardFormat, TInitViewerProc>.Create;
  FViewerMap.Add(cfAnsiText, MakePlainTextViewerProc(TEncoding.ANSI));
  FViewerMap.Add(cfUnicodeText, MakePlainTextViewerProc(TEncoding.Unicode));
  FOEMEncoding := TMBCSEncoding.Create(CP_OEMCP);
  FViewerMap.Add(cfOemText, MakePlainTextViewerProc(FOEMEncoding));
  FViewerMap.Add(TClipboard.RegisterFormat('FileName'), MakePlainTextViewerProc(TEncoding.ANSI));
  FViewerMap.Add(TClipboard.RegisterFormat('FileNameW'), MakePlainTextViewerProc(TEncoding.Unicode));
  FViewerMap.Add(cfLocale, InitIntegerViewer);
  FViewerMap.Add(cfURL, MakePlainTextViewerProc(TEncoding.Unicode));
  FViewerMap.Add(cfRTF, InitRTFViewer);
  FViewerMap.Add(cfHDROP, InitHDROPViewer);
  FViewerMap.Add(cfDataObject, InitDataObjectViewer);
  FViewerMap.Add(cfVirtualFileDescriptor, InitFileGroupDescriptorViewer);
  FViewerMap.Add(TClipboard.RegisterFormat('Rich Text Format Without Objects'), InitRTFViewer);
  FViewerMap.Add(TClipboard.RegisterFormat('RTF As Text'), MakePlainTextViewerProc(TEncoding.ANSI));
  FViewerMap.Add(cfBitmap, MakeGraphicViewerProc(TBitmap));
  FViewerMap.Add(cfGIF, MakeGraphicViewerProc(TGIFImage));
  FViewerMap.Add(cfJpeg, MakeGraphicViewerProc(TJPEGImage));
  FViewerMap.Add(cfPNG, MakeGraphicViewerProc(TPngImage));
  FViewerMap.Add(cfMetafilePict, MakeGraphicViewerProc(TMetafile));
  FViewerMap.Add(cfEnhMetafile, MakeGraphicViewerProc(TMetafile));
  FViewerMap.Add(cfComponent, InitComponentViewer);
  FViewerMap.Add(cfComponents, InitComponentViewer);
  ClipboardChanged(Clipboard);
  if Clipboard.SupportsChangeListeners then //will do so on Vista or later
  begin
    btnUpdateFormats.Visible := False;
    Clipboard.RegisterChangeListener(Self);
  end;
end;

destructor TfraInfo.Destroy;
begin
  Clipboard.UnregisterChangeListener(Self);
  FViewerMap.Free;
  FOEMEncoding.Free;
  inherited;
end;

type
  TControlAccess = class(TControl);

procedure TfraInfo.CMParentFontChanged(var Message: TCMParentFontChanged);
var
  OldName: TFontName;
  OldSize: Integer;

  procedure CheckChildren(Parent: TWinControl);
  var
    Child: TControl;
    I: Integer;
  begin
    for I := 0 to Parent.ControlCount - 1 do
    begin
      Child := Parent.Controls[I];
      if not TControlAccess(Child).ParentFont then
      begin
        if TControlAccess(Child).Font.Name = OldName then
          TControlAccess(Child).Font.Name := Font.Name;
        if TControlAccess(Child).Font.Size = OldSize then
          TControlAccess(Child).Font.Size := Font.Size;
      end;
      if Child is TWinControl then
        CheckChildren(TWinControl(Child));
    end;
  end;
begin
  OldName := Font.Name;
  OldSize := Font.Size;
  inherited;
  if (Font.Size <> OldSize) or (Font.Name <> OldName) then CheckChildren(Self);
end;

procedure TfraInfo.InitComponentViewer(Clipboard: TClipboard; Format: TClipboardFormat);
const
  WantedSignature: array[0..3] of AnsiChar = ('T', 'P', 'F', '0');
var
  Signature: array[1..SizeOf(WantedSignature)] of Byte;
  Encoding: TEncoding;
  Offset: Integer;
  InStream, OutStream: TBytesStream;
begin
  rchPreview.Clear;
  rchPreview.PlainText := True;
  InStream := TBytesStream.Create(Clipboard.GetBytes(Format));
  try
    repeat
      OutStream := TBytesStream.Create;
      try
        ObjectBinaryToText(InStream, OutStream);
        Encoding := nil;
        Offset := TEncoding.GetBufferEncoding(OutStream.Bytes, Encoding);
        rchPreview.Lines.Add(Encoding.GetString(OutStream.Bytes, Offset, OutStream.Size - Offset));
      finally
        OutStream.Free;
      end;
      if (InStream.Read(Signature, SizeOf(Signature)) <> SizeOf(Signature)) or
         not CompareMem(@Signature, @WantedSignature, SizeOf(Signature)) then Break;
      InStream.Seek(-SizeOf(Signature), soCurrent);
    until False;
  finally
    InStream.Free;
  end;
  rchPreview.Visible := True;
end;

procedure TfraInfo.InitDataObjectViewer(Clipboard: TClipboard; ClipFormat: TClipboardFormat);
begin
  rchPreview.Clear;
  rchPreview.PlainText := True;
  Clipboard.EnumDataObject(
    procedure (const DataObject: IDataObject; const FormatEtc: TFormatEtc; var Continue: Boolean)
    var
      S: string;
    begin
      S := Format('$%.4x - %s, ', [FormatEtc.cfFormat, TClipboardFormat.Wrap(FormatEtc.cfFormat).Name]);
      case FormatEtc.dwAspect of
        DVASPECT_CONTENT: S := S + 'content';
        DVASPECT_THUMBNAIL: S := S + 'thumbnail';
        DVASPECT_ICON: S := S + 'icon';
        DVASPECT_DOCPRINT: S := S + 'doc print';
      else S := S + 'unknown';
      end;
      S := Format('%s, index %d, ', [S, FormatEtc.lindex]);
      case FormatEtc.tymed of
        TYMED_HGLOBAL: S := S + 'global memory';
        TYMED_FILE: S := S + 'file';
        TYMED_ISTREAM: S := S + 'stream';
        TYMED_ISTORAGE: S := S + 'storage';
        TYMED_GDI: S := S + 'GDI handle';
        TYMED_MFPICT: S := S + 'metafile';
        TYMED_ENHMF: S := S + 'enhanced metafile';
        TYMED_NULL: S := S + 'null';
      else S := S + 'unknown medium';
      end;
      rchPreview.Lines.Add(S);
    end);
  rchPreview.Visible := True;
end;

procedure TfraInfo.InitFileGroupDescriptorViewer(Clipboard: TClipboard;
  ClipFormat: TClipboardFormat);
begin
  rchPreview.Clear;
  rchPreview.PlainText := True;
  rchPreview.Lines.AddStrings(Clipboard.GetVirtualFileDescriptors);
  rchPreview.Visible := True;
end;

procedure TfraInfo.InitHDROPViewer(Clipboard: TClipboard; Format: TClipboardFormat);
begin
  rchPreview.Clear;
  rchPreview.PlainText := True;
  rchPreview.Lines.AddStrings(Clipboard.GetFileNames);
  rchPreview.Visible := True;
end;

procedure TfraInfo.InitIntegerViewer(Clipboard: TClipboard; Format: TClipboardFormat);
var
  Bytes: TBytes;
begin
  rchPreview.Clear;
  rchPreview.PlainText := True;
  Bytes := Clipboard.GetBytes(Format);
  case Length(Bytes) of
    1: rchPreview.Text := '$' + IntToHex(Bytes[0], 2);
    2: rchPreview.Text := '$' + IntToHex(PWord(Bytes)^, 4);
    4: rchPreview.Text := '$' + IntToHex(PLongWord(Bytes)^, 8);
    8: rchPreview.Text := '$' + IntToHex(PUInt64(Bytes)^, 16);
  else
    panPreview.Caption := SNoViewerAvailable;
  end;
  rchPreview.Visible := True;
end;

procedure TfraInfo.InitRTFViewer(Clipboard: TClipboard; Format: TClipboardFormat);
var
  Stream: TBytesStream;
begin
  rchPreview.Clear;
  rchPreview.PlainText := False;
  //can't use Clipboard.AsRTF because stock TRichEdit doesn't have a RichText or RTF property...
  Stream := TBytesStream.Create(Clipboard.GetBytes(Format));
  try
    rchPreview.Lines.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
  rchPreview.Visible := True;
end;

procedure TfraInfo.ClipboardChanged(const Clipboard: TClipboard);
var
  FormatToSelect, Format: TClipboardFormat;
  HasFormatToSelect: Boolean;
  Item: TListItem;
begin
  HasFormatToSelect := (lsvFormats.SelCount = 1);
  if HasFormatToSelect then
    FormatToSelect := FFormats[lsvFormats.ItemIndex];
  lsvFormats.Items.BeginUpdate;
  try
    lsvFormats.Items.Clear;
    FFormats := Clipboard.GetFormats;
    for Format in FFormats do
    begin
      Item := lsvFormats.Items.Add;
      Item.Caption := '$' + Format.ToHexString;
      Item.SubItems.Add(Format.Name);
      if HasFormatToSelect and (Format = FormatToSelect) then
      begin
        HasFormatToSelect := False;
        Item.Selected := True;
      end;
    end;
  finally
    lsvFormats.Items.EndUpdate;
  end;
  if lsvFormats.SelCount = 0 then lsvFormatsSelectItem(nil, nil, False);
end;

procedure TfraInfo.btnUpdateFormatsClick(Sender: TObject);
begin
  ClipboardChanged(Clipboard);
end;

procedure TfraInfo.lsvFormatsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  Format: TClipboardFormat;
  I: Integer;
  InitViewerProc: TInitViewerProc;
begin
  for I := panPreview.ControlCount - 1 downto 0 do
    panPreview.Controls[I].Visible := False;
  if not Selected then
  begin
    if FFormats <> nil then
      panPreview.Caption := SSelectFormatToPreview
    else
      panPreview.Caption := SClipboardIsEmpty;
    Exit;
  end;
  Format := FFormats[Item.Index];
  if not Clipboard.HasFormat(Format) then
  begin
    panPreview.Caption := SFormatNoLongerOnClipboard;
    Exit;
  end;
  if FViewerMap.TryGetValue(Format, InitViewerProc) then
  begin
    panPreview.Caption := '';
    InitViewerProc(Clipboard, Format);
  end
  else
    panPreview.Caption := SNoViewerAvailable;
end;

end.
