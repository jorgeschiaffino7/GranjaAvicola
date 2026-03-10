unit DAL;

{
  Camada de Acesso a Dados (DAL)
  Toda comunicação com o Oracle é feita via PKG_GRANJA (stored procedures).
  Utiliza FireDAC (TFDConnection, TFDStoredProc, TFDQuery).
}

interface

uses
  System.SysUtils, System.Classes,
  Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.Stan.Def, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.DApt,
  Models;

type

  TGranjaDAL = class
  private
    FConn: TFDConnection;
    procedure RaiseIfErro(const AErro: string);
  public
    constructor Create(AConnection: TFDConnection);

    // Lotes
    procedure ListarLotes(AQuery: TFDQuery);

    // Pesagem
    procedure InserirPesagem(const APesagem: TPesagem;
                             out AIdGerado: Integer;
                             out AErro: string);

    procedure ListarPesagens(const AIdLote: Integer; AQuery: TFDQuery);

    // Mortalidade
    procedure InserirMortalidade(const AMortalidade: TMortalidade;
                                 out AIdGerado: Integer;
                                 out AMortAcumulada: Double;
                                 out AErro: string);

    procedure ListarMortalidades(const AIdLote: Integer; AQuery: TFDQuery);

    // Retorna total de mortes já registradas para o lote
    function TotalMortasPorLote(const AIdLote: Integer): Integer;
  end;

implementation

{ TGranjaDAL }

constructor TGranjaDAL.Create(AConnection: TFDConnection);
begin
  FConn := AConnection;
end;

procedure TGranjaDAL.RaiseIfErro(const AErro: string);
begin
  if AErro <> '' then
    raise Exception.Create(AErro);
end;

// -------------------------------------------------------
// ListarLotes
// -------------------------------------------------------
procedure TGranjaDAL.ListarLotes(AQuery: TFDQuery);
begin
  AQuery.Connection := FConn;
  AQuery.SQL.Text :=
    'SELECT L.ID_LOTE, ' +
    '       L.DESCRICAO, ' +
    '       L.DATA_ENTRADA, ' +
    '       L.QUANTIDADE_INICIAL, ' +
    '       L.PESO_MEDIO_GERAL, ' +
    '       NVL(SUM(M.QUANTIDADE_MORTA), 0) AS TOTAL_MORTAS, ' +
    '       ROUND(NVL(SUM(M.QUANTIDADE_MORTA), 0) / L.QUANTIDADE_INICIAL * 100, 2) AS PERC_MORTALIDADE ' +
    '  FROM TAB_LOTE_AVES L ' +
    '  LEFT JOIN TAB_MORTALIDADE M ON M.ID_LOTE_FK = L.ID_LOTE ' +
    ' GROUP BY L.ID_LOTE, L.DESCRICAO, L.DATA_ENTRADA, L.QUANTIDADE_INICIAL, L.PESO_MEDIO_GERAL ' +
    ' ORDER BY L.DATA_ENTRADA DESC';
  AQuery.Open;
end;

// -------------------------------------------------------
// InserirPesagem  →  PKG_GRANJA.SP_INSERIR_PESAGEM
// -------------------------------------------------------
procedure TGranjaDAL.InserirPesagem(const APesagem: TPesagem;
                                    out AIdGerado: Integer;
                                    out AErro: string);
var
  SP: TFDStoredProc;
begin
  AIdGerado := 0;
  AErro     := '';
  SP        := TFDStoredProc.Create(nil);
  try
    SP.Connection    := FConn;
    SP.StoredProcName := 'PKG_GRANJA.SP_INSERIR_PESAGEM';
    SP.Params.Clear;

    SP.Params.Add('P_ID_LOTE',      ptInput ).AsInteger := APesagem.IdLote;
    SP.Params.Add('P_DATA_PESAGEM', ptInput ).AsDateTime := APesagem.Data;
    SP.Params.Add('P_PESO_MEDIO',   ptInput ).AsFloat    := APesagem.PesoMedio;
    SP.Params.Add('P_QTD_PESADA',   ptInput ).AsInteger  := APesagem.QuantidadePesada;
    SP.Params.Add('P_ID_PESAGEM',   ptOutput).DataType    := ftInteger;
    SP.Params.Add('P_ERRO',         ptOutput).DataType    := ftString;

    SP.ExecProc;

    AIdGerado := SP.Params.ParamByName('P_ID_PESAGEM').AsInteger;
    AErro     := SP.Params.ParamByName('P_ERRO').AsString;
  finally
    SP.Free;
  end;
