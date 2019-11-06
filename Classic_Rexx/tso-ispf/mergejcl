/* rexx */

/**************************************************************************************************************************
   member name : MERGEJCL

   author      : Roy Mathur

   date written: 12/28/2004

   Purpose     : To merge all Jobs with their Procs and Sysins so that you don't have to hunt down each member to see
                 what the job does.  This was written to assist programmers in looking at jcl in environments where jobs
                 use symbolics to define /atasets, pds's and members; making it tedious to identify the files used, the
                 db2 programs executed and the sort parameters used.

   I/O         : Reads : 1. Production Joblib
                         2. Production Proclibs
                         3. Production Sysinlib
                 Writes: 1. MERGEJCL PDS containing all Jobs with JCL resolved, one Job per UCC7 Id
                         2. XREF Dataset containing a primative cross-reference of all jobs, procs, programs, datasets used
                         3. TRACE Dataset containing all "displays"

   Syntax      : TSO %MERGEJCL /nnnnn \xxxxxxxx @

                 Where /nnnnnn   is optional, turns on the trace logic.
                                 '/'       by itself will turn all traces on.
                                 '/2000'             will turn all traces for functions >= 2000.
                                 '/90000             will turn     traces to only display job names before they're processed
                       \xxxxxxxx is optional, used to restart the process from a specific job.
                                 '\'        by itself accomplishes nothing.
                                 '\jobname'           will start processing all jobs from that jobname.
                       @         is optional, used to concatenate to the output datasets.
                                 Warning! If you don't use it then it will delete/allocate the output datasets.

   Example     : "TSO %MERGEJCL"                    - will process all Production jobs
                 "TSO %MERGEJCL /90000"             - will process all Production jobs and write jobs to the output TRACE
                                                      dataset.
                 "TSO %MERGEJCL /90000 \JOBNAME @"  - will restart the process from job JOBNAME and concatenate the results
                                                      to the existing output datasets.

   Future Enhancements/Questions:
               1. build a list of all jobs that execute before/after a given job name using dataset names to determine
                  the jobs.

               2. optimize by using variables instead of stems, ex: use "s_line4" instead of "a_array.i_subscript"

               3. reset variables before each loop

               4. can the proc's pds(mem) name be different from the '//ps001 exec procname' proc name?

               5. currently dropping bytes 73-80 of the job & proc lines, should we keep them?

               6. move '//' eoj card to after each group of ucc7 id so we can save all ucc7-id-jobs under one member name

               7. look into "ISPEXEC CONTROL DISPLAY LOCK" and ISPEXEC CONTROL DISPLAY LINE START(1)" when converting this
                  to use a panel

               8. add logic to create/use a member in the mergejcl pds that contains the last number used to create a job,
                  so that when we restart (b_continue = 1) we won't overlay the existing z0000000 files.

 **************************************************************************************************************************
 maintenance log:
 2004-12-02: - scrapped existing design written back in 2004-05-11 and redesigned to process all jobs.

 **************************************************************************************************************************/

    numeric digits 28

    parse upper arg l_arg

    call 1000_Init

    do i_jobs=i_job_beg to a_jobs.0
       call 2000_Main
    end

    call 9000_Done

    exit

/*------------------------------------------------------------------------------------------------------------------------*/
1000_Init:

    call 1100_Init_Variables
    call 1200_Break_Down_Parameters
    call 1300_Create_Output_Datasets
    call 1400_Get_Jobs

    do i_proc_pds=1 to a_proc_pds.0
       call 1500_Get_Procs
    end
    a_proclibs.0 = i_proclibs

    if i_job_beg <= 1 then b_fnd_job = 0
    else                   b_fnd_job = 1

    return

/*------------------------------------------------------------------------------------------------------------------------*/
1100_Init_Variables:

    /*--------------------------------------------------------------------------------------------------------------------
    | arrays
    |---------------------------------------------------------------------------------------------------------------------*/
    a_index.0         = 0
    a_index_in.0      = 0
    a_job.0           = 0                /* contains a job's JCL */
    a_jobs.0          = 0                /* contains all job names */
    a_jobu.0          = 0
    a_joby.0          = 0

    a_jcl.0           = 0
    a_listcat.0       = 0
    a_mrg.0           = 0

    a_proc_pds.0      = 2
/*
    a_proc_pds.1      = '????????.PROD.PROCLIB'
    a_proc_pds.2      = '????????.SYS2.PROCLIB'
*/
    a_proc_pds.1      = 'PROD.PROCLIB'
    a_proc_pds.2      = 'SYS2.PROCLIB'

    a_proclib.0       = 0                /* holds outtrap results */
    a_proclibs.0      = 0                /* holds all proc pds(mem) */
    a_procs.0         = 0                /* holds all procs within a job */
    a_procs_jobstep.0 = 0                /* holds the jobsteps for a_procs */
    a_procs_joblno.0  = 0                /* holds the jobsteps for a_procs */
    a_procy.0         = 0
    a_procy_beg.0     = 0

    a_sysin.0         = 0

    a_ucc7.0          = 0                /* contains beg/end line nbrs for ucc7 commands */
    a_ucc7_beg.0      = 0
    a_ucc7_end.0      = 0
    a_ucc7_id.0       = 0

    /*--------------------------------------------------------------------------------------------------------------------
    | switches
    |---------------------------------------------------------------------------------------------------------------------*/
    b_continue     = 0
    b_fnd_index    = 0
    b_fnd_job      = 0
    b_fnd_proc     = 0
    b_heading      = 0

    /*--------------------------------------------------------------------------------------------------------------------
    | array subscripts
    |---------------------------------------------------------------------------------------------------------------------*/
    i1             = 0
    i2             = 0

    i_gen          = 0

    i_jobs         = 0                /* subscript for a_jobs */
    i_job          = 0                /* subscript for a_job  */
    i_jobu         = 0                /* subscript for a_jobu */
    i_jobu_beg     = 0
    i_joby         = 0                /* subscript for a_joby */
    i_job_beg      = 1                /* the subscript number to start processing the a_job. array */

    i_jcl          = 0                /* subscript for a_jcl  */
    i_listcat      = 0
    i_mrg          = 0                /* subscript for a_mrg  */

    i_proc         = 0
    i_proc_beg     = 0
    i_procs        = 0                /* subscript for a_procs */
    i_proclib      = 0
    i_procs_pds    = 0                /* subscript for a_proc_pds */
    i_proclibs     = 0                /* subscript for a_proclibs */
    i_procy        = 0
    i_procy_beg    = 0

    i_ucc7         = 0                /* subscript for a_ucc7 */
    i_ucc7_beg     = 0
    i_ucc7_bot     = 0
    i_ucc7_end     = 0
    i_ucc7_top     = 0

    i_xref         = 0

    /*--------------------------------------------------------------------------------------------------------------------
    | numeric variables
    |---------------------------------------------------------------------------------------------------------------------*/
    n_gen          = 0

    n_pos01        = 0
    n_pos02        = 0
    n_pos03        = 0
    n_pos04        = 0
    n_pos05        = 0
    n_pos06        = 0
    n_pos07        = 0
    n_pos08        = 0
    n_pos09        = 0
    n_pos10        = 0

    n_process      = 0
    n_processed    = 0

    n_rc           = 0

    n_trace        = 0

    /*--------------------------------------------------------------------------------------------------------------------
    | strings
    |---------------------------------------------------------------------------------------------------------------------*/
    s_arg          = ''
    s_chr          = ''

    s_job_beg      = ''
    s_job_mem      = ''
    s_job_name     = ''
/*  s_job_pds      = '????????.PROD.JCL' */
    s_job_pds      = 'PROD.JCL'
    s_job_pds_mem  = ''
    s_job_step     = ''

    s_line1        = ''

    s_out_pds      = '???.MERGEJCL'
    s_out_index    = '???.MERGEJCL(#INDEX)'

    s_parse1       = ''
    s_parse2       = ''

    s_proc_line    = ''
    s_proc_mem     = ''
    s_proc_name    = ''
    s_proc_pds     = ''
    s_proc_pds_mem = ''
    s_proc_step    = ''

    s_trace_ds     = '???.MERGEJCL.TRACE'

    s_ucc7         = ''
    s_ucc7_id      = ''

    s_word         = ''

    s_xref_ds      = '???.MERGEJCL.XREF'

    /*--------------------------------------------------------------------------------------------------------------------
    | datasets
    |---------------------------------------------------------------------------------------------------------------------*/
    call msg off
    "free ddn(INDD1)"
    "free ddn(INDD3)"
    "free ddn(INDD4)"
    "free ddn(OUTDD1)"
    "free ddn(OUTDD2)"
    "free ddn(OUTDD3)"
    "free ddn(OUTDD4)"

    "free dsn('"s_job_pds_mem"')"
    "free dsn('"s_out_index"')"
    "free dsn('"s_trace_ds"')"
    "free dsn('"s_xref_ds"')"
    "free dsn('"s_out_pds"')"
    "free dsn('"s_out_index"')"
    call msg on

    return

/*------------------------------------------------------------------------------------------------------------------------*/
1200_Break_Down_Parameters:

    i_words = words(l_arg)

    do i1=1 to i_words
       s_word = word(l_arg, i1)
       s_chr  = substr(s_word, 1, 1)
/*  say '1200 #1 i1='i1', s_word={'s_word'}, s_chr={'s_chr'}' */
       select
         when s_chr            = '@'   then do
                                               b_continue = 1
                                               b_heading  = 1
                                          end
         when s_chr            = '/'   then do
                                               n_trace    = substr(s_word, 2)
                                               if length(n_trace) = 0 then n_trace = 0
                                            end
         when s_chr            = '\'   then s_job_beg     = strip(substr(s_word' ', 2))
         when datatype(s_word) = 'NUM' then n_process     = s_word
         otherwise                          s_arg         = s_arg' 's_word
       end
    end

    l_arg = strip(s_arg)

    if length(n_trace) = 0 then n_trace = 99999

/* say 'l_arg={'l_arg'}, n_trace={'n_trace'}, s_job_beg={'s_job_beg'}, b_continue={'b_continue'}' */

    if length(l_arg) > 0 then do
       say '==> Error invalid parameter syntax: l_arg='l_arg
       exit
    end

    return

