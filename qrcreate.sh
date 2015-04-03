#!/bin/bash


# qrencode app
qr=qrencode

if ! hash $qr 2>/dev/null; then
  echo "qrencode not found"
  echo "please install it"
  exit 2
fi

# Defaults

# qrencode error correction level
# L — lowest
# M
# Q
# H — highest
error_correction_level="L"

# QR image margin
margin="4"

# Output file type
filetype="EPS"

# Output file name
outfile="Output.${filetype,,}"

# Case senitive?
casesens=true

# Functions

function qrsend {
  if [[ $casesens ]]; then 
    case="--casesensitive"
  else
    case="--ignorecase"
  fi
  ${qr} --level=${error_correction_level} --symversion=auto -t ${filetype} --margin=${margin} ${case} -o ${2} "${1}"
}

function email {
  echo "Please, enter email address and press ENTER"
  read email_address
  qrsend "mailto:${email_address}" $1
  exit 0
}

function contact {

  MECARD="MECARD:"

  echo "Please, enter contact name, or several names, devided by ';' symbol, or just press ENTER for pass"
  read contact_name
  PREV_IFS=$IFS # Save previous IFS
  IFS=';' contact_names=($contact_name)
  IFS=$PREV_IFS # Restore IFS
  if [[ ${#contact_names[@]} -gt 0 ]]; then
    for record in "${contact_names[@]}"; do
      MECARD="${MECARD}N:${record};"
    done
  fi

  echo "Please, enter phone number, or several numbers, devided by ';' symbol, or just press ENTER for pass"
  read contact_phone
  PREV_IFS=$IFS # Save previous IFS
  IFS=';' contact_phones=($contact_phone)
  IFS=$PREV_IFS # Restore IFS
  if [[ ${#contact_phones[@]} -gt 0 ]]; then
    for record in "${contact_phones[@]}"; do
      MECARD="${MECARD}TEL:${record};"
    done
  fi

  echo "Please, enter URL, or several urls, devided by ';' symbol, or just press ENTER for pass"
  read contact_url
  PREV_IFS=$IFS # Save previous IFS
  IFS=';' contact_urls=($contact_url)
  IFS=$PREV_IFS # Restore IFS
  if [[ ${#contact_urls[@]} -gt 0 ]]; then
    for record in "${contact_urls[@]}"; do
      MECARD="${MECARD}URL:${record};"
    done
  fi

  echo "Please, enter email address, or several addresses, devided by ';' symbol, or just press ENTER for pass"
  read contact_email
  PREV_IFS=$IFS # Save previous IFS
  IFS=';' contact_emails=($contact_email)
  IFS=$PREV_IFS # Restore IFS
  if [[ ${#contact_emails[@]} -gt 0 ]]; then
    for record in "${contact_emails[@]}"; do
      MECARD="${MECARD}EMAIL:${record};"
    done
  fi

  echo "Please, enter contact address, or several addresses, devided by ';' symbol, or just press ENTER for pass"
  read contact_address
  PREV_IFS=$IFS # Save previous IFS
  IFS=';' contact_addresses=($contact_address)
  IFS=$PREV_IFS # Restore IFS
  if [[ ${#contact_addresses[@]} -gt 0 ]]; then
    for record in "${contact_addresses[@]}"; do
      MECARD="${MECARD}ADR:${record};"
    done
  fi

  echo "Please, enter some notes, if you wish, and yes, you can devide them by ';' symbol, or just press ENTER for pass"
  read contact_note
  PREV_IFS=$IFS # Save previous IFS
  IFS=';' contact_notes=($contact_note)
  IFS=$PREV_IFS # Restore IFS
  if [[ ${#contact_notes[@]} -gt 0 ]]; then
    for record in "${contact_notes[@]}"; do
      MECARD="${MECARD}NOTE:${record};"
    done
  fi

  MECARD="${MECARD};"

  qrsend "${MECARD}" $1
  exit 0
}

function coord {

  echo "Enter latitude XX.YY…:"
  read coord_lat
  echo "Enter longitude ZZ.FF…"
  read coord_long
  echo "Enter altitude (or just press ENTER to pass it)"
  read coord_alt

  geo="geo:${coord_lat},${coord_long}"
  if [[ $coord_alt ]]; then
    geo="${geo},${coord_alt}"
  fi

  qrsend "${geo}" $1
  
  exit 0
}

function phone {
  echo "Enter phone number"
  read phone_tel
  tel="tel:${phone_tel}"

  qrsend "${tel}" $1
  exit 0
}

function sms {
  echo "Enter phone number"
  read sms_phone
  echo "Enter text message"
  read sms_message
  sms="smsto:${sms_phone}:${sms_message}"

  qrsend "${sms}" $1
  exit 0
}

function text {
  echo "Enter your text"
  read text
  qrsend "${text}" $1
  exit 0
}

function wifi {
  echo "Plesae enter a digit, representing your WiFi Encription method:"
  echo "1 if it's WEP encrypted"
  echo "2 if it's WPA encrypted"
  echo "something different from 1 or 2 if it's not encrypted at all"
  read wifi_enription

  case $wifi_enription in
    1 )
      wifi_enc='WEP'
      ;;
    2)
      wifi_enc='WPA'
      ;;
    *)
      wifi_enc='nopass'
      ;;
  esac

  wifi="WIFI:T:${wifi_enc};"

  echo "Enter your network SSID"
  read wifi_ssid

  wifi="${wifi}S:${wifi_ssid};"

  if [[ $wifi_enc != 'nopass' ]]; then
    echo "Enter your network PSK (Pre Shared Key)"
    read wifi_pass
    wifi="${wifi}P:${wifi_pass};"
  fi

  echo "Is your WiFi network is hidden?"
  echo "1 — no"
  echo "2 — yes"
  read wifi_hidden
  if [[ $wifi_hidden == "2" ]]; then
    wifi="${wifi}H:true;"
  fi

  wifi="${wifi};"
  qrsend "${wifi}" $1
  exit 0
}

while getopts ":e:m:f:c" opt; do
  case $opt in
    e)
      error_correction_level=$OPTARG
      ;;
    m)
      margin=$OPTARG
      ;;
    f)
      filetype=$OPTARG
      ;;
    c)
      casesens=$OPTARG
      ;;
    o)
      outfile=$OPTARG
      ;;
    \?)
      echo "Wrong option: -$OPTARG" >&2
      echo "Correct options are:"
      echo "-e — change error correction level"
      echo "-m — set margin value in px"
      echo "-f — set output format, one of PNG,EPS,ANSI,ANSI256"
      echo "-c — set case sensivity, true — do not touch my input, false — IT WILL BE CAPS ALL OVER!"
      ;;
  esac
done

echo
echo "Hi! Generating QR-code in ${outfile}"
echo "using margin of ${margin} px"
echo "using error correction level ${error_correction_level}"
echo "using output format of ${filetype}"
echo "and case sensivity set to ${casesens}"
echo
echo "Please, choose what QR-code type you want to create:"
echo "1 — e-mail"
echo "2 — Contact card"
echo "3 — Geo Coordinates"
echo "4 — Phone number"
echo "5 — SMS"
echo "6 — Text or link"
echo "7 — WiFi"
echo
echo "press Ctrl+C for exit =)"
echo
echo
read Answer

case ${Answer} in
    1)
      email $outfile
      ;;
    2)
      contact $outfile
      ;;
    3)
      coord $outfile
      ;;
    4)
      phone $outfile
      ;;
    5)
      sms $outfile
      ;;
    6)
      text $outfile
      ;;
    7)
      wifi $outfile
      ;;
    *)
      echo "hey, can count only to 7…"
      exit 1
esac

exit 0