from datetime import date
from typing import Any, Callable


# Inject these from your app at import time, for example:
# from your_app.models import EmployeeWorkLocation
# from your_app.geo import haversine_distance
EmployeeWorkLocation: Any = None
haversine_distance: Callable[[float, float, float, float], float] | None = None


def _resolve_dependencies():
    if EmployeeWorkLocation is None:
        raise RuntimeError("EmployeeWorkLocation is not configured in clock_in_location_validation.py")
    if haversine_distance is None:
        raise RuntimeError("haversine_distance is not configured in clock_in_location_validation.py")
    return EmployeeWorkLocation, haversine_distance


def _active_assignments_for_date(employee_work_location_model, employee_id, target_date):
    return (
        employee_work_location_model.objects.filter(
            employee_id=employee_id,
            effective_from__lte=target_date,
            effective_to__isnull=True,
        )
        | employee_work_location_model.objects.filter(
            employee_id=employee_id,
            effective_from__lte=target_date,
            effective_to__gte=target_date,
        )
    ).select_related("location")

def validate_clock_in_location(employee_id, location_lat, location_lng, clock_in_time):
    """
    Validate that employee is within an assigned geofenced location.
    """
    employee_work_location_model, distance_fn = _resolve_dependencies()
    target_date = clock_in_time.date()

    active_assignments = _active_assignments_for_date(
        employee_work_location_model,
        employee_id,
        target_date,
    )

    if not active_assignments.exists():
        return {
            "verified": False,
            "message": "No active work location assigned for this date. Contact HR.",
        }

    for assignment in active_assignments:
        location = assignment.location
        if location.latitude is None or location.longitude is None:
            continue

        distance = distance_fn(
            location_lat,
            location_lng,
            location.latitude,
            location.longitude,
        )

        geofence_radius = location.geofence_radius_meters or 0
        if distance <= geofence_radius:
            return {
                "verified": True,
                "location_id": location.id,
                "location_name": location.location_name,
                "distance_meters": round(distance, 0),
                "message": f"Clock-in verified at {location.location_name}",
            }

    closest = get_closest_location(
        employee_id=employee_id,
        lat=location_lat,
        lng=location_lng,
        reference_date=target_date,
    )

    if closest:
        message = (
            "Outside all assigned work locations. "
            f"Closest: {closest['name']} ({closest['distance']}m away)"
        )
    else:
        message = "Outside all assigned work locations. Closest: none."

    return {
        "verified": False,
        "closest_location": closest["name"] if closest else None,
        "closest_distance": closest["distance"] if closest else None,
        "message": message,
    }


def get_closest_location(employee_id, lat, lng, reference_date: date | None = None):
    """
    Find the closest assigned location for a given date.
    """
    employee_work_location_model, distance_fn = _resolve_dependencies()
    if reference_date is None:
        reference_date = date.today()

    active_assignments = _active_assignments_for_date(
        employee_work_location_model,
        employee_id,
        reference_date,
    )

    closest = None
    min_distance = float("inf")

    for assignment in active_assignments:
        location = assignment.location
        if location.latitude is None or location.longitude is None:
            continue

        distance = distance_fn(lat, lng, location.latitude, location.longitude)
        if distance < min_distance:
            min_distance = distance
            closest = {
                "id": location.id,
                "name": location.location_name,
                "distance": round(distance, 0),
            }

    return closest
