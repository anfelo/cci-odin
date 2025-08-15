package main

import "core:fmt"
import "core:strings"
import "core:testing"
import "core:unicode"
import "core:unicode/utf8"

// [Options 1]: Determines if a string has all unique charaters.
// This implementation uses a chars set to keep track of
// the chars in the string.
is_unique_char_set :: proc(str: string) -> bool {
	char_set := [128]bool{}
	for char in str {
		if (char_set[char]) {
			return false
		}
		char_set[char] = true
	}
	return true
}

// [Options 2]: Determines if a string has all unique charaters.
// This implementation uses bit vector to store the chars of the string.
is_unique_bit_vector :: proc(str: string) -> bool {
	bit_vector: u32 = 0
	for char in str {
		val := char - 'a'
		mask := cast(u32)(1 << cast(u32)val)
		result := bit_vector & mask
		if (result > 0) {
			return false
		}
		bit_vector |= mask
	}
	return true
}

// Determines if a string is a permutation of the other string
is_permutation :: proc(str1: string, str2: string) -> bool {
	if (len(str1) != len(str2)) {
		return false
	}

	char_set := [128]u32{}
	for char in str1 {
		char_set[char] += 1
	}

	for char in str2 {
		if (char_set[char] <= 0) {
			return false
		}
		char_set[char] -= 1
	}

	return true
}

// Urlifies the string. The string is long enough to hold the
// additional chars '%20'. The input string has enough space to hold the additional
// characters. We are given the true length of the string.
// Example:
// Input:  "Mr John Smith    ", 13
// Output: "Mr%20John%20Smith"
urlify :: proc(str: string, result: ^strings.Builder, length: u32) {
	for i := 0; i < cast(int)length; i += 1 {
		char, _ := utf8.decode_rune(str[i:])
		if (char == ' ') {
			strings.write_string(result, "%20")
		} else {
			strings.write_rune(result, char)
		}
	}
}

// Determines is a string is a permutation of a palindrome. Ignores special characters 
// and white space.
palindrome_permutation :: proc(str: string) -> bool {
	bit_vector: u32 = 0
	for char in str {
		if !unicode.is_alpha(char) {
			continue
		}

		bit := cast(u32)unicode.to_lower(char) - 'a'
		mask: u32 = 1 << bit
		bit_vector ~= mask
	}
	// intrinsics.count_ones(bit_vector) < 2 (We don't need to know the total number of ones)
	// we just need to know that at maximum, 1 bit is ON
	return (bit_vector & (bit_vector - 1)) == 0
}

// There are three types of edits that can be performed on strings: insert a character,
// remove a character, or replace a character. Given two strings, write a function to
// check if they are one edit (or zero edits) away.
one_away :: proc(str1: string, str2: string) -> bool {
	// Case 1: Same length -> Edit
	if (len(str1) == len(str2)) {
		found_diff := false
		chars2 := utf8.string_to_runes(str2)
		defer delete(chars2)
		for char1, i in str1 {
			char2 := chars2[i]
			if char1 != char2 {
				if found_diff {
					return false
				}
				found_diff = true
			}
		}
		return true
	}

	// Case 2: Different length -> Insert or Delete
	chars1 := len(str1) + 1 == len(str2) ? utf8.string_to_runes(str1) : utf8.string_to_runes(str2)
	defer delete(chars1)
	chars2 := len(str1) + 1 == len(str2) ? utf8.string_to_runes(str2) : utf8.string_to_runes(str1)
	defer delete(chars2)

	i := 0
	j := 0
	for i < len(chars1) && j < len(chars2) {
		if chars1[i] != chars2[j] {
			if i != j {
				return false
			}
			j += 1
		} else {
			i += 1
			j += 1
		}
	}

	return true
}

// Perfoms a basic compression on the string counting the consecutive repeated
// characters. For example: aabcccccaaa would become a2b1c5a3. If the compressed
// string is not smaller than the original, the string should not be compressed.
string_compression :: proc(str: string, result: ^strings.Builder) {
	count := 0
	prev_char: rune
	for char in str {
		if char == prev_char {
			count += 1
		} else {
			prev_char = char
		}
	}

	if count <= len(str) / 2 {
		strings.write_string(result, str)
		return
	}

	count = 0
	chars := utf8.string_to_runes(str)
	defer delete(chars)
	for i := 0; i < len(chars); i += 1 {
		char := chars[i]
		count += 1

		if i + 1 == len(chars) || char != chars[i + 1] {
			fmt.sbprintf(result, "%v%d", char, count)
			count = 0
		}
	}
}

