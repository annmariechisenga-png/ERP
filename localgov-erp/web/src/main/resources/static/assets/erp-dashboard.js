const state = {
    token: localStorage.getItem("erp.jwt") || "",
    username: localStorage.getItem("erp.username") || "",
    roles: JSON.parse(localStorage.getItem("erp.roles") || "[]"),
    dashboardIdentity: JSON.parse(localStorage.getItem("erp.dashboardIdentity") || "null"),
    dashboardProfiles: null,
    selectedPositionId: "DIRECTOR_HR_ADMIN",
    selectedAuthorityType: "Town Council",
    activeProfile: null,
    leavePolicies: null,
    globalPolicies: null,
    holidayCalendar: null,
    leaveBalance: null,
    leaveHistory: null,
    pendingLeaves: null,
    overtimeRequests: null,
    salaryAdvanceRequests: null,
    pendingDeductions: null,
    employees: null,
    employeeDocuments: null,
    payrollHistory: null,
    lastOvertimeTrigger: null,
    salaryAdvanceTracking: null,
    isOffline: typeof navigator !== "undefined" ? !navigator.onLine : false,
    language: localStorage.getItem("erp.language") || "en",
    holidayRegion: localStorage.getItem("erp.holidayRegion") || "zambia",
    locale: localStorage.getItem("erp.locale") || "en-ZM",
    currency: localStorage.getItem("erp.currency") || "ZMW",
    direction: localStorage.getItem("erp.direction") || "ltr",
    activeTab: "leave-types",
    pendingLeavePage: 0,
    overtimePage: 0,
    salaryAdvancePage: 0,
    isLoadingEmployees: false,
    isLoadingDocuments: false
};

const REQUIRED_DOCUMENT_KEYS = new Set(["terms", "disciplinary", "grievance"]);
const LANGUAGE_CONFIG = {
    en: { label: "English", locale: "en-ZM", currency: "ZMW", dir: "ltr" },
    fr: { label: "Français", locale: "fr", currency: "ZMW", dir: "ltr" },
    ar: { label: "العربية", locale: "ar", currency: "ZMW", dir: "rtl" },
    he: { label: "עברית", locale: "he", currency: "ZMW", dir: "rtl" }
};
const HOLIDAY_CALENDARS = {
    zambia: {
        label: { en: "Zambia national", fr: "Zambie nationale", ar: "العطل الوطنية في زامبيا", he: "חגים לאומיים בזמביה" },
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
        holidayEmpty: "No holiday entries are configured for this region yet."
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
        mfaPlaceholder: "Entrez le code MFA s'il est activé"
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
        mfaPlaceholder: "أدخل رمز التحقق إذا كان مفعلاً"
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
        mfaPlaceholder: "הזן קוד MFA אם הוא מופעל"
    }
};
const LEAVE_API_CODE_ALIASES = {
    
    SICK_LEAVE: "SICK",
    MATERNITY_LEAVE: "MATERNITY",
    PATERNITY_LEAVE: "PATERNITY",
    LOCAL_LEAVE: "LOCAL",
    VACATION_LEAVE: "VACATION",
    COMPASSIONATE_LEAVE: "COMPASSIONATE",
    FAMILY_CARE_LEAVE: "FAMILY_CARE",
    FAMILY_CARE: "FAMILY_CARE",
    MOTHER_S_DAY: "MOTHERS_DAY",
    MOTHERS_DAY: "MOTHERS_DAY",
    UNPAID_LEAVE: "UNPAID"
};
const USE_LEAVE_CALCULATION_API = true;
const SUPPORTED_LEAVE_REQUEST_CODES = new Set(["SICK", "MATERNITY", "PATERNITY", "LOCAL", "VACATION", "COMPASSIONATE", "FAMILY_CARE", "MOTHERS_DAY", "UNPAID"]);
const BIRTH_PROOF_REQUIRED_CODES = new Set(["MATERNITY", "PATERNITY", "MATERNITY_LEAVE", "PATERNITY_LEAVE"]);
const PUBLIC_DATA_CACHE_KEY = "erp.publicDataCache.v1";
const MAX_SUPPORTING_DOCUMENT_BYTES = 5 * 1024 * 1024;
const FAMILY_CARE_ANNUAL_LIMIT = 3;
const MOTHERS_DAY_MONTHLY_LIMIT = 1;
const ALLOWED_SUPPORTING_DOCUMENT_EXTENSIONS = new Set(["pdf", "png", "jpg", "jpeg"]);
const ALLOWED_SUPPORTING_DOCUMENT_TYPES = new Set(["application/pdf", "image/png", "image/jpeg"]);
const PUBLIC_REQUEST_CACHE_TTL_MS = 5 * 60 * 1000;
const PROTECTED_REQUEST_CACHE_TTL_MS = 20 * 1000;
const DEFAULT_PAGE_SIZE = 8;
const REQUEST_TIMEOUT_MS = 8000;

const $ = (selector) => document.querySelector(selector);
let money = getCurrencyFormatter();
let pendingLoadingOperations = 0;
const jsonResponseCache = new Map();
const inflightJsonRequests = new Map();

function getNetworkConnection() {
    return typeof navigator !== "undefined"
        ? (navigator.connection || navigator.mozConnection || navigator.webkitConnection || null)
        : null;
}

function isSlowConnection() {
    const effectiveType = String(getNetworkConnection()?.effectiveType || "").toLowerCase();
    return effectiveType.includes("2g") || effectiveType.includes("3g");
}

function getAdaptivePageSize(defaultSize = DEFAULT_PAGE_SIZE) {
    const effectiveType = String(getNetworkConnection()?.effectiveType || "").toLowerCase();
    if (effectiveType.includes("slow-2g") || effectiveType.includes("2g")) {
        return Math.min(defaultSize, 4);
    }
    if (effectiveType.includes("3g")) {
        return Math.min(defaultSize, 6);
    }
    return defaultSize;
}

document.addEventListener("DOMContentLoaded", () => {
    bindTabs();
    bindLocaleControls();
    bindAuth();
    bindRefreshActions();
    bindConnectivityAwareness();
    bindProfileSelectors();
    bindLeaveRequestForm();
    bindOvertimeTriggerForm();
    bindSalaryAdvanceForm();
    applyLocalization();
    syncAuthStatus();
    loadDashboardProfiles().then(() => {
        applyLocalization();
        return loadPublicData();
    }).then(async () => {
        if (state.token) {
            await loadSessionIdentity();
            await loadProtectedData();
        }
    });
});

async function loadDashboardProfiles() {
    const response = await fetchJson("dashboard/profiles");
    state.dashboardProfiles = response;

    const positionSelect = $("#positionProfileSelect");
    const authoritySelect = $("#authorityTypeSelect");
    const uniqueProfiles = new Map();
    (response.profiles || []).forEach((profile) => {
        if (!uniqueProfiles.has(profile.positionId)) {
            uniqueProfiles.set(profile.positionId, profile.positionTitle);
        }
    });

    positionSelect.innerHTML = [...uniqueProfiles.entries()].map(([positionId, positionTitle]) => `
        <option value="${escapeHtml(positionId)}">${escapeHtml(positionId)} - ${escapeHtml(positionTitle)}</option>
    `).join("");
    authoritySelect.innerHTML = (response.authorityTypes || []).map((authorityType) => `
        <option value="${escapeHtml(authorityType)}">${escapeHtml(authorityType)}</option>
    `).join("");

    if (state.dashboardIdentity?.positionId && uniqueProfiles.has(state.dashboardIdentity.positionId)) {
        state.selectedPositionId = state.dashboardIdentity.positionId;
    }
    if (state.dashboardIdentity?.authorityType && (response.authorityTypes || []).includes(state.dashboardIdentity.authorityType)) {
        state.selectedAuthorityType = state.dashboardIdentity.authorityType;
    }

    const params = new URLSearchParams(window.location.search);
    const requestedPositionId = params.get("positionId");
    const requestedAuthorityType = params.get("authorityType");
    if (requestedPositionId && uniqueProfiles.has(requestedPositionId)) {
        state.selectedPositionId = requestedPositionId;
    }
    if (requestedAuthorityType && (response.authorityTypes || []).includes(requestedAuthorityType)) {
        state.selectedAuthorityType = requestedAuthorityType;
    }

    positionSelect.value = state.selectedPositionId;
    authoritySelect.value = state.selectedAuthorityType;
    await loadActiveDashboardProfile();
}

function bindLocaleControls() {
    const languageSelect = $("#languageSelect");
    const regionSelect = $("#regionCalendarSelect");

    if (!languageSelect || !regionSelect) {
        return;
    }

    const syncControls = () => {
        const calendars = Object.entries(HOLIDAY_CALENDARS);
        const fallbackRegion = calendars[0]?.[0] || "zambia";
        if (!HOLIDAY_CALENDARS[state.holidayRegion]) {
            state.holidayRegion = fallbackRegion;
        }

        languageSelect.innerHTML = Object.entries(LANGUAGE_CONFIG).map(([key, config]) => `
            <option value="${escapeHtml(key)}">${escapeHtml(config.label)}</option>
        `).join("");

        regionSelect.innerHTML = calendars.map(([key, calendar]) => `
            <option value="${escapeHtml(key)}">${escapeHtml(getLocalizedValue(calendar.label))}</option>
        `).join("");

        languageSelect.value = state.language;
        regionSelect.value = state.holidayRegion;
    };

    syncControls();

    if (languageSelect.dataset.bound === "true") {
        return;
    }
    languageSelect.dataset.bound = "true";
    regionSelect.dataset.bound = "true";

    languageSelect.addEventListener("change", () => {
        state.language = languageSelect.value || "en";
        applyLocalization();
        renderAll();
        syncAuthStatus();
    });

    regionSelect.addEventListener("change", () => {
        state.holidayRegion = regionSelect.value || "zambia";
        localStorage.setItem("erp.holidayRegion", state.holidayRegion);
        applyLocalization();
        renderHolidayCalendar();
    });
}

function applyLocalization() {
    const config = getLocaleConfig();
    state.locale = config.locale;
    state.currency = config.currency;
    state.direction = config.dir;

    localStorage.setItem("erp.language", state.language);
    localStorage.setItem("erp.locale", state.locale);
    localStorage.setItem("erp.currency", state.currency);
    localStorage.setItem("erp.direction", state.direction);
    localStorage.setItem("erp.holidayRegion", state.holidayRegion);

    document.documentElement.lang = state.language;
    document.documentElement.dir = state.direction;
    document.body?.setAttribute("dir", state.direction);
    document.title = getLocalizedValue({ en: "LocalGov ERP Workspace", fr: "Espace ERP LocalGov", ar: "مساحة عمل LocalGov ERP", he: "סביבת עבודה LocalGov ERP" });
    money = getCurrencyFormatter();

    const authHeading = document.querySelector(".auth-header h2");
    if (authHeading) {
        authHeading.textContent = getLocalizedValue({
            en: "Sign In For Protected Workflows",
            fr: "Connexion aux workflows protégés",
            ar: "تسجيل الدخول للعمليات المحمية",
            he: "כניסה לתהליכים מוגנים"
        });
    }

    setText("#workspaceIntro", t("workspaceIntro"));
    const activeHolidayCalendar = getHolidayCalendarConfig();

    setText("#tab-leave-types", t("navLeave"));
    setText("#tab-holidays", t("navHolidays"));
    setText("#tab-overtime", t("navOvertime"));
    setText("#tab-performance", t("navPerformance"));
    setText("#tab-salary-advance", t("navSalaryAdvance"));
    setText("#tab-payslips", t("navPayslips"));
    setText("#tab-employee-documents", t("navDocuments"));
    setText("#holidayCalendarHeading", t("leaveHolidayHeading"));
    setText("#holidayCalendarHint", t("leaveHolidayHint"));
    setText("#localeStatus", `${t("localeStatus")} ${t("holidayUpdated", { region: getLocalizedValue(activeHolidayCalendar.label) })}`);

    setInputLabelText("positionProfileSelect", getLocalizedValue({ en: "Dashboard position", fr: "Poste du tableau de bord", ar: "منصب لوحة المعلومات", he: "תפקיד בלוח הבקרה" }));
    setInputLabelText("authorityTypeSelect", getLocalizedValue({ en: "Local authority type", fr: "Type d'autorité locale", ar: "نوع السلطة المحلية", he: "סוג הרשות המקומית" }));
    setInputLabelText("languageSelect", t("displayLanguage"));
    setInputLabelText("regionCalendarSelect", t("holidayRegion"));

    setText("#leaveRequestHeading", getLocalizedValue({ en: "Submit Leave Request", fr: "Soumettre une demande de congé", ar: "إرسال طلب إجازة", he: "הגשת בקשת חופשה" }));
    setText("#leaveFormHint", getLocalizedValue({ en: "Choose the leave type, enter the first day away and the number of leave days, and the ERP will calculate when you should report back to work. The birth record field only appears for maternity and paternity leave.", fr: "Choisissez le type de congé, saisissez le premier jour d'absence et le nombre de jours, puis l'ERP calculera votre date de reprise. Le certificat de naissance n'apparaît que pour les congés maternité et paternité.", ar: "اختر نوع الإجازة وأدخل أول يوم للغياب وعدد الأيام، وسيحسب النظام تلقائيًا موعد العودة إلى العمل. يظهر حقل شهادة الميلاد فقط لإجازة الأمومة والأبوة.", he: "בחרו את סוג החופשה, הזינו את יום ההיעדרות הראשון ואת מספר הימים, והמערכת תחשב מתי יש לחזור לעבודה. שדה תעודת הלידה מופיע רק לחופשת לידה ואבהות." }));

    setInputLabelText("mfaCode", t("mfaLabel"));
    setInputLabelText("leaveRequestTypeSelect", getLocalizedValue({ en: "Leave type", fr: "Type de congé", ar: "نوع الإجازة", he: "סוג חופשה" }));
    setInputLabelText("leaveStartDate", getLocalizedValue({ en: "Start date", fr: "Date de début", ar: "تاريخ البدء", he: "תאריך התחלה" }));
    setInputLabelText("leaveDaysRequested", getLocalizedValue({ en: "Days off", fr: "Jours de congé", ar: "أيام الإجازة", he: "ימי חופשה" }));
    setInputLabelText("leaveEndDate", getLocalizedValue({ en: "Last day of leave", fr: "Dernier jour de congé", ar: "آخر يوم إجازة", he: "יום החופשה האחרון" }));
    setInputLabelText("compassionateRelationSelect", getLocalizedValue({ en: "Compassionate leave relation", fr: "Lien familial du congé compassion", ar: "صلة القرابة لإجازة التعاطف", he: "קרבה משפחתית לחופשת חמלה" }));
    setInputLabelText("leaveReason", getLocalizedValue({ en: "Reason", fr: "Motif", ar: "السبب", he: "סיבה" }));
    setInputLabelText("birthProofFile", getLocalizedValue({ en: "Birth record / certificate", fr: "Acte de naissance / certificat", ar: "سجل / شهادة الميلاد", he: "רישום / תעודת לידה" }));

    setInputLabelText("overtimeEmployeeId", getLocalizedValue({ en: "Employee ID", fr: "Identifiant employé", ar: "رقم الموظف", he: "מזהה עובד" }));
    setInputLabelText("overtimeClockOutTime", getLocalizedValue({ en: "Clock-out time", fr: "Heure de sortie", ar: "وقت الخروج", he: "שעת יציאה" }));
    setInputLabelText("salaryAdvanceAuthorityRef", getLocalizedValue({ en: "Authority reference code", fr: "Code de référence de l'autorité", ar: "رمز مرجع الجهة", he: "קוד סימוכין של הרשות" }));
    setInputLabelText("salaryAdvanceAmount", getLocalizedValue({ en: `Requested amount (${state.currency})`, fr: `Montant demandé (${state.currency})`, ar: `المبلغ المطلوب (${state.currency})`, he: `סכום מבוקש (${state.currency})` }));
    setInputLabelText("salaryAdvanceInstallments", getLocalizedValue({ en: "Installments", fr: "Versements", ar: "الأقساط", he: "תשלומים" }));
    setInputLabelText("salaryAdvanceReason", getLocalizedValue({ en: "Reason", fr: "Motif", ar: "السبب", he: "סיבה" }));

    const authButton = document.querySelector("#authForm button[type='submit']");
    if (authButton) {
        authButton.textContent = getLocalizedValue({ en: "Authenticate", fr: "Se connecter", ar: "تسجيل الدخول", he: "התחברות" });
    }
    const logoutButton = $("#logoutButton");
    if (logoutButton) {
        logoutButton.textContent = getLocalizedValue({ en: "Logout", fr: "Déconnexion", ar: "تسجيل الخروج", he: "התנתקות" });
    }

    const leaveSubmitButton = document.querySelector("#leaveRequestForm button[type='submit']");
    if (leaveSubmitButton) {
        leaveSubmitButton.textContent = getLocalizedValue({ en: "Submit Leave Request", fr: "Soumettre la demande", ar: "إرسال طلب الإجازة", he: "הגש בקשת חופשה" });
    }
    const overtimeSubmitButton = document.querySelector("#overtimeTriggerForm button[type='submit']");
    if (overtimeSubmitButton) {
        overtimeSubmitButton.textContent = getLocalizedValue({ en: "Trigger Overtime", fr: "Lancer l'heures supplémentaires", ar: "تشغيل العمل الإضافي", he: "הפעל שעות נוספות" });
    }
    const advanceSubmitButton = document.querySelector("#salaryAdvanceForm button[type='submit']");
    if (advanceSubmitButton) {
        advanceSubmitButton.textContent = getLocalizedValue({ en: "Submit Salary Advance", fr: "Soumettre l'avance", ar: "إرسال السلفة", he: "הגש מקדמה" });
    }

    const username = $("#username");
    if (username) {
        username.placeholder = getLocalizedValue({ en: "Enter username", fr: "Saisissez le nom d'utilisateur", ar: "أدخل اسم المستخدم", he: "הזינו שם משתמש" });
    }
    const password = $("#password");
    if (password) {
        password.placeholder = getLocalizedValue({ en: "Enter password", fr: "Saisissez le mot de passe", ar: "أدخل كلمة المرور", he: "הזינו סיסמה" });
    }
    const mfaCode = $("#mfaCode");
    if (mfaCode) {
        mfaCode.placeholder = t("mfaPlaceholder");
    }
    const leaveReason = $("#leaveReason");
    if (leaveReason) {
        leaveReason.placeholder = getLocalizedValue({ en: "State the reason for leave", fr: "Indiquez le motif du congé", ar: "اذكر سبب الإجازة", he: "ציינו את סיבת החופשה" });
    }
    const overtimeEmployeeId = $("#overtimeEmployeeId");
    if (overtimeEmployeeId) {
        overtimeEmployeeId.placeholder = getLocalizedValue({ en: "Resolved from your profile when available", fr: "Renseigné depuis votre profil si disponible", ar: "يتم تعبئته من ملفك عند توفره", he: "יתמלא מהפרופיל שלך כשזמין" });
    }
    const salaryAuthority = $("#salaryAdvanceAuthorityRef");
    if (salaryAuthority) {
        salaryAuthority.placeholder = getLocalizedValue({ en: "e.g. LA001", fr: "ex. LA001", ar: "مثال: LA001", he: "למשל LA001" });
    }
    const salaryReason = $("#salaryAdvanceReason");
    if (salaryReason) {
        salaryReason.placeholder = getLocalizedValue({ en: "State the reason for the salary advance request", fr: "Indiquez le motif de l'avance sur salaire", ar: "اذكر سبب طلب السلفة", he: "ציינו את הסיבה לבקשת המקדמה" });
    }

    bindLocaleControls();
    renderHolidayCalendar();
}

function setText(selector, value) {
    const node = $(selector);
    if (node) {
        node.textContent = value;
    }
}

function setInputLabelText(inputId, value) {
    const input = $("#" + inputId);
    const label = input?.closest("label");
    const span = label?.querySelector("span");
    if (span) {
        span.textContent = value;
    }
}

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

function getHolidayCalendarConfig() {
    const fallback = HOLIDAY_CALENDARS[state.holidayRegion] || HOLIDAY_CALENDARS.zambia;
    const liveHolidays = Array.isArray(state.holidayCalendar?.holidays)
        ? state.holidayCalendar.holidays
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
        label: state.holidayCalendar?.label || fallback.label,
        holidays: liveHolidays
    };
}