/*------------------------------------------------------------------------------------------------------------------------*/
1300_Create_Output_Datasets:

    /*--------------------------------------------------------------------------------------------------------------------
    |  create trace dataset
    |---------------------------------------------------------------------------------------------------------------------*/
    if n_trace < 99999 then do
       call msg off
       "free ddn(outdd1)"
       if b_continue = 0 then "delete ('"s_trace_ds"') scratch"
       call msg on
       "alloc ddn(outdd1) dsn('"s_trace_ds"') mod cylinders space(100,15) dsorg(ps) recfm(f,b) blksize(0) lrecl(300)"
       n_rc = rc
       if n_rc <> 0 then do
          say "==> Error allocating OUTDD1 for: '"s_trace_ds"',  rc="n_rc
          exit
       end
    end

    /*--------------------------------------------------------------------------------------------------------------------
    |  create xref dataset
    |---------------------------------------------------------------------------------------------------------------------*/
    call msg off
    "free ddn(outdd2)"
    if b_continue = 0 then "delete ('"s_xref_ds"') scratch"
    call msg on
    "alloc ddn(outdd2) dsn('"s_xref_ds"') mod cylinders space(15,15) dsorg(ps) recfm(f,b) blksize(0) lrecl(260)"
    n_rc = rc
    if n_rc <> 0 then do
       say "==> Error allocating OUTDD2 for: '"s_xref_ds"',  rc="n_rc
       exit
    end

    /*--------------------------------------------------------------------------------------------------------------------
    |  create pds for putting resolved jcl
    |---------------------------------------------------------------------------------------------------------------------*/
    call msg off
    "free ddn(outdd3)"
    if b_continue = 0 then "delete ('"s_out_pds"') scratch"
    call msg on
    if b_continue = 0 then "alloc ddn(outdd3) dsn('"s_out_pds"') new cylinders space(300,150) dir(1000) dsorg(po) recfm(f,b) blksize(0) lrecl(100)"
    else                   "alloc ddn(outdd3) dsn('"s_out_pds"') shr"
    n_rc = rc
    if n_rc <> 0 then do
       say "==> Error allocating OUTDD3 for: '"s_out_pds"',  rc="n_rc
       exit
    end
    "free ddn(outdd3)"

    /*--------------------------------------------------------------------------------------------------------------------
    |  get mem for putting resolved jcl's member name cross-reference
    |  so we can determine the last member number that was generated
    |---------------------------------------------------------------------------------------------------------------------*/
    "alloc ddn(indd4) dsn('"s_out_index"') shr"
    n_rc = rc
    if n_rc <> 0 then do
       say "==> Error allocating INDD4 for '"s_out_index"',  rc="n_rc
       exit
    end

    rc = sysdsn("'"s_out_index"'")
    if rc = 'OK' then do
       "execio * diskr indd4 (finis stem a_index_in."
       n_rc = rc
       if n_rc <> 0 then do
          say '==> error reading INDD4 for 's_out_index', rc='n_rc
          exit
       end
    end

    "free ddn(indd4)"

    /*--------------------------------------------------------------------------------------------------------------------
    | - when the '@' option is NOT requested then we are
    |   delete/defining all datasets regardless of whether the
    |   '\' option has been requested or not.
    | - when the '@' option is requested by the '\' option is NOT
    |   then we process all jobs, concatenating to the existing
    |   datasets.
    | - when both the '@' and '\' options are requested then we
    |   are processing all jobs starting with the provided '\'
    |   job, and all datasets will be concatenated to.
    |---------------------------------------------------------------------------------------------------------------------*/
    select
      when b_continue = 0 then do
           i_gen = 0
           n_gen = 0
      end
      when length(s_job_beg) = 0 then do
           do i_gen=1 to a_index_in.0
              a_index.i_gen = a_index_in.i_gen
           end
           i_gen = a_index_in.0
           n_gen = substr(a_index.i_gen, 2, 7)
      end
      otherwise do
          i2 = 0
          do i_gen=1 to a_index_in.0
             if pos('('s_job_beg')', a_index_in.i_gen) > 0 then do
                n_gen = substr(a_index_in.i_gen, 2, 7)
                leave i_gen
             end
             i2         = i2 + 1
             a_index.i2 = a_index_in.i_gen
          end
          if n_gen = 0 then do
             i_gen = i2
             n_gen = substr(a_index.i_gen, 2, 7)
          end
       end
    end
    if n_trace <= 1300 then call 9900_trace('1300 #1 b_continue='b_continue', s_job_beg='s_job_beg', i_gen='i_gen', n_gen='n_gen)

    /*--------------------------------------------------------------------------------------------------------------------
    |  create mem for putting resolved jcl's member name cross-reference
    |---------------------------------------------------------------------------------------------------------------------*/
    "alloc ddn(outdd4) dsn('"s_out_index"') shr"
    n_rc = rc
    if n_rc <> 0 then do
       say "==> Error allocating OUTDD4 for: '"s_out_index" for output',  rc="n_rc
       exit
    end

    return

/*------------------------------------------------------------------------------------------------------------------------*/
1400_Get_Jobs:
    if n_trace <= 1400 then call 9900_trace('1400_Get_Jobs')

    if (b_continue=0) & (n_process=1) & (length(s_job_beg)>0) then do
       a_jobs.1 = '--MEMBERS--'
       a_jobs.2 = s_job_beg
       a_jobs.0 = 2
    end
    else do
       call outtrap a_jobs.
       "listds '"s_job_pds"' members"
       call outtrap off
       /*-----------------------------------------------------------------------------------------------------------------
       | find job name when user wants to start scanning jcl from
       | a specific job
       |------------------------------------------------------------------------------------------------------------------*/
       if n_trace <= 1400 then call 9900_trace('1400 #1 length(s_job_beg)='length(s_job_beg)', a_jobs.0='a_jobs.0)
       if length(s_job_beg) > 0 then do
          do i1=1 to a_jobs.0
             if n_trace <= 1400 then call 9900_trace('1400 #2 strip(a_jobs.'i1')='strip(a_jobs.i1)', s_job_beg='s_job_beg)
             if strip(a_jobs.i1) = s_job_beg then do
                i_job_beg = i1
                leave i1
             end
          end
       end
    end
    if n_trace <= 1400 then call 9900_trace('1400 #3 a_jobs.0='a_jobs.0', i_job_beg='i_job_beg)

    return

