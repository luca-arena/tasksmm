$PBExportHeader$n_dict.sru
$PBExportComments$Oggetto per gestire un dictionary (nome/valore)
forward
global type n_dict from nonvisualobject
end type
end forward

global type n_dict from nonvisualobject
end type
global n_dict n_dict

type variables
public:
constant long NOTFOUND = 0

protected:
string is_key[]
string is_val[]
long il_count = 0
boolean ib_sorted = false

end variables

forward prototypes
public subroutine of_sort ()
public subroutine of_setsorted (boolean ab_sorted)
public function long of_add (string as_key, string as_val)
public function boolean of_exists (string as_key)
public function long of_addnew (string as_key, string as_val)
public function string of_key (long al_i)
public function integer of_addreplace (string as_key, string as_val)
public function string of_value (long al_i)
public function long of_count ()
public function string of_value (string as_key)
public subroutine of_reset ()
public function long of_search (string as_key)
public function long of_delete (string as_key)
protected subroutine of__set (long al_i, string as_key, string as_val)
end prototypes

public subroutine of_sort ();//*
// Ordina la collezione in modo da rendere la ricerca più rapida (si utilizza
// l'ordinamento per selezione)
//*


int ll_i, ll_j, ll_k
string ls_keytemp
string ls_valtemp

for ll_i = 1 to il_count - 1
	ll_k = ll_i
	ls_keytemp = is_key[ll_i]
	ls_valtemp = is_val[ll_i]
	for ll_j = ll_i + 1 to il_count
		if is_key[ll_j] < ls_keytemp then
			ls_keytemp = is_key[ll_j]
			ls_valtemp = is_val[ll_j]
			ll_k = ll_j
		end if
	end for
	is_key[ll_k] = is_key[ll_i]
	is_val[ll_k] = is_val[ll_i]
	is_key[ll_i] = ls_keytemp
	is_val[ll_i] = ls_valtemp
end for

ib_sorted = true
end subroutine

public subroutine of_setsorted (boolean ab_sorted);//*
// Imposta la condizione di Ordinamento della collezione, utile se si ha la 
// certezza di aver caricato la collezione già in ordine (p.e. se la si 
// carica da una SELECT su db con ORDER BY)
//
// @param  ab_sorted valore a cui impostare l'attributo "sorted"
//*

ib_sorted = ab_sorted
end subroutine

public function long of_add (string as_key, string as_val);//*
// Aggiunge un elemento alla collezione, senza curarsi del fatto che esista o 
// meno (se esistente si avrà un doppione!)
//
// @param  as_key chiave da inserire
// @param  as_val valore corrispondente
// @return posizione in cui è stato inserito l'elemento
//*

il_count ++
of__set(il_count, as_key, as_val)

ib_sorted = false
return il_count
end function

public function boolean of_exists (string as_key);//*
// Restituisce TRUE se la variabile richiesta esiste, FALSE altrimenti
//
// @param  as_key nome dell'elemento da cercare
// @return TRUE se la variabile richiesta esiste, FALSE altrimenti
//*

return of_search(as_key) > 0
end function

public function long of_addnew (string as_key, string as_val);//*
// Aggiunge un elemento alla collezione solo se non è già presente un elemento 
// con la stessa chiave
//
// @param  as_key chiave da inserire
// @param  as_val valore corrispondente
// @return posizione in cui è stato inserito l'elemento o in cui si trovava già
//*

long ll_pos

ll_pos = of_search(as_key)
if ll_pos <> NOTFOUND then
	return ll_pos
end if

return of_add(as_key, as_val)
end function

public function string of_key (long al_i);//*
// Restituisce l'i-esimo nome (chiave) nella collezione
//
// @param  al_i posizione della chiave da restituire
// @return valore dell'i-esima chiave, NULL se inesistente
//*

string ls_val

if al_i > il_count then
	SetNull(ls_val)
	return ls_val
end if

return is_key[al_i]
end function

