import React, { useEffect, useMemo, useState } from 'react';

export default function SalaryPlacementForm({ officerId, currentScale, currentNotch }) {
  const [selectedScale, setSelectedScale] = useState(currentScale ?? '');
  const [selectedNotch, setSelectedNotch] = useState(currentNotch ?? '');

  const [scales, setScales] = useState([]);
  const [availableNotches, setAvailableNotches] = useState([]);
  const [salaryAmount, setSalaryAmount] = useState(null);

  const [loadingScales, setLoadingScales] = useState(false);
  const [loadingNotches, setLoadingNotches] = useState(false);
  const [loadingAmount, setLoadingAmount] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    let cancelled = false;
    setLoadingScales(true);
    setError('');

    fetch('/api/salary-scales/active')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load active salary scales');
        return res.json();
      })
      .then((data) => {
        if (!cancelled) {
          setScales(Array.isArray(data) ? data : []);
        }
      })
      .catch((err) => {
        if (!cancelled) setError(err.message || 'Unable to load salary scales');
      })
      .finally(() => {
        if (!cancelled) setLoadingScales(false);
      });

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (!selectedScale) {
      setAvailableNotches([]);
      setSelectedNotch('');
      setSalaryAmount(null);
      return;
    }

    let cancelled = false;
    setLoadingNotches(true);
    setError('');
    setSelectedNotch('');
    setSalaryAmount(null);

    fetch(`/api/salary-scales/${encodeURIComponent(selectedScale)}/notches`)
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load notches for selected scale');
        return res.json();
      })
      .then((data) => {
        if (!cancelled) {
          setAvailableNotches(Array.isArray(data?.notches) ? data.notches : []);
        }
      })
      .catch((err) => {
        if (!cancelled) setError(err.message || 'Unable to load notches');
      })
      .finally(() => {
        if (!cancelled) setLoadingNotches(false);
      });

    return () => {
      cancelled = true;
    };
  }, [selectedScale]);

  useEffect(() => {
    if (!selectedScale || !selectedNotch) {
      setSalaryAmount(null);
      return;
    }

    let cancelled = false;
    setLoadingAmount(true);
    setError('');

    fetch(
      `/api/salary-scales/${encodeURIComponent(selectedScale)}/notch/${encodeURIComponent(
        selectedNotch
      )}/amount`
    )
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load official salary amount');
        return res.json();
      })
      .then((data) => {
        if (!cancelled) {
          setSalaryAmount(typeof data?.monthly_amount === 'number' ? data.monthly_amount : Number(data?.monthly_amount));
        }
      })
      .catch((err) => {
        if (!cancelled) setError(err.message || 'Unable to load salary amount');
      })
      .finally(() => {
        if (!cancelled) setLoadingAmount(false);
      });

    return () => {
      cancelled = true;
    };
  }, [selectedScale, selectedNotch]);

  const selectedScaleLabel = useMemo(() => {
    const found = scales.find((s) => s.salary_scale === selectedScale);
    return found ? `${found.salary_scale} (${found.division})` : selectedScale;
  }, [scales, selectedScale]);

  return (
    <div className="salary-placement" data-officer-id={officerId}>
      {error ? <div className="alert alert-danger">{error}</div> : null}

      <div className="form-group">
        <label>Salary Scale:</label>
        <select
          value={selectedScale}
          onChange={(e) => setSelectedScale(e.target.value)}
          className="dropdown form-control"
          disabled={loadingScales}
        >
          <option value="">{loadingScales ? 'Loading scales...' : 'Select Scale'}</option>
          {scales.map((scale) => (
            <option key={scale.salary_scale} value={scale.salary_scale}>
              {scale.salary_scale} ({scale.division})
            </option>
          ))}
        </select>
      </div>

      <div className="form-group">
        <label>Notch Number:</label>
        <select
          value={selectedNotch}
          onChange={(e) => setSelectedNotch(e.target.value)}
          className="dropdown form-control"
          disabled={!selectedScale || loadingNotches}
        >
          <option value="">{loadingNotches ? 'Loading notches...' : 'Select Notch'}</option>
          {availableNotches.map((notch) => (
            <option key={notch.notch_number} value={String(notch.notch_number)}>
              Notch {notch.notch_number}
            </option>
          ))}
        </select>
      </div>

      {loadingAmount ? <p className="text-muted">Loading official salary amount...</p> : null}

      {salaryAmount != null && !Number.isNaN(salaryAmount) ? (
        <div className="salary-display">
          <strong>Monthly Salary: ZMW {salaryAmount.toLocaleString()}</strong>
          <p className="text-muted">
            This is the official amount for {selectedScaleLabel} Notch {selectedNotch}
          </p>
        </div>
      ) : null}

      <div className="approval-section">
        <label>Approval Reference (Minute/Circular):</label>
        <input type="text" className="form-control" required />

        <label>Upload Appointment Letter:</label>
        <input type="file" accept=".pdf,.jpg" required />
      </div>
    </div>
  );
}
