unit Frame.Copying;

interface

uses
  System.Types, System.SysUtils, System.Math, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.ToolWin, Vcl.StdActns,
  Vcl.ExtActns, Vcl.ActnList, Vcl.ImgList;

type
  TfraCopying = class(TFrame)
    imlCopying: TImageList;
    aclCopying: TActionList;
    FormatRichEditBold1: TRichEditBold;
    FormatRichEditItalic1: TRichEditItalic;
    FormatRichEditUnderline1: TRichEditUnderline;
    FormatRichEditStrikeOut1: TRichEditStrikeOut;
    FormatRichEditBullets1: TRichEditBullets;
    FormatRichEditAlignLeft1: TRichEditAlignLeft;
    FormatRichEditAlignRight1: TRichEditAlignRight;
    FormatRichEditAlignCenter1: TRichEditAlignCenter;
    actLoadPicture: TOpenPicture;
    panSourceData: TPanel;
    Splitter1: TSplitter;
    panTextToCopy: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton9: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    ToolButton5: TToolButton;
    rchSource: TRichEdit;
    panImageToCopy: TPanel;
    imgSource: TImage;
    ToolBar2: TToolBar;
    ToolButton11: TToolButton;
    panFilesToCopy: TPanel;
    Label10: TLabel;
    memFilesToCopy: TMemo;
    lblImmediate: TLabel;
    panImmediateButtons: TPanel;
    btnCopyPlainText: TButton;
    btnCopyRichText: TButton;
    btnCopyVirtualBMP: TButton;
    btnCopyFiles: TButton;
    btnCopyAll: TButton;
    lblDelayed: TLabel;
    panDelayedButtons: TPanel;
    btnCopyPlainTextDelayed: TButton;
    btnCopyRichTextDelayed: TButton;
    btnCopyVirtualBMPDelayed: TButton;
    btnCopyURLDelayed: TButton;
    btnCopyDelayedAll: TButton;
    panPromises: TPanel;
    btnResolvePromises: TButton;
    btnCancelPromises: TButton;
    actResolvePromises: TAction;
    actCancelPromises: TAction;
    rdoAlwaysResolvePromisesOnExit: TRadioButton;
    rdoPromptToResolvePromises: TRadioButton;
    Label1: TLabel;
    procedure actLoadPictureAccept(Sender: TObject);
    procedure btnCopyPlainTextClick(Sender: TObject);
    procedure btnCopyPlainTextDelayedClick(Sender: TObject);
    procedure btnCopyRichTextClick(Sender: TObject);
    procedure btnCopyRichTextDelayedClick(Sender: TObject);
    procedure btnCopyURLDelayedClick(Sender: TObject);
    procedure btnCopyVirtualBMPClick(Sender: TObject);
    procedure btnCopyVirtualBMPDelayedClick(Sender: TObject);
    procedure btnCopyFilesClick(Sender: TObject);
    procedure btnCopyAllClick(Sender: TObject);
    procedure btnCopyDelayedAllClick(Sender: TObject);
    procedure actResolvePromisesUpdate(Sender: TObject);
    procedure actCancelPromisesUpdate(Sender: TObject);
    procedure actCancelPromisesExecute(Sender: TObject);
    procedure actResolvePromisesExecute(Sender: TObject);
  strict private
    procedure RenderBitmap(Dest: TBitmap);
    function RenderText: string;
    procedure RenderRTF(Stream: TStream);
    function RenderURL: string;
  public
    constructor Create(AOwner: TComponent); override;
    function CanClose: Boolean;
  end;

implementation

uses
  System.UITypes, CCR.Clipboard;

{$R *.dfm}

resourcestring
  SConfirmRenderPendingItems =
    'You placed some data on the Clipboard. Do you want it available to other ' +
    'applications after you quit this one?';

constructor TfraCopying.Create(AOwner: TComponent);
begin
  inherited;
  rchSource.WordWrap := True;
  memFilesToCopy.Text := Application.ExeName;
end;

{ On application closedown the default behaviour is to cancel pending items. Resolving
  instead is likely what you'd want, and is what TClipboard instances that aren't the
  Clipboard singleton do on their destruction. It's an explicit operation for the
  singleton however due to the risk of stale pointers in the rendering callbacks. }

function TfraCopying.CanClose: Boolean;
begin
  Result := True;
  if Clipboard.HasOutstandingPromisesToOS then
    if not rdoPromptToResolvePromises.Checked then
      Clipboard.ResolveOutstandingPromisesToOS
    else
      case MessageDlg(SConfirmRenderPendingItems, mtConfirmation, mbYesNoCancel, 0) of
        mrYes: Clipboard.ResolveOutstandingPromisesToOS;
        mrNo: Clipboard.CancelOutstandingPromisesToOS;
      else Result := False;
      end
end;

{ Delayed rendering callbacks }

procedure TfraCopying.RenderBitmap(Dest: TBitmap);
var
  Ext: TSize;
  Msg: string;
  X, Y: Integer;
  Tile: TGraphic;
