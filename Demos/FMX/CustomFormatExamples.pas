unit CustomFormatExamples;
{
  Demonstrates the following:
  1.  Custom format, no clipper - Clipboard.GetBytes needs to be used explicitly
  2.  One-line registration of a clipper for an existing TPersistent descendant; if it
      weren't for the clipboard viewer functionality implemented by the Info tab we
      wouldn't even need to store the returned TClipboardFormat. Using a default
      clipper is not necessarily recommended, but is available.
  3.  Slightly more involved example of a custom object that implements IStreamPersist,
      along with a clipper for it that writes more than one format to the clipboard.
      Objects don't have to implement IStreamPersist to be clippable, but if possible
      they might as well given assignments to and from the clipboard are essentially
      streaming operations for objects.
}
interface

uses
  System.SysUtils, System.Classes, FMX.Graphics, CCR.Clipboard;

type
  TMyObject = class(TInterfacedPersistent, IStreamPersist)
  const
    Signature: array[0..2] of WideChar = ('T', 'M', 'O');
  strict private
    FDateTime: TDateTime;
    FText: string;
  public
    constructor Create;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property DateTime: TDateTime read FDateTime write FDateTime;
    property Text: string read FText write FText;
  end;

var
  cfMyCustomFormat, cfFMXGradient, cfMyObject: TClipboardFormat;

implementation

{ TMyObject itself }

constructor TMyObject.Create;
begin
  inherited Create;
  FDateTime := Now;
end;

procedure TMyObject.LoadFromStream(Stream: TStream);
var
  Len: Int32;
  S: UnicodeString;
  Sig: array[1..SizeOf(Signature)] of Byte;
begin
  Stream.ReadBuffer(Sig, SizeOf(Sig));
  if not CompareMem(@Sig, @Signature, SizeOf(Sig)) then
    raise EStreamError.Create('Invalid TMyObject data!');
  //TDateTime can be read directly
  Stream.ReadBuffer(FDateTime, SizeOf(FDateTime));
  //string needs a length marker
  Stream.ReadBufferData(Len);
  SetLength(S, Len);
  Stream.ReadBuffer(PWideChar(S)^, Len * SizeOf(WideChar));
  FText := S;
end;

procedure TMyObject.SaveToStream(Stream: TStream);
var
  Len: Int32;
begin
  Stream.WriteBuffer(Signature, SizeOf(Signature));
  //TDateTime can be written directly
  Stream.WriteBuffer(FDateTime, SizeOf(FDateTime));
  //string needs a length marker
  Len := Length(FText);
  Stream.WriteBuffer(Len, SizeOf(Len));
  Stream.WriteBuffer(PWideChar(FText)^, Len * SizeOf(WideChar));
end;

{ Clipper callbacks for TMyObject; reads and writes cfMyObject for fidelity and
  cfUnicodeText for compatibility. }

procedure LoadMyObjectFromClipboard(const Clipboard: TClipboard;
  const Format: TClipboardFormat; Obj: TMyObject);
var
  Stream: TBytesStream;
begin
  if Format = cfUnicodeText then
    Obj.Text := Clipboard.AsText
  else if Format = cfMyObject then
  begin
    Stream := TBytesStream.Create(Clipboard.GetBytes(cfMyObject));
    try
      Obj.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
  end;
end;

procedure SaveMyObjectToClipboard(const Clipboard: TClipboard;
  const Format: TClipboardFormat; PreferDelayed: Boolean;
  const ObjGetter: TFunc<TMyObject>);
begin
  if Format = cfUnicodeText then
    if PreferDelayed then
      Clipboard.AssignTextDelayed(
        function : string
        begin
          Result := ObjGetter.Text;
        end)
    else
      Clipboard.AssignText(ObjGetter.Text)
  else if Format = cfMyObject then
    if PreferDelayed then
      Clipboard.AssignDelayed(cfMyObject,
        procedure (Stream: TStream)
        begin
          ObjGetter.SaveToStream(Stream);
        end)
    else
      Clipboard.Assign(cfMyObject, ObjGetter as IStreamPersist);
end;

procedure RegisterFormatsAndClippers;
begin
  { Format only; OS X/iOS UTI style used for name }
  cfMyCustomFormat := TClipboard.RegisterFormat('com.ccr.custom-format');
  { Register default clipper for a TPersistent descendant; normally you wouldn't
    need to keep a reference to the format }
  cfFMXGradient := TClipboard.RegisterSimpleClipper<TGradient>.Format;
  { Custom format and a delegated clipper for a custom object }
  cfMyObject := TClipboard.RegisterFormat('com.ccr.myobject', 'TMyObject Example');
  TClipboard.RegisterClipper<TMyObject>([cfMyObject, cfUnicodeText], [cfMyObject, cfUnicodeText],
    LoadMyObjectFromClipboard, SaveMyObjectToClipboard);
end;

initialization
  RegisterFormatsAndClippers;
end.
