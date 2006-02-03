79200 #include "rundecs.h"
79210     (*  COPYRIGHT 1983 C.H.LINDSEY, UNIVERSITY OF MANCHESTER  *)
79220  (**)
79230 PROCEDURE GARBAGE (ANOBJECT: OBJECTP); EXTERN ;
79240 PROCEDURE ERRORR(N :INTEGER); EXTERN ;
79250 PROCEDURE TESTF(RF:OBJECTP;VAR F:OBJECTP); EXTERN;
79260 FUNCTION ENSPAGE(RF:OBJECTP;VAR F:OBJECTP):BOOLEAN; EXTERN;
79270 FUNCTION ENSPHYSICALFILE(RF:OBJECTP;VAR F:OBJECTP):BOOLEAN; EXTERN;
79280 (**)
79290 PROCEDURE CLPASC2(P1,P2: IPOINT; PROC: ASPROC); EXTERN;
79300 (**)
79310 (**)
79320 PROCEDURE ERRORSTATE(F:OBJECTP);
79330 (*NOT OPENED OR NOMOOD-ABORT*)
79340   VAR STAT:STATUSSET;
79350     BEGIN STAT:=F^.PCOVER^.STATUS;
79360     IF NOT([OPENED]<=STAT) THEN ERRORR(NOTOPEN)
79370     ELSE IF NOT(([READMOOD]<=STAT) OR ([WRITEMOOD]<=STAT))
79380     THEN ERRORR(NOMOOD);
79390     END;
79400 (**)
79410 (**)
79420 PROCEDURE NEWLINE(RF:OBJECTP);
79430   VAR NSTATUS :STATUSSET; F:OBJECTP;
79440     BEGIN FPINC(RF^);
79450     TESTF(RF,F); NSTATUS:=F^.PCOVER^.STATUS;
79460     IF NOT (([OPENED,READMOOD]<=NSTATUS) OR ([OPENED,WRITEMOOD]<=NSTATUS))
79470     THEN ERRORSTATE(F);
79480     IF [PAGEOVERFLOW]<=NSTATUS
79490     THEN IF NOT ENSPAGE(RF,F) THEN ERRORR(NOLOGICAL);
79500     (* OPENED,LINEOK,MOODOK *)
79510     WITH F^ DO
79520       IF LAZY IN PCOVER^.STATUS THEN WITH PCOVER^ DO
79530         BEGIN
79540         STATUS := STATUS+[NOTINITIALIZED,LFE,PAGEOVERFLOW,LINEOVERFLOW];
79550         LOFCPOS := LOFCPOS+1;
79560         END
79570       ELSE
79580         CLPASC2(ORD(PCOVER), ORD(PCOVER^.BOOK), PCOVER^.DONEWLINE);
79590     WITH RF^ DO BEGIN FDEC; IF FTST THEN GARBAGE(RF) END
79600     END;    (* NEWLINE *)
79610 (**)
79620 (**)
79630 PROCEDURE NEWPAGE(RF:OBJECTP);
79640   VAR NSTATUS :STATUSSET; F:OBJECTP;
79650     BEGIN FPINC(RF^);
79660     TESTF(RF,F); NSTATUS:=F^.PCOVER^.STATUS;
79670     IF NOT(([OPENED,READMOOD]<=NSTATUS) OR ([OPENED,WRITEMOOD]<=NSTATUS))
79680     THEN ERRORSTATE(F);
79690     IF (([PFE]<=NSTATUS) OR ([LFE]<=NSTATUS))
79700     THEN IF NOT ENSPHYSICALFILE(RF,F) THEN ERRORR(NOLOGICAL);
79710     WITH F^ DO
79720       CLPASC2(ORD(PCOVER), ORD(PCOVER^.BOOK), PCOVER^.DONEWPAGE);
79730     WITH RF^ DO BEGIN FDEC; IF FTST THEN GARBAGE(RF) END
79740     END;    (* NEWPAGE *)
79750 (**)
79760 (**)
79770 (*-02()
79780 BEGIN (*OF A68*)
79790 END; (*OF A68*)
79800 ()-02*)
79810 (*+01()
79820 BEGIN (*OF MAIN PROGRAM*)
79830 END (* OF EVERYTHING *).
79840 ()+01*)