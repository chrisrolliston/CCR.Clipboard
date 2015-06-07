unit Frame.Copying;
{
  Demonstrates copying various formats to the clipboard in either an immediately
  or delay rendered way.
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Actions,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Memo, FMX.Objects, FMX.ActnList, FMX.ListBox,
  FMX.Edit, FMX.Colors, CustomFormatExamples, AppIntf;

type
  TAvailableFormat = (afPlainText, afRTF, afBitmap, afVirtualPNG, afVirtualRTF,
    afFile1, afFile2, afURL, afComponent, afGradient, afCustomFormat, afCustomObject);
  TAvailableFormats = set of TAvailableFormat;

  TfraCopying = class(TFrame, ICanCloseResponder)
    aclCopying: TActionList;
    actCancelPromises: TAction;
    actResolvePromises: TAction;
    lyoSourceData: TLayout;
    lblSourceData: TLabel;
    memSource: TMemo;
    imgSource: TImageControl;
    txtDblClickToLoadBitmap: TText;
    edtFile1: TEdit;
    btnChooseFile1: TEllipsesEditButton;
    edtFile2: TEdit;
    btnChooseFile2: TEllipsesEditButton;
    edtURL: TEdit;
    panComponentToCopy: TPanel;
    Text1: TText;
    Selection1: TSelection;
    Rectangle1: TRectangle;
    Selection2: TSelection;
    Rectangle2: TRectangle;
    Selection3: TSelection;
    Rectangle3: TRectangle;
    actCopyNormal: TAction;
    actCopyDelayed: TAction;
    dlgFileToCopy: TOpenDialog;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout1: TLayout;
    Label2: TLabel;
    btnCopyImmediate: TButton;
    Button3: TButton;
    Line1: TLine;
    btnResolvePromises: TButton;
    btnCancelPromises: TButton;
    cboPromisesOnExit: TComboBox;
    Label5: TLabel;
    Layout2: TLayout;
    Label1: TLabel;
    chkText: TCheckBox;
    chkRTF: TCheckBox;
    chkVirtualPNG: TCheckBox;
    chkBitmap: TCheckBox;
    chkVirtualRTF: TCheckBox;
    chkFile1: TCheckBox;
    chkFile2: TCheckBox;
    chkURL: TCheckBox;
    chkComponent: TCheckBox;
    chkCustomFormat: TCheckBox;
    chkCustomObject: TCheckBox;
    Label3: TLabel;
    memStatus: TMemo;
    chkGradient: TCheckBox;
    Layout5: TLayout;
    ccbGradientPt1: TComboColorBox;
    edtGradient: TGradientEdit;
    ccbGradientPt0: TComboColorBox;
    procedure imgSourceLoaded(Sender: TObject; const FileName: string);
    procedure imgSourceDblClick(Sender: TObject);
    procedure actCancelPromisesUpdate(Sender: TObject);
    procedure actCancelPromisesExecute(Sender: TObject);
    procedure actResolvePromisesUpdate(Sender: TObject);
    procedure actResolvePromisesExecute(Sender: TObject);
    procedure chkFormatChange(Sender: TObject);
    procedure actCopyNormalUpdate(Sender: TObject);
    procedure actCopyDelayedUpdate(Sender: TObject);
    procedure actCopyDelayedExecute(Sender: TObject);
    procedure actCopyNormalExecute(Sender: TObject);
    procedure btnChooseFileClick(Sender: TObject);
    procedure edtFile1Change(Sender: TObject);
    procedure edtFile2Change(Sender: TObject);
    procedure ccbGradientPt0Change(Sender: TObject);
    procedure ccbGradientPt1Change(Sender: TObject);
  strict private
    FFormatsToCopy: TAvailableFormats;
    procedure RenderBitmap(Dest: TBitmap);
    function RenderComponent: TComponent;
    function RenderCustomFormat: TBytes;
    procedure RenderCustomObject(Obj: TMyObject);
    function RenderFileName1: TFileName;
    function RenderFileName2: TFileName;
    function RenderGradient: TGradient;
    function RenderText: string;
    function RenderRTF: TBytes;
    function RenderURL: string;
    procedure UpdateStatus(const Msg: string);
  protected
    { ICanCloseResponder }
    function CanClose: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

uses
  System.Math, CCR.Clipboard;

resourcestring
  SConfirmRenderPendingItems =
    'You placed some data on the Clipboard. Do you want it available to other ' +
    'applications after you quit this one?';

{ Helper routine; not part of the TClipboard demo as such }

function PlainTextToRTF(const Text: string): string;
var
  Builder: TStringBuilder;
  SpecialCharType: (scEnd, scCtrl, scSkip, scLF, scNonAscii);
  SeqStartPtr, EndPtr, SeekPtr: PChar;
  Seq: string;
begin
  SpecialCharType := scEnd;
  SeqStartPtr := PChar(Text);
  EndPtr := @SeqStartPtr[Length(Text)];
  SeekPtr := SeqStartPtr;
  Builder := TStringBuilder.Create(Length(Text) * 2);
  try
    while SeekPtr <= EndPtr do
    begin
      if SeekPtr = EndPtr then
        SpecialCharType := scEnd
      else
      begin
        Inc(SeekPtr);
        case SeekPtr^ of
          #13: SpecialCharType := scSkip;
          #10: SpecialCharType := scLF;
          '\', '{', '}': SpecialCharType := scCtrl;
          #128..High(Char): SpecialCharType := scNonAscii;
        else Continue;
        end;
      end;
      SetString(Seq, SeqStartPtr, SeekPtr - SeqStartPtr);
      Builder.Append(Seq);
      case SpecialCharType of
        scEnd: Break;
        scCtrl: Builder.Append('\' + SeekPtr^);
        scSkip: { add nowt };
        scLF: Builder.Append('\line ');
        scNonAscii: Builder.AppendFormat('\u%d?', [Ord(SeekPtr^)]);
      end;
      SeqStartPtr := @SeekPtr[1];
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

{ TfraCopying }

constructor TfraCopying.Create(AOwner: TComponent);
var
  AppPath: string;
begin
  inherited;
  AppPath := GetModuleName(0);
  {$IFDEF MACOS}
  AppPath := AppPath.Substring(0, AppPath.LastIndexOf('.app/') + 4);
  {$ENDIF}
  edtFile1.Text := AppPath;
  chkText.Tag := Ord(afPlainText);
  chkRTF.Tag := Ord(afRTF);
  chkBitmap.Tag := Ord(afBitmap);
  chkVirtualPNG.Tag := Ord(afVirtualPNG);
  chkVirtualRTF.Tag := Ord(afVirtualRTF);
  chkFile1.Tag := Ord(afFile1);
  chkFile2.Tag := Ord(afFile2);
  chkURL.Tag := Ord(afURL);
  chkComponent.Tag := Ord(afComponent);
  chkGradient.Tag := Ord(afGradient);
  chkCustomFormat.Tag := Ord(afCustomFormat);
  chkCustomObject.Tag := Ord(afCustomObject);
  ccbGradientPt0Change(nil);
  ccbGradientPt1Change(nil);
end;

{ On application closedown the default behaviour is to cancel any outstanding delayed
  rendering promises to the OS. Resolving instead is likely what you'd want, and is
  what TClipboard instances that aren't the Clipboard singleton do on their destruction.
  It's an explicit operation for the singleton however due to the risk of stale pointers
  in the rendering callbacks. }

function TfraCopying.CanClose: Boolean;
begin
  Result := True;
  if Clipboard.HasOutstandingPromisesToOS then
    case cboPromisesOnExit.ItemIndex of
      0: Clipboard.ResolveOutstandingPromisesToOS;
      1:
        case MessageDlg(SConfirmRenderPendingItems, TMsgDlgType.mtConfirmation, mbYesNoCancel, 0) of
          mrYes: Clipboard.ResolveOutstandingPromisesToOS;
          mrNo: Clipboard.CancelOutstandingPromisesToOS;
        else Result := False;
        end
    else Clipboard.CancelOutstandingPromisesToOS;
    end;
end;

{ Delayed rendering callbacks }

procedure TfraCopying.RenderBitmap(Dest: TBitmap);
var
  Ext: TRectF;
  Msg: string;
  Size: TSize;
  SrcRect: TRectF;
  X, Y: Integer;
  Tile: TBitmap;
begin
  UpdateStatus('Rendering tiled image at ' + TimeToStr(Time));
  Tile := imgSource.Bitmap;
  SrcRect := RectF(0, 0, Tile.Width, Tile.Height);
  Size := Screen.Size;
  Dest.SetSize(Size.Width, Size.Height);
  Dest.Canvas.BeginScene;
  try
    for X := 0 to Ceil(Size.Width / Tile.Width) - 1 do
      for Y := 0 to Ceil(Size.Height / Tile.Height) - 1 do
        Dest.Canvas.DrawBitmap(Tile, SrcRect,
          TRectF.Create(PointF(X * Tile.Width, Y * Tile.Height), Tile.Width, Tile.Height), 1);
    Msg := ' Image rendered at ' + TimeToStr(Time) + ' ';
    Dest.Canvas.Font.Family := 'Arial Black';
    Dest.Canvas.Font.Size := 18 * 96 / 72;
    Ext := RectF(0, 0, (Dest.Width - Dest.Canvas.TextWidth(Msg)) / 2,
      (Dest.Height - Dest.Canvas.TextHeight(Msg)) / 2);
    Dest.Canvas.Fill.Color := TAlphaColors.Yellow;
    Dest.Canvas.FillRect(Ext, 0, 0, [], 0.8);
    Dest.Canvas.Fill.Color := TAlphaColors.Black;
    Dest.Canvas.FillText(Ext, Msg, False, 0.8, [], TTextAlign.Center);
  finally
    Dest.Canvas.EndScene;
  end;
end;

function TfraCopying.RenderComponent: TComponent;
begin
  UpdateStatus('Rendering component at ' + TimeToStr(Time));
  Result := panComponentToCopy;
end;

function TfraCopying.RenderFileName1: TFileName;
begin
  UpdateStatus('Rendering file name 1 at ' + TimeToStr(Time));
  Result := edtFile1.Text;
end;

function TfraCopying.RenderFileName2: TFileName;
begin
  UpdateStatus('Rendering file name 2 at ' + TimeToStr(Time));
  Result := edtFile2.Text;
end;

function TfraCopying.RenderGradient: TGradient;
begin
  UpdateStatus('Rendering gradient at ' + TimeToStr(Time));
  Result := edtGradient.Gradient;
end;

function TfraCopying.RenderText: string;
begin
  UpdateStatus('Rendering plain text at ' + TimeToStr(Time));
  Result := 'This text was delay-rendered at ' + TimeToStr(Time) + sLineBreak + memSource.Text;
end;

function TfraCopying.RenderRTF: TBytes;
begin
  UpdateStatus('Rendering rich text at ' + TimeToStr(Time));
  Result := TEncoding.UTF8.GetBytes(
    '{\rtf1\ansi\deff0' + sLineBreak +
    '{\colortbl;\red0\green0\blue0;\red255\green0\blue0;}' + sLineBreak +
    'Here is the memo text:\line' + sLineBreak +
    '\cf2' + sLineBreak + PlainTextToRTF(memSource.Text) + '\line' + sLineBreak +
    '\cf1' + sLineBreak +
    'This text was rendered on ' + PlainTextToRTF(DateTimeToStr(Now)) + ' - over and out...}');
end;

function TfraCopying.RenderURL: string;
begin
  UpdateStatus('Rendering URL at ' + TimeToStr(Time));
  Result := edtURL.Text;
end;

function TfraCopying.RenderCustomFormat: TBytes;
begin
  UpdateStatus('Rendering custom format at ' + TimeToStr(Time));
  Result := TEncoding.UTF8.GetBytes('Custom data generated on ' + DateTimeToStr(Now));
end;

procedure TfraCopying.RenderCustomObject(Obj: TMyObject);
begin
  UpdateStatus('Rendering custom object at ' + TimeToStr(Time));
  Obj.DateTime := Now;
  Obj.Text := memSource.Text;
end;

{ other }

procedure TfraCopying.UpdateStatus(const Msg: string);
begin
  memStatus.Lines.Insert(0, Msg);
  Application.MainForm.Caption := Msg;
end;

procedure TfraCopying.edtFile1Change(Sender: TObject);
begin
  chkFile1.Enabled := (edtFile1.Text <> '');
  if not chkFile1.Enabled then chkFile1.IsChecked := False;
end;

procedure TfraCopying.edtFile2Change(Sender: TObject);
begin
  chkFile2.Enabled := (edtFile2.Text <> '');
  if not chkFile2.Enabled then chkFile2.IsChecked := False;
end;

procedure TfraCopying.ccbGradientPt0Change(Sender: TObject);
begin
  edtGradient.Gradient.Color := ccbGradientPt0.Color;
  edtGradient.Repaint;
end;

procedure TfraCopying.ccbGradientPt1Change(Sender: TObject);
begin
  edtGradient.Gradient.Color1 := ccbGradientPt1.Color;
  edtGradient.Repaint;
end;

procedure TfraCopying.chkFormatChange(Sender: TObject);
var
  CheckBox: TCheckBox;
begin
  CheckBox := (Sender as TCheckBox);
  if CheckBox.IsChecked then
    Include(FFormatsToCopy, TAvailableFormat(CheckBox.Tag))
  else
    Exclude(FFormatsToCopy, TAvailableFormat(CheckBox.Tag));
end;

procedure TfraCopying.imgSourceDblClick(Sender: TObject);
begin
  imgSource.EnableOpenDialog := True;
  try
    imgSource.ShowOpenDialog;
  finally
    imgSource.EnableOpenDialog := False;
  end;
end;

procedure TfraCopying.imgSourceLoaded(Sender: TObject; const FileName: string);
begin
  txtDblClickToLoadBitmap.Visible := False;
  chkBitmap.Enabled := True;
  chkVirtualPNG.Enabled := True;
end;

procedure TfraCopying.btnChooseFileClick(Sender: TObject);
var
  Control: TControl;
begin
  Control := (Sender as TControl);
  while not Control.InheritsFrom(TEdit) do
    Control := Control.ParentControl;
  dlgFileToCopy.FileName := TEdit(Control).Text;
  if not dlgFileToCopy.Execute then Exit;
  TEdit(Control).Text := dlgFileToCopy.FileName;
end;

procedure TfraCopying.actCancelPromisesUpdate(Sender: TObject);
begin
  actCancelPromises.Enabled := Clipboard.HasOutstandingPromisesToOS;
end;

procedure TfraCopying.actCopyDelayedExecute(Sender: TObject);
var
  BitmapGetter: TFunc<TBitmap>;
begin
  { Next line is just to prevent fraInfo from auto-updating any currently-selected
    format - while neat in itself, can suggest delayed rendering isn't working! }
  (Application.MainForm as IAppMainForm).NotifyFrames(CM_CANCELCLIPBOARDSELECTION);
  { OK, on to business... }
  Application.MainForm.Caption := Application.Title;
  BitmapGetter := TRenderedObject<TBitmap>.Create(RenderBitmap);
  Clipboard.Open;
  try
    if afPlainText in FFormatsToCopy then
      Clipboard.AssignTextDelayed(RenderText);
    if afRTF in FFormatsToCopy then
      Clipboard.AssignDelayed(cfRTF, RenderRTF);
    if afBitmap in FFormatsToCopy then
      Clipboard.AssignDelayed<TBitmap>(BitmapGetter);
    if afVirtualPNG in FFormatsToCopy then
      Clipboard.AssignVirtualFileDelayed<TBitmap>('Example.png', BitmapGetter);
    if afVirtualRTF in FFormatsToCopy then
      Clipboard.AssignVirtualFileDelayed('Example.rtf', RenderRTF);
    if afFile1 in FFormatsToCopy then
      Clipboard.AssignFileDelayed(RenderFileName1);
    if afFile2 in FFormatsToCopy then
      Clipboard.AssignFileDelayed(RenderFileName2);
    if afURL in FFormatsToCopy then
      Clipboard.AssignURLDelayed(RenderURL);
    if afComponent in FFormatsToCopy then
    begin
      UpdateStatus('Delayed component assignments not supported on any platform');
      Clipboard.SetComponent(RenderComponent);
    end;
    if afGradient in FFormatsToCopy then
      Clipboard.AssignDelayed<TGradient>(RenderGradient);
    if afCustomFormat in FFormatsToCopy then
      Clipboard.AssignDelayed(cfMyCustomFormat, RenderCustomFormat);
    if afCustomObject in FFormatsToCopy then
      Clipboard.AssignDelayed<TMyObject>(RenderCustomObject);
  finally
    Clipboard.Close;
  end;
end;

procedure TfraCopying.actCopyDelayedUpdate(Sender: TObject);
begin
  actCopyDelayed.Enabled := FFormatsToCopy <> [];
end;

procedure TfraCopying.actCopyNormalExecute(Sender: TObject);
var
  BitmapGetter: TFunc<TBitmap>;
  Obj: TMyObject;
begin
  Application.MainForm.Caption := Application.Title;
  { Next line is just to avoid creating and rendering two bitmaps if both afBitmap
    and afVirtualPNG are set; the TFunc<T> returned by TRenderedObject<T> will
    also free the wrapped object when it itself goes out of scope. }
  BitmapGetter := TRenderedObject<TBitmap>.Create(RenderBitmap);
  Clipboard.Open;
  try
    if afPlainText in FFormatsToCopy then
      Clipboard.AssignText(RenderText); //or Clipboard.AsText := RenderText
    if afRTF in FFormatsToCopy then
      Clipboard.Assign(cfRTF, RenderRTF);
    if afBitmap in FFormatsToCopy then
      Clipboard.Assign(BitmapGetter());
    if afVirtualPNG in FFormatsToCopy then
      Clipboard.AssignVirtualFile('Example.png', BitmapGetter());
    if afVirtualRTF in FFormatsToCopy then
      Clipboard.AssignVirtualFile('Example.rtf', RenderRTF);
    if afFile1 in FFormatsToCopy then
      Clipboard.AssignFile(RenderFileName1);
    if afFile2 in FFormatsToCopy then
      Clipboard.AssignFile(RenderFileName2);
    if afURL in FFormatsToCopy then
      Clipboard.AssignURL(RenderURL);
    if afComponent in FFormatsToCopy then
      Clipboard.SetComponent(RenderComponent);
    if afGradient in FFormatsToCopy then
      Clipboard.Assign(RenderGradient);
    if afCustomFormat in FFormatsToCopy then
      Clipboard.Assign(cfMyCustomFormat, RenderCustomFormat);
    if afCustomObject in FFormatsToCopy then
    begin
      Obj := TMyObject.Create;
      try
        RenderCustomObject(Obj);
        Clipboard.Assign(Obj);
      finally
        Obj.Free;
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

procedure TfraCopying.actCopyNormalUpdate(Sender: TObject);
begin
  actCopyNormal.Enabled := FFormatsToCopy <> [];
end;

procedure TfraCopying.actCancelPromisesExecute(Sender: TObject);
begin
  Clipboard.CancelOutstandingPromisesToOS;
end;

procedure TfraCopying.actResolvePromisesExecute(Sender: TObject);
begin
  Clipboard.ResolveOutstandingPromisesToOS;
end;

procedure TfraCopying.actResolvePromisesUpdate(Sender: TObject);
begin
  actResolvePromises.Enabled := Clipboard.HasOutstandingPromisesToOS;
end;

end.
