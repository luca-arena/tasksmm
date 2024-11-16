$PBExportHeader$w_tasksmm_settings.srw
forward
global type w_tasksmm_settings from window
end type
type cb_create_token from commandbutton within w_tasksmm_settings
end type
type cb_settings from commandbutton within w_tasksmm_settings
end type
type sle_token from singlelineedit within w_tasksmm_settings
end type
type sle_api_key from singlelineedit within w_tasksmm_settings
end type
type st_3 from statictext within w_tasksmm_settings
end type
type st_2 from statictext within w_tasksmm_settings
end type
type st_1 from statictext within w_tasksmm_settings
end type
type cb_cancel from commandbutton within w_tasksmm_settings
end type
type cb_save from commandbutton within w_tasksmm_settings
end type
type cb_extract from commandbutton within w_tasksmm_settings
end type
type dw_people from datawindow within w_tasksmm_settings
end type
type r_1 from rectangle within w_tasksmm_settings
end type
end forward

global type w_tasksmm_settings from window
integer width = 3479
integer height = 2124
boolean titlebar = true
string title = "Settings"
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_create_token cb_create_token
cb_settings cb_settings
sle_token sle_token
sle_api_key sle_api_key
st_3 st_3
st_2 st_2
st_1 st_1
cb_cancel cb_cancel
cb_save cb_save
cb_extract cb_extract
dw_people dw_people
r_1 r_1
end type
global w_tasksmm_settings w_tasksmm_settings

type prototypes
Function long ShellExecute(long hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, integer nShowCmd) Library "shell32.dll" alias for "ShellExecuteW"
end prototypes

forward prototypes
protected subroutine of__get_boards ()
end prototypes

protected subroutine of__get_boards ();//*
// Get the ToDo Boards from Trello
//*

JsonParser lnv_parser
string ls_response
int li_count, li_i
long ll_row
n_trello_api lnv_api
s_board lstr_boards[]

if f_is_empty(sle_api_key.Text) or f_is_empty(sle_token.Text) then
	MessageBox('Error', 'Please fill the API Key and the Token.', Exclamation!)
	return
end if

OpenWithParm(w_wait, 'Downloading Boards, please wait...')

lnv_api = create n_trello_api
lnv_api.of_init(sle_api_key.Text, sle_token.Text)
try
	lstr_boards = lnv_api.of_get_boards()
catch (Exception lnv_except)
	Close(w_wait)
	MessageBox('Error', 'Error downloading Trello boards: ' + lnv_except.GetMessage())
	return
end try

dw_people.Reset()
li_count = UpperBound(lstr_boards)
ll_row = 0
for li_i = 1 to li_count
	if Left(lstr_boards[li_i].name, 4) = 'ToDo' then
		ll_row = dw_people.InsertRow(0)
		dw_people.SetItem(ll_row, 'board_id', lstr_boards[li_i].id)
		dw_people.SetItem(ll_row, 'name', Mid(lstr_boards[li_i].name, 6))
	end if
end for

Close(w_wait)

MessageBox('Information', String(ll_row) + ' ToDo Boards found.')
end subroutine

on w_tasksmm_settings.create
this.cb_create_token=create cb_create_token
this.cb_settings=create cb_settings
this.sle_token=create sle_token
this.sle_api_key=create sle_api_key
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.cb_cancel=create cb_cancel
this.cb_save=create cb_save
this.cb_extract=create cb_extract
this.dw_people=create dw_people
this.r_1=create r_1
this.Control[]={this.cb_create_token,&
this.cb_settings,&
this.sle_token,&
this.sle_api_key,&
this.st_3,&
this.st_2,&
this.st_1,&
this.cb_cancel,&
this.cb_save,&
this.cb_extract,&
this.dw_people,&
this.r_1}
end on

on w_tasksmm_settings.destroy
destroy(this.cb_create_token)
destroy(this.cb_settings)
destroy(this.sle_token)
destroy(this.sle_api_key)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.cb_cancel)
destroy(this.cb_save)
destroy(this.cb_extract)
destroy(this.dw_people)
destroy(this.r_1)
end on

