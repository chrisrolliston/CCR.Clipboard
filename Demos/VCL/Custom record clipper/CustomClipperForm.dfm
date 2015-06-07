object frmCustomClipper: TfrmCustomClipper
  Left = 0
  Top = 0
  ActiveControl = btnCopy
  BorderIcons = [biSystemMenu]
  Caption = 'Custom TRect Clipper Demo'
  ClientHeight = 201
  ClientWidth = 434
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Padding.Left = 6
  Padding.Top = 6
  Padding.Right = 6
  Padding.Bottom = 6
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 6
    Top = 6
    Width = 422
    Height = 147
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblLeft: TLabel
      Left = 0
      Top = 0
      Width = 20
      Height = 147
      Align = alLeft
      Caption = 'Left'
      Layout = tlCenter
      ExplicitHeight = 15
    end
    object lblRight: TLabel
      Left = 394
      Top = 0
      Width = 28
      Height = 147
      Align = alRight
      Caption = 'Right'
      Layout = tlCenter
      ExplicitHeight = 15
    end
    object Panel2: TPanel
      Left = 20
      Top = 0
      Width = 374
      Height = 147
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object lblTop: TLabel
        Left = 0
        Top = 0
        Width = 374
        Height = 15
        Align = alTop
        Alignment = taCenter
        Caption = 'Top'
        ExplicitWidth = 21
      end
      object lblBottom: TLabel
        Left = 0
        Top = 132
        Width = 374
        Height = 15
        Align = alBottom
        Alignment = taCenter
        Caption = 'Bottom'
        ExplicitWidth = 40
      end
      object GridPanel1: TGridPanel
        AlignWithMargins = True
        Left = 3
        Top = 18
        Width = 368
        Height = 111
        Align = alClient
        BevelOuter = bvNone
        ColumnCollection = <
          item
            Value = 33.544300448148200000
          end
          item
            Value = 33.350035634799030000
          end
          item
            Value = 33.105663917052770000
          end>
        ControlCollection = <
          item
            Column = 0
            Control = fraSpinnerLeft
            Row = 1
          end
          item
            Column = 1
            Control = fraSpinnerTop
            Row = 0
          end
          item
            Column = 2
            Control = fraSpinnerRight
            Row = 1
          end
          item
            Column = 1
            Control = fraSpinnerBottom
            Row = 2
          end>
        RowCollection = <
          item
            Value = 33.502379102297840000
          end
          item
            Value = 33.471859731912110000
          end
          item
            Value = 33.025761165790040000
          end>
        TabOrder = 0
        DesignSize = (
          368
          111)
        inline fraSpinnerLeft: TfraSpinner
          Left = 6
          Top = 44
          Width = 110
          Height = 23
          Anchors = []
          TabOrder = 0
          ExplicitLeft = 6
          ExplicitTop = 44
          inherited btnSmaller: TButton
            ExplicitHeight = 23
          end
          inherited btnBigger: TButton
            ExplicitLeft = 85
            ExplicitHeight = 23
          end
          inherited edtInput: TEdit
            Text = '11'
            ExplicitWidth = 60
            ExplicitHeight = 23
          end
        end
        inline fraSpinnerTop: TfraSpinner
          Left = 129
          Top = 7
          Width = 110
          Height = 23
          Anchors = []
          TabOrder = 1
          ExplicitLeft = 129
          ExplicitTop = 7
          inherited btnSmaller: TButton
            ExplicitHeight = 23
          end
          inherited btnBigger: TButton
            ExplicitLeft = 85
            ExplicitHeight = 23
          end
          inherited edtInput: TEdit
            Text = '22'
            ExplicitWidth = 60
            ExplicitHeight = 23
          end
        end
        inline fraSpinnerRight: TfraSpinner
          Left = 251
          Top = 44
          Width = 110
          Height = 23
          Anchors = []
          TabOrder = 2
          ExplicitLeft = 251
          ExplicitTop = 44
          inherited btnSmaller: TButton
            ExplicitHeight = 23
          end
          inherited btnBigger: TButton
            ExplicitLeft = 85
            ExplicitHeight = 23
          end
          inherited edtInput: TEdit
            Text = '33'
            ExplicitWidth = 60
            ExplicitHeight = 23
          end
        end
        inline fraSpinnerBottom: TfraSpinner
          Left = 129
          Top = 81
          Width = 110
          Height = 23
          Anchors = []
          TabOrder = 3
          ExplicitLeft = 129
          ExplicitTop = 81
          inherited btnSmaller: TButton
            ExplicitHeight = 23
          end
          inherited btnBigger: TButton
            ExplicitLeft = 85
            ExplicitHeight = 23
          end
          inherited edtInput: TEdit
            Text = '44'
            ExplicitWidth = 60
            ExplicitHeight = 23
          end
        end
      end
    end
  end
  object btnCopy: TButton
    Left = 35
    Top = 168
    Width = 110
    Height = 25
    Caption = 'Copy'
    TabOrder = 1
    OnClick = btnCopyClick
  end
  object btnRandomize: TButton
    Left = 158
    Top = 168
    Width = 110
    Height = 25
    Caption = 'Randomise'
    TabOrder = 2
    OnClick = btnRandomizeClick
  end
  object btnPaste: TButton
    Left = 280
    Top = 168
    Width = 110
    Height = 25
    Caption = 'Paste'
    TabOrder = 3
    OnClick = btnPasteClick
  end
end
