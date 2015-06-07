program FMXDesktopDemoXE2Plus;

uses
  FMX.Forms,
  CCR.Clipboard in '..\..\..\CCR.Clipboard.pas',
  CCR.Clipboard.Consts in '..\..\..\CCR.Clipboard.Consts.pas',
  CCR.Clipboard.Apple in '..\..\..\CCR.Clipboard.Apple.pas',
  CCR.Clipboard.Apple.Helpers in '..\..\..\CCR.Clipboard.Apple.Helpers.pas',
  CCR.Clipboard.Win in '..\..\..\CCR.Clipboard.Win.pas',
  CCR.Clipboard.FMX in '..\..\..\CCR.Clipboard.FMX.pas',
  CCR.Clipboard.FMX.Mac in '..\..\..\CCR.Clipboard.FMX.Mac.pas',
  CCR.Clipboard.FMX.Win in '..\..\..\CCR.Clipboard.FMX.Win.pas',
  ClipboardDemoForm in 'ClipboardDemoForm.pas' {frmClipboardDemo};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmClipboardDemo, frmClipboardDemo);
  Application.Run;
end.