/*------------------------------------------------------------------------------------------------------------------------*/
1500_Get_Procs:
    if n_trace <= 1500 then call 9900_trace('1500_Get_Procs')

    /*--------------------------------------------------------------------------------------------------------------------
    | get proclib's members
    |---------------------------------------------------------------------------------------------------------------------*/
    call outtrap a_proclib.
    "listds '"a_proc_pds.i_proc_pds"' members"
    call outtrap off
    if n_trace <= 1500 then call 9900_trace('1500 #1 a_proclib.0='a_proclib.0', a_proc_pds.'i_proc_pds'='a_proc_pds.i_proc_pds)

    /*--------------------------------------------------------------------------------------------------------------------
    | copy the proclib's members to the bottom of the a_proclibs
    | array
    |---------------------------------------------------------------------------------------------------------------------*/
    b_fnd_proc = 0

    do i_proclib=1 to a_proclib.0
       select
         when a_proclib.i_proclib = '--MEMBERS--' then b_fnd_proc = 1
         when b_fnd_proc          = 1             then do
           i_proclibs = i_proclibs + 1
           a_proclibs.i_proclibs = a_proc_pds.i_proc_pds'('strip(a_proclib.i_proclib)')'
         end
         otherwise                                     nop
       end
    end

    a_proclibs.0 = i_proclibs
    if n_trace <= 1500 then call 9900_trace('1500 #2 a_proclibs.0='a_proclibs.0', a_proc_pds.'i_proc_pds'='a_proc_pds.i_proc_pds)

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2000_Main:
    if n_trace <= 2000 then call 9900_trace('2000_Main')
    if n_trace <= 2000 then call 9900_trace('2000 #1 a_jobs.0='a_jobs.0', b_fnd_job='b_fnd_job)
    if n_trace <  99999 then say             '2000 #2 a_jobs.'i_jobs'='a_jobs.i_jobs
    if n_trace <  99999 then call 9900_trace('2000 #2 a_jobs.'i_jobs'='a_jobs.i_jobs)

    select
      when a_jobs.i_jobs = '--MEMBERS--' then b_fnd_job = 1
      when b_fnd_job     = 1             then call 2100_Process_Mem
      otherwise                               return
    end

    if n_trace <= 2000 then call 9900_trace('2000 #3 n_processed='n_processed', n_process='n_process)
    if (n_process>0) & (n_processed>=n_process) then i_jobs = a_jobs.0 + 1

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2100_Process_Mem:
    if n_trace <= 2100 then call 9900_trace('2100_Process_Mem')

    if n_process > 0 then n_processed = n_processed + 1

    /*--------------------------------------------------------------------------------------------------------------------
    | extract a job name
    |---------------------------------------------------------------------------------------------------------------------*/
    call 2200_Get_Job

    if n_trace <= 9999 then call 9900_trace(' ')
    if n_trace <= 9999 then call 9900_trace('dump #1 - a_job:   original job:'a_job.0)
    if n_trace <= 9999 then do i=1 to a_job.0
    /* n_trace <= 9999 */      call 9900_trace('        a_job.'format(i,5)'='a_job.i)
    /* n_trace <= 9999 */   end

    /*--------------------------------------------------------------------------------------------------------------------
    | identify lines that begin or end ucc7 sets of jcl statements
    |---------------------------------------------------------------------------------------------------------------------*/
    i_ucc7 = 0

    if n_trace <= 2100 then call 9900_trace('2100 #2 a_job.0='a_job.0)
    do i_job=1 to a_job.0
       if n_trace <= 2100 then call 9900_trace('2100 #3 a_job.'i_job'='a_job.i_job)
       a_job.i_job = strip(a_job.i_job)
       s_ucc7      = substr(a_job.i_job, 1, 3)
       if n_trace <= 2100 then call 9900_trace('2100 #4 s_ucc7='s_ucc7)
       select
         when s_ucc7='#MS' then iterate i_job
         when s_ucc7='#SC' then iterate i_job
         when s_ucc7='#7U' then iterate i_job
         when s_ucc7='#JI' | s_ucc7='#JO' then do
              if i_ucc7 > 0 then a_ucc7_end.i_ucc7 = i_job
              parse var a_job.i_job s_parse1 '=' s_parse2
              s_parse2 = strip(s_parse2, 'l', '(')
              s_parse2 = strip(s_parse2, 't', ')')
              parse var s_parse2 s_parse3  ','
              parse var s_parse3 s_parse4  '-'
              parse var s_parse4 s_ucc7_id ' '
              i_ucc7            = i_ucc7 + 1
              a_ucc7_beg.i_ucc7 = i_job
              a_ucc7_id.i_ucc7  = s_ucc7_id
              if n_trace <= 2100 then call 9900_trace('2100 #5 a_ucc7_beg.'i_ucc7'='a_ucc7_beg.i_ucc7)
              if n_trace <= 2100 then call 9900_trace('        a_ucc7_id.'i_ucc7' ='a_ucc7_id.i_ucc7)
         end
         when s_ucc7='#JE' then a_ucc7_end.i_ucc7 = i_job
         otherwise iterate i_job
       end
    end
    if n_trace <= 2100 then call 9900_trace('2100 #6 i_ucc7='i_ucc7)

    if i_ucc7 = 0 then do
       i_ucc7       = 1
       a_ucc7_beg.1 = 0
       a_ucc7_end.1 = a_job.0 + 1
       a_ucc7_id.1  = ''
    end
    if n_trace <= 2100 then call 9900_trace('2100 #7 i_ucc7='i_ucc7)
    if n_trace <= 2100 then call 9900_trace('        a_ucc7_beg.1='a_ucc7_beg.1)
    if n_trace <= 2100 then call 9900_trace('        a_ucc7_end.1='a_ucc7_end.1)
    if n_trace <= 2100 then call 9900_trace('        a_ucc7_id.1 ='a_ucc7_id.1)

    a_ucc7_beg.0 = i_ucc7
    a_ucc7_end.0 = i_ucc7
    a_ucc7_id.0  = i_ucc7
    i_ucc7_top   = a_ucc7_beg.1
    i_ucc7_bot   = a_ucc7_end.i_ucc7
    if n_trace <= 2100 then call 9900_trace('2100 #8 a_ucc7_beg.0='a_ucc7_beg.0)
    if n_trace <= 2100 then call 9900_trace('        a_ucc7_end.0='a_ucc7_end.0)
    if n_trace <= 2100 then call 9900_trace('        a_ucc7_id.0 ='a_ucc7_id.0)
    if n_trace <= 2100 then call 9900_trace('        i_ucc7_top  ='i_ucc7_top)
    if n_trace <= 2100 then call 9900_trace('        i_ucc7_bot  ='i_ucc7_bot)

    /*--------------------------------------------------------------------------------------------------------------------
    | process each ucc7 job
    |---------------------------------------------------------------------------------------------------------------------*/
    do i_ucc7=1 to a_ucc7_beg.0
       if n_trace <= 2100 then call 9900_trace('2100 #9 a_ucc7_beg.'i_ucc7'='a_ucc7_beg.i_ucc7', a_ucc7_end.'i_ucc7'='a_ucc7_end.i_ucc7', a_ucc7_id.'i_ucc7'='a_ucc7_id.i_ucc7)

       call 2300_Build_Job

       if n_trace <= 9999 then call 9900_trace(' ')
       if n_trace <= 9999 then call 9900_trace('dump #2 - a_jobu:  for one ucc7 id:'a_jobu.0)
       if n_trace <= 9999 then do i=1 to a_jobu.0
       /* n_trace <= 9999 */      call 9900_trace('        a_jobu.'format(i,5)'='a_jobu.i)
       /* n_trace <= 9999 */   end

       call 2400_Process_Job

       if a_proc.0 = 0 then iterate i_ucc7

       i_mrg = 0
       do i_jcl=1 to a_jcl.0
          call 2600_Merge_Sysins
       end
       a_mrg.0 = i_mrg

       if n_trace <= 10000 then call 9900_trace(' ')
       if n_trace <= 10000 then call 9900_trace('dump #3 - a_mrg:   merged job/procs/sysins:'a_mrg.0)
       if n_trace <= 10000 then do i=1 to a_mrg.0
       /* n_trace <= 10000 */      call 9900_trace('        a_mrg.'format(i,5)'='a_mrg.i)
       /* n_trace <= 10000 */   end

       call 5000_Build_Xref

       if n_trace <= 9999 then call 9900_trace(' ')
       if n_trace <= 9999 then call 9900_trace('dump #4 - a_xref:'a_xref.0)
       if n_trace <= 9999 then do i=1 to a_xref.0
       /* n_trace <= 9999 */      call 9900_trace('        a_xref.'format(i,5)'='a_xref.i)
       /* n_trace <= 9999 */   end

      call 6000_Write_and_Reset
    end

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2200_Get_Job:
    if n_trace <= 2200 then call 9900_trace('2200_Get_Job')

    s_job_mem     = strip(a_jobs.i_jobs)
    s_job_pds_mem = s_job_pds'('s_job_mem')'
    if n_trace <= 2200 then call 9900_trace('2200 #2 s_job_mem    ='s_job_mem)
    if n_trace <= 2200 then call 9900_trace('        s_job_pds_mem='s_job_pds_mem)

    "alloc ddn(indd1) dsn('"||s_job_pds_mem||"') shr reuse"
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error allocating INDD1 for 's_job_pds_mem', rc='n_rc
       if n_trace <= 2200 then call 9900_trace('2200 #03 's_str1)
       say s_str1
       a_job.0 = 0
       return
    end

    "execio * diskr indd1 (finis stem a_job."
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error reading indd1 for 's_job_pds_mem', rc='n_rc
       if n_trace <= 2200 then call 9900_trace('2200 #04 's_str1)
       say s_str1
       a_job.0 = 0
       return
    end

    "free ddn(indd1)"
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error freeing indd1 for 's_job_pds_mem', rc='n_rc
       if n_trace <= 2200 then call 9900_trace('2200 #05 's_str1)
       say s_str1
       return
    end

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2300_Build_Job:
    if n_trace <= 2300 then call 9900_trace('2300_Build_Job')

    i_jobu = 0

    /*--------------------------------------------------------------------------------------------------------------------
    | first copy the lines before the first #J ucc7 command
    |---------------------------------------------------------------------------------------------------------------------*/
    do i4=1 to i_ucc7_top-1
       if n_trace <= 2300 then call 9900_trace('2300 #1 a_job.'i4'='a_job.i4)
       i_jobu        = i_jobu + 1
       a_jobu.i_jobu = a_job.i4
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | next copy the lines within the #J ucc7 command
    |---------------------------------------------------------------------------------------------------------------------*/
    do i4=a_ucc7_beg.i_ucc7+1 to a_ucc7_end.i_ucc7-1
       if n_trace <= 2300 then call 9900_trace('2300 #2 a_job.'i4'='a_job.i4)
       i_jobu        = i_jobu + 1
       a_jobu.i_jobu = a_job.i4
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | lastly copy the lines after the #JEND command
    |---------------------------------------------------------------------------------------------------------------------*/
    do i4=i_ucc7_bot+1 to a_job.0
       if n_trace <= 2300 then call 9900_trace('2300 #3 a_job.'i4'='a_job.i4)
       i_jobu        = i_jobu + 1
       a_jobu.i_jobu = a_job.i4
    end

    a_jobu.0 = i_jobu
    if n_trace <= 2300 then call 9900_trace('2300 #4 a_jobu.0='a_jobu.0)

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2400_Process_Job:
    if n_trace <= 2400 then call 9900_trace('2400_Process_Job')

    i_joby     = 0
    i_jobu_beg = 1

    do i_jobu=1 to a_jobu.0
       call 2410_Resolve_Job_Symbolics
    end
    a_joby.0 = i_joby

    if n_trace <= 9999 then call 9900_trace(' ')
    if n_trace <= 9999 then call 9900_trace('dump #5 - a_joby:  resolved job Symbolics:'a_joby.0)
    if n_trace <= 9999 then do i=1 to a_joby.0
    /* n_trace <= 9999 */      call 9900_trace('        a_joby.'format(i,5)'='a_joby.i)
    /* n_trace <= 9999 */   end

    /*--------------------------------------------------------------------------------------------------------------------
    | identify Proc Steps
    |---------------------------------------------------------------------------------------------------------------------*/
    i_procs = 0
    do i_joby=1 to a_joby.0
       if substr(a_joby.i_joby, 1, 3) = '//*' then iterate i_joby
       if substr(a_joby.i_joby, 1, 2) <> '//' then iterate i_joby
       if word(a_joby.i_joby,2) = 'EXEC' then n_pos01 = pos(' EXEC ', a_joby.i_joby, 1)
       else                                   n_pos01 = 0
       if n_pos01 = 0 then iterate i_joby
       if pos(' PGM=', a_joby.i_joby, n_pos01+5) > 0 then iterate i_joby
       n_pos02 = pos(' PROC=', a_joby.i_joby, n_pos01+5)
       if n_pos02 > 0 then s_proc_line = substr(a_joby.i_joby, n_pos02+6)
       else                s_proc_line = substr(a_joby.i_joby, n_pos01+6)
       parse var s_proc_line s_parse1 s_parse2
       parse var s_parse1 s_proc_name ',' s_parse2
       n_pos02                 = pos(' ', a_joby.i_joby, 3)
       s_job_step              = strip(substr(a_joby.i_joby, 3, n_pos02))
       i_procs                 = i_procs + 1
       a_procs.i_procs         = strip(s_proc_name)
       a_procs_jobstep.i_procs = s_job_step
       a_procs_joblno.i_procs  = i_joby
       if n_trace <= 2400 then call 9900_trace('2400 #1 a_procs.'i_procs'='a_procs.i_procs)
    end
    a_procs.0         = i_procs
    a_procs_jobstep.0 = i_procs
    a_procs_joblno.0  = i_procs
    if n_trace <= 2400 then call 9900_trace('2400 #2 a_procs.0='a_procs.0)

    if n_trace <= 9999 then call 9900_trace(' ')
    if n_trace <= 9999 then call 9900_trace('dump #6 - a_procs: identified procs:'a_procs.0)
    if n_trace <= 9999 then do i=1 to a_procs.0
    /* n_trace <= 9999 */      call 9900_trace('        a_procs.'format(i,5)'='a_procs.i', jobstep='a_procs_jobstep.i', joblno='a_procs_joblno.i)
    /* n_trace <= 9999 */   end

    /*--------------------------------------------------------------------------------------------------------------------
    | put job into another array so we can concatenate the procs to it
    |---------------------------------------------------------------------------------------------------------------------*/
    n_gen         = n_gen + 1
    s_out_mem     = 'Z'right(n_gen,7,0)
    i_gen         = i_gen + 1
    a_index.i_gen = s_out_mem', 's_job_pds_mem', 'a_ucc7_id.i_ucc7
    i_jcl         = 1
    if length(a_ucc7_id.i_ucc7) =0 then s_str1 = ''
    else                                s_str1 = ', Ucc7Id='a_ucc7_id.i_ucc7
    a_jcl.1   = '++ MergeJclMemName='s_out_mem', Job='s_job_pds_mem||s_str1
    if n_trace <= 2400 then call 9900_trace('2400 #3 s_out_mem='s_out_mem', n_gen='n_gen)

    do i_joby=1 to a_joby.0
       i_jcl       = i_jcl + 1
       a_jcl.i_jcl = a_joby.i_joby
    end

    a_jcl.0 = i_jcl
    if n_trace <= 2400 then call 9900_trace('2400 #4 a_jcl.0='a_jcl.0)

    /*--------------------------------------------------------------------------------------------------------------------
    | Process Procs
    |---------------------------------------------------------------------------------------------------------------------*/
    do i_procs=1 to a_procs.0
       call 2500_Process_Procs
    end

    if n_trace <= 9999 then call 9900_trace(' ')
    if n_trace <= 9999 then call 9900_trace('dump #7 - a_jcl:   job & all procs w/all symbolics resovled:'a_jcl.0)
    if n_trace <= 9999 then do i=1 to a_jcl.0
    /* n_trace <= 9999 */      call 9900_trace('        a_jcl.'format(i,5)'='a_jcl.i)
    /* n_trace <= 9999 */   end

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2410_Resolve_Job_Symbolics:
    if n_trace <= 2410 then call 9900_trace('2410_Resolve_Job_Symbolics')

    /*--------------------------------------------------------------------------------------------------------------------
    | skip comments
    |---------------------------------------------------------------------------------------------------------------------*/
    if substr(a_jobu.i_jobu, 1, 3) = '//*' then do
       i_jobu_beg    = 1
       i_joby        = i_joby + 1
       a_joby.i_joby = a_jobu.i_jobu
       return
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | drop columns 73-80
    |---------------------------------------------------------------------------------------------------------------------*/
    a_jobu.i_jobu = substr(a_jobu.i_jobu, 1, 72)
    if n_trace <= 2410 then call 9900_trace('2410 #1 a_jobu.'i_jobu'='a_jobu.i_jobu)

    /*--------------------------------------------------------------------------------------------------------------------
    | skip temp file names, ex: &&TEMPWK01
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos04 = pos('&&', a_jobu.i_jobu, i_jobu_beg)
    if n_pos04 > 0 then i_jobu_beg = n_pos04 + 2

    /*--------------------------------------------------------------------------------------------------------------------
    | check for line does NOT contain an &
    |---------------------------------------------------------------------------------------------------------------------*/
    if n_trace <= 2410 then call 9900_trace('2410 #2 i_jobu_beg='i_jobu_beg)
    n_pos04 = pos('&', a_jobu.i_jobu, i_jobu_beg)
    if n_pos04 = 0 then do
       i_jobu_beg    = 1
       i_joby        = i_joby + 1
       a_joby.i_joby = a_jobu.i_jobu
       return
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | resolve all & symbolics in the line
    |---------------------------------------------------------------------------------------------------------------------*/
    if n_trace <= 2410 then call 9900_trace('2410 #03  n_pos04='format(n_pos04,5)', a_jobu.'format(i_jobu,5)'='a_jobu.i_jobu)
    s_line1 = a_jobu.i_jobu

    do while n_pos04 > 0
       s_arg = 3000_Extract_Symbolic_Name(n_pos04, s_line1)
       parse var s_arg s_sym ',' n_pos05 ',' i_keep
       if n_trace <= 2410 then call 9900_trace('2410 #04 s_sym='s_sym', n_pos05='n_pos05)
       call 2420_Scan_Job_Line_for_Sym_Def
       n_pos04 = pos('&&', s_line1, i_jobu_beg)
       if n_pos04 > 0 then i_jobu_beg = n_pos04 + 2
       n_pos04 = pos('&', s_line1, i_jobu_beg)
       if n_pos04 > 0 then do
          n_pos04b = pos(' ', s_line1, n_pos04 - 1)
          n_pos04c = pos(' ', s_line1, n_pos04 + 1)
          if n_trace <= 2410 then call 9900_trace('2410 #05 n_pos04='n_pos04', n_pos04b='n_pos04b', n_pos04c='n_pos04c)
          if (n_pos04 > 0) & (n_pos04b > 0) & (n_pos04c > 0) & (n_pos04b <> n_pos04c) then n_pos04 = 0
       end
       if n_trace <= 2410 then call 9900_trace('2410 #06  n_pos04='format(n_pos04,5)', a_jobu.'format(i_jobu,5)'='s_line1)
       i_jobu_beg = n_pos04 + 1
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | write out the original line that contained the & symbolic with
    | the first two '//' bytes replaced with something that can be
    | easily identified.
    |---------------------------------------------------------------------------------------------------------------------*/
    i_jobu_beg    = 1
    i_joby        = i_joby + 1
    a_joby.i_joby = '++'substr(a_jobu.i_jobu, 3)

    /*--------------------------------------------------------------------------------------------------------------------
    | write out the resolved line
    |---------------------------------------------------------------------------------------------------------------------*/
    i_joby        = i_joby + 1
    a_joby.i_joby = s_line1
    if n_trace <= 2410 then call 9900_trace('2410 #07 a_joby.'i_joby'='a_joby.i_joby)

    return

