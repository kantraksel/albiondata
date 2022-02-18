package client

type config struct {
	Debug                          bool
	DebugEvents                    map[int]bool
	DebugEventsString              string
	DebugEventsBlacklistString     string
	DebugOperations                map[int]bool
	DebugOperationsString          string
	DebugOperationsBlacklistString string
	DebugIgnoreDecodingErrors      bool
	DisableUpload                  bool
	ListenDevices                  string
	LogLevel                       string
	LogToFile                      bool
	Minimize                       bool
	Offline                        bool
	OfflinePath                    string
	RecordPath                     string
	NoCPULimit                     bool
}

//ConfigGlobal global config data
var ConfigGlobal = &config{
	LogLevel: "INFO",
}
