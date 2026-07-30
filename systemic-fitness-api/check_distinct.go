package main

import (
	"fmt"
	"path/filepath"
	"strings"

	"github.com/xuri/excelize/v2"
)

func main() {
	files, _ := filepath.Glob(`C:\Users\ITBDG\Documents\SystemicFitness-Handover\CLEAN\systemic-fitness-api\movment new\*.xlsx`)
	sequences := make(map[string]bool)
	types := make(map[string]bool)
	
	for _, file := range files {
		f, err := excelize.OpenFile(file)
		if err != nil {
			continue
		}
		
		sheets := f.GetSheetList()
		rows, _ := f.GetRows(sheets[0])
		
		for i, row := range rows {
			if i == 0 || len(row) == 0 {
				continue
			}
			if len(row) > 0 {
				seq := strings.TrimSpace(row[0])
				if seq != "" {
					sequences[seq] = true
				}
			}
			if len(row) > 2 {
				typ := strings.TrimSpace(row[2])
				if typ != "" {
					types[typ] = true
				}
			}
		}
		f.Close()
	}
	
	fmt.Println("Sequences:", sequences)
	fmt.Println("Types:", types)
}
