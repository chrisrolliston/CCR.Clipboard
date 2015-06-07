unit Frame.Copying;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.Edit, FMX.ExtCtrls,
  FMX.Objects, FMX.Effects, System.Actions, FMX.ActnList, FMX.StdActns,
  FMX.Colors;

type
  TImage = class(FMX.Objects.TImage)
  strict private
    FOnChange: TNotifyEvent;
  protected
    procedure DoChanged; override;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TfraCopying = class(TFrame)
    lyoText1: TLayout;
    swtText1: TSwitch;
    lyoText2: TLayout;
    swtText2: TSwitch;
    edtText1: TEdit;
    ClearEditButton1: TClearEditButton;
    edtText2: TEdit;
    ClearEditButton2: TClearEditButton;
    lyoURL1: TLayout;
    swtURL1: TSwitch;
    edtURL1: TEdit;
    ClearEditButton3: TClearEditButton;
    lyoURL2: TLayout;
    swtURL2: TSwitch;
    edtURL2: TEdit;
    ClearEditButton4: TClearEditButton;
    lyoImage1: TLayout;
    swtImage1: TSwitch;
    Rectangle1: TRectangle;
    InnerGlowEffect1: TInnerGlowEffect;
    lblImage1Hint: TLabel;
    Image1: TImage;
    lyoImage2: TLayout;
    swtImage2: TSwitch;
    Rectangle2: TRectangle;
    InnerGlowEffect2: TInnerGlowEffect;
    Image2: TImage;
    lblImage2Hint: TLabel;
    lyoGradient: TLayout;
    swtGradient: TSwitch;
    Label1: TLabel;
    cboColorFrom: TComboColorBox;
    cboColorTo: TComboColorBox;
    Label2: TLabel;
    tmrFixupLayout: TTimer;
    ToolBar1: TToolBar;
    lyoOptions: TLayout;
    btnCopySelectedItems: TSpeedButton;
    procedure ImageClick(Sender: TObject);
    procedure btnCopySelectedItemsClick(Sender: TObject);
    procedure edtText1Change(Sender: TObject);
    procedure edtText2Change(Sender: TObject);
    procedure edtURL1Change(Sender: TObject);
    procedure edtURL2Change(Sender: TObject);
    procedure Image1Change(Sender: TObject);
    procedure Image2Change(Sender: TObject);
    procedure tmrFixupLayoutTimer(Sender: TObject);
  private
    FFixedUpLayouts: Boolean;
  protected
    procedure Painting; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  System.Math, FMX.MediaLibrary, FMX.Platform, CCR.Clipboard;

{$R *.fmx}

type
  TImageChooser = class(TComponent)
  strict private
    FDlg: TOpenDialog;
    FService: IFMXTakenImageService;
    FTargetImage: TImage;
    procedure FinishedTaking(Bitmap: TBitmap);
    procedure CancelTaking;
  public
    constructor Create(const TargetImage: TImage); reintroduce;
    procedure Execute;
  end;

constructor TImageChooser.Create(const TargetImage: TImage);
begin
  inherited Create(TargetImage);
  FTargetImage := TargetImage;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXTakenImageService, FService) then
  begin
    FDlg := TOpenDialog.Create(Self);
    FDlg.Filter := TBitmapCodecManager.GetFilterString;
    FDlg.DefaultExt := 'png';
    FDlg.Options := FDlg.Options + [TOpenOption.ofFileMustExist];
  end;
end;

procedure TImageChooser.Execute;
var
  Params: TParamsPhotoQuery;
begin
  Params.RequiredResolution.cx := 1024;
  Params.RequiredResolution.cy := 1024;
  Params.Editable := False;
  Params.NeedSaveToAlbum := False;
  Params.OnDidFinishTaking := FinishedTaking;
  Params.OnDidCancelTaking := CancelTaking;
  if FService <> nil then
    FService.TakeImageFromLibrary(FTargetImage, Params)
  else if FDlg.Execute then
    FTargetImage.Bitmap.LoadFromFile(FDlg.FileName);
end;

procedure TImageChooser.CancelTaking;
begin
end;

procedure TImageChooser.FinishedTaking(Bitmap: TBitmap);
begin
  FTargetImage.Bitmap.Assign(Bitmap);
end;

{ TImage }

procedure TImage.DoChanged;
begin
  inherited;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

{ TfraCopying }

procedure UpdateSwitch(Switch: TSwitch; HaveData: Boolean);
begin
  if Switch.Enabled = HaveData then Exit;
  Switch.IsChecked := HaveData;
  Switch.Enabled := HaveData;
end;

constructor TfraCopying.Create(AOwner: TComponent);
begin
  inherited;
  Image1.OnChange := Image1Change;
  Image2.OnChange := Image2Change;
