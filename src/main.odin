package main

import "core:fmt"
import "core:strings"

main :: proc() {
	list2 := list_create()
	defer list_delete(list2)
	list_append(list2, 1)
	list_append(list2, 2)
	list_append(list2, 4)
	list_append(list2, 2)
	list_append(list2, 3)
	list_append(list2, 4)

	list_remove_dups_2(list2)
}
