#!/bin/bash 
export JAVA_HOME=/usr/lib/jvm/java-6-sun
# optional args
G=$1
H=$2
XMLSECTOOLDIR="/usr/local/tools/xmlsectool-1.1.5"
SIGNCERT="/usr/local/metadata-signer-cert/metadata-signer.crt"
SIGNKEY="/usr/local/metadata-signer-cert/metadata-signer.key"
SIGNPASS="YOUR_STRONG_PASS_FOR_PRV_KEY"
RR3_PATH="/usr/local/www-sites/rr3"
RR3_URL="https://YOUR_SITE/rr3_path/tools/sync_metadata/metadataslist";
Y=`tempfile`
cd ${XMLSECTOOLDIR}
if [ $G == "provider" ]; then
 wget --no-check-certificate -O ${Y} ${RR3_URL}/${H}
else
 wget --no-check-certificate -O ${Y} ${RR3_URL}
fi
  for i in `cat ${Y}`; do
    group=`echo $i|awk -F ";" '{ print $1 }'|tr -d ' '`
    name=`echo $i|awk -F ";" '{ print $2 }'|tr -d ' '`
    srcurl=`echo $i|awk -F ";" '{ print $3 }'|tr -d ' '`

    #tempofileoutput="/tmp/${name}"
    dstoutput="/opt/mware-shared/www-sites/webapps/rr3/signedmetadata/${group}/${name}"
    if [ ! -d "/opt/mware-shared/www-sites/webapps/rr3" ]; then
       exit 3
    fi
    if [ ! -d "$dstoutput" ]; then
       mkdir -p $dstoutput
    fi
    ${XMLSECTOOLDIR}/xmlsectool.sh --sign --certificate ${SIGNCERT} --key ${SIGNKEY} --keyPassword ${SIGNPASS} \
      --outFile ${dstoutput}/metadata.xml --inUrl ${srcurl}
  done
  rm ${Y}