event open;n_settings lnv_settings
s_settings lstr_settings

lnv_settings = create n_settings
lstr_settings = lnv_settings.of_load()
sle_api_key.Text = lstr_settings.api_key
sle_token.Text = lstr_settings.token
lstr_settings.people.RowsCopy(1, lstr_settings.people.RowCount(), Primary!, dw_people, 1, Primary!)
end event

type cb_create_token from commandbutton within w_tasksmm_settings
integer x = 3035
integer y = 144
integer width = 384
integer height = 96
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Create..."
end type

event clicked;string ls_url

if f_is_empty(sle_api_key.Text) then
	MessageBox('Error', 'Please fill the API Key first.', Exclamation!)
	return
end if

ls_url = 'https://trello.com/1/authorize?expiration=never&scope=read,write&response_type=token&key=' + sle_api_key.Text

ShellExecute(0, 'open', ls_url, '', '', 1)
end event

type cb_settings from commandbutton within w_tasksmm_settings
integer x = 3035
integer y = 32
integer width = 384
integer height = 96
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Create..."
end type

event clicked;ShellExecute(0, 'open', 'https://trello.com/power-ups/admin', '', '', 1)
end event

type sle_token from singlelineedit within w_tasksmm_settings
integer x = 494
integer y = 144
integer width = 2523
integer height = 96
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean password = true
borderstyle borderstyle = stylelowered!
end type

type sle_api_key from singlelineedit within w_tasksmm_settings
integer x = 494
integer y = 32
integer width = 2523
integer height = 96
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type st_3 from statictext within w_tasksmm_settings
integer x = 55
integer y = 160
integer width = 402
integer height = 80
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Trello Token:"
boolean focusrectangle = false
end type

type st_2 from statictext within w_tasksmm_settings
integer x = 55
integer y = 48
integer width = 402
integer height = 80
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Trello API Key:"
boolean focusrectangle = false
end type

type st_1 from statictext within w_tasksmm_settings
integer x = 55
integer y = 336
integer width = 329
integer height = 112
integer textsize = -14
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "People:"
boolean focusrectangle = false
end type

type cb_cancel from commandbutton within w_tasksmm_settings
integer x = 2542
integer y = 1904
integer width = 366
integer height = 96
integer taborder = 50
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Cancel"
boolean cancel = true
end type

event clicked;CloseWithReturn(parent, 0)
end event

type cb_save from commandbutton within w_tasksmm_settings
integer x = 2926
integer y = 1904
integer width = 494
integer height = 96
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Save Settings"
end type

event clicked;n_settings lnv_settings
s_settings lstr_settings

lnv_settings = create n_settings

lstr_settings.api_key = sle_api_key.Text
lstr_settings.token = sle_token.Text
lstr_settings.people = create datastore
lstr_settings.people.DataObject = 'd_people'
dw_people.RowsCopy(1, dw_people.RowCount(), Primary!, lstr_settings.people, 1, Primary!)

lnv_settings.of_save(lstr_settings)

MessageBox('Information', 'Settings saved.')
CloseWithReturn(parent, 1)
end event

type cb_extract from commandbutton within w_tasksmm_settings
integer x = 37
integer y = 1904
integer width = 823
integer height = 96
integer taborder = 40
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Download Boards from Trello"
end type

event clicked;of__get_boards()
end event

type dw_people from datawindow within w_tasksmm_settings
integer x = 55
integer y = 464
integer width = 3365
integer height = 1344
integer taborder = 30
string title = "none"
string dataobject = "d_people"
boolean vscrollbar = true
boolean border = false
boolean livescroll = true
end type

event clicked;if row > 0 and dwo.Name = 'p_delete' then
	DeleteRow(row)
end if
end event

type r_1 from rectangle within w_tasksmm_settings
long linecolor = 33554432
linestyle linestyle = transparent!
integer linethickness = 4
long fillcolor = 16777215
integer y = 1856
integer width = 3511
integer height = 208
end type

