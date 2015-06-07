program CustomClipboardDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  ClipboardMainForm in 'ClipboardMainForm.pas' {frmMain},
  CCR.Clipboard.Apple.Helpers in '..\..\..\CCR.Clipboard.Apple.Helpers.pas',
  CCR.Clipboard.Apple in '..\..\..\CCR.Clipboard.Apple.pas',
  CCR.Clipboard.Consts in '..\..\..\CCR.Clipboard.Consts.pas',
  CCR.Clipboard.FMX.iOS in '..\..\..\CCR.Clipboard.FMX.iOS.pas',
  CCR.Clipboard.FMX.Mac in '..\..\..\CCR.Clipboard.FMX.Mac.pas',
  CCR.Clipboard.FMX in '..\..\..\CCR.Clipboard.FMX.pas',
  CCR.Clipboard in '..\..\..\CCR.Clipboard.pas',
  ClipboardContentsForm in 'ClipboardContentsForm.pas' {frmClipboardContents};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
