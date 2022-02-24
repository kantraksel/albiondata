//go:build linux || darwin
// +build linux darwin

package platform

func GetRegistryString(name string) string {
	return ""
}
