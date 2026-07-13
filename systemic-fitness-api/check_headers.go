package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func main() {
	xl, _ := excelize.OpenFile("movment/LEVEL 4.xlsx")
	sheet := xl.GetSheetList()[0]
	rows, _ := xl.GetRows(sheet)
	
	fmt.Println("Headers:")
	for i, h := range rows[0] {
		fmt.Printf("Col %d: %s\n", i, h)
	}
	
	fmt.Println("\nRow 1:")
	for i, cell := range rows[1] {
		fmt.Printf("Col %d: %s\n", i, cell)
	}
}

