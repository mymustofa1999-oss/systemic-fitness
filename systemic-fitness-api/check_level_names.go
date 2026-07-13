package main

import (
	"fmt"
	"strings"
	"path/filepath"

	"github.com/xuri/excelize/v2"
)

func main() {
	files, _ := filepath.Glob("movment/LEVEL *.xlsx")

	for _, file := range files {
		xl, err := excelize.OpenFile(file)
		if err != nil {
			continue
		}
		
		fmt.Printf("--- File: %s ---\n", file)
		sheets := xl.GetSheetList()
		for _, sheet := range sheets {
			rows, _ := xl.GetRows(sheet)
			for i, row := range rows {
				for j, cell := range row {
					if strings.Contains(strings.ToLower(cell), "arm rotation") {
						fmt.Printf("Sheet: %s, Row: %d, Col: %d => %s\n", sheet, i, j, cell)
						// print the whole row
						fmt.Printf("  Row data: %v\n", row)
					}
				}
			}
		}
		xl.Close()
	}
}

