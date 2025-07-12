#!/bin/bash

usage() {
	echo "사용법: $0 <IP 목록 파일 경로>"
	echo "예시: $0 path/to/ip_list.txt"
	exit 1
}

if [ $# -ne 1 ]; then
	usage
fi


# ansible target nodes IP 목록
IP_LIST="$1"

USER="netai"

SSH_KEY="$HOME/.ssh/id_rsa"

# 1. SSH 키가 없는 경우 생성
if [ ! -f "$SSH_KEY" ]; then
   	echo "[+] SSH 키가 존재하지 않습니다. 새로 생성합니다."
    	ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N ""
else
    	echo "[+] 기존 SSH 키가 존재합니다. 그대로 사용합니다."
fi

# 2. IP 리스트 확인
if [ ! -f "$IP_LIST" ]; then
	echo "[!] $IP_LIST 파일이 없습니다. IP 주소를 한 줄씩 입력한 파일을 만들어 주세요."
    	exit 1
fi

# 3. 각 IP에 SSH 키 배포
while IFS= read -r IP; do
	echo "[+] $IP에 SSH 키 복사 중..."
	ssh-copy-id -i "$SSH_KEY.pub" "$USER@$IP"
	if [ $? -eq 0 ]; then
        	echo "[✅] $IP에 SSH 키 배포 완료"
    	else
        	echo "[❌] $IP에 SSH 키 배포 실패"
    	fi
done < "$IP_LIST"

echo "모든 IP에 SSH 키 배포 완료!"
