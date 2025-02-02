//go:build windows
// +build windows

package notification

import (
	"github.com/kantraksel/albiondata/log"
	toast "gopkg.in/toast.v1"
)

func Push(msg string) {
	note := toast.Notification{AppID: "Albion Data", Title: "Albion Data", Message: msg}

	err := note.Push()
	if err != nil {
		log.Error(err)
	}
}
