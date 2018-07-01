Stack elements of an array when element equals one

 This type of problem lends itself to a matrix like language?

  Three Solutions

      1. %do_over  (have not ported %do_over to WPS)
      2. do over (same result in WPS and SAS)
      3. WPS Proc R ot IML/R  (nice)
      
 Recent SAS/IML Addition on end
 by Rick Wicklin via listserv.uga.edu
     
github
https://tinyurl.com/ydymlyyo
https://github.com/rogerjdeangelis/utl_stack_elements_of_an_array_when_element_equals_one

https://tinyurl.com/ybu9235n
https://stackoverflow.com/questions/51092121/r-collapse-multiple-boolean-columns-into-single-attribute-column-with-new-rows

see Onyambu profile
https://stackoverflow.com/users/8380272/onyambu

INPUT
=====

  SD1.HAVE total obs=10

     A      S1    S2    S3    S4

    ex1      1     0     0     0
    ex2      0     1     0     0
    ex3      0     0     1     0
    ex4      1     1     0     0
    ex5      0     1     0     1
    ex6      0     1     0     0
    ex7      1     1     1     0
    ex8      0     1     1     0
    ex9      0     0     1     0
    ex10     1     0     0     0

 EXAMPLE OUTPUT

 WORK.WANT            RULES

   A      IND   |   A      S1
                |
  ex1     S1    |  ex1      1  Keep
  ex4     S1    |  ex2      0
  ex7     S1    |  ex3      0
  ex10    S1    |  ex4      1  Keep
                |  ex5      0
                |  ex6      0
                |  ex7      1  Keep
                |  ex8      0
                |  ex9      0
                |  ex10     1  Keep


PROCESS
=======

    1. %do_over

       data want;
         set sd1.have;
         %array(ss,values=1-4);
         %do_over(ss,phrase=%str(if s? = 1 then do; type="S?";output;end;));
         drop s:;
       run;quit;

    2. do over

       data want;
         set sd1.have;
         array ss s:;
         do over ss;
           if ss=1 then do;
              typ=vname(ss);
              output;
           end;
         end;
         keep a typ;
       run;quit;


    3. WPS Proc R ot IML/R

       * nice R solution - all base statemnts;
       * retain A and stack s1-s4 when a 1 appears;

       subset(cbind(A=dat[,1],stack(dat[-1])),values==1,-2)


OUTPUT
======

 WORK.WANT total obs=15

     A      TYP

    ex1     S1
    ex2     S2
    ex3     S3
    ex4     S1
    ex4     S2
    ex5     S2
    ex5     S4
    ex6     S2
    ex7     S1
    ex7     S2
    ex7     S3
    ex8     S2
    ex8     S3
    ex9     S3
    ex10    S1

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input A$ S1 S2 S3 S4;
cards4;
ex1 1 0 0 0
ex2 0 1 0 0
ex3 0 0 1 0
ex4 1 1 0 0
ex5 0 1 0 1
ex6 0 1 0 0
ex7 1 1 1 0
ex8 0 1 1 0
ex9 0 0 1 0
ex10 1 0 0 0
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;

for SAS see process

%utl_submit_wps64('
libname sd1 "d:/sd1";
data want;
  set sd1.have;
  array ss s:;
  do over ss;
    if ss=1 then do;
       typ=vname(ss);
       output;
    end;
  end;
  keep a typ;
run;quit;
proc print;
run;quit;
');

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk  sas7bdat "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat");
head(have);
library(tidyverse);
want<-subset(cbind(A=have[,1],stack(have[-1])),values==1,-2);
endsubmit;
import r=want data=wrk.wantwps;
run;quit;
proc print data=wrk.wantwps;
run;quit;
');

Recent SAS/IML Addition on end
 by Rick Wicklin via listserv.uga.edu

*____  _      _
|  _ \(_) ___| | __
| |_) | |/ __| |/ /
|  _ <| | (__|   <
|_| \_\_|\___|_|\_\

;

Rick Wicklin via listserv.uga.edu
6:43 PM (15 hours ago)
to SAS-L
It seems like this problem is conceptually similar to the
"Determining which variable produced the maximum value" problem that
has been discussed last week. The difference is that here you want
the variable names strung out in a column instead of concatenated together.

As Roger says, a matrix language can make short work of this problem.
I wrote about the general idea back in 2012:
https://blogs.sas.com/content/iml/2012/05/21/find-the-minumum-value-in-each-row.html

For greater understanding, I'll write each step on a separate
line rather attempt to collapse them into terse nested statements:

data have;
input A$ S1 S2 S3 S4;
datalines;
ex1 1 0 0 0
ex2 0 1 0 0
ex3 0 0 1 0
ex4 1 1 0 0
ex5 0 1 0 1
ex6 0 1 0 0
ex7 1 1 1 0
ex8 0 1 1 0
ex9 0 0 1 0
ex10 1 0 0 0
;

proc iml;
use have;
read all var "A";
read all var _NUM_ into ss[colname=varName];
close;

idx = loc(ss=1);                  /* indices where ss = 1 */
rc = ndx2sub(dimension(ss), idx); /* convert to subscripts (row, col) */
row = A[rc[,1]];                  /* names of rows */
TYP = varName[rc[,2]];            /* names of columns */
print row TYP;


Best wishes,
Rick Wicklin