function renderHolidayCalendar() {
    const root = $("#holidayCalendar");
    if (!root) {
        return;
    }

    const summaryRoot = $("#holidaySummary");
    const metaRoot = $("#holidayMeta");
    const calendar = getHolidayCalendarConfig();
    const holidays = [...(calendar?.holidays || [])].sort((left, right) => String(left.date).localeCompare(String(right.date)));
    const weekendDays = [0, 6].map((day) => formatWeekday(day)).join(" / ");
    const sourceLabel = state.holidayCalendar?.sourceLabel || getLocalizedValue({
        en: "Configured 2026 Zambia holiday data",
        fr: "Jours fériés zambiens 2026 configurés",
        ar: "بيانات عطلات زامبيا 2026 المهيأة",
        he: "נתוני חגי זמביה 2026 שהוגדרו"
    });

    if (metaRoot) {
        metaRoot.textContent = sourceLabel;
    }

    if (summaryRoot) {
        summaryRoot.innerHTML = [
            {
                value: String(holidays.length),
                label: getLocalizedValue({ en: "2026 public holidays", fr: "Jours fériés 2026", ar: "عطلات 2026 الرسمية", he: "חגים ציבוריים 2026" }),
                note: getLocalizedValue({ en: "Verified Zambia entries now have a dedicated tab.", fr: "Les entrées vérifiées de la Zambie ont désormais un onglet dédié.", ar: "لدى عطلات زامبيا المؤكدة الآن تبويب مخصص.", he: "לחגי זמביה המאומתים יש כעת לשונית ייעודית." })
            },
            {
                value: getLocalizedValue(calendar.label),
                label: getLocalizedValue({ en: "Calendar scope", fr: "Portée du calendrier", ar: "نطاق التقويم", he: "טווח הלוח" }),
                note: sourceLabel
            },
            {
                value: weekendDays,
                label: t("weekend"),
                note: getLocalizedValue({ en: "Weekend days used by leave and overtime planning.", fr: "Week-ends utilisés pour la planification des congés et des heures supplémentaires.", ar: "أيام عطلة نهاية الأسبوع المستخدمة في تخطيط الإجازات والعمل الإضافي.", he: "ימי סוף השבוע המשמשים לתכנון חופשות ושעות נוספות." })
            }
        ].map(renderMetricCard).join("");
    }

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

function formatWeekday(index) {
    const date = new Date(Date.UTC(2026, 0, 4 + index));
    return new Intl.DateTimeFormat(state.locale, { weekday: "long" }).format(date);
}

function normalizeUnicodeText(value) {
    return String(value ?? "").normalize("NFC").trim();
}

function bindProfileSelectors() {
    $("#positionProfileSelect").addEventListener("change", async (event) => {
        state.selectedPositionId = event.target.value;
        await loadActiveDashboardProfile();
        renderAll();
        updateQueryString();
    });

    $("#authorityTypeSelect").addEventListener("change", async (event) => {
        state.selectedAuthorityType = event.target.value;
        await loadActiveDashboardProfile();
        renderAll();
        updateQueryString();
    });
}

async function loadActiveDashboardProfile() {
    state.activeProfile = await fetchJson(`dashboard/profile?positionId=${encodeURIComponent(state.selectedPositionId)}&authorityType=${encodeURIComponent(state.selectedAuthorityType)}`);
    renderDashboardProfile();
}

async function loadSessionIdentity() {
    if (!state.token) {
        return;
    }

    try {
        const response = await fetchJson("auth/me", {}, true);
        state.username = response.username || state.username;
        state.roles = response.roles || state.roles;
        localStorage.setItem("erp.username", state.username);
        localStorage.setItem("erp.roles", JSON.stringify(state.roles));
        await applyDashboardIdentity(response.dashboardIdentity);
        syncAuthStatus();
    } catch (error) {
        setAuthStatus(`Signed in as ${state.username}. Automatic dashboard resolution is unavailable right now.`, true);
    }
}

async function applyDashboardIdentity(identity) {
    state.dashboardIdentity = identity || null;

    if (state.dashboardIdentity) {
        localStorage.setItem("erp.dashboardIdentity", JSON.stringify(state.dashboardIdentity));

        if (state.dashboardIdentity.positionId) {
            state.selectedPositionId = state.dashboardIdentity.positionId;
        }
        if (state.dashboardIdentity.authorityType) {
            state.selectedAuthorityType = state.dashboardIdentity.authorityType;
        }
    } else {
        localStorage.removeItem("erp.dashboardIdentity");
    }

    syncProfileSelectors();
    await loadActiveDashboardProfile();
    renderAll();
    updateQueryString();
}

function syncProfileSelectors() {
    const positionSelect = $("#positionProfileSelect");
    const authoritySelect = $("#authorityTypeSelect");

    if (positionSelect && [...positionSelect.options].some((option) => option.value === state.selectedPositionId)) {
        positionSelect.value = state.selectedPositionId;
    }
    if (authoritySelect && [...authoritySelect.options].some((option) => option.value === state.selectedAuthorityType)) {
        authoritySelect.value = state.selectedAuthorityType;
    }
}

function bindTabs() {
    const buttons = [...document.querySelectorAll(".tab-button")];
    const panels = [...document.querySelectorAll(".module-panel")];

    if (!buttons.length || !panels.length) {
        return;
    }

    const activateTab = (button, moveFocus = false) => {
        buttons.forEach((item) => {
            const isActive = item === button;
            item.classList.toggle("is-active", isActive);
            item.setAttribute("aria-selected", String(isActive));
            item.setAttribute("tabindex", isActive ? "0" : "-1");
        });

        panels.forEach((panel) => {
            const isActive = panel.dataset.panel === button.dataset.tab;
            panel.classList.toggle("is-active", isActive);
            panel.hidden = !isActive;
            panel.setAttribute("aria-hidden", String(!isActive));
        });

        state.activeTab = button.dataset.tab || "leave-types";
        void loadDeferredTabData(state.activeTab);

        if (moveFocus) {
            button.focus();
        }
    };

    buttons.forEach((button, index) => {
        button.addEventListener("click", () => activateTab(button));
        button.addEventListener("keydown", (event) => {
            let nextIndex = null;

            if (event.key === "ArrowDown" || event.key === "ArrowRight") {
                nextIndex = (index + 1) % buttons.length;
            } else if (event.key === "ArrowUp" || event.key === "ArrowLeft") {
                nextIndex = (index - 1 + buttons.length) % buttons.length;
            } else if (event.key === "Home") {
                nextIndex = 0;
            } else if (event.key === "End") {
                nextIndex = buttons.length - 1;
            } else if (event.key === "Enter" || event.key === " ") {
                event.preventDefault();
                activateTab(button, true);
                return;
            }

            if (nextIndex !== null) {
                event.preventDefault();
                activateTab(buttons[nextIndex], true);
            }
        });
    });

    activateTab(buttons.find((button) => button.classList.contains("is-active")) || buttons[0]);
}

async function loadDeferredTabData(tab) {
    if (tab === "employee-documents" && !state.employeeDocuments && !state.isLoadingDocuments) {
        await loadEmployeeDocumentsData(true);
        return;
    }

    if (!state.token) {
        return;
    }

    const needsDeferredProtectedData = (tab === "performance" && state.employees === null)
        || (tab === "salary-advance" && state.pendingDeductions === null)
        || (tab === "payslips" && state.payrollHistory === null);

    if (needsDeferredProtectedData) {
        await loadProtectedData();
    }
}

function bindAuth() {
    $("#authForm").addEventListener("submit", async (event) => {
        event.preventDefault();
        const username = normalizeUnicodeText($("#username").value);
        const password = $("#password").value;
        const mfaCode = normalizeUnicodeText($("#mfaCode")?.value || "");

        if (!username || !password) {
            setAuthStatus(t("authRequired"), true);
            return;
        }

        setAuthStatus(t("authLoading"), false, true);

        try {
            const response = await fetchJson("auth/login", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ username, password, mfaCode })
            });

            if (response.mfaRequired && !response.token) {
                setAuthStatus(response.message || "MFA verification required before sign-in can complete.", true);
                $("#mfaCode")?.focus();
                return;
            }

            state.token = response.token;
            state.username = response.username;
            state.roles = response.roles || [];
            localStorage.setItem("erp.jwt", state.token);
            localStorage.setItem("erp.username", state.username);
            localStorage.setItem("erp.roles", JSON.stringify(state.roles));
            $("#password").value = "";
            if ($("#mfaCode")) {
                $("#mfaCode").value = "";
            }
            await applyDashboardIdentity(response.dashboardIdentity);
            syncAuthStatus();
            await loadProtectedData();
        } catch (error) {
            setAuthStatus(error.message || t("authFailed"), true);
        }
    });

    $("#logoutButton").addEventListener("click", async () => {
        state.token = "";
        state.username = "";
        state.roles = [];
        state.dashboardIdentity = null;
        state.leaveBalance = null;
        state.pendingLeaves = null;
        state.overtimeRequests = null;
        state.salaryAdvanceRequests = null;
        state.pendingDeductions = null;
        state.employees = null;
        state.lastOvertimeTrigger = null;
        state.salaryAdvanceTracking = null;
        state.selectedPositionId = "DIRECTOR_HR_ADMIN";
        state.selectedAuthorityType = "Town Council";
        localStorage.removeItem("erp.jwt");
        localStorage.removeItem("erp.username");
        localStorage.removeItem("erp.roles");
        localStorage.removeItem("erp.dashboardIdentity");
        syncProfileSelectors();
        await loadActiveDashboardProfile();
        syncAuthStatus();
        renderProtectedFallbacks();
    });
}

function bindRefreshActions() {
    $("#refreshOvertime").addEventListener("click", () => {
        state.overtimePage = 0;
        clearJsonResponseCache();
        loadProtectedData();
    });
    $("#refreshSalaryAdvance").addEventListener("click", () => {
        state.salaryAdvancePage = 0;
        clearJsonResponseCache();
        loadProtectedData();
    });
    $("#overtimeStatusFilter").addEventListener("change", () => {
        state.overtimePage = 0;
        loadProtectedData();
    });
    $("#salaryAdvanceStatusFilter").addEventListener("change", () => {
        state.salaryAdvancePage = 0;
        loadProtectedData();
    });
}

function bindConnectivityAwareness() {
    syncConnectivityBanner();

    window.addEventListener("offline", () => {
        state.isOffline = true;
        syncConnectivityBanner(getLocalizedValue({
            en: "Connection lost. The ERP will keep the last saved policy data visible until the network returns.",
            fr: "Connexion perdue. L'ERP conserve les dernières politiques enregistrées jusqu'au retour du réseau.",
            ar: "انقطع الاتصال. سيواصل النظام عرض آخر بيانات سياسة محفوظة حتى تعود الشبكة.",
            he: "החיבור אבד. המערכת תשאיר את נתוני המדיניות השמורים האחרונים גלויים עד שהרשת תחזור."
        }), true);
    });

    window.addEventListener("online", () => {
        state.isOffline = false;
        syncConnectivityBanner(getLocalizedValue({
            en: "Connection restored. Refreshing ERP policy and workflow data now.",
            fr: "Connexion rétablie. Actualisation des politiques et workflows ERP.",
            ar: "تمت استعادة الاتصال. جارٍ تحديث سياسات النظام وسير العمل الآن.",
            he: "החיבור שוחזר. נתוני המדיניות ותהליכי העבודה מתרעננים כעת."
        }), false);
        loadPublicData();
        if (state.token) {
            loadProtectedData();
        }
    });
}

function syncConnectivityBanner(message = "", isWarning = false) {
    state.isOffline = typeof navigator !== "undefined" ? !navigator.onLine : false;
    const banner = $("#connectivityBanner");
    if (!banner) {
        return;
    }

    const activeMessage = state.isOffline
        ? (message || getLocalizedValue({
            en: "You appear to be offline. Review the saved dashboard data now and retry submissions once the backend is reachable.",
            fr: "Vous semblez hors ligne. Consultez les données enregistrées et réessayez les envois lorsque le backend redevient accessible.",
            ar: "يبدو أنك غير متصل. راجع البيانات المحفوظة الآن وأعد محاولة الإرسال عند توفر الخادم.",
            he: "נראה שאתם במצב לא מקוון. אפשר לעיין בנתונים השמורים ולנסות שוב כששרת ה-ERP יחזור."
        }))
        : (message || "");

    if (!activeMessage) {
        banner.textContent = "";
        banner.classList.add("is-hidden");
        banner.classList.remove("notice-warn");
        return;
    }

    banner.textContent = activeMessage;
    banner.classList.remove("is-hidden");
    banner.classList.toggle("notice-warn", Boolean(isWarning || state.isOffline));
}

function savePublicDataCache(snapshot) {
    try {
        localStorage.setItem(PUBLIC_DATA_CACHE_KEY, JSON.stringify({
            savedAt: new Date().toISOString(),
            snapshot
        }));
    } catch (error) {
    }
}

function loadPublicDataCache() {
    try {
        const raw = localStorage.getItem(PUBLIC_DATA_CACHE_KEY);
        if (!raw) {
            return null;
        }
        const parsed = JSON.parse(raw);
        return parsed?.snapshot ? parsed : null;
    } catch (error) {
        return null;
    }
}

function cloneJsonValue(value) {
    return value == null ? value : JSON.parse(JSON.stringify(value));
}

function buildRequestCacheKey(path, authenticated) {
    return `${authenticated ? `auth:${state.username || "session"}` : "public"}|${path}`;
}

function clearJsonResponseCache(match = null) {
    if (!match) {
        jsonResponseCache.clear();
        return;
    }

    [...jsonResponseCache.keys()].forEach((key) => {
        if ((match instanceof RegExp && match.test(key)) || (typeof match === "string" && key.includes(match))) {
            jsonResponseCache.delete(key);
        }
    });
}

function getCachedJsonResponse(cacheKey, ttlMs) {
    const cached = jsonResponseCache.get(cacheKey);
    if (!cached) {
        return null;
    }
    if ((Date.now() - cached.savedAt) > ttlMs) {
        jsonResponseCache.delete(cacheKey);
        return null;
    }
    return cloneJsonValue(cached.value);
}

function setCachedJsonResponse(cacheKey, value) {
    jsonResponseCache.set(cacheKey, {
        savedAt: Date.now(),
        value: cloneJsonValue(value)
    });
}

function setDashboardLoading(active, message = "") {
    const banner = $("#appLoadingIndicator");
    const text = $("#appLoadingText");
    if (!banner) {
        return;
    }

    pendingLoadingOperations = active
        ? pendingLoadingOperations + 1
        : Math.max(0, pendingLoadingOperations - 1);

    if (message && text) {
        text.textContent = message;
    }

    const shouldShow = pendingLoadingOperations > 0;
    banner.hidden = !shouldShow;
    banner.classList.toggle("is-hidden", !shouldShow);
}

function updateStatusNode(node, message, { warning = false, busy = false } = {}) {
    if (!node) {
        return;
    }

    node.textContent = message || "";
    node.classList.toggle("status-warning", Boolean(warning));
    node.classList.toggle("status-success", !warning && !busy && Boolean(message));
    node.classList.toggle("status-busy", Boolean(busy));
    node.style.color = warning ? "#bb6c25" : "#35515e";
}

function setFieldState(element, message = "") {
    if (!element) {
        return;
    }

    const container = element.closest("label");
    const helpNode = container?.querySelector(".field-hint, small.table-note, .table-note");
    if (helpNode && !helpNode.dataset.defaultMessage) {
        helpNode.dataset.defaultMessage = helpNode.textContent;
    }

    const hasMessage = Boolean(message);
    element.setAttribute("aria-invalid", hasMessage ? "true" : "false");
    container?.classList.toggle("has-error", hasMessage);

    if (helpNode) {
        helpNode.textContent = hasMessage ? message : (helpNode.dataset.defaultMessage || "");
        helpNode.classList.toggle("error-text", hasMessage);
    }
}

function clearFieldStates(...elements) {
    elements.flat().forEach((element) => setFieldState(element, ""));
}

function validateSupportingDocumentFile(file) {
    if (!file) {
        return "";
    }

    const extension = String(file.name || "").split(".").pop()?.toLowerCase() || "";
    const contentType = String(file.type || "").toLowerCase();

    if (Number(file.size || 0) > MAX_SUPPORTING_DOCUMENT_BYTES) {
        return getLocalizedValue({
            en: "Use a PDF, PNG, or JPG file that is 5 MB or smaller.",
            fr: "Utilisez un fichier PDF, PNG ou JPG de 5 Mo maximum.",
            ar: "استخدم ملف PDF أو PNG أو JPG بحجم لا يتجاوز 5 ميغابايت.",
            he: "יש להעלות קובץ PDF, PNG או JPG שגודלו עד 5MB."
        });
    }

    if (!ALLOWED_SUPPORTING_DOCUMENT_EXTENSIONS.has(extension) && !ALLOWED_SUPPORTING_DOCUMENT_TYPES.has(contentType)) {
        return getLocalizedValue({
            en: "Upload a PDF, PNG, or JPG/JPEG certificate file.",
            fr: "Téléversez un certificat au format PDF, PNG ou JPG/JPEG.",
            ar: "ارفع شهادة بصيغة PDF أو PNG أو JPG/JPEG.",
            he: "יש להעלות מסמך אישור מסוג PDF, PNG או JPG/JPEG."
        });
    }

    return "";
}

async function loadPublicData() {
    setDashboardLoading(true, getLocalizedValue({
        en: "Loading ERP policy data and dashboard cards...",
        fr: "Chargement des politiques ERP et des cartes du tableau de bord...",
        ar: "جارٍ تحميل سياسات النظام وبطاقات لوحة المعلومات...",
        he: "נתוני המדיניות וכרטיסי לוח הבקרה נטענים כעת..."
    }));
    renderOverviewCards([]);

    const cached = loadPublicDataCache();
    if (!state.employeeDocuments && cached?.snapshot?.employeeDocuments) {
        state.employeeDocuments = cached.snapshot.employeeDocuments;
    }

    try {
        const [leavePolicies, globalPolicies, holidayCalendar] = await Promise.all([
            fetchJson("meta/schema/leave-policies", { cacheTtlMs: PUBLIC_REQUEST_CACHE_TTL_MS }),
            fetchJson("meta/schema/global-policies", { cacheTtlMs: PUBLIC_REQUEST_CACHE_TTL_MS }),
            fetchJson("meta/schema/holidays", { cacheTtlMs: PUBLIC_REQUEST_CACHE_TTL_MS }).catch(() => null)
        ]);

        state.leavePolicies = leavePolicies;
        state.globalPolicies = globalPolicies;
        state.holidayCalendar = holidayCalendar;

        savePublicDataCache({ leavePolicies, globalPolicies, employeeDocuments: state.employeeDocuments, holidayCalendar });
        syncConnectivityBanner(isSlowConnection()
            ? getLocalizedValue({
                en: "Slow network detected. The dashboard is loading core modules first and larger libraries on demand.",
                fr: "Réseau lent détecté. Le tableau charge d'abord les modules essentiels puis les bibliothèques volumineuses à la demande.",
                ar: "تم اكتشاف شبكة بطيئة. يتم تحميل الوحدات الأساسية أولاً ثم البيانات الأكبر عند الطلب.",
                he: "זוהתה רשת איטית. לוח הבקרה טוען תחילה את המודולים העיקריים ואת הספריות הגדולות לפי דרישה."
            }) : "", false);
        renderAll();

        if (!isSlowConnection()) {
            void loadEmployeeDocumentsData(false);
        }
    } catch (error) {
        if (cached) {
            state.leavePolicies = cached.snapshot.leavePolicies || null;
            state.globalPolicies = cached.snapshot.globalPolicies || null;
            state.employeeDocuments = cached.snapshot.employeeDocuments || null;
            state.holidayCalendar = cached.snapshot.holidayCalendar || null;
            renderAll();
            syncConnectivityBanner(getLocalizedValue({
                en: `Live ERP policy data is unavailable, so the dashboard is using the last saved snapshot from ${formatDateTime(cached.savedAt)}.`,
                fr: `Les données ERP en direct sont indisponibles ; le tableau de bord utilise l'instantané enregistré le ${formatDateTime(cached.savedAt)}.`,
                ar: `بيانات النظام المباشرة غير متاحة، لذا تعرض اللوحة آخر نسخة محفوظة من ${formatDateTime(cached.savedAt)}.`,
                he: `נתוני ה-ERP החיים אינם זמינים, ולכן מוצגת תמונת המצב השמורה האחרונה מ-${formatDateTime(cached.savedAt)}.`
            }), true);
            return;
        }

        state.holidayCalendar = null;
        const message = error.message || "Unable to load public ERP policy data.";
        syncConnectivityBanner(message, true);
        renderOverviewCards([{ label: "Load Status", value: "Unavailable", note: message }]);
        renderNotice("#leaveTypeTable", "Leave policy data is currently unavailable.");
        renderNotice("#jdDirectory", "Performance management policy data is currently unavailable.");
        renderNotice("#salaryAdvanceWorkflow", "Salary advance policy data is currently unavailable.");
        renderHolidayCalendar();
    } finally {
        setDashboardLoading(false);
    }
}

async function loadEmployeeDocumentsData(showBusyState = false) {
    if (state.isLoadingDocuments || state.employeeDocuments) {
        return;
    }

    state.isLoadingDocuments = true;
    if (showBusyState) {
        setDashboardLoading(true, getLocalizedValue({
            en: "Loading the employee document library...",
            fr: "Chargement de la bibliothèque de documents employés...",
            ar: "جارٍ تحميل مكتبة وثائق الموظفين...",
            he: "ספריית מסמכי העובדים נטענת כעת..."
        }));
        renderEmployeeDocuments();
    }

    try {
        state.employeeDocuments = await fetchJson("documents", { cacheTtlMs: PUBLIC_REQUEST_CACHE_TTL_MS }, false);
        savePublicDataCache({
            leavePolicies: state.leavePolicies,
            globalPolicies: state.globalPolicies,
            employeeDocuments: state.employeeDocuments,
            holidayCalendar: state.holidayCalendar
        });
        renderEmployeeDocuments();
    } catch (error) {
        if (!state.employeeDocuments) {
            renderEmployeeDocuments();
        }
    } finally {
        state.isLoadingDocuments = false;
        if (showBusyState) {
            setDashboardLoading(false);
        }
    }
}

function renderAll() {
    renderDashboardProfile();
    renderOverviewCards(buildOverviewMetrics());
    renderLeaveTypes();
    renderHolidayCalendar();
    renderOvertime();
    renderPerformance();
    renderSalaryAdvance();
    renderPayslips();
    renderEmployeeDocuments();
}

async function loadProtectedData() {
    if (!state.token) {
        renderProtectedFallbacks();
        return;
    }

    setDashboardLoading(true, getLocalizedValue({
        en: "Refreshing protected workflow requests...",
        fr: "Actualisation des demandes protégées en cours...",
        ar: "جارٍ تحديث طلبات سير العمل المحمية...",
        he: "רשומות תהליך העבודה המוגנות מתרעננות כעת..."
    }));
    setAuthStatus(`Authenticated as ${state.username}. Loading protected workflow data...`, false, true);

    const overtimeStatus = $("#overtimeStatusFilter").value;
    const salaryAdvanceStatus = $("#salaryAdvanceStatusFilter").value;
    const payPeriod = `${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, "0")}-01`;
    const pageSize = getAdaptivePageSize();
    const needsEmployees = state.activeTab === "performance";
    const needsDeductions = state.activeTab === "salary-advance";
    const needsPayslips = state.activeTab === "payslips";

    state.isLoadingEmployees = needsEmployees && state.employees === null;

    try {
        const [pendingLeaves, overtimeRequests, salaryAdvanceRequests, pendingDeductions, payrollHistory, employees, leaveBalance, leaveHistory] = await Promise.allSettled([
            fetchJson(`leaves/pending/page?page=${state.pendingLeavePage}&size=${pageSize}`, { cacheTtlMs: PROTECTED_REQUEST_CACHE_TTL_MS }, true),
            fetchJson(`overtime/requests?page=${state.overtimePage}&size=${pageSize}${overtimeStatus ? `&status=${encodeURIComponent(overtimeStatus)}` : ""}`, { cacheTtlMs: PROTECTED_REQUEST_CACHE_TTL_MS }, true),
            fetchJson(`salary-advances/requests?page=${state.salaryAdvancePage}&size=${pageSize}${salaryAdvanceStatus ? `&status=${encodeURIComponent(salaryAdvanceStatus)}` : ""}`, { cacheTtlMs: PROTECTED_REQUEST_CACHE_TTL_MS }, true),
            needsDeductions
                ? fetchJson(`salary-advances/deductions/pending?payPeriod=${payPeriod}&status=all`, { cacheTtlMs: PROTECTED_REQUEST_CACHE_TTL_MS }, true)
                : Promise.resolve(state.pendingDeductions),
            needsPayslips
                ? fetchJson("payroll/me", { cacheTtlMs: PROTECTED_REQUEST_CACHE_TTL_MS }, true)
                : Promise.resolve(state.payrollHistory),
            needsEmployees
                ? fetchJson("employees", { cacheTtlMs: PROTECTED_REQUEST_CACHE_TTL_MS }, true)
                : Promise.resolve(state.employees),
            state.dashboardIdentity?.employeeId
                ? fetchJson(`leaves/balance/employee/${encodeURIComponent(state.dashboardIdentity.employeeId)}`, { cacheTtlMs: PROTECTED_REQUEST_CACHE_TTL_MS }, true)
                : Promise.resolve(state.leaveBalance),
            state.dashboardIdentity?.employeeId
                ? fetchJson(`leaves/employee/${encodeURIComponent(state.dashboardIdentity.employeeId)}`, { cacheTtlMs: PROTECTED_REQUEST_CACHE_TTL_MS }, true)
                : Promise.resolve(state.leaveHistory)
        ]);

        state.pendingLeaves = pendingLeaves.status === "fulfilled" ? pendingLeaves.value : null;
        state.overtimeRequests = overtimeRequests.status === "fulfilled" ? overtimeRequests.value : null;
        state.salaryAdvanceRequests = salaryAdvanceRequests.status === "fulfilled" ? salaryAdvanceRequests.value : null;

        if (needsDeductions) {
            state.pendingDeductions = pendingDeductions.status === "fulfilled" ? pendingDeductions.value : null;
        }
        if (needsPayslips) {
            state.payrollHistory = payrollHistory.status === "fulfilled" ? payrollHistory.value : null;
        }
        if (needsEmployees) {
            state.employees = employees.status === "fulfilled" ? employees.value : null;
        }
        state.leaveBalance = leaveBalance.status === "fulfilled" ? leaveBalance.value : null;
        state.leaveHistory = leaveHistory.status === "fulfilled" ? leaveHistory.value : null;

        renderLeaveTypes();
        renderOvertime();
        renderPerformance();
        renderSalaryAdvance();
        renderPayslips();
        renderEmployeeDocuments();

        const failures = [pendingLeaves, overtimeRequests, salaryAdvanceRequests, pendingDeductions, payrollHistory, employees, leaveBalance, leaveHistory]
            .filter((item) => item.status === "rejected");
        if (failures.length) {
            setAuthStatus(state.isOffline
                ? getLocalizedValue({
                    en: `Signed in as ${state.username}, but the backend is currently unavailable. Saved policy data remains visible while workflow tables retry on refresh.`,
                    fr: `Connecté en tant que ${state.username}, mais le backend est actuellement indisponible. Les politiques enregistrées restent visibles pendant les nouvelles tentatives.`,
                    ar: `تم تسجيل الدخول باسم ${state.username}، لكن الخادم غير متاح حالياً. ستظل بيانات السياسة المحفوظة مرئية حتى تتم إعادة المحاولة.`,
                    he: `מחובר/ת כ-${state.username}, אך שרת ה-ERP אינו זמין כרגע. נתוני המדיניות השמורים נשארים זמינים עד לריענון הבא.`
                })
                : `Signed in as ${state.username}. Some protected datasets were blocked by role or server response.`, true);
        } else {
            syncConnectivityBanner(isSlowConnection()
                ? getLocalizedValue({
                    en: "Protected tables are using adaptive page sizes for the current network speed.",
                    fr: "Les tableaux protégés utilisent une pagination adaptative selon la vitesse du réseau.",
                    ar: "تستخدم الجداول المحمية صفحات متكيفة مع سرعة الشبكة الحالية.",
                    he: "הטבלאות המוגנות משתמשות בעימוד מותאם למהירות הרשת הנוכחית."
                }) : "", false);
            setAuthStatus(`Signed in as ${state.username}. Protected workflow data is up to date.`, false);
        }
    } finally {
        state.isLoadingEmployees = false;
        setDashboardLoading(false);
    }
}

