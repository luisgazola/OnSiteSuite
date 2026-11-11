# Segurança e privacidade — OnSiteSuite 2.0

- Modo offline é padrão. `--online` ou `-Online` autoriza ping/DNS externos.
- O software não instala serviço, não usa telemetria, não cria conta em nuvem.
- Logs e identificadores de hardware podem conter dados pessoais/operacionais; obtenha autorização antes de coletar e compartilhar laudos. Avalie obrigações LGPD.
- No Linux, novo diretório de sessão recebe permissão 0700 e relatórios 0600. No Windows, verifique as ACLs herdadas da pasta.
- Não cole laudos completos em plataformas públicas sem retirar host, IPs, nomes, número de série e dados do cliente.
- `--print-test` sem `--yes-print` é recusado. Cortadores/guilhotinas ESC/POS não são acionados.
- Não utiliza sudo automaticamente e não solicita privilégios elevados silenciosamente.
- Verifique scripts antes de executá-los como administrador. Não use bypass global de políticas de execução.
- Modificações futuras com risco exigirão confirmação por ação, backup quando aplicável e registro de auditoria.
- Dados de diagnósticos não são prova de conformidade de segurança nem substituem testes de fabricante.
