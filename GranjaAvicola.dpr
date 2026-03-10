program GranjaAvicola;

uses
  Vcl.Forms,
  FireDAC.Phys.Oracle,
  FireDAC.Phys.OracleDef,
  frmMain in 'frmMain.pas' {FormMain},
  Models in 'Models.pas',
  LoteHealthIndicator in 'LoteHealthIndicator.pas',
  frmDetalhe in 'frmDetalhe.pas' {FormDetalhe},
  frmNovoLote in 'frmNovoLote.pas' {FormNovoLote},
  DAL in 'DAL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
