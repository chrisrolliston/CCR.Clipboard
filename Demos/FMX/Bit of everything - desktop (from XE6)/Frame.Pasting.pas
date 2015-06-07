unit Frame.Pasting;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Generics.Collections,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Actions, FMX.ActnList, FMX.Layouts, FMX.Memo, FMX.ExtCtrls, FMX.Colors;

type
  TLoadItemEvent = procedure (Index: Integer) of object;

  TFramedScrollBox = class(FMX.Layouts.TFramedScrollBox)
  protected
    procedure SetData(const Value: TValue); override;
  end;

  TMemo = class(FMX.Memo.TMemo)
  protected
    procedure SetData(const Value: TValue); override;
  end;

  TfraPasting = class(TFrame)
    ActionList: TActionList;
    actPasteBitmaps: TAction;
    actPastePlainText: TAction;
    actPasteURLs: TAction;
    actPasteFileNames: TAction;
    Layout1: TLayout;
    Label1: TLabel;
    Button1: TButton;
    memPastedText: TMemo;
    Layout2: TLayout;
    Label2: TLabel;
    btnPasteFileNames: TButton;
    memPastedFileNames: TMemo;
    Layout3: TLayout;
    Label3: TLabel;
    Button3: TButton;
    memPastedURLs: TMemo;
    Layout5: TLayout;
    Layout6: TLayout;
    Splitter1: TSplitter;
    Layout4: TLayout;
    Label4: TLabel;
    Button4: TButton;
    Layout7: TLayout;
    Label5: TLabel;
    Button5: TButton;
    sbxComponentHost: TFramedScrollBox;
    Splitter2: TSplitter;
    actPasteComponents: TAction;
    lyoTextItemStatus: TLayout;
    lyoItemButtons: TLayout;
    btnPrevTextItem: TButton;
    btnNextTextItem: TButton;
    lblTextItem: TLabel;
    imgPastedBitmap: TImageViewer;
    lyoBitmapStatus: TLayout;
    Layout9: TLayout;
    btnPrevBitmap: TButton;
    btnNextBitmap: TButton;
    lblBitmap: TLabel;
    Layout8: TLayout;
    Layout10: TLayout;
    btnPrevComponent: TButton;
    btnNextComponent: TButton;
    lblComponent: TLabel;
    Layout11: TLayout;
    Label6: TLabel;
    Button6: TButton;
    actPasteGradient: TAction;
    edtGradient: TGradientEdit;
    actPasteVirtualFiles: TAction;
    btnPasteVirtualFiles: TButton;
    procedure actPasteURLsExecute(Sender: TObject);
    procedure actPasteURLsUpdate(Sender: TObject);
    procedure actPasteFileNamesExecute(Sender: TObject);
    procedure actPasteFileNamesUpdate(Sender: TObject);
    procedure actPastePlainTextExecute(Sender: TObject);
    procedure actPastePlainTextUpdate(Sender: TObject);
    procedure actPasteBitmapsExecute(Sender: TObject);
    procedure actPasteBitmapsUpdate(Sender: TObject);
    procedure btnPrevTextItemClick(Sender: TObject);
    procedure btnNextTextItemClick(Sender: TObject);
    procedure btnPrevBitmapClick(Sender: TObject);
    procedure btnNextBitmapClick(Sender: TObject);
    procedure actPasteComponentsExecute(Sender: TObject);
    procedure actPasteComponentsUpdate(Sender: TObject);
    procedure btnPrevComponentClick(Sender: TObject);
    procedure btnNextComponentClick(Sender: TObject);
    procedure actPasteGradientExecute(Sender: TObject);
    procedure actPasteGradientUpdate(Sender: TObject);
    procedure actPasteVirtualFilesExecute(Sender: TObject);
    procedure actPasteVirtualFilesUpdate(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
  private
    FBitmaps: TObjectList<TBitmap>;
    FBitmapIndex, FComponentIndex, FTextItemIndex: Integer;
    FComponents: TObjectList<TComponent>;
    FShowing: Boolean;
    FTextItems: TArray<string>;
    class procedure DoSetItemIndex<T>(PrevButton, NextButton: TControl;
      CaptionLabel: TLabel; Viewer: TControl; const Items: TArray<T>;
      var CurIndex: Integer; NewIndex: Integer);
    procedure SetBitmapIndex(NewIndex: Integer);
    procedure SetComponentIndex(NewIndex: Integer);
    procedure SetTextItemIndex(NewIndex: Integer);
  strict private
    FVirtualFileOutputDir: string;
  protected
    procedure AncestorVisibleChanged(const AncestorVisible: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses
  System.IOUtils, CCR.Clipboard;

{$R *.fmx}

{ TFramedScrollBox }

procedure TFramedScrollBox.SetData(const Value: TValue);
var
  Child: TControl;
begin
  for Child in Content.Controls do
    Child.Parent := nil;
  if Value.IsEmpty then Exit;
  Child := Value.AsType<TControl>;
  Child.SetBounds(10, 10, Child.Width, Child.Height);
  Child.Parent := Content;
end;

{ TMemo }

procedure TMemo.SetData(const Value: TValue);
begin
  //standard impl fails to take into account that an empty TValue's ToString returns '(empty)' not ''
  if Value.IsEmpty then
    Lines.Clear
  else
    inherited;
end;

{ TfraPasting }

class procedure TfraPasting.DoSetItemIndex<T>(PrevButton, NextButton: TControl;
  CaptionLabel: TLabel; Viewer: TControl; const Items: TArray<T>;
  var CurIndex: Integer; NewIndex: Integer);
var
  DispTotal: Integer;
begin
  if Items = nil then DispTotal := 1 else DispTotal := Length(Items);
  CurIndex := NewIndex;
  CaptionLabel.Text := Format('%d of %d', [NewIndex + 1, DispTotal]);
  PrevButton.Enabled := (NewIndex > 0);
  NextButton.Enabled := (NewIndex < Pred(DispTotal));
  if Items <> nil then
    Viewer.Data := TValue.From<T>(Items[NewIndex])
  else
    Viewer.Data := TValue.Empty;
end;

constructor TfraPasting.Create(AOwner: TComponent);
begin
  inherited;
  FBitmaps := TObjectList<TBitmap>.Create;
  FComponents := TObjectList<TComponent>.Create;
  SetBitmapIndex(0);
  SetComponentIndex(0);
  SetTextItemIndex(0);
end;

destructor TfraPasting.Destroy;
begin
  if FVirtualFileOutputDir <> '' then TDirectory.Delete(FVirtualFileOutputDir, True);
  FComponents.OwnsObjects := False; //allow TComponent ownership to take its course
  FComponents.Free;
  FBitmaps.Free;
  inherited;
end;

procedure TfraPasting.AncestorVisibleChanged(const AncestorVisible: Boolean);
var
  Ctrl: TControl;
begin
  inherited;
  if not AncestorVisible then
    FShowing := False
  else
  begin
    Ctrl := Self;
    repeat
      FShowing := Ctrl.Visible;
      Ctrl := Ctrl.ParentControl;
    until not FShowing or (Ctrl = nil);
  end;
end;

procedure TfraPasting.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  Handled := not FShowing;
end;

procedure TfraPasting.SetBitmapIndex(NewIndex: Integer);
begin
  DoSetItemIndex<TBitmap>(btnPrevBitmap, btnNextBitmap, lblBitmap, imgPastedBitmap,
    FBitmaps.List, FBitmapIndex, NewIndex);
end;

procedure TfraPasting.SetComponentIndex(NewIndex: Integer);
begin
  DoSetItemIndex<TComponent>(btnPrevComponent, btnNextComponent, lblComponent, sbxComponentHost,
    FComponents.List, FComponentIndex, NewIndex);
end;

procedure TfraPasting.SetTextItemIndex(NewIndex: Integer);
begin
  DoSetItemIndex<string>(btnPrevTextItem, btnNextTextItem, lblTextItem, memPastedText,
    FTextItems, FTextItemIndex, NewIndex);
end;

procedure TfraPasting.actPasteBitmapsExecute(Sender: TObject);
begin
  FBitmaps.Clear;
  Clipboard.GetObjects<TBitmap>(
    procedure (const AssignTo: TProc<TBitmap>; var LookForMore: Boolean)
    var
      Bitmap: TBitmap;
    begin
      Bitmap := TBitmap.Create;
      FBitmaps.Add(Bitmap);
      AssignTo(Bitmap);
    end);
  FBitmaps.Capacity := FBitmaps.Count;
  SetBitmapIndex(0);
end;

procedure TfraPasting.actPasteBitmapsUpdate(Sender: TObject);
begin
  actPasteBitmaps.Enabled := Clipboard.HasFormatFor(TBitmap);
end;

type
  TIgnoreErrorsReader = class(TReader)
  protected
    function Error(const Msg: string): Boolean; override;
  end;

function TIgnoreErrorsReader.Error(const Msg: string): Boolean;
begin
  Result := True;
end;

procedure TfraPasting.actPasteComponentsExecute(Sender: TObject);
begin
  { If the component can be streamed as an FMX control, then add it 'live', ignoring
    any streaming errors for missing event handlers etc., otherwise stream out to
    text and show a memo. The 'ignore all recoverable errors' policy does mean VCL
    controls can be 'pasted', though potentially with few readable properties. }
  FComponents.Clear;
  Clipboard.GetComponents(Self,
    function (Stream: TStream): TReader
    begin
      Result := TIgnoreErrorsReader.Create(Stream, $1000);
    end,
    procedure (const Comp: TComponent; var CheckForMore: Boolean)
    var
      BinStream, TextStream: TBytesStream;
      Encoding: TEncoding;
      Memo: TMemo;
      Offset: Integer;
    begin
      if Comp is TControl then
        FComponents.Add(Comp)
      else
      begin
        TextStream := nil;
        BinStream := TBytesStream.Create;
        try
          BinStream.WriteComponent(Comp);
          Comp.DisposeOf;
          BinStream.Seek(0, soBeginning);
          TextStream := TBytesStream.Create;
          ObjectBinaryToText(BinStream, TextStream);
          Encoding := nil;
          Offset := TEncoding.GetBufferEncoding(TextStream.Bytes, Encoding);
          Memo := TMemo.Create(Self);
          Memo.Align := TAlignLayout.Client;
          Memo.Text := Encoding.GetString(TextStream.Bytes, Offset, TextStream.Size - Offset);
          FComponents.Add(Memo)
        finally
          BinStream.Free;
          TextStream.Free;
        end;
      end;
    end);
  SetComponentIndex(0);
end;

procedure TfraPasting.actPasteComponentsUpdate(Sender: TObject);
begin
  actPasteComponents.Enabled := Clipboard.HasComponent;
end;

procedure TfraPasting.actPasteFileNamesExecute(Sender: TObject);
begin
  Clipboard.GetFileNames(memPastedFileNames.Lines);
end;

procedure TfraPasting.actPasteFileNamesUpdate(Sender: TObject);
begin
  actPasteFileNames.Enabled := Clipboard.HasFile
end;

procedure TfraPasting.actPasteGradientExecute(Sender: TObject);
begin
  edtGradient.Gradient.Assign(Clipboard);
  edtGradient.Repaint;
end;

procedure TfraPasting.actPasteGradientUpdate(Sender: TObject);
begin
  actPasteGradient.Enabled := Clipboard.HasFormatFor(TGradient);
end;

{$HINTS OFF} //we don't care about inlining Beep, thanks...
procedure TfraPasting.actPastePlainTextExecute(Sender: TObject);
begin
  FTextItems := Clipboard.GetText;
  if FTextItems = nil then
    Beep;
  SetTextItemIndex(0);
end;
{$HINTS ON}

procedure TfraPasting.actPastePlainTextUpdate(Sender: TObject);
begin
  actPastePlainText.Enabled := Clipboard.HasText;
end;

procedure TfraPasting.actPasteURLsExecute(Sender: TObject);
begin
  Clipboard.GetURLs(memPastedURLs.Lines);
end;

procedure TfraPasting.actPasteURLsUpdate(Sender: TObject);
begin
  actPasteURLs.Enabled := Clipboard.HasURL;
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

procedure TfraPasting.btnNextBitmapClick(Sender: TObject);
begin
  SetBitmapIndex(FBitmapIndex + 1);
end;

procedure TfraPasting.btnNextComponentClick(Sender: TObject);
begin
  SetComponentIndex(FBitmapIndex + 1);
end;

procedure TfraPasting.btnNextTextItemClick(Sender: TObject);
begin
  SetTextItemIndex(FTextItemIndex + 1);
end;

procedure TfraPasting.btnPrevBitmapClick(Sender: TObject);
begin
  SetBitmapIndex(FBitmapIndex - 1);
end;

procedure TfraPasting.btnPrevComponentClick(Sender: TObject);
begin
  SetComponentIndex(FComponentIndex - 1);
end;

procedure TfraPasting.btnPrevTextItemClick(Sender: TObject);
begin
  SetTextItemIndex(FTextItemIndex - 1);
end;

end.
