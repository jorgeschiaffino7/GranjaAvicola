object FormDetalhe: TFormDetalhe
  Left = 0
  Top = 0
  Caption = 'Detalhe do Lote'
  ClientHeight = 600
  ClientWidth = 850
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 850
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Color = 4144959
    TabOrder = 0
    object lblLote: TLabel
      Left = 10
      Top = 12
      Width = 200
      Height = 13
      Caption = 'Lote: '
      Font.Color = clWhite
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlIndicador: TPanel
    Left = 0
    Top = 40
    Width = 850
    Height = 70
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
  end
  object pcDetalhe: TPageControl
    Left = 0
    Top = 110
    Width = 850
    Height = 490
    Align = alClient
    ActivePage = tabPesagem
    TabOrder = 2
    OnChange = pcDetalheChange
    object tabPesagem: TTabSheet
      Caption = 'Pesagens'
      object pnlFormPes: TPanel
        Left = 0
        Top = 0
        Width = 842
        Height = 80
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblDataPes: TLabel
          Left = 10
          Top = 10
          Width = 30
          Height = 13
          Caption = 'Data:'
        end
        object lblPeso: TLabel
          Left = 200
          Top = 10
          Width = 63
          Height = 13
          Caption = 'Peso M'#233'dio:'
        end
        object lblQtdPes: TLabel
          Left = 400
          Top = 10
          Width = 53
          Height = 13
          Caption = 'Quantidade:'
        end
        object dtpDataPes: TDateTimePicker
          Left = 50
          Top = 6
          Width = 120
          Height = 21
          Date = 45725.000000000000000000
          Time = 45725.000000000000000000
          TabOrder = 0
        end
        object edtPeso: TEdit
          Left = 270
          Top = 6
          Width = 100
          Height = 21
          TabOrder = 1
        end
        object edtQtdPes: TEdit
          Left = 460
          Top = 6
          Width = 100
          Height = 21
          TabOrder = 2
        end
        object btnSalvarPes: TButton
          Left = 580
          Top = 4
          Width = 100
          Height = 28
          Caption = 'Salvar Pesagem'
          TabOrder = 3
          OnClick = btnSalvarPesClick
        end
      end
      object gridPesagens: TDBGrid
        Left = 0
        Top = 80
        Width = 842
        Height = 382
        Align = alClient
        DataSource = dsPesagens
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object dsPesagens: TDataSource
        Left = 700
        Top = 30
      end
      object qPesagens: TFDQuery
        Left = 760
        Top = 30
      end
    end
    object tabMortalidade: TTabSheet
      Caption = 'Mortalidades'
      object pnlFormMort: TPanel
        Left = 0
        Top = 0
        Width = 842
        Height = 110
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblDataMort: TLabel
          Left = 10
          Top = 10
          Width = 30
          Height = 13
          Caption = 'Data:'
        end
        object lblQtdMort: TLabel
          Left = 200
          Top = 10
          Width = 53
          Height = 13
          Caption = 'Quantidade:'
        end
        object lblObs: TLabel
          Left = 10
          Top = 50
          Width = 59
          Height = 13
          Caption = 'Observa'#231#227'o:'
        end
        object dtpDataMort: TDateTimePicker
          Left = 50
          Top = 6
          Width = 120
          Height = 21
          Date = 45725.000000000000000000
          Time = 45725.000000000000000000
          TabOrder = 0
        end
        object edtQtdMort: TEdit
          Left = 270
          Top = 6
          Width = 100
          Height = 21
          TabOrder = 1
        end
        object memObs: TMemo
          Left = 80
          Top = 46
          Width = 500
          Height = 50
          TabOrder = 2
        end
        object btnSalvarMort: TButton
          Left = 600
          Top = 46
          Width = 110
          Height = 28
          Caption = 'Salvar Mortalidade'
          TabOrder = 3
          OnClick = btnSalvarMortClick
        end
      end
      object gridMort: TDBGrid
        Left = 0
        Top = 110
        Width = 842
        Height = 352
        Align = alClient
        DataSource = dsMort
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object dsMort: TDataSource
        Left = 700
        Top = 60
      end
      object qMort: TFDQuery
        Left = 760
        Top = 60
      end
    end
  end
end
