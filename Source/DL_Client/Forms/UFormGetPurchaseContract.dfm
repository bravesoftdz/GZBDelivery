inherited fFormGetPurchaseContract: TfFormGetPurchaseContract
  Left = 401
  Top = 134
  Width = 713
  Height = 384
  BorderStyle = bsSizeable
  Constraints.MinHeight = 300
  Constraints.MinWidth = 445
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 697
    Height = 346
    inherited BtnOK: TButton
      Left = 551
      Top = 313
      Caption = #30830#23450
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 621
      Top = 313
      TabOrder = 5
    end
    object EditProvider: TcxButtonEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object ListQuery: TcxListView [3]
      Left = 23
      Top = 107
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #21512#21516#32534#21495
          Width = 70
        end
        item
          Caption = #21407#26448#26009
          Width = 100
        end
        item
          AutoSize = True
          Caption = #20379#24212#21830
          WidthType = (
            -87)
        end
        item
          Caption = #21512#21516#21333#20215
          Width = 90
        end
        item
          Caption = #21512#21516#21097#20313
          Width = 90
        end
        item
          Caption = #22791#27880
          Width = 150
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 3
      ViewStyle = vsReport
      OnDblClick = ListQueryDblClick
      OnKeyPress = ListQueryKeyPress
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 86
      Caption = #26597#35810#32467#26524':'
      ParentFont = False
      Transparent = True
    end
    object EditMate: TcxButtonEdit [5]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCIDPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #26597#35810#26465#20214
        object dxLayout1Item5: TdxLayoutItem
          Caption = #20379' '#24212' '#21830':'
          Control = EditProvider
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21407' '#26448' '#26009':'
          Control = EditMate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Visible = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = ListQuery
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
