package main

import (
	_ "embed"
	"regexp"
	"strconv"
)

//go:embed input.txt
var input string

func atoi(s string) int {
	i, err := strconv.Atoi(s)
	if err != nil {
		panic(err)
	}
	return i
}

func f1() {
	pattern := regexp.MustCompile(`mul\((\d{1,3}),(\d{1,3})\)`)
	m := pattern.FindAllStringSubmatch(input, -1)

	acc := 0
	for _, v := range m {
		acc += atoi(v[1]) * atoi(v[2])
	}
	println(acc)
}

func f2() {
	pattern := regexp.MustCompile(`(?:mul\((\d{1,3}),(\d{1,3})\))|(?:do\(\))|(?:don't\(\))`)
	m := pattern.FindAllStringSubmatch(input, -1)

	acc := 0
	do := true
	for _, v := range m {
		switch {
		case v[0] == "do()":
			do = true
		case v[0] == "don't()":
			do = false
		case do:
			acc += atoi(v[1]) * atoi(v[2])
		}
	}
	println(acc)
}

func main() {
	f1()
	f2()
}
