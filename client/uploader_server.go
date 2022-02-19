package client

import (
	"net"

	"github.com/kantraksel/albiondata/log"
)

type serverUploader struct {
	url  string
	conn net.Conn
}

var (
	up *serverUploader
)

// newServerUploader creates a new server uploader
func newServerUploader(url string) uploader {
	if up == nil {
		conn, err := net.Dial("udp4", url)

		if err != nil {
			log.Errorf("Failed to create connection: %v", err)
			return nil
		}

		up = &serverUploader{
			url:  url,
			conn: conn,
		}
	}

	return up
}

func (u *serverUploader) sendToIngest(body []byte, topic string) {
	n, err := u.conn.Write(body)

	if err != nil {
		log.Errorf("Failed to write: %v", err)
	} else if n != len(body) {
		log.Warnf("Sent %v bytes, expected %v", n, len(body))
	}

	log.Debugf("Successfully sent message to %v", topic)
}