/*------------------------------------------------------------------------------------------------------------------------*/
| scan the job for the symbolic variable definition
|------------------------------------------------------------------------------------------------------------------------*/
2420_Scan_Job_Line_for_Sym_Def:
    if n_trace <= 2420 then call 9900_trace('2420_Scan_Job_Line_for_Sym_Def')

    s_val = ''

    if n_trace <= 2420 then call 9900_trace('2420 #01 a_jobu.0='a_jobu.0)
    do i4 = 1 to a_jobu.0 until length(s_val) > 0
       if substr(a_jobu.i4, 1, 3) = '//*' then iterate i4
       if substr(a_jobu.i4, 1, 2) <> '//' then iterate i4
       if word(a_jobu.i4, 2) = 'EXEC' then leave i4
       s_val = 3100_Search_Jcl_Line(a_jobu.i4, s_sym, s_line1, n_pos04, n_pos05)
       if length(s_val) = 0 then iterate i4
       n_pos08 = pos('&'s_sym'..',s_line1)
       if n_trace <= 2420 then call 9900_trace('2420 #02  a_jobu.'i4'='a_jobu.i4)
       if n_trace <= 2420 then call 9900_trace('          s_line1  ='s_line1)
       if n_trace <= 2420 then call 9900_trace('          n_pos04  ='n_pos04)
       if n_trace <= 2420 then call 9900_trace('          n_pos05  ='n_pos05)
       if n_trace <= 2420 then call 9900_trace('          n_pos08  ='n_pos08)
       if n_trace <= 2420 then call 9900_trace('          s_sym    ='s_sym)
       if n_trace <= 2420 then call 9900_trace('          s_val    ='s_val)
       if n_trace <= 2420 then call 9900_trace('          i_keep   ='i_keep)
       select
         when n_pos08 > 0 then s_line1 = substr(s_line1, 1, n_pos04 - 1)||s_val||substr(s_line1, n_pos05 + 1)
         when n_pos04 = 0 then s_line1 =                                  s_val||substr(s_line1, n_pos05)
         otherwise             s_line1 = substr(s_line1, 1, n_pos04 - 1)||s_val||substr(s_line1, n_pos05 - i_keep)
       end
       if n_trace <= 2420 then call 9900_trace('2420 #03 s_line1='s_line1)
       /*-----------------------------------------------------------------------------------------------------------------'
       | get rid of double-periods when the value contains a period
       |------------------------------------------------------------------------------------------------------------------*/
       n_pos08 = pos(s_sym'..',s_line1)
       if n_pos08 > 0 then s_line1 = substr(s_line1, 1, n_pos08+length(s_sym))||substr(s_line1, n_pos08+length(s_sym)+2)
    end
    if n_trace <= 2420 then call 9900_trace('2420 #04 s_val='s_val', s_line1='s_line1)

    if length(s_val) = 0 then do
       i_joby        = i_joby + 1
       a_joby.i_joby = '?? Symbolic variable definition &'s_sym' <notfnd>'
    end

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2500_Process_Procs:
    if n_trace <= 2500 then call 9900_trace('2500_Process_Procs')

    /*--------------------------------------------------------------------------------------------------------------------
    | put proc into array
    |---------------------------------------------------------------------------------------------------------------------*/
    call 2510_Get_Proc

    if a_proc.0 = 0 then return

    /*--------------------------------------------------------------------------------------------------------------------
    | resolve proc symbolics
    |---------------------------------------------------------------------------------------------------------------------*/
    i_proc_beg = 1
    i_procy    = 0

    do i_proc=1 to a_proc.0
       call 2520_Resolve_Proc_Symbolics
    end
    a_procy.0 = i_procy

    if n_trace <= 9999 then call 9900_trace(' ')
    if n_trace <= 9999 then call 9900_trace('dump #8 - a_procy: resolved proc symbolics:'a_procy.0)
    if n_trace <= 9999 then do i=1 to a_procy.0
    /* n_trace <= 9999 */      call 9900_trace('        a_procy.'format(i,5)'='a_procy.i)
    /* n_trace <= 9999 */   end

    /*--------------------------------------------------------------------------------------------------------------------
    | concatenate proc to array
    |---------------------------------------------------------------------------------------------------------------------*/
    do i_procy=1 to a_procy.0
       i_jcl       = i_jcl + 1
       a_jcl.i_jcl = a_procy.i_procy
    end

    a_jcl.0 = i_jcl
    if n_trace <= 2500 then call 9900_trace('2500 #1 a_jcl.0='a_jcl.0)

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2510_Get_Proc:
    if n_trace <= 2510 then call 9900_trace('2510_Get_Proc')

    /*--------------------------------------------------------------------------------------------------------------------
    | Find the Proc's PDS
    |---------------------------------------------------------------------------------------------------------------------*/
    b_fnd_proc = 0

    do i_proclibs=1 to a_proclibs.0 until b_fnd_proc = 1
       parse var a_proclibs.i_proclibs s_proc_pds '(' s_proc_mem ')'
       if a_procs.i_procs = s_proc_mem then b_fnd_proc = 1
    end
    if n_trace <= 2510 then call 9900_trace('2510 #1 b_fnd_proc='b_fnd_proc', a_proclibs'i_proclibs'='a_proclibs.i_proclibs)

    if b_fnd_proc = 0 then do
       s_str1 = '==> Error: Job "'s_job_mem'" Proc "'a_procs.i_procs'" not found in proclibs'
       if n_trace <= 2510 then call 9900_trace('2510 #02 's_str1)
       say s_str1
       a_proc.0 = 0
       return
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | Get the Proc
    |---------------------------------------------------------------------------------------------------------------------*/
    "alloc ddn(indd1) dsn('"||a_proclibs.i_proclibs||"') shr reuse"
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error allocating INDD1 for 'a_proclibs.i_proclibs', rc='n_rc
       if n_trace <= 2510 then call 9900_trace('2510 #03 's_str1)
       say s_str1
       a_proc.0 = 0
       return
    end

    "execio * diskr indd1 (finis stem a_proc."
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error reading indd1 for 'a_proclibs.i_proclibs', rc='n_rc
       if n_trace <= 2510 then call 9900_trace('2510 #04 's_str1)
       say s_str1
       a_proc.0 = 0
       return
    end
    if n_trace <= 2510 then call 9900_trace('2510 #5 a_proc.0='a_proc.0)

    "free ddn(indd1)"
    n_rc = rc
    if n_trace <= 2510 then call 9900_trace('2510 #06 free rc='n_rc)
    if n_rc <> 0 then do
       say '==> error freeing indd1 for 'a_proclibs.i_proclibs', rc='n_rc
       return
    end

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2520_Resolve_Proc_Symbolics:
    if n_trace <= 2520 then call 9900_trace('2520_Resolve_Proc_Symbolics')

    /*--------------------------------------------------------------------------------------------------------------------
    | skip comments
    |---------------------------------------------------------------------------------------------------------------------*/
    if substr(a_proc.i_proc, 1, 3) = '//*' then do
       i_proc_beg      = 1
       i_procy         = i_procy + 1
       a_procy.i_procy = a_proc.i_proc
       return
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | drop columns 73-80
    |---------------------------------------------------------------------------------------------------------------------*/
    a_proc.i_proc = substr(a_proc.i_proc, 1, 72)
    if n_trace <= 2520 then call 9900_trace('2520 #1 a_proc.'i_proc'='a_proc.i_proc)

    /*--------------------------------------------------------------------------------------------------------------------
    | add job step to all proc steps
    |---------------------------------------------------------------------------------------------------------------------*/
    if word(a_proc.i_proc, 2) = 'EXEC' then n_pos_exec = pos(' EXEC ', a_proc.i_proc, 3)
    else                                    n_pos_exec = 0
    if n_pos_exec > 0 then do
       i_procy         = i_procy + 1
       a_procy.i_procy = '++'||substr(a_proc.i_proc, 3)
       a_proc.i_proc = '//'a_procs_jobstep.i_procs'.'substr(a_proc.i_proc, 3)
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | skip temp file names, ex: &&TEMPWK01
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos04 = pos('&&', a_proc.i_proc, i_proc_beg)
    if n_pos04 > 0 then i_proc_beg = n_pos04 + 2

    /*--------------------------------------------------------------------------------------------------------------------
    | check for line does NOT contain an &
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos04 = pos('&', a_proc.i_proc, i_proc_beg)
    if n_pos04 = 0 then do
       i_proc_beg      = 1
       i_procy         = i_procy + 1
       a_procy.i_procy = a_proc.i_proc
       return
    end
    if n_trace <= 2520 then call 9900_trace('2520 #2 i_proc_beg='i_proc_beg', n_pos04='n_pos04)

    /*--------------------------------------------------------------------------------------------------------------------
    | resolve all & symbolics in the line
    |---------------------------------------------------------------------------------------------------------------------*/
    if n_trace <= 2520 then call 9900_trace('2520 #03  n_pos04='format(n_pos04,5)', a_proc.'format(i_proc,5)'='a_proc.i_proc)
    s_line1 = a_proc.i_proc

    do while n_pos04 > 0
       s_arg = 3000_Extract_Symbolic_Name(n_pos04, s_line1)
       parse var s_arg s_sym ',' n_pos05 ',' i_keep
       if n_trace <= 2520 then call 9900_trace('2520 #04 s_sym='s_sym', n_pos05='n_pos05)
       call 2530_Scan_Proc_Line_for_Sym_Def
       n_pos04 = pos('&&', s_line1, i_proc_beg)
       if n_pos04 > 0 then i_proc_beg = n_pos04 + 2
       n_pos04 = pos('&', s_line1, i_proc_beg)
       if n_pos04 > 0 then do
          n_pos04b = pos(' ', s_line1, n_pos04 - 1)
          n_pos04c = pos(' ', s_line1, n_pos04 + 1)
          if n_trace <= 2520 then call 9900_trace('2520 #05 n_pos04='n_pos04', n_pos04b='n_pos04b', n_pos04c='n_pos04c)
          /*--------------------------------------------------------------------------------------------------------------
          |  the following "if" checks for '&' coded in a comment,
          |  ex: "//  sym='def'   * vals = 'xxx' & 'yyy'"
          |---------------------------------------------------------------------------------------------------------------*/
          if (n_pos04 > 0) & (n_pos04b > 0) & (n_pos04c > 0) & (n_pos04b <> n_pos04c) then n_pos04 = 0
       end
       if n_trace <= 2520 then call 9900_trace('2520 #06  n_pos04='format(n_pos04,5)', a_proc.'format(i_proc,5)'='s_line1)
       i_proc_beg = n_pos04 + 1
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | write out the original line that contained the & symbolic with
    | the first two '//' bytes replaced with something that can be
    | easily identified.
    |---------------------------------------------------------------------------------------------------------------------*/
    i_proc_beg      = 1
    i_procy         = i_procy + 1
    a_procy.i_procy = '++'substr(a_proc.i_proc, 3)

    /*--------------------------------------------------------------------------------------------------------------------
    | write out the resolved line
    |---------------------------------------------------------------------------------------------------------------------*/
    i_procy         = i_procy + 1
    a_procy.i_procy = s_line1
    if n_trace <= 2520 then call 9900_trace('2520 #07 a_procy.'i_procy'='a_procy.i_procy)

    return