function renderProtectedFallbacks() {
    state.payrollHistory = null;
    state.leaveBalance = null;
    state.leaveHistory = null;
    renderNotice("#pendingLeaveTable", "Sign in to view pending leave requests.");
    renderNotice("#overtimeTable", "Sign in to view overtime requests.");
    renderNotice("#salaryAdvanceTable", "Sign in to view salary advance requests.");
    renderNotice("#pendingDeductions", "Sign in to inspect pending deduction schedules.");
    ["#pendingLeavePager", "#overtimeTablePager", "#salaryAdvanceTablePager"].forEach((selector) => {
        const root = $(selector);
        if (root) {
            root.innerHTML = "";
        }
    });
    renderNotice("#orgStructure", "Sign in with a role that can access employees to view department structure.");
    renderNotice("#jdDirectory", "Sign in with a role that can access employees to build the JD directory.");
    renderNotice("#payslipTable", "Sign in to view, download, or print your monthly payslips.");
    const docsError = $("#documentsError");
    if (docsError) {
        docsError.classList.add("is-hidden");
        docsError.innerHTML = "";
    }
    renderPayslips();
    renderEmployeeDocuments();
    renderLeaveRequestForm();
    renderOvertimeTriggerForm();
    renderSalaryAdvanceRequestForm();
    renderSalaryAdvanceTracking();
}

function renderOverviewCards(metrics) {
    const root = $("#overviewCards");
    root.innerHTML = metrics.map((metric) => `
        <article class="metric-card">
            <strong>${escapeHtml(metric.value)}</strong>
            <span>${escapeHtml(metric.label)}</span>
            <p>${escapeHtml(metric.note || "")}</p>
        </article>
    `).join("");
}

function buildOverviewMetrics() {
    const leaveTypeCount = state.leavePolicies?.leaveTypesCount ?? 0;
    const leaveRuleCount = state.leavePolicies?.leavePolicyRulesCount ?? 0;
    const performanceEnabled = state.globalPolicies?.policies?.performanceManagement?.tableExists
        ? getLocalizedValue({ en: "Enabled", fr: "Actif", ar: "مفعل", he: "פעיל" })
        : getLocalizedValue({ en: "Not seeded", fr: "Non alimenté", ar: "غير مهيأ", he: "לא הוגדר" });
    const salaryAdvancePolicyCount = state.globalPolicies?.policies?.salaryAdvance?.policyCount ?? 0;
    const profile = state.activeProfile;

    return [
        { value: String(leaveTypeCount), label: t("navLeave"), note: `${leaveRuleCount} policy rules published for ${profile?.authorityType || "all authorities"}.` },
        { value: performanceEnabled, label: t("navPerformance"), note: "APAS and JD workspace uses policy and employee data." },
        { value: String(salaryAdvancePolicyCount), label: t("navSalaryAdvance"), note: (profile?.priorityMetrics || [])[0] || "Workflow path is rendered from current policy metadata." },
        { value: state.token ? state.roles.join(", ") || getLocalizedValue({ en: "Authenticated", fr: "Authentifié", ar: "موثّق", he: "מאומת" }) : getLocalizedValue({ en: "Public", fr: "Public", ar: "عام", he: "ציבורי" }), label: getLocalizedValue({ en: "Session Scope", fr: "Portée de session", ar: "نطاق الجلسة", he: "טווח הפעלה" }), note: profile ? `${profile.positionTitle} / ${profile.authorityType}` : (state.token ? `Signed in as ${state.username}.` : "Public mode uses schema snapshots only.") }
    ];
}

function renderDashboardProfile() {
    const profile = state.activeProfile;
    if (!profile) {
        return;
    }

    $("#profileTitle").textContent = profile.dashboardTitle;
    $("#profileSummary").textContent = profile.dashboardSummary;
    $("#profileFocusAreas").innerHTML = (profile.focusAreas || []).map((area) => badge(area)).join(" ");

    $("#leavePanelTitle").textContent = `${profile.positionTitle} - ${t("navLeave")}`;
    const holidayTitle = $("#holidayPanelTitle");
    if (holidayTitle) {
        holidayTitle.textContent = `${profile.positionTitle} - ${t("navHolidays")}`;
    }
    $("#overtimePanelTitle").textContent = `${profile.positionTitle} - ${t("navOvertime")}`;
    $("#performancePanelTitle").textContent = `${profile.positionTitle} - ${t("navPerformance")}`;
    $("#salaryAdvancePanelTitle").textContent = `${profile.positionTitle} - ${t("navSalaryAdvance")}`;
    const payslipTitle = $("#payslipPanelTitle");
    if (payslipTitle) {
        payslipTitle.textContent = `${profile.positionTitle} - ${t("navPayslips")}`;
    }
}

function renderLeaveTypes() {
    const leavePolicies = state.leavePolicies;
    const leaveSourceLabel = leavePolicies?.sourceLabel || `${state.selectedAuthorityType} variant`;
    $("#leaveMeta").textContent = leavePolicies ? `${leaveSourceLabel} | ${leavePolicies.authoritiesCovered} authorities covered` : "No policy data";

    const profile = state.activeProfile;
    const leaveOptions = getLeaveOptions();
    const overviewSelect = $("#leaveOverviewSelect");

    const summary = [
        { value: String(leavePolicies?.leaveTypesCount ?? 0), label: getLocalizedValue({ en: "Configured types", fr: "Types configurés", ar: "الأنواع المهيأة", he: "סוגים מוגדרים" }), note: "Available leave request categories." },
        { value: String(leavePolicies?.leavePolicyRulesCount ?? 0), label: getLocalizedValue({ en: "Rules", fr: "Règles", ar: "القواعد", he: "כללים" }), note: (profile?.priorityMetrics || [])[0] || "Eligibility and accrual conditions." },
        { value: String(getCollectionTotal(state.pendingLeaves)), label: getLocalizedValue({ en: "Pending requests", fr: "Demandes en attente", ar: "الطلبات المعلقة", he: "בקשות ממתינות" }), note: state.pendingLeaves ? "Loaded from the paged leave queue." : "Requires sign in." },
        { value: leavePolicies?.uniformAcrossAuthorities ? getLocalizedValue({ en: "Uniform", fr: "Uniforme", ar: "موحد", he: "אחיד" }) : getLocalizedValue({ en: "Mixed", fr: "Mixte", ar: "مختلط", he: "מעורב" }), label: getLocalizedValue({ en: "Policy scope", fr: "Portée de la politique", ar: "نطاق السياسة", he: "טווח המדיניות" }), note: "Evaluated from live schema metadata." }
    ];
    $("#leaveSummary").innerHTML = summary.map(renderMetricCard).join("");
    renderHolidayCalendar();

    if (overviewSelect) {
        const selectedValue = leaveOptions.some((item) => item.code === overviewSelect.value)
            ? overviewSelect.value
            : (leaveOptions[0]?.code || "");

        overviewSelect.innerHTML = leaveOptions.length
            ? leaveOptions.map((item) => `<option value="${escapeHtml(item.code)}">${escapeHtml(item.label)}</option>`).join("")
            : '<option value="">No leave types configured</option>';

        if (selectedValue) {
            overviewSelect.value = selectedValue;
        }

        overviewSelect.onchange = () => renderLeaveTypes();
    }

    const selectedOverview = leaveOptions.find((item) => item.code === overviewSelect?.value) || leaveOptions[0] || null;
    if (selectedOverview) {
        $("#leaveTypeTable").innerHTML = [
            { label: "Leave type", value: selectedOverview.label },
            { label: "Code", value: selectedOverview.code },
            { label: "Paid", value: selectedOverview.details.is_paid ? "Yes" : "No" },
            { label: "Approval", value: selectedOverview.details.requires_approval ? "Required" : "Optional" },
            { label: "Applicable to", value: selectedOverview.details.applicable_to || "All staff" },
            { label: "Notes", value: getLeavePolicyDescription(selectedOverview) }
        ].map((item) => `
            <article class="list-card detail-card">
                <strong>${escapeHtml(item.label)}</strong>
                <p>${escapeHtml(String(item.value ?? "-"))}</p>
            </article>
        `).join("");
    } else {
        renderNotice("#leaveTypeTable", "No leave type records were returned from the schema endpoint.");
    }

    const pendingLeaveRows = getCollectionItems(state.pendingLeaves);
    if (pendingLeaveRows.length) {
        renderTable("#pendingLeaveTable", ["Employee", "Type", "Dates", "Days", "Status"], pendingLeaveRows.map((item) => [
            [item.employeeCode, item.employeeId].filter(Boolean).join(" / ") || "-",
            item.leaveType || "-",
            `${formatDate(item.startDate)} to ${formatDate(item.endDate)}`,
            String(item.daysRequested ?? "-"),
            badge(item.status || "pending")
        ]));
        renderPagination("#pendingLeavePager", state.pendingLeaves, "gotoPendingLeavePage", "pending leave request");
    } else {
        renderPagination("#pendingLeavePager", null, "gotoPendingLeavePage", "pending leave request");
        renderNotice("#pendingLeaveTable", !state.token
            ? "Sign in to view pending leave requests."
            : state.pendingLeaves === null
                ? "Pending leave status is temporarily unavailable. Check the connection and refresh when the backend returns."
                : "No pending leave requests were returned for this session.");
    }

    renderLeaveRequestForm();
}

function bindLeaveRequestForm() {
    const form = $("#leaveRequestForm");
    const select = $("#leaveRequestTypeSelect");
    const startInput = $("#leaveStartDate");
    const daysInput = $("#leaveDaysRequested");
    const endInput = $("#leaveEndDate");
    const compassionateRelationInput = $("#compassionateRelationSelect");
    const reasonInput = $("#leaveReason");
    const birthProofInput = $("#birthProofFile");

    if (!form || !select) {
        return;
    }

    form.addEventListener("submit", submitLeaveRequest);
    select.addEventListener("change", () => renderLeaveRequestForm());
    startInput?.addEventListener("change", () => {
        setFieldState(startInput, "");
        renderLeaveRequestForm();
    });
    daysInput?.addEventListener("input", () => {
        const requestedDays = Number(daysInput.value);
        if (Number.isFinite(requestedDays) && requestedDays > 0) {
            setFieldState(daysInput, "");
            setFieldState(endInput, "");
        }
        renderLeaveRequestForm();
    });
    compassionateRelationInput?.addEventListener("change", () => {
        setFieldState(compassionateRelationInput, "");
        renderLeaveRequestForm();
    });
    reasonInput?.addEventListener("input", () => {
        if (reasonInput.value.trim().length >= 10) {
            setFieldState(reasonInput, "");
        }
    });
    birthProofInput?.addEventListener("change", () => {
        const validationMessage = validateSupportingDocumentFile(birthProofInput.files?.[0] || null);
        setFieldState(birthProofInput, validationMessage);
        if (!validationMessage && birthProofInput.files?.length) {
            setLeaveRequestStatus(getLocalizedValue({ en: "Supporting proof attached and ready for submission.", fr: "Pièce justificative jointe et prête pour l'envoi.", ar: "تم إرفاق المستند الداعم وهو جاهز للإرسال.", he: "המסמך התומך צורף ומוכן להגשה." }), false);
        }
    });
}

function getLeaveOptions() {
    const unique = new Map();

    (state.leavePolicies?.leaveTypes || []).forEach((item) => {
        const rawCode = normalizeLeaveCode(item.leave_type_code || item.leave_type_name || "");
        const code = LEAVE_API_CODE_ALIASES[rawCode] || rawCode;
        if (!code || unique.has(code)) {
            return;
        }

        unique.set(code, {
            code,
            rawCode,
            label: item.leave_type_name || item.leave_type_code || code || "Leave",
            details: item,
            supported: SUPPORTED_LEAVE_REQUEST_CODES.has(code)
        });
    });

    return [...unique.values()].sort((left, right) => left.label.localeCompare(right.label));
}

function getLeavePolicyRule(leaveOption) {
    if (!leaveOption) {
        return null;
    }

    const candidateCodes = new Set([
        leaveOption.code,
        leaveOption.rawCode,
        leaveOption.label,
        String(leaveOption.label || "").replace(/\bleave\b/gi, "").trim()
    ].map((value) => normalizeLeaveCode(value)).filter(Boolean));

    return (state.leavePolicies?.leavePolicyRules || []).find((item) => {
        const rawRuleCode = normalizeLeaveCode(item.leave_type || "");
        const ruleCode = LEAVE_API_CODE_ALIASES[rawRuleCode] || rawRuleCode;
        return candidateCodes.has(rawRuleCode) || candidateCodes.has(ruleCode);
    }) || null;
}

function getLeavePolicyDayLimit(leaveOption) {
    const rule = getLeavePolicyRule(leaveOption);
    const candidates = [
        rule?.fixed_days,
        rule?.max_duration,
        rule?.max_days,
        leaveOption?.details?.max_days_per_year,
        leaveOption?.details?.max_days_per_month
    ];

    for (const value of candidates) {
        const parsed = Number(value);
        if (Number.isFinite(parsed) && parsed > 0) {
            return Math.floor(parsed);
        }
    }

    return null;
}

function getLeavePolicyDescription(leaveOption) {
    if (!leaveOption) {
        return "Conditions are applied in the ERP.";
    }

    const normalizedCode = normalizeLeaveCode(leaveOption.code || leaveOption.rawCode || leaveOption.label || "");
    if (normalizedCode === "FAMILY_CARE" || normalizedCode === "FAMILY_CARE_LEAVE") {
        return "Family Care Leave is limited to 3 paid days in a year for the care, health, or education needs of an employee's child, spouse, dependent, or parent. It is not cumulative and does not reduce earned leave.";
    }

    return leaveOption.details?.description || "Conditions are applied in the ERP.";
}

function parseDateInputValue(value) {
    if (!value) {
        return null;
    }

    const [year, month, day] = String(value).split("-").map(Number);
    if (![year, month, day].every((part) => Number.isFinite(part))) {
        return null;
    }

    return new Date(year, month - 1, day, 12, 0, 0, 0);
}

function formatDateInputValue(value) {
    const date = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(date.getTime())) {
        return "";
    }

    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, "0");
    const day = String(date.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
}

function getActiveHolidayEntries() {
    return state.holidayCalendar?.holidays || getHolidayCalendarConfig()?.holidays || [];
}

function getWeekendDaySet() {
    const configuredWeekendDays = state.holidayCalendar?.weekendDays || getHolidayCalendarConfig()?.weekendDays || [0, 6];
    return new Set(configuredWeekendDays.map((value) => Number(value)));
}

function isNonWorkingLeaveDate(date, holidayDates, weekendDays) {
    if (!(date instanceof Date) || Number.isNaN(date.getTime())) {
        return false;
    }
    return weekendDays.has(date.getDay()) || holidayDates.has(formatDateInputValue(date));
}

function leaveTypeUsesFixedRequestedDays(leaveTypeCode) {
    return leaveTypeCode === "MATERNITY"
        || leaveTypeCode === "PATERNITY"
        || leaveTypeCode === "MOTHERS_DAY"
        || leaveTypeCode === "FAMILY_CARE";
}

function getFixedRequestedLeaveDays(leaveTypeCode) {
    if (leaveTypeCode === "MATERNITY") {
        return 98;
    }
    if (leaveTypeCode === "PATERNITY") {
        return 10;
    }
    if (leaveTypeCode === "FAMILY_CARE") {
        return FAMILY_CARE_ANNUAL_LIMIT;
    }
    if (leaveTypeCode === "MOTHERS_DAY") {
        return MOTHERS_DAY_MONTHLY_LIMIT;
    }
    return null;
}

function leaveTypeUsesFixedInclusiveDays(leaveTypeCode) {
    return leaveTypeCode === "MATERNITY" || leaveTypeCode === "PATERNITY";
}

function getFixedInclusiveLeaveDays(leaveTypeCode) {
    return leaveTypeUsesFixedInclusiveDays(leaveTypeCode)
        ? getFixedRequestedLeaveDays(leaveTypeCode)
        : null;
}

function getCompassionateLeaveMaxDays(relation) {
    if (relation === "SPOUSE") {
        return 21;
    }
    if (relation === "CHILD" || relation === "PARENT") {
        return 14;
    }
    return 21;
}

function getAccruedLeaveBalanceForType(leaveTypeCode) {
    if (leaveTypeCode === "LOCAL") {
        return Number(state.leaveBalance?.localLeaveBalance ?? 0);
    }
    if (leaveTypeCode === "VACATION") {
        return Number(state.leaveBalance?.vacationLeaveBalance ?? 0);
    }
    return null;
}

function getEmployeeLeaveHistory() {
    return Array.isArray(state.leaveHistory) ? state.leaveHistory : [];
}

function getActiveEmployeeLeaveHistory() {
    return getEmployeeLeaveHistory().filter((item) => {
        const status = normalizeStatusValue(item?.status);
        return status !== "REJECTED" && status !== "CANCELLED";
    });
}

function buildMonthKey(value) {
    return String(value || "").slice(0, 7);
}

function formatMonthKey(monthKey) {
    if (!/^\d{4}-\d{2}$/.test(monthKey)) {
        return "this month";
    }

    const [year, month] = monthKey.split("-").map(Number);
    return new Date(year, month - 1, 1).toLocaleDateString(state.locale || "en-ZM", {
        month: "long",
        year: "numeric"
    });
}

function getLeaveDaysUsedByBalanceType(balanceType) {
    return getEmployeeLeaveHistory()
        .filter((item) => item?.deductedFromAccruedBalance && item?.balanceType === balanceType)
        .reduce((total, item) => total + Number(item?.leaveDaysDeducted || 0), 0);
}

function getLeaveDaysUsedByTypes(leaveTypes) {
    const normalizedTypes = new Set((Array.isArray(leaveTypes) ? leaveTypes : [leaveTypes])
        .map((item) => normalizeLeaveCode(item))
        .filter(Boolean));

    return getActiveEmployeeLeaveHistory()
        .filter((item) => normalizedTypes.has(normalizeLeaveCode(item?.leaveType)))
        .reduce((total, item) => total + Number(item?.daysRequested || 0), 0);
}

function getMothersDayUsageForMonth(monthKey) {
    if (!monthKey) {
        return 0;
    }

    return getActiveEmployeeLeaveHistory()
        .filter((item) => normalizeLeaveCode(item?.leaveType) === "MOTHERS_DAY" && buildMonthKey(item?.startDate) === monthKey)
        .length;
}

function renderLeaveBalanceHistoryPanel(selectedLeaveCode = "", selectedStartDate = "") {
    const summaryRoot = $("#leaveBalanceHistorySummary");
    const noteRoot = $("#leaveBalanceHistoryNote");
    const tableRoot = $("#employeeLeaveHistoryTable");

    if (!summaryRoot || !tableRoot) {
        return;
    }

    if (!state.token || !state.dashboardIdentity?.employeeId) {
        summaryRoot.innerHTML = `
            <div class="notice">
                <strong>Leave balance overview</strong>
                <span>Sign in with an employee-linked account to see accrued, used, and remaining leave by type in one place.</span>
            </div>
        `;
        if (noteRoot) {
            noteRoot.textContent = "";
        }
        tableRoot.innerHTML = "";
        return;
    }

    const history = getEmployeeLeaveHistory();
    const localRemaining = Number(state.leaveBalance?.localLeaveBalance ?? 0);
    const vacationRemaining = Number(state.leaveBalance?.vacationLeaveBalance ?? 0);
    const localUsed = getLeaveDaysUsedByBalanceType("LOCAL_LEAVE");
    const vacationUsed = getLeaveDaysUsedByBalanceType("VACATION_LEAVE");
    const monthKey = buildMonthKey(selectedStartDate) || buildMonthKey(new Date().toISOString().slice(0, 10));
    const mothersDayTakenThisMonth = getMothersDayUsageForMonth(monthKey);
    const mothersDayRemainingThisMonth = Math.max(0, MOTHERS_DAY_MONTHLY_LIMIT - mothersDayTakenThisMonth);

    const summaryCards = [
        {
            title: "Local Leave",
            accrued: `${localRemaining + localUsed} day(s)`,
            used: `${localUsed} day(s)`,
            remaining: `${localRemaining} day(s)`,
            note: "Deducted directly from the employee's accrued local leave balance."
        },
        {
            title: "Vacation Leave",
            accrued: `${vacationRemaining + vacationUsed} day(s)`,
            used: `${vacationUsed} day(s)`,
            remaining: `${vacationRemaining} day(s)`,
            note: "Deducted directly from the employee's accrued vacation leave balance.",
        },
        {
            title: "Maternity Leave",
            accrued: "98 fixed calendar days",
            used: `${getLeaveDaysUsedByTypes(["MATERNITY"])} day(s) logged`,
            remaining: "Condition of service",
            note: "Inclusive of weekends and holidays, available only to female employees, and not deducted from accrued leave days."
        },
        {
            title: "Paternity Leave",
            accrued: "10 fixed calendar days",
            used: `${getLeaveDaysUsedByTypes(["PATERNITY"])} day(s) logged`,
            remaining: "Condition of service",
            note: "Inclusive of weekends and holidays; not deducted from accrued leave days."
        },
        {
            title: "Compassionate Leave",
            accrued: "Policy-based",
            used: `${getLeaveDaysUsedByTypes(["COMPASSIONATE"])} day(s) logged`,
            remaining: "Up to 21 / 14 days per case",
            note: "Spouse up to 21 days; child or parent up to 14 days."
        },
        {
            title: "Family Care Leave",
            accrued: `${FAMILY_CARE_ANNUAL_LIMIT} paid day(s) in a year`,
            used: `${getLeaveDaysUsedByTypes(["FAMILY_CARE"])} day(s) logged`,
            remaining: `${Math.max(0, FAMILY_CARE_ANNUAL_LIMIT - getLeaveDaysUsedByTypes(["FAMILY_CARE"]))} day(s) remaining before annual reset`,
            note: "Condition of service: 3 days in a year, not cumulative, and not deducted from earned leave."
        },
        {
            title: "Mother's Day",
            accrued: `${MOTHERS_DAY_MONTHLY_LIMIT} day per month`,
            used: `${mothersDayTakenThisMonth} request(s) in ${formatMonthKey(monthKey)}`,
            remaining: `${mothersDayRemainingThisMonth} of ${MOTHERS_DAY_MONTHLY_LIMIT} day left`,
            note: "Condition of service for female employees only; once per month, supervisor approval, HR notification only."
        }
    ];

    summaryRoot.innerHTML = summaryCards.map((item) => `
        <article class="list-card detail-card">
            <strong>${escapeHtml(item.title)}</strong>
            <p>${escapeHtml(`Accrued: ${item.accrued}`)}</p>
            <p>${escapeHtml(`Used: ${item.used}`)}</p>
            <p>${escapeHtml(`Remaining: ${item.remaining}`)}</p>
            <small class="table-note">${escapeHtml(item.note)}</small>
        </article>
    `).join("");

    if (noteRoot) {
        noteRoot.textContent = selectedLeaveCode === "MOTHERS_DAY"
            ? `Mother's Day availability for ${formatMonthKey(monthKey)}: ${mothersDayRemainingThisMonth} of ${MOTHERS_DAY_MONTHLY_LIMIT} day remaining. It is for female employees only, approved by the supervisor, and HR is only notified.`
            : "Recent leave requests appear below so employees can track dates, status, and balance impact in one place.";
    }

    if (history.length) {
        renderTable("#employeeLeaveHistoryTable", ["Type", "Dates", "Days", "Balance Effect", "Status"], history.slice(0, 8).map((item) => [
            escapeHtml(item?.compassionateRelation ? `${item.leaveType} (${item.compassionateRelation})` : (item?.leaveType || "-")),
            escapeHtml(`${formatDate(item?.startDate)} to ${formatDate(item?.endDate)}`),
            escapeHtml(String(item?.daysRequested ?? "-")),
            item?.deductedFromAccruedBalance
                ? escapeHtml(`-${item?.leaveDaysDeducted || 0} day(s) from ${item?.balanceType || "accrued balance"}`)
                : badge(item?.balanceType === "CONDITION_OF_SERVICE" ? "Condition of service" : "No accrued deduction"),
            badge(item?.status || "PENDING", normalizeStatusValue(item?.status) !== "APPROVED")
        ]));
    } else {
        renderNotice("#employeeLeaveHistoryTable", "No leave requests have been submitted yet for this employee.");
    }
}

