# Payslip Backend Endpoint Contract (Self-Service Portal)

## Scope
This contract defines employee self-service and payroll-admin APIs for payslip view/print/download/verification using authority-aware branding.

Base path (suggested): `/api/v1`

Authentication:
- Employee endpoints: JWT bearer token (employee scope).
- Admin endpoints: JWT bearer token (payroll/admin scope).

Common response headers:
- `X-Request-Id`
- `X-Authority-Code`
- `Cache-Control: no-store` (for payslip JSON endpoints)

---

## 1) Employee - List Payslips
`GET /api/v1/self-service/payslips`

Query params:
- `year` (optional, integer)
- `month` (optional, integer 1-12)
- `page` (optional, default 1)
- `size` (optional, default 20)

Response `200`:
```json
{
  "items": [
    {
      "payslipNo": "KTC/2025/06/001234",
      "runCode": "RUN-2025-06",
      "authorityCode": "KTC",
      "authorityName": "KAFUE TOWN COUNCIL",
      "periodLabel": "JUNE 2025",
      "payPeriodStart": "2025-06-01",
      "payPeriodEnd": "2025-06-30",
      "netPay": 13396.07,
      "currency": "ZMW",
      "generatedAt": "2025-06-25T14:30:00+02:00"
    }
  ],
  "page": 1,
  "size": 20,
  "total": 1
}
```

---

## 2) Employee - Get Payslip Payload (UI)
`GET /api/v1/self-service/payslips/{payslipNo}`

Response `200`:
- Must conform to [payslip_portal_payload_schema.json](payslip_portal_payload_schema.json)
- Use authority-specific branding from employee authority mapping.

Errors:
- `403` if payslip does not belong to logged-in employee.
- `404` if not found.

---

## 3) Employee - Download Payslip PDF
`GET /api/v1/self-service/payslips/{payslipNo}/pdf`

Response `200`:
- `Content-Type: application/pdf`
- `Content-Disposition: attachment; filename="{payslipNo}.pdf"`

Rules:
- PDF must equal UI values.
- Include verification code + QR + verification URL.
- Mask sensitive personal fields.

---

## 4) Employee - Print-Friendly HTML
`GET /api/v1/self-service/payslips/{payslipNo}/print`

Response `200`:
- `Content-Type: text/html`
- Print-optimized layout (no nav/actions).

---

## 5) Public/Authenticated - Verify Payslip
`GET /api/v1/payslip/verify?code={verificationCode}`

Response `200`:
```json
{
  "valid": true,
  "verificationCode": "KTC-8F3A-9B2C",
  "payslipNo": "KTC/2025/06/001234",
  "authorityName": "KAFUE TOWN COUNCIL",
  "periodLabel": "JUNE 2025",
  "employeeNoMasked": "KTC***21",
  "generatedAt": "2025-06-25T14:30:00+02:00",
  "signatureStatus": "SIGNED"
}
```

Invalid code response `404`:
```json
{ "valid": false, "message": "Verification code not found" }
```

---

## 6) Admin - Generate Payslips for Run
`POST /api/v1/payroll/runs/{runCode}/payslips/generate`

Request body:
```json
{
  "regenerateMissingOnly": true,
  "lockAfterGeneration": true
}
```

Response `202`:
```json
{
  "accepted": true,
  "runCode": "RUN-2025-06",
  "jobId": "job_8f4b2c"
}
```

---

## 7) Admin - Bulk Download ZIP
`GET /api/v1/payroll/runs/{runCode}/payslips/zip`

Response `200`:
- `Content-Type: application/zip`
- One PDF per employee.

---

## 8) Audit Events (Mandatory)
Record events for:
- `PAYSLIP_VIEWED`
- `PAYSLIP_PRINTED`
- `PAYSLIP_DOWNLOADED`
- `PAYSLIP_VERIFIED`

Audit payload fields:
- `eventType`, `actorUserId`, `employeeId`, `payslipNo`, `authorityCode`, `ipAddress`, `userAgent`, `timestamp`.

---

## 9) Validation Rules
1. `authorityName` and logo must come from employee's authority record.
2. No `Local Government Service Commission` label in payload/UI branding.
3. `taxablePay` excludes housing allowance.
4. `grossSalary`, `totalDeductions`, `netPay` must reconcile exactly.
5. If verification signature is missing/invalid, `signatureStatus` must not show `SIGNED`.

---

## 10) Suggested Storage Model
Core tables/views (minimum):
- `payslip_header` (payslip id, run id, employee id, authority id, verification code)
- `payslip_lines_earnings`
- `payslip_lines_deductions`
- `payslip_lines_employer_contrib`
- `payslip_payment`
- `payslip_leave_snapshot`
- `payslip_ytd_snapshot`
- `payslip_audit_log`

Immutability:
- Finalized payslips should be append-only.
- Corrections must create superseding payslip records.
