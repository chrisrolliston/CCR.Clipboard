object fraSpinner: TfraSpinner
  Left = 0
  Top = 0
  Width = 110
  Height = 23
  TabOrder = 0
  object btnSmaller: TButton
    Left = 0
    Top = 0
    Width = 25
    Height = 23
    Align = alLeft
    Caption = '3'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Marlett'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = btnSmallerClick
    ExplicitHeight = 25
  end
  object btnBigger: TButton
    Left = 85
    Top = 0
    Width = 25
    Height = 23
    Align = alRight
    Caption = '4'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Marlett'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnBiggerClick
    ExplicitLeft = 0
    ExplicitHeight = 128
  end
  object edtInput: TEdit
    Left = 25
    Top = 0
    Width = 60
    Height = 23
    Align = alClient
    Alignment = taCenter
    NumbersOnly = True
    TabOrder = 2
    Text = '0'
    ExplicitWidth = 78
    ExplicitHeight = 21
  end
end