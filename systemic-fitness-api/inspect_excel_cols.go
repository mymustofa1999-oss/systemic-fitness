package main

import (
	"fmt"
	"strings"

	"github.com/xuri/excelize/v2"
)

func main() {
	files := []string{"movment/LEVEL 1.xlsx", "movment/FEMALE SYSTEMIC MOVEMENT.xlsx"}
	for _, f := range files {
		fmt.Println("File:", f)
		xl, err := excelize.OpenFile(f)
		if err != nil {
			fmt.Println("  Error:", err)
			continue
		}
		sheets := xl.GetSheetList()
		for _, sheet := range sheets {
			fmt.Println("  Sheet:", sheet)
			rows, _ := xl.GetRows(sheet)
			for i, row := range rows {
				if i > 15 {
					break
				}
				fmt.Printf("    Row %d:\n", i)
				for j, cell := range row {
					fmt.Printf("      Col %d: %q\n", j, strings.TrimSpace(cell))
				}
			}
		}
		xl.Close()
	}
}
