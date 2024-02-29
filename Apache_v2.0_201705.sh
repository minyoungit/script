#!/bin/bash

#Programmer : KIITS
#Test OS : CentOS 6.5
#Date : 2016.01
#Version : 2.0
#Comment : Linux Server + Apache

LANG=C
export LANG

# Apache

echo ""
echo ""


IP=`ifconfig -a | grep  "inet addr" | head -1 | awk '{print $2}' | awk -F: '{print $2}'`


RESULT_FILE=./Apache@@`hostname`@@$IP.txt


# Apache 설정파일 입력

echo "Input a apache main configuration file. (ex. /usr/local/httpd/conf/httpd.conf)"
while true
do 
	echo -n "Input path : " 
	read HTTP_CONF_INP
	if [ "$HTTP_CONF_INP" ]
		then
			if [ -f "$HTTP_CONF_INP" ]
				then 
					break
				else
					echo "Wrong path. Please retry."
					echo " "
			fi
	elif [ -z "$HTTP_CONF_INP"]
		then
			break
	else
		echo "Wrong path. Please retry."
		echo " "
	fi
done
echo " "

# Apache 홈 확인

HTTP_ROOT=`grep -i "ServerRoot" $HTTP_CONF_INP | grep -v "#" | head -1 | awk -F\" '{print $2}'`
HTTP_DOC_ROOT=`grep -i "DocumentRoot" $HTTP_CONF_INP | grep -v "#" | head -1 | awk -F\" '{print $2}'`

# Apache 추가 설정 파일 확인

if [ `grep -i "^Include" $HTTP_CONF_INP | grep -v "#" | wc -l` -eq 0 ]
	then
		cat $HTTP_CONF_INP > http_conf.txt
	else
		cat $HTTP_CONF_INP > http_conf.txt
		for a in `grep -i "^Include" $HTTP_CONF_INP | grep -v "#" | awk '{print $2}'`
			do 
				cat $HTTP_ROOT/$a >> http_conf.txt 
		done
fi

HTTP_CONF=./http_conf.txt


# 타이틀
echo "===============  Apache Security Check  ===============" > $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo "Copyright (c) 2016 KIITS Co. Ltd. All right Reserved" >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1

echo ""
echo "============================== START ==============================" 
echo ""

# [WA-1] Apache 디렉토리 리스팅 제거
echo "[WA-1] Apache 디렉토리 리스팅 제거"
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[WA-1] Apache 디렉토리 리스팅 제거"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo [1-START] >> $RESULT_FILE 2>&1
if [ `grep -w "Indexes" $HTTP_CONF_INP | grep -v "#" | wc -l` -eq 0 ]
	then
		echo "★ Indexes 옵션이 존재하지 않음" >> $RESULT_FILE 2>&1
		echo [1-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-1]Result : GOOD >> $RESULT_FILE 2>&1
	else
		echo "★ Indexes 옵션이 존재함" >> $RESULT_FILE 2>&1
		echo "[현황]" >> $RESULT_FILE 2>&1
		grep -inw "Indexes" $HTTP_CONF_INP | grep -v "#" >> $RESULT_FILE 2>&1
		echo [1-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-1]Result : VULNERABLE >> $RESULT_FILE 2>&1
fi
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1


# [WA-2] Apache 웹 프로세스 권한 제한
echo "[WA-2] Apache 웹 프로세스 권한 제한"
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[WA-2] Apache 웹 프로세스 권한 제한"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo [2-START] >> $RESULT_FILE 2>&1
egrep -in "^User" $HTTP_CONF > tmp_2.txt
egrep -in "^Group" $HTTP_CONF >> tmp_2.txt
if [ `cat tmp_2.txt | grep -w "root" | wc -l` -eq 0 ]
	then
		echo "★ Apache 구동 계정이 root가 아닌 일반 계정임" >> $RESULT_FILE 2>&1
		echo "[현황]" >> $RESULT_FILE 2>&1
		cat tmp_2.txt >> $RESULT_FILE 2>&1
		echo [2-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-2]Result : GOOD >> $RESULT_FILE 2>&1
	else
		echo "★ Apache 데몬이 root 계정으로 구동됨" >> $RESULT_FILE 2>&1
		echo "[현황]" >> $RESULT_FILE 2>&1
		cat tmp_2.txt >> $RESULT_FILE 2>&1
		echo [2-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-2]Result : VULNERABLE >> $RESULT_FILE 2>&1
fi
rm -rf tmp_2.txt
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1



