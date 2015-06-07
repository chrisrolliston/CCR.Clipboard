object frmVCLDemo: TfrmVCLDemo
  Left = 0
  Top = 0
  Caption = 'VCL Demo'
  ClientHeight = 401
  ClientWidth = 605
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Padding.Left = 8
  Padding.Top = 8
  Padding.Right = 8
  Padding.Bottom = 8
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 15
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 589
    Height = 385
    ActivePage = tabInfo
    Align = alClient
    TabOrder = 0
    object tabInfo: TTabSheet
      Caption = 'Info'
      inline fraInfo: TfraInfo
        Left = 0
        Top = 0
        Width = 581
        Height = 355
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 581
        ExplicitHeight = 355
        inherited Label1: TLabel
          Width = 187
          Height = 15
          ExplicitWidth = 187
          ExplicitHeight = 15
        end
        inherited Label2: TLabel
          Width = 209
          Height = 15
          ExplicitWidth = 209
          ExplicitHeight = 15
        end
        inherited Label3: TLabel
          Width = 160
          Height = 15
          ExplicitWidth = 160
          ExplicitHeight = 15
        end
      end
    end
    object tabCopying: TTabSheet
      Caption = 'Copying'
      ImageIndex = 1
      inline fraCopying: TfraCopying
        Left = 0
        Top = 0
        Width = 581
        Height = 355
        Align = alClient
        Padding.Left = 6
        Padding.Top = 6
        Padding.Right = 6
        Padding.Bottom = 6
        TabOrder = 0
        ExplicitWidth = 581
        ExplicitHeight = 355
        inherited lblImmediate: TLabel
          Top = 220
          Width = 569
          ExplicitTop = 220
        end
        inherited lblDelayed: TLabel
          Top = 272
          Width = 569
          ExplicitTop = 272
        end
        inherited panSourceData: TPanel
          Width = 569
          Height = 161
          ExplicitWidth = 569
          ExplicitHeight = 161
          inherited Splitter1: TSplitter
            Height = 161
            ExplicitHeight = 161
          end
          inherited panTextToCopy: TPanel
            Height = 161
            ExplicitHeight = 161
            inherited rchSource: TRichEdit
              Height = 134
              ExplicitHeight = 134
            end
          end
          inherited panImageToCopy: TPanel
            Width = 157
            Height = 161
            ExplicitWidth = 157
            ExplicitHeight = 161
          end
        end
        inherited panImmediateButtons: TPanel
          Top = 241
          Width = 569
          ExplicitTop = 241
          ExplicitWidth = 569
        end
        inherited panDelayedButtons: TPanel
          Top = 293
          Width = 569
          ExplicitTop = 293
          ExplicitWidth = 569
        end
        inherited panPromises: TPanel
          Top = 324
          Width = 569
          ExplicitTop = 324
          ExplicitWidth = 569
        end
        inherited panFilesToCopy: TPanel
          Top = 173
          Width = 569
          ExplicitLeft = 6
          ExplicitTop = 173
          ExplicitWidth = 569
          inherited memFilesToCopy: TMemo
            Width = 488
            ExplicitWidth = 488
          end
        end
      end
    end
    object tabPasting: TTabSheet
      Caption = 'Pasting'
      ImageIndex = 2
      inline fraPasting: TfraPasting
        Left = 0
        Top = 0
        Width = 581
        Height = 355
        Align = alClient
        TabOrder = 0
        ExplicitWidth = 581
        ExplicitHeight = 355
        inherited panText: TPanel
          Width = 569
          ExplicitWidth = 569
          inherited Label11: TLabel
            Width = 569
          end
          inherited memPastedText: TRichEdit
            Width = 569
            ExplicitWidth = 569
          end
        end
        inherited panFileNames: TPanel
          Width = 569
          ExplicitWidth = 569
          inherited Label13: TLabel
            Width = 58
          end
        end
        inherited panURL: TPanel
          Width = 569
          ExplicitWidth = 569
          inherited Label12: TLabel
            Width = 23
          end
        end
        inherited panPictures: TPanel
          Width = 569
          Height = 91
          ExplicitWidth = 569
          ExplicitHeight = 91
          inherited Label7: TLabel
            Width = 45
          end
          inherited pgsGraphics: TPageScroller
            inherited panPastePicturesInfo: TPanel
              inherited Label8: TLabel
                Width = 552
                Height = 60
                ExplicitWidth = 552
                ExplicitHeight = 60
              end
            end
          end
        end
      end
    end
    object tabDragAndDrop: TTabSheet
      Caption = 'Drag and Drop'
      ImageIndex = 3
      inline fraDragAndDrop: TfraDragAndDrop
        Left = 0
        Top = 0
        Width = 581
        Height = 355
        Align = alClient
        Padding.Left = 6
        Padding.Top = 6
        Padding.Right = 6
        Padding.Bottom = 6
        TabOrder = 0
        ExplicitWidth = 581
        ExplicitHeight = 355
        inherited Splitter2: TSplitter
          Top = 205
          Width = 569
          ExplicitWidth = 569
        end
        inherited panBottomHalf: TPanel
          Top = 211
          Width = 569
          ExplicitTop = 211
          ExplicitWidth = 569
          inherited grpText: TGroupBox
            inherited panWantPlainText: TPanel
              Top = 50
              ExplicitTop = 50
            end
            inherited RichEdit1: TRichEdit
              Top = 79
              Height = 51
              ExplicitTop = 79
              ExplicitHeight = 51
            end
            inherited Panel1: TPanel
              Top = 23
              ExplicitTop = 23
              inherited cboBehaviour: TComboBox
                Height = 23
                ExplicitHeight = 23
              end
            end
          end
          inherited grpInfo: TGroupBox
            Width = 225
            ExplicitWidth = 225
          end
        end
        inherited panImages: TPanel
          Width = 569
          Height = 199
          ExplicitWidth = 569
          ExplicitHeight = 199
          inherited Splitter3: TSplitter
            Height = 199
            ExplicitHeight = 199
          end
          inherited fraImageToDrag1: TfraImageToDrag
            Height = 199
            ExplicitHeight = 199
            inherited grpImage: TGroupBox
              Height = 199
              ExplicitHeight = 199
              inherited Image: TImage
                Top = 17
                Height = 153
                ExplicitTop = 17
                ExplicitHeight = 153
              end
              inherited Panel1: TPanel
                Top = 170
                ExplicitTop = 170
                inherited cboBehaviour: TComboBox
                  Height = 23
                  ExplicitHeight = 23
                end
              end
            end
          end
          inherited fraImageToDrag2: TfraImageToDrag
            Width = 280
            Height = 199
            ExplicitWidth = 280
            ExplicitHeight = 199
            inherited grpImage: TGroupBox
              Width = 280
              Height = 199
              ExplicitWidth = 280
              ExplicitHeight = 199
              inherited Image: TImage
                Top = 17
                Width = 270
                Height = 153
                ExplicitTop = 17
                ExplicitWidth = 270
                ExplicitHeight = 153
              end
              inherited Panel1: TPanel
                Top = 170
                Width = 270
                ExplicitTop = 170
                ExplicitWidth = 270
                inherited btnReset: TButton
                  Left = 195
                  ExplicitLeft = 195
                end
                inherited cboBehaviour: TComboBox
                  Width = 192
                  Height = 23
                  ExplicitWidth = 192
                  ExplicitHeight = 23
                end
              end
            end
          end
        end
      end
    end
  end
end
