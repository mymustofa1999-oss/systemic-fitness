package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
	"log"
)

func main() {
	f, err := excelize.OpenFile("movment/LEVEL 1.xlsx")
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	sheets := f.GetSheetList()
	rows, err := f.GetRows(sheets[0])
	if err != nil {
		log.Fatal(err)
	}

	for i, row := range rows {
		if i > 5 {
			break
		}
		fmt.Printf("Row %d: %v\n", i, row)
	}
}
