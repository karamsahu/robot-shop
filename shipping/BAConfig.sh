#!/bin/bash
# BAConfig.sh
# Usage: ./BAConfig.sh username applicationname agenthomedir
#
# This script creates the application in AXA based on provided input, uses 
# the application name to configure basnippet file and enables auto snippet 
# injection in bundle.properties.
#
# The Browser Agent lets you monitor web page load performance metrics and events.
# In order for Browser Agent to monitor, it requires a valid 'Application' must be 
# provided from 'App Experience Analytics' (AXA).
# How to obtain this?
#  1. Login to AXA UI. 
#  2. Locate your app by clicking on Manage Apps.
#  3. Click on your App.
#  4. Click on WEB APP.
#  5. Extract the information as shown above and enter on the prompts accordingly.
#  
# AXA APP_ID ==> App Id from AXA Snippet, example: ${txtgreen}myapp${txtrst}
#  <script type=\"text/javascript\" id=\"ca_eum_ba\" agent=browser src=\"http://apm-axa-integration:9080/mdo/v1/sdks/browser/BA.js\"
#  data-profileUrl=\"http://apm-axa-integration:7081/api/1/urn:ca:tenantId:C8215398-4D0D-7A47-D1ED-77FD4B6C635C/urn:ca:appId:appZ/profile?agent=browser\"
#  data-tenantID=\"C8215398-4D0D-7A47-D1ED-77FD4B6C635C\" data-appID=\"${txtgreen}myapp${txtrst}\" data-appKey=\"b4bf86a0-2a15-11e7-a3b9-23fb4b927f7f\" ></script>
#
# Copyright (c) 2017 CA - All rights reserved
# Created 08/06/2017 

txtrst=$(tput sgr0) # Text reset
txtgreen=$(tput setaf 2) # green
txtcyan=$(tput setaf 6) # Cyan
txtred=$(tput setaf 1) # red

# Explain correct usage
script_usage()
{
    echo "Creates the application in AXA (CA App Experience Analytics), uses the application name" 
    echo "to configure basnippet file and enables auto snippet injection in bundle.properties"
    echo
    echo "Usage: $0 username application-name agent-dir"
    echo "  username  - DXI Username"
    echo "  application-name  - Application name"
    echo "  agent-dir(optional) - agent home directory, the default value is current directory"
    echo
    echo "Example: [myuser@myhost:/Introscope] ./BAConfig.sh usr@mail.com myaxaapp /opt/myagent"
    exit 1
}

check_curl() {
    if ! hash "curl" 2>/dev/null; then
        echo "curl command is not available. Please install it."
		exit 4
    fi
}

