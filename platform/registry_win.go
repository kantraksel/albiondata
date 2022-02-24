//go:build windows
// +build windows

package platform

import (
	"github.com/kantraksel/albiondata/log"
	"golang.org/x/sys/windows/registry"
)

func GetRegistryString(name string) string {
	key, err := registry.OpenKey(registry.CURRENT_USER, `Software\Albion Data`, registry.QUERY_VALUE)
	if err != nil {
		log.Error(err)
		return ""
	}
	defer key.Close()

	value, _, err := key.GetStringValue("")
	if err != nil {
		log.Error(err)
		return ""
	}

	return value
}
