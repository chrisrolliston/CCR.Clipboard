unit Frame.ImageToDrag;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, VCL.Imaging.GIFImg, VCL.Imaging.JPEG, Vcl.Imaging.PNGImage;

type
  TfraImageToDrag = class(TFrame)
    grpImage: TGroupBox;
    Image: TImage;
    cboBehaviour: TComboBox;
    btnReset: TButton;
    Panel1: TPanel;
    procedure btnResetClick(Sender: TObject);
    procedure ImageDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ImageDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FImageAcceptDrop: Boolean;
    FOrigPicture: TPicture;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
  CCR.Clipboard, CCR.Clipboard.VCL;

function GetFileExtForGraphic(Graphic: TGraphic): string;
begin
  Result := '';
  if Graphic is TBitmap then
    Result := '.bmp'
  else if Graphic is TPngImage then
    Result := '.png'
  else if Graphic is TGIFImage then
    Result := '.gif'
  else if Graphic is TJPEGImage then
    Result := '.jpg'
  else if Graphic is TMetafile then
    if TMetafile(Graphic).Enhanced then
      Result := '.emf'
    else
      Result := '.wmf'
  else if Graphic is TWICImage then
    case TWICImage(Graphic).ImageFormat of
      wifBmp: Result := '.bmp';
      wifPng: Result := '.png';
      wifJpeg: Result := '.jpg';
      wifGif: Result := '.gif';
      wifTiff: Result := '.tif';
      wifWMPhoto: Result := '.wmp';
    end;
end;

constructor TfraImageToDrag.Create(AOwner: TComponent);
begin
  FOrigPicture := TPicture.Create;
  inherited;
  TClipboard.RegisterDropTarget(Image);
end;

destructor TfraImageToDrag.Destroy;
begin
  FOrigPicture.Free;
  inherited;
end;

procedure TfraImageToDrag.Loaded;
begin
  inherited;
  FOrigPicture.Assign(Image.Picture);
end;

procedure TfraImageToDrag.ImageDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  Clipboard: TClipboard;
begin
  Clipboard := (Source as TClipboard);
  if Clipboard.ObjectBeingDragged <> Sender then
    (Sender as TImage).Picture.Assign(Clipboard);
end;

procedure TfraImageToDrag.ImageDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  Clipboard: TClipboard;
begin
  if State = dsDragEnter then
  begin
    Clipboard := (Source as TClipboard);
    FImageAcceptDrop := (Clipboard.ObjectBeingDragged = Sender) or
      Clipboard.HasFormatFor(TPicture);
  end;
  Accept := FImageAcceptDrop;
end;

procedure TfraImageToDrag.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Image: TImage;
begin
  Image := (Sender as TImage);
  if (Button = mbLeft) and not Image.Picture.Graphic.Empty then
    TClipboard.BeginDrag(Image,
      procedure (Clipboard: TClipboard)
      var
        VirtualFileName: string;
      begin
        VirtualFileName := 'Image' + GetFileExtForGraphic(Image.Picture.Graphic);
        case cboBehaviour.ItemIndex of
          0: Clipboard.Assign(Image.Picture);
          1: Clipboard.AssignVirtualFile(VirtualFileName, Image.Picture.Graphic);
        else
          Clipboard.Assign(Image.Picture);
          Clipboard.AssignVirtualFile(VirtualFileName, Image.Picture.Graphic);
        end;
      end);
end;

procedure TfraImageToDrag.btnResetClick(Sender: TObject);
begin
  Image.Picture.Assign(FOrigPicture);
end;

end.

