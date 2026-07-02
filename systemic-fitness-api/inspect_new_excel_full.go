package main

import (
	"fmt"

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
			rows, err := xl.GetRows(sheet)
			if err != nil {
				continue
			}
			for i := 0; i < 15 && i < len(rows); i++ {
				fmt.Printf("    Row %d: %v\n", i+1, rows[i])
			}
		}
		xl.Close()
		fmt.Println()
	}
}
