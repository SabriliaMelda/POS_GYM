package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"pos-gym/backend/internal/config"
	"pos-gym/backend/internal/database"
	"pos-gym/backend/internal/handler"
	"pos-gym/backend/internal/httpx"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("load config: %v", err)
	}

	db, err := database.Open(cfg)
	if err != nil {
		log.Fatalf("open database: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatalf("ping database: %v", err)
	}

	authHandler := handler.NewAuthHandler(db, cfg)

	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})
	mux.HandleFunc("POST /api/auth/login", authHandler.Login)
	mux.HandleFunc("PATCH /api/auth/me", authHandler.UpdateProfile)
	mux.HandleFunc("GET /api/admin/users/cashiers", authHandler.ListCashiers)
	mux.HandleFunc("POST /api/admin/users/cashiers", authHandler.CreateCashier)
	mux.HandleFunc("PATCH /api/admin/users/cashiers/{id}/password", authHandler.ResetCashierPassword)
	mux.HandleFunc("DELETE /api/admin/users/cashiers/{id}", authHandler.DeleteCashier)
	mux.HandleFunc("GET /api/admin/master/gym-packages", authHandler.ListGymPackages)
	mux.HandleFunc("POST /api/admin/master/gym-packages", authHandler.CreateGymPackage)
	mux.HandleFunc("PUT /api/admin/master/gym-packages/{id}", authHandler.UpdateGymPackage)
	mux.HandleFunc("DELETE /api/admin/master/gym-packages/{id}", authHandler.DeleteGymPackage)
	mux.HandleFunc("GET /api/admin/master/fnb", authHandler.ListFNBItems)
	mux.HandleFunc("POST /api/admin/master/fnb", authHandler.CreateFNBItem)
	mux.HandleFunc("PUT /api/admin/master/fnb/{id}", authHandler.UpdateFNBItem)
	mux.HandleFunc("DELETE /api/admin/master/fnb/{id}", authHandler.DeleteFNBItem)
	mux.HandleFunc("POST /api/admin/master/fnb/image", authHandler.UploadFNBImage)
	mux.HandleFunc("GET /uploads/fnb/{name}", authHandler.ServeFNBImage)
	mux.HandleFunc("GET /api/admin/master/members", authHandler.ListMembers)
	mux.HandleFunc("DELETE /api/admin/master/members/{id}", authHandler.DeleteMember)
	mux.HandleFunc("POST /api/admin/master/members/{id}/follow-up", authHandler.SendMemberFollowUp)
	mux.HandleFunc("POST /api/admin/master/members/{id}/renew", authHandler.RenewMember)
	mux.HandleFunc("POST /api/admin/master/members/{id}/vouchers/{milestone}/use", authHandler.RedeemVoucher)
	mux.HandleFunc("GET /api/admin/transactions/gym", authHandler.ListGymTransactions)
	mux.HandleFunc("POST /api/admin/transactions/gym", authHandler.CreateGymTransaction)
	mux.HandleFunc("GET /api/admin/transactions/fnb", authHandler.ListFNBTransactions)
	mux.HandleFunc("POST /api/admin/transactions/fnb", authHandler.CreateFNBTransaction)
	// Registrasi member baru via QR (publik, dari HP calon member).
	mux.HandleFunc("GET /api/register/info", authHandler.RegisterInfo)
	mux.HandleFunc("POST /api/register/member", authHandler.RegisterMember)
	// Pembayaran Midtrans (Snap).
	mux.HandleFunc("POST /api/payment/snap", authHandler.CreateSnapPayment)
	// Webhook notifikasi Midtrans (publik) — menangkap lunas semua channel.
	mux.HandleFunc("POST /api/payment/notification", authHandler.PaymentNotification)
	mux.HandleFunc("GET /api/payment/status", authHandler.CheckPaymentStatus)
	// Absensi: lookup + check-in publik dari HP member (tanpa login) + daftar kasir.
	mux.HandleFunc("GET /api/attendance/member", authHandler.LookupMemberForCheckIn)
	mux.HandleFunc("POST /api/attendance/check-in", authHandler.CheckInAttendance)
	mux.HandleFunc("GET /api/admin/attendance", authHandler.ListAttendance)

	// --- [AWAL PERUBAHAN UNTUK RENDER] ---
	// Render otomatis memberikan "Pintu" (Port) acak lewat variabel sistem "PORT".
	port := os.Getenv("PORT")

	// Jika "PORT" kosong (artinya sedang jalan di laptopmu), pakai port dari .env
	if port == "" {
		port = cfg.AppPort
	}
	// --- [AKHIR PERUBAHAN UNTUK RENDER] ---

	server := &http.Server{
		Addr:         ":" + port, // Gunakan variabel port di sini
		Handler:      httpx.CORS(cfg.CORSAllowedOrigins)(httpx.Recover(mux)),
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	go func() {
		// Log-nya juga disesuaikan agar menampilkan port yang benar
		log.Printf("backend running on port:%s", port)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			log.Fatalf("listen: %v", err)
		}
	}()

	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	<-stop

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Printf("shutdown error: %v", err)
	}
}
