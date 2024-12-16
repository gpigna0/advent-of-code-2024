package main

import (
	"bufio"
	"os"
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"
)

func inRange(n int) bool {
	switch {
	case n > 0 && n <= 3, n < 0 && n >= -3:
		return true
	default:
		return false
	}
}

func stoi(s []string) []int {
	n := make([]int, len(s))
	var err error

	for i, v := range s {
		n[i], err = strconv.Atoi(v)
		if err != nil {
			panic(err)
		}
	}
	return n
}

func f1() {
	file, err := os.Open("./input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()
	r := bufio.NewScanner(file)

	t1s := time.Now()
	acc := 0
scan:
	for r.Scan() {
		n := stoi(strings.Split(r.Text(), " "))
		for i := 1; i < len(n)-1; i++ {
			diff1 := n[i] - n[i-1]
			diff2 := n[i+1] - n[i]
			if !inRange(diff1) || !inRange(diff2) || diff1*diff2 <= 0 {
				continue scan
			}
		}
		acc++
	}
	t1e := time.Now()
	println(t1e.Sub(t1s).String())

	println(acc)
}

// INFO: This is just a test to see if using goroutines is faster (no in this case)
func f1a() {
	file, err := os.Open("./input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()
	r := bufio.NewScanner(file)

	t2s := time.Now()
	ch := make(chan int, 1005)
	var wg sync.WaitGroup
	for r.Scan() {
		wg.Add(1)
		t := r.Text()

		go func() {
			n := stoi(strings.Split(t, " "))
			for i := 1; i < len(n)-1; i++ {
				diff1 := n[i] - n[i-1]
				diff2 := n[i+1] - n[i]
				if !inRange(diff1) || !inRange(diff2) || diff1*diff2 <= 0 {
					ch <- 0
					wg.Done()
					return
				}
			}
			ch <- 1
			wg.Done()
		}()
	}
	wg.Wait()
	ch <- -1

	acc := 0
	for i := range ch {
		if i == -1 {
			break
		}
		acc += i
	}
	close(ch)
	t2e := time.Now()
	println(t2e.Sub(t2s).String())

	println(acc)
}

////////////////////////////////////////////////////////////

func conc(s1 []int, s2 []int) []int {
	return slices.Concat(s1, s2)
}

func safe(n []int, last bool) bool {
	for i := 1; i < len(n)-1; i++ {
		diff1 := n[i] - n[i-1]
		diff2 := n[i+1] - n[i]
		if !inRange(diff1) || !inRange(diff2) || diff1*diff2 < 0 {
			if last {
				return false
			}
			return safe(conc(n[:i-1], n[i:]), true) || safe(conc(n[:i], n[i+1:]), true) || safe(conc(n[:i+1], n[i+2:]), true)
		}
	}
	return true
}

func f2() {
	file, err := os.Open("./input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()
	r := bufio.NewScanner(file)

	acc := 0
	for r.Scan() {
		n := stoi(strings.Split(r.Text(), " "))
		if safe(n, false) {
			acc++
		}
	}

	println(acc)
}

/////////////////////////////////////////////////////////////

func main() {
	f1()
	f1a()
	f2()
}
