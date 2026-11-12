# Segurança e privacidade — OnSiteSuite 2.0

- Modo offline é padrão. `--online` ou `-Online` autoriza ping/DNS externos.
- O software não instala serviço, não usa telemetria, não cria conta em nuvem.
- Logs e identificadores de hardware podem conter dados pessoais/operacionais; obtenha autorização antes de coletar e compartilhar laudos. Avalie obrigações LGPD.
- No Linux, novo diretório de sessão recebe permissão 0700 e relatórios 0600. No Windows, verifique as ACLs herdadas da pasta.
- Não cole laudos completos em plataformas públicas sem retirar host, IPs, nomes, número de série e dados do cliente.
- `--print-test` sem `--yes-print` é recusado. O corte com guilhotina somente é enviado em modo RAW ESC/POS com `--cut-after-each --yes-cut`, para fila e equipamento explicitamente declarados compatíveis pelo operador. Não há verificação automática de compatibilidade ou confirmação física de corte.
- Não utiliza sudo automaticamente e não solicita privilégios elevados silenciosamente.
- Verifique scripts antes de executá-los como administrador. Não use bypass global de políticas de execução.
- Modificações futuras com risco exigirão confirmação por ação, backup quando aplicável e registro de auditoria.
- Dados de diagnósticos não são prova de conformidade de segurança nem substituem testes de fabricante.


## Cuidados com funções v2.1.0

- Monitor USB por amostragem pode omitir desconexões muito curtas e seus registros incluem identificadores PnP/seriais potencialmente sensíveis. Não interprete eventos isolados como defeito confirmado.
- Somente ligue `--escpos-raw`/`-EscPosRaw` em fila devidamente configurada para aceitar dados brutos compatíveis. Uma impressora sem suporte pode imprimir lixo, ignorar comandos ou cortar inesperadamente.
- O aplicativo restringe impressão a 100 comprovantes por lote e exige autorização; inspecione fisicamente o papel, alimentador e guilhotina, com atenção ao contato com lâminas.
- A sessão USB finaliza ao receber `\q`; interrupção de energia ou processo forçado pode impedir conclusão do laudo. Evite atribuir integridade a um monitoramento incompleto.