# [WA-3] Apache 상위 디렉토리 접근 금지
echo "[WA-3] Apache 상위 디렉토리 접근 금지"
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[WA-3] Apache 상위 디렉토리 접근 금지"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo [3-START] >> $RESULT_FILE 2>&1
grep -win "AllowOverride" $HTTP_CONF | grep -v "#" > tmp_3.txt
if [ `cat tmp_3.txt | wc -l` -eq 0 ]
	then
		echo "★ AllowOverride 설정이 존재하지 않음" >> $RESULT_FILE 2>&1
		echo [3-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-3]Result : VULNERABLE >> $RESULT_FILE 2>&1
	else
		if [ `cat tmp_3.txt | grep -wi "None" | wc -l` -eq 0 ]
			then
				echo "★ AllowOverride None 설정이 존재하지 않음" >> $RESULT_FILE 2>&1
				echo "[현황]" >> $RESULT_FILE 2>&1
				cat tmp_3.txt >> $RESULT_FILE 2>&1
				echo [3-END] >> $RESULT_FILE 2>&1
				echo >> $RESULT_FILE 2>&1
				echo [WA-3]Result : GOOD >> $RESULT_FILE 2>&1
			else
				echo "★ AllowOverride None 설정이 존재함" >> $RESULT_FILE 2>&1
				echo "[현황]" >> $RESULT_FILE 2>&1
				cat tmp_3.txt >> $RESULT_FILE 2>&1
				echo [3-END] >> $RESULT_FILE 2>&1
				echo >> $RESULT_FILE 2>&1
				echo [WA-3]Result : VULNERABLE >> $RESULT_FILE 2>&1
		fi
fi
rm -rf tmp_3.txt
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1



# [WA-4] Apache 불필요한 파일 제거
echo "[WA-4] Apache 불필요한 파일 제거"
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[WA-4] Apache 불필요한 파일 제거"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo [4-START] >> $RESULT_FILE 2>&1
if [ `ls -ld $HTTP_ROOT/manual | wc -l` -eq 0 ]
	then
		if [ `ls -ld $HTTP_DOC_ROOT/manual | wc -l` -eq 0 ]
			then
				echo "★ 불필요한 manual 파일이 존재하지 않음" >> $RESULT_FILE 2>&1
				echo [4-END] >> $RESULT_FILE 2>&1
				echo >> $RESULT_FILE 2>&1
				echo [WA-4]Result : GOOD >> $RESULT_FILE 2>&1
			else
				echo "★ 불필요한 manual 파일이 존재함" >> $RESULT_FILE 2>&1
				echo "[현황]" >> $RESULT_FILE 2>&1
				ls -ld $HTTP_DOC_ROOT/manual >> $RESULT_FILE 2>&1
				echo [4-END] >> $RESULT_FILE 2>&1
				echo >> $RESULT_FILE 2>&1
				echo [WA-4]Result : VULNERABLE >> $RESULT_FILE 2>&1
		fi
	else
		echo "★ 불필요한 manual 파일이 존재함" >> $RESULT_FILE 2>&1
		echo "[현황]" >> $RESULT_FILE 2>&1
		ls -ld $HTTP_ROOT/manual >> $RESULT_FILE 2>&1
		echo [4-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-4]Result : VULNERABLE >> $RESULT_FILE 2>&1
fi
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1



# [WA-5] Apache 링크 사용금지
echo "[WA-5] Apache 링크 사용금지"
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[WA-5] Apache 링크 사용금지"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo [5-START] >> $RESULT_FILE 2>&1
if [ `grep -wi "FollowSymLinks" $HTTP_CONF_INP | grep -v "#" | wc -l` -eq 0 ]
	then
		echo "★ FollowSymLinks 옵션이 존재하지 않음" >> $RESULT_FILE 2>&1
		echo [5-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-5]Result : GOOD >> $RESULT_FILE 2>&1
	else
		echo "★ FollowSymLinks 옵션이 존재함" >> $RESULT_FILE 2>&1
		echo "[현황]" >> $RESULT_FILE 2>&1
		grep -inw "FollowSymLinks" $HTTP_CONF_INP | grep -v "#" >> $RESULT_FILE 2>&1
		echo [5-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-5]Result : VULNERABLE >> $RESULT_FILE 2>&1
fi
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1



# [WA-6] Apache 파일 업로드 및 다운로드 제한
echo "[WA-6] Apache 파일 업로드 및 다운로드 제한"
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[WA-6] Apache 파일 업로드 및 다운로드 제한"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo [6-START] >> $RESULT_FILE 2>&1
if [ `grep -wi "LimitRequestBody" $HTTP_CONF | grep -v "#" | wc -l` -eq 0 ]
	then
		echo "★ LimitRequestBody 옵션이 존재하지 않음" >> $RESULT_FILE 2>&1
		echo [6-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-6]Result : VULNERABLE >> $RESULT_FILE 2>&1
	else
		echo "★ LimitRequestBody 옵션이 존재함" >> $RESULT_FILE 2>&1
		echo "[현황]" >> $RESULT_FILE 2>&1
		grep -inw "LimitRequestBody" $HTTP_CONF | grep -v "#" >> $RESULT_FILE 2>&1
		echo [6-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-6]Result : GOOD >> $RESULT_FILE 2>&1
