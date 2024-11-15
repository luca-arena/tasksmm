$PBExportHeader$w_tasksmm_main.srw
forward
global type w_tasksmm_main from window
end type
type cb_1 from commandbutton within w_tasksmm_main
end type
type cb_save from commandbutton within w_tasksmm_main
end type
type cb_open from commandbutton within w_tasksmm_main
end type
type cb_extract from commandbutton within w_tasksmm_main
end type
type st_1 from statictext within w_tasksmm_main
end type
type cb_settings from commandbutton within w_tasksmm_main
end type
type dw_tasks from datawindow within w_tasksmm_main
end type
type r_1 from rectangle within w_tasksmm_main
end type
end forward

global type w_tasksmm_main from window
integer width = 3506
integer height = 2148
boolean titlebar = true
string title = "Tasks from Meeting Minutes"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
event ue_postopen ( )
cb_1 cb_1
cb_save cb_save
cb_open cb_open
cb_extract cb_extract
st_1 st_1
cb_settings cb_settings
dw_tasks dw_tasks
r_1 r_1
end type
global w_tasksmm_main w_tasksmm_main

type variables
string is_api_key
string is_token
datastore ids_people
end variables
forward prototypes
protected subroutine of__load_settings ()
end prototypes

event ue_postopen();ids_people = create datastore
ids_people.DataObject = 'd_people'

of__load_settings()
if Trim(is_api_key) = '' then
	MessageBox('Information', 'No settings defined. Please clic on the "Settings" button and fill them.')
end if
end event

protected subroutine of__load_settings ();is_api_key = ProfileString('tasksmm.ini', 'settings', 'api_key', '')
is_token = ProfileString('tasksmm.ini', 'settings', 'token', '')

if FileExists('people.config') then
	ids_people.ImportFile(Text!, 'people.config', 1)
end if
end subroutine

on w_tasksmm_main.create
this.cb_1=create cb_1
this.cb_save=create cb_save
this.cb_open=create cb_open
this.cb_extract=create cb_extract
this.st_1=create st_1
this.cb_settings=create cb_settings
this.dw_tasks=create dw_tasks
this.r_1=create r_1
this.Control[]={this.cb_1,&
this.cb_save,&
this.cb_open,&
this.cb_extract,&
this.st_1,&
this.cb_settings,&
this.dw_tasks,&
this.r_1}
end on

on w_tasksmm_main.destroy
destroy(this.cb_1)
destroy(this.cb_save)
destroy(this.cb_open)
destroy(this.cb_extract)
destroy(this.st_1)
destroy(this.cb_settings)
destroy(this.dw_tasks)
destroy(this.r_1)
end on

event open;event post ue_postopen()
end event

type cb_1 from commandbutton within w_tasksmm_main
integer x = 2853
integer y = 1904
integer width = 567
integer height = 96
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Verify Task Status"
end type

type cb_save from commandbutton within w_tasksmm_main
integer x = 1280
integer y = 1904
integer width = 530
integer height = 96
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Save Task File..."
end type

type cb_open from commandbutton within w_tasksmm_main
integer x = 731
integer y = 1904
integer width = 530
integer height = 96
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Open Task File..."
end type

type cb_extract from commandbutton within w_tasksmm_main
integer x = 37
integer y = 1904
integer width = 658
integer height = 96
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Extract from Minutes..."
end type

event clicked;Open(w_tasksmm_minutes)
end event

type st_1 from statictext within w_tasksmm_main
integer x = 55
integer y = 32
integer width = 768
integer height = 112
integer textsize = -14
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Current Task List:"
boolean focusrectangle = false
end type

type cb_settings from commandbutton within w_tasksmm_main
integer x = 3035
integer y = 32
integer width = 384
integer height = 96
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Settings..."
end type

event clicked;int li_status

Open(w_tasksmm_settings)
li_status = Message.DoubleParm
if li_status > 0 then
//	of__load_settings()
end if
end event

type dw_tasks from datawindow within w_tasksmm_main
integer x = 55
integer y = 160
integer width = 3365
integer height = 1648
integer taborder = 10
string title = "none"
string dataobject = "d_task_list"
boolean hscrollbar = true
boolean border = false
boolean livescroll = true
end type

type r_1 from rectangle within w_tasksmm_main
long linecolor = 33554432
linestyle linestyle = transparent!
integer linethickness = 4
long fillcolor = 16777215
integer y = 1856
integer width = 3511
integer height = 208
end type

