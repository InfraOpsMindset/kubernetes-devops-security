############  Add cis-etcd.sh ############ 

#!/bin/bash
#cis-etcd.sh

total_fail=$(kube-bench run --targets etcd  --version 1.15 --check 2.2 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]];
then
    echo "CIS Benchmark Failed ETCD while testing for 2.2"
    exit 1;
else
    echo "CIS Benchmark Passed for ETCD - 2.2"
fi;

############  Add cis-etcd.sh ############ 





############  Add cis-kubelet.sh ############ 

#!/bin/bash
#cis-kubelet.sh

total_fail=$(kube-bench run --targets node  --version 1.15 --check 4.2.1,4.2.2 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]];
then
    echo "CIS Benchmark Failed Kubelet while testing for 4.2.1, 4.2.2"
    exit 1;
else
    echo "CIS Benchmark Passed Kubelet for 4.2.1, 4.2.2"
fi;

############  Add cis-kubelet.sh ############ 







############  Add cis-master.sh ############ 


#!/bin/bash
#cis-master.sh

total_fail=$(kube-bench master  --version 1.15 --check 1.2.7,1.2.8,1.2.9 --json | jq .[].total_fail)

if [[ "$total_fail" -ne 0 ]];
then
    echo "CIS Benchmark Failed MASTER while testing for 1.2.7, 1.2.8, 1.2.9"
    exit 1;
else
    echo "CIS Benchmark Passed for MASTER - 1.2.7, 1.2.8, 1.2.9"
fi;

############  Add cis-master.sh ############ 

