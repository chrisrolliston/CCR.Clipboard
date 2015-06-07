object fraInfo: TfraInfo
  Left = 0
  Top = 0
  Width = 577
  Height = 352
  TabOrder = 0
  DesignSize = (
    577
    352)
  object Label1: TLabel
    Left = 7
    Top = 10
    Width = 167
    Height = 13
    Caption = 'Platform supports custom formats?'
  end
  object edtSupportsCustomFormats: TLabel
    Left = 264
    Top = 7
    Width = 38
    Height = 23
    Alignment = taCenter
    AutoSize = False
    Caption = 'Yes'
    Transparent = False
    Layout = tlCenter
  end
  object Label2: TLabel
    Left = 7
    Top = 39
    Width = 187
    Height = 13
    Caption = 'Platform supports multiple format sets?'
  end
  object edtSupportsFormatSets: TLabel
    Left = 264
    Top = 36
    Width = 38
    Height = 23
    Alignment = taCenter
    AutoSize = False
    Caption = 'Yes'
    Transparent = False
    Layout = tlCenter
  end
  object Label3: TLabel
    Left = 7
    Top = 68
    Width = 145
    Height = 13
    Caption = 'Platform supports virtual files?'
  end
  object edtSupportsVirtualFiles: TLabel
    Left = 264
    Top = 65
    Width = 38
    Height = 23
    Alignment = taCenter
    AutoSize = False
    Caption = 'Yes'
    Transparent = False
    Layout = tlCenter
  end
  object Bevel1: TBevel
    Left = 3
    Top = 98
    Width = 299
    Height = 9
    Shape = bsTopLine
  end
  object Label4: TLabel
    Left = 7
    Top = 113
    Width = 116
    Height = 15
    Caption = 'Formats on clipboard'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 314
    Top = 113
    Width = 138
    Height = 15
    Caption = 'Data for selected format'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnUpdateFormats: TButton
    Left = 227
    Top = 109
    Width = 75
    Height = 25
    Caption = 'Update'
    TabOrder = 0
    OnClick = btnUpdateFormatsClick
  end
  object panPreview: TPanel
    Left = 312
    Top = 140
    Width = 258
    Height = 206
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelKind = bkFlat
    BevelOuter = bvNone
    Caption = 'Preview'
    TabOrder = 1
    object imgPreview: TImage
      Left = 0
      Top = 0
      Width = 254
      Height = 202
      Align = alClient
      Center = True
      Proportional = True
      ExplicitLeft = 80
      ExplicitTop = 48
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
    object rchPreview: TRichEdit
      Left = 0
      Top = 0
      Width = 254
      Height = 202
      Align = alClient
      BorderStyle = bsNone
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      Lines.Strings = (
        'rdePreview')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      Visible = False
      WordWrap = False
    end
  end
  object lsvFormats: TListView
    Left = 7
    Top = 140
    Width = 295
    Height = 206
    Anchors = [akLeft, akTop, akBottom]
    Columns = <
      item
        Caption = 'ID'
      end
      item
        Caption = 'Name'
        Width = -2
        WidthType = (
          -2)
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    OnSelectItem = lsvFormatsSelectItem
  end
end
