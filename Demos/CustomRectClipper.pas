unit CustomRectClipper;
{
  Implements a custom clipper for TRect and TRectF. The LoadFromClipboard methods
  are implemented so that the other type is used as a fallback.
}
interface

uses
  System.Types, System.SysUtils, CCR.Clipboard;

type
  TRectClipper = class(TInterfacedObject, ICustomClipper,
    IRecordClipper<TRect>, IRecordClipper<TRectF>)
  strict private class var
    FInst: TRectClipper;
    FRectFormat, FRectFFormat: TClipboardFormat;
    class constructor InitializeClass;
    procedure DoSaveToClipboard<T: record>(const Format: TClipboardFormat;
      const Clipboard: TClipboard; PreferDelayed: Boolean; const Getter: TFunc<T>);
  strict protected
    { ICustomClipper }
    function CanLoadFromClipboard(const Clipboard: TClipboard): Boolean;
    { IRecordClipper<TRect> }
    procedure LoadFromClipboard(const Clipboard: TClipboard;
      const Callback: TGetInstancesCallback<TRect>); overload;
    procedure SaveToClipboard(const Clipboard: TClipboard; PreferDelayed: Boolean;
      const Getter: TFunc<TRect>); overload;
    { IRecordClipper<TRectF> }
    procedure LoadFromClipboard(const Clipboard: TClipboard;
      const Callback: TGetInstancesCallback<TRectF>); overload;
    procedure SaveToClipboard(const Clipboard: TClipboard; PreferDelayed: Boolean;
      const Getter: TFunc<TRectF>); overload;
  public
    class procedure Register;
    class property RectFormat: TClipboardFormat read FRectFormat;
    class property RectFFormat: TClipboardFormat read FRectFFormat;
  end;

implementation

class constructor TRectClipper.InitializeClass;
begin
  FRectFormat := TClipboard.RegisterFormat('System.Types.TRect');
  FRectFFormat := TClipboard.RegisterFormat('System.Types.TRectF');
end;

class procedure TRectClipper.Register;
begin
  Assert(FInst = nil);
  FInst := TRectClipper.Create;
  TClipboard.RegisterClipper<TRect>(FInst);
  TClipboard.RegisterClipper<TRectF>(FInst);
end;

function TRectClipper.CanLoadFromClipboard(const Clipboard: TClipboard): Boolean;
begin
  Result := Clipboard.HasFormat([FRectFormat, FRectFFormat]);
end;

procedure TRectClipper.LoadFromClipboard(const Clipboard: TClipboard;
  const Callback: TGetInstancesCallback<TRect>);
var
  AtLeastOne: Boolean;
begin
  AtLeastOne := False;
  Clipboard.GetBytes(FRectFormat,
    procedure (const Bytes: TBytes; var LookForMore: Boolean)
    var
      R: TRect;
    begin
      if Length(Bytes) < SizeOf(TRect) then Exit;
      AtLeastOne := True;
      Move(Bytes[0], R, SizeOf(TRect));
      Callback(R, LookForMore);
    end);
  //if weren't any TRect instances, try for TRectF ones
  if AtLeastOne then Exit;
  LoadFromClipboard(Clipboard,
    procedure (const RectF: TRectF; var LookForMore: Boolean)
    begin
      Callback(RectF.Round, LookForMore);
    end);
end;

procedure TRectClipper.LoadFromClipboard(const Clipboard: TClipboard;
  const Callback: TGetInstancesCallback<TRectF>);
var
  AtLeastOne: Boolean;
begin
  AtLeastOne := False;
  Clipboard.GetBytes(FRectFFormat,
    procedure (const Bytes: TBytes; var LookForMore: Boolean)
    var
      R: TRectF;
    begin
      if Length(Bytes) < SizeOf(TRectF) then Exit;
      AtLeastOne := True;
      Move(Bytes[0], R, SizeOf(TRectF));
      Callback(R, LookForMore);
    end);
  //if weren't any TRectF instances, try for TRect ones
  if AtLeastOne then Exit;
  LoadFromClipboard(Clipboard,
    procedure (const Rect: TRect; var LookForMore: Boolean)
    begin
      Callback(TRectF.Create(Rect), LookForMore);
    end);
end;

procedure TRectClipper.DoSaveToClipboard<T>(const Format: TClipboardFormat;
  const Clipboard: TClipboard; PreferDelayed: Boolean; const Getter: TFunc<T>);
var
  GetBytes: TFunc<TBytes>;
begin
  GetBytes :=
    function : TBytes
    var
      R: T;
    begin
      R := Getter;
      SetLength(Result, SizeOf(R));
      Move(R, Result[0], SizeOf(R));
    end;
  if PreferDelayed then
    Clipboard.AssignDelayed(Format, GetBytes)
  else
    Clipboard.Assign(Format, GetBytes());
end;

procedure TRectClipper.SaveToClipboard(const Clipboard: TClipboard;
  PreferDelayed: Boolean; const Getter: TFunc<TRect>);
begin
  DoSaveToClipboard<TRect>(FRectFormat, Clipboard, PreferDelayed, Getter);
end;

procedure TRectClipper.SaveToClipboard(const Clipboard: TClipboard;
  PreferDelayed: Boolean; const Getter: TFunc<TRectF>);
begin
  DoSaveToClipboard<TRectF>(FRectFFormat, Clipboard, PreferDelayed, Getter);
end;

end.
