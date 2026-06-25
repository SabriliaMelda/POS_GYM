package mailer

import (
	"errors"
	"fmt"
	"mime"
	"net/smtp"
	"os"
	"strings"
	"time"

	"pos-gym/backend/internal/config"
)

// Mailer mengirim email teks biasa lewat SMTP (mis. Gmail di port 587
// dengan STARTTLS otomatis dari net/smtp).
type Mailer struct {
	cfg config.Config
}

func New(cfg config.Config) *Mailer {
	return &Mailer{cfg: cfg}
}

// Configured true bila kredensial SMTP minimal sudah diisi.
func (m *Mailer) Configured() bool {
	return m.cfg.SMTPHost != "" && m.cfg.SMTPPort != "" &&
		m.cfg.SMTPUser != "" && m.cfg.SMTPPassword != "" && m.cfg.SMTPFrom != ""
}

// Send mengirim email teks biasa berenkode UTF-8 ke satu penerima.
func (m *Mailer) Send(toEmail, toName, subject, body string) error {
	if !m.Configured() {
		return errors.New("SMTP belum dikonfigurasi")
	}

	fromHeader := m.cfg.SMTPFrom
	if m.cfg.SMTPFromName != "" {
		fromHeader = fmt.Sprintf("%s <%s>",
			mime.QEncoding.Encode("UTF-8", m.cfg.SMTPFromName), m.cfg.SMTPFrom)
	}
	toHeader := toEmail
	if toName != "" {
		toHeader = fmt.Sprintf("%s <%s>",
			mime.QEncoding.Encode("UTF-8", toName), toEmail)
	}

	domain := "localhost"
	if at := strings.LastIndex(m.cfg.SMTPFrom, "@"); at >= 0 && at+1 < len(m.cfg.SMTPFrom) {
		domain = m.cfg.SMTPFrom[at+1:]
	}
	now := time.Now()
	messageID := fmt.Sprintf("<%d.%d@%s>", now.UnixNano(), os.Getpid(), domain)

	// Header lengkap (Date, Message-ID, Reply-To) mengurangi peluang
	// email dianggap spam dibanding hanya From/To/Subject.
	var sb strings.Builder
	sb.WriteString("From: " + fromHeader + "\r\n")
	sb.WriteString("To: " + toHeader + "\r\n")
	sb.WriteString("Reply-To: " + m.cfg.SMTPFrom + "\r\n")
	sb.WriteString("Subject: " + mime.QEncoding.Encode("UTF-8", subject) + "\r\n")
	sb.WriteString("Date: " + now.Format(time.RFC1123Z) + "\r\n")
	sb.WriteString("Message-ID: " + messageID + "\r\n")
	// List-Unsubscribe = sinyal pengirim sah (bukan spammer) bagi Gmail.
	sb.WriteString("List-Unsubscribe: <mailto:" + m.cfg.SMTPFrom + "?subject=Unsubscribe>\r\n")
	sb.WriteString("MIME-Version: 1.0\r\n")
	sb.WriteString("Content-Type: text/plain; charset=\"UTF-8\"\r\n")
	sb.WriteString("Content-Transfer-Encoding: 8bit\r\n")
	sb.WriteString("\r\n")
	sb.WriteString(normalizeNewlines(body))

	addr := m.cfg.SMTPHost + ":" + m.cfg.SMTPPort
	auth := smtp.PlainAuth("", m.cfg.SMTPUser, m.cfg.SMTPPassword, m.cfg.SMTPHost)
	return smtp.SendMail(addr, auth, m.cfg.SMTPFrom, []string{toEmail}, []byte(sb.String()))
}

// normalizeNewlines memastikan baris memakai CRLF sesuai standar email.
func normalizeNewlines(body string) string {
	body = strings.ReplaceAll(body, "\r\n", "\n")
	return strings.ReplaceAll(body, "\n", "\r\n")
}
