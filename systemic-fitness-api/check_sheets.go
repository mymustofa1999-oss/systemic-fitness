package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func main() {
	f, err := excelize.OpenFile("Modul Gerakan .xlsx")
	if err != nil {
		fmt.Println(err)
		return
	}
	defer f.Close()

	for _, sheet := range f.GetSheetList() {
		fmt.Println("Sheet:", sheet)
		rows, _ := f.GetRows(sheet)
		for i, row := range rows {
			if i > 5 { break }
			fmt.Printf("  Row %d: %v\n", i, row)
		}
	}
}
