#!/bin/bash
system_release=$(cat /etc/os-release | grep "ID_LIKE" | cut -d "=" -f2)
clear
if [[ $system_release == "arch" ]] 
then 
    echo -e "\n\t[+] 1 - Downloaded Dependencies [+]"
    echo -e " - [1]. Hping"
    echo -e " - [2]. Nmap"
    sudo pacman -S hping nmap --ignore --needed --noconfirm

else 
    echo -e "\n\t[+] 1 - Downloaded Dependencies [+]"
    echo -e " - [1]. Hping"
    echo -e " - [2]. Nmap"
    sudo apt-get install hping* nmap -y
fi
clear
if [[ $1 == " " ]]
then
    echo -e "\t\t\t############################"
    echo -e "\t\t\t# Development: L3onT3chh   #"
    echo -e "\t\t\t# University: UTFPR        #"
    echo -e "\t\t\t# DevOps security          #"
    echo -e "\t\t\t############################"
else
    echo -e "\t     ####################################################################################"
    echo -e "\t    \t\t\t\tRealizando o parser   \t\t\t\t   "
    echo -e "        ####################################################################################"
    echo -e "\t"
    echo -e "\t     Modo de uso: ./scanner_network.sh host 'path_wordlist'"
    echo -e "\t"
    echo -e "\t     Desenvolvido por L3onT3chh"
    echo -e "\t     University Tecnology Federal of Parana - PR, Santa Helena "
    echo -e "\t####################################################################################\n\n"
    echo -e "\t Listagem de todos os subdomains: \n"    
    # Lendo todos os arquivos de subdomain
    if [[ $2 == "" ]]
    then
        echo "#    Informe a wordlist!   #"
        echo "############################"
    else
        for subDomain in $(cat $2)
        do
            sub=$subDomain.$1
            echo $sub >> .hosts
        done 

        select host in $(cat .hosts)
        do 
            clear
            wrm .hosts   
            echo -e "\tAddress selected: $host\n"
            while true
            do
                select opA in "Informações do host" "Port scanning" "SubDomains" "Anterior"
                do
                    case $opA in
                    "Informações do host")
                        echo -e "\t------------------------------------------"
                        echo "             Informações do $host"
                        echo -e "\t------------------------------------------"

                        echo -e "\n\t- Address: $host"
                        echo -e "\t- Address IP: $(dig $host +short)"
                        echo -e "\t- GeoLocation: $(geoiplookup $host | cut -d ' ' -f2,3,4,5,6)"
                        echo " "
                        break
                    ;;
                    "Port scanning")
                        echo -e "\n\t------------------------------------------"
                        echo "             PortScanning do $host"
                        echo -e "\t------------------------------------------\n"
                        
                        read -p "     Numero maximo de portas: " portsM

                        for port in $(seq 1 $portsM)
                        do
                            openPort=$(hping -S -c 1 -p $port $host 2> /dev/null | grep "flags=SA" | cut -d " " -f6 )
                            if [[ $openPort == "flags=SA" ]]
                            then
                                echo -e "   * Host $host: $(dig +short $host) with port [$port] open [+]"
                            fi
                        done
                        echo " "
                        break
                    ;;
                    "SubDomains")
                        echo -e "\t========================================"
                        echo -e "\t [+] Nova pesquisa: " $host
                        if [ $host != "" ]
                        then
                            echo -e "\t========================================"
                            echo -e "\n\tConsultando {$host}"
                            wget $host -q
                            lists=$(cat index.html | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u)
                            echo -e "\t========================================"
                            for item in $lists
                            do
                                echo $item | cut -d "/" -f3 >> .host 
                            done
                            l=$(cat .host | sort -u > .host2)
                            list=$(cat .host2)
                            for i in $list
                            do
                                target=$(host $i | head -n1 | cut -d " " -f4)
                                if [ $target != "alias" ]
                                then
                                    echo -e "\t$target\t\t$i"
                                fi
                            done
                        fi
                        echo -e "\n"
                        rm index.html .host .host2
                        break
                    ;;
                    "Anterior")
                        break
                        exit
                    ;;
                    esac
                done
            done
        done
    fi
fi