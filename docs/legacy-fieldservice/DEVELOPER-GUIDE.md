# Guia do Desenvolvedor

## Como adicionar um novo módulo

1. Crie o Service em `src/Services`.
2. Crie ou atualize o Model em `src/Models`.
3. Adicione uma View em `src/Views`, se houver saída específica.
4. Acione pelo Controller adequado.
5. Registre valores de referência em `KnowledgeBase`, quando necessário.
6. Documente a alteração no CHANGELOG.

## Convenções

- Funções públicas começam com `Fss`.
- Services não devem escrever diretamente no console quando puderem retornar objeto.
- Views cuidam da saída visual.
- Configurações devem ficar em JSON.
