package main

import (
	"fmt"
	"github.com/xuri/excelize/v2"
)

func main() {
	f, err := excelize.OpenFile("../systemic-fitness-api/movment/LEVEL_6_LOCK.xlsx")
	if err != nil {
		panic(err)
	}
	defer f.Close()

    sheets := f.GetSheetList()
    if len(sheets) == 0 {
        panic("No sheets")
    }
    
	rows, err := f.GetRows(sheets[0])
	if err != nil {
		panic(err)
	}

	for i, row := range rows {
		if i == 56 { // Row 57 (0-indexed 56)
			fmt.Println("Row 57:")
			for j, col := range row {
				fmt.Printf("Col %d: %q\n", j+1, col)
			}
            
            // Also check GetCellHyperLink
            link, target, err := f.GetCellHyperLink(sheets[0], "G57")
            fmt.Printf("Hyperlink G57: link=%v, target=%v, err=%v\n", link, target, err)
		}
	}
}
