package main

import (
	"fmt"
	"strings"
	"github.com/xuri/excelize/v2"
)

func main() {
	xl, _ := excelize.OpenFile("movment/LEVEL 1.xlsx")
	if xl == nil { return }
	sheet := xl.GetSheetList()[0]
	rows, _ := xl.GetRows(sheet)
	
	fmt.Printf("--- Sheet: %s ---\n", sheet)
	for i, row := range rows {
		if len(row) > 0 && strings.ToLower(strings.TrimSpace(row[0])) == "cd" {
			fmt.Printf("Row %d: %v\n", i, row)
		}
	}
	xl.Close()
}