async function fetchLeaveCalculation(employeeId, leaveTypeCode, startDate, requestedDays, compassionateRelation) {
    if (!USE_LEAVE_CALCULATION_API || !state.token || !employeeId || !leaveTypeCode || !startDate) {
        return null;
    }
    try {
        const params = new URLSearchParams({
            employeeId: String(employeeId),
            leaveType: leaveTypeCode,
            startDate: startDate
        });
        if (requestedDays && Number.isFinite(requestedDays) && requestedDays > 0) {
            params.set("requestedDays", String(requestedDays));
        }
        if (compassionateRelation) {
            params.set("compassionateRelation", compassionateRelation);
        }
        const result = await fetchJson(`leaves/calculate?${params.toString()}`, {
            cacheTtlMs: 5000
        }, true);
        return result;
    } catch (err) {
        console.warn("[LeaveCalcAPI] Backend calculation failed, falling back to local:", err);
        return null;
    }
}

function calculateLeaveSchedule(startDateValue, daysOffValue, leaveTypeCode, compassionateRelation) {
    const requestedDays = Math.floor(Number(daysOffValue));
    if (!startDateValue || !Number.isFinite(requestedDays) || requestedDays <= 0) {
        return null;
    }

    const requestedStart = parseDateInputValue(startDateValue);
    if (!requestedStart) {
        return null;
    }

    if (leaveTypeUsesFixedInclusiveDays(leaveTypeCode)) {
        const fixedDays = getFixedInclusiveLeaveDays(leaveTypeCode);
        const endDate = new Date(requestedStart.getTime());
        endDate.setDate(endDate.getDate() + fixedDays - 1);
        const returnToWorkDate = new Date(requestedStart.getTime());
        returnToWorkDate.setDate(returnToWorkDate.getDate() + fixedDays);

        return {
            requestedDays: fixedDays,
            adjustedStartDate: formatDateInputValue(requestedStart),
            endDate: formatDateInputValue(endDate),
            returnToWorkDate: formatDateInputValue(returnToWorkDate),
            weekendDaysSkipped: 0,
            publicHolidaysSkipped: 0,
            startAdjusted: false,
            calculationMode: "FIXED_INCLUSIVE"
        };
    }

    if (leaveTypeCode === "COMPASSIONATE") {
        const maxDays = getCompassionateLeaveMaxDays(compassionateRelation);
        if (requestedDays > maxDays) {
            return null;
        }

        const endDate = new Date(requestedStart.getTime());
        endDate.setDate(endDate.getDate() + requestedDays - 1);
        const returnToWorkDate = new Date(requestedStart.getTime());
        returnToWorkDate.setDate(returnToWorkDate.getDate() + requestedDays);

        return {
            requestedDays,
            adjustedStartDate: formatDateInputValue(requestedStart),
            endDate: formatDateInputValue(endDate),
            returnToWorkDate: formatDateInputValue(returnToWorkDate),
            weekendDaysSkipped: 0,
            publicHolidaysSkipped: 0,
            startAdjusted: false,
            calculationMode: "INCLUSIVE_CALENDAR_DAYS"
        };
    }

    const holidayDates = new Set(getActiveHolidayEntries().map((holiday) => String(holiday.date || "").slice(0, 10)).filter(Boolean));
    const weekendDays = getWeekendDaySet();

    let current = new Date(requestedStart.getTime());
    let firstLeaveDate = null;
    let lastLeaveDate = null;
    let remaining = requestedDays;
    let weekendDaysSkipped = 0;
    let publicHolidaysSkipped = 0;

    while (remaining > 0) {
        const isWeekend = weekendDays.has(current.getDay());
        const isHoliday = holidayDates.has(formatDateInputValue(current));

        if (!isWeekend && !isHoliday) {
            if (!firstLeaveDate) {
                firstLeaveDate = new Date(current.getTime());
            }
            lastLeaveDate = new Date(current.getTime());
            remaining -= 1;
        } else {
            if (isWeekend) {
                weekendDaysSkipped += 1;
            }
            if (isHoliday) {
                publicHolidaysSkipped += 1;
            }
        }

        if (remaining > 0) {
            current.setDate(current.getDate() + 1);
        }
    }

    if (!firstLeaveDate || !lastLeaveDate) {
        return null;
    }

    const returnToWork = new Date(lastLeaveDate.getTime());
    returnToWork.setDate(returnToWork.getDate() + 1);
    while (isNonWorkingLeaveDate(returnToWork, holidayDates, weekendDays)) {
        if (weekendDays.has(returnToWork.getDay())) {
            weekendDaysSkipped += 1;
        }
        if (holidayDates.has(formatDateInputValue(returnToWork))) {
            publicHolidaysSkipped += 1;
        }
        returnToWork.setDate(returnToWork.getDate() + 1);
    }

    return {
        requestedDays,
        adjustedStartDate: formatDateInputValue(firstLeaveDate),
        endDate: formatDateInputValue(lastLeaveDate),
        returnToWorkDate: formatDateInputValue(returnToWork),
        weekendDaysSkipped,
        publicHolidaysSkipped,
        startAdjusted: formatDateInputValue(firstLeaveDate) !== startDateValue,
        calculationMode: "WORKING_DAYS_ONLY"
    };
}