urlencode() {
    # urlencode <string>
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

# Update <Agent_Home>\wily\extensions\browser-agent-ext-<version>\default.basnippet to use the App Experience Analytics snippet 
# from the App Experience Analytics instance that is associated with the Application Performance Management instance you are using.
update_snippet()
{
  if [ ! -e "$BA_EXT_DIR_PATH/default.basnippet" ]; then
    echo $BA_EXT_DIR_PATH/default.basnippet does not exist.
    exit 6   
  fi

  echo "APP_ID : $AXA_APP_ID"
  echo "TENANT_ID : $COHORT_GUID"
  
  AXA_SNIPPET="<script type=\"text/javascript\" id=\"ca_eum_ba\" agent=browser src=\"https://cloud.ca.com/mdo/v1/sdks/browser/BA.js\" data-profileUrl=\"https://collector-axa.cloud.ca.com/api/1/urn:ca:tenantId:$COHORT_GUID/urn:ca:appId:$AXA_APP_ID/profile?agent=browser\" data-tenantID=\"$COHORT_GUID\" data-appID=\"$AXA_APP_ID\" data-appKey=\"11f44e60-4c8e-11e7-b945-1337b991acf5\"></script>"
  echo "BA_SINPPET : $AXA_SNIPPET"
  echo "${txtcyan}Updating "$BA_EXT_DIR_PATH"/default.basnippet to use the created application name in AXA.${txtrst}"
  echo
	echo $AXA_SNIPPET > $BA_EXT_DIR_PATH/default.basnippet
}

# Go to <Agent_Home>\wily\extensions\browser-agent-ext-<version>\bundle.properties file.
# Enable auto snippet injection: introscope.agent.browseragent.autoInjectionEnabled=true
# Enable response decoration: introscope.agent.browseragent.response.decoration.enabled=true
update_bundle()
{
  if [ ! -e "$BA_EXT_DIR_PATH/bundle.properties" ]; then
    echo $BA_EXT_DIR_PATH/bundle.properties does not exist.
    exit 7   
  fi

  echo "${txtcyan}Updating "$BA_EXT_DIR_PATH"/bundle.properties, auto snippet injection and response decoration are enabled.${txtrst}"
  sed -i "s/introscope.agent.browseragent.autoInjectionEnabled=false/introscope.agent.browseragent.autoInjectionEnabled=true/g" $BA_EXT_DIR_PATH/bundle.properties
  sed -i "s/introscope.agent.browseragent.response.decoration.enabled=false/introscope.agent.browseragent.response.decoration.enabled=true/g" $BA_EXT_DIR_PATH/bundle.properties
}

# Go to <Agent_Home>\wily\extensions\Extensions.profile file.
# Add BA extension to introscope.agent.extensions.bundles.load
update_extension()
{
  if [ ! -e "$AGENT_EXT_DIR/Extensions.profile" ]; then
    echo $AGENT_EXT_DIR/Extensions.profile does not exist.
    exit 8   
  fi

  if grep -q "$BA_EXT_DIR_NAME" $AGENT_EXT_DIR/Extensions.profile; then
    echo Browser agent extension is already listed in the Extensions.profile.
    exit 9
  fi

  echo "${txtcyan}Updating "$AGENT_EXT_DIR"/Extensions.profile so browser agent extension will be loaded.${txtrst}"
  sed -i "s/introscope.agent.extensions.bundles.load=/introscope.agent.extensions.bundles.load="$BA_EXT_DIR_NAME",/g" $AGENT_EXT_DIR/Extensions.profile
}

if [ $# -ne 3 ]&&[ $# -ne 2 ]; then 
	script_usage 
fi

SERVER=https://cloud.ca.com
USER=$1
AXA_APP_ID=$2

while [[ $AXA_APP_ID == *[\^\~\`\!\@\#\$\%\&\*\(\)\+\=\{\}\|\\\:\;\"\'\<\,\>\.\?\/]* ]]
do
	read -p "Application name can not contain ^~\`!@#$%&*()+={}|\:;\"'<,>.?/, please enter it again: " AXA_APP_ID
done
		
if [ $# -eq 2 ];
	then
		AGENT_HOME=$PWD
		while [[ $AGENT_HOME == '' ]] || [[ ! -e "$AGENT_HOME/extensions/Extensions.profile" ]]
		do
			read -p "Agent home is missing or wrong, please enter the agent home: " AGENT_HOME
		done
	else
		AGENT_HOME=$3
fi

read -s -p "Enter password: " PASS
echo

read -p "Is the tenand id the same as the username ($USER): Y/N "  TOPT

if [ -z "$TOPT" ] || [ "$TOPT" == "Y" ]|| [ "$TOPT" == "y" ]; 
    then
	 echo "Using $USER as tenant-id"
	 echo
         COHORT=$USER
    else
   read -p "Enter the tenant id: " COHORT
fi

check_curl

cohort=`echo $COHORT | openssl enc -base64`
echo Trying to get security token using server $SERVER with username \($USER\) and tenant-id \($COHORT\)
echo
TOKEN=`curl -s  -X POST -H "Authorization: Basic $cohort" -H "Accept-Language: en_US" -d "grant_type=PASSWORD&username=$USER&password=$PASS" $SERVER/ess/security/v1/token |  grep "\"tkn" | awk -F\" '{print $4}'`

if [ -z "$TOKEN" ]; then
    echo No security token available. Please check server availability or input parameters for username, tenant-id, password.
    exit 2
fi

ENC_AUTHZ=`echo \{\"tkn\":\"$TOKEN\",\"t\":\"$COHORT\"\}    | openssl enc -base64 -A`
echo 'ENC_AUTHZ' $ENC_AUTHZ

URL=$SERVER/mdo/v2/apps

COHORT_GUID=`curl -s  -X POST -H "Authorization: Basic $cohort" -H "Accept-Language: en_US" -d "grant_type=PASSWORD&username=$USER&password=$PASS" $SERVER/ess/security/v1/token | grep "\"userCohort" | awk -F\" '{print $4}'`

echo
echo Creating application $AXA_APP_ID in AXA
echo curl -s  -H "Authorization: Bearer $ENC_AUTHZ" $URL_CU_PROFILE
# curl -X GET  $URL  -H "Authorization: Bearer $ENC_AUTHZ" --header "Content-Type:application/json" 
echo

RESP=`curl -s -H "Authorization: Bearer $ENC_AUTHZ" --header "Content-Type:application/json" -X POST -i --data '{"appId":"'$AXA_APP_ID'","secure":false,"attachProfile":true}' -w "%{http_code}" $URL`
echo

if [ $? -ne 0 ]; then
    echo Could not create the application $AXA_APP_ID. Please check input parameters or server availability.
    exit 3
else
    STATUS=`echo $RESP | head -n 1 | cut -d$' ' -f2`
    if [ $STATUS -ge 200 ] && [ $STATUS -lt 300 ]; then
         echo "${txtcyan}Application $AXA_APP_ID successfully created.${txtrst}"
      else
        echo The application $AXA_APP_ID is already created. Going ahead with configuring the agent.
    fi
fi

WILY_EXT=extensions
AGENT_EXT_DIR="$AGENT_HOME/$WILY_EXT"
AGENT_EXT_DEPLOY_DIR="$AGENT_HOME/$WILY_EXT/deploy"
echo
echo "AGENT_HOME: $AGENT_HOME"
echo "AGENT_EXT_DEPLOY_DIR: $AGENT_EXT_DEPLOY_DIR"
echo "APPLICATION: $AXA_APP_ID"
echo

if [ ! -d "$AGENT_EXT_DEPLOY_DIR" ]; then
  echo $AGENT_EXT_DEPLOY_DIR directory does not exist. Please check input agenthomedir.
  exit 5   
fi

cd $AGENT_EXT_DEPLOY_DIR
#echo "cd $PWD"

#ls $AGENT_EXT_DEPLOY_DIR/browser-agent-ext-*
echo
BA_EXT_NAME=$(find browser-agent-ext-*)
BA_EXT_DIR_NAME="${BA_EXT_NAME%.*.*}"
BA_EXT_DIR_PATH="$AGENT_HOME/$WILY_EXT/$BA_EXT_DIR_NAME"

if [ -d "$BA_EXT_DIR_PATH" ]; then
	echo $BA_EXT_DIR_PATH directory already exists. Going ahead with configuring the agent properties.
	echo
  else
	mkdir -p $BA_EXT_DIR_PATH
	echo "Extracting..... $BA_EXT_NAME to $BA_EXT_DIR_PATH"  
	tar -xzf $BA_EXT_NAME -C $BA_EXT_DIR_PATH
	echo
fi

update_snippet
update_bundle
update_extension

echo "Complete!"
echo
