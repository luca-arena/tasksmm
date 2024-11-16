$PBExportHeader$w_tasksmm_main.srw
forward
global type w_tasksmm_main from window
end type
type cb_verify from commandbutton within w_tasksmm_main
end type
type cb_save from commandbutton within w_tasksmm_main
end type
type cb_load from commandbutton within w_tasksmm_main
end type
type cb_extract from commandbutton within w_tasksmm_main
end type
type st_1 from statictext within w_tasksmm_main
end type
type cb_settings from commandbutton within w_tasksmm_main
end type
type dw_tasks from datawindow within w_tasksmm_main
end type
type r_buttons from rectangle within w_tasksmm_main
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
cb_verify cb_verify
cb_save cb_save
cb_load cb_load
cb_extract cb_extract
st_1 st_1
cb_settings cb_settings
dw_tasks dw_tasks
r_buttons r_buttons
end type
global w_tasksmm_main w_tasksmm_main

type variables
protected:
string is_api_key
string is_token
datastore ids_people

boolean ib_to_save = false
end variables

forward prototypes
protected subroutine of__load_settings ()
protected subroutine of__verify_status ()
protected subroutine of__save_tasks ()
protected subroutine of__load_tasks ()
end prototypes

event ue_postopen();ids_people = create datastore
ids_people.DataObject = 'd_people'

of__load_settings()
if Trim(is_api_key) = '' then
	MessageBox('Information', 'No settings defined. Please clic on the "Settings" button and fill them.')
end if

dw_tasks.Object.Datawindow.Readonly = true
end event

protected subroutine of__load_settings ();is_api_key = ProfileString('tasksmm.ini', 'settings', 'api_key', '')
is_token = ProfileString('tasksmm.ini', 'settings', 'token', '')

if FileExists('people.config') then
	ids_people.ImportFile(Text!, 'people.config', 1)
end if
end subroutine

protected subroutine of__verify_status ();//*
// Verify the status of the Tasks by querying Trello
//*

int li_i, li_count, li_count_changed
n_dict lnv_lists
n_trello_api lnv_api
string ls_task_id, ls_task_name, ls_current_status
s_card lstr_card
s_list lstr_list

li_count = dw_tasks.RowCount()
if li_count = 0 then
	MessageBox('Information', 'There are no Tasks to verify.')
	return
end if

OpenWithParm(w_wait, 'Checking Task status on Trello...')

lnv_api = create n_trello_api
lnv_api.of_init(is_api_key, is_token)

// We cache lists (i.e. task statuses) in a dictionary to reduce API calls
lnv_lists = create n_dict 

dw_tasks.SetRedraw(false)
li_count_changed = 0
for li_i = 1 to li_count
	ls_task_id = dw_tasks.GetItemString(li_i, 'task_id')
	ls_task_name = dw_tasks.GetItemString(li_i, 'task')
	if f_is_empty(ls_task_id) then
		continue
	end if
	try
		lstr_card = lnv_api.of_get_card(ls_task_id)

		// First we check in the cache, if not found we proceed with the call
		if lnv_lists.of_exists(lstr_card.list_id) then
			ls_current_status = lnv_lists.of_value(lstr_card.list_id)
		else
			ls_current_status = lnv_api.of_get_list(lstr_card.list_id).name
			lnv_lists.of_add(lstr_card.list_id, ls_current_status)
		end if
	catch (Exception lnv_except)
		MessageBox('Error', 'Error retrieving Task data from Trello: ' + lnv_except.GetMessage())
		exit
	end try
	if ls_current_status <> dw_tasks.GetItemString(li_i, 'status') then
		dw_tasks.SetItem(li_i, 'status', ls_current_status)
		li_count_changed ++
	end if
end for

dw_tasks.SetRedraw(true)
Close(w_wait)

if li_count_changed > 0 then
	ib_to_save = true
	Title = 'Tasks from Meeting Minutes*'
end if

MessageBox('Information', 'Task status verification completed. ' + &
	String(li_count_changed) + ' tasks updated.')
end subroutine

protected subroutine of__save_tasks ();//*
// Saves the tasks to file
//*

string ls_filename, ls_path
int li_status, li_i, li_count

GetFileSaveName('Salva il file', ls_path, ls_filename, 'tsk', 'File Tasks (*.tsk),*.tsk')

if f_is_empty(ls_filename) then
	return
end if

if Right(ls_filename, 4) <> '.tsk' then
	MessageBox('Error', 'The file extension must be ".tsk".')
	return
end if

li_status = dw_tasks.SaveAs(ls_filename, Text!, true)

if li_status <> 1 then
	MessageBox('Error', 'File save failed')
	return
end if

dw_tasks.SetRedraw(false)
li_count = dw_tasks.RowCount()
for li_i = 1 to li_count
	dw_tasks.SetItemStatus(li_i, 0, Primary!, NotModified!)
end for
dw_tasks.SetRedraw(true)

ib_to_save = false
Title = 'Tasks from Meeting Minutes'
MessageBox('Success', 'File ' + ls_filename + ' saved.')

end subroutine

protected subroutine of__load_tasks ();//*
// Load the Task list from a file
//*

int li_count, li_i
string ls_filename, ls_path

GetFileOpenName('Select Tasks file', ls_filename, ls_path, 'tsk', 'Tasks File (*.tsk),*.tsk')

if f_is_empty(ls_path) then
	return
end if

