package main
import (
	"fmt"
	"strings"
	"github.com/xuri/excelize/v2"
)
func main() {
	xl, _ := excelize.OpenFile("movment/LEVEL 4.xlsx")
	sheet := xl.GetSheetList()[0]
	rows, _ := xl.GetRows(sheet)
	
	headers := rows[0]
	colMap := make(map[string]int)
	for i, h := range headers {
		colMap[strings.TrimSpace(strings.ToUpper(h))] = i
	}

	idxFU := colMap["FEMALE_MOVEMENT_UPPER"]
	idxFL := colMap["FEMALE_MOVEMENT_LOWER"]
	idxMU := colMap["MALE_MOVEMENT_UPPER"]
	idxML := colMap["MALE_MOVEMENT_LOWER"]

	for i, row := range rows {
		if i == 0 || len(row) == 0 { continue }
		getCol := func(idx int) string {
			if idx != -1 && idx < len(row) { return strings.TrimSpace(row[idx]) }
			return ""
		}

		fU, fL := getCol(idxFU), getCol(idxFL)
		mU, mL := getCol(idxMU), getCol(idxML)
		
		female := strings.TrimSpace(fU + " " + fL)
		male := strings.TrimSpace(mU + " " + mL)
		
		if female != male && female != "" && male != "" {
			fmt.Printf("DIFF: Female = %q | Male = %q\n", female, male)
		}
	}
}
