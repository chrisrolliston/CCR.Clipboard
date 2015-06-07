program MultipleFormatSetsDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormatSetsForm in 'FormatSetsForm.pas' {frmFormatSets},
  CCR.Clipboard in '..\..\..\CCR.Clipboard.pas',
  CCR.Clipboard.Apple in '..\..\..\CCR.Clipboard.Apple.pas',
  CCR.Clipboard.Apple.Helpers in '..\..\..\CCR.Clipboard.Apple.Helpers.pas',
  CCR.Clipboard.Consts in '..\..\..\CCR.Clipboard.Consts.pas',
  CCR.Clipboard.FMX in '..\..\..\CCR.Clipboard.FMX.pas',
  CCR.Clipboard.FMX.Mac in '..\..\..\CCR.Clipboard.FMX.Mac.pas',
  CCR.Clipboard.FMX.iOS in '..\..\..\CCR.Clipboard.FMX.iOS.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmFormatSets, frmFormatSets);
  Application.Run;
end.
