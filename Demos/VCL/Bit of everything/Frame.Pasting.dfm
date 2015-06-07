object fraPasting: TfraPasting
  Left = 0
  Top = 0
  Width = 577
  Height = 352
  TabOrder = 0
  object panText: TPanel
    AlignWithMargins = True
    Left = 6
    Top = 6
    Width = 565
    Height = 99
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 0
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    TabOrder = 0
    VerticalAlignment = taAlignTop
    DesignSize = (
      565
      99)
    object Label11: TLabel
      AlignWithMargins = True
      Left = 0
      Top = 5
      Width = 565
      Height = 15
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Margins.Bottom = 8
      Align = alTop
      Caption = 'Text'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 26
    end
    object btnPasteRTF: TButton
      Left = 447
      Top = 0
      Width = 118
      Height = 25
      Action = actPasteRTF
      Anchors = [akTop, akRight]
      TabOrder = 1
    end
    object memPastedText: TRichEdit
      Left = 0
      Top = 28
      Width = 565
      Height = 71
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
    end
    object btnPastePlainText: TButton
      Left = 323
      Top = 0
      Width = 118
      Height = 25
      Action = actPastePlainText
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
  end
  object panFileNames: TPanel
    AlignWithMargins = True
    Left = 6
    Top = 111
    Width = 565
    Height = 83
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 0
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    TabOrder = 1
    VerticalAlignment = taAlignTop
    DesignSize = (
      565
      83)
    object Label13: TLabel
      AlignWithMargins = True
      Left = 0
      Top = 5
      Width = 565
      Height = 15
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Margins.Bottom = 8
      Align = alTop
      Caption = 'File names'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 58
    end
    object btnPasteFileNames: TButton
      Left = 323
      Top = 0
      Width = 118
      Height = 25
      Action = actPasteFileNames
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object memPastedFileNames: TMemo
      Left = 0
      Top = 28
      Width = 565
      Height = 55
      Align = alClient
      ReadOnly = True
      TabOrder = 2
    end
    object btnPasteVirtualFiles: TButton
      Left = 447
      Top = 0
      Width = 118
      Height = 25
      Action = actPasteVirtualFiles
      Anchors = [akTop, akRight]
      TabOrder = 1
    end
  end
  object panURL: TPanel
    AlignWithMargins = True
    Left = 6
    Top = 200
    Width = 565
    Height = 52
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 0
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    TabOrder = 2
    VerticalAlignment = taAlignTop
    DesignSize = (
      565
      52)
    object Label12: TLabel
      AlignWithMargins = True
      Left = 0
      Top = 5
      Width = 565
      Height = 15
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Margins.Bottom = 8
      Align = alTop
      Caption = 'URL'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 23
    end
    object btnPasteURL: TButton
      Left = 447
      Top = 0
      Width = 118
      Height = 25
      Action = actPasteURL
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object memPastedURL: TMemo
      Left = 0
      Top = 28
      Width = 565
      Height = 24
      Align = alClient
      ReadOnly = True
      TabOrder = 1
    end
  end
  object panPictures: TPanel
    AlignWithMargins = True
    Left = 6
    Top = 258
    Width = 565
    Height = 88
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    VerticalAlignment = taAlignTop
    DesignSize = (
      565
      88)
    object Label7: TLabel
      AlignWithMargins = True
      Left = 0
      Top = 5
      Width = 565
      Height = 15
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Margins.Bottom = 8
      Align = alTop
      Caption = 'Pictures'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 45
    end
    object btnPastePictures: TButton
      Left = 447
      Top = 0
      Width = 118
      Height = 25
      Action = actPastePictures
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object pgsGraphics: TPageScroller
      Left = 0
      Top = 28
      Width = 565
      Height = 60
      Align = alClient
      Control = panPastePicturesInfo
      TabOrder = 1
      object panPastePicturesInfo: TPanel
        Left = 0
        Top = 0
        Width = 569
        Height = 60
        BevelOuter = bvNone
        TabOrder = 0
        object Label8: TLabel
          Left = 0
          Top = 0
          Width = 569
          Height = 52
          Align = alTop
          Caption = 
            'While Windows does not support copying more than one instance of' +
            ' any given format, it does support copying more than one file or' +
            ' virtual file. Since our TClipboard class supports pasting direc' +
            'tly from an image file to a suitable TGraphic or TPicture, you w' +
            'ill be able to paste more than one picture at the same time if y' +
            'ou copy multiple image files in Explorer.'
          WordWrap = True
          ExplicitWidth = 563
        end
      end
    end
  end
  object ActionList: TActionList
    Left = 525
    Top = 16
    object actPastePictures: TAction
      Caption = 'Paste Picture(s)'
      OnExecute = actPastePicturesExecute
      OnUpdate = actPastePicturesUpdate
    end
    object actPasteRTF: TAction
      Caption = 'Paste Rich Text'
      OnExecute = actPasteRTFExecute
      OnUpdate = actPasteRTFUpdate
    end
    object actPastePlainText: TAction
      Caption = 'Paste Plain Text'
      OnExecute = actPastePlainTextExecute
      OnUpdate = actPastePlainTextUpdate
    end
    object actPasteURL: TAction
      Caption = 'Paste URL'
      OnExecute = actPasteURLExecute
      OnUpdate = actPasteURLUpdate
    end
    object actPasteFileNames: TAction
      Caption = 'Paste File Name(s)'
      OnExecute = actPasteFileNamesExecute
      OnUpdate = actPasteFileNamesUpdate
    end
    object actPasteComponent: TAction
      Caption = 'Paste Component'
    end
    object actPasteVirtualFiles: TAction
      Caption = 'Paste Virtual File(s)'
      OnExecute = actPasteVirtualFilesExecute
      OnUpdate = actPasteVirtualFilesUpdate
    end
  end
end
