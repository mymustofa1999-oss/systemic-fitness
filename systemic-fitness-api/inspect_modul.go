package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func main() {
	xl, _ := excelize.OpenFile("Modul Gerakan .xlsx")
	rows, _ := xl.GetRows("FC")
	for i, row := range rows {
		if i < 15 {
			fmt.Printf("Row %d:\n", i)
			for j, cell := range row {
				fmt.Printf("  Col %d: '%s'\n", j, cell)
			}
		}
	}
}
