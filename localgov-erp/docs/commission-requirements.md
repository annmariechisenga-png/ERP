# LGSC (Local Government Service Commission) Requirements

## Capability: Cross-council employee career visibility

The Commission needs to see, across all 116 Local Authorities:

- Employee roster, filterable by:
  - Province
  - Local authority
  - Department / section / unit
  - Position / position type
  - Salary scale / division
  - Current notch / grade
  - Length of service
  - Gender, qualification, age band
- Career progression:
  - Current appointment (post, authority, effective date)
  - Appointment history (all posts held)
  - Promotion history
  - Increment history (via employment_history)
  - Next increment eligibility
- Establishment:
  - Posts defined per authority
  - Posts filled / vacant
  - Establishment vs actual
- Audit:
  - Who approved each appointment/promotion
  - Time-to-fill for vacancies

## Design constraints

- Multi-tenant: reads must span all tenants (super-user role)
- Scale: national — tens of thousands of employees
- Audit: reads of personal data must be logged (per Data Protection Act)
- Performance: dashboard + drill-down must respond in <2s

## Design questions (open)

- Should this be a separate service/replica, or a super-tenant role?
- Which tables are the source of truth for "appointment" vs "increment"?
- What's the reporting cadence (real-time, daily, monthly)?

## Implementation notes

- A single DB view cannot serve this — needs a service layer with
  parameterised queries, or a materialised cross-tenant reporting schema.
- `v_officer_career_progression` (V20) was an early attempt; deleted
  in favor of a proper design. See git history.