fi
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1



# [WA-7] Apache 웹 서비스 영역의 분리
echo "[WA-7] Apache 웹 서비스 영역의 분리"
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[WA-7] Apache 웹 서비스 영역의 분리"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo [7-START] >> $RESULT_FILE 2>&1
if [ `echo $HTTP_DOC_ROOT | egrep -w "/usr/local/apache/htdocs|/var/www/html" | wc -l` -eq 0 ]
	then
		echo "★ DocumentRoot로 기본경로를 사용하지 않음" >> $RESULT_FILE 2>&1
		echo "[현황]" >> $RESULT_FILE 2>&1
		echo $HTTP_DOC_ROOT >> $RESULT_FILE 2>&1
		echo [7-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-7]Result : GOOD >> $RESULT_FILE 2>&1
	else
		echo "★ DocumentRoot로 기본경로를 사용함" >> $RESULT_FILE 2>&1
		echo "[현황]" >> $RESULT_FILE 2>&1
		echo $HTTP_DOC_ROOT >> $RESULT_FILE 2>&1
		echo [7-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-7]Result : VULNERABLE >> $RESULT_FILE 2>&1
fi
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1



# [WA-8] Apache 웹 서비스 정보 숨김
echo "[WA-8] Apache 웹 서비스 정보 숨김"
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[WA-8] Apache 웹 서비스 정보 숨김"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo [8-START] >> $RESULT_FILE 2>&1
if [ `grep -wi "servertokens" $HTTP_CONF | grep -v "#" | wc -l` -eq 0 ]
	then
		echo "★ ServerTokens 옵션이 존재하지 않음" >> $RESULT_FILE 2>&1
		echo [8-END] >> $RESULT_FILE 2>&1
		echo >> $RESULT_FILE 2>&1
		echo [WA-8]Result : VULNERABLE >> $RESULT_FILE 2>&1
	else
		if [ `grep -wi "servertokens" $HTTP_CONF | grep -v "#" | grep -wi "prod" | wc -l` -eq 0 ]
			then
				echo "★ ServerTokens 옵션이 Prod로 설정되지 않음" >> $RESULT_FILE 2>&1
				echo [8-END] >> $RESULT_FILE 2>&1
				echo "[현황]" >> $RESULT_FILE 2>&1
				grep -wi "servertokens" $HTTP_CONF | grep -v "#" >> $RESULT_FILE 2>&1
				echo >> $RESULT_FILE 2>&1
				echo [WA-8]Result : VULNERABLE >> $RESULT_FILE 2>&1
			else
				echo "★ ServerTokens 옵션이 Prod로 설정됨" >> $RESULT_FILE 2>&1
				echo [8-END] >> $RESULT_FILE 2>&1
				echo "[현황]" >> $RESULT_FILE 2>&1
				grep -wi "servertokens" $HTTP_CONF | grep -v "#" >> $RESULT_FILE 2>&1
				echo >> $RESULT_FILE 2>&1
				echo [WA-8]Result : GOOD >> $RESULT_FILE 2>&1
		fi
fi
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1



echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo "[ HTTP CONF ]"  >> $RESULT_FILE 2>&1
echo "=======================================================================" 	>> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
cat -n $HTTP_CONF >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1


echo "============================================================" >> $RESULT_FILE 2>&1
echo "[ Version ]"  >> $RESULT_FILE 2>&1
echo "============================================================" >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
uname -a >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
cat /etc/issue >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1


echo "============================================================" >> $RESULT_FILE 2>&1
echo "[ Interface ]"  >> $RESULT_FILE 2>&1
echo "============================================================" >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
ifconfig -a >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1


echo "============================================================" >> $RESULT_FILE 2>&1
echo "[ Daemon ]"  >> $RESULT_FILE 2>&1
echo "============================================================" >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo "1) ps -ef" >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
ps -ef >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo "2) chkconfig --list" >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
chkconfig --list >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1
echo >> $RESULT_FILE 2>&1


echo ""
echo "============================== END ==============================" 




# 임시 파일 삭제
rm -rf ./http_conf.txt

unset HTTP_ROOT
unset HTTP_CONF_INP
unset HTTP_CONF
unset HTTP_DOC_ROOT


exit;

esac