async function renderLeaveRequestForm() {
    const form = $("#leaveRequestForm");
    const select = $("#leaveRequestTypeSelect");
    const detailRoot = $("#leaveRequestDetails");
    const breakdownRoot = $("#leaveCalculationBreakdown");
    const balancePreviewRoot = $("#leaveBalancePreview");
    const workflowRoot = $("#leaveWorkflowGuide");
    const startInput = $("#leaveStartDate");
    const daysInput = $("#leaveDaysRequested");
    const endInput = $("#leaveEndDate");
    const compassionateRelationField = $("#compassionateRelationField");
    const compassionateRelationInput = $("#compassionateRelationSelect");
    const reasonInput = $("#leaveReason");
    const birthProofField = $("#birthProofField");
    const birthProofInput = $("#birthProofFile");
    const submitButton = form?.querySelector('button[type="submit"]');

    if (!form || !select || !detailRoot || !startInput || !daysInput || !endInput || !reasonInput || !submitButton) {
        return;
    }

    const leaveOptions = getLeaveOptions();
    const selectedValue = leaveOptions.some((item) => item.code === select.value)
        ? select.value
        : (leaveOptions[0]?.code || "");

    select.innerHTML = leaveOptions.length
        ? leaveOptions.map((item) => `
            <option value="${escapeHtml(item.code)}">${escapeHtml(item.label)}</option>
        `).join("")
        : '<option value="">No leave types configured</option>';

    if (selectedValue) {
        select.value = selectedValue;
    }

    const selected = leaveOptions.find((item) => item.code === select.value) || leaveOptions[0] || null;
    const calculationEnabled = Boolean(selected);
    const employeeGender = String(state.dashboardIdentity?.gender || "").trim().toLowerCase();
    const genderEligibleForSelectedLeave = !selected || !["MOTHERS_DAY", "MATERNITY"].includes(selected.code) || employeeGender === "female";
    const submissionEnabled = Boolean(state.token && state.dashboardIdentity?.employeeId && selected && genderEligibleForSelectedLeave);
    const requiresBirthProof = leaveTypeRequiresBirthProof(selected?.code || selected?.rawCode);
    const requiresCompassionateRelation = selected?.code === "COMPASSIONATE";
    const compassionateRelation = compassionateRelationInput?.value || "";
    const fixedRequestedDays = getFixedRequestedLeaveDays(selected?.code || "");
    const fixedInclusiveDays = getFixedInclusiveLeaveDays(selected?.code || "");
    const approvalRoute = selected?.code === "MOTHERS_DAY"
        ? getLocalizedValue({ en: "Immediate supervisor only (HR notified)", fr: "Supérieur immédiat uniquement (RH notifiée)", ar: "المشرف المباشر فقط (مع إشعار الموارد البشرية)", he: "ממונה ישיר בלבד (משאבי אנוש מקבלים הודעה)" })
        : selected?.details?.requires_approval
            ? getLocalizedValue({ en: "Supervisor / HR approver", fr: "Superviseur / RH", ar: "المشرف / الموارد البشرية", he: "ממונה / משאבי אנוש" })
            : getLocalizedValue({ en: "Automatic policy check", fr: "Contrôle automatique", ar: "فحص سياسة تلقائي", he: "בדיקת מדיניות אוטומטית" });
    const statusFlow = selected?.code === "MOTHERS_DAY"
        ? getLocalizedValue({ en: "Submitted → Supervisor approval → HR notified → Recorded", fr: "Soumis → Validation du superviseur → RH notifiée → Enregistré", ar: "تم الإرسال ← موافقة المشرف ← إشعار الموارد البشرية ← تم التسجيل", he: "הוגש ← אישור ממונה ← משאבי אנוש קיבלו הודעה ← נרשם" })
        : selected?.details?.requires_approval
            ? getLocalizedValue({ en: "Submitted → Pending review → Approved or rejected", fr: "Soumis → En examen → Approuvé ou rejeté", ar: "تم الإرسال ← قيد المراجعة ← معتمد أو مرفوض", he: "הוגש ← ממתין לבדיקה ← אושר או נדחה" })
            : getLocalizedValue({ en: "Submitted → Policy check → Recorded", fr: "Soumis → Contrôle → Enregistré", ar: "تم الإرسال ← فحص السياسة ← تم التسجيل", he: "הוגש ← בדיקת מדיניות ← נרשם" });
    const policyRule = getLeavePolicyRule(selected);
    const policyDayLimit = getLeavePolicyDayLimit(selected);
    const requestedDays = leaveTypeUsesFixedRequestedDays(selected?.code || "")
        ? fixedRequestedDays
        : Math.floor(Number(daysInput.value || 0));
    let schedule = null;
    if (USE_LEAVE_CALCULATION_API && state.selectedEmployeeId) {
        const apiResult = await fetchLeaveCalculation(
            state.selectedEmployeeId, selected?.code || "", startInput.value,
            requestedDays, compassionateRelation);
        if (apiResult) {
            schedule = {
                adjustedStartDate: apiResult.startDate,
                endDate: apiResult.leaveEndDate,
                resumptionDate: apiResult.resumeDutiesDate,
                requestedDays: apiResult.chargeableDays,
                weekendDaysSkipped: apiResult.weekendDaysSkipped || 0,
                publicHolidaysSkipped: apiResult.publicHolidaysSkipped || 0,
                calculationMode: apiResult.calculationMode
            };
        }
    }
    if (!schedule) {
        schedule = calculateLeaveSchedule(startInput.value, requestedDays, selected?.code || "", compassionateRelation);
    }
    const hasSchedule = Boolean(schedule);
    const currentAccruedBalance = USE_LEAVE_CALCULATION_API && schedule?._apiBalance != null
        ? schedule._apiBalance
        : getAccruedLeaveBalanceForType(selected?.code || "");
    const projectedRemainingBalance = Number.isFinite(currentAccruedBalance) && hasSchedule
        ? currentAccruedBalance - schedule.requestedDays
        : null;
    const selectedMonthKey = buildMonthKey(schedule?.adjustedStartDate || startInput.value || "");
    const mothersDayUsageForSelectedMonth = selected?.code === "MOTHERS_DAY"
        ? getMothersDayUsageForMonth(selectedMonthKey)
        : 0;
    const mothersDayRemainingForSelectedMonth = selected?.code === "MOTHERS_DAY"
        ? Math.max(0, MOTHERS_DAY_MONTHLY_LIMIT - mothersDayUsageForSelectedMonth)
        : MOTHERS_DAY_MONTHLY_LIMIT;
    const mothersDayNoticeMessage = selected?.code === "MOTHERS_DAY"
        ? (mothersDayRemainingForSelectedMonth > 0
            ? `Mother's Day is limited to ${MOTHERS_DAY_MONTHLY_LIMIT} working day in ${formatMonthKey(selectedMonthKey)}, is not cumulative, is available only to female employees, and is approved by the employee's supervisor while HR is notified.`
            : `Mother's Day has already been used for ${formatMonthKey(selectedMonthKey)} and does not accumulate into another month.`)
        : "";
    const mothersDayGenderMessage = selected?.code === "MOTHERS_DAY" && employeeGender !== "female"
        ? "Mother's Day leave is available only to female employees. It is approved by the employee's supervisor and HR is only notified."
        : "";
    const maternityGenderMessage = selected?.code === "MATERNITY" && employeeGender !== "female"
        ? "Maternity leave is available only to female employees."
        : "";
    const policyLimitMessage = policyDayLimit && requestedDays > policyDayLimit
        ? getLocalizedValue({
            en: `${selected?.label || "This leave type"} is configured for up to ${policyDayLimit} day(s) in the ERP rules.`,
            fr: `${selected?.label || "Ce type de congé"} est configuré pour un maximum de ${policyDayLimit} jour(s).`,
            ar: `${selected?.label || "نوع الإجازة هذا"} مضبوط بحد أقصى ${policyDayLimit} يوم/أيام في قواعد النظام.`,
            he: `${selected?.label || "סוג חופשה זה"} מוגדר לעד ${policyDayLimit} ימים בכללי המערכת.`
        })
        : "";

    select.disabled = !leaveOptions.length;
    [startInput, daysInput, endInput, reasonInput].forEach((element) => {
        element.disabled = !calculationEnabled;
    });
    if (compassionateRelationInput) {
        compassionateRelationInput.disabled = !calculationEnabled || !requiresCompassionateRelation;
    }
    submitButton.disabled = !submissionEnabled;

    startInput.required = true;
    daysInput.required = true;
    daysInput.min = "1";
    daysInput.step = "1";
    daysInput.readOnly = leaveTypeUsesFixedRequestedDays(selected?.code || "");
    if (leaveTypeUsesFixedRequestedDays(selected?.code || "") && fixedRequestedDays) {
        daysInput.value = String(fixedRequestedDays);
    }
    if (policyDayLimit) {
        daysInput.max = String(policyDayLimit);
    } else if (requiresCompassionateRelation && compassionateRelation) {
        daysInput.max = String(getCompassionateLeaveMaxDays(compassionateRelation));
    } else {
        daysInput.removeAttribute("max");
    }
    endInput.required = true;
    endInput.readOnly = true;
    reasonInput.required = true;
    reasonInput.minLength = 10;
    reasonInput.maxLength = 500;

    if (birthProofField && birthProofInput) {
        birthProofField.classList.toggle("is-hidden", !requiresBirthProof);
        birthProofField.hidden = !requiresBirthProof;
        birthProofInput.disabled = !submissionEnabled || !requiresBirthProof;
        birthProofInput.required = requiresBirthProof;
        if (!requiresBirthProof) {
            birthProofInput.value = "";
            setFieldState(birthProofInput, "");
        }
    }

    if (compassionateRelationField && compassionateRelationInput) {
        compassionateRelationField.classList.toggle("is-hidden", !requiresCompassionateRelation);
        compassionateRelationField.hidden = !requiresCompassionateRelation;
        compassionateRelationInput.required = requiresCompassionateRelation;
        if (!requiresCompassionateRelation) {
            compassionateRelationInput.value = "";
            setFieldState(compassionateRelationInput, "");
        }
    }

    startInput.min = new Date().toISOString().split("T")[0];
    endInput.min = startInput.value || startInput.min;
    endInput.value = hasSchedule ? schedule.endDate : "";
    renderLeaveBalanceHistoryPanel(selected?.code || "", schedule?.adjustedStartDate || startInput.value || "");
    if (policyLimitMessage) {
        setFieldState(daysInput, policyLimitMessage);
    }

    if (!selected) {
        detailRoot.innerHTML = `<div class="notice"><strong>${escapeHtml(getLocalizedValue({ en: "Leave options", fr: "Options de congé", ar: "خيارات الإجازة", he: "אפשרויות חופשה" }))}</strong><span>${escapeHtml(getLocalizedValue({ en: "No leave types were returned from the ERP table.", fr: "Aucun type de congé n'a été renvoyé par la table ERP.", ar: "لم يتم إرجاع أنواع إجازات من جدول ERP.", he: "לא הוחזרו סוגי חופשה מטבלת ה-ERP." }))}</span></div>`;
        if (breakdownRoot) {
            breakdownRoot.innerHTML = `<strong>${escapeHtml(getLocalizedValue({ en: "Calculation breakdown", fr: "Détails du calcul", ar: "تفاصيل الحساب", he: "פירוט חישוב" }))}</strong><span>${escapeHtml(getLocalizedValue({ en: "Select a leave type, start date, and days off to see the automatic return-to-work calculation.", fr: "Sélectionnez un type de congé, une date de début et des jours demandés pour voir le calcul automatique.", ar: "اختر نوع الإجازة وتاريخ البدء وعدد الأيام لعرض حساب العودة للعمل تلقائيًا.", he: "בחרו סוג חופשה, תאריך התחלה ומספר ימים כדי לראות את חישוב החזרה לעבודה." }))}</span>`;
        }
        if (balancePreviewRoot) {
            balancePreviewRoot.innerHTML = "";
        }
        if (workflowRoot) {
            workflowRoot.innerHTML = "";
        }
        setLeaveRequestStatus(getLocalizedValue({ en: "Leave options will appear here once the ERP leave types load.", fr: "Les options de congé apparaîtront ici une fois les types chargés.", ar: "ستظهر خيارات الإجازة هنا بعد تحميل الأنواع.", he: "אפשרויות החופשה יוצגו כאן לאחר טעינת הסוגים." }), false);
        return;
    }

    if (breakdownRoot) {
        if (hasSchedule) {
            const breakdownItems = [
                getLocalizedValue({ en: `Rule source: ${policyRule?.division || "General leave policy"}`, fr: `Source de règle : ${policyRule?.division || "Politique générale"}`, ar: `مصدر القاعدة: ${policyRule?.division || "سياسة عامة"}`, he: `מקור כלל: ${policyRule?.division || "מדיניות כללית"}` }),
                getLocalizedValue({ en: `Requested days off: ${schedule.requestedDays}`, fr: `Jours demandés : ${schedule.requestedDays}`, ar: `الأيام المطلوبة: ${schedule.requestedDays}`, he: `ימים מבוקשים: ${schedule.requestedDays}` }),
                getLocalizedValue({ en: `Leave starts: ${formatDate(schedule.adjustedStartDate)} | Leave ends: ${formatDate(schedule.endDate)}`, fr: `Début: ${formatDate(schedule.adjustedStartDate)} | Fin: ${formatDate(schedule.endDate)}`, ar: `بداية الإجازة: ${formatDate(schedule.adjustedStartDate)} | نهاية الإجازة: ${formatDate(schedule.endDate)}`, he: `תחילת חופשה: ${formatDate(schedule.adjustedStartDate)} | סוף חופשה: ${formatDate(schedule.endDate)}` }),
                schedule.calculationMode === "WORKING_DAYS_ONLY"
                    ? getLocalizedValue({ en: `Skipped ${schedule.weekendDaysSkipped} weekend day(s) and ${schedule.publicHolidaysSkipped} public holiday(s)`, fr: `${schedule.weekendDaysSkipped} week-end(s) et ${schedule.publicHolidaysSkipped} jour(s) férié(s) exclus`, ar: `تم استبعاد ${schedule.weekendDaysSkipped} من عطلة نهاية الأسبوع و${schedule.publicHolidaysSkipped} عطلة رسمية`, he: `דולגו ${schedule.weekendDaysSkipped} ימי סוף שבוע ו-${schedule.publicHolidaysSkipped} חגים` })
                    : getLocalizedValue({ en: "This leave runs on inclusive calendar days and is not extended for weekends or public holidays.", fr: "Ce congé se calcule en jours calendaires inclusifs sans prolongation pour les week-ends ou jours fériés.", ar: "تُحسب هذه الإجازة بأيام تقويمية شاملة دون تمديد لعطلات نهاية الأسبوع أو العطل الرسمية.", he: "חופשה זו מחושבת בימים קלנדריים רצופים ללא הארכה עבור סופי שבוע או חגים." }),
                getLocalizedValue({ en: `Report back to work: ${formatDate(schedule.returnToWorkDate)}`, fr: `Date de reprise : ${formatDate(schedule.returnToWorkDate)}`, ar: `تاريخ العودة للعمل: ${formatDate(schedule.returnToWorkDate)}`, he: `תאריך חזרה לעבודה: ${formatDate(schedule.returnToWorkDate)}` })
            ];

            breakdownRoot.innerHTML = `
                <strong>${escapeHtml(getLocalizedValue({ en: "Calculation breakdown", fr: "Détails du calcul", ar: "تفاصيل الحساب", he: "פירוט חישוב" }))}</strong>
                <span>${escapeHtml(getLocalizedValue({ en: "The ERP used leave policy rules plus weekends and holidays to compute these dates.", fr: "L'ERP a appliqué les règles de congé, les week-ends et les jours fériés.", ar: "استخدم النظام قواعد الإجازة مع عطلات نهاية الأسبوع والعطل الرسمية لحساب هذه التواريخ.", he: "המערכת השתמשה בכללי חופשה, סופי שבוע וחגים לחישוב התאריכים." }))}</span>
                <ul>
                    ${breakdownItems.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}
                </ul>
            `;
        } else {
            breakdownRoot.innerHTML = `
                <strong>${escapeHtml(getLocalizedValue({ en: "Calculation breakdown", fr: "Détails du calcul", ar: "تفاصيل الحساب", he: "פירוט חישוב" }))}</strong>
                <span>${escapeHtml(getLocalizedValue({ en: "Enter a start date and days off to calculate leave end and return-to-work dates automatically.", fr: "Saisissez une date de début et des jours demandés pour calculer automatiquement la reprise.", ar: "أدخل تاريخ البدء وعدد أيام الإجازة لحساب نهاية الإجازة وموعد العودة تلقائيًا.", he: "הזינו תאריך התחלה ומספר ימי חופשה לחישוב אוטומטי של סוף החופשה ותאריך החזרה לעבודה." }))}</span>
            `;
        }
    }

    if (balancePreviewRoot) {
        if (Number.isFinite(currentAccruedBalance)) {
            balancePreviewRoot.innerHTML = `
                <strong>${escapeHtml(getLocalizedValue({ en: "Accrued balance preview", fr: "Aperçu du solde acquis", ar: "معاينة الرصيد المتراكم", he: "תצוגה מקדימה של יתרה נצברת" }))}</strong>
                <span>${escapeHtml(hasSchedule
                    ? getLocalizedValue({ en: `Current balance: ${currentAccruedBalance} day(s). This request would leave ${projectedRemainingBalance} day(s) remaining.`, fr: `Solde actuel : ${currentAccruedBalance} jour(s). Cette demande laisserait ${projectedRemainingBalance} jour(s).`, ar: `الرصيد الحالي: ${currentAccruedBalance} يوم/أيام. سيبقي هذا الطلب ${projectedRemainingBalance} يوم/أيام.`, he: `יתרה נוכחית: ${currentAccruedBalance} ימים. לאחר בקשה זו יישארו ${projectedRemainingBalance} ימים.` })
                    : getLocalizedValue({ en: `Current balance available: ${currentAccruedBalance} day(s).`, fr: `Solde disponible actuel : ${currentAccruedBalance} jour(s).`, ar: `الرصيد المتاح حالياً: ${currentAccruedBalance} يوم/أيام.`, he: `יתרה זמינה נוכחית: ${currentAccruedBalance} ימים.` }))}</span>
            `;
        } else if (selected?.code === "MOTHERS_DAY") {
            balancePreviewRoot.innerHTML = `
                <strong>${escapeHtml(getLocalizedValue({ en: "Monthly leave preview", fr: "Aperçu mensuel", ar: "معاينة شهرية", he: "תצוגה חודשית" }))}</strong>
                <span>${escapeHtml(mothersDayGenderMessage || mothersDayNoticeMessage || "Mother's Day is a one-day monthly condition-of-service leave for female employees only; the supervisor approves it and HR is notified.")}</span>
            `;
        } else if (selected?.code === "MATERNITY" && maternityGenderMessage) {
            balancePreviewRoot.innerHTML = `
                <strong>${escapeHtml(getLocalizedValue({ en: "Eligibility note", fr: "Note d'éligibilité", ar: "ملاحظة الأهلية", he: "הערת זכאות" }))}</strong>
                <span>${escapeHtml(maternityGenderMessage)}</span>
            `;
        } else if (selected) {
            balancePreviewRoot.innerHTML = `
                <strong>${escapeHtml(getLocalizedValue({ en: "Policy note", fr: "Note de politique", ar: "ملاحظة السياسة", he: "הערת מדיניות" }))}</strong>
                <span>${escapeHtml(getLeavePolicyDescription(selected))}</span>
            `;
        } else {
            balancePreviewRoot.innerHTML = "";
        }
    }

    detailRoot.innerHTML = [
        { label: getLocalizedValue({ en: "Code", fr: "Code", ar: "الرمز", he: "קוד" }), value: selected.code },
        { label: getLocalizedValue({ en: "Paid", fr: "Payé", ar: "مدفوع", he: "בתשלום" }), value: selected.details.is_paid ? getLocalizedValue({ en: "Yes", fr: "Oui", ar: "نعم", he: "כן" }) : getLocalizedValue({ en: "No", fr: "Non", ar: "لا", he: "לא" }) },
        { label: getLocalizedValue({ en: "Approval", fr: "Approbation", ar: "الموافقة", he: "אישור" }), value: selected.details.requires_approval ? getLocalizedValue({ en: "Required", fr: "Requise", ar: "مطلوبة", he: "נדרש" }) : getLocalizedValue({ en: "Optional", fr: "Optionnelle", ar: "اختيارية", he: "אופציונלי" }) },
        { label: getLocalizedValue({ en: "Policy rule", fr: "Règle", ar: "القاعدة", he: "כלל מדיניות" }), value: policyRule?.division || getLocalizedValue({ en: "General leave rule", fr: "Règle générale", ar: "قاعدة عامة", he: "כלל כללי" }) },
        { label: getLocalizedValue({ en: "Days off requested", fr: "Jours demandés", ar: "الأيام المطلوبة", he: "ימים מבוקשים" }), value: hasSchedule ? schedule.requestedDays : (policyDayLimit ? getLocalizedValue({ en: `Up to ${policyDayLimit}`, fr: `Jusqu'à ${policyDayLimit}`, ar: `حتى ${policyDayLimit}`, he: `עד ${policyDayLimit}` }) : getLocalizedValue({ en: "Enter days off", fr: "Saisir les jours", ar: "أدخل عدد الأيام", he: "הזינו מספר ימים" })) },
        { label: getLocalizedValue({ en: "Accrued balance impact", fr: "Impact sur le solde acquis", ar: "أثر الرصيد المتراكم", he: "השפעה על היתרה הנצברת" }), value: Number.isFinite(currentAccruedBalance) ? getLocalizedValue({ en: `Current ${currentAccruedBalance} day(s) | Remaining ${projectedRemainingBalance ?? currentAccruedBalance}`, fr: `Actuel ${currentAccruedBalance} jour(s) | Reste ${projectedRemainingBalance ?? currentAccruedBalance}`, ar: `الحالي ${currentAccruedBalance} يوم/أيام | المتبقي ${projectedRemainingBalance ?? currentAccruedBalance}`, he: `נוכחי ${currentAccruedBalance} ימים | נותר ${projectedRemainingBalance ?? currentAccruedBalance}` }) : getLocalizedValue({ en: "Condition of service - no accrued deduction", fr: "Condition de service - pas de déduction", ar: "شرط خدمة - دون خصم", he: "תנאי שירות - ללא ניכוי" }) },
        { label: getLocalizedValue({ en: "Last day of leave", fr: "Dernier jour", ar: "آخر يوم إجازة", he: "יום החופשה האחרון" }), value: hasSchedule ? formatDate(schedule.endDate) : getLocalizedValue({ en: "Calculated automatically", fr: "Calcul automatique", ar: "يُحسب تلقائياً", he: "מחושב אוטומטית" }) },
        { label: getLocalizedValue({ en: "Back at work", fr: "Retour au travail", ar: "العودة للعمل", he: "חזרה לעבודה" }), value: hasSchedule ? formatDate(schedule.returnToWorkDate) : getLocalizedValue({ en: "Calculated automatically", fr: "Calcul automatique", ar: "يُحسب تلقائياً", he: "מחושב אוטומטית" }) },
        { label: getLocalizedValue({ en: "Calendar adjustment", fr: "Ajustement calendrier", ar: "تعديل التقويم", he: "התאמת לוח שנה" }), value: hasSchedule ? getLocalizedValue({ en: `${schedule.weekendDaysSkipped} weekend day(s) and ${schedule.publicHolidaysSkipped} holiday(s) skipped`, fr: `${schedule.weekendDaysSkipped} week-end(s) et ${schedule.publicHolidaysSkipped} jour(s) férié(s) ignorés`, ar: `تم تجاوز ${schedule.weekendDaysSkipped} من أيام عطلة نهاية الأسبوع و${schedule.publicHolidaysSkipped} من العطل الرسمية`, he: `דולגו ${schedule.weekendDaysSkipped} ימי סוף שבוע ו-${schedule.publicHolidaysSkipped} חגים` }) : getLocalizedValue({ en: "Weekends and public holidays are excluded from the count", fr: "Les week-ends et jours fériés sont exclus", ar: "تُستبعد عطلات نهاية الأسبوع والعطل الرسمية", he: "סופי שבוע וחגים אינם נספרים" }) },
        { label: getLocalizedValue({ en: "Monthly limit", fr: "Limite mensuelle", ar: "الحد الشهري", he: "מגבלה חודשית" }), value: selected.code === "MOTHERS_DAY" ? `${mothersDayRemainingForSelectedMonth} of ${MOTHERS_DAY_MONTHLY_LIMIT} day left in ${formatMonthKey(selectedMonthKey)}` : (selected.details.max_days_per_month ?? "—") },
        { label: getLocalizedValue({ en: "Annual limit", fr: "Limite annuelle", ar: "الحد السنوي", he: "מגבלה שנתית" }), value: policyDayLimit ?? selected.details.max_days_per_year ?? "—" },
        { label: getLocalizedValue({ en: "Policy notes", fr: "Notes de politique", ar: "ملاحظات السياسة", he: "הערות מדיניות" }), value: getLeavePolicyDescription(selected) },
        { label: getLocalizedValue({ en: "Required proof", fr: "Justificatif requis", ar: "المستند المطلوب", he: "מסמך נדרש" }), value: requiresBirthProof ? getLocalizedValue({ en: "Birth record / certificate upload required", fr: "Acte / certificat de naissance requis", ar: "يلزم رفع شهادة / سجل الميلاد", he: "נדרש להעלות תעודת/רישום לידה" }) : getLocalizedValue({ en: "No supporting birth proof required", fr: "Aucune preuve de naissance requise", ar: "لا يلزم مستند ميلاد", he: "לא נדרש מסמך לידה" }) },
        { label: getLocalizedValue({ en: "Next approver", fr: "Prochain approbateur", ar: "الموافق التالي", he: "מאשר/ת הבא/ה" }), value: approvalRoute },
        { label: getLocalizedValue({ en: "Status tracking", fr: "Suivi du statut", ar: "تتبع الحالة", he: "מעקב סטטוס" }), value: statusFlow }
    ].map((item) => `
        <article class="list-card detail-card">
            <strong>${escapeHtml(item.label)}</strong>
            <p>${escapeHtml(String(item.value))}</p>
        </article>
    `).join("");

    if (workflowRoot) {
        workflowRoot.innerHTML = [
            {
                title: getLocalizedValue({ en: "1. Calculate", fr: "1. Calculer", ar: "1. احسب", he: "1. חשבו" }),
                note: getLocalizedValue({ en: "Choose the leave type, first day away, and the number of leave days. The ERP calculates the last day away and your return-to-work date automatically.", fr: "Choisissez le type, le premier jour d'absence et le nombre de jours. L'ERP calcule automatiquement la date de reprise.", ar: "اختر نوع الإجازة وأول يوم غياب وعدد الأيام. سيحسب النظام تلقائياً آخر يوم إجازة وموعد العودة للعمل.", he: "בחרו את סוג החופשה, יום ההיעדרות הראשון ומספר הימים. המערכת מחשבת אוטומטית את יום החופשה האחרון ואת תאריך החזרה לעבודה." })
            },
            {
                title: getLocalizedValue({ en: "2. Review", fr: "2. Examen", ar: "2. المراجعة", he: "2. בדיקה" }),
                note: requiresBirthProof
                    ? getLocalizedValue({ en: "Attach a PDF/JPG/PNG certificate so the approving officer can validate the request.", fr: "Joignez un certificat PDF/JPG/PNG pour validation.", ar: "أرفق شهادة PDF/JPG/PNG ليتمكن المسؤول من التحقق من الطلب.", he: "צרפו מסמך PDF/JPG/PNG כדי שהמאשר יוכל לאמת את הבקשה." })
                    : getLocalizedValue({ en: `The request moves to ${approvalRoute} once submitted.`, fr: `La demande est transmise à ${approvalRoute} après l'envoi.`, ar: `ينتقل الطلب إلى ${approvalRoute} بعد الإرسال.`, he: `לאחר ההגשה הבקשה עוברת ל-${approvalRoute}.` })
            },
            {
                title: getLocalizedValue({ en: "3. Track outcome", fr: "3. Suivre le résultat", ar: "3. متابعة النتيجة", he: "3. מעקב אחר התוצאה" }),
                note: getLocalizedValue({ en: "Use the Pending Requests register above to monitor whether the leave is still pending or has been actioned.", fr: "Utilisez le registre ci-dessus pour voir si la demande est en attente ou traitée.", ar: "استخدم سجل الطلبات المعلقة أعلاه لمعرفة ما إذا كانت الإجازة ما تزال قيد الانتظار أو تم البت فيها.", he: "השתמשו ברשימת הבקשות הממתינות לעיל כדי לבדוק אם החופשה עדיין ממתינה או כבר טופלה." })
            }
        ].map((item) => `
            <article class="timeline-card">
                <strong>${escapeHtml(item.title)}</strong>
                <p>${escapeHtml(item.note)}</p>
            </article>
        `).join("");
    }

    const fileValidationMessage = validateSupportingDocumentFile(birthProofInput?.files?.[0] || null);
    if (birthProofInput && fileValidationMessage) {
        setFieldState(birthProofInput, fileValidationMessage);
    }

    if (!selected.supported) {
        setLeaveRequestStatus(getLocalizedValue({ en: `${selected.label} is listed in the ERP table and visible in the dropdown, but the current API does not yet accept it.`, fr: `${selected.label} est visible dans la liste, mais l'API actuelle ne l'accepte pas encore.`, ar: `${selected.label} يظهر في القائمة، لكن الواجهة الحالية لا تقبله بعد.`, he: `${selected.label} מופיע ברשימה, אך ה-API הנוכחי עדיין לא מקבל אותו.` }), true);
    } else if (policyLimitMessage) {
        setLeaveRequestStatus(policyLimitMessage, true);
    } else if (hasSchedule && !state.token) {
        setLeaveRequestStatus(getLocalizedValue({
            en: `${selected.label}: ${schedule.requestedDays} day(s) off would bring you back on ${formatDate(schedule.returnToWorkDate)}. Sign in to submit the request.`,
            fr: `${selected.label} : ${schedule.requestedDays} jour(s) vous ramèneraient au travail le ${formatDate(schedule.returnToWorkDate)}. Connectez-vous pour soumettre la demande.`,
            ar: `${selected.label}: ${schedule.requestedDays} يوم/أيام إجازة تعني العودة للعمل في ${formatDate(schedule.returnToWorkDate)}. سجّل الدخول لإرسال الطلب.`,
            he: `${selected.label}: ${schedule.requestedDays} ימי חופשה מחזירים אותך לעבודה ב-${formatDate(schedule.returnToWorkDate)}. התחברו כדי להגיש את הבקשה.`
        }), false);
    } else if (!state.token) {
        setLeaveRequestStatus(t("leaveSignIn", {
            count: leaveOptions.length,
            plural: leaveOptions.length === 1 ? "" : "s",
            source: state.leavePolicies?.sourceLabel || "the ERP database"
        }), false);
    } else if (!state.dashboardIdentity?.employeeId) {
        setLeaveRequestStatus(getLocalizedValue({ en: "This account is not yet linked to an employee profile for leave submission.", fr: "Ce compte n'est pas encore lié à un profil employé pour les demandes de congé.", ar: "هذا الحساب غير مرتبط بعد بملف موظف لتقديم طلب الإجازة.", he: "חשבון זה עדיין לא מקושר לפרופיל עובד להגשת בקשת חופשה." }), true);
    } else if (state.isOffline) {
        setLeaveRequestStatus(getLocalizedValue({ en: "You can calculate your return-to-work date while offline, but submission must wait until the backend connection returns.", fr: "Vous pouvez calculer votre date de reprise hors ligne, mais l'envoi doit attendre le retour de la connexion.", ar: "يمكنك حساب موعد العودة للعمل دون اتصال، لكن الإرسال ينتظر عودة الخادم.", he: "אפשר לחשב את תאריך החזרה לעבודה גם ללא חיבור, אך ההגשה תמתין לחזרת השרת." }), true);
    } else if (selected?.code === "MATERNITY" && maternityGenderMessage) {
        setLeaveRequestStatus(maternityGenderMessage, true);
    } else if (selected?.code === "MOTHERS_DAY" && mothersDayGenderMessage) {
        setLeaveRequestStatus(mothersDayGenderMessage, true);
    } else if (requiresBirthProof) {
        setLeaveRequestStatus(fileValidationMessage
            ? fileValidationMessage
            : t("leaveBirthProof", { leaveType: selected.label }), true);
    } else if (selected?.code === "MOTHERS_DAY" && mothersDayRemainingForSelectedMonth <= 0) {
        setLeaveRequestStatus(mothersDayGenderMessage, true);
    } else if (selected?.code === "MOTHERS_DAY" && mothersDayRemainingForSelectedMonth <= 0) {
        setLeaveRequestStatus(mothersDayNoticeMessage || "Mother's Day has already been used for the selected month and does not accumulate.", true);
    } else if (hasSchedule) {
        setLeaveRequestStatus(getLocalizedValue({
            en: `If leave starts on ${formatDate(schedule.adjustedStartDate)}, you should report back on ${formatDate(schedule.returnToWorkDate)}.`,
            fr: `Si le congé commence le ${formatDate(schedule.adjustedStartDate)}, la reprise est prévue le ${formatDate(schedule.returnToWorkDate)}.`,
            ar: `إذا بدأت الإجازة في ${formatDate(schedule.adjustedStartDate)}، فموعد العودة للعمل هو ${formatDate(schedule.returnToWorkDate)}.`,
            he: `אם החופשה מתחילה ב-${formatDate(schedule.adjustedStartDate)}, יש לחזור לעבודה ב-${formatDate(schedule.returnToWorkDate)}.`
        }), false);
    } else {
        setLeaveRequestStatus(getLocalizedValue({ en: "Enter the first day away and the number of leave days to calculate your return-to-work date.", fr: "Saisissez le premier jour d'absence et le nombre de jours pour calculer la date de reprise.", ar: "أدخل أول يوم غياب وعدد أيام الإجازة لحساب موعد العودة للعمل.", he: "הזינו את יום ההיעדרות הראשון ואת מספר הימים כדי לחשב את תאריך החזרה לעבודה." }), false);
    }
}

