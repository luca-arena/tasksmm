$PBExportHeader$n_settings.sru
forward
global type n_settings from nonvisualobject
end type
end forward

global type n_settings from nonvisualobject
end type
global n_settings n_settings

forward prototypes
public function s_settings of_load ()
public subroutine of_save (s_settings astr_settings)
public function string of_board_id_by_person_code (s_settings astr_settings, string as_person_code)
public function string of_name_by_person_code (s_settings astr_settings, string as_person_code)
end prototypes

public function s_settings of_load ();s_settings lstr_settings

lstr_settings.api_key = ProfileString('tasksmm.ini', 'settings', 'api_key', '')
lstr_settings.token = ProfileString('tasksmm.ini', 'settings', 'token', '')
lstr_settings.people = create datastore
lstr_settings.people.DataObject = 'd_people'

if FileExists('people.config') then
	lstr_settings.people.ImportFile(Text!, 'people.config', 1)
end if

return lstr_settings
end function

public subroutine of_save (s_settings astr_settings);long ll_file

if not FileExists('tasksmm.ini') then
	ll_file = FileOpen('tasksmm.ini', LineMode!, Write!, LockReadWrite!, Replace!)
	FileWrite(ll_file, '[settings]')
	FileClose(ll_file)
end if

SetProfileString('tasksmm.ini', 'settings', 'api_key', astr_settings.api_key)
SetProfileString('tasksmm.ini', 'settings', 'token', astr_settings.token)
astr_settings.people.SaveAs('people.config', Text!, false)

end subroutine

public function string of_board_id_by_person_code (s_settings astr_settings, string as_person_code);//*
// Finds the Board ID of a person by code (if any)
//
// @param  astr_settings settings of the application
// @param  as_person_code code of the person
// @return Board ID, empty string if person not found in the Settings
//*

int li_row

li_row = astr_settings.people.Find( &
	'code = ~'' + as_person_code + '~'', 1, astr_settings.people.RowCount())
if li_row > 0 then
	return astr_settings.people.GetItemString(li_row, 'board_id')
else
	return ''
end if
end function

public function string of_name_by_person_code (s_settings astr_settings, string as_person_code);//*
// Finds the name of a person by code (if any)
//
// @param  astr_settings settings of the application
// @param  as_person_code code of the person
// @return Name, empty string if person not found in the Settings
//*

int li_row

li_row = astr_settings.people.Find( &
	'code = ~'' + as_person_code + '~'', 1, astr_settings.people.RowCount())
if li_row > 0 then
	return astr_settings.people.GetItemString(li_row, 'name')
else
	return ''
end if
end function

on n_settings.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_settings.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

