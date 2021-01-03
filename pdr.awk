BEGIN {
        sendLine = 0;
        recvLine = 0;
        fowardLine = 0;
	TC =0;
	rt_pkts = 0;
	rt_s = 0;
	rt_f = 0;
	rreq = 0;
	rreqs = 0;
	rreqf = 0;
	rrep = 0;
	rreps = 0;
	rrepf = 0;
}

$0 ~/^s.* AGT/ {
        sendLine ++ ;
}

$0 ~/^r.* AGT/ {
        recvLine ++ ;
}

$0 ~/^f.* RTR/ {
        fowardLine ++ ;
}

$0 ~/^s.* \[TC / {
        TC ++ ;
}



{  
	if($4 == "AGT" && $1 == "s" && seqno < $6) {

          seqno = $6;

	} 
	#end-to-end delay

	    if($4 == "AGT" && $1 == "s") {

		  start_time[$6] = $2;

	    } else if(($7 == "cbr") && ($1 == "r")) {

		end_time[$6] = $2;

	    } else if($1 == "D" && $7 == "cbr") {

		  end_time[$6] = -1;

	    } else if (($1 == "s" || $1 == "f") && ($4 == "RTR") && ($7 == "DSR")) {
    		
		  rt_pkts++;

	    } if (($1 == "s") && ($4 == "RTR") && ($7 == "DSR")) {
    		
		  rt_s++;

	    } if (($1 == "f") && ($4 == "RTR") && ($7 == "DSR")) {
    		
		  rt_f++;

	    } if (($1 == "s" || $1 == "f") && ($4 == "RTR") && ($7 == "DSR") && ($19 == "[1")) {
    		
		  rreq++;

	    } if (($1 == "s") && ($4 == "RTR") && ($7 == "DSR") && ($19 == "[1")) {
    		
		  rreqs++;

	    } if (($1 == "f") && ($4 == "RTR") && ($7 == "DSR") ($19 == "[1")) {
    		
		  rreqf++;

	    } if (($1 == "s" || $1 == "f") && ($4 == "RTR") && ($7 == "DSR") && ($21 == "[1")) {
    		
		  rrep++;

	    } if (($1 == "s") && ($4 == "RTR") && ($7 == "DSR") && ($21 == "[1")) {
    		
		  rreps++;

	    } if (($1 == "f") && ($4 == "RTR") && ($7 == "DSR") ($21 == "[1")) {
    		
		  rrepf++;

	    }
}

 
END {        
  
    for(i=0; i<=seqno; i++) {

          if(end_time[i] > 0) {

              delay[i] = end_time[i] - start_time[i];

                  count++;

        }

            else

            {

                  delay[i] = -1;

            }

    }

    for(i=0; i<=seqno; i++) {

          if(delay[i] > 0) {

              n_to_n_delay = n_to_n_delay + delay[i];

        }         

    }

	n_to_n_delay = n_to_n_delay/count;

	printf "Packet sendLine \t= %d \n", sendLine;
	printf "Packet recvLine \t= %d \n", recvLine;
	printf "Packet PDR Ratio \t= %.4f \n", (recvLine/sendLine);
	printf "Packet loss 	\t= %d \n", (sendLine-recvLine);
	#printf "Packet forwardLine\t= %d \n", fowardLine;
	printf "End-to-End Delay \t= " n_to_n_delay * 1000 " ms \n";
	#printf "Topology Control \t= %d \n", TC;
	printf "Routing Packets \t= %d \n", rt_pkts;
	printf "Routing Packets S \t= %d \n", rt_s;
	printf "Routing Packets F \t= %d \n", rt_f;
	printf "Route Request \t\t= %d \n", rreq;
	printf "Route Request S \t= %d \n", rreqs;
	printf "Route Request F \t= %d \n", rreqf;
	printf "Route Reply \t\t= %d \n", rrep;
	printf "Route Reply S \t\t= %d \n", rreps;
	printf "Route Reply F \t\t= %d \n", rrepf;
}
