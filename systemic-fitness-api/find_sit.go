package main

import (
	"fmt"
	"path/filepath"
	"strings"
	"github.com/xuri/excelize/v2"
)

func main() {
	files, _ := filepath.Glob("movment/LEVEL [2-6].xlsx")
	for _, file := range files {
		f, _ := excelize.OpenFile(file)
		sheet := f.GetSheetList()[0]
		rows, _ := f.GetRows(sheet)
		for i, row := range rows {
			for j, cell := range row {
				if strings.Contains(strings.ToLower(cell), "sit") {
					fmt.Printf("%s - Row %d Col %d: %s\n", file, i, j, cell)
				}
			}
		}
		f.Close()
	}
}
