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
	rows, _ := f.GetRows(sheets[0])
	
	if len(rows) > 0 {
		fmt.Println("Header:")
		for i, col := range rows[0] {
			fmt.Printf("[%d] %s\n", i, col)
		}
		if len(rows) > 1 {
			fmt.Println("\nRow 1:")
			for i, col := range rows[1] {
				fmt.Printf("[%d] %s\n", i, col)
			}
		}
	}
}
