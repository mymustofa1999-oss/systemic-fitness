package service

import (
	"context"
	"fmt"
	"log/slog"
	"net/smtp"
	"os"
)

// MailerService handles sending emails.
type MailerService interface {
	SendEmail(ctx context.Context, to string, subject string, body string) error
	SendReassessmentReminder(ctx context.Context, to string, name string) error
}

type defaultMailerService struct {
	logger *slog.Logger
	host   string
	port   string
	user   string
	pass   string
}

func NewMailerService(logger *slog.Logger) MailerService {
	return &defaultMailerService{
		logger: logger,
		host:   os.Getenv("SMTP_HOST"),
		port:   os.Getenv("SMTP_PORT"),
		user:   os.Getenv("SMTP_USER"),
		pass:   os.Getenv("SMTP_PASS"),
	}
}

func (m *defaultMailerService) SendEmail(ctx context.Context, to string, subject string, body string) error {
	if m.host == "" || m.port == "" {
		m.logger.Warn("SMTP configuration is missing, skipping actual email send", "to", to, "subject", subject)
		// For local development, we just log it
		return nil
	}

	auth := smtp.PlainAuth("", m.user, m.pass, m.host)
	msg := []byte(fmt.Sprintf("To: %s\r\nSubject: %s\r\n\r\n%s\r\n", to, subject, body))
	addr := fmt.Sprintf("%s:%s", m.host, m.port)

	if err := smtp.SendMail(addr, auth, m.user, []string{to}, msg); err != nil {
		m.logger.Error("Failed to send email", "to", to, "error", err)
		return err
	}

	m.logger.Info("Email sent successfully", "to", to, "subject", subject)
	return nil
}

func (m *defaultMailerService) SendReassessmentReminder(ctx context.Context, to string, name string) error {
	subject := "Waktunya Re-assessment Bulanan Anda!"
	body := fmt.Sprintf("Halo %s,\n\nSudah saatnya untuk memperbarui Assessment Anda bulan ini agar kami dapat memonitor perkembangan Anda dengan lebih baik.\n\nSilakan login ke aplikasi Systemic Fitness dan lengkapi Re-assessment Anda.\n\nTerima kasih,\nTim Systemic Fitness", name)
	return m.SendEmail(ctx, to, subject, body)
}
