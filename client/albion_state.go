package client

import (
	"github.com/kantraksel/albiondata/lib"
	"github.com/kantraksel/albiondata/log"
	"github.com/kantraksel/albiondata/notification"
)

type albionState struct {
	LocationId     int
	LocationString string
	CharacterId    lib.CharacterID
	CharacterName  string
}

func (state albionState) IsValidLocation() bool {
	if state.LocationId < 0 {
		if state.LocationId == -1 {
			log.Error("The players location has not yet been set. Please transition zones so the location can be identified.")
			if !ConfigGlobal.Debug {
				notification.Push("The players location has not yet been set. Please transition zones so the location can be identified.")
			}
		} else {
			log.Error("The players location is not valid. Please transition zones so the location can be fixed.")
			if !ConfigGlobal.Debug {
				notification.Push("The players location is not valid. Please transition zones so the location can be fixed.")
			}
		}
		return false
	}
	return true
}
