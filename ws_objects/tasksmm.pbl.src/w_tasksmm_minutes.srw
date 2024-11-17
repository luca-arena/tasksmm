$PBExportHeader$w_tasksmm_minutes.srw
forward
global type w_tasksmm_minutes from window
end type
type cb_extract_tasks from commandbutton within w_tasksmm_minutes
end type
type mle_minutes from multilineedit within w_tasksmm_minutes
end type
type st_1 from statictext within w_tasksmm_minutes
end type
end forward

global type w_tasksmm_minutes from window
integer width = 2921
integer height = 2220
boolean titlebar = true
string title = "Tasks from Meeting Minutes"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_extract_tasks cb_extract_tasks
mle_minutes mle_minutes
st_1 st_1
end type
global w_tasksmm_minutes w_tasksmm_minutes

type variables
protected:
n_settings inv_settings
s_settings istr_settings
n_trello_api inv_api
n_dict inv_todo_lists
end variables

forward prototypes
protected subroutine of__extract ()
public function datastore of__parse (string as_minutes)
public function boolean of__sync_task (datastore ads_tasks, integer ai_row) throws exception
end prototypes

protected subroutine of__extract ();datastore lds_tasks
int li_count, li_i, li_confirm

if f_is_empty(mle_minutes.Text) then
	MessageBox('Error', 'Please paste the minutes in the box to import them.', Exclamation!)
	return
end if	

lds_tasks = of__parse(mle_minutes.Text)
li_count = lds_tasks.RowCount()
if li_count = 0 then
	MessageBox('Information', 'No ToDos found.')
	return
end if

li_confirm = MessageBox('Extract Tasks', 'Found ' + String(li_count) + ' ToDos in the minutes.~n~n' + &
	'Proceed to create cards on Trello?', Question!, YesNo!, 1)
if li_confirm = 2 then
	return
end if

lds_tasks.SaveAs('parsed_tasks.debug.txt', Text!, true)

inv_settings = create n_settings
istr_settings = inv_settings.of_load()
inv_api = create n_trello_api
inv_api.of_init(istr_settings.api_key, istr_settings.token)
inv_todo_lists = create n_dict

OpenWithParm(w_wait, 'Synchronizing ' + String(li_count) + ' tasks with Trello...')
for li_i = 1 to li_count
	try
		of__sync_task(lds_tasks, li_i)
	catch (Exception lnv_except)
		MessageBox('Error while syncing tasks', lnv_except.GetMessage())
		Close(w_wait)
		return
	end try
end for

Close(w_wait)
MessageBox('Information', 'Synchronization completed.')
CloseWithReturn(this, lds_tasks)
end subroutine

public function datastore of__parse (string as_minutes);datastore lds_tasks
date ld_due_date
long ll_start, ll_end, ll_row
string ls_person_code, ls_task, ls_due_date

lds_tasks = create datastore
lds_tasks.DataObject = 'd_task_list'

ll_start = Pos(as_minutes, '[todo')
do while ll_start > 0
	ll_end = Pos(as_minutes, ']', ll_start)
	if ll_end = 0 then
		exit
	end if
	ls_person_code = Mid(as_minutes, ll_start + 6, 2)
	ls_task = Mid(as_minutes, ll_start + 9, ll_end - ll_start - 9)
	ls_due_date = Right(ls_task, 10)
	if IsDate(ls_due_date) then
		ld_due_date = Date(ls_due_date)
		ls_task = Left(ls_task, Len(ls_task) - 11)
	else
		SetNull(ld_due_date)
	end if
	
	ll_row = lds_tasks.InsertRow(0)
	lds_tasks.SetItem(ll_row, 'code', ls_person_code)
	lds_tasks.SetItem(ll_row, 'task', ls_task)
	lds_tasks.SetItem(ll_row, 'due_date', ld_due_date)	
	
	ll_start = Pos(as_minutes, '[todo', ll_start + 5)
loop

return lds_tasks
end function

public function boolean of__sync_task (datastore ads_tasks, integer ai_row) throws exception;//*
// Checks if a task is already present in the person's Board; if not, it adds it
//
// @param  ads_tasks tasks datastore
// @param  ai_row row containing the task to process
// @return true if the task gets added to the board, false otherwise
//*

date ld_due
string ls_person_code, ls_todo_id, ls_board_id, ls_task, ls_task_id
s_card lstr_card

// Get the Person Code and the person's Board ID (from the Settings)

ls_person_code = ads_tasks.GetItemString(ai_row, 'code')
ls_task = ads_tasks.GetItemString(ai_row, 'task')
ld_due = ads_tasks.GetItemDate(ai_row, 'due_date')

ls_board_id = inv_settings.of_board_id_by_person_code(istr_settings, ls_person_code)
if f_is_empty(ls_board_id) then
	return false
end if

// If the tasks is already in the Board we skip it

if inv_api.of_task_exists_in_board(ls_board_id, ls_task) then
	return false
end if

// If the ToDo List ID of the person is already in the "cache" (inv_todo_lists) then we use that;
// instead we query Trello to find it (and save it in the "cache")

if inv_todo_lists.of_exists(ls_person_code) then
	ls_todo_id = inv_todo_lists.of_value(ls_person_code)
else
	ls_todo_id = inv_api.of_find_list_by_name(ls_board_id, 'ToDo')
	inv_todo_lists.of_add(ls_person_code, ls_todo_id)
end if

if f_is_empty(ls_todo_id) then
	return false
end if

lstr_card.name = ls_task
lstr_card.due_date = ld_due
lstr_card.list_id = ls_todo_id
ls_task_id = inv_api.of_add_card(lstr_card)

ads_tasks.SetItem(ai_row, 'task_id', ls_task_id)
ads_tasks.SetItem(ai_row, 'code', ls_person_code)
ads_tasks.SetItem(ai_row, 'name', inv_settings.of_name_by_person_code(istr_settings, ls_person_code))
ads_tasks.SetItem(ai_row, 'status', 'ToDo')

return true


end function

on w_tasksmm_minutes.create
this.cb_extract_tasks=create cb_extract_tasks
this.mle_minutes=create mle_minutes
this.st_1=create st_1
this.Control[]={this.cb_extract_tasks,&
this.mle_minutes,&
this.st_1}
end on

on w_tasksmm_minutes.destroy
destroy(this.cb_extract_tasks)
destroy(this.mle_minutes)
destroy(this.st_1)
end on

type cb_extract_tasks from commandbutton within w_tasksmm_minutes
integer x = 2432
integer y = 32
integer width = 439
integer height = 96
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Extract Tasks"
end type

event clicked;of__extract()
end event

type mle_minutes from multilineedit within w_tasksmm_minutes
integer x = 37
integer y = 176
integer width = 2834
integer height = 1920
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type st_1 from statictext within w_tasksmm_minutes
integer x = 37
integer y = 48
integer width = 1783
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Paste your Meetings Minutes here and clic the Extract Tasks button:"
boolean focusrectangle = false
end type