end;

// -------------------------------------------------------
// ListarPesagens
// -------------------------------------------------------
procedure TGranjaDAL.ListarPesagens(const AIdLote: Integer; AQuery: TFDQuery);
begin
  AQuery.Connection := FConn;
  AQuery.SQL.Text :=
    'SELECT ID_PESAGEM, DATA_PESAGEM, PESO_MEDIO, QUANTIDADE_PESADA ' +
    '  FROM TAB_PESAGEM ' +
    ' WHERE ID_LOTE_FK = :P_ID_LOTE ' +
    ' ORDER BY DATA_PESAGEM DESC';
  AQuery.ParamByName('P_ID_LOTE').AsInteger := AIdLote;
  AQuery.Open;
end;

// -------------------------------------------------------
// InserirMortalidade  →  PKG_GRANJA.SP_INSERIR_MORTALIDADE
// -------------------------------------------------------
procedure TGranjaDAL.InserirMortalidade(const AMortalidade: TMortalidade;
                                        out AIdGerado: Integer;
                                        out AMortAcumulada: Double;
                                        out AErro: string);
var
  SP: TFDStoredProc;
begin
  AIdGerado       := 0;
  AMortAcumulada  := 0;
  AErro           := '';
  SP              := TFDStoredProc.Create(nil);
  try
    SP.Connection     := FConn;
    SP.StoredProcName := 'PKG_GRANJA.SP_INSERIR_MORTALIDADE';
    SP.Params.Clear;

    SP.Params.Add('P_ID_LOTE',        ptInput ).AsInteger  := AMortalidade.IdLote;
    SP.Params.Add('P_DATA_MORT',      ptInput ).AsDateTime := AMortalidade.Data;
    SP.Params.Add('P_QTD_MORTA',      ptInput ).AsInteger  := AMortalidade.QuantidadeMorta;
    SP.Params.Add('P_OBSERVACAO',     ptInput ).AsString   := AMortalidade.Observacao;
    SP.Params.Add('P_ID_MORTALIDADE', ptOutput).DataType   := ftInteger;
    SP.Params.Add('P_MORT_ACUMULADA', ptOutput).DataType   := ftFloat;
    SP.Params.Add('P_ERRO',           ptOutput).DataType   := ftString;

    SP.ExecProc;

    AIdGerado      := SP.Params.ParamByName('P_ID_MORTALIDADE').AsInteger;
    AMortAcumulada := SP.Params.ParamByName('P_MORT_ACUMULADA').AsFloat;
    AErro          := SP.Params.ParamByName('P_ERRO').AsString;
  finally
    SP.Free;
  end;
end;

// -------------------------------------------------------
// ListarMortalidades
// -------------------------------------------------------
procedure TGranjaDAL.ListarMortalidades(const AIdLote: Integer; AQuery: TFDQuery);
begin
  AQuery.Connection := FConn;
  AQuery.SQL.Text :=
    'SELECT ID_MORTALIDADE, DATA_MORTALIDADE, QUANTIDADE_MORTA, OBSERVACAO ' +
    '  FROM TAB_MORTALIDADE ' +
    ' WHERE ID_LOTE_FK = :P_ID_LOTE ' +
    ' ORDER BY DATA_MORTALIDADE DESC';
  AQuery.ParamByName('P_ID_LOTE').AsInteger := AIdLote;
  AQuery.Open;
end;

// -------------------------------------------------------
// TotalMortasPorLote
// -------------------------------------------------------
function TGranjaDAL.TotalMortasPorLote(const AIdLote: Integer): Integer;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text :=
      'SELECT NVL(SUM(QUANTIDADE_MORTA), 0) AS TOTAL ' +
      '  FROM TAB_MORTALIDADE ' +
      ' WHERE ID_LOTE_FK = :P_ID_LOTE';
    Q.ParamByName('P_ID_LOTE').AsInteger := AIdLote;
    Q.Open;
    Result := Q.FieldByName('TOTAL').AsInteger;
  finally
    Q.Free;
  end;
end;

end.
