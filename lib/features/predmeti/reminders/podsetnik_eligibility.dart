/// Owner-controlled active PODSETNIK eligibility.
///
/// Reminder configuration is historical/technical state and may remain stored
/// for an ineligible PREDMET. Only these two lifecycle statuses may participate
/// in active selection, due evaluation or notification scheduling.
bool isPodsetnikEligibleStatus(String status) =>
    status == 'OTVOREN' || status == 'ZATVOREN';
