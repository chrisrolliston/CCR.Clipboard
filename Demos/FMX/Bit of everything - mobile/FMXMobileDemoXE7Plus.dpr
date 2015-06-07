program FMXMobileDemoXE7Plus;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.MobilePreview,
  CCR.Clipboard in '..\..\..\CCR.Clipboard.pas',
  CCR.Clipboard.Consts in '..\..\..\CCR.Clipboard.Consts.pas',
  CCR.Clipboard.Apple in '..\..\..\CCR.Clipboard.Apple.pas',
  CCR.Clipboard.Apple.Helpers in '..\..\..\CCR.Clipboard.Apple.Helpers.pas',
  CCR.Clipboard.Win in '..\..\..\CCR.Clipboard.Win.pas',
  CCR.Clipboard.FMX in '..\..\..\CCR.Clipboard.FMX.pas',
  CCR.Clipboard.FMX.Mac in '..\..\..\CCR.Clipboard.FMX.Mac.pas',
  CCR.Clipboard.FMX.iOS in '..\..\..\CCR.Clipboard.FMX.iOS.pas',
  CCR.Clipboard.FMX.Win in '..\..\..\CCR.Clipboard.FMX.Win.pas',
  CustomFormatExamples in '..\CustomFormatExamples.pas',
  FormatViewers in '..\FormatViewers.pas',
  MobileDemoForm in 'MobileDemoForm.pas' {frmMobileDemo},
  Frame.Viewer in 'Frame.Viewer.pas' {fraViewer: TFrame},
  Frame.Copying in 'Frame.Copying.pas' {fraCopying: TFrame},
  Frame.Pasting in 'Frame.Pasting.pas' {fraPasting: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMobileDemo, frmMobileDemo);
  Application.Run;
end.
