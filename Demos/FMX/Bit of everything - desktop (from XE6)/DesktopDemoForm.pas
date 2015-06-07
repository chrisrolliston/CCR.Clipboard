unit DesktopDemoForm;
{
  Demonstrates:
  - Implementing a basic clipboard viewer that decodes various formats
  - Copying various formats 'normally' and in a delay-rendered fashion
  - Pasting, including pasting more multiple instances of the same class
  - TClipboard-based drag and drop, FMX version
  See the individual frame units for details.
}
interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Objects, FMX.StdCtrls,
  AppIntf, Frame.Info, Frame.Copying, Frame.Pasting, Frame.DragAndDrop;

type
  TfrmDesktopDemo = class(TForm, IAppMainForm)
    TabControl: TTabControl;
    tabInfo: TTabItem;
    tabCopying: TTabItem;
    tabPasting: TTabItem;
    tabDragDrop: TTabItem;
    fraInfo: TfraInfo;
    fraCopying: TfraCopying;
    fraPasting: TfraPasting;
    fraDragAndDrop1: TfraDragAndDrop;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  protected
    { IAppMainForm }
    procedure NotifyFrames(Msg: Word);
  end;

var
  frmDesktopDemo: TfrmDesktopDemo;

implementation

{$R *.fmx}

uses
  CCR.Clipboard, CCR.Clipboard.FMX;

procedure TfrmDesktopDemo.FormCreate(Sender: TObject);
begin
  //registering for TClipboard-based drag and drop in FMX done at the form level
  if TClipboard.SupportsDragAndDrop then
    TClipboard.RegisterForDragAndDrop(Self)
  else
    tabDragDrop.Visible := False;
end;

procedure TfrmDesktopDemo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Comp: TComponent;
  Intf: ICanCloseResponder;
begin
  for Comp in Self do
    if Supports(Comp, ICanCloseResponder, Intf) and not Intf.CanClose then
    begin
      CanClose := False;
      Exit;
    end;
end;

procedure TfrmDesktopDemo.NotifyFrames(Msg: Word);
var
  Comp: TComponent;
begin
  for Comp in Self do
    if Comp is TFrame then
      TFrame(Comp).Dispatch(Msg);
end;

end.
