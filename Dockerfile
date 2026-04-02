# Usa a imagem oficial e leve recomendada
FROM nginx:alpine

# Cria a pasta para armazenar os certificados
RUN mkdir -p /etc/nginx/ssl

# Copia os certificados que você gerou no Passo 1
COPY nginx-selfsigned.crt /etc/nginx/ssl/
COPY nginx-selfsigned.key /etc/nginx/ssl/

# Substitui o arquivo de configuração padrão do NGINX pelo nosso
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia a página HTML para a pasta pública do servidor
COPY index.html /usr/share/nginx/html/