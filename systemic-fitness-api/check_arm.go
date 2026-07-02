package main

import (
	"fmt"
	"path/filepath"
	"strings"
	"github.com/xuri/excelize/v2"
)

func main() {
	files, _ := filepath.Glob("movment/LEVEL *.xlsx")
	
	fmt.Println("Arm Rotation videos:")
	for _, file := range files {
		xl, _ := excelize.OpenFile(file)
		sheet := xl.GetSheetList()[0]
		rows, _ := xl.GetRows(sheet)
		
		for _, row := range rows {
			seq := getCol(row, 0)
			nameF := getCol(row, 4)
			nameM := getCol(row, 7)
			vidF := getCol(row, 6)
			vidM := getCol(row, 9)
			
			if strings.Contains(strings.ToLower(nameF), "arm rotation") || strings.Contains(strings.ToLower(nameM), "arm rotation") {
				fmt.Printf("File: %s | Seq: %s | F: %s | M: %s\n", filepath.Base(file), seq, vidF, vidM)
			}
		}
		xl.Close()
	}
}

func getCol(row []string, idx int) string {
	if idx < len(row) {
		return strings.TrimSpace(row[idx])
	}
	return ""
}
