object FormNovoLote: TFormNovoLote
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Novo Lote de Aves'
  ClientHeight = 220
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  object pnlForm: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 220
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lblDesc: TLabel
      Left = 16
      Top = 20
      Width = 62
      Height = 13
      Caption = 'Descri'#231#227'o:'
    end
    object lblData: TLabel
      Left = 16
      Top = 60
      Width = 79
      Height = 13
      Caption = 'Data de Entrada:'
    end
    object lblQtd: TLabel
      Left = 16
      Top = 100
      Width = 107
      Height = 13
      Caption = 'Quantidade Inicial:'
    end
    object edtDesc: TEdit
      Left = 130
      Top = 16
      Width = 250
      Height = 21
      TabOrder = 0
    end
    object dtpData: TDateTimePicker
      Left = 130
      Top = 56
      Width = 150
      Height = 21
      Date = 45725.000000000000000000
      Time = 45725.000000000000000000
      TabOrder = 1
    end
    object edtQtd: TEdit
      Left = 130
      Top = 96
      Width = 100
      Height = 21
      TabOrder = 2
    end
    object btnSalvar: TButton
      Left = 210
      Top = 175
      Width = 80
      Height = 28
      Caption = 'Salvar'
      Default = True
      TabOrder = 3
      OnClick = btnSalvarClick
    end
    object btnCancelar: TButton
      Left = 300
      Top = 175
      Width = 80
      Height = 28
      Cancel = True
      Caption = 'Cancelar'
      TabOrder = 4
      OnClick = btnCancelarClick
    end
  end
end
