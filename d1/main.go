package main

import (
	"bufio"
	"os"
	"slices"
	"strconv"
	"strings"
)

func absDiff(x int, y int) int {
	if res := x - y; res > 0 {
		return res
	} else {
		return -res
	}
}

func f1() {
	file, err := os.Open("./input.txt")
	if err != nil {
		return
	}
	defer file.Close()

	r := bufio.NewScanner(file)

	a := make([]int, 0)
	b := make([]int, 0)
	for r.Scan() {
		s := r.Text()
		listElem := strings.Split(s, "   ")
		na, err := strconv.Atoi(listElem[0])
		if err != nil {
			panic(err)
		}
		nb, err := strconv.Atoi(listElem[1])
		if err != nil {
			panic(err)
		}

		a = append(a, na)
		b = append(b, nb)
	}
	slices.Sort(a)
	slices.Sort(b)

	acc := 0
	for i := range a {
		acc = acc + absDiff(a[i], b[i])
	}
	println(acc)
}

func f2() {
	file, err := os.Open("./input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()
	r := bufio.NewScanner(file)

	a := make([]int, 0)
	b := make(map[int]int, 0)
	for r.Scan() {
		s := strings.Split(r.Text(), "   ")
		na, err := strconv.Atoi(s[0])
		if err != nil {
			panic(err)
		}
		nb, err := strconv.Atoi(s[1])
		if err != nil {
			panic(err)
		}

		a = append(a, na)
		b[nb] += 1
	}

	acc := 0
	for _, v := range a {
		acc += v * b[v]
	}
	println(acc)
}

func main() {
	f1()
	f2()
}