// Rotates a matrix of numbers 90 Deg
// Asume we have NxN matrix
rotate_matrix_90 :: proc(mat: ^[][]u8) {
	len := len(mat)

	for layer := 0; layer < len / 2; layer += 1 {
		first := layer
		last := len - 1 - layer
		for i := first; i < last; i += 1 {
			offset := i - first
			top := mat[first][i] // save top

			// left -> top
			mat[first][i] = mat[last - offset][first]

			// bottom -> left
			mat[last - offset][first] = mat[last][last - offset]

			// right -> bottom
			mat[last][last - offset] = mat[i][last]

			// top -> right
			mat[i][last] = top
		}
	}
}

// Sets the entire row and column to zero when one of the elements is zero in a NxM matrix.
// Catch: Should only set to zero the rows and columns of the originally zero values.
zero_matrix :: proc(mat: ^[][]u8) {
	// Do a first dry run over the entire matrix and mark all the rows that contain a zero
	// and all the columns that contain a zero. We do not care the exact possition of the zero
	// as all the row or column will be set to zero anyway.
	rows := make([dynamic]bool, len(mat))
	columns := make([dynamic]bool, len(mat[0]))
	defer delete(rows)
	defer delete(columns)

	for i := 0; i < len(mat); i += 1 {
		for j := 0; j < len(mat[0]); j += 1 {
			if (mat[i][j] == 0) {
				rows[i] = true
				columns[j] = true
			}
		}
	}

	// Then go through all the rows that have a zero and set to zero all the row
	for i := 0; i < len(rows); i += 1 {
		if (rows[i]) {
			for j := 0; j < len(mat[0]); j += 1 {
				mat[i][j] = 0
			}
		}
	}

	// Then go through all the columns that have a zero and set to zero all the row
	for i := 0; i < len(columns); i += 1 {
		if (columns[i]) {
			for j := 0; j < len(mat); j += 1 {
				mat[j][i] = 0
			}
		}
	}
}

@(test)
test_is_unique :: proc(t: ^testing.T) {
	result := is_unique_char_set("andres")
	testing.expect(t, result, "[is_unique_char_set] should be unique string")

	result = is_unique_char_set("foo")
	testing.expect(t, !result, "[is_unique_char_set] should NOT be unique string")

	result = is_unique_bit_vector("andres")
	testing.expect(t, result, "[is_unique_bit_vector] should be unique string")

	result = is_unique_bit_vector("foo")
	testing.expect(t, !result, "[is_unique_bit_vector] should NOT be unique string")
}

@(test)
test_is_permutation :: proc(t: ^testing.T) {
	result := is_permutation("andres", "serdna")
	testing.expect(t, result, "[is_permutation] str1 should be permutaion of str2")

	result = is_permutation("foo", "ofo")
	testing.expect(t, result, "[is_permutation] str1 should be permutaion of str2")

	result = is_permutation("andres", "serdnaa")
	testing.expect(t, !result, "[is_permutation] str1 should NOT be permutaion of str2")

	result = is_permutation("andres", "serdaa")
	testing.expect(t, !result, "[is_permutation] str1 should NOT be permutaion of str2")

	result = is_permutation("aadres", "serdna")
	testing.expect(t, !result, "[is_permutation] str1 should NOT be permutaion of str2")
}

@(test)
test_urlify :: proc(t: ^testing.T) {
	input := "Mr John Smith    "
	output := strings.builder_make()
	defer strings.builder_destroy(&output)

	urlify(input, &output, 13) // Uses a builder to create the string
	testing.expect(
		t,
		strings.to_string(output) == "Mr%20John%20Smith",
		"[urilify] should urlify correctly",
	)
}

@(test)
test_palindrome_permutation :: proc(t: ^testing.T) {
	input := "Tact Coa"
	testing.expect(
		t,
		palindrome_permutation(input),
		"[palindrome_permutation] should be a palindrome permutation",
	)

	input = "Andres"
	testing.expect(
		t,
		!palindrome_permutation(input),
		"[palindrome_permutation] should NOT be a palindrome permutation",
	)
}

