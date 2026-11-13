# OnSiteSuite 2.2.0 — USB Diagnostic Lab

**Desenvolvido por Excelsior Soluções em Tecnologia · Desenvolvedor Luís Gazola**

## Objetivo

Elevar o monitoramento USB contínuo da série 2.1 para um conjunto de evidências e análises por dispositivo, preservando a CLI, a operação offline e o comportamento do monitor no `kgx`, no PowerShell 7 e no CMD.

## Entregas implementadas

- `usb-resumo.json`: contagens de conexões, desconexões e reconexões observadas, dispositivos afetados, estado inicial/final, identificador, rótulo, VID/PID quando inferível, horário do primeiro e último evento registrados.
- `usb-comparacao.json`: diferenças **brutas** das contagens em relação a uma sessão de referência informada pelo operador com `--usb-baseline` ou `-UsbBaseline`.
- Análise isolada em `src/linux/Services/UsbAnalysisService.sh` e `src/windows/Services/UsbAnalysisService.ps1`; adaptadores de coleta existentes preservados.
- Testes Linux determinísticos de estados e reconexões; teste PowerShell com eventos simulados disponível.
- Persistência de `usb-eventos.jsonl`, `relatorio.json`, `relatorio.txt` e `relatorio.html`; o contrato principal continua **schemaVersion 2.0**. Os arquivos novos possuem um esquema auxiliar `schemaVersion 1.0`.
- Funcionalidades de impressão e guilhotina da v2.1.0 preservadas, inclusive proteções por consentimento.

## Exemplo Linux

```bash
./onsite.sh --usb-monitor --usb-terminal kgx --usb-interval 1
# Conecte/desconecte um dispositivo; depois digite \q na janela auxiliar.
# Encontre o usb-resumo.json na pasta da sessão anterior.
./onsite.sh --usb-monitor --usb-terminal kgx \
  --usb-baseline '/caminho/da/sessao/anterior/usb-resumo.json'
```

## Exemplo Windows 10/11 (PowerShell 7)

```powershell
.\OnSiteSuite.ps1 -UsbMonitor -UsbTerminal PowerShell
.\OnSiteSuite.ps1 -UsbMonitor -UsbTerminal CMD -UsbBaseline 'C:\Laudos\anterior\usb-resumo.json'
```

## Limitações e cuidados

- A captura continua **por amostragem**. Uma desconexão muito curta pode passar despercebida. Não há medida física de tensão, oscilação de sinal, integridade do cabo nem taxa de erros elétricos.
- `reconnections` significa que um dispositivo **antes observado como desconectado voltou a ser observado como conectado** na sessão. É um indício, não diagnóstico conclusivo de defeito.
- No Linux, `port` identifica o caminho de topologia relatado pelo `sysfs`. No Windows, a identificação principal é o PnP Device ID, e o campo `port` é `null`; não inventamos uma porta física.
- Os dados de identificação de dispositivos podem conter número de série. Trate relatórios como confidenciais e compartilhe apenas com autorização.
- A comparação de sessões não normaliza pelas diferenças de duração nem pelo intervalo escolhido. O resultado deve ser interpretado pelo técnico, nunca como nota automática de saúde.
- Uma sessão interrompida por queda de energia ou encerramento forçado pode não gerar relatório completo.

## Verificação

```bash
bash tests/run-linux.sh
```

```powershell
pwsh -NoProfile -File .\tests\usb-analysis-windows.ps1
pwsh -NoProfile -File .\tests\advanced-windows.ps1
```

As rotinas de USB e a suíte Linux passaram em ambiente simulado. O usuário informou que a versão 2.1.0 funcionou normalmente no Windows, mas os **novos casos de uso da v2.2.0** ainda exigem execução e homologação em Windows real. Impressão e corte físicos permanecem sem homologação nesta entrega.
