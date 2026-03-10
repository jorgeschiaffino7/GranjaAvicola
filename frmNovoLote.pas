unit frmNovoLote;

{
  Tela de cadastro de novo Lote de Aves.
}

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  FireDAC.Comp.Client;

type
  TFormNovoLote = class(TForm)
    pnlForm:     TPanel;
    lblDesc:     TLabel;
    edtDesc:     TEdit;
    lblData:     TLabel;
    dtpData:     TDateTimePicker;
    lblQtd:      TLabel;
    edtQtd:      TEdit;
    btnSalvar:   TButton;
    btnCancelar: TButton;

    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    FConn: TFDConnection;
  public
    procedure Init(AConn: TFDConnection);
  end;

implementation

{$R *.dfm}

procedure TFormNovoLote.Init(AConn: TFDConnection);
begin
  FConn := AConn;
  dtpData.Date := Now;
end;

procedure TFormNovoLote.btnSalvarClick(Sender: TObject);
var
  Q: TFDQuery;
begin
  if Trim(edtDesc.Text) = '' then
  begin
    ShowMessage('Informe a descrição do lote.');
    Exit;
  end;

  if StrToIntDef(edtQtd.Text, 0) <= 0 then
  begin
    ShowMessage('Quantidade inicial deve ser maior que zero.');
    Exit;
  end;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text :=
      'INSERT INTO TAB_LOTE_AVES (ID_LOTE, DESCRICAO, DATA_ENTRADA, QUANTIDADE_INICIAL) ' +
      'VALUES (SEQ_LOTE_AVES.NEXTVAL, :P_DESC, :P_DATA, :P_QTD)';
    Q.ParamByName('P_DESC').AsString  := Trim(edtDesc.Text);
    Q.ParamByName('P_DATA').AsDate    := dtpData.Date;
    Q.ParamByName('P_QTD').AsInteger  := StrToInt(edtQtd.Text);
    Q.ExecSQL;
    FConn.Commit;
    ShowMessage('Lote cadastrado com sucesso!');
    ModalResult := mrOk;
  except
    on E: Exception do
    begin
      FConn.Rollback;
      ShowMessage('Erro ao cadastrar lote: ' + E.Message);
    end;
  end;
  Q.Free;
end;

procedure TFormNovoLote.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
