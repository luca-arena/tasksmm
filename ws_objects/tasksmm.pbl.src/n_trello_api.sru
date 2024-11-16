$PBExportHeader$n_trello_api.sru
forward
global type n_trello_api from nonvisualobject
end type
end forward

shared variables
long sl_api_calls = 0
end variables
global type n_trello_api from nonvisualobject
end type
global n_trello_api n_trello_api

type variables
protected:
string TRELLO_API_LOG = 'trello_api.log'
boolean ib_log_enabled = true

string is_api_key
string is_token
boolean ib_initialized
end variables
forward prototypes
public subroutine of_init (string as_api_key, string as_token)
public function any of_get_boards () throws exception
protected subroutine of__check_initialized () throws exception
public function boolean of_task_exists_in_board (string as_board_id, string as_task_name) throws exception
public function any of_get_lists (string as_board_id) throws exception
public function string of_find_list_by_name (string as_board_id, string as_list_name) throws exception
public function s_card of_get_card (string as_card_id) throws exception
public function string of_add_card (s_card astr_card) throws exception
public function s_list of_get_list (string as_list_id) throws exception
public function string of_get_card_list_name (string as_card_id) throws exception
protected function string of__get (string as_url) throws exception
protected subroutine of__log (string as_msg)
protected function string of__post (string as_url, string as_post_data) throws exception
protected subroutine of__api_error (integer ai_status) throws exception
end prototypes

public subroutine of_init (string as_api_key, string as_token);//*
// Initialize the object with API Key and Token
//
// @param  as_api_key API Key
// @param  as_token Token
//*

is_api_key = as_api_key
is_token = as_token
ib_initialized = true
end subroutine

public function any of_get_boards () throws exception;//*
// Returns a list of the boards
//*

JsonParser lnv_parser
string ls_url, ls_response
int li_count, li_i
long ll_root, ll_item
s_board lstr_boards[]

of__check_initialized()

lnv_parser = create JsonParser

ls_url = 'https://api.trello.com/1/members/me/boards?key=' + is_api_key + "&token=" + is_token
ls_response = of__get(ls_url)

lnv_parser.LoadString(ls_response)
ll_root = lnv_parser.GetRootItem()
li_count = lnv_parser.GetChildCount(ll_root)

for li_i = 1 to li_count
	ll_item = lnv_parser.GetChildItem(ll_root, li_i)
	lstr_boards[li_i].id = lnv_parser.GetItemString(ll_item, 'id')
	lstr_boards[li_i].name = lnv_parser.GetItemString(ll_item, 'name')
end for

return lstr_boards
end function

protected subroutine of__check_initialized () throws exception;//*
// Checks that the API object is initialized with API Key and Token
//*

if not ib_initialized then
	throw f_except('Trello API client not initialized, please specify API Key and Token')
end if
end subroutine

public function boolean of_task_exists_in_board (string as_board_id, string as_task_name) throws exception;//*
// Finds if a Task exists in a Board
//
// @param  as_board_id ID of the Board to search for the Task
// @param  as_task_name Name of the Task
// @return true if the task exists, false otherwise 
//*

string ls_url, ls_response

ls_url = 'https://api.trello.com/1/boards/' + as_board_id + '/cards?key=' + is_api_key + '&token=' + is_token
ls_response = of__get(ls_url)
return Pos(ls_response, as_task_name) > 0 

end function

public function any of_get_lists (string as_board_id) throws exception;//*
// Gets the Lists in a Trello Board
//
// @param  as_board_id Board ID
// @return array of the Lists of the Board
//*

HttpClient lnv_http
JsonParser lnv_parser
string ls_url, ls_response
int li_status, li_i, li_count
long ll_root, ll_item
s_list lstr_list[]

lnv_http = create HttpClient
ls_url = 'https://api.trello.com/1/boards/' + as_board_id + '/lists?key=' + is_api_key + '&token=' + is_token

li_status = lnv_http.SendRequest('GET', ls_url)
of__api_error(li_status)

lnv_http.GetResponseBody(ls_response)

lnv_parser = create JsonParser
lnv_parser.LoadString(ls_response)
ll_root = lnv_parser.GetRootItem()
li_count = lnv_parser.GetChildCount(ll_root)
for li_i = 1 to li_count
	ll_item = lnv_parser.GetChildItem(ll_root, li_i)
	lstr_list[li_i].id = lnv_parser.GetItemString(ll_item, 'id')
	lstr_list[li_i].name = lnv_parser.GetItemString(ll_item, 'name')
