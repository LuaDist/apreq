# Microsoft Developer Studio Generated NMAKE File, Based on testall.dsp

!IF "$(APACHE)" == ""
!MESSAGE No Apache directory was specified.
!MESSAGE This makefile is not to be run directly.
!MESSAGE Please run Configure.bat, and then $(MAKE) on Makefile.
!ERROR
!ENDIF

!IF "$(CFG)" == ""
CFG=test_cgi - Win32 Release
!MESSAGE No configuration specified. Defaulting to test_cgi - Win32 Release.
!ENDIF 

!IF "$(CFG)" != "test_cgi - Win32 Release" && "$(CFG)" != "test_cgi - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "test_cgi.mak" CFG="test_cgi - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "test_cgi - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "test_cgi - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF

CFG_HOME=$(APREQ_HOME)\win32
OUTDIR=$(CFG_HOME)\libs
INTDIR=$(CFG_HOME)\libs

!IF  "$(CFG)" == "test_cgi - Win32 Release"
ALL : "$(OUTDIR)\test_cgi.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /MD /W3 /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /I"$(APACHE)\include" /I"$(APREQ_HOME)\src" /Fp"$(INTDIR)\test_cgi.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\test_cgi.bsc" 
LINK32=link.exe
LINK32_FLAGS=kernel32.lib wsock32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no /pdb:"$(OUTDIR)\test_cgi.pdb" /machine:I386 /out:"$(OUTDIR)\test_cgi.exe" 
LINK32_OBJS= \
        "$(INTDIR)\test_cgi.obj" \
        "$(OUTDIR)\libapreq2_cgi.lib" \
	"$(OUTDIR)\libapreq2.lib" \
	"$(APACHE)\lib\libapr.lib" \
	"$(APACHE)\lib\libaprutil.lib"

"$(OUTDIR)\test_cgi.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "test_cgi - Win32 Debug"

ALL : "$(OUTDIR)\test_cgi.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP=cl.exe
CPP_PROJ=/nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /I"$(APACHE)\include" /I"$(APREQ_HOME)\src" /Fp"$(INTDIR)\test_cgi.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

RSC=rc.exe
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\test_cgi.bsc" 
LINK32=link.exe
LINK32_FLAGS=kernel32.lib wsock32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:yes /pdb:"$(OUTDIR)\test_cgi.pdb" /debug /machine:I386 /out:"$(OUTDIR)\test_cgi.exe" /pdbtype:sept 
LINK32_OBJS= \
        "$(INTDIR)\test_cgi.obj" \
        "$(OUTDIR)\libapreq2_cgi.lib" \
	"$(OUTDIR)\libapreq2.lib" \
	"$(APACHE)\lib\libapr.lib" \
	"$(APACHE)\lib\libaprutil.lib"

"$(OUTDIR)\test_cgi.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 


!IF "$(CFG)" == "test_cgi - Win32 Release" || "$(CFG)" == "test_cgi - Win32 Debug"

SOURCE=$(APREQ_HOME)\env\test_cgi.c

"$(INTDIR)\test_cgi.obj" : $(SOURCE) "$(INTDIR)"
	$(CPP) $(CPP_PROJ) $(SOURCE)

!ENDIF 

