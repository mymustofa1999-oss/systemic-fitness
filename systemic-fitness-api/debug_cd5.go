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
	
	for _, row := range rows {
		if len(row) > 0 && strings.ToLower(strings.TrimSpace(row[0])) == "cd" {
			for i, cell := range row {
				fmt.Printf("Col %d: %q\n", i, cell)
			}
			break
		}
	}
	xl.Close()
}

