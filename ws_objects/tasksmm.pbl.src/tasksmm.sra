$PBExportHeader$tasksmm.sra
$PBExportComments$Generated Application Object
forward
global type tasksmm from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global type tasksmm from application
string appname = "tasksmm"
string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 19.0\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = false
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 2
long richtexteditx64type = 3
long richtexteditversion = 1
string richtexteditkey = ""
string appicon = "E:\pbapps\tools\tasksmm\tasksmm.ico"
string appruntimeversion = "19.2.0.2779"
end type
global tasksmm tasksmm

on tasksmm.create
appname="tasksmm"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on tasksmm.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;Open(w_tasksmm_main)
end event

