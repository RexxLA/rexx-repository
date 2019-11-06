/*Rexx*/
/* List DSN ENQ information using ISPF Services */
arg indsn .
parse source . how .

"subcom ispexec"
if rc\=0 then do
    say "This command must be executed under ISPF environment."
    exit 12
    end
if indsn='' then do
    say "Dataset name is required. Please specify a Dataset name."
    exit 12
    end
indsn=strip(indsn,'b',"'")
Okdsn=sysdsn("'"indsn"'")
if Okdsn\='OK' then do
    say indsn ":" Okdsn
    exit 12
    end

address ispexec
"control errors return"
"lminit dataid(ispenqdd) dataset('"indsn"') enq(exclu) "
if rc\=0 then do
    "vget (zenqlist zenqcnt zenqdsn zenqtype) profile"
     call show_enq
     end
else say "No enqueue contention for dataset:"indsn
"lmfree dataid("ispenqdd")"
  exit 0

  show_enq:
/* "Clear" */
/* CLEAR is not part of base ISPF product, some maynot have it*/
  say center('Dataset Enque Contention',65)
  say
  say "Dataset:" zenqdsn
  say "is in use by the following" zenqcnt "user(s) or Job(s):"
  say copies('-',79)
  say

tasklist=zenqlist
do while tasklist\=''
    parse var tasklist taskname +9 tasklist
    parse var zenqtype enqtype zenqtype
    msg=''
    parse var taskname 1 code +1 taskname
    code=c2x(code)
    if code='01' then qtye='SHR'
    if code='02' then qtye='OLD'
    if enqtype='ssssssss' then msg=' owns  resource with DISP=SHR'
    if enqtype='SSSSSSSS' then msg=' wants resource with DISP=SHR'
    if enqtype='oooooooo' then msg=' owns  resource with DISP=OLD'
    if enqtype='OOOOOOOO' then msg=' Wants resource with DISP=OLD'
    say left(taskname,8,' ') msg
end
return 0