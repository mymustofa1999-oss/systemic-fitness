package main

import (
	"fmt"
	"log"

	"github.com/xuri/excelize/v2"
)

func main() {
	f, err := excelize.OpenFile("Modul Gerakan .xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	for _, sheet := range f.GetSheetList() {
		fmt.Println("Sheet:", sheet)
		rows, err := f.GetRows(sheet)
		if err != nil {
			fmt.Println(" Error:", err)
			continue
		}
		for i, row := range rows {
			if i >= 5 { // Print first 5 rows
				break
			}
			fmt.Printf("  Row %d: %v\n", i, row)
		}
	}
}
