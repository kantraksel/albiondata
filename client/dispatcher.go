package client

import (
	"encoding/json"

	"github.com/kantraksel/albiondata/log"
)

type dispatcher struct {
	serverUploader uploader
}

var (
	dis *dispatcher
)

func createDispatcher() {
	dis = &dispatcher{
		serverUploader: newServerUploader(ConfigGlobal.RemoteServer),
	}
}

func sendMsgToUploader(upload interface{}, topic string, state *albionState) {
	if ConfigGlobal.DisableUpload {
		log.Info("Upload is disabled.")
		return
	}

	data, err := json.Marshal(upload)
	if err != nil {
		log.Errorf("Error while marshalling payload for %v: %v", err, topic)
		return
	}

	dis.serverUploader.sendToIngest(data, topic)
}
