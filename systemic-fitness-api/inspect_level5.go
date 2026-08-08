package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func main() {
	xl, err := excelize.OpenFile("Modul Gerakan .xlsx")
	if err != nil {
		fmt.Println(err)
		return
	}
	rows, _ := xl.GetRows("FC")
	for i, row := range rows {
		if i < 20 { 
            fmt.Printf("Row %d: %v\n", i, row)
		}
	}
}
