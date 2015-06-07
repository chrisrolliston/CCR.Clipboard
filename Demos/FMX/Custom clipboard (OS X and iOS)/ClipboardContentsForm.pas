unit ClipboardContentsForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ExtCtrls, FMX.Memo, FMX.StdCtrls;

type
  TfrmClipboardContents = class(TForm)
    lblClipboardName: TLabel;
    Memo: TMemo;
    Label1: TLabel;
    ImageViewer: TImageViewer;
    Layout1: TLayout;
    btnClose: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
