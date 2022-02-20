package client

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/kantraksel/albiondata/log"
	"github.com/kantraksel/albiondata/notification"
)

type LocationMapType map[int]bool

var (
	knownLocations LocationMapType
)

func checkLocation(location int) {
	isKnown := knownLocations[location]

	if !isKnown {
		info := fmt.Sprintf("Location %d is unknown. Please share where you've entered!", location)
		log.Info(info)
		notification.Push(info)
	}
}

func createLocations() {
	resp, err := http.Get(ConfigGlobal.DataUrl)

	if err != nil {
		log.Errorf("Failed to get %s", ConfigGlobal.DataUrl)
		return
	}

	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)

	if err != nil {
		log.Errorf("Failed to read %s", ConfigGlobal.DataUrl)
		return
	}

	knownLocations = make(LocationMapType)
	err = json.Unmarshal(body, &knownLocations)

	if err != nil {
		log.Errorf("Failed to parse %s", ConfigGlobal.DataUrl)
		return
	}
}
