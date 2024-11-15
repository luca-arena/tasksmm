$PBExportHeader$w_wait.srw
$PBExportComments$[400std0] Finestra di Attesa
forward
global type w_wait from window
end type
type st_wait from statictext within w_wait
end type
type p_clessidra from picture within w_wait
end type
end forward

global type w_wait from window
integer width = 1646
integer height = 348
boolean titlebar = true
string title = "Attendere..."
boolean minbox = true
windowtype windowtype = popup!
long backcolor = 16777215
string icon = "wait.ico"
boolean center = true
st_wait st_wait
p_clessidra p_clessidra
end type
global w_wait w_wait

forward prototypes
public subroutine of_change_message (string as_msg)
end prototypes

public subroutine of_change_message (string as_msg);st_wait.Text = as_msg
end subroutine

on w_wait.create
this.st_wait=create st_wait
this.p_clessidra=create p_clessidra
this.Control[]={this.st_wait,&
this.p_clessidra}
end on

on w_wait.destroy
destroy(this.st_wait)
destroy(this.p_clessidra)
end on

event open;st_wait.Text = message.StringParm
end event

type st_wait from statictext within w_wait
integer x = 274
integer y = 96
integer width = 1298
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
boolean italic = true
long textcolor = 33554432
long backcolor = 16777215
string text = "Please wait..."
boolean focusrectangle = false
end type

type p_clessidra from picture within w_wait
integer x = 73
integer y = 64
integer width = 146
integer height = 128
boolean originalsize = true
string picturename = "hourglass.png"
boolean focusrectangle = false
end type

