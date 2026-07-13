package main

import (
	"fmt"
	"path/filepath"
	"github.com/xuri/excelize/v2"
)

func main() {
	levelFiles, _ := filepath.Glob("movment/LEVEL *.xlsx")
	for _, file := range levelFiles {
		xl, _ := excelize.OpenFile(file)
		if xl == nil { continue }
		sheet := xl.GetSheetList()[0]
		rows, _ := xl.GetRows(sheet)
		
		fmt.Printf("--- File: %s ---\n", file)
		for i, row := range rows {
			if len(row) > 0 && row[0] != "" {
				fmt.Printf("Row %d Col 0: %s\n", i, row[0])
			}
		}
		xl.Close()
	}
}

