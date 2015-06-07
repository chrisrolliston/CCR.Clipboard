program CustomClipperDemoVCL;

uses
  Vcl.Forms,
  CustomClipperForm in 'CustomClipperForm.pas' {frmCustomClipper},
  SpinnerFrame in 'SpinnerFrame.pas' {fraSpinner: TFrame},
  CCR.Clipboard.Consts in '..\..\..\CCR.Clipboard.Consts.pas',
  CCR.Clipboard in '..\..\..\CCR.Clipboard.pas',
  CCR.Clipboard.VCL in '..\..\..\CCR.Clipboard.VCL.pas',
  CCR.Clipboard.Win in '..\..\..\CCR.Clipboard.Win.pas',
  CustomRectClipper in '..\..\CustomRectClipper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmCustomClipper, frmCustomClipper);
  Application.Run;
end.