begin
  Application.MainForm.Caption := 'Rendering tiled image at ' + TimeToStr(Time);
  Tile := imgSource.Picture.Graphic;
  Dest.SetSize(Screen.Width, Screen.Height);
  for X := 0 to Ceil(Dest.Width / Tile.Width) - 1 do
    for Y := 0 to Ceil(Dest.Height / Tile.Height) - 1 do
      Dest.Canvas.Draw(X * Tile.Width, Y * Tile.Height, Tile);
  Msg := ' Image rendered at ' + TimeToStr(Time) + ' ';
  Dest.Canvas.Brush.Color := clYellow;
  Dest.Canvas.Font.Name := 'Arial Black';
  Dest.Canvas.Font.Size := 18;
  Ext := Dest.Canvas.TextExtent(Msg);
  Dest.Canvas.TextOut((Dest.Width - Ext.cx) div 2, (Dest.Height - Ext.cy) div 2, Msg);
end;

function TfraCopying.RenderText: string;
begin
  Application.MainForm.Caption := 'Rendering plain text at ' + TimeToStr(Time);
  Result := 'This text was delay-rendered at ' + TimeToStr(Time) + sLineBreak + rchSource.Text;
end;

procedure TfraCopying.RenderRTF(Stream: TStream);
begin
  Application.MainForm.Caption := 'Rendering rich text at ' + TimeToStr(Time);
  rchSource.Lines.SaveToStream(Stream);
end;

function TfraCopying.RenderURL: string;
begin
  Application.MainForm.Caption := 'Rendering URL at ' + TimeToStr(Time);
  Result := 'https://quality.embarcadero.com/secure/Dashboard.jspa';
end;

procedure TfraCopying.actCancelPromisesExecute(Sender: TObject);
begin
  Clipboard.CancelOutstandingPromisesToOS;
end;

procedure TfraCopying.actCancelPromisesUpdate(Sender: TObject);
begin
  actCancelPromises.Enabled := Clipboard.HasOutstandingPromisesToOS;
end;

procedure TfraCopying.actLoadPictureAccept(Sender: TObject);
begin
  imgSource.Picture.LoadFromFile(actLoadPicture.Dialog.FileName);
end;

procedure TfraCopying.actResolvePromisesExecute(Sender: TObject);
begin
  Clipboard.ResolveOutstandingPromisesToOS;
end;

procedure TfraCopying.actResolvePromisesUpdate(Sender: TObject);
begin
  actResolvePromises.Enabled := Clipboard.HasOutstandingPromisesToOS;
end;

procedure TfraCopying.btnCopyAllClick(Sender: TObject);
begin
  Clipboard.Open;
  try
    btnCopyPlainText.Click;
    btnCopyRichText.Click;
    btnCopyVirtualBMP.Click;
    btnCopyFiles.Click;
  finally
    Clipboard.Close;
  end;
end;

procedure TfraCopying.btnCopyDelayedAllClick(Sender: TObject);
begin
  Clipboard.Open;
  try
    Clipboard.AssignTextDelayed(RenderText);
    Clipboard.AssignDelayed(cfRTF, RenderRTF);
    Clipboard.AssignVirtualFileDelayed<TBitmap>('Test.bmp', RenderBitmap);
    Clipboard.AssignURLDelayed(RenderURL);
  finally
    Clipboard.Close;
  end;
end;

procedure TfraCopying.btnCopyFilesClick(Sender: TObject);
var
  S: string;
begin
  Application.MainForm.Caption := 'Adding files at ' + TimeToStr(Time);
  Clipboard.Open;
  try
    for S in memFilesToCopy.Lines do
      if S <> '' then
        Clipboard.AssignFile(S);
  finally
    Clipboard.Close;
  end;
end;

procedure TfraCopying.btnCopyPlainTextClick(Sender: TObject);
begin
  Clipboard.AsText := RenderText; //or Clipboard.AssignText(RenderText);
end;

procedure TfraCopying.btnCopyPlainTextDelayedClick(Sender: TObject);
begin
  Application.MainForm.Caption := 'Delay rendered text added to clipboard...';
  Clipboard.AssignTextDelayed(RenderText);
end;

procedure TfraCopying.btnCopyRichTextClick(Sender: TObject);
var
  Stream: TBytesStream;
begin
  Stream := TBytesStream.Create;
  try
    RenderRTF(Stream);
    Clipboard.Assign(cfRTF, Stream);
  finally
    Stream.Free;
  end;
end;

procedure TfraCopying.btnCopyRichTextDelayedClick(Sender: TObject);
begin
  Application.MainForm.Caption := 'Delay rendered rich text added to clipboard...';
  Clipboard.AssignDelayed(cfRTF, RenderRTF);
end;

procedure TfraCopying.btnCopyURLDelayedClick(Sender: TObject);
begin
  Application.MainForm.Caption := 'Delay rendered URL added to clipboard...';
  Clipboard.AssignURLDelayed(RenderURL);
end;

procedure TfraCopying.btnCopyVirtualBMPClick(Sender: TObject);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    RenderBitmap(Bitmap);
    Clipboard.AssignVirtualFile('Test.bmp', Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure TfraCopying.btnCopyVirtualBMPDelayedClick(Sender: TObject);
begin
  Application.MainForm.Caption := 'Delay rendered virtual file added to clipboard...';
  Clipboard.AssignVirtualFileDelayed<TBitmap>('Test.bmp', RenderBitmap);
end;

end.