async function submitLeaveRequest(event) {
    event.preventDefault();

    const leaveTypeInput = $("#leaveRequestTypeSelect");
    const startInput = $("#leaveStartDate");
    const daysInput = $("#leaveDaysRequested");
    const endInput = $("#leaveEndDate");
    const compassionateRelationInput = $("#compassionateRelationSelect");
    const reasonInput = $("#leaveReason");
    const birthProofInput = $("#birthProofFile");

    const leaveType = leaveTypeInput?.value;
    const startDate = startInput?.value;
    const selectedLeave = getLeaveOptions().find((item) => item.code === leaveType) || null;
    const compassionateRelation = compassionateRelationInput?.value || "";
    const requestedDays = leaveTypeUsesFixedRequestedDays(leaveType)
        ? getFixedRequestedLeaveDays(leaveType)
        : Math.floor(Number(daysInput?.value || 0));
    const policyDayLimit = getLeavePolicyDayLimit(selectedLeave);
    const reason = normalizeUnicodeText(reasonInput?.value);
    const supportingDocument = birthProofInput?.files?.[0] || null;
    const employeeId = state.dashboardIdentity?.employeeId;

    clearFieldStates(leaveTypeInput, startInput, daysInput, endInput, compassionateRelationInput, reasonInput, birthProofInput);

    if (!state.token || !employeeId) {
        setLeaveRequestStatus(getLocalizedValue({ en: "Sign in with an employee-linked account to submit leave.", fr: "Connectez-vous avec un compte lié à un employé pour soumettre un congé.", ar: "سجّل الدخول بحساب مرتبط بموظف لإرسال طلب الإجازة.", he: "התחברו עם חשבון המקושר לעובד כדי להגיש חופשה." }), true);
        return;
    }

    if (state.isOffline) {
        const offlineMessage = getLocalizedValue({ en: "The ERP backend is currently unreachable. Review the form now and submit once the connection is restored.", fr: "Le backend ERP est actuellement inaccessible. Vérifiez le formulaire puis soumettez-le une fois la connexion rétablie.", ar: "خادم النظام غير متاح حالياً. راجع النموذج الآن ثم أرسله بعد استعادة الاتصال.", he: "שרת ה-ERP אינו זמין כרגע. אפשר להכין את הטופס כעת ולהגיש אותו לאחר חידוש החיבור." });
        syncConnectivityBanner(offlineMessage, true);
        setLeaveRequestStatus(offlineMessage, true);
        return;
    }

    if (!leaveType) {
        setFieldState(leaveTypeInput, getLocalizedValue({ en: "Choose the leave type from the ERP-synced list.", fr: "Choisissez le type de congé dans la liste synchronisée.", ar: "اختر نوع الإجازة من القائمة المتزامنة مع النظام.", he: "בחרו את סוג החופשה מתוך הרשימה המסונכרנת." }));
        setLeaveRequestStatus(getLocalizedValue({ en: "Choose the leave type before you submit the request.", fr: "Choisissez le type de congé avant l'envoi.", ar: "اختر نوع الإجازة قبل إرسال الطلب.", he: "בחרו את סוג החופשה לפני ההגשה." }), true);
        return;
    }

    if (!startDate) {
        setFieldState(startInput, getLocalizedValue({ en: "Choose the first day of leave.", fr: "Choisissez le premier jour de congé.", ar: "اختر أول يوم للإجازة.", he: "בחרו את יום החופשה הראשון." }));
        setLeaveRequestStatus(getLocalizedValue({ en: "Start date is required for the leave workflow.", fr: "La date de début est requise pour le workflow de congé.", ar: "تاريخ البدء مطلوب لسير عمل الإجازة.", he: "נדרש תאריך התחלה לתהליך החופשה." }), true);
        return;
    }

    if (!Number.isFinite(requestedDays) || requestedDays <= 0) {
        const daysMessage = getLocalizedValue({ en: "Enter how many leave days the ERP should calculate.", fr: "Indiquez le nombre de jours de congé à calculer.", ar: "أدخل عدد أيام الإجازة التي يجب أن يحسبها النظام.", he: "הזינו כמה ימי חופשה המערכת צריכה לחשב." });
        setFieldState(daysInput, daysMessage);
        setLeaveRequestStatus(daysMessage, true);
        return;
    }

    if (leaveType === "COMPASSIONATE" && !compassionateRelation) {
        const relationMessage = getLocalizedValue({ en: "Select whether the compassionate leave relates to a spouse, child, or parent.", fr: "Sélectionnez s'il s'agit du conjoint, de l'enfant ou du parent.", ar: "حدد ما إذا كانت الإجازة تخص الزوج أو الطفل أو الوالد.", he: "בחרו אם חופשת החמלה קשורה לבן/בת זוג, ילד או הורה." });
        setFieldState(compassionateRelationInput, relationMessage);
        setLeaveRequestStatus(relationMessage, true);
        return;
    }

    if (!reason || reason.length < 10) {
        const reasonMessage = getLocalizedValue({ en: "Explain the reason in at least 10 characters so the approver has enough context.", fr: "Expliquez le motif en au moins 10 caractères pour aider l'approbateur.", ar: "اشرح السبب في 10 أحرف على الأقل ليكون لدى المسؤول سياق كافٍ.", he: "הסבירו את הסיבה בלפחות 10 תווים כדי שלמאשר יהיה מספיק הקשר." });
        setFieldState(reasonInput, reasonMessage);
        setLeaveRequestStatus(reasonMessage, true);
        return;
    }

    if (!SUPPORTED_LEAVE_REQUEST_CODES.has(leaveType)) {
        setLeaveRequestStatus("The selected leave option is shown from the ERP table but is not yet accepted by the leave request API.", true);
        return;
    }

    if (policyDayLimit && requestedDays > policyDayLimit) {
        const policyMessage = getLocalizedValue({
            en: `${selectedLeave?.label || "This leave type"} is configured for up to ${policyDayLimit} day(s) in the ERP rules.`,
            fr: `${selectedLeave?.label || "Ce type de congé"} est configuré pour un maximum de ${policyDayLimit} jour(s).`,
            ar: `${selectedLeave?.label || "نوع الإجازة هذا"} مضبوط بحد أقصى ${policyDayLimit} يوم/أيام في قواعد النظام.`,
            he: `${selectedLeave?.label || "סוג חופשה זה"} מוגדר לעד ${policyDayLimit} ימים בכללי המערכת.`
        });
        setFieldState(daysInput, policyMessage);
        setLeaveRequestStatus(policyMessage, true);
        return;
    }

    if (leaveType === "COMPASSIONATE" && requestedDays > getCompassionateLeaveMaxDays(compassionateRelation)) {
        const compassionateMessage = compassionateRelation === "SPOUSE"
            ? getLocalizedValue({ en: "Compassionate leave for a spouse cannot exceed 21 calendar days.", fr: "Le congé compassion pour un conjoint ne peut pas dépasser 21 jours calendaires.", ar: "لا يمكن أن تتجاوز إجازة التعاطف للزوج أو الزوجة 21 يومًا تقويميًا.", he: "חופשת חמלה עבור בן/בת זוג לא יכולה לעלות על 21 ימים קלנדריים." })
            : getLocalizedValue({ en: "Compassionate leave for a child or parent cannot exceed 14 calendar days.", fr: "Le congé compassion pour un enfant ou un parent ne peut pas dépasser 14 jours calendaires.", ar: "لا يمكن أن تتجاوز إجازة التعاطف لطفل أو والد 14 يومًا تقويميًا.", he: "חופשת חמלה עבור ילד או הורה לא יכולה לעלות על 14 ימים קלנדריים." });
        setFieldState(daysInput, compassionateMessage);
        setLeaveRequestStatus(compassionateMessage, true);
        return;
    }

    const employeeGender = String(state.dashboardIdentity?.gender || "").trim().toLowerCase();
    if (leaveType === "MATERNITY" && employeeGender !== "female") {
        const maternityGenderValidationMessage = "Maternity leave is available only to female employees.";
        setFieldState(leaveTypeInput, maternityGenderValidationMessage);
        setLeaveRequestStatus(maternityGenderValidationMessage, true);
        return;
    }

    if (leaveType === "MOTHERS_DAY" && employeeGender !== "female") {
        const mothersDayGenderValidationMessage = "Mother's Day leave is available only to female employees. The employee's supervisor approves it and HR is only notified.";
        setFieldState(leaveTypeInput, mothersDayGenderValidationMessage);
        setLeaveRequestStatus(mothersDayGenderValidationMessage, true);
        return;
    }

    if (leaveType === "MOTHERS_DAY" && requestedDays !== MOTHERS_DAY_MONTHLY_LIMIT) {
        const mothersDayLengthMessage = "Mother's Day leave is limited to one working day per month and does not accumulate.";
        setFieldState(daysInput, mothersDayLengthMessage);
        setLeaveRequestStatus(mothersDayLengthMessage, true);
        return;
    }

    let schedule = null;
    if (USE_LEAVE_CALCULATION_API && state.selectedEmployeeId) {
        const apiResult = await fetchLeaveCalculation(
            state.selectedEmployeeId, leaveType, startDate, requestedDays, compassionateRelation);
        if (apiResult) {
            schedule = {
                adjustedStartDate: apiResult.startDate,
                endDate: apiResult.leaveEndDate,
                resumptionDate: apiResult.resumeDutiesDate,
                requestedDays: apiResult.chargeableDays,
                weekendDaysSkipped: apiResult.weekendDaysSkipped || 0,
                publicHolidaysSkipped: apiResult.publicHolidaysSkipped || 0,
                calculationMode: apiResult.calculationMode
            };
        }
    }
    if (!schedule) {
        schedule = calculateLeaveSchedule(startDate, requestedDays, leaveType, compassionateRelation);
    }
    if (!schedule?.endDate) {
        const calculationMessage = getLocalizedValue({ en: "Choose a valid start date and days off so the ERP can calculate your return date.", fr: "Choisissez une date de début valide et le nombre de jours pour calculer la reprise.", ar: "اختر تاريخ بدء صالحًا وعدد الأيام ليحسب النظام موعد العودة.", he: "בחרו תאריך התחלה ומספר ימים תקינים כדי שהמערכת תחשב את תאריך החזרה." });
        setFieldState(endInput, calculationMessage);
        setLeaveRequestStatus(calculationMessage, true);
        return;
    }

    if (leaveType === "MOTHERS_DAY") {
        const mothersDayMonthKey = buildMonthKey(schedule.adjustedStartDate || startDate);
        if (getMothersDayUsageForMonth(mothersDayMonthKey) >= MOTHERS_DAY_MONTHLY_LIMIT) {
            const mothersDayMonthlyMessage = `Mother's Day has already been used for ${formatMonthKey(mothersDayMonthKey)} and does not accumulate into another month.`;
            setFieldState(daysInput, mothersDayMonthlyMessage);
            setLeaveRequestStatus(mothersDayMonthlyMessage, true);
            return;
        }
    }

    const endDate = schedule.endDate;
    if (endInput) {
        endInput.value = endDate;
    }

    const documentValidationMessage = validateSupportingDocumentFile(supportingDocument);
    if (documentValidationMessage) {
        setFieldState(birthProofInput, documentValidationMessage);
        setLeaveRequestStatus(documentValidationMessage, true);
        return;
    }

    if (leaveTypeRequiresBirthProof(leaveType) && !supportingDocument) {
        const proofMessage = getLocalizedValue({ en: "Attach a PDF, PNG, or JPG birth record/certificate (max 5 MB) for maternity or paternity leave.", fr: "Joignez un acte de naissance PDF, PNG ou JPG (5 Mo max.) pour un congé maternité ou paternité.", ar: "أرفق سجل/شهادة ميلاد بصيغة PDF أو PNG أو JPG (بحد أقصى 5 ميغابايت) لإجازة الأمومة أو الأبوة.", he: "יש לצרף תעודת/רישום לידה מסוג PDF, PNG או JPG (עד 5MB) לחופשת לידה או אבהות." });
        setFieldState(birthProofInput, proofMessage);
        setLeaveRequestStatus(proofMessage, true);
        return;
    }

    setLeaveRequestStatus(getLocalizedValue({ en: "Submitting leave request...", fr: "Envoi de la demande de congé...", ar: "جارٍ إرسال طلب الإجازة...", he: "שולח בקשת חופשה..." }), false, true);

    try {
        const formData = new FormData();
        formData.append("employeeId", String(employeeId));
        formData.append("leaveType", leaveType);
        if (compassionateRelation) {
            formData.append("compassionateRelation", compassionateRelation);
        }
        formData.append("startDate", startDate);
        formData.append("endDate", endDate);
        formData.append("reason", reason);
        if (supportingDocument) {
            formData.append("supportingDocument", supportingDocument);
        }

        const response = await fetchJson("leaves", {
            method: "POST",
            body: formData
        }, true);

        if (reasonInput) {
            reasonInput.value = "";
        }
        if (startInput) {
            startInput.value = "";
        }
        if (daysInput) {
            daysInput.value = "";
        }
        if (endInput) {
            endInput.value = "";
        }
        if (compassionateRelationInput) {
            compassionateRelationInput.value = "";
        }
        if (birthProofInput) {
            birthProofInput.value = "";
        }

        renderLeaveRequestForm();
        setLeaveRequestStatus(getLocalizedValue({
            en: `Leave request submitted successfully for ${response.leaveType || leaveType}${response.supportingDocumentName ? ` with ${response.supportingDocumentName}` : ""}. You should report back on ${formatDate(schedule.returnToWorkDate)}${Number.isFinite(response.remainingBalance) ? `. Remaining accrued balance: ${response.remainingBalance} day(s).` : ". This leave was recorded as a condition of service and did not reduce accrued leave balance."}`,
            fr: `La demande de congé a été envoyée avec succès pour ${response.leaveType || leaveType}${response.supportingDocumentName ? ` avec ${response.supportingDocumentName}` : ""}. La reprise est prévue le ${formatDate(schedule.returnToWorkDate)}${Number.isFinite(response.remainingBalance) ? `. Solde acquis restant : ${response.remainingBalance} jour(s).` : ". Ce congé a été enregistré comme condition de service et n'a pas réduit le solde acquis."}`,
            ar: `تم إرسال طلب الإجازة بنجاح لـ ${response.leaveType || leaveType}${response.supportingDocumentName ? ` مع ${response.supportingDocumentName}` : ""}. موعد العودة للعمل هو ${formatDate(schedule.returnToWorkDate)}${Number.isFinite(response.remainingBalance) ? `. الرصيد المتبقي: ${response.remainingBalance} يوم/أيام.` : ". تم تسجيل هذه الإجازة كشرط خدمة ولم تُخصم من الرصيد المتراكم."}`,
            he: `בקשת החופשה נשלחה בהצלחה עבור ${response.leaveType || leaveType}${response.supportingDocumentName ? ` עם ${response.supportingDocumentName}` : ""}. החזרה לעבודה צפויה ב-${formatDate(schedule.returnToWorkDate)}${Number.isFinite(response.remainingBalance) ? `. יתרה נצברת שנותרה: ${response.remainingBalance} ימים.` : ". חופשה זו נרשמה כתנאי שירות ולא הפחיתה מיתרת החופשה הנצברת."}`
        }), false);
        await loadProtectedData();
    } catch (error) {
        setLeaveRequestStatus(error.message || getLocalizedValue({ en: "Unable to submit leave request.", fr: "Impossible d'envoyer la demande de congé.", ar: "تعذر إرسال طلب الإجازة.", he: "לא ניתן לשלוח את בקשת החופשה." }), true);
    }
}

function setLeaveRequestStatus(message, isWarning, isBusy = false) {
    updateStatusNode($("#leaveRequestStatus"), message, { warning: isWarning, busy: isBusy });
}

function bindOvertimeTriggerForm() {
    const form = $("#overtimeTriggerForm");
    const employeeInput = $("#overtimeEmployeeId");
    const clockOutInput = $("#overtimeClockOutTime");

    if (!form) {
        return;
    }

    form.addEventListener("submit", submitOvertimeTrigger);
    employeeInput?.addEventListener("input", () => {
        employeeInput.dataset.userEdited = employeeInput.value ? "true" : "";
        if (Number(employeeInput.value) > 0) {
            setFieldState(employeeInput, "");
        }
    });
    clockOutInput?.addEventListener("change", () => {
        setFieldState(clockOutInput, "");
    });
}

function renderOvertimeTriggerForm() {
    const form = $("#overtimeTriggerForm");
    const employeeInput = $("#overtimeEmployeeId");
    const clockOutInput = $("#overtimeClockOutTime");
    const submitButton = form?.querySelector('button[type="submit"]');

    if (!form || !employeeInput || !clockOutInput || !submitButton) {
        return;
    }

    if (!employeeInput.dataset.userEdited && state.dashboardIdentity?.employeeId) {
        employeeInput.value = String(state.dashboardIdentity.employeeId);
    }

    if (!clockOutInput.value) {
        clockOutInput.value = formatLocalDateTimeInput(new Date());
    }
    clockOutInput.max = formatLocalDateTimeInput(new Date(Date.now() + 5 * 60 * 1000));

    const formEnabled = Boolean(state.token);
    [employeeInput, clockOutInput, submitButton].forEach((element) => {
        element.disabled = !formEnabled;
    });

    if (!state.token) {
        setOvertimeTriggerStatus(getLocalizedValue({ en: "Sign in to trigger overtime or review pending sessions.", fr: "Connectez-vous pour lancer ou examiner les sessions d'heures supplémentaires.", ar: "سجّل الدخول لتشغيل أو مراجعة جلسات العمل الإضافي.", he: "התחברו כדי להפעיל או לבדוק סשנים של שעות נוספות." }), false);
    } else if (state.isOffline) {
        setOvertimeTriggerStatus(getLocalizedValue({ en: "The overtime service is currently offline. Review the approval path below and retry when the backend reconnects.", fr: "Le service d'heures supplémentaires est hors ligne. Consultez le circuit d'approbation puis réessayez plus tard.", ar: "خدمة العمل الإضافي غير متاحة حالياً. راجع مسار الموافقة أدناه ثم أعد المحاولة لاحقاً.", he: "שירות השעות הנוספות אינו זמין כרגע. אפשר לעיין במסלול האישור ולנסות שוב מאוחר יותר." }), true);
    } else if (state.dashboardIdentity?.employeeId) {
        setOvertimeTriggerStatus(getLocalizedValue({ en: `Ready to evaluate overtime for ${state.dashboardIdentity.employeeName || state.username}.`, fr: `Prêt à évaluer les heures supplémentaires pour ${state.dashboardIdentity.employeeName || state.username}.`, ar: `جاهز لتقييم العمل الإضافي لـ ${state.dashboardIdentity.employeeName || state.username}.`, he: `מוכן להערכת שעות נוספות עבור ${state.dashboardIdentity.employeeName || state.username}.` }), false);
    } else {
        setOvertimeTriggerStatus(getLocalizedValue({ en: "Enter the employee ID and clock-out time to evaluate overtime eligibility.", fr: "Saisissez l'identifiant employé et l'heure de sortie pour évaluer l'éligibilité.", ar: "أدخل رقم الموظف ووقت الخروج لتقييم الأهلية.", he: "הזינו מזהה עובד ושעת יציאה כדי להעריך זכאות." }), true);
    }

    renderLastOvertimeTrigger();
}

async function submitOvertimeTrigger(event) {
    event.preventDefault();

    const employeeInput = $("#overtimeEmployeeId");
    const clockOutInput = $("#overtimeClockOutTime");
    const employeeId = Number(employeeInput?.value);
    const clockOutTimeValue = clockOutInput?.value;

    clearFieldStates(employeeInput, clockOutInput);

    if (state.isOffline) {
        const offlineMessage = getLocalizedValue({ en: "The backend is unavailable right now. Please retry the overtime trigger once the connection is restored.", fr: "Le backend est indisponible pour le moment. Réessayez une fois la connexion rétablie.", ar: "الخادم غير متاح حالياً. أعد محاولة تشغيل العمل الإضافي بعد استعادة الاتصال.", he: "השרת אינו זמין כרגע. נסו שוב להפעיל את בדיקת השעות הנוספות לאחר חידוש החיבור." });
        syncConnectivityBanner(offlineMessage, true);
        setOvertimeTriggerStatus(offlineMessage, true);
        return;
    }

    if (!Number.isFinite(employeeId) || employeeId <= 0) {
        const employeeMessage = getLocalizedValue({ en: "Enter a valid employee ID before triggering the overtime check.", fr: "Saisissez un identifiant employé valide avant le déclenchement.", ar: "أدخل رقم موظف صالح قبل تشغيل الفحص.", he: "הזינו מזהה עובד תקין לפני הפעלת הבדיקה." });
        setFieldState(employeeInput, employeeMessage);
        setOvertimeTriggerStatus(employeeMessage, true);
        return;
    }

    if (!clockOutTimeValue) {
        const timeMessage = getLocalizedValue({ en: "Choose the clock-out time to evaluate overtime eligibility.", fr: "Choisissez l'heure de sortie pour évaluer l'éligibilité.", ar: "اختر وقت الخروج لتقييم الأهلية.", he: "בחרו שעת יציאה כדי להעריך זכאות." });
        setFieldState(clockOutInput, timeMessage);
        setOvertimeTriggerStatus(timeMessage, true);
        return;
    }

    const selectedTime = new Date(clockOutTimeValue);
    if (!Number.isNaN(selectedTime.getTime()) && selectedTime.getTime() > Date.now() + (5 * 60 * 1000)) {
        const futureMessage = getLocalizedValue({ en: "Clock-out time cannot be set in the future. Choose the actual time worked.", fr: "L'heure de sortie ne peut pas être future. Choisissez l'heure réelle.", ar: "لا يمكن أن يكون وقت الخروج في المستقبل. اختر الوقت الفعلي للعمل.", he: "שעת היציאה לא יכולה להיות בעתיד. בחרו את זמן העבודה בפועל." });
        setFieldState(clockOutInput, futureMessage);
        setOvertimeTriggerStatus(futureMessage, true);
        return;
    }

    const normalizedClockOutTime = clockOutTimeValue.length === 16 ? `${clockOutTimeValue}:00` : clockOutTimeValue;
    setOvertimeTriggerStatus(getLocalizedValue({ en: "Evaluating overtime eligibility...", fr: "Évaluation de l'éligibilité aux heures supplémentaires...", ar: "جارٍ تقييم أهلية العمل الإضافي...", he: "נבדקת זכאות לשעות נוספות..." }), false, true);

    try {
        const response = await fetchJson(`overtime/trigger?employeeId=${encodeURIComponent(employeeId)}&clockOutTime=${encodeURIComponent(normalizedClockOutTime)}`, {
            method: "POST"
        }, true);

        state.lastOvertimeTrigger = response;
        await loadProtectedData();
        renderLastOvertimeTrigger();

        const message = response.sessionCreated
            ? `Overtime session ${response.session?.id ? `#${response.session.id}` : ""} created successfully and is now visible in the review queue.`
            : (response.skipReason || "No overtime session was created for the selected clock-out time.");
        setOvertimeTriggerStatus(message, !response.sessionCreated);
    } catch (error) {
        setOvertimeTriggerStatus(error.message || "Unable to trigger overtime evaluation.", true);
    }
}

function renderLastOvertimeTrigger() {
    const detailRoot = $("#overtimeTriggerDetails");
    const summaryRoot = $("#overtimeActionSummary");

    if (summaryRoot) {
        const content = state.overtimeRequests?.content || [];
        const pendingReviews = content.filter((item) => ["PENDING_SUPERVISOR", "PENDING_HOD"].includes(normalizeStatusValue(item.status))).length;
        summaryRoot.innerHTML = [
            { label: "Pending review", value: String(pendingReviews) },
            { label: "My review scope", value: hasAnyRole("ADMIN", "HR", "HEAD") ? "Enabled" : "Read only" },
            { label: "Approval route", value: "Supervisor → HOD → Payroll" },
            { label: "Payroll action", value: hasAnyRole("ADMIN", "PAYROLL") ? "Available" : "Restricted" }
        ].map((item) => `
            <article class="list-card detail-card">
                <strong>${escapeHtml(item.label)}</strong>
                <p>${escapeHtml(item.value)}</p>
            </article>
        `).join("");
    }

    if (!detailRoot) {
        return;
    }

    if (!state.lastOvertimeTrigger) {
        detailRoot.innerHTML = '<div class="notice"><strong>Trigger result</strong><span>The latest overtime eligibility result will appear here after you submit the form.</span></div>';
        return;
    }

    const session = state.lastOvertimeTrigger.session;
    detailRoot.innerHTML = [
        { label: "Employee", value: state.lastOvertimeTrigger.employeeId ?? "-" },
        { label: "Session created", value: state.lastOvertimeTrigger.sessionCreated ? "Yes" : "No" },
        { label: "Status", value: session?.status || state.lastOvertimeTrigger.skipReason || "No session created" },
        { label: "Next approver", value: session?.status === "PENDING_HOD" ? "Head of Department" : (state.lastOvertimeTrigger.sessionCreated ? "Supervisor review" : "No approval stage started") },
        { label: "Hours", value: session ? Number(session.overtimeHours || 0).toFixed(2) : "—" },
        { label: "Amount due", value: session ? money.format(Number(session.amountDue || 0)) : "—" },
        { label: "Date", value: session ? formatDate(session.sessionDate) : "—" }
    ].map((item) => `
        <article class="list-card detail-card">
            <strong>${escapeHtml(item.label)}</strong>
            <p>${escapeHtml(String(item.value))}</p>
        </article>
    `).join("");
}

function setOvertimeTriggerStatus(message, isWarning, isBusy = false) {
    updateStatusNode($("#overtimeTriggerStatus"), message, { warning: isWarning, busy: isBusy });
}

function buildOvertimeActions(item) {
    const status = normalizeStatusValue(item.status);
    const actions = [];

    if (canReviewOvertimeItem(status)) {
        actions.push(`<button class="ghost-button" type="button" onclick="approveOvertimeSession(${Number(item.id)})">Approve</button>`);
        actions.push(`<button class="ghost-button" type="button" onclick="rejectOvertimeSession(${Number(item.id)})">Reject</button>`);
    }

    if (hasAnyRole("ADMIN", "PAYROLL") && status === "APPROVED_LEVEL3" && !item.paid) {
        actions.push(`<button class="ghost-button" type="button" onclick="markOvertimeSessionPaid(${Number(item.id)})">Mark paid</button>`);
    }

    return actions.length ? `<div class="table-actions">${actions.join("")}</div>` : '<span class="table-note">No actions</span>';
}

function canReviewOvertimeItem(status) {
    if (!state.token || !state.dashboardIdentity?.employeeId) {
        return false;
    }

    if (status === "PENDING_SUPERVISOR") {
        return hasAnyRole("ADMIN", "HR", "HEAD");
    }

    if (status === "PENDING_HOD") {
        return hasAnyRole("ADMIN", "HEAD");
    }

    return false;
}

async function reviewOvertimeSession(id, decision) {
    if (!state.dashboardIdentity?.employeeId) {
        setOvertimeTriggerStatus("This account must be linked to an employee record before reviewing overtime.", true);
        return;
    }

    const reason = decision === "reject"
        ? window.prompt("Enter the rejection reason for this overtime session:", "")
        : "Approved from the ERP dashboard";

    if (reason === null) {
        return;
    }

    try {
        const endpoint = decision === "approve" ? `overtime/${id}/approve` : `overtime/${id}/reject`;
        await fetchJson(endpoint, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                decidedBy: state.dashboardIdentity.employeeId,
                reason: reason || undefined
            })
        }, true);

        await loadProtectedData();
        setOvertimeTriggerStatus(`Overtime session #${id} ${decision === "approve" ? "approved" : "rejected"} successfully.`, false);
    } catch (error) {
        setOvertimeTriggerStatus(error.message || "Unable to update the overtime session.", true);
    }
}

async function markOvertimeSessionPaid(id) {
    const payrollReference = window.prompt("Enter the payroll reference for this paid overtime session:", `PAY-${new Date().toISOString().slice(0, 10)}-${id}`);
    if (!payrollReference) {
        return;
    }

    try {
        await fetchJson("overtime/payroll/mark-paid", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                sessionIds: [Number(id)],
                payrollReference,
                payrollDate: new Date().toISOString().split("T")[0]
            })
        }, true);

        await loadProtectedData();
        setOvertimeTriggerStatus(`Overtime session #${id} marked as paid under ${payrollReference}.`, false);
    } catch (error) {
        setOvertimeTriggerStatus(error.message || "Unable to mark the overtime session as paid.", true);
    }
}

function bindSalaryAdvanceForm() {
    const form = $("#salaryAdvanceForm");
    const authorityInput = $("#salaryAdvanceAuthorityRef");

    if (!form) {
        return;
    }

    form.addEventListener("submit", submitSalaryAdvanceRequest);
    authorityInput?.addEventListener("input", () => {
        authorityInput.dataset.userEdited = authorityInput.value ? "true" : "";
    });
}