/*------------------------------------------------------------------------------------------------------------------------
| scan the proc for the symbolic variable definition
|-------------------------------------------------------------------------------------------------------------------------*/
2530_Scan_Proc_Line_for_Sym_Def:
    if n_trace <= 2530 then call 9900_trace('2530_Scan_Proc_Line_for_Sym_Def')

    s_val = ''

    /*--------------------------------------------------------------------------------------------------------------------
    | first search the job for the symbolic variable definition
    |---------------------------------------------------------------------------------------------------------------------*/
    if n_trace <= 2530 then call 9900_trace('2530 #01 a_joby.0='a_joby.0', a_procs_joblno.i_procs='a_procs_joblno.i_procs)
    do i4 = 1 to a_joby.0 until length(s_val) > 0
       if n_trace <= 2530 then call 9900_trace('2530 #02 substr(a_joby.i4,1,3)='substr(a_joby.i4,1,3))
       if n_trace <= 2530 then call 9900_trace('          word(a_joby.i4,2)    ='word(a_joby.i4,2))
       if n_trace <= 2530 then call 9900_trace('          i4                   ='i4)
       if n_trace <= 2530 then call 9900_trace('          a_procs_joblno.'format(i_procs,5)'='a_procs_joblno.i_procs)
       if substr(a_joby.i4, 1, 3) = '//*' then iterate i4
       if substr(a_joby.i4, 1, 2) <> '//' then iterate i4
       if word(a_joby.i4, 2) = 'EXEC' then do
          if n_trace <= 2530 then call 9900_trace('          i4='i4', a_procs_joblno.'format(i_procs,5)'='a_procs_joblno.i_procs)
          if i4 > a_procs_joblno.i_procs then leave i4
          i4 = a_procs_joblno.i_procs
       end
       s_val = 3100_Search_Jcl_Line(a_joby.i4, s_sym, s_line1, n_pos04, n_pos05)
       if length(s_val) = 0 then iterate i4
       n_pos08 = pos('&'s_sym'..',s_line1)
       n_pos09 = pos('&'s_sym'.',s_line1)
       if n_trace <= 2530 then call 9900_trace('2530 #03  a_joby.'i4'='a_joby.i4)
       if n_trace <= 2530 then call 9900_trace('          s_line1  ='s_line1)
       if n_trace <= 2530 then call 9900_trace('          n_pos04  ='n_pos04)
       if n_trace <= 2530 then call 9900_trace('          n_pos05  ='n_pos05)
       if n_trace <= 2530 then call 9900_trace('          n_pos08  ='n_pos08)
       if n_trace <= 2530 then call 9900_trace('          s_sym    ='s_sym)
       if n_trace <= 2530 then call 9900_trace('          s_val    ='s_val)
       if n_trace <= 2530 then call 9900_trace('          i_keep   ='i_keep)
       select
         when n_pos08 > 0 then s_line1 = substr(s_line1, 1, n_pos04 - 1)||s_val||substr(s_line1, n_pos05 + 1)
         when n_pos09 > 0 then s_line1 = substr(s_line1, 1, n_pos04 - 1)||s_val||substr(s_line1, n_pos05 + 1)
         when n_pos04 = 0 then s_line1 =                                  s_val||substr(s_line1, n_pos05)
         otherwise             s_line1 = substr(s_line1, 1, n_pos04 - 1)||s_val||substr(s_line1, n_pos05 - i_keep)
       end
       if n_trace <= 2530 then call 9900_trace('2530 #04  s_line1='s_line1)
       /*-----------------------------------------------------------------------------------------------------------------
       | get rid of double-periods when the value contains a period
       |------------------------------------------------------------------------------------------------------------------*/
       n_pos08 = pos(s_sym'..',s_line1)
       if n_pos08 > 0 then s_line1 = substr(s_line1, 1, n_pos08+length(s_sym))||substr(s_line1, n_pos08+length(s_sym)+2)
       return
    end
    if n_trace <= 2530 then call 9900_trace('2530 #05 s_val='s_val', s_line1='s_line1)

    /*--------------------------------------------------------------------------------------------------------------------
    | then search the proc for the symbolic variable definition
    |---------------------------------------------------------------------------------------------------------------------*/
    if n_trace <= 2530 then call 9900_trace('2530 #06 a_proc.0='a_proc.0)
    do i4 = 1 to a_proc.0 until length(s_val) > 0
       if substr(a_proc.i4, 1, 3) = '//*' then iterate i4
       if substr(a_proc.i4, 1, 2) <> '//' then iterate i4
       if word(a_proc.i4, 2) = 'EXEC' then leave i4
       s_val = 3100_Search_Jcl_Line(a_proc.i4, s_sym, s_line1, n_pos04, n_pos05)
       if length(s_val) = 0 then iterate i4
       n_pos08 = pos('&'s_sym'..',s_line1)
       n_pos09 = pos('&'s_sym'.',s_line1)
       if n_trace <= 2530 then call 9900_trace('2530 #07  a_proc.'i4'='a_proc.i4)
       if n_trace <= 2530 then call 9900_trace('          s_line1  ='s_line1)
       if n_trace <= 2530 then call 9900_trace('          n_pos04  ='n_pos04)
       if n_trace <= 2530 then call 9900_trace('          n_pos05  ='n_pos05)
       if n_trace <= 2530 then call 9900_trace('          n_pos08  ='n_pos08)
       if n_trace <= 2530 then call 9900_trace('          s_sym    ='s_sym)
       if n_trace <= 2530 then call 9900_trace('          s_val    ='s_val)
       if n_trace <= 2530 then call 9900_trace('          i_keep   ='i_keep)
       select
         when n_pos08 > 0 then s_line1 = substr(s_line1, 1, n_pos04 - 1)||s_val||substr(s_line1, n_pos05 + 1)
         when n_pos09 > 0 then s_line1 = substr(s_line1, 1, n_pos04 - 1)||s_val||substr(s_line1, n_pos05 + 1)
         when n_pos04 = 0 then s_line1 =                                  s_val||substr(s_line1, n_pos05)
         otherwise             s_line1 = substr(s_line1, 1, n_pos04 - 1)||s_val||substr(s_line1, n_pos05)
       end
       if n_trace <= 2530 then call 9900_trace('2530 #08  s_line1='s_line1)
       /*-----------------------------------------------------------------------------------------------------------------
       | get rid of double-periods when the value contains a period
       |------------------------------------------------------------------------------------------------------------------*/
       n_pos08 = pos(s_sym'..',s_line1)
       if n_pos08 > 0 then s_line1 = substr(s_line1, 1, n_pos08+length(s_sym))||substr(s_line1, n_pos08+length(s_sym)+2)
       return
    end
    if n_trace <= 2530 then call 9900_trace('2530 #09 s_val='s_val', s_line1='s_line1)

    /*--------------------------------------------------------------------------------------------------------------------
    | if we get here then the symbolic variable's definition was not found
    |---------------------------------------------------------------------------------------------------------------------*/
    i_procy         = i_procy + 1
    a_procy.i_procy = '?? Symbolic variable definition 's_sym' <notfnd>'

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2600_Merge_Sysins:
    if n_trace <= 2600 then call 9900_trace('2600_Merge_Sysins')

    s_jcl = a_jcl.i_jcl

    i_mrg       = i_mrg + 1
    a_mrg.i_mrg = strip(s_jcl)

    if substr(s_jcl, 1, 3) = '//*' then return
    if substr(s_jcl, 1, 2) <> '//' then return
    if n_trace <= 2600 then call 9900_trace('2600 #00 i_jcl='i_jcl', s_jcl='s_jcl)

    /*--------------------------------------------------------------------------------------------------------------------
    |  see if the record contains a SYSIN or SYSTSIN DD card
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos01 = pos('//SYSIN', s_jcl, 1)

    if n_pos01 = 0 then n_pos01 = pos('//SYSTSIN', s_jcl, 1)
    if n_pos01 = 0 then n_pos01 = pos('.SYSIN'   , s_jcl, 1)
    if n_pos01 = 0 then n_pos01 = pos('.SYSTSIN' , s_jcl, 1)

    if n_pos01 = 0 then return
    if n_trace <= 2600 then call 9900_trace('2600 #01 n_pos01='n_pos01', a_jcl.'i_jcl'='s_jcl)

    /*--------------------------------------------------------------------------------------------------------------------
    |  see if the record contains a DSN= card
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos02 = pos('DSN=', s_jcl, 1)
    if n_pos02 = 0 then return
    if n_trace <= 2600 then call 9900_trace('2600 #02 n_pos02='n_pos02)

    n_pos03 = pos(',', s_jcl, n_pos02 + 4)
    if n_pos03 = 0 then n_pos03 = pos(' ', s_jcl, n_pos02 + 4)
    if n_trace <= 2600 then call 9900_trace('2600 #03 n_pos03='n_pos03)

    if n_pos03 = 0 then s_dsn1 = substr(s_jcl, n_pos02 + 4)
    else                s_dsn1 = substr(s_jcl, n_pos02 + 4, n_pos03 - n_pos02 - 4)
    if n_trace <= 2600 then call 9900_trace('2600 #04 n_pos02='n_pos02', n_pos03='n_pos03', s_dsn1='s_dsn1)

    if substr(s_dsn1,1,1) = "'" then dsn2 =      s_dsn1
    else                             dsn2 = "'"||s_dsn1||"'"

    call 2610_Copy_Sysin

    return

/*------------------------------------------------------------------------------------------------------------------------*/
2610_Copy_Sysin:
    if n_trace <= 2610 then call 9900_trace('2610_Copy_Sysin')

    /*--------------------------------------------------------------------------------------------------------------------
    | some jobs/programs have a DD referencing an entire pds (without a member), so skip them
    |---------------------------------------------------------------------------------------------------------------------*/
    if dsn2 = "'PROD.SYSIN'" then return
    if dsn2 = "'FBACK.SYSIN'" then return

    /*--------------------------------------------------------------------------------------------------------------------
    | skip tempoary dataset names
    |---------------------------------------------------------------------------------------------------------------------*/
    if pos('&&', dsn2) > 0 then return

    /*--------------------------------------------------------------------------------------------------------------------
    | change +1 gdg's to 0, so we can get the latest file
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos12 = pos('(+1)', dsn2)
    if n_pos12 > 0 then do
       dsn2 = substr(dsn2, 1, n_pos12)'0)'
       if substr(dsn2, 1, 1) = "'" then dsn2 = dsn2"'"
    end
    if n_trace <= 2610 then call 9900_trace('2610 #01 dsn2={'dsn2'}')

    /*--------------------------------------------------------------------------------------------------------------------
    | change +1 gdg's to 0, so we can get the latest file
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos12 = pos('(0)', dsn2)
    if n_pos12 > 0 then do
       dsn3 = substr(dsn2, 1, n_pos12-1)"'"
       call outtrap a_listcat.
       "listcat lvl("dsn3")"
       call outtrap off
       if n_trace <= 2610 then call 9900_trace('2610 #02 a_listcat.0='a_listcat.0)
       if n_trace <= 2610 then do i=1 to a_listcat.0
       /* n_trace <= 2610 */      call 9900_trace('2610 #02b a_listcat.'i'={'a_listcat.i'}')
       /* n_trace <= 2610 */   end
       i_listcat = a_listcat.0 - 1
       dsn2 = "'"word(a_listcat.i_listcat,3)"'"
    end
    if n_trace <= 2610 then call 9900_trace('2610 #03 dsn2={'dsn2'}')

    /*--------------------------------------------------------------------------------------------------------------------
    | allocate the dataset
    |---------------------------------------------------------------------------------------------------------------------*/
    "alloc ddn(indd3) dsn("||dsn2||") shr reuse"
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error allocating INDD3 for 'dsn2', rc='n_rc', s_job_mem='s_job_mem', s_proc_name='s_proc_name
       if n_trace <= 2610 then call 9900_trace('2610 #04 's_str1)
       say s_str1
       i_mrg       = i_mrg + 1
       a_mrg.i_mrg = '## Error Allocating SYSIN:'dsn2', rc='n_rc
       return
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | read the entire file into an array
    |---------------------------------------------------------------------------------------------------------------------*/
    "execio * diskr indd3 (finis stem a_sysin."
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error reading indd3 for 'dsn2', rc='n_rc', s_job_mem='s_job_mem', s_proc_name='s_proc_name
       if n_trace <= 2610 then call 9900_trace('2610 #05 's_str1)
       say s_str1
       i_mrg       = i_mrg + 1
       a_mrg.i_mrg = '## Error Reading SYSIN:'dsn2', rc='n_rc
       return
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | free the dataset
    |---------------------------------------------------------------------------------------------------------------------*/
    "free ddn(indd3)"
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error freeing indd3 for 'dsn2', rc='n_rc', s_job_mem='s_job_mem', s_proc_name='s_proc_name
       if n_trace <= 2610 then call 9900_trace('2610 #06 's_str1)
       say s_str1
       i_mrg       = i_mrg + 1
       a_mrg.i_mrg = '## Error Freeing SYSIN:'dsn2', rc='n_rc
       return
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | concatenate the file to the jcl
    |---------------------------------------------------------------------------------------------------------------------*/
    do i4=1 to a_sysin.0
       i_mrg       = i_mrg + 1
       a_mrg.i_mrg = a_sysin.i4
    end
    if n_trace <= 2610 then call 9900_trace('2610 #07 a_sysin.0='a_sysin.0)

    return

