unit FormatViewers;
{
  Simple clipboard viewer framework. Note: it is *not* recommended to read an object by
  asking for a specific format. Instead, either assign the clipboard to the object, or
  read all possible instances of the class via LoadObjects<ClassType>.
}
interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FMX.Graphics, FMX.Controls, FMX.Memo, FMX.Objects, CCR.Clipboard, CustomFormatExamples;

type
  TControlClass = class of TControl;

  TFormatViewer = class
  protected
    function GetItemCount: Integer; virtual; abstract;
    function GetOutput: TControl; virtual; abstract;
  public
    constructor Create(const AOutput: TControl); virtual;
    class function OutputClass: TControlClass; virtual; abstract;
    procedure Initialize(const Clipboard: TClipboard; Format: TClipboardFormat); virtual; abstract;
    procedure LoadItem(Index: Integer); virtual; abstract;
    property ItemCount: Integer read GetItemCount;
    property Output: TControl read GetOutput;
  end;

  TFormatViewerClass = class of TFormatViewer;

  TFormatViewerManager = class
  strict private type
    TViewerDetails = class
      Control: TControl;
      Format: TClipboardFormat;
      ViewerClass: TFormatViewerClass;
    end;
  strict private
    FOutputControls: TArray<TControl>;
    FViewerMap: TObjectList<TViewerDetails>;
    FViewerInsts: TDictionary<TFormatViewerClass, TFormatViewer>;
    function TryGetOutputControl(const ClassType: TControlClass; var Matched: TControl): Boolean;
  public
    constructor Create(const OutputControls: array of TControl);
    destructor Destroy; override;
    function FindViewer(const Format: TClipboardFormat; out Viewer: TFormatViewer): Boolean;
    procedure RegisterViewer(const Format: TClipboardFormat; ViewerClass: TFormatViewerClass);
    function TryRegisterViewer(const Format: TClipboardFormat; ViewerClass: TFormatViewerClass): Boolean;
  end;

  TFormatViewer<T: TControl> = class(TFormatViewer)
  strict private
    FOutput: T;
  protected
    function GetOutput: TControl; override;
  public
    constructor Create(const AOutput: TControl); override;
    class function OutputClass: TControlClass; override;
    property Output: T read FOutput;
  end;

  TBytesFormatViewer<T: TControl> = class(TFormatViewer<T>)
  strict private
    FData: TList<TBytes>;
  protected
    function GetItemCount: Integer; override;
    property Data: TList<TBytes> read FData;
  public
    constructor Create(const AOutput: TControl); override;
    destructor Destroy; override;
    procedure Initialize(const Clipboard: TClipboard; Format: TClipboardFormat); override;
  end;

  TBitmapFormatViewer = class(TBytesFormatViewer<TImage>)
  public
    procedure LoadItem(Index: Integer); override;
  end;

  {$IFDEF MSWINDOWS}
  TWinBitmapFormatViewer = class(TFormatViewer<TImage>)
  strict private
    FBitmap: TBitmap;
  protected
    function GetItemCount: Integer; override;
  public
    constructor Create(const AOutput: TControl); override;
    destructor Destroy; override;
    procedure Initialize(const Clipboard: TClipboard; Format: TClipboardFormat); override;
    procedure LoadItem(Index: Integer); override;
  end;

  TWinDataObjectFormatViewer = class(TFormatViewer<TMemo>)
  strict private
    FFormatInfo: TList<string>;
  protected
    function GetItemCount: Integer; override;
  public
    constructor Create(const AOutput: TControl); override;
    destructor Destroy; override;
    procedure Initialize(const Clipboard: TClipboard; ClipFormat: TClipboardFormat); override;
    procedure LoadItem(Index: Integer); override;
  end;
  {$ENDIF}

  TTextFormatViewer<T: TEncoding, constructor> = class(TBytesFormatViewer<TMemo>)
  strict private
    FEncoding: TEncoding;
  public
    constructor Create(const AOutput: TControl); override;
    destructor Destroy; override;
    procedure LoadItem(Index: Integer); override;
  end;

  TAnsiTextFormatViewer = TTextFormatViewer<TMBCSEncoding>;
  TUnicodeTextFormatViewer = TTextFormatViewer<TUnicodeEncoding>;
  TUTF8TextFormatViewer = TTextFormatViewer<TUTF8Encoding>;

  TStringArrayFormatViewer = class(TFormatViewer<TMemo>)
  strict private
    FStrings: TList<string>;
  protected
    function GetItemCount: Integer; override;
    function GetStrings(const Clipboard: TClipboard;
      Format: TClipboardFormat): TArray<string>; virtual; abstract;
  public
    constructor Create(const AOutput: TControl); override;
    destructor Destroy; override;
    procedure Initialize(const Clipboard: TClipboard; Format: TClipboardFormat); override;
    procedure LoadItem(Index: Integer); override;
  end;

  TFileNamesViewer = class(TStringArrayFormatViewer)
  protected
    function GetStrings(const Clipboard: TClipboard; Format: TClipboardFormat): TArray<string>; override;
  end;

  TURLsViewer = class(TStringArrayFormatViewer)
  protected
    function GetStrings(const Clipboard: TClipboard; Format: TClipboardFormat): TArray<string>; override;
  end;

  TVirtualFileDescriptorsViewer = class(TStringArrayFormatViewer)
  protected
    function GetStrings(const Clipboard: TClipboard; Format: TClipboardFormat): TArray<string>; override;
  end;

  TComponentFormatViewer = class(TBytesFormatViewer<TMemo>)
    procedure Initialize(const Clipboard: TClipboard; Format: TClipboardFormat); override;
    procedure LoadItem(Index: Integer); override;
  end;

  TMyObjectFormatViewer = class(TFormatViewer<TMemo>)
  strict private
    FObjs: TObjectList<TMyObject>;
  protected
    function GetItemCount: Integer; override;
  public
    constructor Create(const AOutput: TControl); override;
    destructor Destroy; override;
    procedure Initialize(const Clipboard: TClipboard; Format: TClipboardFormat); override;
    procedure LoadItem(Index: Integer); override;
  end;