public function integer of_addreplace (string as_key, string as_val);//*
// Aggiunge un elemento alla collezione o ne modifica il valore se già esistente
//
// @param  as_key chiave da inserire
// @param  as_val valore corrispondente
// @return posizione in cui è stato inserito l'elemento
//*

long ll_i

ll_i = of_search(as_key)
if ll_i = NOTFOUND then
	il_count ++
	ll_i = il_count
end if

of__set(ll_i, as_key, as_val)
return ll_i

end function

public function string of_value (long al_i);//*
// Restituisce l'i-esimo valore nella collezione
//
// @param  al_i posizione del valore da restituire
// @return valore dell'i-esimo elemento
//*

f_assert('n_dict::of_value', al_i <= il_count, 'Attempting to read an item ' + &
	'in a non-existent position (' + String(al_i) + ')')

return is_val[al_i]
end function

public function long of_count ();//*
// Restituisce il numero di elementi attualmente presenti nella collezione
//
// @param  nessuno
// @return numero elementi nella collezione
//*

return il_count
end function

public function string of_value (string as_key);//*
// Restituisce il valore nella collezione corrispondente alla chiave indicata
//
// @param  as_key posizione del valore da restituire
// @return valore dell'elemento richiesto
//*

long ll_pos

ll_pos = of_search(as_key)

f_assert('n_dict::of_value', ll_pos <> NOTFOUND, 'Attempting to read ' + &
	'a non-existent item (key: ' + as_key + ')')

return is_val[ll_pos]
end function

public subroutine of_reset ();//*
// Svuota la collezione
//*

string ls_vuoto[]

il_count = 0
is_val = ls_vuoto

end subroutine

public function long of_search (string as_key);//*
// Restituisce la posizione dell'array in cui si trova il valore corrispondente
// al nome indicato
//
// @param  as_key nome dell'elemento da cercare
// @return posizione dell'elemento cercato, NOTFOUND se non presente
//*

long ll_i, ll_primo, ll_mezzo, ll_ultimo

// Se non è presente l'ordinamento oppure se il numero di elementi è 
// minore o uguale a 5, esegue la ricerca sequenziale

if not ib_sorted or il_count <= 5 then
	for ll_i = 1 to il_count
		if is_key[ll_i] = as_key then
			return ll_i
		end if
	end for
end if

// In caso contrario esegue la ricerca binaria

if ib_sorted and il_count > 5 then
	ll_primo = 1
	ll_ultimo = il_count
	
	do while ll_primo <= ll_ultimo
		ll_mezzo = (ll_primo + ll_ultimo) / 2
		if is_key[ll_mezzo] < as_key then
			ll_primo = ll_mezzo + 1
		else
			if is_key[ll_mezzo] > as_key then
				ll_ultimo = ll_mezzo - 1
			else
				return ll_mezzo
			end if
		end if
	loop
end if

return NOTFOUND
end function

public function long of_delete (string as_key);//*
// Elimina un elemento dalla collezione
//
// @param  as_key elemento da eliminare
// @return posizione in cui era presente l'elemento eliminato, NOTFOUND se 
//         inesistente
//*

long ll_i, ll_j

ll_j = of_search(as_key)
if ll_j = NOTFOUND then
	return NOTFOUND
end if

for ll_i = ll_j + 1 to il_count
	is_key[ll_i - 1] = is_key[ll_i]
	is_val[ll_i - 1] = is_val[ll_i]
end for

il_count --
return ll_j
end function

protected subroutine of__set (long al_i, string as_key, string as_val);//*
// Inserisce un elemento alla collezione nella posizione richiesta
//
// @param  al_i posizione in cui inserire l'elemento
// @param  as_key chiave da inserire
// @param  as_val valore corrispondente
//*


f_assert('n_dict::of__set', al_i <= il_count, &
	'Attempting to insert an item in a non-existent position (' + String(al_i) + ')')

is_key[al_i] = as_key
is_val[al_i] = as_val
end subroutine

on n_dict.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_dict.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

