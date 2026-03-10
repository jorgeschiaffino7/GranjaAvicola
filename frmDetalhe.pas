unit frmDetalhe;

{
  Tela de Detalhe do Lote:
  - Aba 1: Pesagens
  - Aba 2: Mortalidades
  Usa PKG_GRANJA via FDAL para inserções.
}

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls,
  Data.DB,
  FireDAC.Comp.Client,
  DAL, Models, LoteHealthIndicator;

type
  TFormDetalhe = class(TForm)
    pnlTopo:       TPanel;
    lblLote:       TLabel;
    pcDetalhe:     TPageControl;
    tabPesagem:    TTabSheet;
    tabMortalidade:TTabSheet;

    // --- Pesagem ---
    pnlFormPes:    TPanel;
    lblDataPes:    TLabel;
    dtpDataPes:    TDateTimePicker;
    lblPeso:       TLabel;
    edtPeso:       TEdit;
    lblQtdPes:     TLabel;
    edtQtdPes:     TEdit;
    btnSalvarPes:  TButton;
    qPesagens:     TFDQuery;
    dsPesagens:    TDataSource;
    gridPesagens:  TDBGrid;

    // --- Mortalidade ---
    pnlFormMort:   TPanel;
    lblDataMort:   TLabel;
    dtpDataMort:   TDateTimePicker;
    lblQtdMort:    TLabel;
    edtQtdMort:    TEdit;
    lblObs:        TLabel;
    memObs:        TMemo;
    btnSalvarMort: TButton;
    qMort:         TFDQuery;
    dsMort:        TDataSource;
    gridMort:      TDBGrid;

    pnlIndicador:  TPanel;

    procedure btnSalvarPesClick(Sender: TObject);
    procedure btnSalvarMortClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pcDetalheChange(Sender: TObject);
  private
    FDAL:          TGranjaDAL;
    FIdLote:       Integer;
    FQtdInicial:   Integer;
    FDescricao:    string;
    FIndicador:    TLoteHealthIndicator;
    FConn:         TFDConnection;

    procedure CarregarPesagens;
    procedure CarregarMortalidades;
    procedure AtualizarIndicador(const APerc: Double);
  public
    procedure Init(AConn: TFDConnection; ADAL: TGranjaDAL;
                   AIdLote, AQtdInicial: Integer; const ADescricao: string);
  end;

implementation

{$R *.dfm}

procedure TFormDetalhe.FormCreate(Sender: TObject);
begin
  FIndicador := TLoteHealthIndicator.Create(pnlIndicador);
  FIndicador.Parent := pnlIndicador;
  FIndicador.Left   := 4;
  FIndicador.Top    := 4;
end;

procedure TFormDetalhe.Init(AConn: TFDConnection; ADAL: TGranjaDAL;
                             AIdLote, AQtdInicial: Integer;
                             const ADescricao: string);
var
  vMortasTotal: Integer;
  vPerc:        Double;
begin
  FConn       := AConn;
  FDAL        := ADAL;
  FIdLote     := AIdLote;
  FQtdInicial := AQtdInicial;
  FDescricao  := ADescricao;

  lblLote.Caption := 'Lote: ' + ADescricao +
                     ' | Qtd. Inicial: ' + IntToStr(AQtdInicial);

  // Configura data sources
  dsPesagens.DataSet := qPesagens;
  gridPesagens.DataSource := dsPesagens;
  dsMort.DataSet := qMort;
  gridMort.DataSource := dsMort;

  // Indicador inicial
  vMortasTotal := FDAL.TotalMortasPorLote(FIdLote);
  if FQtdInicial > 0 then
    vPerc := (vMortasTotal / FQtdInicial) * 100
  else
    vPerc := 0;
  AtualizarIndicador(vPerc);

  CarregarPesagens;
  CarregarMortalidades;
end;

procedure TFormDetalhe.CarregarPesagens;
begin
  qPesagens.Close;
  FDAL.ListarPesagens(FIdLote, qPesagens);
end;

procedure TFormDetalhe.CarregarMortalidades;
begin
  qMort.Close;
  FDAL.ListarMortalidades(FIdLote, qMort);
end;

procedure TFormDetalhe.AtualizarIndicador(const APerc: Double);
begin
  FIndicador.Mortalidade := APerc;
end;

procedure TFormDetalhe.pcDetalheChange(Sender: TObject);
begin
  // Recarrega grid ao trocar aba
  if pcDetalhe.ActivePage = tabPesagem then
    CarregarPesagens
  else
    CarregarMortalidades;
end;

// -------------------------------------------------------
// Salvar Pesagem
// -------------------------------------------------------
procedure TFormDetalhe.btnSalvarPesClick(Sender: TObject);
var
  vPes:      TPesagem;
  vIdGerado: Integer;
  vErro:     string;
  vMensagem: string;
begin
  vPes := TPesagem.Create;
  try
    vPes.IdLote           := FIdLote;
    vPes.Data             := dtpDataPes.Date;
    vPes.PesoMedio        := StrToFloatDef(edtPeso.Text, 0);
    vPes.QuantidadePesada := StrToIntDef(edtQtdPes.Text, 0);

    // Validação local (model)
    if not vPes.Validar(FQtdInicial, vMensagem) then
    begin
      ShowMessage(vMensagem);
      Exit;
    end;

    // Chama procedure Oracle
    FDAL.InserirPesagem(vPes, vIdGerado, vErro);
    if vErro <> '' then
    begin
      ShowMessage('Erro: ' + vErro);
      Exit;
    end;

    ShowMessage('Pesagem registrada com sucesso! ID: ' + IntToStr(vIdGerado));
    edtPeso.Clear;
    edtQtdPes.Clear;
    CarregarPesagens;
  finally
    vPes.Free;
  end;
end;

// -------------------------------------------------------
// Salvar Mortalidade
// -------------------------------------------------------
procedure TFormDetalhe.btnSalvarMortClick(Sender: TObject);
var
  vMort:          TMortalidade;
  vIdGerado:      Integer;
  vMortAcum:      Double;
  vErro:          string;
  vMensagem:      string;
  vJaMortas:      Integer;
begin
  vJaMortas := FDAL.TotalMortasPorLote(FIdLote);

  vMort := TMortalidade.Create;
  try
    vMort.IdLote         := FIdLote;
    vMort.Data           := dtpDataMort.Date;
    vMort.QuantidadeMorta := StrToIntDef(edtQtdMort.Text, 0);
    vMort.Observacao     := memObs.Text;

    // Validação local (model)
    if not vMort.Validar(FQtdInicial, vJaMortas, vMensagem) then
    begin
      ShowMessage(vMensagem);
      Exit;
    end;

    // Chama procedure Oracle (retorna % acumulada)
    FDAL.InserirMortalidade(vMort, vIdGerado, vMortAcum, vErro);
    if vErro <> '' then
    begin
      ShowMessage('Erro: ' + vErro);
      Exit;
    end;

    // Atualiza indicador de saúde com valor retornado pela procedure
    AtualizarIndicador(vMortAcum);

    ShowMessage(Format('Mortalidade registrada! Mortalidade acumulada: %.2f%%', [vMortAcum]));
    edtQtdMort.Clear;
    memObs.Clear;
    CarregarMortalidades;
  finally
    vMort.Free;
  end;
end;

end.
