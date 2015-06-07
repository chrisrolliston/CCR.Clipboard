program SimpleClipperAndObjectsDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  SimpleClipperAndGetObjectsForm in 'SimpleClipperAndGetObjectsForm.pas' {frmSimpleClipperAndGetObjectsDemo},
  CCR.Clipboard in '..\..\..\CCR.Clipboard.pas',
  CCR.Clipboard.Apple in '..\..\..\CCR.Clipboard.Apple.pas',
  CCR.Clipboard.Apple.Helpers in '..\..\..\CCR.Clipboard.Apple.Helpers.pas',
  CCR.Clipboard.Consts in '..\..\..\CCR.Clipboard.Consts.pas',
  CCR.Clipboard.FMX.iOS in '..\..\..\CCR.Clipboard.FMX.iOS.pas',
  CCR.Clipboard.FMX.Mac in '..\..\..\CCR.Clipboard.FMX.Mac.pas',
  CCR.Clipboard.FMX in '..\..\..\CCR.Clipboard.FMX.pas',
  CCR.Clipboard.FMX.Win in '..\..\..\CCR.Clipboard.FMX.Win.pas',
  CCR.Clipboard.Win in '..\..\..\CCR.Clipboard.Win.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TfrmSimpleClipperAndGetObjectsDemo, frmSimpleClipperAndGetObjectsDemo);
  Application.Run;
end.
