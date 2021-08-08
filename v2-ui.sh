#!/bin/bash

#======================================================
#   System Required: CentOS 7+ / Debian 8+ / Ubuntu 16+
#   Description: Manage v2-ui
#   Author: sprov
#   Translation: Andley302
#   Blog: https://blog.sprov.xyz
#   Github - v2-ui: https://github.com/sprov065/v2-ui
#======================================================

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Erro: ${plain} Você deve usar o usuário root para executar este script!\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}A versão do sistema não foi detectada,entre em contato com o autor do script！${plain}\n" && exit 1
fi

os_version=""

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Por favor,use CentOS 7 ou sistema superior！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Por favor,use Ubuntu 16 ou sistema superior！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Por favor,use Debian 8 ou sistema superior！${plain}\n" && exit 1
    fi
fi

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [padrão $2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "Se deseja reiniciar o painel,reinicie o painel também reiniciará xray" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Pressione enter para retornar ao menu principal: ${plain}" && read temp
    show_menu
}

install() {
    cd /root && rm -rf v2-ui.sh
	wget https://github.com/andley302/v2ui-ptbr/master/v2-ui.sh
	chmod +x v2-ui.sh && ./v2-ui.sh
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

update() {
    confirm "Esta função irá reinstalar à força a versão mais recente atual, os dados não serão perdidos,deseja continuar?" "n"
    if [[ $? != 0 ]]; then
        echo -e "${red}Cancelado ${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    cd /root && rm -rf v2-ui.sh
	wget https://github.com/andley302/v2ui-ptbr/master/v2-ui.sh
	chmod +x v2-ui.sh && ./v2-ui.sh
    if [[ $? == 0 ]]; then
        echo -e "${green}A atualização está concluída e o painel foi reiniciado automaticamente ${plain}"
        exit
#        if [[ $# == 0 ]]; then
#            restart
#        else
#            restart 0
#        fi
    fi
}

uninstall() {
    confirm "Tem certeza que deseja desinstalar o painel?Também irá desinstalar o xray" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    systemctl stop v2-ui
    systemctl disable v2-ui
    rm /etc/systemd/system/v2-ui.service -f
    systemctl daemon-reload
    systemctl reset-failed
    rm /etc/v2-ui/ -rf
    rm /usr/local/v2-ui/ -rf

    echo ""
    echo -e "A desinstalação foi bem-sucedida.Se quiser excluir este script, saia do script e execute ${green}rm /usr/bin/v2-ui -f${plain} excluir"
    echo ""
    echo -e "Telegram: ${green}https://t.me/sprov_blog${plain}"
    echo -e "Github issues:${green}https://github.com/sprov065/v2-ui/issues${plain}"
    echo -e "Blog:${green}Traduzido por @Andley302${plain}"

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

reset_user() {
    confirm "Tem certeza de que deseja redefinir seu nome de usuário e senha para admin?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    /usr/local/v2-ui/v2-ui resetuser
    echo -e "Nome de usuário e senha foram redefinidos para${green}admin${plain}，Agora reinicie o painel."
    confirm_restart
}

reset_config() {
    confirm "Tem certeza de que deseja redefinir todas as configurações do painel? Os dados da conta não serão perdidos,o nome de usuário e a senha não serão alterados" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    /usr/local/v2-ui/v2-ui resetconfig
    echo -e "Todos os painéis foram redefinidos para os valores padrão,agora reinicie os painéis e use o padrão${green}65432${plain} Painel de acesso à porta"
    confirm_restart
}

set_port() {
    echo && echo -n -e "Digite o número da porta [1-65535]: " && read port
    if [[ -z "${port}" ]]; then
        echo -e "${yellow}Cancelado${plain}"
        before_show_menu
    else
        /usr/local/v2-ui/v2-ui setport ${port}
        echo -e "Depois de configurar a porta,reinicie o painel e use a porta recém-configurada${green}${port}${plain} Painel de acesso"
        confirm_restart
    fi
}

start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        echo -e "${green}O painel já está em execução,não há necessidade de começar novamente,se você precisar reiniciar selecione reiniciar${plain}"
    else
        systemctl start v2-ui
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            echo -e "${green}v2-ui Iniciado com sucesso${plain}"
        else
            echo -e "${red}O painel falhou ao iniciar.Pode ser porque demorou mais de dois segundos para iniciar.Verifique as informações de registro mais tarde.${plain}"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    check_status
    if [[ $? == 1 ]]; then
        echo ""
        echo -e "${green}O painel parou,não há necessidade de parar novamente${plain}"
    else
        systemctl stop v2-ui
        sleep 2
        check_status
        if [[ $? == 1 ]]; then
            echo -e "${green}v2-ui e xray parados com sucesso${plain}"
        else
            echo -e "${red}O painel falhou ao parar.Pode ser porque o tempo de parada excede dois segundos.Verifique as informações de registro mais tarde.${plain}"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    systemctl restart v2-ui
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        echo -e "${green}v2-ui e xray reiniciados com sucesso${plain}"
    else
        echo -e "${red}A reinicialização do painel falhou,pode ser porque o tempo de inicialização excede dois segundos,verifique as informações de log mais tarde${plain}"
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    systemctl status v2-ui -l
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    systemctl enable v2-ui
    if [[ $? == 0 ]]; then
        echo -e "${green}v2-ui Defina a inicialização automática de inicialização com sucesso${plain}"
    else
        echo -e "${red}v2-ui Falha ao definir autoinício após ligar${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    systemctl disable v2-ui
    if [[ $? == 0 ]]; then
        echo -e "${green}v2-ui Inicialização automática cancelada com sucesso${plain}"
    else
        echo -e "${red}v2-ui Cancelar a falha de inicialização${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_log() {
    echo && echo -n -e "Pode haver muita saída durante o uso do painel.AVISO: Log,se não houver problema com o painel,então não há problema,pressione Enter para continuar: " && read temp
    tail -500f /etc/v2-ui/v2-ui.log
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

install_bbr() {
    bash <(curl -L -s https://raw.githubusercontent.com/sprov065/blog/master/bbr.sh)
    if [[ $? == 0 ]]; then
        echo ""
        echo -e "${green}BBR instalado com sucesso!${plain}"
    else
        echo ""
        echo -e "${red}Script de instalação BBR falhou,verifique se a máquina pode ser conectada Github${plain}"
    fi

    before_show_menu
}

update_shell() {
    wget -O /usr/bin/v2-ui -N --no-check-certificate https://github.com/sprov065/v2-ui/raw/master/v2-ui.sh
    if [[ $? != 0 ]]; then
        echo ""
        echo -e "${red}Falha ao baixar o script,verifique se a máquina pode ser conectada Github${plain}"
        before_show_menu
    else
        chmod +x /usr/bin/v2-ui
        echo -e "${green}O script de atualização foi bem-sucedido,execute novamente o script${plain}" && exit 0
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f /etc/systemd/system/v2-ui.service ]]; then
        return 2
    fi
    temp=$(systemctl status v2-ui | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        return 0
    else
        return 1
    fi
}

check_enabled() {
    temp=$(systemctl is-enabled v2-ui)
    if [[ x"${temp}" == x"enabled" ]]; then
        return 0
    else
        return 1;
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        echo -e "${red}O painel foi instalado,não instale repetidamente${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        echo -e "${red}Instale o painel primeiro${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

show_status() {
    check_status
    case $? in
        0)
            echo -e "Status do painel:${green} Ativo${plain}"
            show_enable_status
            ;;
        1)
            echo -e "Status do painel:${yellow}Não está rodando${plain}"
            show_enable_status
            ;;
        2)
            echo -e "Status do painel:${red} Não está instalado${plain}"
    esac
    show_xray_status
}

show_enable_status() {
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "Inicialização automática após reiniciar o sistema:${green} Ativado${plain}"
    else
        echo -e "Inicialização automática após reiniciar o sistema: ${red}Desativado${plain}"
    fi
}

check_xray_status() {
    count=$(ps -ef | grep "xray-v2-ui" | grep -v "grep" | wc -l)
    if [[ count -ne 0 ]]; then
        return 0
    else
        return 1
    fi
}

show_xray_status() {
    check_xray_status
    if [[ $? == 0 ]]; then
        echo -e "Status xray:${green} Ativo${plain}"
    else
        echo -e "ttatus xray:${red} Desativado!${plain}"
    fi
}

show_usage() {
    echo "GERENCIADOR V2-UI: "
    echo "------------------------------------------"
    echo "v2-ui              - Mostrar menu de gerenciamento(Mais funções)"
    echo "v2-ui start        - Inicia o painel v2-ui"
    echo "v2-ui stop         - Parar painel v2-ui"
    echo "v2-ui restart      - Reiniciar o painel v2-ui"
    echo "v2-ui status       - Ver o status v2-ui"
    echo "v2-ui enable       - Configure v2-ui para iniciar automaticamente após a inicialização"
    echo "v2-ui disable      - Cancelar inicialização v2-ui automaticamente"
    echo "v2-ui log          - Ver registro v2-ui"
    echo "v2-ui update       - Atualizar painel v2-ui"
    echo "v2-ui install      - Instale o painel v2-ui"
    echo "v2-ui uninstall    - Desinstalar painel v2-ui"
    echo "------------------------------------------"
}

show_menu() {
    echo -e "
  ${green}GERENCIADOR V2-UI ${plain}
--- Traduzido por @Andley302 ---
  ${green}0.${plain} Sair do script
————————————————
  ${green}1.${plain} Instale v2-ui
  ${green}2.${plain} Atualizar v2-ui
  ${green}3.${plain} Desinstalar v2-ui
————————————————
  ${green}4.${plain} Redefinir nome de usuário e senha
  ${green}5.${plain} Redefinir as configurações do painel
  ${green}6.${plain} Defina a porta de acesso ao painel web
————————————————
  ${green}7.${plain} Iniciar v2-ui
  ${green}8.${plain} Parar v2-ui
  ${green}9.${plain} Reiniciar v2-ui
 ${green}10.${plain} Ver o status v2-ui
 ${green}11.${plain} Ver log v2-ui
————————————————
 ${green}12.${plain} Configure v2-ui para iniciar automaticamente após a inicialização
 ${green}13.${plain} Cancelar inicialização v2-ui automaticamente
————————————————
 ${green}14.${plain} 一Instalar BBR (kernel mais recente)
 "
    show_status
    echo && read -p "Selecione uma opção [0-14]: " num

    case "${num}" in
        0) exit 0
        ;;
        1) check_uninstall && install
        ;;
        2) check_install && update
        ;;
        3) check_install && uninstall
        ;;
        4) check_install && reset_user
        ;;
        5) check_install && reset_config
        ;;
        6) check_install && set_port
        ;;
        7) check_install && start
        ;;
        8) check_install && stop
        ;;
        9) check_install && restart
        ;;
        10) check_install && status
        ;;
        11) check_install && show_log
        ;;
        12) check_install && enable
        ;;
        13) check_install && disable
        ;;
        14) install_bbr
        ;;
        *) echo -e "${red}Por favor insira o número correto [0-14]${plain}"
        ;;
    esac
}


if [[ $# > 0 ]]; then
    case $1 in
        "start") check_install 0 && start 0
        ;;
        "stop") check_install 0 && stop 0
        ;;
        "restart") check_install 0 && restart 0
        ;;
        "status") check_install 0 && status 0
        ;;
        "enable") check_install 0 && enable 0
        ;;
        "disable") check_install 0 && disable 0
        ;;
        "log") check_install 0 && show_log 0
        ;;
        "update") check_install 0 && update 0
        ;;
        "install") check_uninstall 0 && install 0
        ;;
        "uninstall") check_install 0 && uninstall 0
        ;;
        *) show_usage
    esac
else
    show_menu
fi
