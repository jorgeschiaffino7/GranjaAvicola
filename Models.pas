unit Models;

{
  Entidades de negócio: TLote, TPesagem, TMortalidade
  Conceitos aplicados: encapsulamento, herança (TRegistroBase)
}

interface

uses
  System.SysUtils, System.Classes;

type

  // -------------------------------------------------------
  // Classe base com campos comuns a registros de lote
  // -------------------------------------------------------
  TRegistroBase = class
  private
    FIdLote: Integer;
    FData:   TDate;
  public
    property IdLote : Integer read FIdLote write FIdLote;
    property Data   : TDate   read FData   write FData;
  end;

  // -------------------------------------------------------
  // TLote - representa TAB_LOTE_AVES
  // -------------------------------------------------------
  TLote = class
  private
    FIdLote:            Integer;
    FDescricao:         string;
    FDataEntrada:       TDate;
    FQuantidadeInicial: Integer;
    FPesoMedioGeral:    Double;
  public
    property IdLote:            Integer read FIdLote            write FIdLote;
    property Descricao:         string  read FDescricao          write FDescricao;
    property DataEntrada:       TDate   read FDataEntrada        write FDataEntrada;
    property QuantidadeInicial: Integer read FQuantidadeInicial  write FQuantidadeInicial;
    property PesoMedioGeral:    Double  read FPesoMedioGeral     write FPesoMedioGeral;
  end;

  // -------------------------------------------------------
  // TPesagem - representa TAB_PESAGEM
  // -------------------------------------------------------
  TPesagem = class(TRegistroBase)
  private
    FIdPesagem:        Integer;
    FPesoMedio:        Double;
    FQuantidadePesada: Integer;
  public
    property IdPesagem:        Integer read FIdPesagem        write FIdPesagem;
    property PesoMedio:        Double  read FPesoMedio         write FPesoMedio;
    property QuantidadePesada: Integer read FQuantidadePesada  write FQuantidadePesada;

    { Valida se a quantidade não ultrapassa o limite do lote }
    function Validar(const AQuantidadeInicial: Integer; out AMensagem: string): Boolean;
  end;

  // -------------------------------------------------------
  // TMortalidade - representa TAB_MORTALIDADE
  // -------------------------------------------------------
  TMortalidade = class(TRegistroBase)
  private
    FIdMortalidade:  Integer;
    FQuantidadeMorta: Integer;
    FObservacao:     string;
  public
    property IdMortalidade:  Integer read FIdMortalidade   write FIdMortalidade;
    property QuantidadeMorta: Integer read FQuantidadeMorta write FQuantidadeMorta;
    property Observacao:     string  read FObservacao       write FObservacao;

    { Valida se a soma com o acumulado não ultrapassa o limite }
    function Validar(const AQuantidadeInicial, AJaMortas: Integer;
                     out AMensagem: string): Boolean;
  end;

implementation

{ TPesagem }

function TPesagem.Validar(const AQuantidadeInicial: Integer;
                          out AMensagem: string): Boolean;
begin
  Result := True;
  AMensagem := '';

  if FPesoMedio <= 0 then
  begin
    AMensagem := 'Peso médio deve ser maior que zero.';
    Result := False;
    Exit;
  end;

  if FQuantidadePesada <= 0 then
  begin
    AMensagem := 'Quantidade pesada deve ser maior que zero.';
    Result := False;
    Exit;
  end;

  if FQuantidadePesada > AQuantidadeInicial then
  begin
    AMensagem := Format('Quantidade pesada (%d) ultrapassa a quantidade inicial do lote (%d).',
                        [FQuantidadePesada, AQuantidadeInicial]);
    Result := False;
  end;
end;

{ TMortalidade }

function TMortalidade.Validar(const AQuantidadeInicial, AJaMortas: Integer;
                               out AMensagem: string): Boolean;
var
  vTotal: Integer;
begin
  Result := True;
  AMensagem := '';

  if FQuantidadeMorta <= 0 then
  begin
    AMensagem := 'Quantidade morta deve ser maior que zero.';
    Result := False;
    Exit;
  end;

  vTotal := AJaMortas + FQuantidadeMorta;
  if vTotal > AQuantidadeInicial then
  begin
    AMensagem := Format('Mortalidade acumulada (%d) ultrapassaria a quantidade inicial (%d).',
                        [vTotal, AQuantidadeInicial]);
    Result := False;
  end;
end;

end.
