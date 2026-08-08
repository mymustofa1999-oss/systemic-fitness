package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func main() {
	xl, err := excelize.OpenFile("movment/FEMALE SYSTEMIC MOVEMENT.xlsx")
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	sheets := xl.GetSheetList()
	if len(sheets) == 0 {
		return
	}
	rows, err := xl.GetRows(sheets[0])
	for i, row := range rows {
		if i < 20 {
			fmt.Printf("Row %d: %v\n", i, row)
		}
	}
}
