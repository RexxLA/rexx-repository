/* Android System Test */
/* Very basic test of Android "JCL" */
PARSE SOURCE osname unused1 unused2
SAY osname "is your operating system"

"ls -a"

Say "let's see your current settings... OK?"
PULL ok
"am start -a android.intent.action.MAIN -n com.android.settings/.Settings"


