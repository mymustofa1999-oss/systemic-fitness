package main

import (
	"fmt"
	"path/filepath"
	"github.com/xuri/excelize/v2"
)

func main() {
	files, _ := filepath.Glob("movment/LEVEL *.xlsx")
	for _, file := range files {
		f, err := excelize.OpenFile(file)
		if err != nil {
			continue
		}
		sheet := f.GetSheetList()[0]
		rows, _ := f.GetRows(sheet)
		if len(rows) > 1 {
			fmt.Printf("%s: %v\n", file, rows[1])
		}
		f.Close()
	}
}
