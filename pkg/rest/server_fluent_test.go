package rest

import (
	"fmt"
	"net/http"
	"testing"

	"github.com/GopeedLab/gopeed/pkg/rest/model"
)

func TestNativeExplicitAPIEnableStartsListener(t *testing.T) {
	enabled := true
	port, err := Start(&model.StartConfig{
		NativeMode: true,
		Storage:    model.StorageMem,
		ApiEnable:  &enabled,
		Network:    "tcp",
		Address:    "127.0.0.1:0",
	})
	if err != nil {
		t.Fatal(err)
	}
	defer Stop()
	if port == 0 {
		t.Fatal("explicitly enabled native API did not open a listener")
	}

	response, err := http.Get(fmt.Sprintf("http://127.0.0.1:%d/api/v1/info", port))
	if err != nil {
		t.Fatal(err)
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		t.Fatalf("REST API returned status %d", response.StatusCode)
	}
}