end for

return lstr_list
end function

public function string of_find_list_by_name (string as_board_id, string as_list_name) throws exception;//*
// Finds a list by name in a Trello board
//
// @param  as_board_id ID of the Board to search for the list
// @param  as_list_name name of the List to look for
// @return list ID or empty string if not found
//*

int li_i, li_count
s_list lstr_list[]

lstr_list = of_get_lists(as_board_id)
li_count = UpperBound(lstr_list)
for li_i = 1 to li_count
	if lstr_list[li_i].name = as_list_name then
		return lstr_list[li_i].id
	end if
end for

return ''
end function

public function s_card of_get_card (string as_card_id) throws exception;//*
// Gets a Card data from Trello
//
// @param  as_card_id Card ID
// @return Card structure
//*

JsonParser lnv_parser
string ls_url, ls_response
long ll_root
s_card lstr_card

ls_url = 'https://api.trello.com/1/cards/' + as_card_id + '/?key=' + is_api_key + '&token=' + is_token
ls_response = of__get(ls_url)

lnv_parser = create JsonParser
lnv_parser.LoadString(ls_response)
ll_root = lnv_parser.GetRootItem()
lstr_card.name = lnv_parser.GetItemString(ll_root, 'name')
lstr_card.id = as_card_id
lstr_card.list_id = lnv_parser.GetItemString(ll_root, 'idList')
lstr_card.due_date = Date(Left(lnv_parser.GetItemString(ll_root, 'due'), 10))

return lstr_card
end function

public function string of_add_card (s_card astr_card) throws exception;//*
// Adds a card to a List
//
// @param  astr_card card to be added
// @return Card ID
//*

JsonGenerator lnv_json
JsonParser lnv_parser
long ll_root
string ls_response, ls_post_data

lnv_json = create JsonGenerator
ll_root = lnv_json.CreateJsonObject()
lnv_json.AddItemString(ll_root, 'key', is_api_key)
lnv_json.AddItemString(ll_root, 'token', is_token)
lnv_json.AddItemString(ll_root, 'idList', astr_card.list_id)
lnv_json.AddItemString(ll_root, 'name', astr_card.name)
if not IsNull(astr_card.due_date) then
	lnv_json.AddItemString(ll_root, 'due', + String(astr_card.due_date, 'yyyy-mm-dd') + 'T12:00:00Z')
end if
ls_post_data = lnv_json.GetJsonString()

ls_response = of__post('https://api.trello.com/1/cards', ls_post_data)

lnv_parser = create JsonParser
lnv_parser.LoadString(ls_response)
ll_root = lnv_parser.GetRootItem()
return lnv_parser.GetItemString(ll_root, 'id')

end function

public function s_list of_get_list (string as_list_id) throws exception;//*
// Gets a List data from Trello
//
// @param  as_list_id List ID
// @return List structure
//*

JsonParser lnv_parser
string ls_url, ls_response
long ll_root
s_list lstr_list

ls_url = 'https://api.trello.com/1/lists/' + as_list_id + '/?key=' + is_api_key + '&token=' + is_token
ls_response = of__get(ls_url)

lnv_parser = create JsonParser
lnv_parser.LoadString(ls_response)
ll_root = lnv_parser.GetRootItem()
lstr_list.name = lnv_parser.GetItemString(ll_root, 'name')
lstr_list.id = as_list_id

return lstr_list
end function

public function string of_get_card_list_name (string as_card_id) throws exception;//*
// Gets a Card List name from Trello
//
// @param  as_card_id Card ID
// @return name of the List to which the Card belongs
//*

return of_get_list(of_get_card(as_card_id).list_id).name
end function

protected function string of__get (string as_url) throws exception;//*
// Executes a GET call to the Trello API
//
// @param  as_url url (filled with query parameters, if required) to be called
// @return json response (string)
//*

HttpClient lnv_http
string ls_response
int li_status
long ll_start, ll_end

lnv_http = create HttpClient
lnv_http.SetRequestHeader('Accept', 'application/json')
lnv_http.SetRequestHeader('User-Agent', 'TasksMM')
lnv_http.SetRequestHeader('Connection', 'keep-alive')

