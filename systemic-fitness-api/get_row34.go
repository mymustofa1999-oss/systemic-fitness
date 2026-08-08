package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func main() {
	xl, _ := excelize.OpenFile("movment/MALE SYSTEMIC MOVEMENT.xlsx")
    sheets := xl.GetSheetList()
    if len(sheets) > 0 {
	    rows, _ := xl.GetRows(sheets[0])
	    if len(rows) > 34 {
            for j, cell := range rows[34] {
		        fmt.Printf("MALE row 34 Col %d: '%s'\n", j, cell)
            }
	    }
    }
}