@(test)
test_one_away :: proc(t: ^testing.T) {
	result := one_away("pale", "ple")
	testing.expect(t, result, "[one_away] should be one edit away")

	result = one_away("pales", "pale")
	testing.expect(t, result, "[one_away] should be one edit away")

	result = one_away("pale", "bale")
	testing.expect(t, result, "[one_away] should be one edit away")

	result = one_away("pale", "pale")
	testing.expect(t, result, "[one_away] should be one edit away")

	result = one_away("pale", "bake")
	testing.expect(t, !result, "[one_away] should NOT be one edit away")
}

@(test)
test_string_compression :: proc(t: ^testing.T) {
	input := "aabcccccaaa"
	output := strings.builder_make()
	defer strings.builder_destroy(&output)

	string_compression(input, &output)

	testing.expect(
		t,
		strings.to_string(output) == "a2b1c5a3",
		"[string_compression] should compress the string",
	)

	input2 := "abca"
	strings.builder_reset(&output)

	string_compression(input2, &output)

	testing.expect(
		t,
		strings.to_string(output) == "abca",
		"[string_compression] should NOT compress the string",
	)
}

@(test)
test_rotate_matrix_90 :: proc(t: ^testing.T) {
	input := [][]u8{{1, 2}, {3, 4}}
	expected := [][]u8{{3, 1}, {4, 2}}

	rotate_matrix_90(&input)

	for i := 0; i < len(input); i += 1 {
		for j := 0; j < len(input); j += 1 {
			testing.expect(
				t,
				input[i][j] == expected[i][j],
				"[rotate_matrix_90] should rotate matrix 90 deg",
			)
		}
	}

	input = [][]u8{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}
	expected = [][]u8{{7, 4, 1}, {8, 5, 2}, {9, 6, 3}}

	rotate_matrix_90(&input)

	for i := 0; i < len(input); i += 1 {
		for j := 0; j < len(input); j += 1 {
			testing.expect(
				t,
				input[i][j] == expected[i][j],
				"[rotate_matrix_90] should rotate matrix 90 deg",
			)
		}
	}

	input = [][]u8{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 14, 15, 16}}
	expected = [][]u8{{13, 9, 5, 1}, {14, 10, 6, 2}, {15, 11, 7, 3}, {16, 12, 8, 4}}

	rotate_matrix_90(&input)

	for i := 0; i < len(input); i += 1 {
		for j := 0; j < len(input); j += 1 {
			testing.expect(
				t,
				input[i][j] == expected[i][j],
				"[rotate_matrix_90] should rotate matrix 90 deg",
			)
		}
	}
}

@(test)
test_zero_matrix :: proc(t: ^testing.T) {
	input := [][]u8{{1, 2, 3}, {0, 5, 6}}
	expected := [][]u8{{0, 2, 3}, {0, 0, 0}}

	zero_matrix(&input)

	for i := 0; i < len(input); i += 1 {
		for j := 0; j < len(input); j += 1 {
			testing.expect(
				t,
				input[i][j] == expected[i][j],
				"[zero_matrix] should set the row and column elements to zero",
			)
		}
	}

	input = [][]u8{{1, 2, 3}, {4, 0, 6}, {7, 8, 9}}
	expected = [][]u8{{1, 0, 3}, {0, 0, 0}, {7, 0, 9}}

	zero_matrix(&input)

	for i := 0; i < len(input); i += 1 {
		for j := 0; j < len(input); j += 1 {
			testing.expect(
				t,
				input[i][j] == expected[i][j],
				"[zero_matrix] should set the row and column elements to zero",
			)
		}
	}

	input = [][]u8{{1, 2, 3, 0}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 0, 15, 16}}
	expected = [][]u8{{0, 0, 0, 0}, {5, 0, 7, 0}, {9, 0, 11, 0}, {0, 0, 0, 0}}

	zero_matrix(&input)

	for i := 0; i < len(input); i += 1 {
		for j := 0; j < len(input); j += 1 {
			testing.expect(
				t,
				input[i][j] == expected[i][j],
				"[zero_matrix] should set the row and column elements to zero",
			)
		}
	}
}
