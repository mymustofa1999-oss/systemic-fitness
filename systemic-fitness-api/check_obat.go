package main

import (
	"fmt"
	"log"

	"github.com/xuri/excelize/v2"
)

func main() {
	f, err := excelize.OpenFile("obat/Daftar Obat.xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	sheets := f.GetSheetList()
	fmt.Println("Sheets:", sheets)

	for _, sheet := range sheets {
		fmt.Println("--- Sheet:", sheet)
		rows, err := f.GetRows(sheet)
		if err != nil {
			fmt.Println("Error reading sheet:", err)
			continue
		}
		if len(rows) > 0 {
			fmt.Println("Headers:", rows[0])
			if len(rows) > 1 {
				fmt.Println("Row 1:", rows[1])
			}
		}
	}
}
