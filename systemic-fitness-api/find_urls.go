package main

import (
	"fmt"
	"strings"
	"github.com/xuri/excelize/v2"
)

func main() {
	xl, err := excelize.OpenFile("Modul Gerakan .xlsx")
	if err != nil { return }
	
	for _, sheet := range xl.GetSheetList() {
		rows, _ := xl.GetRows(sheet)
		for i, row := range rows {
			for j, cell := range row {
				if strings.Contains(cell, "Ij1diXjbLic") || strings.Contains(cell, "http") {
					fmt.Printf("Sheet: %s, Row: %d, Col: %d, Val: %s\n", sheet, i, j, cell)
				}
			}
		}
	}
}
