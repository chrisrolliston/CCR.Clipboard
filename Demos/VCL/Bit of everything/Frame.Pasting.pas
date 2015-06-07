unit Frame.Pasting;

interface

uses
  WinApi.Windows, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ActnList;

type
  TfraPasting = class(TFrame)
    ActionList: TActionList;
    actPastePictures: TAction;
    actPasteRTF: TAction;
    actPastePlainText: TAction;
    actPasteURL: TAction;
    actPasteFileNames: TAction;
    panText: TPanel;
    Label11: TLabel;
    btnPasteRTF: TButton;
    memPastedText: TRichEdit;
    btnPastePlainText: TButton;
    panFileNames: TPanel;
    Label13: TLabel;
    btnPasteFileNames: TButton;
    memPastedFileNames: TMemo;
    panURL: TPanel;
    Label12: TLabel;
    btnPasteURL: TButton;
    memPastedURL: TMemo;
    panPictures: TPanel;
    Label7: TLabel;
    btnPastePictures: TButton;
    pgsGraphics: TPageScroller;
    panPastePicturesInfo: TPanel;
    Label8: TLabel;
    actPasteComponent: TAction;
    actPasteVirtualFiles: TAction;
    btnPasteVirtualFiles: TButton;
    procedure actPastePlainTextExecute(Sender: TObject);
    procedure actPastePlainTextUpdate(Sender: TObject);
    procedure actPasteRTFExecute(Sender: TObject);
    procedure actPasteRTFUpdate(Sender: TObject);
    procedure actPastePicturesExecute(Sender: TObject);
    procedure actPastePicturesUpdate(Sender: TObject);
    procedure actPasteURLExecute(Sender: TObject);
    procedure actPasteURLUpdate(Sender: TObject);
    procedure actPasteFileNamesExecute(Sender: TObject);
    procedure actPasteFileNamesUpdate(Sender: TObject);
    procedure actPasteVirtualFilesUpdate(Sender: TObject);
    procedure actPasteVirtualFilesExecute(Sender: TObject);
  strict private
    FVirtualFileOutputDir: string;
  public
    destructor Destroy; override;
  end;

implementation

uses
  System.IOUtils, CCR.Clipboard;

{$R *.dfm}

destructor TfraPasting.Destroy;
begin
  if FVirtualFileOutputDir <> '' then TDirectory.Delete(FVirtualFileOutputDir, True);
  inherited;
end;

procedure TfraPasting.actPasteFileNamesExecute(Sender: TObject);
begin
  memPastedFileNames.Clear;
  memPastedFileNames.Lines.AddStrings(Clipboard.GetFileNames);
end;

procedure TfraPasting.actPasteFileNamesUpdate(Sender: TObject);
begin
  actPasteFileNames.Enabled := Clipboard.HasFile;
end;

procedure TfraPasting.actPastePicturesExecute(Sender: TObject);
var
  NextLeft: Integer;
  Panel: TPanel;
begin
  if not Clipboard.HasFormatFor(TPicture) then
  begin
    Beep;
    Exit;
  end;
  Panel := TPanel.Create(Self);
  Panel.BevelOuter := bvNone;
  NextLeft := 0;
  Clipboard.GetObjects<TPicture>(
    procedure (const AssignTo: TProc<TPicture>; var LookForMore: Boolean)
    var
      Image: TImage;
    begin
      Image := TImage.Create(Panel);
      AssignTo(Image.Picture);
      Image.Proportional := True;
      Image.SetBounds(NextLeft, 0,
        MulDiv(pgsGraphics.Height, Image.Picture.Width, Image.Picture.Height), pgsGraphics.Height);
      Inc(NextLeft, Image.Width);
      Image.Parent := Panel;
    end);
  Panel.Width := NextLeft;
  pgsGraphics.Control.Free;
  pgsGraphics.Control := Panel;
end;

procedure TfraPasting.actPastePicturesUpdate(Sender: TObject);
begin
  actPastePictures.Enabled := Clipboard.HasFormatFor(TPicture);
end;

procedure TfraPasting.actPastePlainTextExecute(Sender: TObject);
begin
  memPastedText.Lines.Clear;
  memPastedText.PlainText := True;
  memPastedText.Text := Clipboard.AsText;
end;

procedure TfraPasting.actPastePlainTextUpdate(Sender: TObject);
begin
  actPastePlainText.Enabled := Clipboard.HasText;
end;

procedure TfraPasting.actPasteRTFExecute(Sender: TObject);
var
  Stream: TBytesStream;
begin
  memPastedText.Lines.Clear;
  memPastedText.PlainText := False;
  { Ideally would do memPastedText.RichText := Clipboard.AsRTF; however, TRichEdit
    doesn't have a RichText property, so have to stream in }
  Stream := TBytesStream.Create(Clipboard.GetBytes(cfRTF));
  try
    memPastedText.Lines.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TfraPasting.actPasteRTFUpdate(Sender: TObject);
begin
  actPasteRTF.Enabled := Clipboard.HasFormat(cfRTF);
end;

procedure TfraPasting.actPasteURLExecute(Sender: TObject);
begin
  memPastedURL.Lines.Clear;
  memPastedURL.Lines.AddStrings(Clipboard.GetURLs);
end;

procedure TfraPasting.actPasteURLUpdate(Sender: TObject);
begin
  actPasteURL.Enabled := Clipboard.HasURL;
end;

procedure TfraPasting.actPasteVirtualFilesExecute(Sender: TObject);
begin
  if FVirtualFileOutputDir <> '' then
    TDirectory.Delete(FVirtualFileOutputDir, True);
  FVirtualFileOutputDir := IncludeTrailingPathDelimiter(TPath.GetTempPath) +
    'TClipboard demo ' + FormatDateTime('yyyy-mm-dd hh-mm-ss', Now);
  if not ForceDirectories(FVirtualFileOutputDir) then
    RaiseLastOSError;
  Clipboard.SaveVirtualFiles(FVirtualFileOutputDir, memPastedFileNames.Lines);
end;

procedure TfraPasting.actPasteVirtualFilesUpdate(Sender: TObject);
begin
  actPasteVirtualFiles.Enabled := Clipboard.HasVirtualFile;
end;

end.
