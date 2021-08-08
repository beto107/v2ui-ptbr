# v2ui-ptbr
Script de instalação e gerenciamento V2Ray

## Instalação

Primeiramente verifique se seu provedor de VPS bloqueia acesso as portas,e libere no mesmo as portas que irá usar.
Também verifique se não existe nenhuma regra no iptables da sua máquina que possa impedir a conexão/acesso ao painel

`cd /rooot && apt update && apt install wget && wget https://raw.githubusercontent.com/Andley302/v2ui-ptbr/main/install_v2ray.sh && chmod +x install_v2ray.sh && ./install_v2ray.sh;`
