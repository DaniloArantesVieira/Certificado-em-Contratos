# Laboratório HTTPS com Nginx e Docker

[![Docker CI](https://github.com/DaniloArantesVieira/Certificado-em-Contratos/actions/workflows/docker.yml/badge.svg)](https://github.com/DaniloArantesVieira/Certificado-em-Contratos/actions/workflows/docker.yml)
[![Docker / Nginx](https://img.shields.io/badge/Docker%20%2F%20Nginx-Alpine-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/_/nginx)
[![HTTPS / TLS 1.2 e TLS 1.3](https://img.shields.io/badge/HTTPS%20%2F%20TLS-1.2%20%7C%201.3-2E8B57?logo=letsencrypt&logoColor=white)](#4-arquitetura)
[![Licença MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 1. Visão geral

Este é um projeto acadêmico e laboratorial que publica uma página estática com **Nginx** em containers Docker. Ele demonstra o uso de HTTP e HTTPS, a negociação TLS com certificado autoassinado e o redirecionamento permanente de HTTP para HTTPS.

## 2. Objetivo

O objetivo é oferecer um exemplo pequeno e didático de como:

- executar o Nginx com Docker e Docker Compose;
- atender conexões HTTP e HTTPS;
- redirecionar requisições HTTP para HTTPS;
- montar certificado e chave privada somente em tempo de execução;
- manter certificados locais fora da imagem Docker e do estado versionado atual.

## 3. Tecnologias

- Nginx;
- Docker;
- Docker Compose;
- HTTP e HTTPS;
- TLS 1.2 e TLS 1.3;
- certificado X.509 autoassinado;
- PowerShell.

## 4. Arquitetura

```text
Cliente
  |
  | HTTP:80
  v
Nginx
  |
  | 301 Redirect
  v
HTTPS:443
  |
  | TLS
  v
Página estática
```

O Nginx recebe requisições locais na porta 80 e responde com redirecionamento permanente (`301`) para `https://localhost`. Na porta 443, ele usa os arquivos montados em `/etc/nginx/ssl` para estabelecer TLS e servir o conteúdo de `public/`. As duas portas são vinculadas somente ao endereço de loopback IPv4 (`127.0.0.1`).

## 5. Estrutura do repositório

```text
Certificado-em-Contratos/
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       └── docker.yml
├── certs/
│   └── .gitkeep
├── config/
│   └── nginx.conf
├── public/
│   └── index.html
├── scripts/
│   └── generate-cert.ps1
├── .dockerignore
├── .gitignore
├── Dockerfile
├── LICENSE
├── README.md
├── SECURITY.md
└── docker-compose.yml
```

Após a geração local, `certs/` também conterá `nginx-selfsigned.crt` e `nginx-selfsigned.key`. Esses dois arquivos são ignorados pelo Git.

## 6. Pré-requisitos

- Windows com PowerShell;
- Docker Desktop iniciado e configurado para containers Linux;
- Docker Compose v2, disponível pelo comando `docker compose`;
- acesso à internet na primeira execução para baixar as imagens Docker necessárias.

Não é necessário instalar o OpenSSL diretamente no Windows. O script executa o OpenSSL dentro de um container Alpine temporário.

## 7. Geração do certificado

No PowerShell, a partir da raiz do repositório, execute:

```powershell
.\scripts\generate-cert.ps1
```

O script cria, se necessário:

- `certs/nginx-selfsigned.crt`;
- `certs/nginx-selfsigned.key`.

O certificado é emitido para `localhost` e inclui os SANs `DNS:localhost` e `IP:127.0.0.1`. Os arquivos são locais, ignorados pelo Git e não são copiados para a imagem Docker.

## 8. Execução

Após gerar o certificado, inicie o ambiente:

```powershell
docker compose up --build -d
```

A página ficará disponível em `https://localhost`.

## 9. Validação HTTP

Confira o redirecionamento da porta 80:

```powershell
curl.exe -I http://localhost
```

A resposta esperada contém o status `301 Moved Permanently` e o cabeçalho `Location: https://localhost/`.

## 10. Validação HTTPS

Confira a página servida com TLS:

```powershell
curl.exe -k -I https://localhost
```

A resposta esperada contém o status `200 OK`.

A opção `-k` desativa, somente nesse comando de laboratório, a validação da cadeia de confiança. Ela é necessária porque o certificado foi autoassinado e não pertence a uma autoridade certificadora confiável do sistema. Não use `-k` para contornar validações TLS em produção.

## 11. Encerramento do ambiente

Para remover o container e a rede criados pelo Compose:

```powershell
docker compose down
```

## 12. Segurança

- Certificados e chaves gerados localmente não fazem parte do estado versionado atual nem são incluídos no contexto de build.
- A chave é montada no container em tempo de execução por um volume somente leitura.
- Chaves privadas nunca devem ser publicadas no Git, compartilhadas ou incorporadas em imagens Docker.
- Se uma chave privada for publicada, considere-a comprometida, revogue-a quando aplicável e substitua-a imediatamente.
- O `.gitignore` impede novos arquivos locais de serem adicionados por engano, mas não remove arquivos que já existam em commits anteriores; a sanitização do histórico deve ser feita separadamente e de forma coordenada.
- Em produção, utilize gerenciamento apropriado de segredos e certificados emitidos por uma autoridade certificadora confiável.

## 13. Limitações do certificado autoassinado

O certificado deste laboratório não é confiável por padrão para navegadores, sistemas operacionais ou clientes HTTP. Por isso, alertas de segurança são esperados. O certificado serve apenas para estudo e testes locais: não oferece validação pública de identidade, não possui processo automático de renovação e não deve ser usado dessa maneira em produção.

## 14. Competências demonstradas

- Docker;
- Docker Compose;
- Nginx;
- HTTP e HTTPS;
- TLS 1.2 e TLS 1.3;
- certificados X.509 autoassinados;
- volumes somente leitura;
- tratamento seguro de chaves privadas;
- PowerShell;
- GitHub Actions;
- Dependabot;
- Secret Scanning e boas práticas de proteção de segredos;
- headers básicos de segurança HTTP.

## 15. Automação e segurança do repositório

- O workflow `Docker CI`, definido em `.github/workflows/docker.yml`, valida o ambiente Docker e o funcionamento de HTTP e HTTPS.
- O Dependabot, configurado em `.github/dependabot.yml`, verifica semanalmente atualizações para Docker e GitHub Actions.
- Um ruleset protege a branch `main`, exige alterações por Pull Request e aplica o check obrigatório `docker`.
- `Secret Protection` e `Push Protection` ajudam a identificar e bloquear a publicação de segredos.

O ruleset, o `Secret Protection` e o `Push Protection` são configurações do repositório no GitHub. Eles não correspondem a arquivos versionados neste projeto.