function renderSalaryAdvanceRequestForm() {
    const form = $("#salaryAdvanceForm");
    const authorityInput = $("#salaryAdvanceAuthorityRef");
    const amountInput = $("#salaryAdvanceAmount");
    const installmentsInput = $("#salaryAdvanceInstallments");
    const reasonInput = $("#salaryAdvanceReason");
    const detailRoot = $("#salaryAdvanceDetails");
    const submitButton = form?.querySelector('button[type="submit"]');

    if (!form || !authorityInput || !amountInput || !installmentsInput || !reasonInput || !detailRoot || !submitButton) {
        return;
    }

    if (!authorityInput.dataset.userEdited) {
        authorityInput.value = authorityInput.value || state.salaryAdvanceRequests?.content?.[0]?.authorityRef || state.dashboardIdentity?.authorityCode || "";
    }

    if (!installmentsInput.value) {
        installmentsInput.value = "3";
    }

    const formEnabled = Boolean(state.token && state.dashboardIdentity?.employeeId);
    [authorityInput, amountInput, installmentsInput, reasonInput, submitButton].forEach((element) => {
        element.disabled = !formEnabled;
    });

    const applicantName = state.dashboardIdentity?.employeeName || state.username || "-";
    detailRoot.innerHTML = [
        { label: getLocalizedValue({ en: "Applicant", fr: "Demandeur", ar: "صاحب الطلب", he: "מבקש/ת" }), value: applicantName },
        { label: getLocalizedValue({ en: "Employee ID", fr: "Identifiant employé", ar: "رقم الموظف", he: "מזהה עובד" }), value: state.dashboardIdentity?.employeeId || getLocalizedValue({ en: "Link required", fr: "Lien requis", ar: "يتطلب ربطًا", he: "נדרש קישור" }) },
        { label: getLocalizedValue({ en: "Authority ref", fr: "Réf. autorité", ar: "مرجع الجهة", he: "אסמכתא רשות" }), value: authorityInput.value || getLocalizedValue({ en: "Enter authority ref", fr: "Saisir la référence", ar: "أدخل المرجع", he: "הזינו אסמכתא" }) },
        { label: getLocalizedValue({ en: "Role access", fr: "Accès du rôle", ar: "وصول الدور", he: "גישת תפקיד" }), value: hasAnyRole("ADMIN", "HR", "HEAD", "FINANCE", "PAYROLL", "EMPLOYEE") ? getLocalizedValue({ en: "Workflow enabled", fr: "Workflow activé", ar: "سير العمل مفعّل", he: "זרימת העבודה פעילה" }) : getLocalizedValue({ en: "Read only", fr: "Lecture seule", ar: "قراءة فقط", he: "קריאה בלבד" }) }
    ].map((item) => `
        <article class="list-card detail-card">
            <strong>${escapeHtml(item.label)}</strong>
            <p>${escapeHtml(String(item.value))}</p>
        </article>
    `).join("");

    if (!state.token) {
        setSalaryAdvanceRequestStatus(getLocalizedValue({ en: "Sign in to submit and track salary advance workflow requests.", fr: "Connectez-vous pour soumettre et suivre les avances sur salaire.", ar: "سجّل الدخول لإرسال ومتابعة طلبات السلفة.", he: "התחברו כדי להגיש ולעקוב אחר בקשות למקדמת שכר." }), false);
    } else if (!state.dashboardIdentity?.employeeId) {
        setSalaryAdvanceRequestStatus(getLocalizedValue({ en: "This account is not linked to an employee profile for salary advance submission.", fr: "Ce compte n'est pas lié à un profil employé pour les avances sur salaire.", ar: "هذا الحساب غير مرتبط بملف موظف لتقديم السلفة.", he: "חשבון זה אינו מקושר לפרופיל עובד להגשת מקדמה." }), true);
    } else {
        setSalaryAdvanceRequestStatus(getLocalizedValue({ en: `Ready to submit a salary advance request for ${applicantName}.`, fr: `Prêt à soumettre une demande d'avance pour ${applicantName}.`, ar: `جاهز لإرسال طلب سلفة لـ ${applicantName}.`, he: `מוכן להגשת בקשת מקדמה עבור ${applicantName}.` }), false);
    }
}

async function submitSalaryAdvanceRequest(event) {
    event.preventDefault();

    if (!state.dashboardIdentity?.employeeId) {
        setSalaryAdvanceRequestStatus(getLocalizedValue({ en: "This account must be linked to an employee profile before requesting a salary advance.", fr: "Ce compte doit être lié à un profil employé avant la demande d'avance.", ar: "يجب ربط هذا الحساب بملف موظف قبل طلب السلفة.", he: "חשבון זה חייב להיות מקושר לפרופיל עובד לפני בקשת מקדמה." }), true);
        return;
    }

    const authorityRef = normalizeUnicodeText($("#salaryAdvanceAuthorityRef")?.value);
    const requestedAmount = Number($("#salaryAdvanceAmount")?.value);
    const requestedInstallments = Number($("#salaryAdvanceInstallments")?.value);
    const reason = normalizeUnicodeText($("#salaryAdvanceReason")?.value);
    const applicantName = state.dashboardIdentity?.employeeName || state.username;

    if (!authorityRef) {
        setSalaryAdvanceRequestStatus(getLocalizedValue({ en: "Enter the authority reference before submitting the request.", fr: "Saisissez la référence de l'autorité avant l'envoi.", ar: "أدخل مرجع الجهة قبل الإرسال.", he: "הזינו את אסמכתת הרשות לפני ההגשה." }), true);
        return;
    }

    if (!Number.isFinite(requestedAmount) || requestedAmount <= 0) {
        setSalaryAdvanceRequestStatus(getLocalizedValue({ en: "Enter a valid requested amount greater than zero.", fr: "Saisissez un montant valide supérieur à zéro.", ar: "أدخل مبلغًا صالحًا أكبر من صفر.", he: "הזינו סכום תקין הגדול מאפס." }), true);
        return;
    }

    if (!Number.isInteger(requestedInstallments) || requestedInstallments <= 0) {
        setSalaryAdvanceRequestStatus(getLocalizedValue({ en: "Enter a valid number of installments.", fr: "Saisissez un nombre de versements valide.", ar: "أدخل عدد أقساط صالحًا.", he: "הזינו מספר תשלומים תקין." }), true);
        return;
    }

    if (!reason) {
        setSalaryAdvanceRequestStatus(getLocalizedValue({ en: "Provide the reason for the salary advance request.", fr: "Indiquez le motif de l'avance sur salaire.", ar: "اذكر سبب طلب السلفة.", he: "ציינו את סיבת בקשת המקדמה." }), true);
        return;
    }

    setSalaryAdvanceRequestStatus(getLocalizedValue({ en: "Submitting salary advance request...", fr: "Envoi de la demande d'avance...", ar: "جارٍ إرسال طلب السلفة...", he: "שולח בקשת מקדמה..." }), false, true);

    try {
        const response = await fetchJson("salary-advances/requests", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                employeeId: state.dashboardIdentity.employeeId,
                authorityRef,
                requestedAmount,
                requestedInstallments,
                reason,
                applicantName
            })
        }, true);

        $("#salaryAdvanceAmount").value = "";
        $("#salaryAdvanceReason").value = "";
        await loadProtectedData();
        await viewSalaryAdvanceTracking(response.id, true);
        setSalaryAdvanceRequestStatus(`Salary advance request ${response.requestNumber || `#${response.id}`} submitted successfully.`, false);
    } catch (error) {
        setSalaryAdvanceRequestStatus(error.message || "Unable to submit the salary advance request.", true);
    }
}

function setSalaryAdvanceRequestStatus(message, isWarning, isBusy = false) {
    updateStatusNode($("#salaryAdvanceRequestStatus"), message, { warning: isWarning, busy: isBusy });
}

function buildSalaryAdvanceActions(item) {
    const status = normalizeStatusValue(item.status);
    const actions = [];

    if (state.token) {
        actions.push(`<button class="ghost-button" type="button" onclick="viewSalaryAdvanceTracking(${Number(item.id)})">Track</button>`);
    }

    if (hasAnyRole("ADMIN", "HR", "HEAD") && ["SUBMITTED", "PENDING_HEAD_APPROVAL"].includes(status)) {
        actions.push(`<button class="ghost-button" type="button" onclick="approveSalaryAdvanceHead(${Number(item.id)})">Head approve</button>`);
        actions.push(`<button class="ghost-button" type="button" onclick="rejectSalaryAdvanceHead(${Number(item.id)})">Head reject</button>`);
    }

    if (hasAnyRole("ADMIN", "FINANCE", "PAYROLL") && status === "PENDING_FINANCE_APPROVAL") {
        actions.push(`<button class="ghost-button" type="button" onclick="approveSalaryAdvanceFinance(${Number(item.id)})">Finance approve</button>`);
        actions.push(`<button class="ghost-button" type="button" onclick="rejectSalaryAdvanceFinance(${Number(item.id)})">Finance reject</button>`);
    }

    if (hasAnyRole("ADMIN", "FINANCE", "PAYROLL") && status === "APPROVED_FOR_DISBURSEMENT") {
        actions.push(`<button class="ghost-button" type="button" onclick="disburseSalaryAdvanceRequest(${Number(item.id)})">Disburse</button>`);
    }

    return actions.length ? `<div class="table-actions">${actions.join("")}</div>` : '<span class="table-note">No actions</span>';
}

async function viewSalaryAdvanceTracking(id, silent = false) {
    try {
        if (!silent) {
            setSalaryAdvanceRequestStatus(`Loading tracking for request #${id}...`, false, true);
        }
        const response = await fetchJson(`salary-advances/requests/${id}/tracking`, {}, true);
        state.salaryAdvanceTracking = response;
        renderSalaryAdvanceTracking();
        if (!silent) {
            setSalaryAdvanceRequestStatus(`Loaded tracking for ${response.requestNumber || `request #${id}`}.`, false);
        }
    } catch (error) {
        setSalaryAdvanceRequestStatus(error.message || "Unable to load salary advance tracking.", true);
    }
}

async function reviewSalaryAdvanceHead(id, approved) {
    const headApproverName = window.prompt("Enter the head approver name:", state.dashboardIdentity?.employeeName || state.username || "");
    if (!headApproverName) {
        return;
    }

    const defaultTitle = normalizeStatusValue(state.selectedAuthorityType).includes("CITY") ? "TOWN_CLERK" : "COUNCIL_SECRETARY";
    const title = window.prompt("Enter the head approver title (COUNCIL_SECRETARY or TOWN_CLERK):", defaultTitle);
    if (!title) {
        return;
    }

    const notes = approved
        ? (window.prompt("Approval notes (optional):", "Approved from ERP dashboard") ?? "")
        : window.prompt("Enter the rejection reason:", "");

    if (notes === null) {
        return;
    }

    try {
        await fetchJson(`salary-advances/requests/${id}/head-decision`, {
            method: "PATCH",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                headApproverTitle: normalizeStatusValue(title),
                headApproverName,
                decision: approved ? "APPROVED" : "REJECTED",
                notes
            })
        }, true);

        await loadProtectedData();
        await viewSalaryAdvanceTracking(id, true);
        setSalaryAdvanceRequestStatus(`Head decision recorded for salary advance request #${id}.`, false);
    } catch (error) {
        setSalaryAdvanceRequestStatus(error.message || "Unable to record the head decision.", true);
    }
}

async function reviewSalaryAdvanceFinance(id, approved) {
    const financeOfficerName = window.prompt("Enter the finance officer name:", state.dashboardIdentity?.employeeName || state.username || "");
    if (!financeOfficerName) {
        return;
    }

    const notes = approved
        ? (window.prompt("Approval notes (optional):", "Finance approval recorded from ERP dashboard") ?? "")
        : window.prompt("Enter the rejection reason:", "");

    if (notes === null) {
        return;
    }

    try {
        await fetchJson(`salary-advances/requests/${id}/finance-decision`, {
            method: "PATCH",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                financeOfficerName,
                decision: approved ? "APPROVED" : "REJECTED",
                notes
            })
        }, true);

        await loadProtectedData();
        await viewSalaryAdvanceTracking(id, true);
        setSalaryAdvanceRequestStatus(`Finance decision recorded for salary advance request #${id}.`, false);
    } catch (error) {
        setSalaryAdvanceRequestStatus(error.message || "Unable to record the finance decision.", true);
    }
}

async function disburseSalaryAdvance(id) {
    const disbursedBy = window.prompt("Enter the disbursing officer name:", state.dashboardIdentity?.employeeName || state.username || "");
    if (!disbursedBy) {
        return;
    }

    const disbursementReference = window.prompt("Enter the disbursement reference:", `DISB-${new Date().toISOString().slice(0, 10)}-${id}`);
    if (!disbursementReference) {
        return;
    }

    try {
        await fetchJson(`salary-advances/requests/${id}/disburse`, {
            method: "PATCH",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                disbursedByTitle: "DIRECTOR_OF_FINANCE",
                disbursedBy,
                disbursementReference
            })
        }, true);

        await loadProtectedData();
        await viewSalaryAdvanceTracking(id, true);
        setSalaryAdvanceRequestStatus(`Salary advance request #${id} marked as disbursed.`, false);
    } catch (error) {
        setSalaryAdvanceRequestStatus(error.message || "Unable to disburse the salary advance request.", true);
    }
}

