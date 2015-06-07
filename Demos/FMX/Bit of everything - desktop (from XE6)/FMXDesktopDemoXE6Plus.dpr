program FMXDesktopDemoXE6Plus;

uses
  System.StartUpCopy,
  FMX.Forms,
  CCR.Clipboard in '..\..\..\CCR.Clipboard.pas',
  CCR.Clipboard.Consts in '..\..\..\CCR.Clipboard.Consts.pas',
  CCR.Clipboard.Apple in '..\..\..\CCR.Clipboard.Apple.pas',
  CCR.Clipboard.Apple.Helpers in '..\..\..\CCR.Clipboard.Apple.Helpers.pas',
  CCR.Clipboard.Win in '..\..\..\CCR.Clipboard.Win.pas',
  CCR.Clipboard.FMX in '..\..\..\CCR.Clipboard.FMX.pas',
  CCR.Clipboard.FMX.Mac in '..\..\..\CCR.Clipboard.FMX.Mac.pas',
  CCR.Clipboard.FMX.Win in '..\..\..\CCR.Clipboard.FMX.Win.pas',
  AppIntf in 'AppIntf.pas',
  CustomFormatExamples in '..\CustomFormatExamples.pas',
  FormatViewers in '..\FormatViewers.pas',
  DesktopDemoForm in 'DesktopDemoForm.pas' {frmDesktopDemo},
  Frame.Info in 'Frame.Info.pas' {fraInfo: TFrame},
  Frame.Copying in 'Frame.Copying.pas' {fraCopying: TFrame},
  Frame.Pasting in 'Frame.Pasting.pas' {fraPasting: TFrame},
  Frame.DragAndDrop in 'Frame.DragAndDrop.pas' {fraDragAndDrop: TFrame},
  Frame.ImageToDrag in 'Frame.ImageToDrag.pas' {fraImageToDrag: TFrame};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TfrmDesktopDemo, frmDesktopDemo);
  Application.Run;
end.
