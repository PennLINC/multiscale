homedir=/cbica/home/pinesa/multiscale/results/sge/SingleParcellation/Initialization
projectdir=/cbica/projects/pinesParcels/data/SingleParcellation/Initialization
# parameterizations for filepaths
let beta=10
let tNum=555
let numUsed=100
let nM=12
# for all scales
for s in {2..30}
do
	let K=${s}
	let pL="($beta * $tNum * $numUsed)/($K * $nM)"
	# account for annoying rounding differences between matlab and bash
	let pLplus="1+($beta * $tNum * $numUsed)/($K * $nM)"
	let pLminus="($beta * $tNum * $numUsed)/($K * $nM) -1"
	# alpha is negligible (=1) in this iteration
	let pS="($tNum * $numUsed)/$K"
	# same annoying thing for other term
	let pSplus="1 + (($tNum * $numUsed)/$K)"
	let pSminus="(($tNum * $numUsed)/$K)-1"
	# recalc penalty terms or wildcard my way ini
	# for all 50 initializations
	for i in {1..50}
	do		
		file=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pS}_L_${pL}_spaR_1_vxInfo_1_ard_0/init.mat
		fileplusplus=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pSplus}_L_${pLplus}_spaR_1_vxInfo_1_ard_0/init.mat
		fileminusminus=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pSminus}_L_${pLminus}_spaR_1_vxInfo_1_ard_0/init.mat
		fileplusminus=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pSplus}_L_${pLminus}_spaR_1_vxInfo_1_ard_0/init.mat
		fileminusplus=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pSminus}_L_${pLplus}_spaR_1_vxInfo_1_ard_0/init.mat
		file_plus=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pS}_L_${pLplus}_spaR_1_vxInfo_1_ard_0/init.mat
		file_minus=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pS}_L_${pLminus}_spaR_1_vxInfo_1_ard_0/init.mat
		fileminus_=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pSminus}_L_${pL}_spaR_1_vxInfo_1_ard_0/init.mat
		fileplus_=InitializationRes_${i}/Initialization_num100_comp${s}_S1_${pSplus}_L_${pL}_spaR_1_vxInfo_1_ard_0/init.mat
		pfile=${projectdir}/${file}
		pfileplus_=${projectdir}/${fileplus_}
		pfileminus_=${projectdir}/${fileminus_}
		pfile_plus=${projectdir}/${file_plus}
		pfile_minus=${projectdir}/${file_minus}
		pfileplusplus=${projectdir}/${fileplusplus}
		pfileplusminus=${projectdir}/${fileplusminus}
		pfileminusminus=${projectdir}/${fileminusminus}
		pfileminusplus=${projectdir}/${fileminusplus}
		hfile=${homedir}/${file}
		hfileplus_=${homedir}/${fileplus_}
                hfileminus_=${homedir}/${fileminus_}
                hfile_plus=${homedir}/${file_plus}
                hfile_minus=${homedir}/${file_minus}
                hfileplusplus=${homedir}/${fileplusplus}
                hfileplusminus=${homedir}/${fileplusminus}
                hfileminusminus=${homedir}/${fileminusminus}
                hfileminusplus=${homedir}/${fileminusplus}
                if [[ ! -f "$pfile" && ! -f "$pfileplus_" && ! -f "$pfileminus_" && ! -f "$pfile_plus" && ! -f "$pfile_minus" && ! -f "$pfileplusplus" && ! -f "$pfileplusminus" && ! -f "$pfileminusminus" && ! -f "$pfileminusplus" ]]; then
                        if [ -f "$hfile" ] || [ -f "$hfileplus_" ] || [ -f "$hfileminus_" ] || [ -f "$hfile_plus" ] || [ -f "$hfile_minus" ] || [ -f "$hfileplusplus" ] || [ -f "$hfileplusminus" ] || [ -f "$hfileminusminus" ] || [ -f "$hfileminusplus" ]; then
				echo "project dir is missing scale $s iteration $i, but homedir has it"
			else
				echo "project dir is missing scale $s iteration $i"
				#echo $hfile
			fi
                fi
	done
done
