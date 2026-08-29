package main

import (
	"fmt"
	"github.com/go-playground/validator/v10"
)

type Test struct {
	URL *string alidate:"omitempty,url"
}

func main() {
	v := validator.New()
	empty := ""
	t := Test{URL: &empty}
	err := v.Struct(t)
	if err != nil {
		fmt.Println("Error:", err)
	} else {
		fmt.Println("Valid!")
	}
}
