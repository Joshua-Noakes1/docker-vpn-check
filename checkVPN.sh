# Check if VPN is dead
echo [Info] Finding names
checkNameXTeVe=$(curl -s "https://hyouta.joshuanoakes.co.uk/api/main"| jq -r '.checks[6].name')
if [ "$checkNameXTeVe" != "XTeVe" ]
then
    echo $(tput setaf 1)[Error] Can\'t find check for XTeVe
    tput sgr0 # reset console color
    exit
fi

echo [Info] Getting XTeve Status
checkStatusXTeVe=$(curl -s "https://hyouta.joshuanoakes.co.uk/api/main"| jq -r '.checks[6].success')
if [ "$checkStatusXTeVe" == "false" ]
then # XTeVe down
    echo $(tput setaf 1)[Fail] Check Failed
    echo $(tput setaf 3)[Info] Possilbe VPN stack crash checking other containers
    tput sgr0 # reset console color
    checkNameProwlarr=$(curl -s "https://hyouta.joshuanoakes.co.uk/api/main"| jq -r '.checks[7].name')
    if (( "$checkNameProwlarr" != "Prowlarr" ))
    then
        echo $(tput setaf 1)[Info] Can\'t find check for Prowlarr
        exit
    else
        echo [Info] Checking Prowlarr status
        checkStatusProwlarr=$(curl -s "https://hyouta.joshuanoakes.co.uk/api/main"| jq -r '.checks[7].success')
        if (( "$checkStatusProwlarr" == "false" ))
        then # VPN Stack is down
            echo $(tput setaf 1)[Fail] Check Failed
            echo [Fail] Assuming VPN stack is down, trying reset
            tput sgr0 # reset console color
            cd /home/infinity/docker/VPN
            docker-compose down
            sleep 2
            docker-compose up -d
            echo $(tput setaf 3)[Info] Attempted reset on VPN Stack
            tput sgr0 # reset console color
            exit
        else # Prowlar is up, XTeVe is down
            echo $(tput setaf 2)[Success] VPN stack isn\'t down
            tput sgr0 # reset console color
            exit
        fi
    fi
    exit
else
    echo $(tput setaf 2)[Success] VPN stack isn\'t down
    tput sgr0 # reset console color
    exit
fi