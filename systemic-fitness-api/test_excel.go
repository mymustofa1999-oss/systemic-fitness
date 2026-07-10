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

	if len(rows) > 0 {
		for i, col := range rows[0] {
			fmt.Printf("Col %d: %s\n", i, col)
		}
	}
}