function renderSalaryAdvanceTracking() {
    const root = $("#salaryAdvanceTracking");
    if (!root) {
        return;
    }

    if (!state.salaryAdvanceTracking) {
        root.innerHTML = `
            <article class="timeline-card">
                <strong>Tracking is ready</strong>
                <p>Select <em>Track</em> from any request in the register to load its workflow history here.</p>
            </article>
        `;
        return;
    }

    const tracking = state.salaryAdvanceTracking;
    const timeline = Array.isArray(tracking.timeline) ? tracking.timeline : [];
    const cards = [
        `
            <article class="timeline-card">
                <strong>${escapeHtml(tracking.requestNumber || `Request #${tracking.requestId}`)}</strong>
                <p>${escapeHtml(tracking.currentStage || "Workflow stage pending")}</p>
                <p>${escapeHtml(tracking.progressLabel || "Tracking summary")}</p>
            </article>
        `,
        ...timeline.map((event) => `
            <article class="timeline-card">
                <strong>${escapeHtml(event.stage || event.action || "Workflow event")}</strong>
                <p>${escapeHtml([event.action, event.actorRole, event.actorName].filter(Boolean).join(" • ") || "Recorded event")}</p>
                <p>${escapeHtml(event.notes || formatDateTime(event.at))}</p>
            </article>
        `)
    ];

    root.innerHTML = cards.join("");
}

window.gotoPendingLeavePage = (page) => {
    state.pendingLeavePage = Math.max(0, Number(page) || 0);
    loadProtectedData();
};
window.gotoOvertimePage = (page) => {
    state.overtimePage = Math.max(0, Number(page) || 0);
    loadProtectedData();
};
window.gotoSalaryAdvancePage = (page) => {
    state.salaryAdvancePage = Math.max(0, Number(page) || 0);
    loadProtectedData();
};
window.approveOvertimeSession = (id) => reviewOvertimeSession(id, "approve");
window.rejectOvertimeSession = (id) => reviewOvertimeSession(id, "reject");
window.markOvertimeSessionPaid = markOvertimeSessionPaid;
window.viewSalaryAdvanceTracking = viewSalaryAdvanceTracking;
window.approveSalaryAdvanceHead = (id) => reviewSalaryAdvanceHead(id, true);
window.rejectSalaryAdvanceHead = (id) => reviewSalaryAdvanceHead(id, false);
window.approveSalaryAdvanceFinance = (id) => reviewSalaryAdvanceFinance(id, true);
window.rejectSalaryAdvanceFinance = (id) => reviewSalaryAdvanceFinance(id, false);
window.disburseSalaryAdvanceRequest = disburseSalaryAdvance;

function normalizeLeaveCode(value) {
    return String(value || "")
        .trim()
        .replace(/[^a-zA-Z0-9]+/g, "_")
        .replace(/^_+|_+$/g, "")
        .toUpperCase();
}

function leaveTypeRequiresBirthProof(value) {
    return BIRTH_PROOF_REQUIRED_CODES.has(normalizeLeaveCode(value));
}

function renderOvertime() {
    const content = state.overtimeRequests?.content || [];
    const employeesById = buildEmployeeIndex();
    const totalAmount = content.reduce((sum, item) => sum + Number(item.amountDue || 0), 0);
    const profile = state.activeProfile;

    $("#overtimeSummary").innerHTML = [
        { value: String(content.length), label: "Visible requests", note: "Current page after status filter." },
        { value: money.format(totalAmount || 0), label: "Amount due", note: (profile?.priorityMetrics || [])[1] || "Sum of visible overtime rows." },
        { value: state.overtimeRequests ? String(state.overtimeRequests.totalElements ?? content.length) : "Locked", label: "Total register", note: state.overtimeRequests ? "All matching requests in dataset." : "Requires sign in." },
        { value: $("#overtimeStatusFilter").value || "All", label: "Active filter", note: `${state.selectedAuthorityType} dashboard variant.` }
    ].map(renderMetricCard).join("");

    renderOvertimeTriggerForm();

    if (content.length) {
        renderTable("#overtimeTable", ["Employee", "Session", "Hours", "Type", "Amount", "Status", "Actions"], content.map((item) => [
            employeesById.get(item.employeeId)?.name || `Employee ${item.employeeId}`,
            formatDate(item.sessionDate),
            Number(item.overtimeHours || 0).toFixed(2),
            item.overtimeType || "-",
            money.format(Number(item.amountDue || 0)),
            badge(item.status || "-", normalizeStatusValue(item.status).includes("REJECT")),
            buildOvertimeActions(item)
        ]));
        renderPagination("#overtimeTablePager", state.overtimeRequests, "gotoOvertimePage", "overtime request");
    } else {
        renderPagination("#overtimeTablePager", null, "gotoOvertimePage", "overtime request");
        renderNotice("#overtimeTable", !state.token
            ? "Sign in to view overtime requests."
            : state.overtimeRequests === null
                ? "Overtime workflow data is temporarily unavailable. You can still review the approval guidance above and retry when the backend is reachable."
                : "No overtime requests matched the current filter.");
    }
}

function renderPerformance() {
    const performancePolicy = state.globalPolicies?.policies?.performanceManagement;
    $("#performanceMeta").textContent = performancePolicy?.tableExists ? `${state.selectedAuthorityType} variant | Policy rows: ${performancePolicy.policyCount}` : "Policy table not detected";

    const profile = state.activeProfile;

    const departments = groupEmployeesByDepartment();
    const positions = [...departments.values()].flatMap((group) => group.map((employee) => employee.positionTitle)).filter(Boolean);

    $("#performanceSummary").innerHTML = [
        { value: performancePolicy?.tableExists ? "Policy loaded" : "Policy missing", label: "Policy state", note: "Derived from the global policy snapshot." },
        { value: String(departments.size || 0), label: "Departments", note: state.isLoadingEmployees ? "Loading employee directory for this tab now." : (state.employees ? "Grouped from employee master data." : (state.token ? "Loaded on demand for faster dashboard startup." : "Requires sign in with employee access.")) },
        { value: String(new Set(positions).size || 0), label: "JD coverage", note: (profile?.priorityMetrics || [])[2] || "Distinct position titles available for job description views." },
        { value: "4-step", label: "APAS cycle", note: `${state.selectedPositionId} performance workflow.` }
    ].map(renderMetricCard).join("");

    const apasCards = [
        ["Planning", "Set annual targets, KRAs, and expected service standards."],
        ["Commitment", "Capture supervisor and officer agreement on outputs and evidence."],
        ["Mid-Year Review", "Review progress, barriers, and target corrections."],
        ["Final Assessment", "Rate delivery, archive evidence, and trigger next-cycle actions."]
    ];
    $("#apasBoard").innerHTML = apasCards.map(([title, note]) => `
        <article class="timeline-card">
            <strong>${escapeHtml(title)}</strong>
            <p>${escapeHtml(note)}</p>
        </article>
    `).join("");

    if (departments.size) {
        $("#jdDirectory").innerHTML = [...departments.entries()].map(([department, employees]) => `
            <article class="list-card">
                <strong>${escapeHtml(department)}</strong>
                <p>${employees.length} staff records</p>
                <div>${employees.slice(0, 6).map((employee) => `<span class="chip">${escapeHtml(employee.positionTitle || "Unassigned role")}</span>`).join(" ")}</div>
            </article>
        `).join("");

        $("#orgStructure").innerHTML = [...departments.entries()].map(([department, employees]) => `
            <article class="org-card">
                <strong>${escapeHtml(department)}</strong>
                <p>${employees.length} position records</p>
                <ul>${employees.slice(0, 10).map((employee) => `<li>${escapeHtml(employee.name)} <span class="table-note">${escapeHtml(employee.positionTitle || "No title")}</span></li>`).join("")}</ul>
            </article>
        `).join("");
    } else {
        renderNotice("#jdDirectory", state.isLoadingEmployees
            ? "Loading employee positions for the performance workspace..."
            : (state.token
                ? (state.employees === null
                    ? "Employee directory data loads on demand to keep the main dashboard fast."
                    : "No employee positions were returned for JD rendering.")
                : "Sign in with access to employees to build the JD directory."));
        renderNotice("#orgStructure", state.isLoadingEmployees
            ? "Loading department structure for this workspace..."
            : (state.token
                ? (state.employees === null
                    ? "Department structure loads when the performance tab is opened."
                    : "No employee department data was returned.")
                : "Sign in with access to employees to view department structure."));
    }
}

function renderSalaryAdvance() {
    const salaryAdvancePolicy = state.globalPolicies?.policies?.salaryAdvance;
    const content = state.salaryAdvanceRequests?.content || [];
    const totalRequested = content.reduce((sum, item) => sum + Number(item.requestedAmount || 0), 0);
    const profile = state.activeProfile;

    $("#salaryAdvanceSummary").innerHTML = [
        { value: String(salaryAdvancePolicy?.policyCount ?? 0), label: "Policy versions", note: "Loaded from current policy snapshot." },
        { value: String(content.length), label: "Visible requests", note: "Current page after status filter." },
        { value: money.format(totalRequested || 0), label: "Requested value", note: (profile?.priorityMetrics || [])[3] || "Sum of visible request values." },
        { value: String(state.pendingDeductions?.pendingDeductionCount ?? state.pendingDeductions?.items?.length ?? 0), label: "Pending deductions", note: state.pendingDeductions ? `${state.selectedAuthorityType} deduction exposure.` : (state.token ? "Loaded on demand to keep finance views responsive." : "Requires sign in.") }
    ].map(renderMetricCard).join("");

    const workflow = salaryAdvancePolicy?.workflowPath || [
        "Applicant",
        "Eligibility Check",
        "Head of Institution",
        "Finance",
        "Disbursement"
    ];
    $("#salaryAdvanceWorkflow").innerHTML = workflow.map((step, index) => `
        <article class="timeline-card">
            <strong>Step ${index + 1}</strong>
            <p>${escapeHtml(step)}</p>
        </article>
    `).join("");

    renderSalaryAdvanceRequestForm();
    renderSalaryAdvanceTracking();

    if (state.pendingDeductions?.items?.length) {
        renderTable("#pendingDeductions", ["Employee", "Pay Period", "Installment", "Amount", "Status"], state.pendingDeductions.items.slice(0, 10).map((item) => [
            [item.employeeCode, item.employeeName].filter(Boolean).join(" / ") || "-",
            formatDate(item.scheduledPayPeriod),
            `${item.installmentNo}/${item.totalInstallments}`,
            money.format(Number(item.deductionAmount || 0)),
            badge(item.status || "pending")
        ]));
    } else {
        renderNotice("#pendingDeductions", !state.token
            ? "Sign in to inspect pending deductions."
            : state.pendingDeductions === null
                ? "Pending deduction data is currently unavailable. Refresh again when the payroll backend is reachable."
                : "No pending deduction rows were returned for the current pay period.");
    }

    if (content.length) {
        renderTable("#salaryAdvanceTable", ["Request", "Employee", "Amount", "Installments", "Eligibility", "Status", "Actions"], content.map((item) => [
            item.requestNumber || `Request ${item.id}`,
            [item.employeeCode, item.employeeName].filter(Boolean).join(" / ") || "-",
            money.format(Number(item.requestedAmount || 0)),
            String(item.requestedInstallments || "-"),
            badge(item.eligibilityStatus || "pending", normalizeStatusValue(item.eligibilityStatus) === "INELIGIBLE"),
            badge(item.status || "-", normalizeStatusValue(item.status).includes("REJECT") || normalizeStatusValue(item.status).includes("FAILED")),
            buildSalaryAdvanceActions(item)
        ]));
        renderPagination("#salaryAdvanceTablePager", state.salaryAdvanceRequests, "gotoSalaryAdvancePage", "salary advance request");
    } else {
        renderPagination("#salaryAdvanceTablePager", null, "gotoSalaryAdvancePage", "salary advance request");
        renderNotice("#salaryAdvanceTable", !state.token
            ? "Sign in to view salary advance requests."
            : state.salaryAdvanceRequests === null
                ? "Salary advance workflow data is temporarily unavailable. The approval path above remains visible while the register reconnects."
                : "No salary advance requests matched the current filter.");
    }
}

function renderPayslips() {
    const history = Array.isArray(state.payrollHistory) ? state.payrollHistory : [];
    const latest = history[0];
    const cumulativeNet = history.reduce((sum, item) => sum + Number(item.netPay || 0), 0);
    const summaryRoot = $("#payslipSummary");
    const metaRoot = $("#payslipMeta");

    if (summaryRoot) {
        summaryRoot.innerHTML = [
            { value: String(history.length), label: "Monthly records", note: "Processed payslips accumulate here month by month." },
            { value: latest ? formatMonth(latest.payPeriod) : (state.token ? "Awaiting payroll" : "Locked"), label: "Latest month", note: latest ? "Most recent processed payroll period." : "Visible after payroll is processed." },
            { value: history.length ? money.format(cumulativeNet) : (state.token ? money.format(0) : "Sign in"), label: "Cumulative net pay", note: "Sum of loaded monthly payslips." },
            { value: "View / Download / Print", label: "Actions", note: "Each payslip can be opened, saved, or printed." }
        ].map(renderMetricCard).join("");
    }

    if (metaRoot) {
        metaRoot.textContent = state.token
            ? `${state.selectedAuthorityType} dashboard | ${history.length} monthly payslip record(s)`
            : "Sign in to access personal monthly payslips";
    }

    if (history.length) {
        renderTable("#payslipTable", ["Month", "Employee", "Base Salary", "Deductions", "Net Pay", "Actions"], history.map((item) => [
            formatMonth(item.payPeriod),
            [item.employeeCode, item.employeeId].filter(Boolean).join(" / ") || "-",
            money.format(Number(item.baseSalary || 0)),
            money.format(Number(item.deductions || 0)),
            money.format(Number(item.netPay || 0)),
            `<div class="doc-actions">
                <button class="ghost-button" type="button" onclick="openPayslipView(${Number(item.id)})">View</button>
                <button class="ghost-button" type="button" onclick="downloadPayslip(${Number(item.id)})">Download</button>
                <button class="ghost-button" type="button" onclick="printPayslip(${Number(item.id)})">Print</button>
            </div>`
        ]));
    } else {
        renderNotice("#payslipTable", state.token
            ? "No payslip records are available yet. New monthly payroll runs will accumulate here automatically."
            : "Sign in to view, download, or print your monthly payslips.");
    }
}

function getPayslipRecord(recordId) {
    return (state.payrollHistory || []).find((item) => Number(item.id) === Number(recordId)) || null;
}

function buildPayslipMarkup(record) {
    const overtimeHours = Number(record.overtimeHours || 0);
    const overtimeRate = Number(record.overtimeRate || 0);
    const overtimeValue = overtimeHours * overtimeRate;

    return `<!doctype html>
<html lang="${escapeHtml(state.language)}" dir="${escapeHtml(state.direction)}">
<head>
    <meta charset="utf-8" />
    <title>Payslip ${escapeHtml(record.employeeCode || record.employeeId || "employee")} - ${escapeHtml(formatMonth(record.payPeriod))}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 32px; color: #16303a; }
        .sheet { max-width: 760px; margin: 0 auto; border: 1px solid #cfe6ea; border-radius: 16px; padding: 24px; }
        h1 { margin: 0 0 6px; color: #0a5b8f; }
        p { margin: 4px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 18px; }
        th, td { padding: 10px 12px; border-bottom: 1px solid #d9e8ec; text-align: left; }
        th { color: #0a5b8f; text-transform: uppercase; font-size: 12px; }
        .total { font-weight: 700; color: #5b2b2f; }
    </style>
</head>
<body>
    <section class="sheet">
        <h1>Monthly Payslip</h1>
        <p><strong>Pay period:</strong> ${escapeHtml(formatMonth(record.payPeriod))}</p>
        <p><strong>Employee:</strong> ${escapeHtml(record.employeeCode || `Employee ${record.employeeId || ""}`)}</p>
        <p><strong>Generated:</strong> ${escapeHtml(formatDateTime(record.generatedAt))}</p>
        <table>
            <thead>
                <tr><th>Description</th><th>Value</th></tr>
            </thead>
            <tbody>
                <tr><td>Base salary</td><td>${escapeHtml(money.format(Number(record.baseSalary || 0)))}</td></tr>
                <tr><td>Overtime hours</td><td>${escapeHtml(overtimeHours.toFixed(2))}</td></tr>
                <tr><td>Overtime value</td><td>${escapeHtml(money.format(overtimeValue || 0))}</td></tr>
                <tr><td>Deductions</td><td>${escapeHtml(money.format(Number(record.deductions || 0)))}</td></tr>
                <tr class="total"><td>Net pay</td><td>${escapeHtml(money.format(Number(record.netPay || 0)))}</td></tr>
            </tbody>
        </table>
    </section>
</body>
</html>`;
}

function openPayslipView(recordId) {
    const record = getPayslipRecord(recordId);
    if (!record) {
        alert("The selected payslip could not be found.");
        return;
    }

    const view = window.open("", "_blank", "noopener");
    if (!view) {
        alert("Please allow pop-ups to view the payslip.");
        return;
    }

    view.document.open();
    view.document.write(buildPayslipMarkup(record));
    view.document.close();
}

function downloadPayslip(recordId) {
    const record = getPayslipRecord(recordId);
    if (!record) {
        alert("The selected payslip could not be found.");
        return;
    }

    const blob = new Blob([buildPayslipMarkup(record)], { type: "text/html;charset=utf-8" });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = `payslip-${(record.employeeCode || record.employeeId || "employee").toString().replace(/[^a-zA-Z0-9_-]+/g, "-")}-${record.payPeriod || "period"}.html`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(link.href);
}

function printPayslip(recordId) {
    const record = getPayslipRecord(recordId);
    if (!record) {
        alert("The selected payslip could not be found.");
        return;
    }

    const view = window.open("", "_blank", "noopener");
    if (!view) {
        alert("Please allow pop-ups to print the payslip.");
        return;
    }

    view.document.open();
    view.document.write(buildPayslipMarkup(record));
    view.document.close();
    view.onload = () => {
        view.focus();
        view.print();
    };
}

window.openPayslipView = openPayslipView;
window.downloadPayslip = downloadPayslip;
window.printPayslip = printPayslip;

function renderEmployeeDocuments() {
    const docs = (state.employeeDocuments || []).filter((item) => REQUIRED_DOCUMENT_KEYS.has(String(item.key || "").toLowerCase()));
    const byKey = new Map(docs.map((item) => [String(item.key || "").toLowerCase(), item]));
    const orderedDocs = ["terms", "disciplinary", "grievance"].map((key) => byKey.get(key)).filter(Boolean);

    const summaryRoot = $("#documentsSummary");
    if (summaryRoot) {
        summaryRoot.innerHTML = [
            { value: String(orderedDocs.length), label: "Published Documents", note: "Official employee documents available now." },
            { value: "3", label: "Required Documents", note: "Terms, Disciplinary code, and Grievance procedure." },
            { value: state.token ? "Authenticated" : "Public", label: "Visibility", note: "Available on every dashboard, with or without login." }
        ].map(renderMetricCard).join("");
    }

    const metaRoot = $("#documentsMeta");
    if (metaRoot) {
        metaRoot.textContent = `${state.selectedAuthorityType} dashboard | Employee policy library`;
    }

    const errorRoot = $("#documentsError");
    if (errorRoot) {
        errorRoot.classList.add("is-hidden");
        errorRoot.innerHTML = "";
    }

    const grid = $("#employeeDocumentsGrid");
    if (!grid) {
        return;
    }

    if (!state.employeeDocuments) {
        if (state.isLoadingDocuments) {
            renderNotice("#employeeDocumentsGrid", "Employee documents are loading in the background for faster startup.");
        } else {
            renderNotice("#employeeDocumentsGrid", "Employee documents are currently unavailable.");
            if (errorRoot) {
                errorRoot.classList.remove("is-hidden");
                errorRoot.innerHTML = "<strong>Document load issue</strong><span>The employee policy documents endpoint did not return records.</span>";
            }
        }
        return;
    }

    if (!orderedDocs.length) {
        renderNotice("#employeeDocumentsGrid", "No required employee documents were returned by the server.");
        return;
    }

    grid.innerHTML = orderedDocs.map((doc) => {
        const available = Boolean(doc.available);
        const title = escapeHtml(doc.title || doc.key || "Document");
        const description = escapeHtml(doc.description || "Official employee document.");
        const category = escapeHtml(doc.category || "policy");
        const key = escapeHtml(String(doc.key || ""));
        const unavailableTag = available ? "" : "<span class=\"chip warn\">Not available</span>";
        const actions = available
            ? `
                <div class=\"doc-actions\">
                    <button class=\"ghost-button\" type=\"button\" onclick=\"openEmployeeDocument('${key}', 'view')\">View</button>
                    <button class=\"ghost-button\" type=\"button\" onclick=\"downloadEmployeeDocument('${key}')\">Download</button>
                    <button class=\"ghost-button\" type=\"button\" onclick=\"printEmployeeDocument('${key}')\">Print</button>
                </div>
            `
            : "";

        return `
            <article class=\"document-card${available ? "" : " unavailable"}\">
                <span class=\"chip\">${category}</span>
                <h4>${title}</h4>
                <p>${description}</p>
                ${unavailableTag}
                ${actions}
            </article>
        `;
    }).join("");
}

async function fetchDocumentBlob(key, action) {
    const headers = {};
    if (state.token) {
        headers["Authorization"] = `Bearer ${state.token}`;
    }

    const response = await fetch(`documents/${encodeURIComponent(key)}?action=${encodeURIComponent(action)}`, {
        headers
    });

    if (!response.ok) {
        throw new Error(`Unable to load document (${response.status}).`);
    }

    const blob = await response.blob();
    return { blob, response };
}

async function openEmployeeDocument(key, action = "view") {
    try {
        const { blob } = await fetchDocumentBlob(key, action);
        const blobUrl = URL.createObjectURL(blob);
        window.open(blobUrl, "_blank", "noopener");
    } catch (error) {
        alert(error.message || "Unable to open document.");
    }
}

async function downloadEmployeeDocument(key) {
    try {
        const { blob, response } = await fetchDocumentBlob(key, "download");
        const disposition = response.headers.get("Content-Disposition") || "";
        const filenameMatch = disposition.match(/filename\*?=(?:UTF-8''|\")?([^\";]+)/i);
        const filename = filenameMatch ? decodeURIComponent(filenameMatch[1].replace(/\"/g, "")) : `${key}.pdf`;

        const link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    } catch (error) {
        alert(error.message || "Unable to download document.");
    }
}

async function printEmployeeDocument(key) {
    try {
        const { blob } = await fetchDocumentBlob(key, "print");
        const blobUrl = URL.createObjectURL(blob);
        const frame = document.createElement("iframe");
        frame.style.position = "fixed";
        frame.style.width = "1px";
        frame.style.height = "1px";
        frame.style.opacity = "0";
        frame.style.border = "0";
        frame.src = blobUrl;
        document.body.appendChild(frame);

        frame.onload = () => {
            frame.contentWindow.focus();
            frame.contentWindow.print();
            setTimeout(() => {
                document.body.removeChild(frame);
                URL.revokeObjectURL(blobUrl);
            }, 1500);
        };
    } catch (error) {
        alert(error.message || "Unable to print document.");
    }
}

window.openEmployeeDocument = openEmployeeDocument;
window.downloadEmployeeDocument = downloadEmployeeDocument;
window.printEmployeeDocument = printEmployeeDocument;

function buildEmployeeIndex() {
    const index = new Map();
    (state.employees || []).forEach((employee) => {
        index.set(employee.id, {
            name: [employee.firstName, employee.lastName].filter(Boolean).join(" ") || employee.employeeCode || `Employee ${employee.id}`,
            department: employee.department || "Unassigned",
            positionTitle: employee.positionTitle || "Unassigned role"
        });
    });
    return index;
}

function groupEmployeesByDepartment() {
    const groups = new Map();
    const employees = buildEmployeeIndex();
    employees.forEach((employee) => {
        const department = employee.department || "Unassigned";
        if (!groups.has(department)) {
            groups.set(department, []);
        }
        groups.get(department).push(employee);
    });
    groups.forEach((group) => group.sort((left, right) => left.name.localeCompare(right.name)));
    return new Map([...groups.entries()].sort((left, right) => left[0].localeCompare(right[0])));
}

function renderMetricCard(metric) {
    return `
        <article class="metric-card">
            <strong>${escapeHtml(metric.value)}</strong>
            <span>${escapeHtml(metric.label)}</span>
            <p>${escapeHtml(metric.note || "")}</p>
        </article>
    `;
}

function getCollectionItems(value) {
    return Array.isArray(value) ? value : (value?.content || []);
}

function getCollectionTotal(value) {
    return Array.isArray(value) ? value.length : Number(value?.totalElements ?? value?.content?.length ?? 0);
}

function renderPagination(target, pageData, handlerName, label) {
    const root = $(target);
    if (!root) {
        return;
    }

    if (!pageData || Array.isArray(pageData)) {
        root.innerHTML = "";
        return;
    }

    const pageNumber = Number(pageData.number ?? 0);
    const totalPages = Number(pageData.totalPages ?? 0);
    const totalElements = Number(pageData.totalElements ?? 0);
    const pageSize = Number(pageData.size ?? pageData.content?.length ?? 0);
    const numberOfElements = Number(pageData.numberOfElements ?? pageData.content?.length ?? 0);
    const start = totalElements ? (pageNumber * pageSize) + 1 : 0;
    const end = totalElements ? Math.min(totalElements, start + numberOfElements - 1) : 0;

    root.innerHTML = `
        <p class="pager-summary">${escapeHtml(totalElements ? `Showing ${start}-${end} of ${totalElements} ${label}${totalElements === 1 ? "" : "s"}` : `No ${label}s to display`)}.</p>
        <div class="pager-actions">
            <button class="ghost-button" type="button" ${pageNumber <= 0 ? "disabled" : `onclick="${handlerName}(${pageNumber - 1})"`}>Previous</button>
            <button class="ghost-button" type="button" ${totalPages <= 1 || pageNumber >= totalPages - 1 ? "disabled" : `onclick="${handlerName}(${pageNumber + 1})"`}>Next</button>
        </div>
    `;
}

function renderTable(target, headers, rows) {
    $(target).innerHTML = `
        <table>
            <thead>
                <tr>${headers.map((header) => `<th>${escapeHtml(header)}</th>`).join("")}</tr>
            </thead>
            <tbody>
                ${rows.map((row) => `<tr>${row.map((cell) => `<td>${cell}</td>`).join("")}</tr>`).join("")}
            </tbody>
        </table>
    `;
}

function renderNotice(target, message) {
    $(target).innerHTML = `
        <div class="notice">
            <strong>Workspace note</strong>
            <span>${escapeHtml(message)}</span>
        </div>
    `;
}

function badge(text, warning = false) {
    return `<span class="chip${warning ? " warn" : ""}">${escapeHtml(String(text))}</span>`;
}

function syncAuthStatus() {
    if (state.token) {
        const rolesText = state.roles.join(", ") || getLocalizedValue({ en: "Authenticated", fr: "Authentifié", ar: "موثّق", he: "מאומת" });
        const identityNote = state.dashboardIdentity?.positionTitle
            ? getLocalizedValue({
                en: ` Dashboard resolved to ${state.dashboardIdentity.positionTitle} / ${state.dashboardIdentity.authorityType || state.selectedAuthorityType}.`,
                fr: ` Tableau de bord défini sur ${state.dashboardIdentity.positionTitle} / ${state.dashboardIdentity.authorityType || state.selectedAuthorityType}.`,
                ar: ` تم ضبط لوحة المعلومات على ${state.dashboardIdentity.positionTitle} / ${state.dashboardIdentity.authorityType || state.selectedAuthorityType}.`,
                he: ` לוח הבקרה הוגדר ל-${state.dashboardIdentity.positionTitle} / ${state.dashboardIdentity.authorityType || state.selectedAuthorityType}.`
            })
            : "";
        setAuthStatus(getLocalizedValue({
            en: `Signed in as ${state.username}. Roles: ${rolesText}.${identityNote}`,
            fr: `Connecté en tant que ${state.username}. Rôles : ${rolesText}.${identityNote}`,
            ar: `تم تسجيل الدخول باسم ${state.username}. الأدوار: ${rolesText}.${identityNote}`,
            he: `מחובר/ת כ-${state.username}. תפקידים: ${rolesText}.${identityNote}`
        }), false);
    } else {
        setAuthStatus(t("authPublic"), false);
    }
}

function hasAnyRole(...roles) {
    return roles.some((role) => state.roles.includes(role));
}

function normalizeStatusValue(value) {
    return String(value || "")
        .trim()
        .replace(/[^a-zA-Z0-9]+/g, "_")
        .replace(/^_+|_+$/g, "")
        .toUpperCase();
}

function formatLocalDateTimeInput(value) {
    const date = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(date.getTime())) {
        return "";
    }
    const adjusted = new Date(date.getTime() - (date.getTimezoneOffset() * 60000));
    return adjusted.toISOString().slice(0, 16);
}

function setAuthStatus(message, isWarning, isBusy = false) {
    updateStatusNode($("#authStatus"), message, { warning: isWarning, busy: isBusy });
}

function updateQueryString() {
    const params = new URLSearchParams(window.location.search);
    params.set("positionId", state.selectedPositionId);
    params.set("authorityType", state.selectedAuthorityType);
    window.history.replaceState({}, "", `${window.location.pathname}?${params.toString()}`);
}

async function fetchJson(path, options = {}, authenticated = false) {
    const {
        timeoutMs = REQUEST_TIMEOUT_MS,
        cacheTtlMs = authenticated ? PROTECTED_REQUEST_CACHE_TTL_MS : PUBLIC_REQUEST_CACHE_TTL_MS,
        bypassCache = false,
        ...fetchOptions
    } = options;

    const headers = new Headers(fetchOptions.headers || {});
    if (authenticated && state.token) {
        headers.set("Authorization", `Bearer ${state.token}`);
    }

    const method = String(fetchOptions.method || "GET").toUpperCase();
    if (!["GET", "HEAD", "OPTIONS", "TRACE"].includes(method)) {
        const csrfToken = getCookie("XSRF-TOKEN");
        if (csrfToken && !headers.has("X-XSRF-TOKEN")) {
            headers.set("X-XSRF-TOKEN", csrfToken);
        }
    }

    const cacheKey = method === "GET" && !bypassCache
        ? buildRequestCacheKey(path, authenticated)
        : null;

    if (cacheKey && cacheTtlMs > 0) {
        const cached = getCachedJsonResponse(cacheKey, cacheTtlMs);
        if (cached) {
            return cached;
        }
        if (inflightJsonRequests.has(cacheKey)) {
            return inflightJsonRequests.get(cacheKey);
        }
    }

    const requestPromise = (async () => {
        const controller = typeof AbortController !== "undefined" ? new AbortController() : null;
        const timeoutHandle = controller && timeoutMs > 0
            ? window.setTimeout(() => controller.abort(), timeoutMs)
            : null;

        try {
            const response = await fetch(path, {
                ...fetchOptions,
                headers,
                credentials: "same-origin",
                ...(controller ? { signal: controller.signal } : {})
            });
            if (!response.ok) {
                let message = `${response.status} ${response.statusText}`;
                try {
                    const payload = await response.json();
                    message = payload.message || payload.error || message;
                } catch (error) {
                }
                throw new Error(message);
            }

            const payload = await response.json();
            if (cacheKey && cacheTtlMs > 0) {
                setCachedJsonResponse(cacheKey, payload);
            }
            if (method !== "GET") {
                clearJsonResponseCache();
            }
            return payload;
        } catch (error) {
            if (error?.name === "AbortError") {
                throw new Error(getLocalizedValue({
                    en: "The request took too long. The dashboard switched to its cached or reduced-data view.",
                    fr: "La requête a pris trop de temps. Le tableau est repassé sur sa vue réduite ou en cache.",
                    ar: "استغرقت العملية وقتاً طويلاً. تم التحويل إلى العرض المخزن أو المخفف.",
                    he: "הבקשה ארכה זמן רב מדי. לוח הבקרה עבר לתצוגת מטמון/תצוגה מצומצמת."
                }));
            }
            throw error;
        } finally {
            if (timeoutHandle) {
                window.clearTimeout(timeoutHandle);
            }
            if (cacheKey) {
                inflightJsonRequests.delete(cacheKey);
            }
        }
    })();

    if (cacheKey && cacheTtlMs > 0) {
        inflightJsonRequests.set(cacheKey, requestPromise);
    }

    return requestPromise;
}

function getCurrencyFormatter() {
    const config = getLocaleConfig();
    return new Intl.NumberFormat(state.locale || config.locale, {
        style: "currency",
        currency: state.currency || config.currency || "ZMW",
        maximumFractionDigits: 2
    });
}

function toDateValue(value) {
    if (!value) {
        return null;
    }
    if (value instanceof Date) {
        return value;
    }
    const normalized = typeof value === "string" && /^\d{4}-\d{2}-\d{2}$/.test(value)
        ? `${value}T00:00:00`
        : value;
    const date = new Date(normalized);
    return Number.isNaN(date.getTime()) ? null : date;
}

function formatDate(value) {
    if (!value) {
        return "-";
    }
    const date = toDateValue(value);
    if (!date) {
        return String(value);
    }
    return new Intl.DateTimeFormat(state.locale, { year: "numeric", month: "short", day: "numeric" }).format(date);
}

function formatDateTime(value) {
    if (!value) {
        return "-";
    }
    const date = toDateValue(value);
    if (!date) {
        return String(value);
    }
    return new Intl.DateTimeFormat(state.locale, { dateStyle: "medium", timeStyle: "short" }).format(date);
}

function formatMonth(value) {
    if (!value) {
        return "-";
    }
    const date = toDateValue(value);
    if (!date) {
        return String(value);
    }
    return new Intl.DateTimeFormat(state.locale, { year: "numeric", month: "long" }).format(date);
}

function getCookie(name) {
    const prefix = `${name}=`;
    return document.cookie.split(";")
        .map((item) => item.trim())
        .find((item) => item.startsWith(prefix))
        ?.slice(prefix.length) || "";
}

function escapeHtml(value) {
    return String(value ?? "")
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#39;");
}