package main

import (
	"fmt"
	"path/filepath"
	"strings"
	"github.com/xuri/excelize/v2"
)

type Mov struct {
	Cat  string
	VidF string
	VidM string
}

func main() {
	files, _ := filepath.Glob("movment/LEVEL *.xlsx")
	for _, file := range files {
		xl, _ := excelize.OpenFile(file)
		sheet := xl.GetSheetList()[0]
		rows, _ := xl.GetRows(sheet)
		
		movements := make(map[string][]Mov)
		
		for i, row := range rows {
			if i == 0 { continue }
			seq := getCol(row, 0)
			if seq == "" { continue }
			nameF := getCol(row, 4)
			if nameF == "" || strings.ToLower(nameF) == "waitlist" { nameF = getCol(row, 5) }
			nameM := getCol(row, 7)
			if nameM == "" || strings.ToLower(nameM) == "waitlist" { nameM = getCol(row, 8) }
			vidF := getCol(row, 6)
			vidM := getCol(row, 9)
			
			name := nameF
			if name == "" { name = nameM }
			
			if name != "" {
				movements[name] = append(movements[name], Mov{Cat: seq, VidF: vidF, VidM: vidM})
			}
		}
		
		fmt.Println("File:", file)
		for name, movs := range movements {
			if len(movs) > 1 {
				diff := false
				for i := 1; i < len(movs); i++ {
					if movs[i].VidF != movs[0].VidF || movs[i].VidM != movs[0].VidM {
						diff = true
						break
					}
				}
				if diff {
					fmt.Printf("Movement '%s' has conflicting videos:\n", name)
					for _, m := range movs {
						fmt.Printf("  [%s] F: %s | M: %s\n", m.Cat, m.VidF, m.VidM)
					}
				}
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