/*------------------------------------------------------------------------------------------------------------------------
| function
| input(s) : n_pos     = the position of the first '&' in the line
|            s_line    = the JCL line
| output(s): s_sym     = the symbolic variable name
|            n_pos_end = the position of the end of the & symbolic name
|-------------------------------------------------------------------------------------------------------------------------*/
3000_Extract_Symbolic_Name: procedure expose n_trace
    arg n_pos_beg, s_jcl_line
    if n_trace <= 3000 then call 9900_trace('3000_Extract_Symbolic_Name')
    if n_trace <= 3000 then call 9900_trace('3000 #01 n_pos_beg='n_pos_beg', s_jcl_line='s_jcl_line)

    /*--------------------------------------------------------------------------------------------------------------------
    | init local variables used by this function
    |---------------------------------------------------------------------------------------------------------------------*/
    i_keep    = 0
    i1        = 0
    n_pos_end = 0
    s_chr     = ''

    /*--------------------------------------------------------------------------------------------------------------------
    | find the end of the symbolic name
    |---------------------------------------------------------------------------------------------------------------------*/
    s_jcl_line = s_jcl_line' '

    do i1=n_pos_beg+1 to length(s_jcl_line)+1
       s_chr = substr(s_jcl_line, i1, 1)
       select
         when s_chr = ',' then nop
         when s_chr = '&' then nop
         when s_chr = "'" then nop
         when s_chr = '(' then i_keep = 1
         when s_chr = ')' then nop
         when s_chr = '.' then nop
         when s_chr = ' ' then nop
         otherwise             iterate i1
      end
      n_pos_end = i1
      leave i1
    end
    if n_trace <= 3000 then call 9900_trace('3000 #02 n_pos_end='n_pos_end)

    if n_pos_end = 0 then do
       s_str1 = '==> logic error #1: s_jcl_line   ={'s_jcl_line'}'
       s_str2 = '                    n_pos_beg    ={'n_pos_beg'}'
       s_str3 = '                    n_pos_end    ={'n_pos_end'}'
       s_str4 = '                    s_chr        ={'s_chr'}'
       s_str5 = '                    i1           ={'i1'}'
       say s_str1
       say s_str2
       say s_str3
       say s_str4
       say s_str5
       if n_trace <= 3000 then call 9900_trace('3000 #03 's_str1)
       if n_trace <= 3000 then call 9900_trace('         's_str2)
       if n_trace <= 3000 then call 9900_trace('         's_str3)
       if n_trace <= 3000 then call 9900_trace('         's_str4)
       if n_trace <= 3000 then call 9900_trace('         's_str5)
       exit
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | extract the symbolic name from the line
    |---------------------------------------------------------------------------------------------------------------------*/
    s_sym = substr(s_jcl_line, n_pos_beg + 1, n_pos_end - n_pos_beg - 1)
    if n_trace <= 3000 then call 9900_trace('3000 #04 s_sym='s_sym)

    return s_sym','n_pos_end','i_keep

