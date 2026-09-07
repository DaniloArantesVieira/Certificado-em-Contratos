[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$certsDirectory = Join-Path $projectRoot "certs"
$certificatePath = Join-Path $certsDirectory "nginx-selfsigned.crt"
$privateKeyPath = Join-Path $certsDirectory "nginx-selfsigned.key"
$temporaryCertificatePath = Join-Path $certsDirectory ".nginx-selfsigned.crt.tmp"
$temporaryPrivateKeyPath = Join-Path $certsDirectory ".nginx-selfsigned.key.tmp"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("Docker não foi encontrado. Instale e inicie o Docker Desktop antes de executar este script.")
    exit 1
}

New-Item -ItemType Directory -Path $certsDirectory -Force | Out-Null
Remove-Item $temporaryCertificatePath, $temporaryPrivateKeyPath -Force -ErrorAction SilentlyContinue

try {
    & docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "O Docker não está disponível. Confirme se o Docker Desktop está em execução."
    }

    & docker run --rm `
        --volume "${certsDirectory}:/certs" `
        alpine:3.21 `
        sh -c 'apk add --no-cache openssl >/dev/null && openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 365 -keyout /certs/.nginx-selfsigned.key.tmp -out /certs/.nginx-selfsigned.crt.tmp -subj /CN=localhost -addext subjectAltName=DNS:localhost,IP:127.0.0.1 && test -s /certs/.nginx-selfsigned.crt.tmp && test -s /certs/.nginx-selfsigned.key.tmp && openssl x509 -in /certs/.nginx-selfsigned.crt.tmp -pubkey -noout > /tmp/certificate.pub && openssl pkey -in /certs/.nginx-selfsigned.key.tmp -pubout > /tmp/private-key.pub && cmp -s /tmp/certificate.pub /tmp/private-key.pub'

    if ($LASTEXITCODE -ne 0) {
        throw "O OpenSSL executado no container retornou o código $LASTEXITCODE."
    }

    if (-not (Test-Path $temporaryCertificatePath) -or -not (Test-Path $temporaryPrivateKeyPath)) {
        throw "O container terminou sem criar os dois arquivos esperados."
    }

    Move-Item $temporaryCertificatePath $certificatePath -Force
    Move-Item $temporaryPrivateKeyPath $privateKeyPath -Force
}
catch {
    Remove-Item $temporaryCertificatePath, $temporaryPrivateKeyPath -Force -ErrorAction SilentlyContinue
    [Console]::Error.WriteLine("Falha ao gerar o certificado: $($_.Exception.Message)")
    exit 1
}

Write-Host "Certificado criado: $certificatePath"
Write-Host "Chave privada criada: $privateKeyPath"
Write-Host "Esses arquivos são locais e estão ignorados pelo Git. Não publique a chave privada."
