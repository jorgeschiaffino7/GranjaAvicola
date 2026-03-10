unit LoteHealthIndicator;

{
  Componente visual: TLoteHealthIndicator
  Exibe um painel colorido com % mortalidade do lote.
    Verde   → mortalidade < 5%
    Amarelo → mortalidade entre 5% e 10%
    Vermelho → mortalidade > 10%
}

interface

uses
  System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.StdCtrls,
  Winapi.Windows, Winapi.Messages;

type

  THealthStatus = (hsVerde, hsAmarelo, hsVermelho, hsSemDados);

  TLoteHealthIndicator = class(TPanel)
  private
    FMortalidade:  Double;   // 0..100 (percentual)
    FLoteDesc:     string;
    FStatusLabel:  TLabel;
    FPercLabel:    TLabel;

    function GetStatus: THealthStatus;
    procedure SetMortalidade(const AValue: Double);
    procedure SetLoteDesc(const AValue: string);
    procedure AtualizarVisual;
  public
    constructor Create(AOwner: TComponent); override;
    property Mortalidade: Double  read FMortalidade write SetMortalidade;
    property LoteDesc:    string  read FLoteDesc    write SetLoteDesc;
    function StatusTexto: string;
  end;

implementation

{ TLoteHealthIndicator }

constructor TLoteHealthIndicator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width   := 220;
  Height  := 60;
  Caption := '';
  BevelOuter := bvLowered;

  FStatusLabel := TLabel.Create(Self);
  FStatusLabel.Parent    := Self;
  FStatusLabel.Left      := 8;
  FStatusLabel.Top       := 6;
  FStatusLabel.Font.Style := [fsBold];
  FStatusLabel.Font.Size  := 9;

  FPercLabel := TLabel.Create(Self);
  FPercLabel.Parent    := Self;
  FPercLabel.Left      := 8;
  FPercLabel.Top       := 28;
  FPercLabel.Font.Size  := 8;

  FMortalidade := -1;
  AtualizarVisual;
end;

function TLoteHealthIndicator.GetStatus: THealthStatus;
begin
  if FMortalidade < 0 then
    Result := hsSemDados
  else if FMortalidade < 5 then
    Result := hsVerde
  else if FMortalidade <= 10 then
    Result := hsAmarelo
  else
    Result := hsVermelho;
end;

procedure TLoteHealthIndicator.SetMortalidade(const AValue: Double);
begin
  FMortalidade := AValue;
  AtualizarVisual;
end;

procedure TLoteHealthIndicator.SetLoteDesc(const AValue: string);
begin
  FLoteDesc := AValue;
  AtualizarVisual;
end;

procedure TLoteHealthIndicator.AtualizarVisual;
begin
  case GetStatus of
    hsVerde:
    begin
      Color := $00C8FFC8;  // verde claro
      FStatusLabel.Caption := '● SAUDÁVEL';
      FStatusLabel.Font.Color := clGreen;
    end;
    hsAmarelo:
    begin
      Color := $0080FFFF;  // amarelo claro
      FStatusLabel.Caption := '● ATENÇÃO';
      FStatusLabel.Font.Color := $00007BC0;  // laranja escuro
    end;
    hsVermelho:
    begin
      Color := $00C8C8FF;  // vermelho claro
      FStatusLabel.Caption := '● CRÍTICO';
      FStatusLabel.Font.Color := clRed;
    end;
    hsSemDados:
    begin
      Color := clBtnFace;
      FStatusLabel.Caption := '● SEM DADOS';
      FStatusLabel.Font.Color := clGray;
    end;
  end;

  if FMortalidade >= 0 then
    FPercLabel.Caption := Format('Mortalidade acumulada: %.2f%%', [FMortalidade])
  else
    FPercLabel.Caption := 'Sem registros de mortalidade';
end;

function TLoteHealthIndicator.StatusTexto: string;
begin
  case GetStatus of
    hsVerde:    Result := 'SAUDÁVEL';
    hsAmarelo:  Result := 'ATENÇÃO';
    hsVermelho: Result := 'CRÍTICO';
  else
    Result := 'SEM DADOS';
  end;
end;

end.
