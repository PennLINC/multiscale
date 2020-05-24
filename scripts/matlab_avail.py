import subprocess
def matlab_license():
  while True:
    lic_server=['lmutil','lmstat','-a','-c','pinesa@cbica-cluster']
    cmdout = subprocess.check_output(lic_server)
    F=open('mat_lic.info','w')
    F.write(cmdout)
    F.close()
    F=open('mat_lic.info','r')
    for line in F:
      if 'Users of MATLAB' in line:
        text = line
        break
    F.close()
    num=[]
    for word in text.split():
      if word.isdigit():
        num.append(word)
    lic_avail = max(num) - min(num)
    if lic_avail  < 2:
        print(" < 2 %d license(s) found. Trying again.")
    else:
        print(" %d licenses available.")
    return

