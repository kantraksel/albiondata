package client

import (
	"encoding/json"

	"github.com/kantraksel/albiondata/lib"
	"github.com/kantraksel/albiondata/log"
)

type dispatcher struct {
}

var (
	dis *dispatcher
)

func createDispatcher() {
	dis = &dispatcher{
	}
}

func sendMsgToPublicUploaders(upload interface{}, topic string, state *albionState) {
	data, err := json.Marshal(upload)
	if err != nil {
		log.Errorf("Error while marshalling payload for %v: %v", err, topic)
		return
	}

	sendMsgToUploaders(data, topic, dis.publicUploaders)
	sendMsgToUploaders(data, topic, dis.privateUploaders)
}

func sendMsgToPrivateUploaders(upload lib.PersonalizedUpload, topic string, state *albionState) {
	if ConfigGlobal.DisableUpload {
		log.Info("Upload is disabled.")
		return
	}

	// TODO: Re-enable this when issue #14 is fixed
	// Will personalize with blanks for now in order to allow people to see the format
	// if state.CharacterName == "" || state.CharacterId == "" {
	// 	log.Error("The player name or id has not been set. Please restart the game and make sure the client is running.")
	// 	notification.Push("The player name or id has not been set. Please restart the game and make sure the client is running.")
	// 	return
	// }

	upload.Personalize(state.CharacterId, state.CharacterName)

	data, err := json.Marshal(upload)
	if err != nil {
		log.Errorf("Error while marshalling payload for %v: %v", err, topic)
		return
	}

	if len(dis.privateUploaders) > 0 {
		sendMsgToUploaders(data, topic, dis.privateUploaders)
	}
}

func sendMsgToUploaders(msg []byte, topic string, uploaders []uploader) {
	if ConfigGlobal.DisableUpload {
		log.Info("Upload is disabled.")
		return
	}

	for _, u := range uploaders {
		u.sendToIngest(msg, topic)
	}
}