implementation

uses
  {$IFDEF MSWINDOWS}WinApi.ActiveX,{$ENDIF}                      //for IDataObject parsing symbols
  CCR.Clipboard.Apple, CCR.Clipboard.Win, CCR.Clipboard.FMX.Win; //for some platform-specific cfXXX symbols

{ TFormatViewer }

constructor TFormatViewer.Create(const AOutput: TControl);
begin
  inherited Create;
end;

{ TFormatViewer<T> }

constructor TFormatViewer<T>.Create(const AOutput: TControl);
begin
  FOutput := AOutput as T;
  inherited;
end;

function TFormatViewer<T>.GetOutput: TControl;
begin
  Result := FOutput;
end;

class function TFormatViewer<T>.OutputClass: TControlClass;
begin
  Result := T;
end;

{ TBytesFormatViewer<T> }

constructor TBytesFormatViewer<T>.Create(const AOutput: TControl);
begin
  inherited;
  FData := TList<TBytes>.Create;
end;

destructor TBytesFormatViewer<T>.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TBytesFormatViewer<T>.Initialize(const Clipboard: TClipboard; Format: TClipboardFormat);
begin
  FData.Clear;
  Clipboard.GetBytes(Format,
    procedure (const Bytes: TBytes; var Continue: Boolean)
    begin
      FData.Add(Bytes);
    end);
end;

function TBytesFormatViewer<T>.GetItemCount: Integer;
begin
  Result := FData.Count;
end;

{ TBitmapFormatViewer }

procedure TBitmapFormatViewer.LoadItem(Index: Integer);
var
  Stream: TStream;
begin
  Stream := TBytesStream.Create(Data[Index]);
  try
    Output.Bitmap.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

{$IFDEF MSWINDOWS}

{ TWinBitmapFormatViewer }

constructor TWinBitmapFormatViewer.Create(const AOutput: TControl);
begin
  inherited;
   FBitmap := TBitmap.Create;
end;

destructor TWinBitmapFormatViewer.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

function TWinBitmapFormatViewer.GetItemCount: Integer;
begin
  if FBitmap.IsEmpty then
    Result := 0
  else
    Result := 1;
end;

