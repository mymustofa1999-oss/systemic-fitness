package main

import (
	"fmt"
	"log"

	"github.com/xuri/excelize/v2"
)

func main() {
	f, err := excelize.OpenFile("obat/Daftar Obat.xlsx")
	if err != nil {
		log.Fatal("Failed to open excel:", err)
	}
	defer f.Close()

	sheetName := f.GetSheetList()[0]
	rows, err := f.GetRows(sheetName)
	if err != nil {
		log.Fatal("Failed to read rows:", err)
	}

	for _, row := range rows {
		if len(row) > 1 && row[1] == "Allopurinol" {
			for i, col := range row {
				fmt.Printf("Col %d: %s\n", i, col)
			}
			break
		}
	}
}
