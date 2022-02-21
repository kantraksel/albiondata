package client

import (
	"strconv"
	"strings"

	"github.com/kantraksel/albiondata/lib"
	"github.com/kantraksel/albiondata/log"
)

type operationJoinResponse struct {
	CharacterID   lib.CharacterID `mapstructure:"1"`
	CharacterName string          `mapstructure:"2"`
	Location      string          `mapstructure:"8"`
	GuildID       lib.CharacterID `mapstructure:"47"`
	GuildName     string          `mapstructure:"51"`
}

//CharacterPartsJSON string          `mapstructure:"6"`
//Edition            string          `mapstructure:"38"`

func (op operationJoinResponse) Process(state *albionState) {
	log.Debugf("Got JoinResponse operation...")

	loc, err := strconv.Atoi(strings.SplitN(op.Location, "-", 2)[0])
	if err != nil {
		log.Debugf("Unable to convert zoneID to int. Probably an instance.")
		state.LocationId = -2
	} else {
		state.LocationId = loc
		checkLocation(loc)
	}
	state.LocationString = op.Location
	log.Infof("Updating player location to %v.", op.Location)

	if state.CharacterId != op.CharacterID {
		log.Infof("Updating player ID to %v.", op.CharacterID)
	}
	state.CharacterId = op.CharacterID

	/*if state.CharacterName != op.CharacterName {
		log.Infof("Updating player to %v.", op.CharacterName)
	}
	state.CharacterName = op.CharacterName*/

	sendMsgToUploader(state, "", state)
}
