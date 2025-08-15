package main

import "core:fmt"
import "core:testing"

Node :: struct {
	data: u8,
	next: ^Node,
	prev: ^Node,
}

List :: struct {
	head:   ^Node,
	tail:   ^Node,
	length: uint,
}

list_create :: proc() -> ^List {
	list := new(List)
	return list
}

list_delete :: proc(list: ^List) {
	n := list.head
	prev := n
	for n != nil {
		n = n.next
		free(prev)
		prev = n
	}

	free(list)
}

list_append :: proc(list: ^List, data: u8) {
	node := new(Node)
	node.data = data

	if list.head == nil || list.tail == nil {
		list.head = node
		list.tail = node
		list.length = 1
		return
	}

	list.length += 1
	node.prev = list.tail
	list.tail.next = node
	list.tail = node
}

list_prepend :: proc(list: ^List, data: u8) {
	node := new(Node)
	node.data = data

	if list.head == nil || list.tail == nil {
		list.head = node
		list.tail = node
		list.length = 1
		return
	}

	list.length += 1
	node.next = list.head
	list.head.prev = node
	list.head = node
}

list_remove :: proc(list: ^List, value: u8) {
	n := list.head
	for n != nil {
		if n.data == value {
			if n.prev != nil {
				n.prev.next = n.next
			}

			if n.next != nil {
				n.next.prev = n.prev
			}

			if n == list.head {
				list.head = n.next
			}

			if n == list.tail {
				list.tail = n.prev
			}

			free(n)
			break
		}
		n = n.next
	}
}

// [Option 1] Removes duplicates of the list. This option uses a map to store
// the values that are already in the list.
list_remove_dups_1 :: proc(list: ^List) {
	vals_map := make(map[u8]bool)
	defer delete(vals_map)

	n := list.head
	for n != nil {
		if (!vals_map[n.data]) {
			vals_map[n.data] = true
			n = n.next
			continue
		}

		if n.prev != nil {
			n.prev.next = n.next
		}

		if n.next != nil {
			n.next.prev = n.prev
		}

		if n == list.head {
			list.head = n.next
		}

		if n == list.tail {
			list.tail = n.prev
		}

		temp := n
		n = n.next

		free(temp)
	}
}

// [Option 2] Removes duplicates on a linked list without using a map
list_remove_dups_2 :: proc(list: ^List) {
	curr := list.head
	for curr != nil {
		p := curr.next
		for p != nil {
			if p.data != curr.data {
				p = p.next
				continue
			}

			if p.prev != nil {
				p.prev.next = p.next
			}

			if p.next != nil {
				p.next.prev = p.prev
			}

			if p == list.head {
				list.head = p.next
			}

			if p == list.tail {
				list.tail = p.prev
			}

			temp := p
			p = p.next

			free(temp)
		}

		curr = curr.next
	}
}

@(test)
test_linkedlist :: proc(t: ^testing.T) {
	list := list_create()
	defer list_delete(list)

	testing.expect(t, list != nil, "[linkedlist] should create empty list")
	testing.expect(t, list.length == 0, "[linkedlist] should create empty list")
	testing.expect(t, list.head == nil, "[linkedlist] should create empty list")
	testing.expect(t, list.tail == nil, "[linkedlist] should create empty list")

	list_append(list, 1)
	list_append(list, 2)
	list_append(list, 3)

	testing.expect(
		t,
		list.head.data == 1,
		"[linkedlist] should append data at the end of the list",
	)
	testing.expect(
		t,
		list.tail.data == 3,
		"[linkedlist] should append data at the end of the list",
	)
	testing.expect(
		t,
		list.tail.prev.data == 2,
		"[linkedlist] should append data at the end of the list",
	)

	list_prepend(list, 4)

	testing.expect(
		t,
		list.head.data == 4,
		"[linkedlist] should prepend data at the begining of the list",
	)
	testing.expect(
		t,
		list.head.next.data == 1,
		"[linkedlist] should prepend data at the begining of the list",
	)

	list_remove(list, 2)

	testing.expect(
		t,
		list.head.data == 4,
		"[linkedlist] should remove the first node that matches the value",
	)
	testing.expect(
		t,
		list.head.next.data == 1,
		"[linkedlist] should remove the first node that matches the value",
	)
	testing.expect(
		t,
		list.head.next.next.data == 3,
		"[linkedlist] should remove the first node that matches the value",
	)
}

@(test)
test_list_remove_dups :: proc(t: ^testing.T) {
	list := list_create()
	defer list_delete(list)
	list_append(list, 1)
	list_append(list, 2)
	list_append(list, 4)
	list_append(list, 2)
	list_append(list, 3)
	list_append(list, 4)

	list_remove_dups_1(list)

	testing.expect(t, list.head.data == 1, "[list_remove_dups_1] should remove duplicates")
	testing.expect(t, list.head.next.data == 2, "[list_remove_dups_1] should remove duplicates")
	testing.expect(
		t,
		list.head.next.next.data == 4,
		"[list_remove_dups_1] should remove duplicates",
	)
	testing.expect(
		t,
		list.head.next.next.next.data == 3,
		"[list_remove_dups_1] should remove duplicates",
	)
	testing.expect(t, list.tail.data == 3, "[list_remove_dups_1] should remove duplicates")

	list2 := list_create()
	defer list_delete(list2)
	list_append(list2, 1)
	list_append(list2, 2)
	list_append(list2, 4)
	list_append(list2, 2)
	list_append(list2, 3)
	list_append(list2, 4)

	list_remove_dups_2(list2)

	testing.expect(t, list2.head.data == 1, "[list_remove_dups_2] should remove duplicates")
	testing.expect(t, list2.head.next.data == 2, "[list_remove_dups_2] should remove duplicates")
	testing.expect(
		t,
		list2.head.next.next.data == 4,
		"[list_remove_dups_2] should remove duplicates",
	)
	testing.expect(
		t,
		list2.head.next.next.next.data == 3,
		"[list_remove_dups_2] should remove duplicates",
	)
	testing.expect(t, list2.tail.data == 3, "[list_remove_dups_2] should remove duplicates")
}
