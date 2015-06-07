program VCLDemo;

uses
  Vcl.Forms,
  CCR.Clipboard in '..\..\..\CCR.Clipboard.pas',
  CCR.Clipboard.Consts in '..\..\..\CCR.Clipboard.Consts.pas',
  CCR.Clipboard.Win in '..\..\..\CCR.Clipboard.Win.pas',
  CCR.Clipboard.VCL in '..\..\..\CCR.Clipboard.VCL.pas',
  Frame.Info in 'Frame.Info.pas' {fraInfo: TFrame},
  Frame.Copying in 'Frame.Copying.pas' {fraCopying: TFrame},
  Frame.Pasting in 'Frame.Pasting.pas' {fraPasting: TFrame},
  Frame.DragAndDrop in 'Frame.DragAndDrop.pas' {fraDragAndDrop: TFrame},
  Frame.ImageToDrag in 'Frame.ImageToDrag.pas' {fraImageToDrag: TFrame},
  VCLDemoForm in 'VCLDemoForm.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'VCL Demo';
  Application.CreateForm(TfrmVCLDemo, frmVCLDemo);
  Application.Run;
end.
