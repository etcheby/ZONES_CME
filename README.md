# Credits to Christian Castillo - Cloud Architect from Check Point LATAM - who helped develop this script -

CME Custom Script used in Check Point ASG/MIG/VMSS deployments to automatically assign eth0 interface to a Security-Zone "External" 
"External" is a custom name but could be any other defined Security Zone of your choice  
Automates Configuration of all Checkpoint autoscaling deployment with assignment of eth0 to security-zone. 

# ------- Not supported in production -------
 


# Instructions.

1- First copy the bash script into the management server directory of your choice.

# curl_cli -k https://url/of/raw -O .sh


2- Provide exectuable permissions to let the admin execute the script.
# chmod +x .sh

3- Now you need to enable the file to be used as custom script on the CME. 

# autoprov-cfg set management -cs /path/to/.bash

4-Enable the parameter to launch the script, in this case the bash is looking for "ZONE" to be trigger

# autoprov-cfg set template -tn "your_CME_template_name" -cp ZONE
Above command will trigger the custom script everytime gateway belonging to CME configuration template is autoprovisionned.

**NOTE a script variable called POLICY_PACKAGE_NAME= needs to be map policy_name defined with CME -po flag of the configuration template. 
It's case sensitive and script will fail if wrong policy name entered. 
