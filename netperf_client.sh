rm -f result_file
touch result_file

#for netperf DURATION is *3 sec.
let DURATION=$(($DURATION/3))

for i in {1..${NUM_INSTANCES}}; do
	if [[ ( "${TRAFFIC_DIR}" == "TX" ) || ( "${TRAFFIC_DIR}" == "BIDI" ) ]]; then
		str1="netperf -H ${SERVER_IP1} -L ${CLIENT_IP1} -t TCP_STREAM -B outbound_port1 -i 10 -P 0 -v 0 -S 256K -l $DURATION >> result_file"
        eval $str1 &
	fi
	if [[ ( "${TRAFFIC_DIR}" == "RX" ) || ( "${TRAFFIC_DIR}" == "BIDI" ) ]]; then
		str1="netperf -H ${SERVER_IP1} -L ${CLIENT_IP1} -t TCP_MAERTS -B inbound_port1 -i 10 -P 0 -v 0 -S 256K -l $DURATION >> result_file"
        eval $str1 &
	fi
done

if [[ "${NUM_PORT}" == "DUAL" ]]; then
	for i in {1..${NUM_INSTANCES}}; do
		if [[ ("${TRAFFIC_DIR}" == "TX") || ("${TRAFFIC_DIR}" == "BIDI") ]]; then
			str1="netperf -H ${SERVER_IP2} -L ${CLIENT_IP2} -t TCP_STREAM -B outbound_port2 -i 10 -P 0 -v 0 -S 256K -l $DURATION >> result_file"
            eval $str1 &
		fi
		if [[ ("${TRAFFIC_DIR}" == "RX") || ("${TRAFFIC_DIR}" == "BIDI") ]]; then
			str1="netperf -H ${SERVER_IP2} -L ${CLIENT_IP2} -t TCP_MAERTS -B inbound_port2 -i 10 -P 0 -v 0 -S 256K -l $DURATION >> result_file"
            eval $str1 &
		fi
	done
fi

while [ `pgrep netperf | wc -l` -gt 0 ]; do
	sleep 20
done

sleep 5


echo "Done with Netperf Test"
sudo rm -f netperf_result.log

set -x
if [[ ("${TRAFFIC_DIR}" == "TX") || ("${TRAFFIC_DIR}" == "BIDI") ]]; then
	conf="outbound_port1"
    cat result_file | grep $conf | awk '{for (I=1;I<=NF;I++) if ($I == "outbound_port1") {print $(I-1)}}' > tmp
	j=0;
	while read line; do
		j=$(echo "$j+$line" | bc);
	done < tmp;
	echo $conf: $j Mb/s >> netperf_result.log
fi
if [[ ("${TRAFFIC_DIR}" == "RX") || ("${TRAFFIC_DIR}" == "BIDI") ]]; then
	conf="inbound_port1"
	cat result_file | grep $conf | awk '{for (I=1;I<=NF;I++) if ($I == "inbound_port1") {print $(I-1)}}' > tmp
    j=0;
	while read line; do
		j=$(echo "$j+$line" | bc);
	done < tmp;
	echo $conf: $j Mb/s >> netperf_result.log
fi
set +x

if [[ "${NUM_PORT}" == "DUAL" ]]; then
	if [[ ("${TRAFFIC_DIR}" == "TX") || ("${TRAFFIC_DIR}" == "BIDI") ]]; then
		conf="outbound_port2"
		cat result_file | grep $conf | awk '{for (I=1;I<=NF;I++) if ($I == "outbound_port2") {print $(I-1)}}' > tmp
		j=0;
		while read line; do
			j=$(echo "$j+$line" | bc);
		done < tmp;
		echo $conf: $j Mb/s >> netperf_result.log
	fi
	if [[ ("${TRAFFIC_DIR}" == "RX") || ("${TRAFFIC_DIR}" == "BIDI") ]]; then
		conf="inbound_port2"
		cat result_file | grep $conf | awk '{for (I=1;I<=NF;I++) if ($I == "inbound_port2") {print $(I-1)}}' > tmp
		j=0;
		while read line; do
			j=$(echo "$j+$line" | bc);
		done < tmp;
		echo $conf: $j Mb/s >> netperf_result.log
	fi
fi

rm -f tmp