/*------------------------------------------------------------------------------------------------------------------------
| function
| input(s) : s_jcl_line = the current a_jobu line we are testing
|            s_sym_line = the original a_jobu line that we found a '&' on
|            s_sym      = the symbolic variable name
|            n_pos_beg  = the start of the symbolic variable on the job line
|            n_pos_end  = the end   of the symbolic variable on the job line
| output(s): s_val      = the symbolic variable definition
|-------------------------------------------------------------------------------------------------------------------------*/
3100_Search_Jcl_Line: procedure expose n_trace
    arg s_jcl_line, s_sym, s_sym_line, n_pos_beg, n_pos_end
    if n_trace <= 3100 then call 9900_trace('3100_Search_Jcl_Line')
/*
    if n_trace <= 3100 then call 9900_trace('3100 #01 s_jcl_line='s_jcl_line)
    if n_trace <= 3100 then call 9900_trace('         s_sym     ='s_sym)
    if n_trace <= 3100 then call 9900_trace('         s_sym_line='s_sym_line)
    if n_trace <= 3100 then call 9900_trace('         n_pos_beg='n_pos_beg)
    if n_trace <= 3100 then call 9900_trace('         n_pos_end='n_pos_end)
*/
    /*--------------------------------------------------------------------------------------------------------------------
    | init variables used by this function
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos_sym_start = 0
    n_pos_sym_beg   = 0
    n_pos_sym_end   = 0

    s_val           = ''

    /*--------------------------------------------------------------------------------------------------------------------
    | skip jcl comments
    |---------------------------------------------------------------------------------------------------------------------*/
    if substr(s_jcl_line, 1, 3) = '//*' then return ''

    /*--------------------------------------------------------------------------------------------------------------------
    | check for the line contains the symbolic variable name=definition
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos_sym_start = pos(','||s_sym||'=', s_jcl_line, 1)
    if n_pos_sym_start = 0 then n_pos_sym_start = pos(' '||s_sym||'=', s_jcl_line, 1)
    if n_pos_sym_start = 0 then return ''

    if n_trace <= 3100 then call 9900_trace('3100 #02  n_pos_sym_start='n_pos_sym_start)

    /*--------------------------------------------------------------------------------------------------------------------
    | identify the postion of where the defintion begins
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos_sym_beg = pos('=', s_jcl_line, n_pos_sym_start)
    if n_trace <= 3100 then call 9900_trace('3100 #03 n_pos_sym_beg='n_pos_sym_beg)

    /*--------------------------------------------------------------------------------------------------------------------
    | identify the postion of where the defintion ends
    |---------------------------------------------------------------------------------------------------------------------*/
    n_pos_sym_end = pos(',', s_jcl_line, n_pos_sym_beg+1)
    if n_trace <= 3100 then call 9900_trace('3100 #04 n_pos_sym_end='n_pos_sym_end)

    if n_pos_sym_end = 0 then n_pos_sym_end = pos(' ', s_jcl_line, n_pos_sym_beg+1)
    if n_trace <= 3100 then call 9900_trace('3100 #05 n_pos_sym_start='n_pos_sym_start', n_pos_sym_end='n_pos_sym_end)

    if n_pos_sym_end = 0 then do
       s_str1 = '==> logic error #2: s_jcl_line     ={'s_jcl_line'}'
       s_str2 = '                    s_sym          ={'s_sym'}'
       s_str3 = '                    s_sym_line     ={'s_sym_line'}'
       s_str4 = '                    n_pos_beg      ={'n_pos_beg'}'
       s_str5 = '                    n_pos_end      ={'n_pos_end'}'
       s_str6 = '                    n_pos_sym_start={'n_pos01'}'
       s_str7 = '                    n_pos_sym_beg  ={'n_pos02'}'
       s_str8 = '                    n_pos_sym_end  ={'n_pos03'}'
       say s_str1
       say s_str2
       say s_str3
       say s_str4
       say s_str5
       say s_str6
       say s_str7
       say s_str8
       if n_trace <= 3100 then call 9900_trace('3100 #06 's_str1)
       if n_trace <= 3100 then call 9900_trace('         's_str2)
       if n_trace <= 3100 then call 9900_trace('         's_str3)
       if n_trace <= 3100 then call 9900_trace('         's_str4)
       if n_trace <= 3100 then call 9900_trace('         's_str5)
       if n_trace <= 3100 then call 9900_trace('         's_str6)
       if n_trace <= 3100 then call 9900_trace('         's_str7)
       if n_trace <= 3100 then call 9900_trace('         's_str8)
       exit
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | extract the symbolic definition
    |---------------------------------------------------------------------------------------------------------------------*/
    s_str2 = substr(s_jcl_line, n_pos_sym_beg + 1, n_pos_sym_end - n_pos_sym_beg - 1)
    if n_trace <= 3100 then call 9900_trace('3100 #07 s_str2='s_str2)

    /*--------------------------------------------------------------------------------------------------------------------
    | check whether the definition is in quotes
    |---------------------------------------------------------------------------------------------------------------------*/
    s_str2 = strip(s_str2,'b',"'")
    if n_trace <= 3100 then call 9900_trace('3100 #08 s_str2='s_str2)

    /*--------------------------------------------------------------------------------------------------------------------
    | get rid of any comments after the definition
    |---------------------------------------------------------------------------------------------------------------------*/
    parse var s_str2 s_val ' '
    s_val = strip(s_val,'b',"'")
    if n_trace <= 3100 then call 9900_trace('3100 #08 s_val='s_val)

    return s_val

/*------------------------------------------------------------------------------------------------------------------------*/
5000_Build_Xref:
    if n_trace <= 5000 then call 9900_trace('5000_Build_Xref')

    s_xref = ''

    /*--------------------------------------------------------------------------------------------------------------------
    |  extract datasets and their DISP
    |---------------------------------------------------------------------------------------------------------------------*/
     if b_heading = 0 then do
        b_heading = 1
        s_xref    =           left('Job Mem'  ,  8)
        s_xref    = s_xref', 'left('UCC7 ID'  ,  7)
        s_xref    = s_xref', 'left('Proc Mem' ,  8)
        s_xref    = s_xref', 'left('Proc Step',  9)
        s_xref    = s_xref', 'left('Type'     ,  4)
        s_xref    = s_xref', 'left('Exec'     ,  8)
        s_xref    = s_xref', 'left('DB2 Pgm'  ,  8)
        s_xref    = s_xref', 'left('Disp'     ,  8)
        s_xref    = s_xref', 'left('Dataset'  , 60)
        s_xref    = s_xref', 'left('Job PDS'  , 44)
        s_xref    = s_xref', 'left('Jobname'  ,  8)
        s_xref    = s_xref', 'left('Proc PDS' , 44)
        s_xref    = s_xref', 'left('Procname' ,  8)
        s_xref    = s_xref', 'left('Genname ' ,  8)
        i_xref    = 1
        a_xref.1  = s_xref
     end

     s_dsn1      = ''
     s_proc_step = ''
     s_type      = ''
     s_exec      = ''
     s_db2pgm    = ''

    if n_trace <= 5000 then call 9900_trace('5000 #01 a_mrg.0='a_mrg.0)
    do i_mrg = 1 to a_mrg.0
       s_dsn1 = ''
       call 5100_Extract_Datasets
       if length(s_dsn1) > 0 then do
          s_xref        =           left(s_job_mem        , 8)
          s_xref        = s_xref', 'left(a_ucc7_id.i_ucc7 , 7)
          s_xref        = s_xref', 'left(s_proc_mem       , 8)
          s_xref        = s_xref', 'left(s_proc_step      , 9)
          s_xref        = s_xref', 'left(s_type           , 4)
          s_xref        = s_xref', 'left(s_exec           , 8)
          s_xref        = s_xref', 'left(s_db2pgm         , 8)
          s_xref        = s_xref', 'left(s_disp           , 8)
          s_xref        = s_xref', 'left(s_dsn1           , 60)
          s_xref        = s_xref', 'left(s_job_pds        , 44)
          s_xref        = s_xref', 'left(s_job_name       , 8)
          s_xref        = s_xref', 'left(s_proc_pds       , 44)
          s_xref        = s_xref', 'left(s_proc_name      , 8)
          s_xref        = s_xref', 'left(s_out_mem        , 8)
          i_xref        = i_xref + 1
          a_xref.i_xref = s_xref
          if n_trace <= 5000 then call 9900_trace('5000 #02 a_xref.'i_xref'='a_xref.i_xref)
       end
    end
    a_xref.0 = i_xref
    if n_trace <= 5000 then call 9900_trace('5000 #03 a_xref.0='a_xref.0)

    return

