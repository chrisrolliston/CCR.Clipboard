unit VCLDemoForm;
{
  Demonstrates:
  - Implementing a basic clipboard viewer that decodes various formats
  - Copying various formats 'normally' and in a delay-rendered fashion
  - Pasting, including pasting more than one TPicture at the same time
  - TClipboard-based drag and drop, VCL version
  See the individual frame units for details.
}
interface

uses
  WinApi.Windows, WinApi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ComCtrls,
  Frame.Info, Frame.Copying, Frame.Pasting, Frame.DragAndDrop, Frame.ImageToDrag;

type
  TfrmVCLDemo = class(TForm)
    PageControl: TPageControl;
    tabInfo: TTabSheet;
    tabCopying: TTabSheet;
    tabPasting: TTabSheet;
    tabDragAndDrop: TTabSheet;
    fraInfo: TfraInfo;
    fraCopying: TfraCopying;
    fraPasting: TfraPasting;
    fraDragAndDrop: TfraDragAndDrop;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  end;

var
  frmVCLDemo: TfrmVCLDemo;

implementation

{$R *.dfm}

procedure TfrmVCLDemo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := fraCopying.CanClose;
end;

end.
