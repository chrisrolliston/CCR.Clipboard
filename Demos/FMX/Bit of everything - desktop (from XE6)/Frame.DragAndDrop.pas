unit Frame.DragAndDrop;
{
  Demonstrates the FMX version of TClipboard-based drag and drop, including the
  generation of custom drag images.
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Memo, Frame.ImageToDrag;

type
  TfraDragAndDrop = class(TFrame)
    fraImageToDrag1: TfraImageToDrag;
    fraImageToDrag2: TfraImageToDrag;
    grpOtherSources: TGroupBox;
    rctPlainText: TRectangle;
    Text1: TText;
    rctVirtualRTF: TRectangle;
    Text2: TText;
    grpInfo: TGroupBox;
    lyoImages: TLayout;
    Splitter1: TSplitter;
    Layout1: TLayout;
    Splitter2: TSplitter;
    memInfo: TMemo;
    rctContentDest: TRectangle;
    txtDest: TText;
    rctGradient: TRectangle;
    Text3: TText;
    Layout2: TLayout;
    Splitter3: TSplitter;
    procedure memInfoDragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure memInfoDragDrop(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure rctContentDestDragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure rctContentDestDragDrop(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure rctPlainTextMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure rctGradientMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure rctContentDestDragEnter(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure rctVirtualRTFMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    FAcceptDrop: Boolean;
  end;

implementation

{$R *.fmx}

uses
  FMX.TextLayout, CCR.Clipboard, CCR.Clipboard.FMX;

procedure TfraDragAndDrop.memInfoDragOver(Sender: TObject;
  const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if Data.Source is TClipboard then
    Operation := TDragOperation.Copy
  else
    Operation := TDragOperation.None;
end;

procedure TfraDragAndDrop.rctGradientMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then Exit;
  TClipboard.BeginDrag(rctGradient,
    procedure (Clipboard: TClipboard)
    begin
      Clipboard.Assign(rctGradient.Fill.Gradient);
    end);
end;

procedure TfraDragAndDrop.rctPlainTextMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
const
  Margin: TPointF = (X: 10; Y: 10);
var
  DragImage: TBitmap;
  Layout: TTextLayout;
begin
  if Button <> TMouseButton.mbLeft then Exit;
  DragImage := nil;
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      Layout.Font.Size := 12 * (96 / 72);
      Layout.Font.Style := [TFontStyle.fsBold];
      Layout.TopLeft := Margin;
      Layout.MaxSize := PointF(grpOtherSources.Width * 3/4, 1000);
      Layout.WordWrap := True;
      Layout.Text := 'With a custom drag image, this is some plain text generated at ' + TimeToStr(Time);
      Layout.Color := TAlphaColors.Azure;
      Layout.Opacity := 0.5;
    finally
      Layout.EndUpdate;
    end;
    DragImage := TBitmap.Create;
    DragImage.SetSize(Trunc(Layout.TextWidth + Margin.X * 2), Trunc(Layout.TextHeight + Margin.Y * 2));
    DragImage.Clear(TAlphaColors.Null);
    DragImage.Canvas.BeginScene;
    Layout.TopLeft := PointF(Margin.X - 1, Margin.Y - 1);
    Layout.HorizontalAlign := TTextAlign.Center;
    Layout.RenderLayout(DragImage.Canvas);
    Layout.TopLeft := PointF(Margin.X + 1, Margin.Y + 1);
    Layout.RenderLayout(DragImage.Canvas);
    Layout.Color := TAlphaColors.Black;
    Layout.Opacity := 1;
    Layout.RenderLayout(DragImage.Canvas);
    Layout.TopLeft := Margin;
    DragImage.Canvas.EndScene;
    TClipboard.BeginDrag(DragImage,
      procedure (Clipboard: TClipboard)
      begin
        Clipboard.AsText := Layout.Text;
      end);
  finally
    DragImage.Free;
    Layout.Free;
  end;
end;

procedure TfraDragAndDrop.rctVirtualRTFMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then Exit;
  TClipboard.BeginDrag(rctVirtualRTF,
    procedure (Clipboard: TClipboard)
    var
      RTF: TBytes;
    begin
      RTF := TEncoding.UTF8.GetBytes(
        '{\rtf1\ansi\deff0' + sLineBreak +
        '{\colortbl;\red0\green0\blue0;\red255\green0\blue0;}' + sLineBreak +
        'This is a test:\line' + sLineBreak +
        '\cf2' + sLineBreak + 'Oh yes it is\line}');
      Clipboard.AssignVirtualFile('Example.rtf', RTF);
    end);
end;

procedure TfraDragAndDrop.rctContentDestDragEnter(Sender: TObject;
  const Data: TDragObject; const Point: TPointF);
var
  Clipboard: TClipboard;
begin
  if not (Data.Source is TClipboard) then
    FAcceptDrop := False
  else
  begin
    Clipboard := TClipboard(Data.Source);
    FAcceptDrop := Clipboard.HasText or Clipboard.HasFile or Clipboard.HasURL or
      Clipboard.HasFormatFor(TGradient);
  end;
end;

procedure TfraDragAndDrop.rctContentDestDragOver(Sender: TObject;
  const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if FAcceptDrop then
    Operation := TDragOperation.Copy
  else
    Operation := TDragOperation.None;
end;

procedure TfraDragAndDrop.rctContentDestDragDrop(Sender: TObject;
  const Data: TDragObject; const Point: TPointF);
var
  Clipboard: TClipboard;
begin
  Clipboard := Data.Source as TClipboard;
  if Clipboard.HasFormatFor(TGradient) then
  begin
    rctContentDest.Fill.Gradient.Assign(Clipboard);
    rctContentDest.Fill.Kind := TBrushKind.Gradient;
  end
  else
    rctContentDest.Fill.Kind := TBrushKind.Solid;
  if Clipboard.HasText then
    txtDest.Text := Clipboard.AsText
  else if Clipboard.HasFile then
    txtDest.Text := string.Join(sLineBreak, Clipboard.GetFileNames)
  else if Clipboard.HasURL then
    txtDest.Text := string.Join(sLineBreak, Clipboard.GetURLs)
end;

procedure TfraDragAndDrop.memInfoDragDrop(Sender: TObject;
  const Data: TDragObject; const Point: TPointF);
var
  Format: TClipboardFormat;
begin
  memInfo.Lines.BeginUpdate;
  try
    memInfo.Lines.Clear;
    for Format in (Data.Source as TClipboard) do
      memInfo.Lines.Add(Format.Name)
  finally
    memInfo.Lines.EndUpdate;
  end;
end;

end.
