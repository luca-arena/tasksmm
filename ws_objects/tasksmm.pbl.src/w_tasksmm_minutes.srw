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
windowtype windowtype = popup!
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_extract_tasks cb_extract_tasks
mle_minutes mle_minutes
st_1 st_1
end type
global w_tasksmm_minutes w_tasksmm_minutes

forward prototypes
protected subroutine of__extract ()
public function datastore of__parse (string as_minutes)
end prototypes

protected subroutine of__extract ();datastore lds_tasks
int li_count, li_i

lds_tasks = of__parse(mle_minutes.Text)
li_count = lds_tasks.RowCount()
if li_count = 0 then
	MessageBox('Information', 'No ToDos found.')
	return
end if

lds_tasks.SaveAs('e:\tmp\tasks.txt', Text!, true)
OpenWithParm(w_wait, 'Syncing ' + String(li_count) + ' tasks with Trello...')
for li_i = 1 to li_count
	//of__sync_task(lds_tasks, li_i)
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
	lds_tasks.SetItem(ll_row, 'name', ls_person_code)
	lds_tasks.SetItem(ll_row, 'task', ls_task)
	lds_tasks.SetItem(ll_row, 'due_date', ld_due_date)	
	
	ll_start = Pos(as_minutes, '[todo', ll_start + 5)
loop

return lds_tasks
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