sl_api_calls ++
of__log('------------------------------------------------------------------')
of__log('REQUEST NO.: ' + String(sl_api_calls))
of__log('REQUEST: ')
of__log('GET ' + as_url)
of__log('REQUEST HEADERS: ')
of__log(lnv_http.GetRequestHeaders())

ll_start = Cpu()
li_status = lnv_http.SendRequest('GET', as_url)
ll_end = Cpu()
of__log('ELAPSED TIME: ' + String(Double(ll_end - ll_start) / 1000, '0.000') + 's')

of__api_error(li_status)

of__log('HTTP STATUS CODE: ' + String(lnv_http.GetResponseStatusCode()))

lnv_http.GetResponseBody(ls_response)

of__log('RESPONSE:')
of__log(ls_response)
of__log('RESPONSE HEADERS:')
of__log(lnv_http.GetResponseHeaders())

destroy lnv_http

return ls_response
end function

protected subroutine of__log (string as_msg);//*
// Write a message in the Trello API Calls log file
//
// @param  as_msg message to be written in the log file
//*

if ib_log_enabled then
	f_simple_log(TRELLO_API_LOG, '$time ' + as_msg)
end if

end subroutine

protected function string of__post (string as_url, string as_post_data) throws exception;//*
// Execute a POST call to the Trello API
//
// @param  as_url endpoint to be called
// @param  as_post_data data to be sent in the POST request
// @return response
//*

HttpClient lnv_http
int li_status
long ll_start, ll_end
string ls_response

lnv_http = create HttpClient
lnv_http.SetRequestHeader('Accept', 'application/json')
lnv_http.SetRequestHeader('User-Agent', 'TasksMM')
lnv_http.SetRequestHeader('Content-Type', 'application/json') // Mandatory!!

sl_api_calls ++
of__log('------------------------------------------------------------------')
of__log('REQUEST NO.: ' + String(sl_api_calls))
of__log('REQUEST: ')
of__log('POST ' + as_url)
of__log('POST DATA: ')
of__log(as_post_data)
of__log('REQUEST HEADERS: ')
of__log(lnv_http.GetRequestHeaders())

ll_start = Cpu()
li_status = lnv_http.SendRequest('POST', as_url, as_post_data)
ll_end = Cpu()
of__log('ELAPSED TIME: ' + String(Double(ll_end - ll_start) / 1000, '0.000') + 's')

of__api_error(li_status)

of__log('HTTP STATUS CODE: ' + String(lnv_http.GetResponseStatusCode()))

lnv_http.GetResponseBody(ls_response)

of__log('RESPONSE:')
of__log(ls_response)
of__log('RESPONSE HEADERS:')
of__log(lnv_http.GetResponseHeaders())

destroy lnv_http

return ls_response
end function

protected subroutine of__api_error (integer ai_status) throws exception;//*
// Throws an Exception if there has been a call API error
//
// @param  ai_status status of the last API call
//*

string ls_message

if ai_status = 1 then
	return
end if

choose case ai_status
	case -1
		ls_message = 'General error'
	case -2
		ls_message = 'Invalid URL'
	case -3
		ls_message = 'Cannot connect to the Internet'
	case -4
		ls_message = 'Timed out'
	case -5
		ls_message = 'Code conversion failed'
	case -6
		ls_message = 'Unsupported character sets'
	case -7
		ls_message = 'Certification revocation checking has been enabled, but the revocation check failed to verify whether a certificate has been revoked. The server used to check for revocation might be unreachable.'
	case -8
		ls_message = 'SSL certificate is invalid.'
	case -9
		ls_message = 'SSL certificate was revoked.'
	case -10
		ls_message = 'The function is unfamiliar with the Certificate Authority that generated the server certificate.'
	case -11
		ls_message = 'SSL certificate common name (host name field) is incorrect, for example, you entered www.appeon.com and the common name on the certificate says www.demo.appeon.com.'
	case -12
		ls_message = 'SSL certificate date that was received from the server is invalid. The certificate has expired.'
	case -13
		ls_message = 'The certificate was not issued for the server authentication purpose.'
	case -14
		ls_message = 'The application experienced an internal error when loading the SSL libraries.'
	case -15
		ls_message = 'More than one type of errors when validating the server certificate.'
end choose

throw f_except('Error calling Trello API: ' + ls_message)
end subroutine

on n_trello_api.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_trello_api.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

