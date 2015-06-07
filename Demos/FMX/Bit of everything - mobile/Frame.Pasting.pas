unit Frame.Pasting;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  FMX.Types, FMX.Graphics, FMX.TextLayout,
  FMX.Controls, FMX.Forms, FMX.StdCtrls, FMX.ExtCtrls, FMX.Dialogs,
  FMX.Layouts, FMX.ListBox, System.Actions, FMX.ActnList, FMX.Objects, FMX.Ani,
  FMX.Effects, FMX.Controls.Presentation, FMX.Edit,
  CCR.Clipboard, CustomFormatExamples;

type
  TfraPasting = class(TFrame)
    ActionList: TActionList;
    actPaste: TAction;
    rctText: TRectangle;
    Label2: TLabel;
    imgBitmap: TImage;
    Label4: TLabel;
    Label1: TLabel;
    ShadowEffect1: TShadowEffect;
    aniTextToPaste: TColorAnimation;
    rctURL: TRectangle;
    aniURLToPaste: TColorAnimation;
    ShadowEffect2: TShadowEffect;
    rctBitmap: TRectangle;
    aniBitmapToPaste: TColorAnimation;
    ShadowEffect3: TShadowEffect;
    Label5: TLabel;
    rctGradient: TRectangle;
    aniGradientToPaste: TColorAnimation;
    ShadowEffect4: TShadowEffect;
    Label3: TLabel;
    procedure actPasteUpdate(Sender: TObject);
    procedure rctTextPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure rctTextClick(Sender: TObject);
    procedure rctURLClick(Sender: TObject);
    procedure rctBitmapClick(Sender: TObject);
    procedure rctGradientClick(Sender: TObject);
  strict private
    FLastChangeCount: TClipboardChangeCount;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

{ TfraPasting }

constructor TfraPasting.Create(AOwner: TComponent);
begin
  inherited;
  actPaste.DisableIfNoHandler := False;
  FLastChangeCount := TClipboardChangeCount(-1);
end;

procedure TfraPasting.actPasteUpdate(Sender: TObject);
var
  NewChangeCount: TClipboardChangeCount;
begin
  { Internally the TClipboard code caches HasFormatFor results for the latest
    change count. We do it too so in order to ensure our shapes only pulse when
    there is new data to paste. }
  NewChangeCount := Clipboard.ChangeCount;
  if NewChangeCount = FLastChangeCount then Exit;
  FLastChangeCount := NewChangeCount;
  aniTextToPaste.Enabled := Clipboard.HasText;
  aniURLToPaste.Enabled := Clipboard.HasURL;
  aniGradientToPaste.Enabled := Clipboard.HasFormatFor(TGradient);
  aniBitmapToPaste.Enabled := Clipboard.HasFormatFor(TBitmap);
end;

procedure TfraPasting.rctTextPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
var
  Layout: TTextLayout;
  Shape: TRectangle;
begin
  Shape := (Sender as TRectangle);
  if Shape.TagString = '' then Exit;
  Layout := TTextLayoutManager.TextLayoutByCanvas(Canvas.ClassType).Create;
  try
    Layout.BeginUpdate;
    try
      Layout.TopLeft := PointF(ARect.Left + Shape.Padding.Left,
                               ARect.Top + Shape.Padding.Top);
      Layout.MaxSize := PointF(ARect.Width - Shape.Padding.Left - Shape.Padding.Right,
                               ARect.Height - Shape.Padding.Top - Shape.Padding.Bottom);
      Layout.Text := Shape.TagString;
      Layout.WordWrap := True;
    finally
      Layout.EndUpdate;
    end;
    Layout.RenderLayout(Canvas);
  finally
    Layout.Free;
  end;
end;

procedure TfraPasting.rctTextClick(Sender: TObject);
begin
  aniTextToPaste.Enabled := False;
  rctText.Stroke.Color := aniTextToPaste.StartValue;
  if Clipboard.HasText then
    rctText.TagString := Clipboard.AsText;
end;

procedure TfraPasting.rctURLClick(Sender: TObject);
begin
  aniURLToPaste.Enabled := False;
  rctURL.Stroke.Color := aniURLToPaste.StartValue;
  if Clipboard.HasURL then
    rctURL.TagString := Clipboard.AsURL;
end;

procedure TfraPasting.rctBitmapClick(Sender: TObject);
begin
  aniBitmapToPaste.Enabled := False;
  rctBitmap.Stroke.Color := aniBitmapToPaste.StartValue;
  if Clipboard.HasFormatFor(TBitmap) then
    imgBitmap.Bitmap.Assign(Clipboard);
end;

procedure TfraPasting.rctGradientClick(Sender: TObject);
begin
  aniGradientToPaste.Enabled := False;
  rctGradient.Stroke.Color := aniGradientToPaste.StartValue;
  if Clipboard.HasFormatFor(TGradient) then
  begin
    rctGradient.Fill.Gradient.Assign(Clipboard);
    rctGradient.Fill.Gradient.Change; //TGradient bug
  end;
end;

end.
