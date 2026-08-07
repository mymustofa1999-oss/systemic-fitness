package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/go-chi/chi/v5"
	chimw "github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/fitcoach/api/internal/config"
	"github.com/fitcoach/api/internal/fcm"
	"github.com/fitcoach/api/internal/handler"
	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/scheduler"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/internal/ws"
	"github.com/fitcoach/api/pkg/response"
	"github.com/fitcoach/api/pkg/utils"
)

func main() {
	// ─── Logger ─────────────────────────────────────────────────
	cfg := config.Load()

	logLevel := slog.LevelInfo
	if cfg.IsDevelopment() {
		logLevel = slog.LevelDebug
	}
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: logLevel}))
	slog.SetDefault(logger)

	// ─── Database ───────────────────────────────────────────────
	ctx := context.Background()

	poolCfg, err := pgxpool.ParseConfig(cfg.DatabaseURL)
	if err != nil {
		logger.Error("invalid database URL", "error", err)
		os.Exit(1)
	}
	poolCfg.MaxConns = int32(cfg.DBMaxConns)
	poolCfg.MinConns = int32(cfg.DBMinConns)

	db, err := pgxpool.NewWithConfig(ctx, poolCfg)
	if err != nil {
		logger.Error("failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer db.Close()

	if err := db.Ping(ctx); err != nil {
		logger.Error("database ping failed", "error", err)
		os.Exit(1)
	}
	logger.Info("database connected")

	// ─── Utilities ──────────────────────────────────────────────
	jwtManager := utils.NewJWTManager(cfg.JWTSecret, cfg.JWTAccessExpiry, cfg.JWTRefreshExpiry)

	// ─── WebSocket Hub (must init before services that need it) ─
	wsHub := ws.NewHub(logger)
	go wsHub.Run()

	// ─── Repositories ───────────────────────────────────────────
	userRepo := repository.NewUserRepository(db)
	exerciseRepo := repository.NewExerciseRepository(db)
	workoutRepo := repository.NewWorkoutRepository(db)
	programRepo := repository.NewProgramRepository(db)
	progressRepo := repository.NewProgressRepository(db)
	nutritionRepo := repository.NewNutritionRepository(db)
	messageRepo := repository.NewMessageRepository(db)
	automationRepo := repository.NewAutomationRepository(db)
	paymentRepo := repository.NewPaymentRepository(db)
	notificationRepo := repository.NewNotificationRepository(db)
	foodRepo := repository.NewFoodRepository(db)
	habitRepo := repository.NewHabitRepository(db)
	formRepo := repository.NewFormRepository(db)
	schedulingRepo := repository.NewSchedulingRepository(db)
	groupRepo := repository.NewGroupRepository(db)
	challengeRepo := repository.NewChallengeRepository(db)
	announcementRepo := repository.NewAnnouncementRepository(db)
	uploadRepo := repository.NewUploadRepository(db)
	dlRepo := repository.NewDigitalLibraryRepository(db)
	medicineRepo := repository.NewMedicineRepository(db)
	programCategoryRepo := repository.NewProgramCategoryRepository(db)
	customerSetupRepo := repository.NewCustomerSetupRepository(db)
	dailyJournalRepo := repository.NewDailyJournalRepository(db)
	trainerCardRepo := repository.NewTrainerCardRepository(db)
	trainerCardTemplateRepo := repository.NewTrainerCardTemplateRepository(db)
	menuRepo := repository.NewMenuRepository(db)
	trainingScheduleRepo := repository.NewTrainingScheduleRepository(db)
	clientSubRepo := repository.NewClientSubscriptionRepository(db)
	bankAccountRepo := repository.NewBankAccountRepository(db)
	equipmentRepo := repository.NewEquipmentRepository(db)
	assessmentRepo := repository.NewAssessmentRepository(db)
	quarterlyAssessmentRepo := repository.NewQuarterlyAssessmentRepository(db)
	nutritionGuidanceRepo := repository.NewNutritionGuidanceRepository(db)
	promotionRepo := repository.NewPromotionRepository(db)
	cmsContentRepo := repository.NewCMSContentRepository(db)
	cmsTestimonialRepo := repository.NewCMSTestimonialRepository(db)
	cmsProgramRepo := repository.NewCMSProgramRepository(db)
	cmsPricingRepo := repository.NewCMSPricingRepository(db)
	conditionRepo := repository.NewConditionRepository(db)         // SF Phase 1 — master kondisi fisik
	assessmentV2Repo := repository.NewAssessmentV2Repository(db)    // SF Phase 2 — assessment v2
	labConsultationRepo := repository.NewLabConsultationRepository(db) // SF Phase 6
	tier4WaitlistRepo := repository.NewTier4WaitlistRepository(db)     // SF Phase 6
	clinicalNoteRepo := repository.NewClinicalNoteRepository(db)       // SF Phase 7b
	healthContentRepo := repository.NewHealthContentRepository(db)
	workoutSessionRepo := repository.NewWorkoutSessionRepository(db)    // Level 5/6 session logs
	workoutReminderRepo := repository.NewWorkoutReminderRepository(db)  // client workout reminders

	// Wire up WebSocket hub's member resolver (avoids circular import)
	wsHub.MemberResolver = messageRepo.GetMemberIDs

	// ─── FCM Client ────────────────────────────────────────────
	var fcmClient *fcm.Client
	if cfg.FCMCredentialsFile != "" {
		var err error
		fcmClient, err = fcm.New(cfg.FCMCredentialsFile, logger)
		if err != nil {
			logger.Error("failed to init FCM client", "error", err)
			os.Exit(1)
		}
	} else {
		fcmClient = fcm.NewNoop(logger)
	}

	// ─── Services ───────────────────────────────────────────────
	authService := service.NewAuthService(userRepo, jwtManager, cfg.BcryptCost, logger)
	userService := service.NewUserService(userRepo, logger)
	workoutService := service.NewWorkoutService(workoutRepo, exerciseRepo, logger)
	programService := service.NewProgramService(programRepo, logger)
	progressService := service.NewProgressService(progressRepo, programRepo, logger)
	nutritionService := service.NewNutritionService(nutritionRepo, logger)
	messageService := service.NewMessageService(messageRepo, wsHub, logger)
	automationService := service.NewAutomationService(automationRepo, logger)
	dashboardService := service.NewDashboardService(userRepo, paymentRepo, logger)
	notificationService := service.NewNotificationService(notificationRepo, fcmClient, logger)
	foodService := service.NewFoodService(foodRepo, logger)
	habitService := service.NewHabitService(habitRepo, logger)
	formService := service.NewFormService(formRepo, logger)
	schedulingService := service.NewSchedulingService(schedulingRepo, logger)
	groupService := service.NewGroupService(groupRepo, logger)
	challengeService := service.NewChallengeService(challengeRepo, logger)
	announcementService := service.NewAnnouncementService(announcementRepo, logger)
	uploadService := service.NewUploadService(uploadRepo, logger, cfg.UploadDir, cfg.MaxUploadSizeMB, cfg.BaseURL)
	dlService := service.NewDigitalLibraryService(dlRepo, logger)
	medicineService := service.NewMedicineService(medicineRepo, logger)
	programCategoryService := service.NewProgramCategoryService(programCategoryRepo, logger)
	customerSetupService := service.NewCustomerSetupService(customerSetupRepo, logger)
	dailyJournalService := service.NewDailyJournalService(dailyJournalRepo, logger)
	trainerCardTemplateService := service.NewTrainerCardTemplateService(trainerCardTemplateRepo, logger)
	// notificationService is already initialized at line 146

	trainerCardService := service.NewTrainerCardService(trainerCardRepo, trainerCardTemplateRepo, notificationService, logger)
	paymentService := service.NewPaymentService(paymentRepo, trainerCardService, notificationService, logger)
	menuService := service.NewMenuService(menuRepo, logger)
	trainingScheduleService := service.NewTrainingScheduleService(trainingScheduleRepo, notificationService, logger)
	bankAccountService := service.NewBankAccountService(bankAccountRepo, logger)
	midtransService := service.NewMidtransService(
		cfg.MidtransServerKey,
		cfg.MidtransClientKey,
		cfg.MidtransEnv,
		cfg.MidtransNotifyURL,
		logger,
	)
	clientSubService := service.NewClientSubscriptionService(clientSubRepo, bankAccountRepo, midtransService, trainerCardService, notificationService, logger)
	equipmentService := service.NewEquipmentService(equipmentRepo, logger)
	assessmentService := service.NewAssessmentService(assessmentRepo, logger)
	nutritionGuidanceService := service.NewNutritionGuidanceService(nutritionGuidanceRepo, logger)
	promotionService := service.NewPromotionService(promotionRepo, logger)
	cmsService := service.NewCMSService(cmsContentRepo, cmsTestimonialRepo, cmsProgramRepo, cmsPricingRepo, logger)
	conditionService := service.NewConditionService(conditionRepo, logger)                                    // SF Phase 1
	assessmentV2Service := service.NewAssessmentV2Service(assessmentV2Repo, conditionRepo, userRepo, clientSubRepo, trainerCardService, logger) // SF Phase 2
	labConsultationService := service.NewLabConsultationService(labConsultationRepo, logger)                  // SF Phase 6
	tier4WaitlistService := service.NewTier4WaitlistService(tier4WaitlistRepo, logger)             // SF Phase 6
	clinicalNoteService := service.NewClinicalNoteService(clinicalNoteRepo, assessmentV2Repo, logger) // SF Phase 7b
	healthContentService := service.NewHealthContentService(healthContentRepo, logger)
	workoutSessionService := service.NewWorkoutSessionService(workoutSessionRepo, trainerCardRepo, logger)
	workoutReminderService := service.NewWorkoutReminderService(workoutReminderRepo, logger)

	// ─── Handlers ───────────────────────────────────────────────
	authHandler := handler.NewAuthHandler(authService)
	userHandler := handler.NewUserHandler(userService)
	exerciseHandler := handler.NewExerciseHandler(workoutService)
	workoutHandler := handler.NewWorkoutHandler(workoutService)
	programHandler := handler.NewProgramHandler(programService)
	progressHandler := handler.NewProgressHandler(progressService)
	nutritionHandler := handler.NewNutritionHandler(nutritionService)
	messageHandler := handler.NewMessageHandler(messageService)
	automationHandler := handler.NewAutomationHandler(automationService)
	dashboardHandler := handler.NewDashboardHandler(dashboardService)
	paymentHandler := handler.NewPaymentHandler(paymentService)
	notificationHandler := handler.NewNotificationHandler(notificationService)
	foodHandler := handler.NewFoodHandler(foodService, uploadService)
	habitHandler := handler.NewHabitHandler(habitService, uploadService)
	formHandler := handler.NewFormHandler(formService)
	schedulingHandler := handler.NewSchedulingHandler(schedulingService)
	groupHandler := handler.NewGroupHandler(groupService, uploadService)
	challengeHandler := handler.NewChallengeHandler(challengeService, uploadService)
	announcementHandler := handler.NewAnnouncementHandler(announcementService, uploadService)
	uploadHandler := handler.NewUploadHandler(uploadService, cfg.MaxUploadSizeMB)
	dlHandler := handler.NewDigitalLibraryHandler(dlService, uploadService)
	medicineHandler := handler.NewMedicineHandler(medicineService, uploadService)
	programCategoryHandler := handler.NewProgramCategoryHandler(programCategoryService)
	customerSetupHandler := handler.NewCustomerSetupHandler(customerSetupService)
	dailyJournalHandler := handler.NewDailyJournalHandler(dailyJournalService)
	trainerCardTemplateHandler := handler.NewTrainerCardTemplateHandler(trainerCardTemplateService)
	trainerCardHandler := handler.NewTrainerCardHandler(trainerCardService)
	menuHandler := handler.NewMenuHandler(menuService)
	trainingScheduleHandler := handler.NewTrainingScheduleHandler(trainingScheduleService)
	clientSubHandler := handler.NewClientSubscriptionHandler(clientSubService, uploadService)
	bankAccountHandler := handler.NewBankAccountHandler(bankAccountService)
	equipmentHandler := handler.NewEquipmentHandler(equipmentService)
	assessmentHandler := handler.NewAssessmentHandler(assessmentService)
	quarterlyAssessmentHandler := handler.NewQuarterlyAssessmentHandler(quarterlyAssessmentRepo)
	nutritionGuidanceHandler := handler.NewNutritionGuidanceHandler(nutritionGuidanceService)
	promotionHandler := handler.NewPromotionHandler(promotionService, uploadService)
	publicCMSHandler := handler.NewPublicCMSHandler(cmsService)
	conditionHandler := handler.NewConditionHandler(conditionService)             // SF Phase 1
	assessmentV2Handler := handler.NewAssessmentV2Handler(assessmentV2Service)    // SF Phase 2
	labConsultationHandler := handler.NewLabConsultationHandler(labConsultationService) // SF Phase 6
	tier4WaitlistHandler := handler.NewTier4WaitlistHandler(tier4WaitlistService)       // SF Phase 6
	consultantHandler := handler.NewConsultantHandler(clinicalNoteService, labConsultationService) // SF Phase 7b
	healthContentHandler := handler.NewHealthContentHandler(healthContentService)
	workoutSessionHandler := handler.NewWorkoutSessionHandler(workoutSessionService)
	workoutReminderHandler := handler.NewWorkoutReminderHandler(workoutReminderService)

	// Training Session Logs (Manual Input Form)
	trainingSessionRepo := repository.NewTrainingSessionRepo(db)
	trainingSessionService := service.NewTrainingSessionService(trainingSessionRepo)
	trainingSessionHandler := handler.NewTrainingSessionHandler(trainingSessionService)

	// Systemic Session Logs
	systemicSessionRepo := repository.NewSystemicSessionLogRepository(db)
	systemicSessionService := service.NewSystemicSessionLogService(systemicSessionRepo)
	systemicSessionHandler := handler.NewSystemicSessionLogHandler(systemicSessionService)

	// Adapter for paid-subscription middleware (avoids middleware → service import cycle).
	subscriptionInfoFn := func(ctx context.Context, userID string) (middleware.SubscriptionInfo, error) {
		res, err := clientSubService.GetMySubscription(ctx, userID)
		if err != nil || res == nil {
			return middleware.SubscriptionInfo{}, err
		}
		info := middleware.SubscriptionInfo{HasSubscription: res.HasSubscription}
		if res.Subscription != nil {
			info.Status = res.Subscription.Status
			info.Tier = res.Subscription.Tier
		}
		return info, nil
	}

	// ─── Scheduler ──────────────────────────────────────────────
	sched := scheduler.New(automationRepo, programRepo, messageRepo, notificationRepo, workoutReminderRepo, fcmClient, logger)
	sched.Start()

	// ─── Router ─────────────────────────────────────────────────
	r := chi.NewRouter()

	// Global middleware
	r.Use(chimw.RequestID)
	r.Use(chimw.RealIP)
	r.Use(middleware.Logger(logger))
	r.Use(middleware.CORS(cfg.CORSAllowedOrigins))
	r.Use(chimw.Recoverer)
	r.Use(chimw.Heartbeat("/ping"))

	// Health check
	r.Get("/health", handler.HealthCheck)

	// API routes
	r.Route("/api", func(r chi.Router) {

		// ── Auth (public) ───────────────────────────────────
		r.Route("/auth", func(r chi.Router) {
			r.Post("/register", authHandler.Register)
			r.Post("/login", authHandler.Login)
			r.Post("/refresh", authHandler.Refresh)
			r.Post("/forgot-password", authHandler.ForgotPassword)

			r.Group(func(r chi.Router) {
				r.Use(middleware.Auth(jwtManager))
				r.Get("/me", authHandler.Me)
			})
		})

		// ── Midtrans webhook (public, gateway-to-server callback) ──
		// No auth — Midtrans signs each payload, server verifies signature.
		r.Post("/payments/midtrans/webhook", clientSubHandler.MidtransWebhook)

		// ── Public CMS (landing page content, no auth) ──────
		r.Get("/public/cms/landing", publicCMSHandler.GetLanding)

		// All routes below require authentication
		r.Group(func(r chi.Router) {
			r.Use(middleware.Auth(jwtManager))

			// ── Users (admin+) ──────────────────────────────
			r.Route("/users", func(r chi.Router) {
				r.With(middleware.RequireRole(model.RoleAdmin)).Get("/", userHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin)).Post("/invite", userHandler.Invite)

				r.Route("/{id}", func(r chi.Router) {
					r.With(middleware.RequireSelfOrRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant)).Get("/", userHandler.GetByID)
					r.With(middleware.RequireSelfOrRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant)).Put("/", userHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin)).Delete("/", userHandler.Delete)
					r.With(middleware.RequireSelfOrRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant)).Get("/stats", userHandler.Stats)
					r.With(middleware.RequireMinRole(model.RoleTrainer)).Get("/assessments", assessmentHandler.ListByUser)
					
					// Training Session Logs
					r.With(middleware.RequireMinRole(model.RoleTrainer)).Get("/training-sessions", trainingSessionHandler.GetLogs)
					r.With(middleware.RequireMinRole(model.RoleTrainer)).Post("/training-sessions", trainingSessionHandler.UpsertLogs)

					// Systemic Session Logs
					r.With(middleware.RequireMinRole(model.RoleTrainer)).Get("/systemic-session-log", systemicSessionHandler.GetLogs)
					r.With(middleware.RequireMinRole(model.RoleTrainer)).Post("/systemic-session-log", systemicSessionHandler.CreateLog)
				})
			})

			// ── Clients (dedicated) ─────────────────────────
			r.Route("/clients", func(r chi.Router) {
				r.Get("/", userHandler.ListClients)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant)).Post("/assign", userHandler.AssignClient)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant)).Post("/unassign", userHandler.UnassignClient)
			})

			// ── Team (dedicated) ────────────────────────────
			r.Route("/team", func(r chi.Router) {
				r.Use(middleware.RequireRole(model.RoleAdmin, model.RoleConsultant, model.RoleTrainer))
				r.Get("/", userHandler.ListTeam)
			})

			// ── Exercises ───────────────────────────────────
			r.Route("/exercises", func(r chi.Router) {
				r.Get("/", exerciseHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", exerciseHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", exerciseHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", exerciseHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", exerciseHandler.Delete)
				})
			})

			// ── Workouts ────────────────────────────────────
			r.Route("/workouts", func(r chi.Router) {
				r.Get("/", workoutHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", workoutHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", workoutHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", workoutHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/duplicate", workoutHandler.Duplicate)
				})
			})

			// ── Programs ────────────────────────────────────
			r.Route("/programs", func(r chi.Router) {
				r.Get("/", programHandler.List)
				r.Get("/templates", programHandler.Templates)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", programHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", programHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", programHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/assign", programHandler.Assign)
				})
			})

			// ── Progress ────────────────────────────────────
			r.Route("/progress", func(r chi.Router) {
				r.Post("/log", progressHandler.LogProgress)
				r.Post("/body-metric", progressHandler.LogBodyMetric)
				r.Route("/user/{id}", func(r chi.Router) {
					r.Use(middleware.RequireSelfOrRole(model.RoleAdmin, model.RoleTrainer))
					r.Get("/", progressHandler.GetHistory)
					r.Get("/charts", progressHandler.GetCharts)
					r.Get("/body-metrics", progressHandler.GetBodyMetrics)
				})
			})

			// ── Nutrition ───────────────────────────────────
			r.Route("/nutrition", func(r chi.Router) {
				r.Get("/meal-plans", nutritionHandler.ListMealPlans)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/meal-plans", nutritionHandler.CreateMealPlan)
				r.Post("/log", nutritionHandler.LogNutrition)
				r.Route("/user/{id}", func(r chi.Router) {
					r.Use(middleware.RequireSelfOrRole(model.RoleAdmin, model.RoleTrainer))
					r.Get("/daily", nutritionHandler.GetDaily)
				})
			})

			// ── Nutrition Guidance & Monitoring (paid only) ─
			r.Route("/nutrition-guidance", func(r chi.Router) {
				r.Use(middleware.RequirePaidSubscription(subscriptionInfoFn))
				r.Post("/profile", nutritionGuidanceHandler.UpsertProfile)
				r.Get("/plan", nutritionGuidanceHandler.GetPlan)
				r.Post("/daily/log", nutritionGuidanceHandler.SubmitDailyLog)
				r.Get("/daily/result", nutritionGuidanceHandler.GetDailyResult)
				r.Get("/daily/logs", nutritionGuidanceHandler.ListMyLogs)
			})

			// ── Nutrition Guidance Admin (admin/trainer) ────
			r.Route("/admin/nutrition-guidance", func(r chi.Router) {
				r.Use(middleware.RequireMinRole(model.RoleTrainer))
				r.Get("/users/{id}/profile", nutritionGuidanceHandler.AdminGetProfile)
				r.Put("/users/{id}/profile", nutritionGuidanceHandler.AdminUpsertProfile)
				r.Get("/users/{id}/plan", nutritionGuidanceHandler.AdminGetPlan)
				r.Get("/users/{id}/logs", nutritionGuidanceHandler.AdminListLogs)
			})

			// ── Messages ────────────────────────────────────
			r.Route("/messages", func(r chi.Router) {
				r.Get("/conversations", messageHandler.ListConversations)
				r.Post("/direct", messageHandler.CreateDirect)
				r.Post("/group", messageHandler.CreateGroup)
				r.Post("/send", messageHandler.Send)
				r.Route("/conversations/{id}", func(r chi.Router) {
					r.Get("/", messageHandler.GetMessages)
					r.Post("/read", messageHandler.MarkAsRead)
				})
			})

			// ── Online Status ───────────────────────────────
			r.Get("/users/online", func(w http.ResponseWriter, req *http.Request) {
				ids := wsHub.OnlineUserIDs()
				response.OK(w, map[string]any{
					"online_user_ids": ids,
					"count":           len(ids),
				})
			})
			r.Post("/users/online/check", func(w http.ResponseWriter, req *http.Request) {
				var input struct {
					UserIDs []string `json:"user_ids"`
				}
				if err := response.DecodeJSON(req, &input); err != nil {
					response.BadRequest(w, "Invalid request body")
					return
				}
				result := wsHub.AreOnline(input.UserIDs)
				response.OK(w, result)
			})

			// ── Automations (admin/trainer) ─────────────────
			r.Route("/automations", func(r chi.Router) {
				r.Use(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer))
				r.Get("/", automationHandler.List)
				r.Post("/", automationHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", automationHandler.GetByID)
					r.Put("/", automationHandler.Update)
					r.Delete("/", automationHandler.Delete)
					r.Get("/logs", automationHandler.GetLogs)
				})
			})

			// ── Dashboard (owner/admin/finance) ─────────────
			r.Route("/dashboard", func(r chi.Router) {
				r.Use(middleware.RequireRole(model.RoleOwner, model.RoleAdmin, model.RoleFinance))
				r.Get("/overview", dashboardHandler.Overview)
				r.Get("/revenue", dashboardHandler.Revenue)
				r.Get("/engagement", dashboardHandler.Engagement)
				r.Get("/trainers", dashboardHandler.TrainerPerformance)
			})

			// ── Notifications ───────────────────────────────
			r.Route("/notifications", func(r chi.Router) {
				r.Post("/device-token", notificationHandler.RegisterToken)
				r.Delete("/device-token", notificationHandler.UnregisterToken)
				r.Get("/", notificationHandler.List)
				r.Get("/unread-count", notificationHandler.UnreadCount)
				r.Post("/read-all", notificationHandler.MarkAllAsRead)
				r.Post("/{id}/read", notificationHandler.MarkAsRead)

				// Admin-only: broadcast / promo
				r.With(middleware.RequireRole(model.RoleAdmin)).Post("/broadcast", notificationHandler.Broadcast)
				r.With(middleware.RequireRole(model.RoleAdmin)).Get("/broadcasts", notificationHandler.ListBroadcasts)
			})

			// ── Client Subscription ─────────────────────────
			r.Route("/subscription", func(r chi.Router) {
				r.Get("/plans", clientSubHandler.ListPlans)
				r.Get("/plans/{id}", clientSubHandler.GetPlan)
				r.Get("/me", clientSubHandler.MySubscription)
				r.Post("/subscribe", clientSubHandler.Subscribe)
				r.Post("/{id}/cancel", clientSubHandler.Cancel)
				r.Get("/history", clientSubHandler.History)
				r.Get("/payments", clientSubHandler.MyPayments)
				r.Post("/payments/{id}/proof", clientSubHandler.UploadPaymentProof)
				// Client-facing read of active bank accounts (for payment instructions)
				r.Get("/bank-accounts", bankAccountHandler.List)
			})

			// ── Payments (owner/finance) ────────────────────
			r.Route("/payments", func(r chi.Router) {
				r.Use(middleware.RequireRole(model.RoleFinance))
				r.Get("/", paymentHandler.ListPayments)
				r.Patch("/{id}/status", paymentHandler.UpdatePaymentStatus)
				r.Get("/{id}/logs", paymentHandler.ListPaymentLogs)
				r.Get("/subscriptions", paymentHandler.ListSubscriptions)
				r.Put("/subscriptions/{id}/attachment", paymentHandler.UpdateSubscriptionAttachment)
				r.Post("/subscriptions", paymentHandler.CreateManualSubscription)
				r.Get("/reports", paymentHandler.FinancialReport)
				r.Route("/plans", func(r chi.Router) {
					r.Get("/", paymentHandler.ListPlans)
					r.Post("/", paymentHandler.CreatePlan)
					r.Route("/{id}", func(r chi.Router) {
						r.Get("/", paymentHandler.GetPlan)
						r.Put("/", paymentHandler.UpdatePlan)
					})
				})
				// Bank account management (admin)
				r.Route("/bank-accounts", func(r chi.Router) {
					r.Get("/", bankAccountHandler.List)
					r.Post("/", bankAccountHandler.Create)
					r.Route("/{id}", func(r chi.Router) {
						r.Get("/", bankAccountHandler.GetByID)
						r.Put("/", bankAccountHandler.Update)
						r.Delete("/", bankAccountHandler.Delete)
					})
				})
			})

			// ── Foods (Master Library → Nutrition → Foods) ──
			r.Route("/foods", func(r chi.Router) {
				r.Get("/", foodHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", foodHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", foodHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", foodHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", foodHandler.Delete)
				})
			})

			// ── Habits (Master Library → Habits) ────────────
			r.Route("/habits", func(r chi.Router) {
				r.Get("/", habitHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", habitHandler.Create)
				r.Post("/log", habitHandler.LogHabit)

				// Folders
				r.Get("/folders", habitHandler.ListFolders)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/folders", habitHandler.CreateFolder)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/folders/{id}", habitHandler.UpdateFolder)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/folders/{id}", habitHandler.DeleteFolder)

				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", habitHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", habitHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", habitHandler.Delete)
				})

				// User habit logs
				r.Route("/user/{id}", func(r chi.Router) {
					r.Use(middleware.RequireSelfOrRole(model.RoleAdmin, model.RoleTrainer))
					r.Get("/logs", habitHandler.GetUserLogs)
				})
			})

			// ── Forms (Master Library → Others → Forms) ─────
			r.Route("/forms", func(r chi.Router) {
				r.Get("/", formHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", formHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", formHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", formHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", formHandler.Delete)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/fields", formHandler.SaveFields)
					r.Post("/responses", formHandler.SubmitResponse)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Get("/responses", formHandler.ListResponses)
				})
			})

			// ── Scheduling (Calendar, Availability, Events) ─
			r.Route("/scheduling", func(r chi.Router) {
				// Event Types
				r.Route("/event-types", func(r chi.Router) {
					r.Get("/", schedulingHandler.ListEventTypes)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", schedulingHandler.CreateEventType)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/{id}", schedulingHandler.UpdateEventType)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/{id}", schedulingHandler.DeleteEventType)
				})

				// Calendar Events
				r.Route("/events", func(r chi.Router) {
					r.Get("/", schedulingHandler.ListEvents)
					r.Post("/", schedulingHandler.CreateEvent)
					r.Route("/{id}", func(r chi.Router) {
						r.Get("/", schedulingHandler.GetEvent)
						r.Put("/", schedulingHandler.UpdateEvent)
						r.Delete("/", schedulingHandler.DeleteEvent)
						r.Post("/participants", schedulingHandler.AddParticipant)
						r.Get("/participants", schedulingHandler.ListParticipants)
					})
				})

				// Availability
				r.Post("/availability", schedulingHandler.SetAvailability)
				r.Get("/availability/{trainerId}", schedulingHandler.ListAvailability)
				r.Delete("/availability/{id}", schedulingHandler.DeleteAvailability)
			})

			// ── Groups ──────────────────────────────────────
			r.Route("/groups", func(r chi.Router) {
				r.Get("/", groupHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", groupHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", groupHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", groupHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", groupHandler.Delete)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/members", groupHandler.AddMember)
					r.Get("/members", groupHandler.ListMembers)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/members/{userId}", groupHandler.RemoveMember)
				})
			})

			// ── Challenges ──────────────────────────────────
			r.Route("/challenges", func(r chi.Router) {
				r.Get("/", challengeHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", challengeHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", challengeHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", challengeHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", challengeHandler.Delete)
					r.Post("/join", challengeHandler.Join)
					r.Post("/leave", challengeHandler.Leave)
					r.Post("/progress", challengeHandler.UpdateProgress)
					r.Get("/participants", challengeHandler.ListParticipants)
				})
			})

			// ── Promotions ──────────────────────────────────
			r.Route("/promotions", func(r chi.Router) {
				r.Get("/active", promotionHandler.ListActive) // Client: active promos
				r.With(middleware.RequireRole(model.RoleAdmin)).Get("/", promotionHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin)).Post("/", promotionHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", promotionHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin)).Put("/", promotionHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin)).Delete("/", promotionHandler.Delete)
				})
			})

			// ── Health Content (Articles & Videos) ───────────
			r.Get("/health-news", healthContentHandler.ListArticlesPublic)
			r.Get("/doctor-videos", healthContentHandler.ListVideosPublic)

			r.Route("/cms/health-news", func(r chi.Router) {
				r.Use(middleware.RequireMinRole(model.RoleAdmin))
				r.Get("/", healthContentHandler.ListArticlesAdmin)
				r.Post("/", healthContentHandler.CreateArticle)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", healthContentHandler.GetArticle)
					r.Put("/", healthContentHandler.UpdateArticle)
					r.Delete("/", healthContentHandler.DeleteArticle)
				})
			})

			r.Route("/cms/doctor-videos", func(r chi.Router) {
				r.Use(middleware.RequireMinRole(model.RoleAdmin))
				r.Get("/", healthContentHandler.ListVideosAdmin)
				r.Post("/", healthContentHandler.CreateVideo)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", healthContentHandler.GetVideo)
					r.Put("/", healthContentHandler.UpdateVideo)
					r.Delete("/", healthContentHandler.DeleteVideo)
				})
			})

			// ── Announcements ───────────────────────────────
			r.Route("/announcements", func(r chi.Router) {
				r.Get("/feed", announcementHandler.Feed)
				r.Post("/{id}/read", announcementHandler.MarkAsRead)
				r.With(middleware.RequireRole(model.RoleAdmin)).Get("/", announcementHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin)).Post("/", announcementHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", announcementHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin)).Put("/", announcementHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin)).Delete("/", announcementHandler.Delete)
				})
			})

			// ── Uploads ─────────────────────────────────────
			r.Route("/uploads", func(r chi.Router) {
				r.Post("/", uploadHandler.Upload)
				r.Get("/my", uploadHandler.ListMy)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", uploadHandler.GetByID)
					r.Delete("/", uploadHandler.Delete)
				})
			})

			// ── Training Card Types (Master) ─────────────────
			r.Route("/training-card-types", func(r chi.Router) {
				r.Get("/", trainerCardHandler.ListTypes)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", trainerCardHandler.CreateType)
				r.Route("/{id}", func(r chi.Router) {
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", trainerCardHandler.UpdateType)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", trainerCardHandler.DeleteType)
				})
			})

			// ── Training Card Templates (Master) ─────────────
			r.Route("/training-card-templates", func(r chi.Router) {
				r.Get("/", trainerCardTemplateHandler.ListTemplates)
				r.Route("/{level}", func(r chi.Router) {
					r.Get("/", trainerCardTemplateHandler.GetTemplate)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", trainerCardTemplateHandler.UpsertTemplate)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", trainerCardTemplateHandler.DeleteTemplate)
				})
			})

			// ── Customer Setup ──────────────────────────────
			r.Route("/customers/{customerId}", func(r chi.Router) {
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant)).Get("/setup", customerSetupHandler.GetFullSetup)

				r.Route("/staff", func(r chi.Router) {
					r.Use(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant))
					r.Get("/", customerSetupHandler.GetStaff)
					r.Post("/", customerSetupHandler.AssignStaff)
				})

				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant)).Put("/priority", customerSetupHandler.UpdatePriority)

				r.Route("/hr-zone", func(r chi.Router) {
					r.Use(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant))
					r.Get("/", customerSetupHandler.GetHRZone)
					r.Put("/", customerSetupHandler.UpsertHRZone)
				})

				r.Route("/medicines", func(r chi.Router) {
					r.Use(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant))
					r.Get("/", customerSetupHandler.ListMedicines)
					r.Post("/", customerSetupHandler.AddMedicine)
					r.Delete("/{medicineId}", customerSetupHandler.RemoveMedicine)
				})

				r.Route("/programs", func(r chi.Router) {
					r.Use(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant))
					r.Get("/", customerSetupHandler.ListPrograms)
					r.Post("/", customerSetupHandler.UpsertProgram)
					r.Delete("/{programCategoryId}", customerSetupHandler.RemoveProgram)
				})

				r.Route("/journal", func(r chi.Router) {
					r.Use(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant))
					r.Get("/", dailyJournalHandler.ListByMonth)
					r.Get("/months", dailyJournalHandler.ListMonths)
					r.Post("/", dailyJournalHandler.UpsertSession)
					r.Delete("/{sessionId}", dailyJournalHandler.DeleteSession)
				})

				r.Route("/training-card", func(r chi.Router) {
					r.Use(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleConsultant))
					r.Get("/", trainerCardHandler.GetCard)
					r.Post("/", trainerCardHandler.UpsertCard)
					r.Post("/publish", trainerCardHandler.PublishCard)
					r.Delete("/", trainerCardHandler.DeleteCard)
				})
			})

			// ── Program Categories ─────────────────────────
			r.Route("/program-categories", func(r chi.Router) {
				r.Get("/", programCategoryHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", programCategoryHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", programCategoryHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", programCategoryHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", programCategoryHandler.Delete)
				})
			})

			// ── Medicines (Daftar Obat) ─────────────────────
			r.Route("/medicines", func(r chi.Router) {
				r.Get("/", medicineHandler.List)
				r.Get("/me", customerSetupHandler.GetMyMedicines) // Client's own medicines
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", medicineHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", medicineHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", medicineHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", medicineHandler.Delete)
				})
			})

			// ── Equipments (Master Data) ────────────────────
			r.Route("/equipments", func(r chi.Router) {
				r.Get("/", equipmentHandler.List)
				r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", equipmentHandler.Create)
				r.Route("/{id}", func(r chi.Router) {
					r.Get("/", equipmentHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", equipmentHandler.Update)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", equipmentHandler.Delete)
				})
			})

			// ── SF Master Data (Phase 1: Klasifikasi Kondisi & Kondisi Spesifik)
			r.Route("/master", func(r chi.Router) {
				// Klasifikasi Kondisi Fisik (5 kategori)
				r.Route("/condition-classifications", func(r chi.Router) {
					r.Get("/", conditionHandler.ListClassifications)
					r.With(middleware.RequireMinRole(model.RoleAdmin)).Post("/", conditionHandler.CreateClassification)
					r.Route("/{id}", func(r chi.Router) {
						r.Get("/", conditionHandler.GetClassification)
						r.With(middleware.RequireMinRole(model.RoleAdmin)).Put("/", conditionHandler.UpdateClassification)
						r.With(middleware.RequireMinRole(model.RoleAdmin)).Delete("/", conditionHandler.DeleteClassification)
					})
				})

				// Kondisi Spesifik per Klasifikasi
				r.Route("/specific-conditions", func(r chi.Router) {
					r.Get("/", conditionHandler.ListSpecificConditions)
					r.With(middleware.RequireMinRole(model.RoleAdmin)).Post("/", conditionHandler.CreateSpecific)
					r.Route("/{id}", func(r chi.Router) {
						r.Get("/", conditionHandler.GetSpecific)
						r.With(middleware.RequireMinRole(model.RoleAdmin)).Put("/", conditionHandler.UpdateSpecific)
						r.With(middleware.RequireMinRole(model.RoleAdmin)).Delete("/", conditionHandler.DeleteSpecific)
					})
				})

				// Physical Status Levels (read-only, output Phase A Q1)
				r.Get("/physical-status-levels", conditionHandler.ListPhysicalStatusLevels)
			})

			// ── SF Tier 4 Waitlist (Phase 6) ───────────────────────
			r.Route("/v2/tier4-waitlist", func(r chi.Router) {
				// Client / authenticated user → join waitlist
				r.Post("/", tier4WaitlistHandler.Join)
				// Admin → list + manage status
				r.With(middleware.RequireMinRole(model.RoleAdmin)).Get("/", tier4WaitlistHandler.List)
				r.With(middleware.RequireMinRole(model.RoleAdmin)).
					Patch("/{id}/status", tier4WaitlistHandler.UpdateStatus)
			})

			// ── SF Lab Consultation (Phase 6) ──────────────────────
			r.Route("/v2/lab-consultations", func(r chi.Router) {
				r.Post("/", labConsultationHandler.Book)
				r.Get("/", labConsultationHandler.List)
				r.Get("/{id}", labConsultationHandler.Get)
				r.With(middleware.RequireMinRole(model.RoleAdmin)).
					Patch("/{id}", labConsultationHandler.Update)
				// SF Phase 7b — dedicated assign-consultant endpoint (admin/owner only)
				r.With(middleware.RequireMinRole(model.RoleAdmin)).
					Patch("/{id}/assign", consultantHandler.AssignLab)
			})

			// ── SF Consultant Dashboard (Phase 7b) ─────────────────
			r.Route("/v2/consultant", func(r chi.Router) {
				// Antrian review v2 assessments — consultant + admin/owner
				r.With(middleware.RequireRole(model.RoleConsultant, model.RoleAdmin)).
					Get("/queue", consultantHandler.Queue)
				// "Klien Saya" — consultant only (own clients)
				r.With(middleware.RequireRole(model.RoleConsultant)).
					Get("/clients", consultantHandler.Clients)
			})

			// ── SF Clinical Notes (Phase 7b) ───────────────────────
			r.Route("/v2/clinical-notes", func(r chi.Router) {
				// Author = consultant only. Update/Delete enforced inside service.
				r.With(middleware.RequireRole(model.RoleConsultant)).
					Post("/", consultantHandler.CreateNote)

				// List & filter — consultant + admin/owner.
				r.With(middleware.RequireRole(model.RoleConsultant, model.RoleAdmin)).
					Get("/", consultantHandler.ListNotes)

				// GetByID — any authenticated role; ACL via service.CanRead
				// (client only sees published notes that target them).
				r.Get("/{id}", consultantHandler.GetNote)

				// Update / Delete — author or admin (enforced di service).
				r.With(middleware.RequireRole(model.RoleConsultant, model.RoleAdmin)).
					Patch("/{id}", consultantHandler.UpdateNote)
				r.With(middleware.RequireRole(model.RoleConsultant, model.RoleAdmin)).
					Delete("/{id}", consultantHandler.DeleteNote)
			})

			// ── SF Assessment v2 (Phase 2: Phase A/B/C, Chronobiology, System Score 35/35/30)
			r.Route("/v2/assessments", func(r chi.Router) {
				r.Post("/", assessmentV2Handler.Submit)
				r.Get("/latest", assessmentV2Handler.Latest)
				r.Get("/training-card", assessmentV2Handler.GetTrainingCard)

				// Score weights: read for any role, edit owner-only.
				r.Get("/score-weights", assessmentV2Handler.GetWeights)
				r.With(middleware.RequireRole(model.RoleOwner)).Patch("/score-weights", assessmentV2Handler.UpdateWeights)

				// Admin/Owner/Trainer: read another user's latest v2 assessment (Phase 3 web viewer).
				r.With(middleware.RequireMinRole(model.RoleTrainer)).
					Get("/user/{userId}/latest", assessmentV2Handler.LatestForUser)

				r.With(middleware.RequireMinRole(model.RoleTrainer)).
					Post("/user/{userId}", assessmentV2Handler.SubmitForUser)

				r.With(middleware.RequireMinRole(model.RoleTrainer)).
					Get("/user/{userId}/training-card", assessmentV2Handler.GetTrainingCardForUser)

				r.Get("/{id}", assessmentV2Handler.Get)
			})

			// 🎯 Quarterly Assessments (Systemic Assessment)
			r.Route("/v2/quarterly-assessments", func(r chi.Router) {
				r.With(middleware.RequireMinRole(model.RoleTrainer)).Post("/", quarterlyAssessmentHandler.Create)
				r.With(middleware.RequireMinRole(model.RoleTrainer)).Get("/client/{id}", quarterlyAssessmentHandler.ListByClient)
			})

			// 🎯 Workout Sessions & Reminders (Level 5/6 client) 🎯🎯🎯─────
			// Self-scoped to the authenticated client via GetUserID.
			r.Route("/v2/workout-sessions", func(r chi.Router) {
				r.Post("/", workoutSessionHandler.Log)
				r.Get("/", workoutSessionHandler.ListMine)
				r.Get("/stats", workoutSessionHandler.Stats)
			})
			r.Route("/v2/workout-reminders", func(r chi.Router) {
				r.Get("/me", workoutReminderHandler.GetMine)
				r.Put("/me", workoutReminderHandler.SetMine)
			})

			// ── Menus & Privileges ─────────────────────────
			r.Route("/menus", func(r chi.Router) {
				r.Get("/my", menuHandler.MyMenus)

				// Owner-only management
				r.With(middleware.RequireRole(model.RoleOwner)).Get("/", menuHandler.List)
				r.With(middleware.RequireRole(model.RoleOwner)).Get("/tree", menuHandler.Tree)
				r.With(middleware.RequireRole(model.RoleOwner)).Post("/", menuHandler.Create)
				r.With(middleware.RequireRole(model.RoleOwner)).Post("/reorder", menuHandler.Reorder)
				r.With(middleware.RequireRole(model.RoleOwner)).Get("/privileges", menuHandler.ListPrivileges)
				r.With(middleware.RequireRole(model.RoleOwner)).Put("/privileges/bulk", menuHandler.BulkUpsertPrivileges)

				r.Route("/{id}", func(r chi.Router) {
					r.With(middleware.RequireRole(model.RoleOwner)).Get("/", menuHandler.GetByID)
					r.With(middleware.RequireRole(model.RoleOwner)).Put("/", menuHandler.Update)
					r.With(middleware.RequireRole(model.RoleOwner)).Delete("/", menuHandler.Delete)
					r.With(middleware.RequireRole(model.RoleOwner)).Get("/privileges", menuHandler.GetPrivileges)
					r.With(middleware.RequireRole(model.RoleOwner)).Put("/privileges", menuHandler.UpsertPrivileges)
				})
			})

			// ── Training Schedules (owner only) ────────────
			r.Route("/training-schedules", func(r chi.Router) {
				// Read: trainer+ (trainers see their own; admin/owner see all).
				// Server-side auto-scopes trainer_id when caller is a trainer.
				r.Group(func(r chi.Router) {
					r.Use(middleware.RequireMinRole(model.RoleTrainer))

					// Recurring schedules
					r.Get("/", trainingScheduleHandler.ListSchedules)
					r.Get("/{id}", trainingScheduleHandler.GetSchedule)

					// Individual sessions
					r.Get("/sessions", trainingScheduleHandler.ListSessions)
					r.Get("/sessions/{id}", trainingScheduleHandler.GetSession)
				})

				// Write: admin/owner only. Trainers cannot self-create or
				// self-substitute — assignment flows go through konsultan.
				r.Group(func(r chi.Router) {
					r.Use(middleware.RequireRole(model.RoleAdmin))

					// Recurring schedules
					r.Post("/", trainingScheduleHandler.CreateSchedule)
					r.Put("/{id}", trainingScheduleHandler.UpdateSchedule)
					r.Delete("/{id}", trainingScheduleHandler.DeleteSchedule)

					// Individual sessions
					r.Post("/sessions", trainingScheduleHandler.CreateSession)
					r.Put("/sessions/{id}", trainingScheduleHandler.UpdateSession)
					r.Delete("/sessions/{id}", trainingScheduleHandler.DeleteSession)
					r.Post("/sessions/{id}/substitute", trainingScheduleHandler.SubstituteTrainer)
					r.Post("/sessions/bulk-substitute", trainingScheduleHandler.BulkSubstitute)
				})
			})

			// ── Digital Library ─────────────────────────────
			r.Route("/digital-library", func(r chi.Router) {
				r.Get("/categories", dlHandler.ListCategories)
				r.Get("/levels", dlHandler.ListLevels)

				r.Route("/movements", func(r chi.Router) {
					r.Get("/", dlHandler.ListMovements)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/", dlHandler.CreateMovement)
					r.Route("/{id}", func(r chi.Router) {
						r.Get("/", dlHandler.GetMovement)
						r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Put("/", dlHandler.UpdateMovement)
						r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Delete("/", dlHandler.DeleteMovement)
						r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer)).Post("/upload-image", dlHandler.UploadMovementImage)
					})
				})

				r.Route("/categories/{code}", func(r chi.Router) {
					r.Get("/menu", dlHandler.ListMenuItems)
					r.Get("/isolate", dlHandler.ListIsolateItems)
					r.Get("/dynamic", dlHandler.ListDynamicItems)
					r.Get("/program", dlHandler.GetProgramOverview)
				})

				r.Route("/modul-cards", func(r chi.Router) {
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleOwner)).Post("/", dlHandler.AddModulCardItem)
					r.With(middleware.RequireRole(model.RoleAdmin, model.RoleTrainer, model.RoleOwner)).Delete("/{levelID}/{movementID}", dlHandler.DeleteModulCardItem)
				})
			})

			// ── Assessments (v1 — DEPRECATED) ───────────────
			// SF Phase 8e — endpoint v1 ditandai deprecated; client harus
			// migrate ke /api/v2/assessments (Phase 2 engine).
			// Sunset planned: 2026-10-27 (~6 bulan setelah Phase 7 GA).
			// Removal akan dilakukan di Phase 9 setelah telemetri menunjukkan
			// tidak ada traffic lagi dari mobile/web client di production.
			//
			// Owners + admins manage reviews. Trainers may VIEW the queue
			// and detail pages (read-only) but cannot submit a review.
			r.Route("/assessments", func(r chi.Router) {
				r.Use(middleware.Deprecated(
					"/api/v2/assessments",
					time.Date(2026, 10, 27, 0, 0, 0, 0, time.UTC),
				))
				r.Get("/schema", assessmentHandler.GetSchema)
				r.Get("/latest", assessmentHandler.GetLatest)
				r.Post("/free", assessmentHandler.SubmitFree)
				r.Post("/paid", assessmentHandler.SubmitPaid)
				r.Get("/", assessmentHandler.ListMine)
				r.With(middleware.RequireMinRole(model.RoleTrainer)).Get("/pending-review", assessmentHandler.ListPendingReview)
				// Admin/owner-only "all assessments" listing (filterable by tier/status).
				r.With(middleware.RequireRole(model.RoleAdmin)).Get("/all", assessmentHandler.ListAll)
				r.Get("/{id}", assessmentHandler.GetByID)
				r.Get("/{id}/previous", assessmentHandler.GetPrevious)
				// WRITE — admin/owner only (RequireRole(admin) lets owner pass too).
				r.With(middleware.RequireRole(model.RoleAdmin)).Patch("/{id}/review", assessmentHandler.Review)
			})
		})
	})

	// ── Static file serving for uploads ────────────────────────
	fileServer := http.FileServer(http.Dir(cfg.UploadDir))
	r.Handle("/uploads/*", http.StripPrefix("/uploads/", fileServer))

	// ── WebSocket ───────────────────────────────────────────────
	r.Route("/ws", func(r chi.Router) {
		r.Get("/messages", func(w http.ResponseWriter, req *http.Request) {
			token := req.URL.Query().Get("token")
			if token == "" {
				http.Error(w, "Missing token", http.StatusUnauthorized)
				return
			}
			claims, err := jwtManager.ValidateToken(token)
			if err != nil {
				http.Error(w, "Invalid token", http.StatusUnauthorized)
				return
			}

			// On connect: send unread count to the client
			onConnect := func(client *ws.Client) {
				count, err := messageService.GetUnreadCount(context.Background(), client.UserID)
				if err != nil {
					return
				}
				data, _ := json.Marshal(map[string]int{"unread_count": count})
				client.Send(data)
			}

			wsHub.HandleWebSocket(claims.UserID, string(claims.Role), onConnect)(w, req)
		})
	})

	// ─── Server ─────────────────────────────────────────────────
	addr := fmt.Sprintf(":%s", cfg.Port)
	srv := &http.Server{
		Addr:         addr,
		Handler:      r,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		logger.Info("server starting", "addr", addr, "env", cfg.Env)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Error("server error", "error", err)
			os.Exit(1)
		}
	}()

	<-done
	logger.Info("shutting down...")

	sched.Stop()

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(shutdownCtx); err != nil {
		logger.Error("forced shutdown", "error", err)
		os.Exit(1)
	}

	logger.Info("server stopped gracefully")
}

