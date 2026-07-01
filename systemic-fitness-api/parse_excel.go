package main

import (
	"fmt"
	"os"

	"github.com/xuri/excelize/v2"
)

func main() {
	filePath := "Modul Gerakan .xlsx"
	f, err := excelize.OpenFile(filePath)
	if err != nil {
		fmt.Println("Error opening file:", err)
		os.Exit(1)
	}
	defer f.Close()

	sheets := f.GetSheetList()
	fmt.Println("Sheets:", sheets)

	for _, sheet := range sheets {
		fmt.Println("--- Sheet:", sheet, "---")
		rows, err := f.GetRows(sheet)
		if err != nil {
			fmt.Println("Error reading sheet:", err)
			continue
		}
		
		for i, row := range rows {
			if i < 3 {
				fmt.Println("Row", i, ":", row)
			}
		}
	}
}
