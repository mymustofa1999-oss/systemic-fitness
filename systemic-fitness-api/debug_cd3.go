package main

import (
	"fmt"
	"strings"
	"github.com/xuri/excelize/v2"
)

func main() {
	xl, _ := excelize.OpenFile("Modul Gerakan .xlsx")
	if xl == nil { return }
	for _, sheet := range xl.GetSheetList() {
		if !strings.HasPrefix(sheet, "LEVEL") { continue }
		rows, _ := xl.GetRows(sheet)
		
		fmt.Printf("--- Sheet: %s ---\n", sheet)
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
	}
	xl.Close()
}

