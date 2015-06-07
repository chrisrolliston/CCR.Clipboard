unit Frame.ImageToDrag;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.ListBox, FMX.Layouts;

type
  TfraImageToDrag = class(TFrame)
    grpImage: TGroupBox;
    Layout1: TLayout;
    btnReset: TButton;
    cboBehaviour: TComboBox;
    Image: TImage;
    procedure btnResetClick(Sender: TObject);
    procedure ImageDragEnter(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    procedure ImageDragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure ImageDragDrop(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
  private
    FCanDrop: Boolean;
    FOrigBitmap: TBitmap;
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

uses
  CCR.Clipboard;

constructor TfraImageToDrag.Create(AOwner: TComponent);
begin
  inherited;
  FOrigBitmap := TBitmap.Create;
  { By default, a TImage with its DragMode set to dmAutomatic will drag its content.
    We'll provide an explicit event handler to implement further options. }
  TClipboard.OnGetDragData[Image] :=
    procedure (DraggedObject: TObject; Clipboard: TClipboard)
    begin
      case cboBehaviour.ItemIndex of
        0: Clipboard.Assign(Image.Bitmap);
        1: Clipboard.AssignVirtualFile('Image.png', Image.Bitmap);
      else
        Clipboard.Assign(Image.Bitmap);
        Clipboard.AssignVirtualFile('Image.png', Image.Bitmap);
      end;
    end;
end;

destructor TfraImageToDrag.Destroy;
begin
  FOrigBitmap.Free;
  inherited;
end;

procedure TfraImageToDrag.ImageDragEnter(Sender: TObject; const Data: TDragObject;
  const Point: TPointF);
begin
  FCanDrop := (Data.Source is TClipboard) and TClipboard(Data.Source).HasFormatFor(TBitmap);
end;

procedure TfraImageToDrag.ImageDragOver(Sender: TObject;
  const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
begin
  if FCanDrop then
    Operation := TDragOperation.Copy
  else
    Operation := TDragOperation.None;
end;

procedure TfraImageToDrag.Loaded;
begin
  inherited;
  FOrigBitmap.Assign(Image.Bitmap);
end;

procedure TfraImageToDrag.ImageDragDrop(Sender: TObject;
  const Data: TDragObject; const Point: TPointF);
var
  Clipboard: TClipboard;
begin
  Clipboard := Data.Source as TClipboard;
  if Clipboard.ObjectBeingDragged <> Sender then
    Image.Bitmap.Assign(Clipboard);
end;

procedure TfraImageToDrag.btnResetClick(Sender: TObject);
begin
  Image.Bitmap.Assign(FOrigBitmap);
end;

end.
