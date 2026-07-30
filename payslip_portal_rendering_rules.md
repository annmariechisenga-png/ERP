# Payslip Portal Rendering Rules

## 1. Branding Rules
- Render only the employee's Local Authority name in the header.
- Do not render `Local Government Service Commission` anywhere on the payslip.
- Resolve logo, employer TPIN, employer NAPSA/NHIMA numbers, verification domain, and contact email from the authority master record.
- Support all 116 Local Authorities using the same component and payload contract.

## 2. Screen Layout Rules
Top section order:
1. Authority logo + authority name
2. Payslip title and pay period
3. Payslip number + verification code
4. Employee/employer identity block

Middle section order:
1. Earnings table
2. Deductions table
3. Employer contributions table
4. Pay summary card

Bottom section order:
1. Payment details
2. Leave summary
3. YTD summary
4. Verification footer

## 3. Display Rules
- Currency format: `ZMW 12,345.67` or `12,345.67` with header `Amount (ZMW)`.
- Dates: `DD/MM/YYYY` in UI and printed PDF.
- Negative adjustments must display with minus sign and distinct styling.
- `Housing Allowance` must appear under earnings and remain non-taxable.
- Employer contributions must appear in a separate non-deductible section.
- Hide any earnings item where `visibleOnPayslip=false`.
- Always show `taxablePay` and `grossSalary` in summary.

## 4. Arithmetic Rules
UI must reconcile exactly:
- `totalEarnings = sum(earnings.items.amount where visibleOnPayslip=true or included in total)`
- `grossSalary = basicSalary + all earnings amounts`
- `taxablePay = basicSalary + taxable earnings amounts`
- `totalDeductions = totalStatutory + totalOther`
- `netPay = grossSalary - totalDeductions`

If any reconciliation fails, the payslip should not render as final.

## 5. Masking Rules
- NRC, TPIN, NAPSA, NHIMA, bank account numbers must be masked in UI and PDF.
- Only authorized payroll administrators may view unmasked values.

## 6. Print and Download Rules
- Print view must remove portal navigation and action buttons.
- PDF must match on-screen values exactly.
- PDF must include verification URL and QR code.
- PDF should include generated timestamp and signature status.

## 7. Employee Actions
Employees must be able to:
- View current and historical payslips.
- Print a payslip.
- Download a payslip as PDF.
- Verify authenticity through the verification code / QR flow.

## 8. Security and Audit Rules
- Every payslip view event must be logged with user ID, timestamp, and IP/device metadata when available.
- Every print/download action must be logged.
- Finalized payslips must be immutable.
- Corrected payslips must be issued as superseding versions, not overwritten artifacts.

## 9. Accessibility Rules
- Use semantic headings and tables.
- Meet readable contrast ratios.
- Ensure keyboard navigation for all actions.
- Provide screen-reader labels for summary values and verification controls.

## 10. API-to-UI Mapping
- `header.authorityName` -> top banner authority name
- `header.logoUrl` -> authority logo
- `employee.*` -> employee identity block
- `employer.*` -> employer identity block
- `earnings.items[]` -> earnings table
- `deductions.items[]` -> deductions table
- `employerContributions.items[]` -> employer contributions table
- `summary.*` -> pay summary card
- `payment.*` -> payment block
- `leave.items[]` -> leave block
- `ytd.*` -> YTD summary
- `verification.*` -> footer and QR verification

## 11. Minimum Portal Acceptance Criteria
- Employee can open payslip in browser in under 3 seconds on normal connection.
- Employee can print without broken page sections.
- Employee can download signed PDF.
- Values on UI, PDF, and verification endpoint are identical.
- Payslip branding changes correctly by authority without code changes.
