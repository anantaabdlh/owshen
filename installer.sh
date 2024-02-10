#!/bin/bash
PACKAGE_ROOT="${PACKAGE_ROOT:-"https://packages.ternoa.network/ternoa"}"
OS=""
OS_VERSION=""
TERNOA_ENV="mainnet"
TERNOA_VERSION="1.3.1"

# Detect the platform 
 if cat /etc/*release | grep ^NAME | grep CentOS; then
    echo "==============================================="
    echo "Installing ternoa validator on CentOS not available yet"
    echo "https://ternoahelp.zendesk.com/hc/en-150"
    exit 1;
  elif cat /etc/*release | grep ^NAME | grep Red; then
    echo "==============================================="
    echo "Installing ternoa validator on RedHat not available yet"
    echo "https://ternoahelp.zendesk.com/hc/en-150"
    exit 1;
 elif cat /etc/*release | grep ^NAME | grep Fedora; then
    echo "================================================"
    echo "Installing ternoa validator on Fedorea not available yet"
    echo "https://ternoahelp.zendesk.com/hc/en-150"
    exit 1;
 elif cat /etc/*release | grep ^NAME | grep Ubuntu; then
    echo "==============================================="
    echo "Installing ternoa validator on Ubuntu ..."
    OS="ubuntu"
    OS_VERSION="20.04"
 elif cat /etc/*release | grep ^NAME | grep Debian ; then
    echo "==============================================="
    echo "Installing ternoa validator on Debian ..."
    OS="debian"
    OS_VERSION="11"
 else
    echo "OS NOT DETECTED, couldn't install ternoa validator"
    echo "https://ternoahelp.zendesk.com/hc/en-150"
    exit 1;
 fi


DOWNLOAD_URL="https://packages.ternoa.network/ternoa/${TERNOA_ENV}/${OS}-${OS_VERSION}/${TERNOA_VERSION}/ternoa"
_divider="--------------------------------------------------------------------------------"
_prompt=">>>"
_indent="   "

validator_name=""
chain_name=""
cat 1>&2 <<EOF
                                  Welcome to TERNOA installer 


$_divider
Website: https://ternoa.com
Docs: https://ternoa-2.gitbook.io/ternoa-testnet-guide/
Support : https://ternoahelp.zendesk.com/hc/en-150
$_divider

EOF

echo "$_prompt We'll be installing Ternoa via a pre-built archive at ${DOWNLOAD_URL}/"


PS3='Please choose the ternoa chain environment: '
select opt in Alphanet Mainnet
do
    case $opt in
        Alphanet)
            echo "Connecting to Mainnet ...";
	    TERNOA_ENV="alphanet"; break
	;;
        Mainnet)
            echo "Connecting to Mainnet ...";
   	    TERNOA_ENV="mainnet";  break
		;;
           
        *) echo "invalid option $REPLY"; 
		exit 1 
		;;   
 esac
done

while true; do
    read -rp "Enter Your Validator Name: " validator_name  </dev/tty
    if [[ ! -z "$validator_name" ]] ; then
        break ;
    fi
done

curl $DOWNLOAD_URL > /usr/bin/ternoa
mkdir -p "/opt/ternoa/node-data"
chmod +x "/usr/bin/ternoa"

printf "\n"



tee /etc/systemd/system/ternoa.service > /dev/null <<EOT
[Unit]
Description=Ternoa Validator Node By Ternoa.com

[Service]

ExecStart=/usr/bin/ternoa --chain ${TERNOA_ENV}  --base-path /opt/ternoa/node-data --name ${validator_name} --telemetry-url "wss://telemetry.polkadot.io/submit/ 0" --validator --state-cache-size 0 --execution wasm --port 10333 --rpc-port 1144
WorkingDirectory=/usr/bin
KillSignal=SIGINT
Restart=on-failure
LimitNOFILE=10240
SyslogIdentifier=ternoa


[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable ternoa
systemctl start ternoa


printf "%s Install succeeded!\n" "$_prompt"
printf "\n"
printf "%s You can restart ternoa service using : systemctl restart ternoa\n"
printf "%s You can get the status of ternoa service using : systemctl status ternoa\n"
printf "%s You can stop ternoa service using : systemctl stop ternoa\n"
printf "\n"
printf "%s More information at https://ternoa-2.gitbook.io/ternoa-testnet-guide/\n" "$_prompt"
