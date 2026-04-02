# Contratos

Projeto de laboratório para servir uma aplicação/página web com **Nginx**, **Docker** e **certificado self-signed**.

## Estrutura

```text
Contratos/
├─ docker-compose.yml
├─ Dockerfile
├─ index.html
├─ nginx-selfsigned.crt
├─ nginx-selfsigned.key
└─ nginx.conf
```

## Objetivo

Disponibilizar uma página web estática com suporte a HTTPS em ambiente de testes, usando certificado autoassinado.

## Arquivos

- `docker-compose.yml`: orquestração do serviço.
- `Dockerfile`: definição da imagem customizada.
- `index.html`: conteúdo da página inicial.
- `nginx.conf`: configuração do servidor Nginx.
- `nginx-selfsigned.crt`: certificado autoassinado.
- `nginx-selfsigned.key`: chave privada do certificado.

## Requisitos

- Docker
- Docker Compose

## Como executar

```bash
docker compose up --build
```

Depois, acesse o endereço configurado no navegador. Como o certificado é autoassinado, o navegador poderá exibir aviso de segurança.

## Segurança

- Não utilize certificados autoassinados em produção.
- Não publique chaves privadas em repositórios públicos.
- Em produção, use gerenciamento seguro de segredos e certificados válidos.
