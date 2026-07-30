# International-Grade Payslip & Self-Service Portal Specification

## 1) Purpose
This specification defines:
- A production-ready payslip format for Zambia local government payroll context.
- International best-practice enhancements for transparency, privacy, and auditability.
- Self-service portal requirements for view, print, and download.

Authority branding rule:
- Payslip branding must use the employee's Local Authority employer name only.
- Do not display `Local Government Service Commission` in the payslip header or employer identity block.
- The payslip header, logo, verification domain, and employer registration details must resolve dynamically from the employee's assigned Local Authority.
- The solution must support all 116 Local Authorities.

## 2) Design Principles
- Clarity: Employee can independently validate gross, taxable pay, deductions, and net pay.
- Compliance: PAYE, NAPSA, NHIMA, and employer obligations are explicit.
- Privacy: Sensitive identifiers masked by default.
- Verifiability: Every payslip can be authenticated and traced.
- Accessibility: Works across desktop/mobile, screen readers, and low-bandwidth contexts.

## 3) International-Grade Payslip Layout (Improved)

### Header
- Local Authority legal name and logo.
- Payroll period label (e.g., PAYSLIP - JUNE 2025).
- Pay period dates.
- Payslip number (unique, immutable).
- Verification code (human-friendly short code) + QR verification token.
- Processing timestamp (ISO 8601 with timezone).

Header branding rule:
- Example: `KAFUE TOWN COUNCIL` appears as the employer name if the employee belongs to Kafue Town Council.
- No shared umbrella body name should appear above or below the authority name.

### Employee and Employer Identity Block
Employee side:
- Full name.
- Employee number.
- Department / Cost center.
- Grade, division, step/notch.
- Employment type (permanent/contract/probation).
- Masked IDs: NRC, TPIN, NAPSA, NHIMA.

Employer side:
- Local Authority legal name.
- Employer TPIN.
- Employer NAPSA registration.
- Employer NHIMA registration (if applicable).
- Employer physical address/contact.

Authority identity source:
- Employer identity must come from the employee's Local Authority master record.
- Required branding fields per authority: official name, short code, logo, TPIN, NAPSA registration, NHIMA registration (if available), address, payroll contact email, verification domain.

### Earnings Block
Columns:
- Code, description, units, rate (optional), amount.

Include:
- Basic salary.
- Housing allowance (visible, non-taxable).
- Other taxable allowances.
- Other non-taxable allowances.
- Overtime/arrears/bonuses (if applicable).

Subtotals (required):
- Total earnings.
- Taxable allowances subtotal.
- Non-taxable allowances subtotal.

### Statutory & Other Deductions Block
Columns:
- Code, description, authority/reference, amount.

Include at minimum:
- PAYE.
- NAPSA employee contribution.
- NHIMA employee contribution.
- Other approved deductions (loan, salary advance, union, levy, funeral policy, etc.).

Subtotals (required):
- Total statutory deductions.
- Total non-statutory deductions.
- Total deductions.

### Employer Contributions Block (Recommended International Practice)
This is not deducted from employee net pay but should be visible:
- NAPSA employer contribution.
- NHIMA employer contribution.
- Total employer statutory contribution.

### Pay Summary Block (Required)
- Basic salary.
- Total earnings.
- Gross salary.
- Taxable pay.
- Non-taxable pay.
- Total deductions.
- Net pay.

### Payment & Leave Block
Payment details:
- Payment method.
- Bank name.
- Masked account number.
- Payment reference.
- Value date.

Leave summary:
- Current balances by leave type.
- Policy cap(s).

### YTD (Year-to-Date) Block (Strong Best Practice)
- YTD gross.
- YTD taxable pay.
- YTD PAYE.
- YTD NAPSA employee.
- YTD NHIMA employee.
- YTD net pay.

### Verification / Legal Footer
- Statement: system-generated valid without wet signature.
- Digital signature/hash reference.
- Verification URL + QR code.
- Contact for payroll queries.
- Data privacy notice (minimal).

---

## 4) Calculation Rules (Aligned to Your Current Direction)

### 4.1 Earnings and Taxable Pay
- Housing allowance = 20% of basic salary.
- Housing allowance appears on payslip.
- Housing allowance is non-taxable.
- Taxable pay = basic salary + taxable allowances (exclude housing).
- Gross salary = basic salary + all allowances.

### 4.2 Statutory Contributions
- NAPSA employee = 5% of basic.
- NAPSA employer = 5% of basic.
- NHIMA employee = 1% of gross.
- NHIMA employer = 1% of gross.
- PAYE = computed from taxable pay per approved tax bands/rules.