procedure TWinBitmapFormatViewer.Initialize(const Clipboard: TClipboard;
  Format: TClipboardFormat);
begin
  if Format = cfBitmap then
    LoadBitmapFromDDB(FBitmap, Clipboard.GetAsHandle(Format))
  else if Format = cfDIBv5 then
    LoadBitmapFromDIB5HGlobal(FBitmap, Clipboard.GetAsHandle(Format))
  else
    FBitmap.Assign(nil);
end;

procedure TWinBitmapFormatViewer.LoadItem(Index: Integer);
begin
  Output.Data := FBitmap;
end;

{ TWinDataObjectFormatViewer }

constructor TWinDataObjectFormatViewer.Create(const AOutput: TControl);
begin
  inherited;
  FFormatInfo := TList<string>.Create;
end;

destructor TWinDataObjectFormatViewer.Destroy;
begin
  FFormatInfo.Free;
  inherited;
end;

function TWinDataObjectFormatViewer.GetItemCount: Integer;
begin
  Result := FFormatInfo.Count;
end;

procedure TWinDataObjectFormatViewer.Initialize(const Clipboard: TClipboard;
  ClipFormat: TClipboardFormat);
begin
  FFormatInfo.Clear;
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
      FFormatInfo.Add(S);
    end);
end;

procedure TWinDataObjectFormatViewer.LoadItem(Index: Integer);
begin
  Output.Text := FFormatInfo[Index];
end;

{$ENDIF}

{ TTextFormatViewer<T> }

constructor TTextFormatViewer<T>.Create(const AOutput: TControl);
begin
  inherited;
  FEncoding := T.Create;
end;

destructor TTextFormatViewer<T>.Destroy;
begin
  FEncoding.Free;
  inherited;
end;

procedure TTextFormatViewer<T>.LoadItem(Index: Integer);
begin
  Output.Text := FEncoding.GetString(Data[Index]);
end;

{ TStringArrayFormatViewer }

constructor TStringArrayFormatViewer.Create(const AOutput: TControl);
begin
  inherited;
  FStrings := TList<string>.Create;
end;

destructor TStringArrayFormatViewer.Destroy;
begin
  FStrings.Free;
  inherited;
end;

function TStringArrayFormatViewer.GetItemCount: Integer;
begin
  Result := FStrings.Count;
end;

procedure TStringArrayFormatViewer.Initialize(const Clipboard: TClipboard; Format: TClipboardFormat);
begin
  FStrings.Clear;
  FStrings.AddRange(GetStrings(Clipboard, Format));
end;

procedure TStringArrayFormatViewer.LoadItem(Index: Integer);
begin
  Output.Text := FStrings[Index];
end;

{ TFileNamesViewer }

function TFileNamesViewer.GetStrings(const Clipboard: TClipboard;
  Format: TClipboardFormat): TArray<string>;
begin
  Result := Clipboard.GetFileNames;
end;

{ TURLsViewer }

function TURLsViewer.GetStrings(const Clipboard: TClipboard; Format: TClipboardFormat): TArray<string>;
begin
  Result := Clipboard.GetURLs;
end;

{ TVirtualFileDescriptorsViewer }

function TVirtualFileDescriptorsViewer.GetStrings(const Clipboard: TClipboard; Format: TClipboardFormat): TArray<string>;
begin
  Result := Clipboard.GetVirtualFileDescriptors;
end;

{ TComponentFormatViewer }

{$IF DECLARED(PAnsiChar)}
function BytePos(const Buffer: PByte; BufferSize: Integer; const Pattern: PAnsiChar): PByte;
{$ELSE}
function BytePos(const Buffer: PByte; BufferSize: Integer; const Pattern: PChar): PByte;
{$ENDIF}
var
  PastBuffer, MatchStart, LStr1, LStr2: PByte;
