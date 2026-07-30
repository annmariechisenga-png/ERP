/**
 * dashboard-i18n.js
 *
 * Internationalization module extracted from erp-dashboard.js.
 * Provides locale/language switching, translation lookup, holiday calendar rendering,
 * and utility formatting for the ERP dashboard.
 *
 * Exposes a global `DashboardI18n` object so it can be used by any HTML page.
 */
const DashboardI18n = (function () {
    "use strict";

    const STORAGE_KEYS = {
        language: "erp.language",
        locale: "erp.locale",
        currency: "erp.currency",
        direction: "erp.direction",
        holidayRegion: "erp.holidayRegion"
    };

    const state = {
        language: localStorage.getItem(STORAGE_KEYS.language) || "en",
        locale: localStorage.getItem(STORAGE_KEYS.locale) || "en-ZM",
        currency: localStorage.getItem(STORAGE_KEYS.currency) || "ZMW",
        direction: localStorage.getItem(STORAGE_KEYS.direction) || "ltr",
        holidayRegion: localStorage.getItem(STORAGE_KEYS.holidayRegion) || "zambia"
    };

    const LANGUAGE_CONFIG = {
        en: { label: "English", locale: "en-ZM", currency: "ZMW", dir: "ltr" },
        fr: { label: "Français", locale: "fr", currency: "ZMW", dir: "ltr" },
        ar: { label: "العربية", locale: "ar", currency: "ZMW", dir: "rtl" },
        he: { label: "עברית", locale: "he", currency: "ZMW", dir: "rtl" }
    };

    const HOLIDAY_CALENDARS = {
        zambia: {
            label: {
                en: "Zambia national",
                fr: "Zambie nationale",
                ar: "العطل الوطنية في زامبيا",
                he: "חגים לאומיים בזמביה"
            },
            holidays: [
                { date: "2026-01-01", name: "New Year's Day" },
                { date: "2026-03-09", name: "International Women's Day (observed)" },
                { date: "2026-03-12", name: "Youth Day" },
                { date: "2026-04-03", name: "Good Friday" },
                { date: "2026-04-04", name: "Holy Saturday" },
                { date: "2026-04-05", name: "Easter Sunday" },
                { date: "2026-04-06", name: "Easter Monday" },
                { date: "2026-04-28", name: "Kenneth Kaunda Day" },
                { date: "2026-05-01", name: "Labour Day" },
                { date: "2026-05-25", name: "Africa Freedom Day" },
                { date: "2026-07-06", name: "Heroes' Day" },
                { date: "2026-07-07", name: "Unity Day" },
                { date: "2026-08-03", name: "Farmers' Day" },
                { date: "2026-08-13", name: "Election Day" },
                { date: "2026-10-19", name: "National Day of Prayer (observed)" },
                { date: "2026-10-24", name: "Independence Day" },
                { date: "2026-12-25", name: "Christmas Day" },
                { date: "2026-12-29", name: "Christian Nation Declaration Day" }
            ]
        }
    };

    const I18N = {
        en: {
            workspaceIntro: "Use this workspace to move between leave, overtime, performance, salary advance, payslip, and policy modules with a consistent layout and clear instructions.",
            displayLanguage: "Display language",
            holidayRegion: "Holiday calendar region",
            localeStatus: "Language, locale formats, Unicode text, and regional holidays update instantly.",
            navLeave: "Leave Request Types",
            navHolidays: "Holiday Calendar",
            navOvertime: "Overtime Requests",
            navPerformance: "Performance Management",
            navSalaryAdvance: "Salary Advance",
            navPayslips: "Payslips",
            navDocuments: "Employee Documents",
            leaveHolidayHeading: "Regional Holiday Calendar",
            leaveHolidayHint: "Review public holidays and weekends that apply to the selected region.",
            weekend: "Weekend",
            leaveOptionsLabel: "Leave Options",
            pendingRequestsLabel: "Pending Requests",
            submitLeaveTitle: "Submit Leave Request",
            leaveFormHint: "Choose the leave type, dates, and reason. The birth record field only appears for maternity and paternity leave.",
            overtimeHint: "Provide the employee ID and clock-out time to assess overtime eligibility and create a request when applicable.",
            salaryHint: "Enter the authority reference, amount, repayment installments, and reason so the request can move through head and finance review.",
            authRequired: "Username and password are required.",
            authLoading: "Authenticating session...",
            authFailed: "Authentication failed.",
            authPublic: "Public policy data is available immediately. Protected request tables require login.",
            mfaLabel: "Authenticator code",
            mfaPlaceholder: "Enter MFA code if enabled",
            leaveReady: "Ready to submit {leaveType} for {name}.",
            leaveBirthProof: "Upload the birth record/certificate before submitting {leaveType}.",
            leaveSignIn: "Synced {count} leave type{plural} from {source}. Sign in to submit a leave request.",
            holidayUpdated: "Holiday calendar updated for {region}.",
            holidayEmpty: "No holiday entries are configured for this region yet.",
            signOut: "Sign Out",
            home: "Home",
            selfService: "Self Service",
            management: "Management",
            financialControl: "Financial Control",
            dashboard: "Dashboard",
            myJobDescription: "My Job Description",
            myPayslips: "My Payslips",
            policyDocuments: "Policy Documents",
            requestLeave: "Request Leave",
            requestOvertime: "Request Overtime",
            myDepartment: "My Department",
            pendingApprovals: "Pending Approvals",
            budgetAndBank: "Budget & Bank",
            detailedLedger: "Detailed Ledger",
            leaveBalance: "Leave Balance",
            projectedOvertime: "Projected Overtime",
            nextScheduledPay: "Next Scheduled Pay",
            newRequest: "New Request",
            logHours: "Log Hours",
            statusActive: "Status: Active",
            accruingDays: "Accruing 3.0 days/month",
            hoursLogged: "0.0 hours logged",
            officialJobDescription: "Official Job Description",
            downloadJDDocument: "Download JD Document",
            statutoryPolicyDocuments: "Statutory Policy Documents",
            period: "Period",
            gross: "Gross (ZMW)",
            deductions: "Deductions",
            netPay: "Net Pay",
            status: "Status",
            totalRevenueYTD: "Total Revenue YTD",
            totalExpenditureYTD: "Total Expenditure YTD",
            bankBalances: "Bank Balances",
            generalLedger: "General Ledger",
            date: "Date",
            ref: "Ref",
            description: "Description",
            category: "Category",
            amount: "Amount",
            leaveType: "Leave Type",
            compassionateRelation: "Compassionate Relation",
            startDate: "Start Date",
            endDate: "End Date",
            reason: "Reason",
            submitForApproval: "Submit for Approval",
            requestOvertimeTitle: "Request Overtime",
            otDate: "Date",
            otStartTime: "Start Time",
            otEndTime: "End Time",
            overtimeType: "Overtime Type",
            submitOvertimeRequest: "Submit Overtime Request",
            systemView: "System View:",
            employee: "Employee (PRO)",
            headOfDepartment: "Head of Department",
            directorFinance: "Director – Finance"
        },
        fr: {
            workspaceIntro: "Utilisez cet espace pour naviguer entre les congés, les heures supplémentaires, la performance, les avances salariales, les fiches de paie et les politiques avec une mise en page cohérente.",
            displayLanguage: "Langue d'affichage",
            holidayRegion: "Région du calendrier des jours fériés",
            localeStatus: "La langue, les formats locaux, le texte Unicode et les jours fériés régionaux se mettent à jour instantanément.",
            navLeave: "Types de congé",
            navHolidays: "Calendrier des jours fériés",
            navOvertime: "Heures supplémentaires",
            navPerformance: "Gestion de la performance",
            navSalaryAdvance: "Avance sur salaire",
            navPayslips: "Fiches de paie",
            navDocuments: "Documents des employés",
            leaveHolidayHeading: "Calendrier régional des jours fériés",
            leaveHolidayHint: "Consultez les jours fériés et week-ends applicables à la région sélectionnée.",
            weekend: "Week-end",
            authRequired: "Le nom d'utilisateur et le mot de passe sont obligatoires.",
            authLoading: "Authentification en cours...",
            authFailed: "Échec de l'authentification.",
            authPublic: "Les politiques publiques sont disponibles immédiatement. Les tableaux protégés nécessitent une connexion.",
            mfaLabel: "Code d'authentification",
            mfaPlaceholder: "Entrez le code MFA s'il est activé",
            signOut: "Se déconnecter",
            home: "Accueil",
            selfService: "Self-Service",
            management: "Gestion",
            financialControl: "Contrôle financier",
            dashboard: "Tableau de bord",
            myJobDescription: "Ma description de poste",
            myPayslips: "Mes fiches de paie",
            policyDocuments: "Documents de politique",
            requestLeave: "Demander un congé",
            requestOvertime: "Demander des heures supp.",
            myDepartment: "Mon département",
            pendingApprovals: "Approbations en attente",
            budgetAndBank: "Budget & Banque",
            detailedLedger: "Grand livre détaillé",
            leaveBalance: "Solde de congés",
            projectedOvertime: "Heures supp. prévues",
            nextScheduledPay: "Prochaine paie",
            newRequest: "Nouvelle demande",
            logHours: "Saisir les heures",
            statusActive: "Statut : Actif",
            accruingDays: "Acquisition 3,0 jours/mois",
            hoursLogged: "0,0 heure enregistrée",
            officialJobDescription: "Description de poste officielle",
            downloadJDDocument: "Télécharger la description",
            statutoryPolicyDocuments: "Documents de politique légale",
            period: "Période",
            gross: "Brut (ZMW)",
            deductions: "Déductions",
            netPay: "Net à payer",
            status: "Statut",
            totalRevenueYTD: "Revenus totaux YTD",
            totalExpenditureYTD: "Dépenses totales YTD",
            bankBalances: "Soldes bancaires",
            generalLedger: "Grand livre général",
            date: "Date",
            ref: "Réf.",
            description: "Description",
            category: "Catégorie",
            amount: "Montant",
            leaveType: "Type de congé",
            compassionateRelation: "Lien de parenté",
            startDate: "Date de début",
            endDate: "Date de fin",
            reason: "Motif",
            submitForApproval: "Soumettre pour approbation",
            requestOvertimeTitle: "Demander des heures supp.",
            otDate: "Date",
            otStartTime: "Heure de début",
            otEndTime: "Heure de fin",
            overtimeType: "Type d'heures supp.",
            submitOvertimeRequest: "Soumettre la demande",
            systemView: "Vue système :",
            employee: "Employé (PRO)",
            headOfDepartment: "Chef de département",
            directorFinance: "Directeur – Finances"
        },
        ar: {
            workspaceIntro: "استخدم مساحة العمل هذه للتنقل بين الإجازات والعمل الإضافي والأداء والسلف والرواتب والسياسات بتخطيط متسق وتعليمات واضحة.",
            displayLanguage: "لغة العرض",
            holidayRegion: "منطقة تقويم العطل",
            localeStatus: "يتم تحديث اللغة والتنسيقات المحلية ونصوص يونيكود والعطل الإقليمية فورًا.",
            navLeave: "أنواع الإجازات",
            navHolidays: "تقويم العطل",
            navOvertime: "طلبات العمل الإضافي",
            navPerformance: "إدارة الأداء",
            navSalaryAdvance: "السلفة المالية",
            navPayslips: "قسائم الرواتب",
            navDocuments: "وثائق الموظفين",
            leaveHolidayHeading: "تقويم العطل الإقليمي",
            leaveHolidayHint: "راجع العطل الرسمية وعطلة نهاية الأسبوع للمنطقة المحددة.",
            weekend: "عطلة نهاية الأسبوع",
            authRequired: "اسم المستخدم وكلمة المرور مطلوبان.",
            authLoading: "جارٍ التحقق من الجلسة...",
            authFailed: "فشل تسجيل الدخول.",
            authPublic: "بيانات السياسات العامة متاحة فورًا. الجداول المحمية تتطلب تسجيل الدخول.",
            mfaLabel: "رمز المصادقة",
            mfaPlaceholder: "أدخل رمز التحقق إذا كان مفعلاً",
            signOut: "تسجيل الخروج",
            home: "الرئيسية",
            selfService: "الخدمة الذاتية",
            management: "الإدارة",
            financialControl: "الرقابة المالية",
            dashboard: "لوحة المعلومات",
            myJobDescription: "الوصف الوظيفي",
            myPayslips: "قسائم الراتب",
            policyDocuments: "وثائق السياسة",
            requestLeave: "طلب إجازة",
            requestOvertime: "طلب عمل إضافي",
            myDepartment: "قسمي",
            pendingApprovals: "الموافقات المعلقة",
            budgetAndBank: "الميزانية والبنك",
            detailedLedger: "دفتر الأستاذ التفصيلي",
            leaveBalance: "رصيد الإجازة",
            projectedOvertime: "العمل الإضافي المتوقع",
            nextScheduledPay: "الراتب التالي",
            newRequest: "طلب جديد",
            logHours: "تسجيل الساعات",
            statusActive: "الحالة: نشط",
            accruingDays: "تراكم 3.0 يوم/شهر",
            hoursLogged: "0.0 ساعة مسجلة",
            officialJobDescription: "الوصف الوظيفي الرسمي",
            downloadJDDocument: "تحميل الوصف الوظيفي",
            statutoryPolicyDocuments: "وثائق السياسة القانونية",
            period: "الفترة",
            gross: "إجمالي (ZMW)",
            deductions: "الاستقطاعات",
            netPay: "الصافي",
            status: "الحالة",
            totalRevenueYTD: "إجمالي الإيرادات YTD",
            totalExpenditureYTD: "إجمالي المصروفات YTD",
            bankBalances: "أرصدة البنوك",
            generalLedger: "الدفتر العام",
            date: "التاريخ",
            ref: "المرجع",
            description: "الوصف",
            category: "الفئة",
            amount: "المبلغ",
            leaveType: "نوع الإجازة",
            compassionateRelation: "صلة القرابة",
            startDate: "تاريخ البدء",
            endDate: "تاريخ الانتهاء",
            reason: "السبب",
            submitForApproval: "إرسال للموافقة",
            requestOvertimeTitle: "طلب عمل إضافي",
            otDate: "التاريخ",
            otStartTime: "وقت البدء",
            otEndTime: "وقت الانتهاء",
            overtimeType: "نوع العمل الإضافي",
            submitOvertimeRequest: "إرسال طلب العمل الإضافي",
            systemView: "عرض النظام:",
            employee: "موظف (PRO)",
            headOfDepartment: "رئيس القسم",
            directorFinance: "المدير المالي"
        },
        he: {
            workspaceIntro: "השתמשו בסביבת העבודה הזו כדי לעבור בין חופשות, שעות נוספות, ביצועים, מקדמות שכר, תלושים ומדיניות בפריסה עקבית.",
            displayLanguage: "שפת תצוגה",
            holidayRegion: "אזור לוח חגים",
            localeStatus: "השפה, הפורמטים המקומיים, טקסט Unicode והחגים האזוריים מתעדכנים מיד.",
            navLeave: "סוגי חופשה",
            navHolidays: "לוח חגים",
            navOvertime: "בקשות שעות נוספות",
            navPerformance: "ניהול ביצועים",
            navSalaryAdvance: "מקדמת שכר",
            navPayslips: "תלושי שכר",
            navDocuments: "מסמכי עובדים",
            leaveHolidayHeading: "לוח חגים אזורי",
            leaveHolidayHint: "בדקו את ימי החג וסופי השבוע החלים על האזור הנבחר.",
            weekend: "סוף שבוע",
            authRequired: "יש להזין שם משתמש וסיסמה.",
            authLoading: "מתבצע אימות...",
            authFailed: "ההתחברות נכשלה.",
            authPublic: "נתוני מדיניות ציבוריים זמינים מיד. טבלאות מוגנות דורשות כניסה.",
            mfaLabel: "קוד מאמת",
            mfaPlaceholder: "הזן קוד MFA אם הוא מופעל",
            signOut: "התנתקות",
            home: "בית",
            selfService: "שירות עצמי",
            management: "ניהול",
            financialControl: "בקרה פיננסית",
            dashboard: "לוח בקרה",
            myJobDescription: "תיאור התפקיד שלי",
            myPayslips: "תלושי השכר שלי",
            policyDocuments: "מסמכי מדיניות",
            requestLeave: "בקשת חופשה",
            requestOvertime: "בקשת שעות נוספות",
            myDepartment: "המחלקה שלי",
            pendingApprovals: "אישורים ממתינים",
            budgetAndBank: "תקציב ובנק",
            detailedLedger: "ספר חשבונות מפורט",
            leaveBalance: "יתרת חופשה",
            projectedOvertime: "שעות נוספות צפויות",
            nextScheduledPay: "תשלום מתוכנן הבא",
            newRequest: "בקשה חדשה",
            logHours: "רישום שעות",
            statusActive: "סטטוס: פעיל",
            accruingDays: "צובר 3.0 ימים/חודש",
            hoursLogged: "0.0 שעות רשומות",
            officialJobDescription: "תיאור תפקיד רשמי",
            downloadJDDocument: "הורדת תיאור תפקיד",
            statutoryPolicyDocuments: "מסמכי מדיניות חוקתיים",
            period: "תקופה",
            gross: "ברוטו (ZMW)",
            deductions: "ניכויים",
            netPay: "נטו לתשלום",
            status: "סטטוס",
            totalRevenueYTD: "הכנסות כוללות YTD",
            totalExpenditureYTD: "הוצאות כוללות YTD",
            bankBalances: "יתרות בנק",
            generalLedger: "ספר חשבונות כללי",
            date: "תאריך",
            ref: "מספר",
            description: "תיאור",
            category: "קטגוריה",
            amount: "סכום",
            leaveType: "סוג חופשה",
            compassionateRelation: "קשר משפחתי",
            startDate: "תאריך התחלה",
            endDate: "תאריך סיום",
            reason: "סיבה",
            submitForApproval: "שלח לאישור",
            requestOvertimeTitle: "בקשת שעות נוספות",
            otDate: "תאריך",
            otStartTime: "שעת התחלה",
            otEndTime: "שעת סיום",
            overtimeType: "סוג שעות נוספות",
            submitOvertimeRequest: "שלח בקשת שעות נוספות",
            systemView: "תצוגת מערכת:",
            employee: "עובד (PRO)",
            headOfDepartment: "ראש מחלקה",
            directorFinance: "מנהל כספים"
        }
    };

    function getLocaleConfig() {
        return LANGUAGE_CONFIG[state.language] || LANGUAGE_CONFIG.en;
    }

    function t(key, replacements = {}) {
        const languagePack = I18N[state.language] || I18N.en;
        const template = languagePack[key] ?? I18N.en[key] ?? key;
        return Object.entries(replacements).reduce(
            (text, [token, value]) => text.replaceAll(`{${token}}`, String(value ?? "")),
            template
        );
    }

    function getLocalizedValue(value) {
        if (value && typeof value === "object" && !Array.isArray(value)) {
            return value[state.language] || value.en || Object.values(value)[0] || "";
        }
        return String(value ?? "");
    }

    function normalizeUnicodeText(value) {
        return String(value ?? "").normalize("NFC").trim();
    }

    function getCurrencyFormatter() {
        try {
            return new Intl.NumberFormat(state.locale, {
                style: "currency",
                currency: state.currency,
                minimumFractionDigits: 2
            });
        } catch (error) {
            return new Intl.NumberFormat("en-ZM", {
                style: "currency",
                currency: "ZMW",
                minimumFractionDigits: 2
            });
        }
    }

    function formatDate(value) {
        if (!value) return "";
        const date = value instanceof Date ? value : new Date(value);
        if (Number.isNaN(date.getTime())) return String(value);
        return new Intl.DateTimeFormat(state.locale, { year: "numeric", month: "short", day: "numeric" }).format(date);
    }

    function formatDateTime(value) {
        if (!value) return "";
        const date = value instanceof Date ? value : new Date(value);
        if (Number.isNaN(date.getTime())) return String(value);
        return new Intl.DateTimeFormat(state.locale, {
            year: "numeric", month: "short", day: "numeric", hour: "2-digit", minute: "2-digit"
        }).format(date);
    }

    function formatWeekday(index) {
        const date = new Date(Date.UTC(2026, 0, 4 + index));
        return new Intl.DateTimeFormat(state.locale, { weekday: "long" }).format(date);
    }

    function getHolidayCalendarConfig(liveCalendar) {
        const fallback = HOLIDAY_CALENDARS[state.holidayRegion] || HOLIDAY_CALENDARS.zambia;
        const liveHolidays = Array.isArray(liveCalendar?.holidays)
            ? liveCalendar.holidays
                .map((holiday) => ({
                    date: holiday.date || holiday.holidayDate || holiday.holiday_date,
                    name: holiday.name || holiday.description || holiday.holiday_name || "Public Holiday"
                }))
                .filter((holiday) => holiday.date)
            : [];

        if (!liveHolidays.length) {
            return fallback;
        }

        return {
            label: liveCalendar?.label || fallback.label,
            holidays: liveHolidays
        };
    }

    function renderHolidayCalendar(rootSelector, liveCalendar, sourceLabel) {
        const root = document.querySelector(rootSelector);
        if (!root) return;

        const calendar = getHolidayCalendarConfig(liveCalendar);
        const holidays = [...(calendar?.holidays || [])].sort((left, right) => String(left.date).localeCompare(String(right.date)));
        const weekendDays = [0, 6].map((day) => formatWeekday(day)).join(" / ");
        const activeLabel = sourceLabel || getLocalizedValue({
            en: "Configured 2026 Zambia holiday data",
            fr: "Jours fériés zambiens 2026 configurés",
            ar: "بيانات عطلات زامبيا 2026 المهيأة",
            he: "נתוני חגי זמביה 2026 שהוגדרו"
        });

        if (!holidays.length) {
            root.innerHTML = `<div class="notice"><strong>${escapeHtml(t("leaveHolidayHeading"))}</strong><span>${escapeHtml(t("holidayEmpty"))}</span></div>`;
            return;
        }

        const cards = [
            `<article class="list-card detail-card"><strong>${escapeHtml(getLocalizedValue(calendar.label))}</strong><p>${escapeHtml(t("weekend"))}: ${escapeHtml(weekendDays)}</p></article>`,
            ...holidays.map((holiday) => `
                <article class="list-card detail-card">
                    <strong>${escapeHtml(getLocalizedValue(holiday.name))}</strong>
                    <p>${escapeHtml(formatDate(holiday.date))}</p>
                </article>
            `)
        ];

        root.innerHTML = cards.join("");
    }

    function setText(selector, value) {
        const node = document.querySelector(selector);
        if (node) node.textContent = value;
    }

    function setInputLabelText(inputId, value) {
        const input = document.getElementById(inputId);
        const label = input?.closest("label");
        const span = label?.querySelector("span");
        if (span) span.textContent = value;
    }

    function escapeHtml(value) {
        const text = String(value ?? "");
        const div = document.createElement("div");
        div.textContent = text;
        return div.innerHTML;
    }

    function setLanguage(language) {
        state.language = LANGUAGE_CONFIG[language] ? language : "en";
        applyLanguageSettings();
    }

    function getLanguage() {
        return state.language;
    }

    function setHolidayRegion(region) {
        state.holidayRegion = HOLIDAY_CALENDARS[region] ? region : "zambia";
        localStorage.setItem(STORAGE_KEYS.holidayRegion, state.holidayRegion);
    }

    function applyLanguageSettings() {
        const config = getLocaleConfig();
        state.locale = config.locale;
        state.currency = config.currency;
        state.direction = config.dir;

        localStorage.setItem(STORAGE_KEYS.language, state.language);
        localStorage.setItem(STORAGE_KEYS.locale, state.locale);
        localStorage.setItem(STORAGE_KEYS.currency, state.currency);
        localStorage.setItem(STORAGE_KEYS.direction, state.direction);

        document.documentElement.lang = state.language;
        document.documentElement.dir = state.direction;
        document.body?.setAttribute("dir", state.direction);
    }

    function applyLocalization(mappings = {}, options = {}) {
        applyLanguageSettings();

        if (options.titleKey) {
            const title = t(options.titleKey);
            if (title && title !== options.titleKey) {
                document.title = title;
            }
        }

        Object.entries(mappings).forEach(([selector, key]) => {
            if (typeof key === "string") {
                setText(selector, t(key));
            } else if (key && typeof key === "object") {
                const value = key.key ? t(key.key, key.replacements || {}) : getLocalizedValue(key);
                setText(selector, value);
            }
        });

        if (typeof options.onApplied === "function") {
            options.onApplied(state);
        }
    }

    function bindLocaleControls(options = {}) {
        const languageSelect = typeof options.languageSelect === "string"
            ? document.querySelector(options.languageSelect)
            : options.languageSelect;
        const regionSelect = typeof options.regionSelect === "string"
            ? document.querySelector(options.regionSelect)
            : options.regionSelect;

        if (languageSelect) {
            languageSelect.innerHTML = Object.entries(LANGUAGE_CONFIG).map(([key, config]) => `
                <option value="${escapeHtml(key)}">${escapeHtml(config.label)}</option>
            `).join("");
            languageSelect.value = state.language;

            if (languageSelect.dataset.bound !== "true") {
                languageSelect.dataset.bound = "true";
                languageSelect.addEventListener("change", () => {
                    setLanguage(languageSelect.value);
                    if (typeof options.onLanguageChange === "function") {
                        options.onLanguageChange(state.language);
                    }
                });
            }
        }

        if (regionSelect) {
            const calendars = Object.entries(HOLIDAY_CALENDARS);
            regionSelect.innerHTML = calendars.map(([key, calendar]) => `
                <option value="${escapeHtml(key)}">${escapeHtml(getLocalizedValue(calendar.label))}</option>
            `).join("");
            regionSelect.value = state.holidayRegion;

            if (regionSelect.dataset.bound !== "true") {
                regionSelect.dataset.bound = "true";
                regionSelect.addEventListener("change", () => {
                    setHolidayRegion(regionSelect.value);
                    if (typeof options.onRegionChange === "function") {
                        options.onRegionChange(state.holidayRegion);
                    }
                });
            }
        }
    }

    function init(options = {}) {
        if (options.language && LANGUAGE_CONFIG[options.language]) {
            state.language = options.language;
        }
        applyLanguageSettings();
        bindLocaleControls(options);
        applyLocalization(options.mappings || {}, { titleKey: options.titleKey, onApplied: options.onApplied });
    }

    return {
        init,
        t,
        getLocalizedValue,
        setLanguage,
        getLanguage,
        setHolidayRegion,
        getLocaleConfig,
        applyLocalization,
        bindLocaleControls,
        renderHolidayCalendar,
        formatDate,
        formatDateTime,
        formatWeekday,
        getCurrencyFormatter,
        normalizeUnicodeText,
        escapeHtml,
        LANGUAGE_CONFIG,
        HOLIDAY_CALENDARS,
        I18N
    };
})();