### 4.3 Net Pay
- Total deductions = PAYE + NAPSA employee + NHIMA employee + other deductions.
- Net pay = gross salary - total deductions.

---

## 5) Data Masking Standard
- NRC: show first 3 and last 1, mask middle.
- TPIN: show first 3 and last 3, mask middle.
- NAPSA/NHIMA number: show first 3 and last 2, mask middle.
- Bank account: show only last 4.

Masking should apply to:
- Portal UI default view.
- Downloaded PDF (unless explicit role-based override).
- Printed version.

---

## 6) Self-Service Portal Best-Practice Checklist

## 6.1 Access & Identity
- [ ] MFA enabled for employee and admin accounts.
- [ ] RBAC enforced (employee sees only own payslips).
- [ ] Session timeout and device revocation supported.

## 6.2 Payslip Experience
- [ ] Employee can view payslip in-browser.
- [ ] Employee can print with print-optimized layout.
- [ ] Employee can download PDF.
- [ ] Payslip list supports period filter and search.
- [ ] Mobile-responsive rendering.

## 6.3 Security & Integrity
- [ ] PDF is tamper-evident (hash/QR/verification token).
- [ ] Verification endpoint confirms authenticity and status.
- [ ] Immutable payslip archive after payroll finalization.
- [ ] All view/print/download actions logged (audit trail).

## 6.4 Compliance & Records
- [ ] Retention policy configured (e.g., statutory minimum years).
- [ ] Payslip regeneration from source snapshot is deterministic.
- [ ] Correction flow uses reversal/adjustment payslip, not overwrite.
- [ ] Legal references shown for statutory deductions.

## 6.5 Usability & Accessibility
- [ ] WCAG-oriented color contrast and font sizing.
- [ ] Screen-reader labels for tables and totals.
- [ ] Consistent currency formatting (ZMW, 2 decimals).
- [ ] Clear error/support channel in portal.

## 6.6 Operations
- [ ] Payroll lock state enforced after approval.
- [ ] Batch PDF generation available for HR/payroll admins.
- [ ] Monitoring alerts for failed generation/export jobs.
- [ ] Daily backup and restore tests for payroll artifacts.

---

## 7) API / Data Contract (Recommended)

Required payload sections for payslip rendering:
- `header`: employer, period, payslip_no, verification_code, generated_at.
- `employee`: identity + masked statutory IDs.
- `employer`: registration numbers and address.
- `earnings`: line items + totals.
- `deductions`: line items + statutory/non-statutory totals.
- `employer_contributions`: NAPSA/NHIMA employer obligations.
- `summary`: gross, taxable, non-taxable, deductions, net.
- `payment`: bank/ref/value_date.
- `leave`: balances.
- `ytd`: annual totals.
- `verification`: qr_token, verify_url, signature/hash metadata.

Required authority branding fields inside `header` / `employer`:
- `authority_id`
- `authority_name`
- `authority_code`
- `authority_logo_url`
- `authority_tpin`
- `authority_napsa_number`
- `authority_nhima_number`
- `authority_address`
- `authority_contact_email`
- `verification_base_url`

---

## 8) Suggested Acceptance Criteria
A payslip is release-ready when:
1. All arithmetic reconciles exactly to 2 decimals.
2. Taxable pay excludes housing allowance.
3. Employee and employer statutory contributions are both visible (separate sections).
4. PDF downloaded by employee matches on-screen values exactly.
5. Verification URL confirms code and shows status = valid.
6. Audit logs show who viewed/printed/downloaded and when.

---

## 9) Gap-to-Implementation Guide (Current ERP)
Priority order:
1. Implement PAYE band engine and make `paye_amount` derive from taxable pay bands.
2. Keep housing visible and non-taxable (already aligned).
3. Add Local Authority branding configuration so each payslip renders with the correct authority name/logo/contact for all 116 authorities.
4. Ensure payslip renderer includes employer contributions section.
5. Add YTD aggregation fields in payroll history tables/views.
6. Expose verification endpoint for payslip authenticity checks.
7. Add portal print CSS + signed PDF generation.

---

## 10) Recommended Final Payslip Sections (Display Order)
1. Header + verification
2. Employee/employer identity
3. Earnings
4. Deductions
5. Employer contributions
6. Pay summary
7. Payment + leave
8. YTD totals
9. Verification footer

This order is internationally recognizable, audit-friendly, and employee-readable.
