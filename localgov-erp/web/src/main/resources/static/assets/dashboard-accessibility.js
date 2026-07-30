/**
 * dashboard-accessibility.js
 *
 * Extracted keyboard navigation, ARIA handling, and focus management from erp-dashboard.js.
 * Exposes a global `DashboardAccessibility` object so it can be wired into any HTML page.
 */
const DashboardAccessibility = (function () {
    "use strict";

    function setFieldState(element, message) {
        message = message || "";
        if (!element || typeof element.setAttribute !== "function") {
            return;
        }

        var container = element.closest ? element.closest("label, .form-group, .field") : null;
        var helpNode = container ? container.querySelector(".field-hint, .form-hint, .error-text, small.table-note, .table-note") : null;

        if (helpNode && !helpNode.dataset.defaultMessage) {
            helpNode.dataset.defaultMessage = helpNode.textContent;
        }

        var hasMessage = Boolean(message);
        element.setAttribute("aria-invalid", hasMessage ? "true" : "false");
        if (container) { container.classList.toggle("has-error", hasMessage); }

        if (helpNode) {
            helpNode.textContent = hasMessage ? message : (helpNode.dataset.defaultMessage || "");
            helpNode.classList.toggle("error-text", hasMessage);
        }
    }

    function clearFieldStates() {
        var elements = [];
        for (var i = 0; i < arguments.length; i++) {
            elements = elements.concat(arguments[i] || []);
        }
        elements.forEach(function (element) { setFieldState(element, ""); });
    }

    function bindTabs(options) {
        var buttonSelector = options.buttonSelector || ".tab-button";
        var panelSelector = options.panelSelector || ".module-panel";
        var onActivate = typeof options.onActivate === "function" ? options.onActivate : null;
        var initialTab = options.initialTab;

        var buttons = [].slice.call(document.querySelectorAll(buttonSelector));
        var panels = [].slice.call(document.querySelectorAll(panelSelector));

        if (!buttons.length || !panels.length) {
            return;
        }

        function activate(button, moveFocus) {
            buttons.forEach(function (item) {
                var isActive = item === button;
                item.classList.toggle("is-active", isActive);
                item.classList.toggle("active", isActive);

                if (item.getAttribute("role") === "tab") {
                    item.setAttribute("aria-selected", String(isActive));
                    item.setAttribute("tabindex", isActive ? "0" : "-1");
                }
            });

            panels.forEach(function (panel) {
                var isActive = (panel.dataset.panel === button.dataset.tab) || (panel.id === button.dataset.tab);
                panel.classList.toggle("is-active", isActive);
                panel.classList.toggle("active", isActive);
                panel.hidden = !isActive;

                if (panel.getAttribute("role") === "tabpanel") {
                    panel.setAttribute("aria-hidden", String(!isActive));
                }
            });

            if (onActivate) {
                onActivate(button.dataset.tab || button.dataset.panel || button.id, button);
            }

            if (moveFocus) {
                button.focus();
            }
        }

        buttons.forEach(function (button, index) {
            button.addEventListener("click", function () { activate(button); });

            button.addEventListener("keydown", function (event) {
                var nextIndex = null;

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
                    activate(button, true);
                    return;
                }

                if (nextIndex !== null) {
                    event.preventDefault();
                    activate(buttons[nextIndex], true);
                }
            });
        });

        var initialButton = initialTab
            ? buttons.find(function (button) { return button.dataset.tab === initialTab || button.dataset.panel === initialTab; })
            : buttons.find(function (button) { return button.classList.contains("is-active") || button.classList.contains("active"); });

        activate(initialButton || buttons[0]);
    }

    return {
        setFieldState: setFieldState,
        clearFieldStates: clearFieldStates,
        bindTabs: bindTabs
    };
})();
