package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	path := "../systemic-fitness-api/internal/repository/trainer_card_repo.go"
	b, err := ioutil.ReadFile(path)
	if err != nil {
		panic(err)
	}
	content := string(b)

	endPatchStr := 	if batch.Len() > 0 {
		br := tx.SendBatch(ctx, batch)
		// We need to consume all results otherwise commit fails
		for i := 0; i < batch.Len(); i++ {
			if _, err := br.Exec(); err != nil {
				br.Close()
				return fmt.Errorf("batch execute at idx %d: %w", i, err)
			}
		}
		if err := br.Close(); err != nil {
			return fmt.Errorf("close batch: %w", err)
		}
	}

	return tx.Commit(ctx)
}


	// append the end block because it was overwritten.
	content = content + endPatchStr

	err = ioutil.WriteFile(path, []byte(content), 0644)
	if err != nil {
		panic(err)
	}
	fmt.Println("success")
}
