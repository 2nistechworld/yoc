#!/bin/bash
YOC_CLI=/usr/local/bin/yoc
##Check if YOC Already installed
if [ -f "$YOC_CLI" ]; then
  whiptail --title "YOC Installation" --yesno "Do you want to delete YOC and all containers datas?" 8 78
    if [[ $? -eq 0 ]]; then
      YOC_FOLDER=$(grep "YOC_FOLDER=" $YOC_CLI | cut -d "=" -f2 )
      yoc stop
      yoc delete
      rm -rf $YOC_FOLDER
      rm $YOC_CLI
      whiptail --title "YOC Installation" --msgbox "YOC successfuly uninstalled" 8 78
      exit 0
    elif [[ $? -eq 1 ]]; then 
      whiptail --title "YOC Installation" --msgbox "Uninstall canceled." 8 78
      exit 0          
    elif [[ $? -eq 255 ]]; then 
      whiptail --title "YOC Installation" --msgbox "User pressed ESC. Exiting the script" 8 78 
      exit 0
    fi
else
  whiptail --title "YOC Installation" --msgbox "YOC is not installed." 8 78
  exit 0  
fi