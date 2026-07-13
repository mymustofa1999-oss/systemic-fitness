package main

import (
	"fmt"
	"path/filepath"
	"strings"
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
		found := false
		for i, row := range rows {
			for j, cell := range row {
				lower := strings.ToLower(strings.TrimSpace(cell))
				if lower == "cd" || lower == "cooldown" || lower == "cool down" {
					fmt.Printf("Row %d Col %d: %s\n", i, j, cell)
					found = true
				}
			}
		}
		if !found {
			fmt.Println("No CD found in this sheet")
		}
		xl.Close()
	}
}