end;

procedure TfraCopying.Painting;
begin
  inherited Painting;
  if not FFixedUpLayouts then
  begin
    FFixedUpLayouts := True;
    tmrFixupLayout.Enabled := True;
  end;
end;

procedure TfraCopying.tmrFixupLayoutTimer(Sender: TObject);

  procedure FixupLayout(Layout: TLayout);
  var
    Ctrl: TControl;
    MaxHeight: Single;
    Switch: TSwitch;
  begin
    MaxHeight := 0;
    Switch := nil;
    for Ctrl in Layout.Controls do
    begin
      if Ctrl.Height > MaxHeight then MaxHeight := Ctrl.Height;
      if (Switch = nil) and (Ctrl is TSwitch) then
        Switch := TSwitch(Ctrl);
    end;
    Assert(Switch <> nil);
    Layout.Height := MaxHeight;
    for Ctrl in Layout.Controls do
      Ctrl.Position.Y := (MaxHeight - Ctrl.Height) / 2;
    Switch.Position.X := Layout.Width - Switch.Width;
    Switch.Anchors := [TAnchorKind.akTop, TAnchorKind.akRight];
    if Layout.Controls.Count = 2 then
    begin
      Ctrl := Layout.Controls.First;
      if Ctrl = Switch then Ctrl := Layout.Controls.Last;
      Ctrl.Width := Switch.Position.X - lyoOptions.Padding.Left;
      Ctrl.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
    end;
  end;
var
  Control: TControl;
  ButtonY: Single;
begin
  tmrFixupLayout.Enabled := False;
  ButtonY := 0;
  for Control in lyoOptions.Controls do
    if (Control is TLayout) and (Control.Controls.Count >= 2) then
    begin
      FixupLayout(TLayout(Control));
      ButtonY := Max(ButtonY, Control.Position.Y + Control.Height);
    end;
end;

procedure TfraCopying.edtText1Change(Sender: TObject);
begin
  UpdateSwitch(swtText1, edtText1.Text <> '');
end;

procedure TfraCopying.edtText2Change(Sender: TObject);
begin
  UpdateSwitch(swtText2, edtText2.Text <> '');
end;

procedure TfraCopying.edtURL1Change(Sender: TObject);
begin
  UpdateSwitch(swtURL1, edtURL1.Text <> '');
end;

procedure TfraCopying.edtURL2Change(Sender: TObject);
begin
  UpdateSwitch(swtURL2, edtURL2.Text <> '');
end;

procedure TfraCopying.Image1Change(Sender: TObject);
begin
  lblImage1Hint.Visible := (Image1.MultiResBitmap.Count = 0);
  UpdateSwitch(swtImage1, not lblImage1Hint.Visible);
end;

procedure TfraCopying.Image2Change(Sender: TObject);
begin
  lblImage2Hint.Visible := (Image2.MultiResBitmap.Count = 0);
  UpdateSwitch(swtImage2, not lblImage2Hint.Visible);
end;

procedure TfraCopying.ImageClick(Sender: TObject);
var
  Chooser: TImageChooser;
  Image: TImage;
begin
  Image := (Sender as TImage);
  Chooser := (Image.TagObject as TImageChooser);
  if Chooser = nil then
  begin
    Chooser := TImageChooser.Create(Image);
    Image.TagObject := Chooser;
  end;
  Chooser.Execute;
end;

{ The actual TClipboard-using code! }

procedure TfraCopying.btnCopySelectedItemsClick(Sender: TObject);
var
  Gradient: TGradient;
begin
  Clipboard.Open;
  try
    if swtText1.IsChecked and (edtText1.Text <> '') then
      Clipboard.AssignText(edtText1.Text);
    if swtText2.IsChecked and (edtText2.Text <> '') then
      Clipboard.AssignText(edtText2.Text);
    if swtURL1.IsChecked and (edtURL1.Text <> '') then
      Clipboard.AssignURL(edtURL1.Text);
    if swtURL2.IsChecked and (edtURL2.Text <> '') then
      Clipboard.AssignURL(edtURL2.Text);
    if swtImage1.IsChecked and not Image1.Bitmap.IsEmpty then
      Clipboard.Assign(Image1.Bitmap);
    if swtImage2.IsChecked and not Image2.Bitmap.IsEmpty then
      Clipboard.Assign(Image2.Bitmap);
    if swtGradient.IsChecked then
    begin
      Gradient := TGradient.Create;
      try
        Gradient.Color1 := cboColorFrom.Color;
        Gradient.Color := cboColorTo.Color;
        Clipboard.Assign(Gradient);
      finally
        Gradient.Free;
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

end.