dw_tasks.SetRedraw(false)
li_count = dw_tasks.ImportFile(Text!, ls_path, 2)
if li_count < 0 then
	MessageBox('Error', 'File import failed')
	dw_tasks.SetRedraw(true)
	return
end if

for li_i = 1 to li_count
	dw_tasks.SetItemStatus(li_i, 0, Primary!, NotModified!)
end for
dw_tasks.SetRedraw(true)
MessageBox('Success', String(dw_tasks.RowCount()) + ' tasks loaded.')
end subroutine

on w_tasksmm_main.create
this.cb_verify=create cb_verify
this.cb_save=create cb_save
this.cb_load=create cb_load
this.cb_extract=create cb_extract
this.st_1=create st_1
this.cb_settings=create cb_settings
this.dw_tasks=create dw_tasks
this.r_buttons=create r_buttons
this.Control[]={this.cb_verify,&
this.cb_save,&
this.cb_load,&
this.cb_extract,&
this.st_1,&
this.cb_settings,&
this.dw_tasks,&
this.r_buttons}
end on

on w_tasksmm_main.destroy
destroy(this.cb_verify)
destroy(this.cb_save)
destroy(this.cb_load)
destroy(this.cb_extract)
destroy(this.st_1)
destroy(this.cb_settings)
destroy(this.dw_tasks)
destroy(this.r_buttons)
end on

event open;//*
// Restore the position/dimensions from the INI file (if available) and calls the
// posteven event
//*

if ProfileString('tasksmm.ini', 'position', 'x', '*') <> '*' then
	X = Long(ProfileString('tasksmm.ini', 'position', 'x', String(this.X)))
	Y = Long(ProfileString('tasksmm.ini', 'position', 'y', String(this.Y)))
	Width = Long(ProfileString('tasksmm.ini', 'position', 'width', String(this.Width)))
	Height = Long(ProfileString('tasksmm.ini', 'position', 'height', String(this.Height)))
end if

event post ue_postopen()
end event

event closequery;int li_response

if ib_to_save then
	li_response = MessageBox('Close without saving?', &
		'You have unsaved Tasks synchronized with Trello, you SHOULD save them before ' + &
		'closing!~n~nDo you want to save?', Question!, YesNo!, 1)
	if li_response = 1 then
		post of__save_tasks()
		return 1
	end if
end if
end event

event resize;//*
// Resizes/moves the window controls after a resize
//*

//cb_settings.x = newwidth - 435
//dw_tasks.width = newwidth - 105
//dw_tasks.height = newheight - 396
//r_buttons.y = newheight - 

cb_settings.x = newwidth - 435
dw_tasks.width = newwidth - 105
dw_tasks.height = newheight - 396
r_buttons.y = newheight - 188
r_buttons.width = newwidth + 41
cb_extract.y = newheight - 140
cb_load.y = newheight - 140
cb_save.y = newheight - 140
cb_verify.x = newwidth - 617
cb_verify.y = newheight - 140


end event

event close;//*
// Saves position & dimensions of the window
//*

long ll_file

if not FileExists('tasksmm.ini') then
	ll_file = FileOpen('tasksmm.ini', LineMode!, Write!, LockReadWrite!, Replace!)
	FileWrite(ll_file, '[position]')
	FileClose(ll_file)
end if

SetProfileString('tasksmm.ini', 'position', 'x', String(this.X))
SetProfileString('tasksmm.ini', 'position', 'y', String(this.Y))
SetProfileString('tasksmm.ini', 'position', 'width', String(this.Width))
SetProfileString('tasksmm.ini', 'position', 'height', String(this.Height))
end event

type cb_verify from commandbutton within w_tasksmm_main
integer x = 2853
integer y = 1904
integer width = 567
integer height = 96
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Verify Task Status"
end type

event clicked;of__verify_status()
end event

type cb_save from commandbutton within w_tasksmm_main
integer x = 1280
integer y = 1904
integer width = 530
integer height = 96
integer taborder = 50
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Save Task File..."
end type

event clicked;of__save_tasks()
end event

type cb_load from commandbutton within w_tasksmm_main
integer x = 731
integer y = 1904
integer width = 530
integer height = 96
integer taborder = 40
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Load Task File..."
end type

event clicked;of__load_tasks()
end event

type cb_extract from commandbutton within w_tasksmm_main
integer x = 37
integer y = 1904
integer width = 658
integer height = 96
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Extract from Minutes..."
end type

event clicked;datastore lds_tasks
int li_i, li_count

Open(w_tasksmm_minutes)
lds_tasks = Message.PowerObjectParm
if not IsValid(lds_tasks) then
	return
end if

li_count = lds_tasks.RowCount()
for li_i = 1 to li_count
	if not f_is_empty(lds_tasks.GetItemString(li_i, 'task_id')) then
		lds_tasks.RowsCopy(li_i, li_i, Primary!, dw_tasks, dw_tasks.RowCount() + 1, Primary!)
		ib_to_save = true
	end if
end for

if ib_to_save then
	parent.Title = 'Tasks from Meeting Minutes*'
end if
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
integer taborder = 20
string title = "none"
string dataobject = "d_task_list"
boolean hscrollbar = true
boolean border = false
boolean livescroll = true
end type

type r_buttons from rectangle within w_tasksmm_main
long linecolor = 33554432
linestyle linestyle = transparent!
integer linethickness = 4
long fillcolor = 16777215
integer y = 1856
integer width = 3511
integer height = 208
end type