/*------------------------------------------------------------------------------------------------------------------------*/
5100_Extract_Datasets:
    if n_trace <= 5100 then call 9900_trace('5100_Extract_Datasets')

    s_mrg_dsn_line = a_mrg.i_mrg

    if substr(s_mrg_dsn_line, 1, 3) = '//*' then return
    if substr(s_mrg_dsn_line, 1, 2) <> '//' then return

    if word(s_mrg_dsn_line,2) = 'EXEC' then n_pos02 = pos(' EXEC ', s_mrg_dsn_line, 1)
    else                                    n_pos02 = 0

    if n_pos02 > 0 then do
       s_arg = strip(substr(s_mrg_dsn_line, 3, n_pos02 - 3))
       parse var s_arg s_job_step '.' s_proc_step
       if n_trace <= 5100 then call 9900_trace('5100 #01 s_proc_step='s_proc_step', n_pos02='n_pos02', a_mrg.'i_mrg'='s_mrg_dsn_line)
       s_line1 = strip(substr(s_mrg_dsn_line, n_pos02 + 5))' '
       if n_trace <= 5100 then call 9900_trace('5100 #02 s_line1='s_line1)
       n_pos02 = pos(',', s_line1, 1)
       if n_pos02 = 0 then n_pos02 = pos(' ', s_line1, 1)
       if n_trace <= 5100 then call 9900_trace('5100 #03 n_pos02='n_pos02)
       if n_pos02 = 0 then do
          s_type   = ''
          s_exec   = '<NOTFND>'
          s_db2pgm = ''
          if n_trace <= 5100 then call 9900_trace('5100 #04 s_type='s_type', s_exec='s_exec)
          return
       end
       if substr(s_line1, 1, 4) = 'PGM=' then do
          s_type   = 'PGM'
          s_exec   = substr(s_line1, 5, n_pos02 - 5)
          s_db2pgm = ''
          if n_trace <= 5100 then call 9900_trace('5100 #05 s_type='s_type', s_exec='s_exec)
          if s_exec = 'IKJEFT01' then do
             do i2=i_mrg+1 to a_mrg.0 until s_db2pgm > ''
                call 5110_Extract_Pgm
             end
          end
          return
       end
       s_type = 'PROC'
       if substr(s_line1, 1, 5) = 'PROC=' then
          s_exec = strip(substr(s_line1, 6, n_pos02 - 6))
       else
          s_exec = strip(s_line1)
       s_exec = strip(s_exec,,',')
       if n_trace <= 5100 then call 9900_trace('5100 #06 s_type='s_type', s_exec='s_exec)
       s_db2pgm = ''
       return
    end

    if pos('&&', s_mrg_dsn_line, 1) > 0 then return

    n_pos02 = pos('DSN=', s_mrg_dsn_line, 1)
    if n_trace <= 5100 then call 9900_trace('5100 #07 n_pos02='n_pos02', a_mrg.'i_mrg'='s_mrg_dsn_line)

    if n_pos02 = 0 then return

    n_pos03 = pos(',', s_mrg_dsn_line, n_pos02 + 4)
    if n_pos03 = 0 then n_pos03 = pos(' ', s_mrg_dsn_line, n_pos02 + 4)
    if n_trace <= 5100 then call 9900_trace('5100 #08 n_pos03='n_pos03)

    if n_pos03 = 0 then s_dsn1 = substr(s_mrg_dsn_line, n_pos02 + 4)
    else                s_dsn1 = substr(s_mrg_dsn_line, n_pos02 + 4, n_pos03 - n_pos02 - 4)
    if n_trace <= 5100 then call 9900_trace('5100 #09 n_pos02='n_pos02', n_pos03='n_pos03', s_dsn1='s_dsn1)
    if n_trace <= 5100 then call 9900_trace('5100 #10 s_dsn1='s_dsn1)

    s_disp = ''
    i_retry = 1
    do i2=i_mrg to a_mrg.0 until s_disp > ''
       call 5120_Extract_Disp
    end
    if n_trace <= 5100 then call 9900_trace('5100 #11 s_disp='s_disp)

    if s_disp='<NOTFND>' | s_disp='' then do
       s_disp = ''
       i_retry = 0
       do i2=i_mrg to i_mrg-10 by -1 until s_disp > ''
          call 5120_Extract_Disp
       end
    end
    if n_trace <= 5100 then call 9900_trace('5100 #12 s_disp='s_disp)

    if s_disp = '' then s_disp = '<NOTFND>'

    return

/*------------------------------------------------------------------------------------------------------------------------*/
5110_Extract_Pgm:
    if n_trace <= 5110 then call 9900_trace('5110_Extract_Pgm')

    s_mrg = a_mrg.i2

    if n_trace <= 5110 then call 9900_trace('5110 #01 a_mrg.'i2'='s_mrg)
    if substr(s_mrg, 1, 3) = '//*' then return
    if substr(s_mrg, 1, 2) = '++'  then return

    if word(s_mrg,2) = 'EXEC' then do
       s_db2pgm = '<NOTFND>'
       if n_trace <= 5110 then call 9900_trace('5110 #02 EXEC found, s_db2pgm='s_db2pgm)
       return
    end

    if substr(s_mrg, 1, 2) = '//' then return

    if word(s_mrg, 1) <> 'RUN' then return
    if n_trace <= 5110 then call 9900_trace('5110 #03 RUN found')

    if substr(word(s_mrg, 2), 1, 7) <> 'PROGRAM' then return
    if n_trace <= 5110 then call 9900_trace('5110 #04 PROGRAM found')

    n_pos03 = pos('(', s_mrg, 1)
    n_pos04 = pos(')', s_mrg, n_pos03+1)
    if n_trace <= 5110 then call 9900_trace('5110 #05 n_pos03='n_pos03', n_pos04='n_pos04)
    if n_pos03=0 | n_pos04=0 then return

    s_db2pgm = substr(s_mrg, n_pos03+1, n_pos04-n_pos03-1)
    if n_trace <= 5110 then call 9900_trace('5110 #06 s_db2pgm='s_db2pgm)

    return

/*------------------------------------------------------------------------------------------------------------------------*/
5120_Extract_Disp:
    if n_trace <= 5120 then call 9900_trace('5120_Extract_Disp')
    if n_trace <= 5120 then call 9900_trace('5120 #01 a_mrg.'i2'='a_mrg.i2)

    s_mrg = a_mrg.i2

    if substr(s_mrg, 1, 3) = '//*' then return
    if substr(s_mrg, 1, 3) = '++'  then return
    if substr(s_mrg, 1, 1) = ' '   then return

    if i_retry>=1 & i2<>i_mrg then do
       i_retry = i_retry + 1
       n_pos03 = pos(' DD ', s_mrg, 1)
       if n_pos03 = 0 then do
          if word(s_mrg,2) = 'EXEC' then n_pos03 = pos(' EXEC ', s_mrg, 1)
       end
       if n_pos03 = 0 then do
          if word(s_mrg,2) = 'PROC' then n_pos03 = pos(' PROC ', s_mrg, 1)
       end
       if n_pos03 > 0 then do
          s_disp = '<NOTFND>'
          if n_trace <= 5120 then call 9900_trace('5120 #02 n_pos03='n_pos03', s_disp='s_disp', a_mrg.'i_mrg'='a_mrg.i_mrg)
          return
       end
    end

    n_pos03 = pos('DISP=', s_mrg, 1)
    if n_pos03 = 0 then return

    n_pos03 = pos('DISP=SHR', s_mrg, 1)
    if n_pos03 = 0 then n_pos03 = pos('DISP=(SHR,', s_mrg, 1)
    if n_pos03 > 0 then do
       s_disp = 'SHR'
       if n_trace <= 5120 then call 9900_trace('5120 #03 n_pos03='n_pos03', s_disp='s_disp', a_mrg.'i_mrg'='a_mrg.i_mrg)
       return
    end

    n_pos03 = pos('DISP=MOD', s_mrg, 1)
    if n_pos03 = 0 then n_pos03 = pos('DISP=(MOD,', s_mrg, 1)
    if n_pos03 > 0 then do
       s_disp = 'MOD'
       if n_trace <= 5120 then call 9900_trace('5120 #04 n_pos03='n_pos03', s_disp='s_disp', a_mrg.'i_mrg'='a_mrg.i_mrg)
       return
    end

    n_pos03 = pos('DISP=OLD', s_mrg, 1)
    if n_pos03 = 0 then n_pos03 = pos('DISP=(OLD,', s_mrg, 1)
    if n_pos03 > 0 then do
       s_disp = 'OLD'
       if n_trace <= 5120 then call 9900_trace('5120 #05 n_pos03='n_pos03', s_disp='s_disp', a_mrg.'i_mrg'='a_mrg.i_mrg)
       return
    end

    n_pos03 = pos('DISP=(NEW', s_mrg, 1)
    if n_pos03 = 0 then n_pos03 = pos('DISP=(,', s_mrg, 1)
    if n_pos03 > 0 then do
       s_disp = 'NEW'
       if n_trace <= 5120 then call 9900_trace('5120 #06 n_pos03='n_pos03', s_disp='s_disp', a_mrg.'i_mrg'='a_mrg.i_mrg)
       return
    end

    return

/*------------------------------------------------------------------------------------------------------------------------*/
6000_Write_and_Reset:
    if n_trace <= 6000 then call 9900_trace('6000_Write_and_Reset')

   "execio * diskw outdd4 (finis stem a_index."
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error writing outdd4 for 's_out_index', rc='n_rc', a_index.0='a_index.0
       if n_trace <= 6000 then call 9900_trace('6000 #01 's_str1)
       say s_str1
    end

    /*--------------------------------------------------------------------------------------------------------------------
    | the arrays must be initialized to '' or otherwise a succeeding write will write out left-over data, because execio
    | diskw does not use the array.0 value to determine how many lines to write unless you specify "execio a_xref.0", but
    | instead stops when it hits a null value ''.
    |---------------------------------------------------------------------------------------------------------------------*/
    "execio * diskw outdd2 (stem a_xref."
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error writing outdd2 for 's_xref_ds', rc='n_rc', a_xref.0='a_xref.0
       if n_trace <= 6000 then call 9900_trace('6000 #02 's_str1)
       say s_str1
    end
    a_xref.=''

    s_out_pds_mem = s_out_pds'('s_out_mem')'
    if n_trace <= 6000 then call 9900_trace('6000 #3 s_out_mem='s_out_mem', n_gen='n_gen)

    "alloc ddn(outdd3) dsn('"s_out_pds_mem"') shr"
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error allocating OUTDD3 for 's_out_pds_mem', rc='n_rc
       if n_trace <= 6000 then call 9900_trace('6000 #04 's_str1)
       say s_str1
       return
    end

    "execio * diskw outdd3 (finis stem a_mrg."
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error writing 's_job_mem' outdd3 for 's_out_pds_mem', rc='n_rc', a_mrg.0='a_mrg.0
       if n_trace <= 6000 then call 9900_trace('6000 #05 's_str1)
       say s_str1
    end
    a_mrg.=''

    "free ddn(outdd3)"
    n_rc = rc
    if n_rc <> 0 then do
       s_str1 = '==> error freeing outdd3 for 's_out_pds_mem', rc='n_rc
       if n_trace <= 6000 then call 9900_trace('6000 #06 's_str1)
       say s_str1
    end

    i_jobu    = 0
    i_jcl     = 0
    i_mrg     = 0
    i_xref    = 0
    a_index.0 = 0
    a_jobu.0  = 0
    a_jcl.0   = 0
    a_mrg.0   = 0
    a_xref.0  = 0

    return

/*------------------------------------------------------------------------------------------------------------------------*/
9000_Done:
    if n_trace <= 9000 then call 9900_trace('9000_Done')

   call msg off
   "execio 0 diskw outdd4 (finis"
   "free ddn(outdd4)"

   "execio 0 diskw outdd2 (finis"
   "free ddn(outdd2)"

   if n_trace > 0 then do
      "execio 0 diskw outdd1 (finis"
      "free ddn(outdd1)"
   end
   call msg on

   return

/*------------------------------------------------------------------------------------------------------------------------*/
9900_trace: procedure expose n_trace
    arg s_trace

    if datatype(n_trace,'N') > 0 then do
       a_trace.1 = s_trace
       "execio 1 diskw outdd1 (stem a_trace."
    end
    else do
       say s_trace
    end

    return

