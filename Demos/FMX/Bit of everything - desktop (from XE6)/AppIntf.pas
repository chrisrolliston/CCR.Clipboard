unit AppIntf;

interface

type
  IAppMainForm = interface
  ['{0F670F7F-AF27-4047-B2CA-C8A39844B0B4}']
    procedure NotifyFrames(Msg: Word);
  end;

  ICanCloseResponder = interface
  ['{A535FF6A-5673-4700-A951-2B8F8D3E8A11}']
    function CanClose: Boolean;
  end;

const
  CM_BASE                     = $B000;
  CM_CANCELCLIPBOARDSELECTION = CM_BASE + 1;

implementation

end.
