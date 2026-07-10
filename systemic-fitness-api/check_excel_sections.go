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

	sheets := f.GetSheetList()
	for _, sheet := range sheets {
		fmt.Printf("Sheet: %s\n", sheet)
		rows, err := f.GetRows(sheet)
		if err != nil || len(rows) == 0 {
			continue
		}
		fmt.Printf("  Headers: %v\n", rows[0])
		if len(rows) > 1 {
			fmt.Printf("  Row 1: %v\n", rows[1])
		}
	}
}