begin
  Result := nil;
  if (BufferSize <= 0) or (Pattern^ = #0) then
    Exit;
  PastBuffer := Buffer + BufferSize;
  MatchStart := Buffer;
  while MatchStart < PastBuffer do
  begin
    if MatchStart^ = Ord(Pattern^) then
    begin
      LStr1 := MatchStart + 1;
      LStr2 := @Pattern[1];
      while LStr1 < PastBuffer do
      begin
        if LStr2^ = 0 then
          Exit(MatchStart);
        if LStr1^ <> LStr2^ then
          Break;
        Inc(LStr1);
        Inc(LStr2, SizeOf(Pattern^));
      end;
    end;
    Inc(MatchStart);
  end;
end;

procedure TComponentFormatViewer.Initialize(const Clipboard: TClipboard;
  Format: TClipboardFormat);
var
  Bytes, SubBytes: TBytes;
  VeryStartPos, VeryEndPos, StartPos, SeekPtr, EndPos: PByte;
begin
  inherited;
  if (Format = cfComponent) or (Data.Count = 0) then Exit;
  Bytes := Data.First;
  VeryStartPos := PByte(Bytes);
  VeryEndPos := @VeryStartPos[Length(Bytes)];
  StartPos := VeryStartPos;
  repeat
    SeekPtr := BytePos(StartPos + 4, VeryEndPos - StartPos - 4, 'TPF0');
    EndPos := SeekPtr;
    if EndPos = nil then
      if StartPos = VeryStartPos then
        Exit
      else
        EndPos := VeryEndPos;
    SubBytes := nil;
    SetLength(SubBytes, EndPos - StartPos);
    Move(StartPos^, SubBytes[0], Length(SubBytes));
    Data.Add(SubBytes);
    StartPos := SeekPtr;
  until (SeekPtr = nil);
  Data.Delete(0);
end;

procedure TComponentFormatViewer.LoadItem(Index: Integer);
var
  BinStream: TBytesStream;
  Encoding: TEncoding;
  Offset: Integer;
  TextStream: TBytesStream;
begin
  TextStream := nil;
  BinStream := TBytesStream.Create(Data[Index]);
  try
    BinStream.Seek(0, soBeginning);
    TextStream := TBytesStream.Create;
    ObjectBinaryToText(BinStream, TextStream);
    Encoding := nil;
    Offset := TEncoding.GetBufferEncoding(TextStream.Bytes, Encoding);
    Output.Text := Encoding.GetString(TextStream.Bytes, Offset, TextStream.Size - Offset);
  finally
    BinStream.Free;
    TextStream.Free;
  end;
end;

{ TMyObjectFormatViewer }

constructor TMyObjectFormatViewer.Create(const AOutput: TControl);
begin
  inherited;
  FObjs := TObjectList<TMyObject>.Create;
end;

destructor TMyObjectFormatViewer.Destroy;
begin
  FObjs.Free;
  inherited;
end;

function TMyObjectFormatViewer.GetItemCount: Integer;
begin
  Result := FObjs.Count;
end;

procedure TMyObjectFormatViewer.Initialize(const Clipboard: TClipboard; Format: TClipboardFormat);
begin
  FObjs.Clear;
  Clipboard.GetObjects<TMyObject>(
    procedure (const AssignTo: TProc<TMyObject>; var Continue: Boolean)
    var
      NewObj: TMyObject;
    begin
      NewObj := TMyObject.Create;
      FObjs.Add(NewObj);
      AssignTo(NewObj);
    end);
end;

procedure TMyObjectFormatViewer.LoadItem(Index: Integer);
begin
  Output.Lines.Clear;
  Output.Lines.Add('DateTime: ' + DateTimeToStr(FObjs[Index].DateTime));
  Output.Lines.Add('Text: ' + FObjs[Index].Text);
end;

{ TFormatViewerManager }

constructor TFormatViewerManager.Create(const OutputControls: array of TControl);
var
  I: Integer;
begin
  inherited Create;
  SetLength(FOutputControls, Length(OutputControls));
  for I := 0 to High(OutputControls) do
    FOutputControls[I] := OutputControls[I];
  FViewerInsts := TObjectDictionary<TFormatViewerClass, TFormatViewer>.Create([doOwnsValues]);
  FViewerMap := TObjectList<TViewerDetails>.Create;
  { A 'complete' clipboard viewer application would include platform specific
    viewer types. The IFDEFs here in contrast just register a few platform-
    specific formats with nevertheless platform-neutral viewers. }
  TryRegisterViewer(cfGIF, TBitmapFormatViewer);
  TryRegisterViewer(cfJpeg, TBitmapFormatViewer);
  TryRegisterViewer(cfPNG, TBitmapFormatViewer);
  TryRegisterViewer(cfTIFF, TBitmapFormatViewer);
  {$IFDEF MSWINDOWS}
  TryRegisterViewer(cfAnsiText, TAnsiTextFormatViewer);
  TryRegisterViewer(cfAnsiFileName, TAnsiTextFormatViewer);
  TryRegisterViewer(cfUnicodeFileName, TUnicodeTextFormatViewer);
  TryRegisterViewer(cfHDROP, TFileNamesViewer);
  TryRegisterViewer(cfBitmap, TWinBitmapFormatViewer);
  TryRegisterViewer(cfDIBv5, TWinBitmapFormatViewer);
  TryRegisterViewer(cfDataObject, TWinDataObjectFormatViewer);
  {$ELSE}
  TryRegisterViewer(cfFileName, TFileNamesViewer);
  {$ENDIF}
  {$IFDEF MACOS}
  TryRegisterViewer(cfAppleICNS, TBitmapFormatViewer);
  TryRegisterViewer(TClipboard.RegisterFormat('NSFilenamesPboardType'), TFileNamesViewer);
  TryRegisterViewer(TClipboard.RegisterFormat('Apple URL pasteboard type'), TURLsViewer);
  {$ENDIF}
  TryRegisterViewer(cfVirtualFileDescriptor, TVirtualFileDescriptorsViewer);
  TryRegisterViewer(cfRTF, TUTF8TextFormatViewer);
  TryRegisterViewer(cfUTF8Text, TUTF8TextFormatViewer);
  TryRegisterViewer(cfUnicodeText, TUnicodeTextFormatViewer);
  TryRegisterViewer(cfURL, TURLsViewer);
  TryRegisterViewer(cfComponent, TComponentFormatViewer);
  TryRegisterViewer(cfComponents, TComponentFormatViewer);
  TryRegisterViewer(cfMyCustomFormat, TUTF8TextFormatViewer);
  TryRegisterViewer(cfMyObject, TMyObjectFormatViewer);
  TryRegisterViewer(cfFMXGradient, TComponentFormatViewer);
end;

destructor TFormatViewerManager.Destroy;
begin
  FViewerMap.Free;
  FViewerInsts.Free;
  inherited;
end;

function TFormatViewerManager.FindViewer(const Format: TClipboardFormat; out Viewer: TFormatViewer): Boolean;
var
  Details: TViewerDetails;
begin
  for Details in FViewerMap do
  begin
    Result := Format.ConformsTo(Details.Format);
    if Result then
    begin
      if FViewerInsts.TryGetValue(Details.ViewerClass, Viewer) then Exit;
      Viewer := Details.ViewerClass.Create(Details.Control);
      FViewerInsts.Add(Details.ViewerClass, Viewer);
      Exit;
    end;
  end;
  Result := False;
end;

function TFormatViewerManager.TryGetOutputControl(const ClassType: TControlClass; var Matched: TControl): Boolean;
var
  Control: TControl;
begin
  for Control in FOutputControls do
    if Control.InheritsFrom(ClassType) then
    begin
      Matched := Control;
      Result := True;
      Exit;
    end;
  Result := False;
end;

procedure TFormatViewerManager.RegisterViewer(const Format: TClipboardFormat; ViewerClass: TFormatViewerClass);
begin
  if not TryRegisterViewer(Format, ViewerClass) then
    raise EClipboardException.Create('Output control not available (' + ClassType.ClassName + ')');
end;

function TFormatViewerManager.TryRegisterViewer(const Format: TClipboardFormat;
  ViewerClass: TFormatViewerClass): Boolean;
var
  Details: TViewerDetails;
begin
  Details := TViewerDetails.Create;
  Result := TryGetOutputControl(ViewerClass.OutputClass, Details.Control);
  if not Result then
  begin
    Details.Free;
    Exit;
  end;
  FViewerMap.Add(Details);
  Details.Format := Format;
  Details.ViewerClass := ViewerClass;
end;

end.
