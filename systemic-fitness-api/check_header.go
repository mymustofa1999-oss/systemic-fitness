package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func main() {
	f, _ := excelize.OpenFile("movment/LEVEL 1.xlsx")
	defer f.Close()

	sheet := f.GetSheetList()[0]
	rows, _ := f.GetRows(sheet)
	
	fmt.Println("LEVEL 1:")
	for i, row := range rows {
		if i > 0 && i < 15 {
			fmt.Printf("Row %d: %v\n", i, row)
		}
	}
}
