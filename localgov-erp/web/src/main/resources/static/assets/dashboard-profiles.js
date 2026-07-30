/**
 * dashboard-profiles.js
 *
 * Extracted dashboard-profile logic from erp-dashboard.js:
 *   positionProfileSelect, authorityTypeSelect, profile loading, identity application,
 *   selector syncing, and profile rendering.
 *
 * Exposes a global `DashboardProfiles` object so it can be wired into any HTML page.
 */
const DashboardProfiles = (function () {
    "use strict";

    var state = {
        dashboardProfiles: null,
        selectedPositionId: "DIRECTOR_HR_ADMIN",
        selectedAuthorityType: "Town Council",
        activeProfile: null,
        dashboardIdentity: null,
        token: ""
    };

    var apiBase = "";

    function $(selector) {
        return document.querySelector(selector);
    }

    function escapeHtml(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    function t(key, replacements) {
        replacements = replacements || {};
        var fn = (typeof DashboardI18n !== "undefined" && DashboardI18n.t) ? DashboardI18n.t : null;
        var text = fn ? fn(key, replacements) : key;
        return text;
    }

    function getLocalizedValue(value) {
        if (typeof value === "string") { return value; }
        if (value === null || typeof value !== "object") { return ""; }
        var lang = (typeof DashboardI18n !== "undefined" && DashboardI18n.getLanguage) ? DashboardI18n.getLanguage() : "en";
        return value[lang] || value.en || "";
    }

    function badge(text, warning) {
        return '<span class="chip' + (warning ? " warn" : "") + '">' + escapeHtml(String(text)) + '</span>';
    }

    function updateQueryString() {
        var params = new URLSearchParams(window.location.search);
        params.set("positionId", state.selectedPositionId);
        params.set("authorityType", state.selectedAuthorityType);
        window.history.replaceState({}, "", window.location.pathname + "?" + params.toString());
    }

    async function fetchJson(path, options) {
        options = options || {};
        var url = apiBase + path;
        if (url.indexOf("http") !== 0 && url.indexOf("/") !== 0) {
            url = "/" + url;
        }
        var headers = new Headers(options.headers || {});
        headers.set("Accept", "application/json");
        headers.set("Content-Type", "application/json");
        if (state.token) {
            headers.set("Authorization", "Bearer " + state.token);
        }
        var response = await fetch(url, {
            method: options.method || "GET",
            headers: headers,
            credentials: "same-origin"
        });
        if (!response.ok) {
            var message = response.status + " " + response.statusText;
            try {
                var payload = await response.json();
                message = payload.message || payload.error || message;
            } catch (e) {}
            throw new Error(message);
        }
        return response.json();
    }

    function renderProfile() {
        var profile = state.activeProfile;
        if (!profile) {
            return;
        }
        setText("#profileTitle", profile.dashboardTitle);
        setText("#profileSummary", profile.dashboardSummary);

        var focusRoot = $("#profileFocusAreas");
        if (focusRoot) {
            focusRoot.innerHTML = (profile.focusAreas || []).map(function (area) { return badge(area); }).join("");
        }

        setText("#leavePanelTitle", profile.positionTitle + " - " + t("navLeave"));
        setText("#holidayPanelTitle", profile.positionTitle + " - " + t("navHolidays"));
        setText("#overtimePanelTitle", profile.positionTitle + " - " + t("navOvertime"));
        setText("#performancePanelTitle", profile.positionTitle + " - " + t("navPerformance"));
        setText("#salaryAdvancePanelTitle", profile.positionTitle + " - " + t("navSalaryAdvance"));
        setText("#payslipPanelTitle", profile.positionTitle + " - " + t("navPayslips"));
    }

    function setText(selector, value) {
        var node = $(selector);
        if (node) {
            node.textContent = value;
        }
    }

    function setInputLabelText(inputId, value) {
        var input = $("#" + inputId);
        var label = input ? input.closest("label") : null;
        var span = label ? label.querySelector("span") : null;
        if (span) {
            span.textContent = value;
        }
    }

    function syncProfileSelectors() {
        var positionSelect = $("#positionProfileSelect");
        var authoritySelect = $("#authorityTypeSelect");
        if (positionSelect && Array.prototype.some.call(positionSelect.options, function (option) {
            return option.value === state.selectedPositionId;
        })) {
            positionSelect.value = state.selectedPositionId;
        }
        if (authoritySelect && Array.prototype.some.call(authoritySelect.options, function (option) {
            return option.value === state.selectedAuthorityType;
        })) {
            authoritySelect.value = state.selectedAuthorityType;
        }
    }

    async function loadProfile() {
        var url = "/dashboard/profile?positionId=" + encodeURIComponent(state.selectedPositionId) + "&authorityType=" + encodeURIComponent(state.selectedAuthorityType);
        state.activeProfile = await fetchJson(url);
        renderProfile();
    }

    async function applyProfile(identity) {
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
        await loadProfile();
        updateQueryString();
    }

    async function loadProfiles() {
        var response = await fetchJson("/dashboard/profiles");
        state.dashboardProfiles = response;

        var positionSelect = $("#positionProfileSelect");
        var authoritySelect = $("#authorityTypeSelect");
        if (!positionSelect || !authoritySelect) {
            return;
        }

        var uniqueProfiles = new Map();
        (response.profiles || []).forEach(function (profile) {
            if (!uniqueProfiles.has(profile.positionId)) {
                uniqueProfiles.set(profile.positionId, profile.positionTitle);
            }
        });

        positionSelect.innerHTML = Array.from(uniqueProfiles.entries()).map(function (entry) {
            return '<option value="' + escapeHtml(entry[0]) + '">' + escapeHtml(entry[0]) + " - " + escapeHtml(entry[1]) + "</option>";
        }).join("");

        authoritySelect.innerHTML = (response.authorityTypes || []).map(function (authorityType) {
            return '<option value="' + escapeHtml(authorityType) + '">' + escapeHtml(authorityType) + "</option>";
        }).join("");

        if (state.dashboardIdentity && state.dashboardIdentity.positionId && uniqueProfiles.has(state.dashboardIdentity.positionId)) {
            state.selectedPositionId = state.dashboardIdentity.positionId;
        }
        if (state.dashboardIdentity && state.dashboardIdentity.authorityType && (response.authorityTypes || []).indexOf(state.dashboardIdentity.authorityType) >= 0) {
            state.selectedAuthorityType = state.dashboardIdentity.authorityType;
        }

        var params = new URLSearchParams(window.location.search);
        var requestedPositionId = params.get("positionId");
        var requestedAuthorityType = params.get("authorityType");
        if (requestedPositionId && uniqueProfiles.has(requestedPositionId)) {
            state.selectedPositionId = requestedPositionId;
        }
        if (requestedAuthorityType && (response.authorityTypes || []).indexOf(requestedAuthorityType) >= 0) {
            state.selectedAuthorityType = requestedAuthorityType;
        }

        positionSelect.value = state.selectedPositionId;
        authoritySelect.value = state.selectedAuthorityType;
        await loadProfile();
    }

    function bindProfileSelectors() {
        var positionSelect = $("#positionProfileSelect");
        var authoritySelect = $("#authorityTypeSelect");
        if (!positionSelect || !authoritySelect) {
            return;
        }
        positionSelect.addEventListener("change", async function (event) {
            state.selectedPositionId = event.target.value;
            await loadProfile();
            updateQueryString();
        });
        authoritySelect.addEventListener("change", async function (event) {
            state.selectedAuthorityType = event.target.value;
            await loadProfile();
            updateQueryString();
        });
    }

    function init(options) {
        options = options || {};
        apiBase = options.apiBase || "";
        state.token = options.token || localStorage.getItem("erp.jwt") || localStorage.getItem("erp_token") || "";

        try {
            var stored = JSON.parse(localStorage.getItem("erp.dashboardIdentity") || "null");
            state.dashboardIdentity = stored;
            if (stored && stored.positionId) { state.selectedPositionId = stored.positionId; }
            if (stored && stored.authorityType) { state.selectedAuthorityType = stored.authorityType; }
        } catch (e) {
            state.dashboardIdentity = null;
        }

        var params = new URLSearchParams(window.location.search);
        if (params.get("positionId")) { state.selectedPositionId = params.get("positionId"); }
        if (params.get("authorityType")) { state.selectedAuthorityType = params.get("authorityType"); }

        bindProfileSelectors();
        return loadProfiles().catch(function (err) { console.error("Failed to load dashboard profiles:", err); });
    }

    return {
        init: init,
        loadProfiles: loadProfiles,
        loadProfile: loadProfile,
        applyProfile: applyProfile,
        bindProfileSelectors: bindProfileSelectors,
        syncProfileSelectors: syncProfileSelectors,
        renderProfile: renderProfile,
        state: state
    };
})();
