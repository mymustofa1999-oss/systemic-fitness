package main

import (
	"fmt"
	"log"
	"path/filepath"

	"github.com/xuri/excelize/v2"
)

func main() {
	files, err := filepath.Glob("movment/*.xlsx")
	if err != nil {
		log.Fatal(err)
	}
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
				fmt.Println("    Error:", err)
				continue
			}
			if len(rows) > 0 {
				fmt.Printf("    Headers: %v\n", rows[0])
				if len(rows) > 1 {
					fmt.Printf("    First row: %v\n", rows[1])
				}
			} else {
				fmt.Println("    Empty sheet")
			}
		}
		xl.Close()
		fmt.Println()
	}
}
